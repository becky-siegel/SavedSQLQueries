DECLARE @begin_date AS DATETIME
SET @begin_date = DATEADD(DAY ,DATEDIFF(DAY ,7  ,GETDATE()) ,0) 

IF OBJECT_ID('tempdb..#lds') IS NOT NULL DROP TABLE #lds
IF OBJECT_ID('tempdb..#dk') IS NOT NULL DROP TABLE #dk

SELECT 
i.leadid
, i.leaddatecreated
, i.dayphonenumber AS ani
, u.DisplayName
INTO #lds
FROM plattform.EnterpriseODS.dbo.inquiry i (NOLOCK)
LEFT JOIN plattform.plattform_db.dbo.leadextendedinfo lei (NOLOCK)
ON lei.leadid = i.leadid
AND lei.sourcename = 'AgentID'
LEFT JOIN plattform.plattform_db.dbo.[user] u (NOLOCK)
ON u.UserID = lei.value

WHERE i.leaddatecreated >= @begin_date
AND i.affiliatelocationid = 42126
--AND i.leadid = 139115637

SELECT 
DISTINCT ir.LeadID
, ir.LeadDateCreated
, b.d_record_id 
, l.ani
, ir.tsr AS ir_agent
, b.tsr AS cl_agent
, l.DisplayName
, CHARINDEX(LEFT(l.DisplayName, 3), b.tsr) + CHARINDEX(RIGHT(l.DisplayName, 3), b.tsr) AS compare
INTO #dk
FROM LEDBI.dbo.inquiry_ref ir (NOLOCK)

LEFT JOIN #lds l
       ON l.leadid = ir.LeadID

LEFT JOIN LEDBI.dbo.BPO_call_log b
       ON b.ani = l.ani
       AND CAST(b.call_datetime AS DATE) = CAST(l.leaddatecreated AS DATE)
       AND b.call_datetime < l.leaddatecreated
       AND b.CallCenterID = 21
       AND b.STATUS = 'Sale'
       
WHERE ir.LeadDateCreated >= @begin_date
AND ir.ListCode = 'IHNV'

AND (CHARINDEX(LEFT(l.DisplayName, 3), b.tsr) + CHARINDEX(RIGHT(l.DisplayName, 3), b.tsr)) > 0

/* select all
SELECT
ir.leadid
, d.d_record_id 
FROM LEDBI.dbo.inquiry_ref ir
INNER JOIN #dk d
ON d.leadid = ir.LeadID
WHERE ir.DialerKey IS NULL
--*/


/* use this to update
update ir

set ir.dialerkey = d.d_record_id 

FROM LEDBI.dbo.inquiry_ref ir

INNER JOIN #dk d
ON d.leadid = ir.LeadID

WHERE ir.DialerKey IS NULL
--*/
