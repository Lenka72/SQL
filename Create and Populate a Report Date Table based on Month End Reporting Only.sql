USE dw_valuation;
GO

DROP TABLE IF EXISTS report_date;

CREATE TABLE dbo.report_date (ReportDate DATE NULL
                             ,DateKey BIGINT NULL
                             ,StartOfMonth DATE NULL
                             ,EndOfMonth DATE NULL
                             ,ReportMonth INT NULL
                             ,ReportYear INT NULL
                             ,DaysInMonth INT NULL
                             ,MEPeriod INT NULL
                             ,ReportMonthName VARCHAR(10) NULL
                             ,PriorReportDate DATE NULL
                             ,PriorDateKey BIGINT NULL
                             ,PriorStartOfMonth DATE NULL
                             ,PriorEndofMonth DATE NULL
                             ,PriorReportMonth INT NULL
                             ,PriorReportYear INT NULL
                             ,PriorDaysInMonth INT NULL
                             ,PriorMEPeriod INT NULL
                             ,PriorReportMonthName VARCHAR(10) NULL
                             ,IsLeapYear BIT NULL
                             ,Weekday BIT NULL
                             ,WeekEnd BIT NULL
                             ,Quarter INT NULL) ON [PRIMARY];
GO
;



-- populate the dbo.report_date table with the new data
WITH ReportDate AS (SELECT      DATEADD(DAY, -1, DATEADD(MONTH, SPV.number + 1, CAST('20000101' AS DATE)))                                    AS ReportDate
                               ,CONVERT(VARCHAR(8), DATEADD(d, -1, DATEADD(MONTH, SPV.number + 1, CAST('20000101' AS DATE))), 112)            AS DateKey
                               ,DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))                                                          AS StartOfMonth
                               ,DATEADD(DAY, -1, DATEADD(MONTH, SPV.number + 1, CAST('20000101' AS DATE)))                                    AS EndOfMonth
                               ,MONTH(DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE)))                                                   AS ReportMonth
                               ,YEAR(DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE)))                                                    AS ReportYear
                               ,DAY(DATEADD(DAY, -1, DATEADD(MONTH, SPV.number + 1, CAST('20000101' AS DATE))))                               AS DaysInMonth
                               ,LEFT(CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, SPV.number + 1, CAST('20000101' AS DATE))), 112), 6) AS MEPeriod
                               ,DATEADD(DAY, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE)))                                        AS PriorReportDate
                               ,CONVERT(VARCHAR(8), DATEADD(d, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))), 112)                AS PriorDateKey
                               ,DATEADD(MONTH, SPV.number - 1, CAST('20000101' AS DATE))                                                      AS PriorStartOfMonth
                               ,DATEADD(DAY, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE)))                                        AS PriorEndofMonth
                               ,MONTH(DATEADD(DAY, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))))                                 AS PriorReportMonth
                               ,YEAR(DATEADD(DAY, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))))                                  AS PriorReportYear
                               ,DAY(DATEADD(DAY, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))))                                   AS PriorDaysInMonth
                               ,LEFT(CONVERT(VARCHAR(8), DATEADD(d, -1, DATEADD(MONTH, SPV.number, CAST('20000101' AS DATE))), 112), 6)       AS PriorMEPeriod
                    FROM        master.dbo.spt_values SPV
                    WHERE       SPV.type = 'P')
    ,ReportDateFinal AS (SELECT         SPV.ReportDate
                                       ,SPV.DateKey
                                       ,SPV.StartOfMonth
                                       ,SPV.EndOfMonth
                                       ,SPV.ReportMonth
                                       ,SPV.ReportYear
                                       ,SPV.DaysInMonth
                                       ,SPV.MEPeriod
                                       ,DATENAME(MONTH, SPV.ReportDate)      AS ReportMonthName
                                       ,SPV.PriorReportDate
                                       ,SPV.PriorDateKey
                                       ,SPV.PriorStartOfMonth
                                       ,SPV.PriorEndofMonth
                                       ,SPV.PriorReportMonth
                                       ,SPV.PriorReportYear
                                       ,SPV.PriorDaysInMonth
                                       ,SPV.PriorMEPeriod
                                       ,DATENAME(MONTH, SPV.PriorReportDate) AS PriorReportMonthName
                                       ,LYC.IsLeapYear
                                       ,SDW.WeekDay
                                       ,SDW.WeekEnd
                                       ,SDW.Quarter
                         FROM           ReportDate                                 SPV
                         CROSS   APPLY
                                        (SELECT         DISTINCT       CASE
                                                                               WHEN RD.DaysInMonth = 29 THEN 1
                                                                               ELSE    0
                                                                       END AS IsLeapYear
                                         FROM           ReportDate RD
                                         WHERE          RD.ReportYear = SPV.ReportYear
                                                        AND     RD.ReportMonth = 2) LYC
                         CROSS   APPLY
                                        (SELECT         CASE
                                                                WHEN DATEPART(WEEKDAY, RD.ReportDate) IN (2, 3, 4, 5, 6) THEN 1
                                                                ELSE    0
                                                        END                              AS WeekDay
                                                       ,CASE
                                                                WHEN DATEPART(WEEKDAY, RD.ReportDate) IN (1, 7) THEN 1
                                                                ELSE    0
                                                        END                              AS WeekEnd
                                                       ,DATEPART(QUARTER, RD.ReportDate) AS Quarter
                                         FROM           ReportDate RD
                                         WHERE          RD.ReportDate = SPV.ReportDate) SDW )
INSERT INTO     dbo.report_date
(ReportDate
,DateKey
,StartOfMonth
,EndOfMonth
,ReportMonth
,ReportYear
,DaysInMonth
,MEPeriod
,ReportMonthName
,PriorReportDate
,PriorDateKey
,PriorStartOfMonth
,PriorEndofMonth
,PriorReportMonth
,PriorReportYear
,PriorDaysInMonth
,PriorMEPeriod
,PriorReportMonthName
,IsLeapYear
,Weekday
,WeekEnd
,Quarter)
SELECT                  RD1.ReportDate
                       ,RD1.DateKey
                       ,RD1.StartOfMonth
                       ,RD1.EndOfMonth
                       ,RD1.ReportMonth
                       ,RD1.ReportYear
                       ,RD1.DaysInMonth
                       ,RD1.MEPeriod
                       ,RD1.ReportMonthName
                       ,RD1.PriorReportDate
                       ,RD1.PriorDateKey
                       ,RD1.PriorStartOfMonth
                       ,RD1.PriorEndofMonth
                       ,RD1.PriorReportMonth
                       ,RD1.PriorReportYear
                       ,RD1.PriorDaysInMonth
                       ,RD1.PriorMEPeriod
                       ,RD1.PriorReportMonthName
                       ,RD1.IsLeapYear
                       ,RD1.WeekDay
                       ,RD1.WeekEnd
                       ,RD1.Quarter
FROM                    ReportDateFinal    RD1
LEFT    OUTER JOIN      dbo.reporting_date RD2
ON RD2.DateKey = RD1.DateKey
WHERE                   RD2.DateKey IS NULL;

IF NOT EXISTS
        (SELECT         *
         FROM           sys.indexes I
         WHERE          I.name = 'IDX_report_date_C'
                        AND    I.object_id = OBJECT_ID('reporting_date'))
        CREATE CLUSTERED INDEX IDX_report_date_C
        ON dbo.report_date (DateKey ASC)
        WITH    (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO