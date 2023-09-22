SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF OBJECT_ID('tempdb..#thresholds') IS NOT NULL DROP TABLE #thresholds
IF OBJECT_ID('tempdb..#counts') IS NOT NULL DROP TABLE #counts
IF OBJECT_ID('tempdb..#lookup') IS NOT NULL DROP TABLE #lookup
IF OBJECT_ID('tempdb..#connects') IS NOT NULL DROP TABLE #connects
IF OBJECT_ID('tempdb..#staging') IS NOT NULL DROP TABLE #staging
IF OBJECT_ID('tempdb..#final') IS NOT NULL DROP TABLE #final

CREATE TABLE #thresholds (callcenter INT, limit INT)
INSERT INTO #thresholds (callcenter, limit) values
(17, 5000), (17, 4000), (17, 3000), (17, 2250), (17, 2000), (17, 1500), (17, 1000), (17, 750), (17, 250),
(1, 1100), (1, 880), (1, 660), (1, 495), (1, 440), (1, 330), (1, 220), (1, 165), (1, 55);

WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
INTO #counts
FROM x ones,     x tens,      x hundreds,       x thousands

SELECT
    lookupTable.counts,
    CASe WHEN dataTable.callcenter = 17 THEN dataTable.limit END AS IA_Limit,
	CASE WHEN dataTable.callcenter = 1 THEN dataTable.limit END AS LE_Limit
INTO #lookup
    FROM #thresholds  dataTable RIGHT JOIN
    ( SELECT 
		DISTINCT c.counts AS counts
		, max(t.limit) AS maxCount
		FROM #counts c
		LEFT JOIN #thresholds t
		ON c.counts >= t.limit
		GROUP by c.counts
    ) as lookupTable
    ON lookupTable.maxCount = dataTable.limit
ORDER BY lookupTable.counts


SELECT
distinct r.Call_Date
, r.tsr
, r.call_center_id
, SUM(r.tot_connects) AS connects
INTO #connects
FROM LEDBI.dbo.Realtime r (NOLOCK)
INNER JOIN LEDBI.dbo.tsrmaster t (NOLOCK)
	ON t.tsr = r.tsr
WHERE r.hire_date >= DATEADD(MONTH, -12, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
AND r.call_center_id IN (1, 17)
GROUP BY r.tsr, r.Call_Date, r.call_center_id
ORDER BY r.tsr, r.Call_Date

SELECT 
c.*
, SUM(c.connects) OVER (PARTITION BY c.tsr ORDER BY c.call_date) AS rolling_connects
INTO #staging
FROM #connects c

SELECT s.*  
, ISNULL(CASE WHEN s.call_center_id = 1 THEN l.LE_Limit ELSE l.IA_Limit END, 0) AS threshold
, RANK () OVER (PARTITION BY s.tsr, CASE WHEN s.call_center_id = 1 THEN l.LE_Limit ELSE l.IA_Limit END
		 ORDER BY s.call_date) AS date_hit
INTO #final
FROM #staging s
LEFT JOIN #lookup l
	ON l.counts = s.rolling_connects
INNER JOIN LEDBI.dbo.tsrmaster t (NOLOCK)
	ON t.tsr = s.tsr
ORDER BY s.tsr, s.Call_Date

SELECT 
f.tsr AS AgentID
, t.sname AS AgentName
, f.call_center_id
, DATEDIFF(DAY, t.hire_date, f.Call_Date) AS DaysTenure
, t.address2 AS TeamManager
, f.rolling_connects AS LiftetimeConnects
, f.threshold AS ThresholdMet
FROM #final f
INNER JOIN ledbi.dbo.tsrmaster t (nolock)
on t.tsr = f.tsr
WHERE f.threshold > 0
AND f.date_hit = 1
AND f.Call_Date = CAST(GETDATE() AS DATE)
--AND t.CallCenterID = 1  --LE report
--AND t.CallCenterID = 17  --IA report
ORDER BY f.call_center_id, f.tsr