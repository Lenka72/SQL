USE RandomActsOfSQL
GO

/****** Object:  StoredProcedure dls.usp_process_history_start_job    Script Date: 9/7/2018 11:54:20 PM ******/
DROP PROCEDURE IF EXISTS dbo.usp_process_history_start_job
GO

/****** Object:  StoredProcedure dls.usp_process_history_start_job    Script Date: 9/7/2018 11:54:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ================================================
-- Author:		Elaena Bakman		 
-- Create date: 09/04/2018
-- Description:	provided this works, use this 
-- stored procedure to log the start of a process
-- from the first step of a job.
-- To call this stored procedure from inside the job
-- step, use EXECUTE dbo.usp_process_history_start_job   $(ESCAPE_SQUOTE(JOBID));
-- Update:		
-- ================================================

CREATE PROCEDURE dbo.usp_process_history_start_job (
        @JobId UNIQUEIDENTIFIER)
AS
BEGIN
        SET NOCOUNT ON; 

        INSERT INTO dbo.process_history
        (ProcessName
        ,ProcessId
		,UserId
        ,StartedDateTime)
        SELECT  name AS ProcessName
               ,job_id AS ProcessId
			   ,REPLACE(SUSER_SNAME(),'PNMAC\','')
               ,GETDATE() AS StartedDateTime
        FROM    msdb.dbo.sysjobs
        WHERE   job_id = @JobId;
END;
GO


