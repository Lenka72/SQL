USE [dw_valuation]
GO

/****** Object:  View [dbo].[vw_partition_detail]    Script Date: 2/22/2018 6:20:37 PM ******/
DROP VIEW [dbo].[vw_partition_detail]
GO

/****** Object:  View [dbo].[vw_partition_detail]    Script Date: 2/22/2018 6:20:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ================================================
-- Author:		Elaena Bakman 
-- Create date: 02/07/2017
-- Description:	This view will allow us to see the 
-- partitoin function, scheme and index related information
-- for a given table.
-- Update:		
-- ================================================
CREATE VIEW [dbo].[vw_partition_detail]
AS
    SELECT  PF.name AS PartitionFunctName
           ,PF.function_id AS PartitionFunctionId
           ,OBJECT_NAME(P.object_id) AS TableName
           ,P.object_id AS TableObjectId
           ,S.PartitionSchemeName
           ,I.name AS IndexName
           ,I.type_desc AS IndexTypeDescription
           ,CAST(IIF(I.type = 1, 1, 0) AS BIT) AS IsClustered
           ,P.partition_number AS PartitionNumber
           ,PRV.value AS PartitionValue
           ,P.rows AS PartitionRowCount
    FROM    sys.partition_functions PF WITH (NOLOCK)
    INNER JOIN sys.partition_range_values PRV WITH (NOLOCK)
    ON      PRV.function_id = PF.function_id
    INNER JOIN sys.partitions P WITH (NOLOCK)
    ON      P.partition_number = PRV.boundary_id
    INNER JOIN sys.indexes I WITH (NOLOCK)
    ON      I.index_id = P.index_id
            AND I.object_id = P.object_id
    CROSS APPLY (SELECT PS.name AS PartitionSchemeName
                 FROM   sys.partition_schemes PS WITH (NOLOCK)
                 WHERE  PS.data_space_id = I.data_space_id
                        AND PS.function_id = PF.function_id
                        AND PS.type = 'PS'
                ) S
    WHERE   I.type = 1;
GO


