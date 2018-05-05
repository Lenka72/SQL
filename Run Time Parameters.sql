USE dw_valuation;
GO

--============================================
-- Use Shift+Ctrl+"M" to set the Template 
-- Parameter Values. 
--============================================

WITH ObjectType AS (SELECT  IQ.ObjectType
                           ,IQ.ObjectTypeDescription
                    FROM    (VALUES
                                     (20, 'Project Parameter')
                                    ,(30, 'Package Parameter')) IQ (ObjectType, ObjectTypeDescription) )
    ,ReferenceType AS (SELECT   IQ.ReferenceType
                               ,IQ.ReferenceTypeDescription
                       FROM     (VALUES
                                         ('R', 'Relative Rference')
                                        ,('A', 'Absolute Reference')) IQ (ReferenceType, ReferenceTypeDescription) )
SELECT          OT.ObjectTypeDescription
               ,E.folder_name AS FolderName
               ,E.project_name AS ProjectName
               ,E.package_name AS PackageName
               ,EPV.parameter_data_type AS ParameterDataType
               ,EPV.parameter_name AS ParameterName
               ,EPV.parameter_value AS ParameterValue
               ,RT.ReferenceTypeDescription
               ,E.executed_as_name
FROM            SSISDB.catalog.execution_parameter_values EPV
INNER   JOIN    SSISDB.catalog.executions E
ON E.execution_id = EPV.execution_id
INNER   JOIN    ObjectType OT
ON OT.ObjectType = EPV.object_type
INNER   JOIN    ReferenceType RT
ON RT.ReferenceType = E.reference_type
WHERE           EPV.value_set = 1
                AND E.execution_id = <ExecutionId, INT, NULL>;
