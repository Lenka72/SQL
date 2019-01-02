USE RandomActsOfSQL
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_delete_partition]    Script Date: 12/28/2018 12:35:16 PM ******/
DROP PROCEDURE dbo.usp_partitioned_table_delete_partition
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_delete_partition]    Script Date: 12/28/2018 12:35:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ================================================
-- Author:		E. Bakman   
-- Create date: 09/08/2016
-- Description:	Delete the partition of a partitioned table.
-- Update:		
-- ================================================
CREATE PROCEDURE dbo.usp_partitioned_table_delete_partition (@DateKey BIGINT
,@TableName VARCHAR(255))
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @PartitionNumber INT
		   ,@Rows INT
		   ,@SQL NVARCHAR(4000);

		SELECT  @Rows = VPD.PartitionRowCount
			   ,@PartitionNumber = VPD.PartitionNumber
		FROM    dbo.vw_partition_detail VPD
		WHERE VPD.TableName = @TableName
		AND VPD.PartitionValue = @DateKey;

		IF @PartitionNumber IS NOT NULL
			AND @Rows != 0
		BEGIN
			SET @SQL = 'TRUNCATE TABLE dbo.' + @TableName + ' 
			WITH ( PARTITIONS  (' + CAST(@PartitionNumber AS VARCHAR(10)) + '));';
                        EXECUTE sys.sp_executesql @SQL;

		END 

    END;



GO


