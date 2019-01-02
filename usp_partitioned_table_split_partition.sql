USE RandomActsOfSQL
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_split_partition]    Script Date: 12/28/2018 12:37:03 PM ******/
DROP PROCEDURE dbo.usp_partitioned_table_split_partition
GO

/****** Object:  StoredProcedure [dbo].[usp_partitioned_table_split_partition]    Script Date: 12/28/2018 12:37:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ================================================
-- Author:		E. Bakman 
-- Create date: 02/03/2017
-- Description:	This will split out partition for the new date that was just added
-- Update:		
-- ================================================
CREATE PROCEDURE dbo.usp_partitioned_table_split_partition (@DateKey BIGINT
	,@TableName VARCHAR(255))
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @SQL NVARCHAR(4000)
           ,@PartitionFunctionName VARCHAR(255)
           ,@PartitionSchemeName VARCHAR(255);


        IF EXISTS ( 
		SELECT DISTINCT
                            1
                    FROM    sys.partitions P
                    WHERE   P.object_id = OBJECT_ID(@TableName)
					 )
            BEGIN 
                IF NOT EXISTS ( SELECT  1
                                FROM    dbo.vw_partition_detail VPD
                                WHERE   VPD.TableName = @TableName
                                        AND VPD.PartitionValue = @DateKey )
                    BEGIN 
                        SELECT DISTINCT
                                @PartitionFunctionName = VPD.PartitionFunctName
                               ,@PartitionSchemeName = VPD.PartitionSchemeName
                        FROM    dbo.vw_partition_detail VPD
                        WHERE   VPD.TableName = @TableName;
                        SET @SQL = CONCAT('ALTER PARTITION SCHEME ', @PartitionSchemeName, ' NEXT USED [PRIMARY];');
                        EXECUTE sys.sp_executesql @SQL;

                        SET @SQL = CONCAT('ALTER PARTITION FUNCTION ', @PartitionFunctionName, '() SPLIT RANGE(', @DateKey, ');');
                        EXECUTE sys.sp_executesql @SQL;
                    END;	
            END;

    END;



GO


