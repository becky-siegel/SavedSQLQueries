SET NOCOUNT ON

IF OBJECT_ID('tempdb..#pct') IS NOT NULL DROP TABLE #pct
IF OBJECT_ID('tempdb..#tte') IS NOT NULL DROP TABLE #tte


DECLARE @begin_date AS DATETIME
DECLARE @end_date AS DATETIME
SET @begin_date = '2017-08-01'
SET @end_date = '2018-10-11'

SELECT 
  pct.DialerKey
, pct.CAProspectID
, EnrollTime.NAME AS EnrollTime

INTO #pct
FROM 
Plattform.Plattform_DB.dbo.ProspectCallTracker pct (nolock)

LEFT JOIN plattform.plattform_db.dbo.caprospect cap WITH (NOLOCK)
	ON pct.caprospectid = cap.caprospectid
	AND cap.receiveddate >= @begin_date

LEFT JOIN Plattform.Plattform_DB.dbo.ListValue EnrollTime WITH (NOLOCK)
	ON EnrollTime.ListValueID = cap.EnrollTime

WHERE
pct.CreatedDateTime >= @begin_date
AND pct.CreatedDateTime < @end_date

SELECT 
  DISTINCT c.ani AS Phone
, p.EnrollTime AS TTE
, CAST(c.call_datetime AS DATE) AS ReceivedDate
, ISNULL(COUNT(DISTINCT ir.LeadID),0) AS lead_submitted
, ISNULL(COUNT(DISTINCT CASE WHEN irm.leadid IS NOT NULL THEN irm.leadid END),0) AS moat_lead
, CASE WHEN ir.leadid IS NOT NULL THEN 1 ELSE 0 END AS conversion
INTO #tte
FROM 
LEDBI.dbo.call_log c WITH (NOLOCK)

LEFT JOIN #pct p	
	ON p.DialerKey = c.d_record_id

LEFT JOIN LEDBI.dbo.inquiry_ref ir WITH (NOLOCK)
	ON ir.DialerKey = c.d_record_id
	AND ir.tsr = c.tsr
	AND ir.LeadDateCreated >= @begin_Date

LEFT JOIN LEDBI.dbo.inquiry_ref irm WITH (NOLOCK)
	ON irm.DialerKey = c.d_record_id
	AND irm.tsr = c.tsr
	AND irm.LeadDateCreated >= @begin_Date
	AND irm.SourceType = 'ExternalTransfer'

LEFT JOIN LEDBI.dbo.appl_info ai
	ON ai.appl = c.appl

WHERE c.call_datetime >= @begin_date
AND c.call_datetime < @end_Date
AND ai.IsStep1 = 0
AND p.EnrollTime IS NOT NULL
AND c.ani NOT IN ('','0000000000','1266696687')

GROUP BY 
  c.ani 
, p.EnrollTime 
, CAST(c.call_datetime AS DATE) 
, CASE WHEN ir.leadid IS NOT NULL THEN 1 ELSE 0 END 
, CASE WHEN irm.leadid IS NOT NULL THEN 1 ELSE 0 END 


INSERT INTO scratch.dbo.cap_tte
SELECT * FROM #tte
