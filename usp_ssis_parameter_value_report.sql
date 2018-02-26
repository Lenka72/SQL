USE [dw_valuation]
GO

/****** Object:  StoredProcedure [dbo].[usp_ssis_parameter_value_report]    Script Date: 2/25/2018 9:29:19 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[usp_ssis_parameter_value_report]
GO

/****** Object:  StoredProcedure [dbo].[usp_ssis_parameter_value_report]    Script Date: 2/25/2018 9:29:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ================================================
-- Author:		Elaena Bakman		 
-- Create date: 05/02/107
-- Description:	This stored procedure will show the 
-- package and project level parameters associated 
-- WITH SSIS packages.
-- Update:		
-- ================================================

CREATE PROCEDURE [dbo].[usp_ssis_parameter_value_report] (
        @FolderName NVARCHAR(MAX) = NULL
       ,@ProjectName NVARCHAR(MAX) = NULL
       ,@PackageName NVARCHAR(MAX) = NULL
       ,@UserId dtUserId)
AS
BEGIN
        SET NOCOUNT ON;

        DECLARE @Result INT;

        --================================================================================================================================
        --==                                             This section will handle report security                                       ==
        --================================================================================================================================
        EXEC @Result = dbo.usp_security_report_level_access 0
                                                           ,@UserId
                                                           ,'SSIS Parameter Value Report'
                                                           ,NULL;

        IF @Result = 0
                RETURN;

        --================================================================================================================================
        --==                                                   End of Security Section                                                  ==
        --================================================================================================================================

        WITH Unassigned AS (SELECT  F.name AS FolderName
                                   ,'Not Assigned' AS ProjectNamme
                                   ,'Not Assigned' AS PackageName
                                   ,E.created_time AS ProjectLastDeployedDateTime
                                   ,'Unassigned' AS ParameterName
                                   ,'Not Assigned' AS ParameterDataType
                                   ,'Not Assigned' AS ParameterDesignDefaultValue
                                   ,'Not Assigned' AS ParameterReferencedVariableName
                                   ,EV.name AS EnvironmentVariableName
                                   ,EV.description AS EnvironmentVariableDescription
                                   ,EV.type AS EnvironmentVariableType
                                   ,EV.value AS EnvironmentVariableValue
                                   ,'Unassigned' AS VariableLevel
                            FROM    SSISDB.catalog.environment_variables EV
                            INNER   JOIN SSISDB.catalog.environments E
                            ON E.environment_id = EV.environment_id
                            INNER   JOIN SSISDB.catalog.folders F
                            ON F.folder_id = E.folder_id
                            LEFT    OUTER JOIN SSISDB.catalog.object_parameters OP
                            ON OP.referenced_variable_name = EV.name
                            WHERE   OP.parameter_id IS NULL)
        SELECT  F.name AS FolderName
               ,P.name AS ProjectName
               ,P2.name AS PackageName
               ,P.last_deployed_time AS ProjectLastDeployedDateTime
               ,COALESCE(OP2.parameter_name, OP1.parameter_name) AS ParameterName
               ,COALESCE(OP2.data_type, OP1.data_type) AS ParameterDataType
               ,COALESCE(OP2.design_default_value, OP1.design_default_value) AS ParameterDesignDefaultValue
               ,COALESCE(OP2.referenced_variable_name, OP1.referenced_variable_name) AS ParameterReferencedVariableName
               ,COALESCE(EV2.name, EV1.name) AS EnvironmentVariableName
               ,COALESCE(EV2.description, EV1.description) AS EnvironmentVariableDescription
               ,COALESCE(EV2.type, EV1.type) AS EnvironmentVariableType
               ,COALESCE(EV2.value, EV1.value) AS EnvironmentVariableValue
               ,CASE
                        WHEN EV2.name IS NULL THEN 'Project Variable'
                        ELSE    'Package Variable'
                END AS VariableLevel
        FROM    SSISDB.catalog.folders F
        INNER   JOIN SSISDB.catalog.environments E
        ON E.folder_id = F.folder_id
        INNER   JOIN SSISDB.catalog.projects P
        ON P.folder_id = F.folder_id
        INNER   JOIN SSISDB.catalog.packages P2
        ON P2.project_id = P.project_id
        LEFT    OUTER JOIN SSISDB.catalog.object_parameters OP1
        ON OP1.object_name = P.name
           AND  OP1.object_type = 20
           AND  OP1.value_type = 'R'
        LEFT    OUTER JOIN SSISDB.catalog.environment_variables EV1
        ON EV1.name = OP1.referenced_variable_name
           AND  EV1.environment_id = E.environment_id
        LEFT    OUTER JOIN SSISDB.catalog.object_parameters OP2
        ON OP2.object_name = P2.name
           AND  OP2.object_type = 30
           AND  OP2.value_type = 'R'
        LEFT    OUTER JOIN SSISDB.catalog.environment_variables EV2
        ON EV2.name = OP2.referenced_variable_name
           AND  EV2.environment_id = E.environment_id
        WHERE   F.name = ISNULL(@FolderName, F.name)
                AND P.name = ISNULL(@ProjectName, P.name)
                AND P2.name = ISNULL(@PackageName, P2.name)
        UNION
        SELECT  U.FolderName
               ,U.ProjectNamme
               ,U.PackageName
               ,U.ProjectLastDeployedDateTime
               ,U.ParameterName
               ,U.ParameterDataType
               ,U.ParameterDesignDefaultValue
               ,U.ParameterReferencedVariableName
               ,U.EnvironmentVariableName
               ,U.EnvironmentVariableDescription
               ,U.EnvironmentVariableType
               ,U.EnvironmentVariableValue
               ,U.VariableLevel
        FROM    Unassigned U
        WHERE   U.FolderName = ISNULL(@FolderName, U.FolderName)
                AND U.ProjectNamme = ISNULL(@ProjectName, U.ProjectNamme)
                AND U.PackageName = ISNULL(@PackageName, U.PackageName)
        ORDER BY    FolderName
                   ,ProjectName
                   ,PackageName
                   ,EnvironmentVariableName
                   ,EnvironmentVariableValue;
END;
GO


