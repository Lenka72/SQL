USE [dw_valuation]
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_merge_partition]    Script Date: 12/28/2018 12:36:37 PM ******/
DROP PROCEDURE [dbo].[usp_partitioned_table_merge_partition]
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_merge_partition]    Script Date: 12/28/2018 12:36:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ================================================
-- Author:		Elaena Bakman		 
-- Create date: 04/07/2017
-- Description:	Use this to merge partitions in a 
-- partitioned table.  When you delete a partition
-- as part of a daily purge, the partition is emptied
-- out, but it does not get removed.  In order to 
-- actually remove it, you'd have to call the ALTER 
-- PARTITION MERGE RANGE function.
-- Update:		
-- ================================================
CREATE PROCEDURE [dbo].[usp_partitioned_table_merge_partition]
    (
     @DateKey BIGINT
    ,@TableName VARCHAR(255)
    )
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @PartitionFunctName VARCHAR(255)
           ,@SQL NVARCHAR(4000)
           ,@ErrorMessage VARCHAR(500);

        SET @PartitionFunctName = (SELECT   VPD.PartitionFunctName
                                   FROM     dbo.vw_partition_detail VPD
                                   WHERE    VPD.TableName = @TableName
                                            AND VPD.PartitionValue = @DateKey
                                            AND VPD.PartitionRowCount = 0  -- this is important, don't merge it if it's not 0 you will end up with bad daily counts
                                  );

        IF @PartitionFunctName IS NOT NULL
            BEGIN

                SET @SQL = N'ALTER PARTITION FUNCTION ' + @PartitionFunctName + ' ()
        MERGE RANGE (' + CAST(@DateKey AS CHAR(8)) + ');';
                EXECUTE sys.sp_executesql @SQL;
            END;	
        ELSE
            BEGIN
                SET @ErrorMessage = 'Error: Unable to find a partition to merge based on provided parameters.  Either your table is not partitioned or the partition you requested to merge was not empty.';
                RAISERROR(@ErrorMessage, 16, 1);
                RETURN;
            END;
    END;	
GO


