USE SSISDB
GO 

--===============================================================================
-- Use Shift+Ctrl+"M" to populat the Project Name and the ISPAC Name values
--===============================================================================
-- Project Name - the name of the project the package is being deployed into
-- ISPAC - the file path minus the extension since that is hard coded here.
--===============================================================================

PRINT 'Deploying <Project Name, VARCHAR(500), NULL> - Time: ' + CONVERT(VARCHAR(25), GETDATE(), 131);
GO 

DECLARE @ProjectBinary AS VARBINARY(MAX)
       ,@OperationId AS BIGINT
       ,@ProjectName NVARCHAR(128)
       ,@FolderName NVARCHAR(128);

SET @ProjectName = '<Project Name, VARCHAR(500), NULL>';
SET @FolderName =
(SELECT     F.name
 FROM       catalog.projects P
 INNER   JOIN catalog.folders F
 ON F.folder_id = P.folder_id
 WHERE      P.name = @ProjectName);


SET @ProjectBinary =
(SELECT     *
 FROM
            OPENROWSET(BULK
                    '<ISPAC, VARCHAR(MAX), NULL>.ispac'
                   ,SINGLE_BLOB)
            AS BinaryData );

EXEC catalog.deploy_project @folder_name = @FolderName
                           ,@project_name = @ProjectName
                           ,@project_stream = @ProjectBinary
                           ,@operation_id = @OperationId OUT;
GO

PRINT 'Finished deploying <Project Name, VARCHAR(500), NULL>  - Time: ' + CONVERT(VARCHAR(25), GETDATE(), 131);
GO 



