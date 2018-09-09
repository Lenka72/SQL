USE RandomActsOfSQL;
GO

ALTER TABLE dbo.report_format DROP CONSTRAINT DF_report_format_FontWeight;
GO

/****** Object:  Table [dbo].[report_format]    Script Date: 9/9/2018 12:15:22 PM ******/
DROP TABLE IF EXISTS dbo.report_format;
GO

/****** Object:  Table [dbo].[report_format]    Script Date: 9/9/2018 12:15:22 PM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE dbo.report_format (ReportFormatId INT IDENTITY(1, 1) NOT NULL
                               ,StyleName VARCHAR(25) NOT NULL
                               ,FontFamily VARCHAR(50) NOT NULL
                               ,FontSize VARCHAR(5) NOT NULL
                               ,FontWeight BIT NOT NULL
                               ,BackgroundColor VARCHAR(10) NULL
                               ,FontColor VARCHAR(10) NULL
                               ,CONSTRAINT PK_report_format PRIMARY KEY CLUSTERED (ReportFormatId ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY];
GO

ALTER TABLE dbo.report_format
ADD     CONSTRAINT DF_report_format_FontWeight DEFAULT ((0)) FOR FontWeight;
GO
;

WITH ReportStyle AS (SELECT     IQ.StyleName
                               ,IQ.FontFamily
                               ,IQ.FontSize
                               ,IQ.FontWeight
                               ,IQ.BackgroundColor
                               ,IQ.FontColor
                     FROM       (VALUES
                                         ('Heading1', 'Calibri', '24pt', 1, NULL, '#678996')
                                        ,('Heading2', 'Calibri', '12pt', 0, NULL, '#678996')
                                        ,('Heading3', 'Calibri', '11pt', 1, NULL, '#678996')
                                        ,('Heading4', 'Calibri', '11pt', 0, NULL, '#678996')
                                        ,('Heading5', 'Calibri', '10pt', 1, NULL, '#678996')
                                        ,('TableHeading', 'Calibri', '11pt', 1, '#678996', '#FFFFFF')
                                        ,('TableSubLevel1', 'Calibri', '10pt', 0, '#BDBDBD', '#000000')
                                        ,('TableSubLevel2', 'Calibri', '10pt', 0, '#E0E0E0', '#000000')
                                        ,('TableSubLevel3', 'Calibri', '10pt', 0, NULL, '#000000')
                                        ,('TableCellWarning', 'Calibri', '10pt', 0, '#FFEBEE', '#BB2124')
                                        ,('TableAlternatingRows', 'Calibri', '10pt', 0, '#E0E0E0', '#000000')
                                        ,('BodyText', 'Calibri', '10pt', 0, NULL, '#000000')
                                        ,('BodyTextWarning', 'Calibri', '10pt', 0, NULL, '#BB2124')
                                        ,('BodyTextSuccess', 'Calibri', '10pt', 0, NULL, '#4CAF50')
                                        ,('Buttons', 'Calibri', '10ptv', 1, '#678996', '#FFFFFF')
                                        ,('TableCurrentRow', 'Calibri', '10pt', 0, '#FFE57F', '#000000')
                                        ,('TableHeadingSubLevel', 'Calibri', '10pt', 1, '#235378', '#FFFFFF')
                                        ,('BodyTextSubLevel', 'Calibri', '8pt', 0, NULL, '#84888F')
                                        ,('MainMenu', 'Calibri', '14ptv', 0, NULL, '#678996')) IQ (StyleName, FontFamily, FontSize, FontWeight, BackgroundColor, FontColor) )
INSERT INTO dbo.report_format
(StyleName
,FontFamily
,FontSize
,FontWeight
,BackgroundColor
,FontColor)
SELECT              RS.StyleName
                   ,RS.FontFamily
                   ,RS.FontSize
                   ,RS.FontWeight
                   ,RS.BackgroundColor
                   ,RS.FontColor
FROM                ReportStyle RS
LEFT    OUTER JOIN  dbo.report_format RF
ON RS.StyleName = RF.StyleName
WHERE               RF.ReportFormatId IS NULL;
