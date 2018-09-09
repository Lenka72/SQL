USE RandomActsOfSQL
GO

/****** Object:  Table dbo.process_history    Script Date: 9/9/2018 12:09:40 PM ******/
DROP TABLE dbo.process_history
GO

/****** Object:  Table dbo.process_history    Script Date: 9/9/2018 12:09:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.process_history(
	ProcessHistoryId bigint IDENTITY(1,1) NOT NULL,
	ProcessName varchar(255) NOT NULL,
	ProcessId sysname NULL,
	UserId dbo.dtUserId NULL,
	StartedDateTime datetime NOT NULL,
	EndedDateTime datetime NULL,
	JobOutcome varchar(25) NULL,
	ErrorMessage varchar(max) NULL,
 CONSTRAINT PK_process_history PRIMARY KEY CLUSTERED 
(
	ProcessHistoryId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON PRIMARY
) ON PRIMARY TEXTIMAGE_ON PRIMARY
GO


