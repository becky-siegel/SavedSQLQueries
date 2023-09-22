--All Data
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @today AS DATETIME
SET @today = '2020-09-24'  --CAST(GETDATE() AS DATE)
-- need to make this work for any day
	
DECLARE @begin_date AS DATETIME
SET @begin_date = DATEADD(MONTH, -3, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
DECLARE @end_date AS DATETIME
SET @end_date = CAST(GETDATE() AS DATE)

IF OBJECT_ID('tempdb..#LEHistory') IS NOT NULL DROP TABLE #LEHistory
IF OBJECT_ID('tempdb..#LXHistory') IS NOT NULL DROP TABLE #LXHistory
IF OBJECT_ID('tempdb..#BPOHistory') IS NOT NULL DROP TABLE #BPOHistory
IF OBJECT_ID('tempdb..#IAHistory') IS NOT NULL DROP TABLE #IAHistory
IF OBJECT_ID('tempdb..#IAFinalHistory') IS NOT NULL DROP TABLE #IAFinalHistory

IF OBJECT_ID('tempdb..#act_rev') IS NOT NULL DROP TABLE #act_rev
IF OBJECT_ID('tempdb..#act_cost') IS NOT NULL DROP TABLE #act_cost
IF OBJECT_ID('tempdb..#bpo_wages') IS NOT NULL DROP TABLE #bpo_wages
IF OBJECT_ID('tempdb..#wages_by_day') IS NOT NULL DROP TABLE #wages_by_day
IF OBJECT_ID('tempdb..#wage_rate') IS NOT NULL DROP TABLE #wage_rate

IF OBJECT_ID('tempdb..#max_hour') IS NOT NULL DROP TABLE #max_hour
IF OBJECT_ID('tempdb..#through_hour') IS NOT NULL DROP TABLE #through_hour
IF OBJECT_ID('tempdb..#inday_staging') IS NOT NULL DROP TABLE #inday_staging


SELECT
DATENAME(WEEKDAY, i.call_datetime) AS dow
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) AS call_date
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) AS hour_interval
, ai.VendorName
, i.call_center_id
, CAST(CAST(SUM(i.time_connect + i.time_acwork) AS FLOAT) /60 AS FLOAT)/60 AS call_hours
, SUM(CASE WHEN cl.IsConnect = 1 THEN 1 ELSE 0 END) AS connects		
, SUM(ir.revenue) AS revenue
INTO #IAHistory
FROM ledbi.dbo.CallLog i (NOLOCK)
INNER JOIN LEDBI.dbo.CallLogStatusMapping cl (NOLOCK)
	ON cl.CallLogStatus = i.STATUS
	AND cl.IsConnect = 1
LEFT JOIN LEDBI.dbo.APPL_MasterDetail ai (NOLOCK)
	ON ai.APPL = i.appl
	AND ai.IsActive = 1
LEFT JOIN (
	SELECT
	DISTINCT DialerKey
	, SUM(ir.UnauditedRevenue) AS revenue
	FROM LEDBI.dbo.inquiry_ref ir (NOLOCK)
	WHERE ir.LeadDateCreated >= @begin_date
	AND ir.LeadDateCreated < @end_date
	GROUP by DialerKey ) ir
	ON ir.DialerKey = i.d_record_id
WHERE i.call_datetime >= @begin_date
AND i.call_datetime < @end_date
AND DATEPART(HOUR, i.call_datetime) >= 7
AND i.time_connect > 0
AND i.call_center_id = 17
GROUP BY
  DATENAME(WEEKDAY, i.call_datetime)
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) 
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) 
, ai.VendorName
, i.call_center_id



SELECT
DATENAME(WEEKDAY, i.call_datetime) AS dow
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) AS call_date
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) AS hour_interval
, i.appl
, i.call_center_id
, CAST(CAST(SUM(i.time_connect + i.time_acwork) AS FLOAT) /60 AS FLOAT)/60 AS call_hours
, SUM(CASE WHEN cl.IsConnect = 1 THEN 1 ELSE 0 END) AS connects		
, 0 AS revenue
INTO #BPOHistory
FROM ledbi.dbo.CallLog i (NOLOCK)
LEFT JOIN LEDBI.dbo.CallLogStatusMapping cl (NOLOCK)
	ON cl.CallLogStatus = i.STATUS
LEFT JOIN LEDBI.dbo.APPL_MasterDetail ai (NOLOCK)
	ON ai.APPL = i.appl
	AND ai.IsActive = 1
LEFT JOIN (
	SELECT
	DISTINCT DialerKey
	, SUM(ir.UnauditedRevenue) AS revenue
	FROM LEDBI.dbo.inquiry_ref ir (NOLOCK)
	WHERE ir.LeadDateCreated >= @begin_date
	AND ir.LeadDateCreated < @end_date
	GROUP by DialerKey ) ir
	ON ir.DialerKey = i.d_record_id
INNER JOIN LEDBI.dbo.CallCenter cc (NOLOCK)
	ON cc.CallCenterID = i.call_center_id
	AND cc.IsBPO = 1
WHERE i.call_datetime >= @begin_date
AND i.call_datetime < @end_date
AND DATEPART(HOUR, i.call_datetime) >= 8

GROUP BY
  DATENAME(WEEKDAY, i.call_datetime)
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) 
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) 
, i.appl
, i.call_center_id


SELECT
DATENAME(WEEKDAY, i.call_datetime) AS dow
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) AS call_date
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) AS hour_interval
, i.appl
, i.call_center_id
, CAST(CAST(SUM(i.time_connect + i.time_acwork) AS FLOAT) /60 AS FLOAT)/60 AS call_hours
, SUM(CASE WHEN cl.IsConnect = 1 THEN 1 ELSE 0 END) AS connects		
, SUM(ir.revenue) AS revenue
INTO #LXHistory
FROM ledbi.dbo.CallLog i (NOLOCK)
LEFT JOIN LEDBI.dbo.CallLogStatusMapping cl (NOLOCK)
	ON cl.CallLogStatus = i.STATUS
LEFT JOIN LEDBI.dbo.APPL_MasterDetail ai (NOLOCK)
	ON ai.APPL = i.appl
	AND ai.IsActive = 1
LEFT JOIN (
	SELECT
	DISTINCT DialerKey
	, SUM(ir.UnauditedRevenue) AS revenue
	FROM LEDBI.dbo.inquiry_ref ir (NOLOCK)
	WHERE ir.LeadDateCreated >= @begin_date
	AND ir.LeadDateCreated < @end_date
	GROUP by DialerKey ) ir
	ON ir.DialerKey = i.d_record_id

WHERE i.call_datetime >= @begin_date
AND i.call_datetime < @end_date
AND DATEPART(HOUR, i.call_datetime) >= 8
AND i.call_center_id = 1
GROUP BY
  DATENAME(WEEKDAY, i.call_datetime)
, DATEADD(DAY ,DATEDIFF(DAY ,0 ,i.call_datetime) ,0) 
, (DATEPART(HOUR, i.call_datetime)*100) + 
	(CASE
	WHEN DATEPART(MINUTE, i.call_datetime) < 15 THEN 0
	WHEN DATEPART(MINUTE, i.call_datetime) < 30 THEN 15
	WHEN DATEPART(MINUTE, i.call_datetime) < 45 THEN 30
	WHEN DATEPART(MINUTE, i.call_datetime) >= 45 THEN 45 
	ELSE NULL END) 
, i.appl
, i.call_center_id


SELECT
distinct l.dow
, 'Liquid Education' AS BusinessUnit
, l.call_center_id
, l.appl
, hour_interval
, SUM(call_hours) OVER (PARTITION BY l.dow, l.appl, l.call_center_id ORDER BY l.hour_interval) / tt.dow_hrs_tot AS hours_pct
, SUM(connects * 1.00) OVER (PARTITION BY l.dow, l.appl, l.call_center_id ORDER BY l.hour_interval) / tt.dow_conn_tot AS conn_pct
, SUM(revenue) OVER (PARTITION BY l.dow, l.appl, l.call_center_id ORDER BY l.hour_interval) / tt.dow_rev_tot AS rev_pct
INTO #LEHistory
FROM #LXHistory l
LEFT JOIN (
	SELECT DISTINCT DOW, appl, SUM(call_hours) AS dow_hrs_tot, SUM(connects) AS dow_conn_tot, SUM(revenue) AS dow_rev_tot
	FROM #LXHistory 
	GROUP BY DOW, appl) tt
	ON tt.dow = l.dow AND tt.appl = l.appl
WHERE tt.dow_conn_tot > 100
GROUP BY l.dow, l.call_center_id, l.appl, hour_interval, call_hours, tt.dow_hrs_tot, connects, tt.dow_conn_tot, revenue, tt.dow_rev_tot
UNION
SELECT
distinct b.dow
, 'Liquid Education' AS BusinessUnit
, b.call_center_id
, b.appl
, hour_interval
, SUM(call_hours) OVER (PARTITION BY b.dow, b.appl, b.call_center_id ORDER BY b.hour_interval) / tt.dow_hrs_tot AS hours_pct
, SUM(connects * 1.00) OVER (PARTITION BY b.dow, b.appl, b.call_center_id ORDER BY b.hour_interval) / tt.dow_conn_tot AS conn_pct
, 0 AS rev_pct
FROM #BPOHistory b
LEFT JOIN (
	SELECT DISTINCT DOW, appl, call_center_id, SUM(call_hours) AS dow_hrs_tot, SUM(connects) AS dow_conn_tot, SUM(revenue) AS dow_rev_tot
	FROM #BPOHistory 
	GROUP BY DOW, appl, call_center_id) tt
	ON tt.dow = b.dow AND tt.appl = b.appl
	AND tt.call_center_id = b.call_center_id
WHERE tt.dow_conn_tot > 100
GROUP BY b.dow, b.appl, b.call_center_id, hour_interval, call_hours, tt.dow_hrs_tot, connects, tt.dow_conn_tot, revenue, tt.dow_rev_tot
ORDER BY l.dow, l.appl, l.call_center_id, l.hour_interval


SELECT
distinct i.dow
, 'Inside Academics' AS BusinessUnit
, i.call_center_id
, i.VendorName
, hour_interval
, SUM(call_hours * 1.00) OVER (PARTITION BY i.dow, i.VendorName ORDER BY i.hour_interval) / tt.dow_hrs_tot AS hours_pct
, SUM(connects * 1.00) OVER (PARTITION BY i.dow, i.VendorName ORDER BY i.hour_interval) / tt.dow_conn_tot AS conn_pct
, SUM(revenue * 1.00) OVER (PARTITION BY i.dow, i.VendorName ORDER BY i.hour_interval) / tt.dow_rev_tot AS rev_pct
INTO #IAFinalHistory
FROM #IAHistory i
LEFT JOIN (
	SELECT DISTINCT DOW, VendorName, SUM(call_hours) AS dow_hrs_tot, SUM(connects) AS dow_conn_tot, SUM(revenue) AS dow_rev_tot
	FROM #IAHistory 
	GROUP BY DOW, VendorName) tt
	ON tt.dow = i.dow AND tt.VendorName = i.VendorName
WHERE tt.dow_conn_tot > 100
GROUP BY i.dow, i.VendorName, i.call_center_id, hour_interval, call_hours, tt.dow_hrs_tot, connects, tt.dow_conn_tot, revenue, tt.dow_rev_tot
ORDER BY i.dow, i.VendorName, hour_interval

SELECT 
  r.Call_Date
, r.appl
, a.VendorName
, r.call_center_id
, SUM(r.UnauditedRevenue) AS actual_revenue
, SUM(r.time_total) AS total_hours
, SUM(r.time_productive) AS prod_time
INTO #act_rev
FROM LEDBI.dbo.Realtime r (NOLOCK)
INNER JOIN LEDBI.dbo.APPL_MasterDetail a (NOLOCK)
	ON a.appl = r.appl
	AND a.IsActive = 1
WHERE r.Call_Date = @today
GROUP BY r.Call_Date, r.appl, a.VendorName, r.call_center_id



SELECT 
DISTINCT ba_ListCode
, ISNULL(cost_to_callcenter_id, a.CallCenterID) AS CallCenterID
, SUM(ba_NetPayableAmount) as list_cost
INTO #act_cost
FROM highlander_d.dbo.enterprise_billableactionpayabledetail det (NOLOCK)
LEFT JOIN LEDBI.dbo.APPL_MasterDetail a (NOLOCK)
	ON a.APPL = det.ba_ListCode
	AND a.IsActive = 1
WHERE cast(action_timestamp as date) = @today
GROUP BY ba_ListCode, isnull(cost_to_callcenter_id, a.callcenterid)


SELECT 
DISTINCT a.call_center_id
, a.call_date
, CASE WHEN a.call_center_id = 49 and ac.agent_group = 'live' THEN 10
	WHEN a.call_center_id = 49 and ac.agent_group = 'LX' THEN 6
	WHEN a.call_center_id = 49 and ac.agent_group = 'OB' THEN 6
	WHEN a.call_center_id = 59 THEN 15
	WHEN a.call_center_id = 70 THEN 11
	WHEN a.call_center_id = 72 THEN 7
	ELSE 10 END * CAST(CAST(SUM(CASE WHEN a.call_center_id = 49 THEN a.time_connect
	ELSE a.time_connect + a.time_deassigned + a.time_acw END) /60 AS FLOAT) /60 AS FLOAT) 
		AS billable_hours
INTO #bpo_wages
FROM LEDBI.dbo.AgentTime a (NOLOCK)
INNER JOIN LEDBI.dbo.CallCenter c (NOLOCK)
	ON c.CallCenterID = a.call_center_id
	AND c.IsBPO = 1
INNER JOIN (
	SELECT DISTINCT c.tsr,
	CASE WHEN c.agent_group = 'live' THEN c.agent_group
	ELSE LEFT(c.agent_group, 2) END AS agent_group
	FROM LEDBI.dbo.CallLog c
	INNER JOIN LEDBI.dbo.CallCenter cc
	ON cc.CallCenterID = c.call_center_id 
	AND cc.IsBPO = 1
	WHERE CAST(call_datetime AS DATE) = @today
	) ac ON ac.tsr = a.agent_id
WHERE a.call_date = @today
GROUP BY a.call_center_id, a.call_date, ac.agent_group


SELECT
DISTINCT t.CallCenterID
, DATENAME(WEEKDAY, p.[date]) AS DOW
, SUM(p.Amount) AS wages
INTO #wages_by_day
FROM LEDBI.dbo.TimecardPaycom p (NOLOCK)
INNER JOIN LEDBI.dbo.TSRMGR t (NOLOCK)
	ON t.Payroll_ID = p.EECode
	AND t.Day_Date = p.[Date]
WHERE p.[Date] >= @begin_date
AND p.[Date] < @end_date
GROUP BY 
t.CallCenterID
, DATENAME(WEEKDAY, p.[Date])

SELECT
DISTINCT r.call_center_id
, DATENAME(WEEKDAY, r.call_date) AS dow
, w.wages/sum(r.time_total) AS avg_per_hour
into #wage_rate
FROM LEDBI.dbo.Realtime r (NOLOCK)
LEFT JOIN #wages_by_day w
	ON w.CallCenterID = r.call_center_id
	AND w.DOW = DATENAME(WEEKDAY, r.call_date)
WHERE r.Call_Date >= @begin_date
AND r.Call_Date < @end_date
AND r.call_center_id IN (1, 17)
GROUP BY 
r.call_center_id
, DATENAME(WEEKDAY, r.call_date) 
, w.wages
ORDER BY 
r.call_center_id
, DATENAME(WEEKDAY, r.call_date) 


SELECT CAST(cc.call_datetime as date) as call_date, max(datepart(hour, cc.call_datetime)) AS max_hour
INTO #max_hour
FROM LEDBI.dbo.CallLog cc (NOLOCK)
WHERE CAST(cc.call_datetime AS DATE) = @today
AND cc.tsr <> ''
group by cast(cc.call_datetime as date)

SELECT
DISTINCT c.call_center_id
, CAST(c.call_datetime AS DATE) AS call_date
, (DATEPART(HOUR, MAX(c.call_datetime))*100) + 
   (CASE
	WHEN DATEPART(MINUTE, MAX(c.call_datetime)) < 15 THEN 0
	WHEN DATEPART(MINUTE, MAX(c.call_datetime)) < 30 THEN 15
	WHEN DATEPART(MINUTE, MAX(c.call_datetime)) < 45 THEN 30
	WHEN DATEPART(MINUTE, MAX(c.call_datetime)) >= 45 THEN 45 
	ELSE NULL END) AS hour_interval
, MAX(DATEPART(HOUR, c.call_Datetime)) AS through_hour
INTO #through_hour  
FROM LEDBI.dbo.CallLog c (NOLOCK)
WHERE CAST(c.call_datetime AS DATE) = @today
AND c.tsr <> ''
GROUP BY C.call_center_id, CAST(c.call_datetime AS date)


SELECT 
a.call_date
, cc.[Name] AS CallCenter
, CASE WHEN a.call_center_id = 17 THEN 'Inside Academics' ELSE 'Liquid Education' END AS business_unit
, a.appl
, a.VendorName
, a.call_center_id
, a.actual_revenue
, ISNULL(c.list_cost, 0) 
	* (1 + ((m.max_hour - lc.through_hour) * 0.10))  
	AS list_cost
, ISNULL(CASE WHEN a.appl = 'Agnt' THEN b.bpo_Wages ELSE 0 END, 0) 
	* (1 + ((m.max_hour - lc.through_hour) * 0.10)) 
	AS bpo_wages
, ISNULL(w.avg_per_hour * a.total_hours, 0) * 
	CASE WHEN a.call_center_id = 1 THEN
		CASE WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Saturday' THEN 1.5 ELSE 1.4 END
	WHEN a.call_center_id = 17 THEN
		CASE WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Monday' THEN 2
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Tuesday' THEN 1.95
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Wednesday' THEN 1.85
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Thursday' THEN 1.75
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Friday' THEN 1.15 END
	ELSE 0 END AS wages
, ISNULL(NULLIF(a.actual_revenue,0) 
	/ ISNULL(ISNULL(lh.rev_pct, ih.rev_pct), df.default_pct),0) AS proj_rev 
, ISNULL((NULLIF(c.list_cost, 0) 
	* (1 + ((m.max_hour - lc.through_hour) * 0.10)))
	/ ISNULL(ISNULL(lh.conn_pct, ih.conn_pct), df.default_pct),0) AS proj_list_cost
, ISNULL((NULLIF(CASE WHEN a.appl = 'Agnt' THEN b.bpo_Wages ELSE 0 END, 0) 
	* (1 + ((m.max_hour - lc.through_hour) * 0.10)) )
	/ ISNULL(ISNULL(lh.hours_pct, ih.hours_pct), df.default_pct),0) AS proj_bpo_wages
, ISNULL((NULLIF(w.avg_per_hour * a.total_hours, 0) * 
	CASE WHEN a.call_center_id = 1 THEN
		CASE WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Saturday' THEN 1.5 ELSE 1.4 END
	WHEN a.call_center_id = 17 THEN
		CASE WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Monday' THEN 2
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Tuesday' THEN 1.95
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Wednesday' THEN 1.85
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Thursday' THEN 1.75
		WHEN DATENAME(WEEKDAY, a.Call_Date) = 'Friday' THEN 1.15 END
	ELSE 0 END)
	/ ISNULL(ISNULL(lh.hours_pct, ih.hours_pct), df.default_pct),0) AS proj_wages
INTO #inday_staging
FROM #act_rev a
LEFT JOIN LEDBI.dbo.CallCenter cc (NOLOCK)
	ON cc.CallCenterID = a.call_center_id
LEFT JOIN #act_cost c
	ON c.ba_ListCode = a.appl
	AND c.CallCenterID = a.call_center_id
LEFT JOIN (
	SELECT
	b.call_center_id
	, b.call_date
	, SUM(b.billable_hours) AS bpo_Wages
	FROM  #bpo_wages b
	GROUP BY b.call_center_id, b.call_date) b
	ON b.call_center_id = a.call_center_id
	AND b.call_date = a.Call_Date
LEFT JOIN #wage_rate w
	ON w.call_center_id = a.call_center_id
	AND w.dow = DATENAME(WEEKDAY, a.call_date)
LEFT JOIN #through_hour lc
	ON lc.call_center_id = a.call_center_id
	AND lc.call_date = a.Call_Date
LEFT JOIN #max_hour M
	ON m.call_date = a.Call_Date
LEFT JOIN #LEHistory lh
	ON (lh.call_center_id = a.call_center_id
	AND lh.appl = a.appl
	AND lh.dow = DATENAME(WEEKDAY, a.Call_Date)
	AND lh.hour_interval = lc.hour_interval
	AND lh.call_center_id = lc.call_center_id)
LEFT JOIN #IAFinalHistory ih
	ON (ih.call_center_id = a.call_center_id
	AND ih.VendorName = a.VendorName
	AND ih.dow = DATENAME(WEEKDAY, a.Call_Date)
	AND ih.hour_interval = lc.hour_interval
	AND ih.call_center_id = lc.call_center_id)
LEFT JOIN (
		SELECT
		t.call_center_id
		, t.call_date
		, ISNULL(MAX(i.hours_pct), MAX(l.hours_pct)) AS default_pct
		FROM #through_hour t
		LEFT JOIN  #IAFinalHistory i
			ON i.call_center_id = t.call_center_id
			AND i.dow = datename(weekday, t.call_date)
			AND i.hour_interval = t.hour_interval
		LEFT JOIN #LEHistory l
			ON l.call_center_id = t.call_center_id
			AND l.dow = datename(weekday, t.call_date)
			AND l.hour_interval = t.hour_interval
		GROUP BY t.call_center_id, t.call_date) df
		ON df.call_center_id = a.call_center_id
		AND df.call_date = a.Call_Date
ORDER BY a.call_center_id, a.appl


----Liquid Education
--SELECT 
--DISTINCT CallCenter
--, Call_Date
--, CASE WHEN call_center_id = 1 THEN 
--	CASE WHEN appl = 'Agnt' THEN 'NonProductiveTime' ELSE appl END
--	ELSE CallCenter END AS appl
--, SUM(actual_revenue) AS Revenue
--, SUM(list_cost + bpo_wages) AS ListCost
--, SUM(wages) AS Wages
--, SUM(proj_rev) AS ProjRevenue
--, SUM(proj_list_cost + proj_bpo_wages) AS ProjListCost
--, SUM(proj_wages) AS ProjWages
--FROM #inday_staging 
--WHERE business_unit = 'Liquid Education'
--GROUP BY 
--  CallCenter
--, Call_Date
--, CASE WHEN call_center_id = 1 THEN 
--	CASE WHEN appl = 'Agnt' THEN 'NonProductiveTime' ELSE appl END
--	ELSE CallCenter END 

----Inside Academics
SELECT 
DISTINCT CallCenter
, Call_Date
, CASE WHEN VendorName = 'NA' THEN 'NonProductiveTime' ELSE VendorName END AS VendorName
, SUM(actual_revenue) AS Revenue
, SUM(list_cost) AS ListCost
, SUM(wages) AS Wages
, SUM(proj_rev) AS ProjRevenue
, SUM(proj_list_cost) AS ProjListCost
, SUM(proj_wages) AS ProjWages
FROM #inday_staging i
WHERE i.business_unit = 'Inside Academics'
GROUP BY 
i.CallCenter
, Call_Date
, CASE WHEN VendorName = 'NA' THEN 'NonProductiveTime' ELSE VendorName END