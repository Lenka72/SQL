USE RandomActsOfSQL;
GO

/****** Object:  StoredProcedure dbo.usp_process_history_end_job    Script Date: 9/8/2018 12:38:12 AM ******/
DROP PROCEDURE IF EXISTS dbo.usp_process_history_end_job;
GO

/****** Object:  StoredProcedure dbo.usp_process_history_end_job    Script Date: 9/8/2018 12:38:12 AM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ================================================
-- Author:		Elaena Bakman		 
-- Create date: 09/04/2018
-- Description:	provided this works, use this 
-- stored procedure to log the end of a process
-- from the first step of a job.
-- To call this stored procedure from inside the job
-- step, use EXECUTE dbo.usp_process_history_end_job   $(ESCAPE_SQUOTE(JOBID));
-- Update:		
-- ================================================

CREATE PROCEDURE dbo.usp_process_history_end_job (
        @JobId UNIQUEIDENTIFIER)
AS
BEGIN
        SET NOCOUNT ON;

        WITH MostRecentProcess AS (SELECT   CAST(MAX(PH.ProcessHistoryId) AS SMALLDATETIME) AS ProcessHistoryId
                                   FROM     dbo.process_history PH
                                   WHERE    PH.ProcessId =
                                   (SELECT  job_id
                                    FROM    msdb.dbo.sysjobs
                                    WHERE   job_id = @JobId
                                            AND PH.EndedDateTime IS NULL))
            ,JobOutcome AS (SELECT          JSH.job_id
                                           ,MIN(    JSH.run_status) AS LastRunOutcome
                            FROM            msdb.dbo.sysjobhistory JSH
                            CROSS   APPLY   (SELECT CAST(STR(JSH.run_date, 8, 0) AS DATETIME) + CAST(STUFF(STUFF(RIGHT('000000' + CAST(JSH.run_time AS VARCHAR(6)), 6), 5, 0, ':'), 3, 0, ':') AS DATETIME) AS StartDatetime) CALC(StartDateTime)
                            WHERE           JSH.job_id = @JobId
                                            AND CALC.StartDateTime >=
                                            (SELECT         DATEADD(SECOND, -1, CAST(PH.StartedDateTime AS DATETIME2(0))) AS StartedDateTime
                                             FROM           dbo.process_history PH
                                             INNER   JOIN   MostRecentProcess MRP
                                             ON MRP.ProcessHistoryId = PH.ProcessHistoryId)
                            GROUP BY        JSH.job_id)
        UPDATE          PH
        SET             PH.EndedDateTime = GETDATE()
                       ,PH.ErrorMessage = dbo.fn_get_job_failed_error_message(PH.ProcessName)
                       ,PH.JobOutcome = CASE
                                                WHEN JO.LastRunOutcome = 0 THEN 'Failed'
                                                WHEN JO.LastRunOutcome = 1 THEN 'Succeeded'
                                                WHEN JO.LastRunOutcome = 2 THEN 'Retry'
                                                WHEN JO.LastRunOutcome = 3 THEN 'Canceled'
                                                WHEN JO.LastRunOutcome = 4 THEN 'In Progress'
                                                WHEN JO.LastRunOutcome = 5 THEN 'Unknown'
                                                ELSE    'N/A'
                                        END
        FROM            dbo.process_history PH
        INNER   JOIN    MostRecentProcess MRP
        ON MRP.ProcessHistoryId = PH.ProcessHistoryId
        INNER   JOIN    JobOutcome JO
        ON JO.job_id = PH.ProcessId;
END;
GO