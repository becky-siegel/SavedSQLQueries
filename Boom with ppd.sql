-- DO NOT CHANGE THESE LINES ---------------------------------------------------
    SET NOCOUNT ON
    DECLARE @begin_date DATETIME = '{begin_date}'
    DECLARE @end_date DATETIME = '{end_date}'
--------------------------------------------------------------------------------
DECLARE @call_center_id INT = 49
DECLARE @ppd AS DATETIME = '2023-03-05'  --Sunday 

IF OBJECT_ID('tempdb..#actual_billable') IS NOT NULL DROP TABLE #actual_billable

IF OBJECT_ID('tempdb..#BPO_scales') IS NOT NULL DROP TABLE #BPO_scales
IF OBJECT_ID('tempdb..#counts') IS NOT NULL DROP TABLE #counts
IF OBJECT_ID('tempdb..#lookup') IS NOT NULL DROP TABLE #lookup
IF OBJECT_ID('tempdb..#performance') IS NOT NULL DROP TABLE #performance
IF OBJECT_ID('tempdb..#rate') IS NOT NULL DROP TABLE #rate


select
begin_date, call_center_id, agent_group, KPI, tier
, case when KPI = 'WLPH' THEN tier_value * 100
	WHEN KPI = 'MONT_RATE' THEN tier_value * 10000
	ELSE tier_value END as tier_value
, tier_payout
into #bpo_scales
from ledbi.dbo.bpo_scales
where call_center_id = @call_center_id; 


	WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
	SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
	INTO #counts
	FROM x ones,     x tens,      x hundreds,       x thousands

	SELECT
		lookupTable.counts,
		CASe WHEN dataTable.agent_group = 'LX_IA' THEN dataTable.tier_value END AS IA_Limit,
		CASE WHEN dataTable.agent_group = 'LX' THEN dataTable.tier_value END AS LX_Limit
		INTO #lookup
		FROM #BPO_scales  dataTable RIGHT JOIN
		( SELECT 
			DISTINCT c.counts AS counts
			, max(t.tier_value) AS maxCount
			FROM #counts c
			LEFT JOIN #BPO_scales t
			ON c.counts >= t.tier_value
			GROUP by c.counts
		) as lookupTable
		ON lookupTable.maxCount = dataTable.tier_value
	ORDER BY lookupTable.counts	


	SELECT 
	distinct tsr
	, Agent_Type AS agent_group
	, DATEADD(DAY, -DATEDIFF(DAY, @ppd, call_date)%7, call_date) as payable_period
	, r.call_center_id
	, NULLIF(((sum(r.tot_lts) * 2.5) + (sum(r.CVX) * 2.5) + sum(r.tot_cfs)),0) / sum(r.time_productive) AS WLPH
	, NULLIF(SUM(tot_converts_step1)*1.0,0) / SUM(tot_calls) AS MONT_RATE
	INTO #performance
	FROM LEDBI.dbo.Realtime r (nolock)
	WHERE r.Call_Date >= @begin_date
	and r.Call_Date < CAST(GETDATE() AS DATE)
	and call_center_id = @call_center_id
	group by r.tsr, DATEADD(DAY, -DATEDIFF(DAY, @ppd, call_date)%7, call_date), Agent_Type, r.call_center_id


	SELECT 
	distinct p.tsr, p.payable_period
	, CASE WHEN p.agent_group = 'LX_IA' AND d.bonus_eligible = 1 THEN  b.tier_payout 
		WHEN p.agent_group = 'LX' AND d.bonus_eligible = 1 THEN bb.tier_payout
		WHEN d.bonus_eligible = 0 THEN base.tier_payout
		ELSE 0 END AS Rate
	, d.bonus_eligible
	INTO #rate
	FROM #performance p
	
	LEFT JOIN (
		SELECT DISTINCT counts
		, MAX(ISNULL(IA_Limit,0)) AS WLPH
		FROM #lookup 
		GROUP BY counts) wlph
		ON wlph.counts = (ROUND(ISNULL(p.WLPH,0) *100,0))
		AND p.agent_group = 'LX_IA'
	LEFT JOIN #BPO_scales b
	ON b.tier_value = wlph.WLPH
	AND b.KPI = 'wlph'
	
	LEFT JOIN (
		SELECT DISTINCT counts
		, MAX(ISNULL(LX_Limit,0)) AS mont
		FROM #lookup 
		GROUP BY counts) mont
		ON mont.counts = (ROUND(isnull(p.MONT_RATE,0) * 10000,0))
		AND p.agent_group = 'LX'
	LEFT JOIN #BPO_scales bb
	ON bb.tier_value = mont.mont
	AND bb.KPI = 'MONT_RATE'

LEFT JOIN (
	SELECT DISTINCT DATEADD(DAY, -DATEDIFF(DAY, @ppd, d.call_Date)%7, call_date) AS ppd
	, call_center_id
	, agent_group
	, MAX(bonus_eligible) AS bonus_eligible
	FROM ledbi.dbo.DailyGoals d
	WHERE d.call_Date >= @begin_date
	GROUP BY DATEADD(DAY, -DATEDIFF(DAY, @ppd, d.call_Date)%7, call_date) 
	, call_center_id
	, agent_group) d
	ON d.ppd = p.payable_period
	AND d.agent_group = p.agent_group
	AND d.call_center_id = p.call_center_id

LEFT JOIN #BPO_scales base
	ON base.agent_group = p.agent_group
	AND base.tier = 1


--/*
 SELECT
          CASE WHEN b.agent_group = 'LX_IA' THEN 'BPO_Hours_BPO_IA'
		  WHEN b.agent_group = 'LX' THEN 'BPO_Hours_Step_1'
		  ELSE 'Error' END AS ext_datasource
        , CONCAT(b.agent_id,'_',b.call_date,'_',b.agent_group)     AS ext_uid 
        , b.call_center_id AS callcenter_id
         , b.call_date          AS action_timestamp 
         , CASE WHEN b.agent_group = 'LX_IA' THEN 'COSTBOOMIA'
		  WHEN b.agent_group = 'LX' THEN 'COSTBOOM'
		  ELSE 'Error' END AS listcode
		, CAST(CAST(SUM(b.time_connect + b.time_deassigned + b.time_acw)/60 AS FLOAT) /60 AS FLOAT) AS payable_qty
		, CAST(CAST(SUM(b.time_connect + b.time_deassigned + b.time_acw)/60 AS FLOAT) /60 AS FLOAT) *  r.Rate AS payable_amount

		, r.Rate
		, b.agent_group

	FROM ledbi.dbo.AgentTime b (NOLOCK)

	LEFT JOIN #rate r
	ON r.payable_period = DATEADD(DAY, -DATEDIFF(DAY, @ppd, b.call_date)%7, b.call_date) 
	AND r.tsr = b.agent_id

	WHERE b.call_date >= @begin_date
	AND b.call_date < @end_date
    AND b.call_date <> CAST(GETDATE() AS DATE)
	AND DATENAME(WEEKDAY, b.call_date) NOT IN ('Saturday', 'Sunday')
	AND b.call_center_id = @call_center_id
	AND b.time_connect > 0
	AND b.agent_group NOT IN ('EF_OB_AV', 'EF_OB', 'LXP')

	GROUP BY
	  b.call_date
	, CONCAT(b.agent_id,'_',b.call_date,'_',b.agent_group)     
	, b.call_center_id
	, b.agent_group
	, r.Rate
--*/