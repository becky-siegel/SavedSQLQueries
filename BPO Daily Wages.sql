USE [LEDBI]
GO

/****** Object:  StoredProcedure [dbo].[usp_BPO_daily_rate_Touchstone]    Script Date: 8/29/2023 2:31:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

























ALTER PROCEDURE [dbo].[usp_BPO_daily_rate_Touchstone]

AS

DECLARE @call_center_id INT = 72
DECLARE @ppd AS DATETIME = '2023-03-05'  

DECLARE @last_month AS DATETIME = DATEADD(DAY, 1, EOMONTH(DATEADD(MONTH, -2, CAST(GETDATE() AS DATE))))
DECLARE @begin_date DATETIME = DATEADD(DAY, 0, DATEADD(DAY, -DATEDIFF(DAY, @ppd, @last_month)%7, @last_month))
DECLARE @end_date DATETIME = cast(getdate() as date)

DELETE FROM LEDBI.dbo.bpo_daily_agent_rate 
WHERE call_date >= @begin_date AND call_date < @end_date and call_center_id = @call_center_id

IF OBJECT_ID('tempdb..#actual_billable') IS NOT NULL DROP TABLE #actual_billable
IF OBJECT_ID('tempdb..#BPO_scales') IS NOT NULL DROP TABLE #BPO_scales
IF OBJECT_ID('tempdb..#counts') IS NOT NULL DROP TABLE #counts
IF OBJECT_ID('tempdb..#lookup') IS NOT NULL DROP TABLE #lookup

IF OBJECT_ID('tempdb..#BPO_scales2') IS NOT NULL DROP TABLE #BPO_scales2
IF OBJECT_ID('tempdb..#counts2') IS NOT NULL DROP TABLE #counts2
IF OBJECT_ID('tempdb..#lookup2') IS NOT NULL DROP TABLE #lookup2

IF OBJECT_ID('tempdb..#BPO_scales3') IS NOT NULL DROP TABLE #BPO_scales3
IF OBJECT_ID('tempdb..#counts3') IS NOT NULL DROP TABLE #counts3
IF OBJECT_ID('tempdb..#lookup3') IS NOT NULL DROP TABLE #lookup3

IF OBJECT_ID('tempdb..#BPO_scales_ef') IS NOT NULL DROP TABLE #BPO_scales_ef
IF OBJECT_ID('tempdb..#counts_ef') IS NOT NULL DROP TABLE #counts_ef
IF OBJECT_ID('tempdb..#lookup_ef') IS NOT NULL DROP TABLE #lookup_ef

IF OBJECT_ID('tempdb..#performance') IS NOT NULL DROP TABLE #performance
IF OBJECT_ID('tempdb..#qa_Stage') IS NOT NULL DROP TABLE #qa_stage
IF OBJECT_ID('tempdb..#qa') IS NOT NULL DROP TABLE #qa
IF OBJECT_ID('tempdb..#rate_stage') IS NOT NULL DROP TABLE #rate_stage
IF OBJECT_ID('tempdb..#rate') IS NOT NULL DROP TABLE #rate



select 
distinct DATEADD(DAY, 7, DATEADD(DAY, -DATEDIFF(DAY, @ppd, s.call_date)%7, s.call_date)) as ppd
, s.tsr
, sum(new_step2_pass_fail) as pass
, sum(new_step2_score_count*1.0) as counts
into #qa_stage
from ledbi.dbo.ScoreCard_Overall_2019 s (nolock)
inner join ledbi.dbo.CallCenter cc (nolock)
	on cc.callcenterid = s.call_center_id
	and cc.IsBPO = 1
where call_date >= '2023-04-24'
and call_date < @end_date
group by DATEADD(DAY, 7, DATEADD(DAY, -DATEDIFF(DAY, @ppd, s.call_date)%7, s.call_date))
, s.tsr
UNION
SELECT DISTINCT 
DATEADD(DAY, 7, DATEADD(DAY, -DATEDIFF(DAY, @ppd, cast(c.call_datetime as date))%7, cast(c.call_datetime as date))) as ppd
, c.tsr
, COUNT(DISTINCT CASE WHEN q.QualityScore >= 100 THEN q.DialerSessionID END) as pass
, COUNT(DISTINCT q.DialerSessionID) AS counts

FROM ledbi.dbo.leadHOOP_QualityLeads q (NOLOCK) 

LEFT JOIN ledbi.dbo.CallLog c
	ON c.d_record_id = q.dialersessionid

WHERE c.call_datetime >= @begin_date
GROUP BY c.tsr, cast(c.call_Datetime as date) 

select 
distinct tsr
, ppd
, sum(pass)/sum(counts) as qa_score
into #qa
from #qa_stage
group by tsr, ppd





select
begin_date, isnull(end_date, cast(getdate() as date)) as end_date, call_center_id, agent_group, KPI, tier
, case when KPI = 'WLPH' THEN tier_value * 100
	WHEN KPI = 'MONT_RATE' THEN tier_value * 10000
	ELSE tier_value END as tier_value
, tier_payout
into #bpo_scales
from ledbi.dbo.bpo_scales
where call_center_id = @call_center_id
AND agent_group IN ('LX_IA')
AND (end_date IS NULL or end_date <= @end_date); 


	WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
	SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
	INTO #counts
	FROM x ones,     x tens,      x hundreds,       x thousands

	SELECT
		lookupTable.counts
		, dataTable.begin_date
		, ISNULL(dataTable.end_date, CAST(GETDATE() AS DATE)) AS end_date
		,CASE WHEN dataTable.agent_group = 'LX_IA' THEN dataTable.tier_value END AS IA_Limit
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



select
begin_date, isnull(end_date, cast(getdate() as date)) as end_date, call_center_id, agent_group, KPI, tier
, case when KPI = 'WLPH' THEN tier_value * 100
	WHEN KPI = 'MONT_RATE' THEN tier_value * 10000
	ELSE tier_value END as tier_value
, tier_payout
into #bpo_scales2
from ledbi.dbo.bpo_scales
where call_center_id = @call_center_id
and agent_group IN ('LX') 
and (end_date IS NULL or end_date <= @end_date); 


	WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
	SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
	INTO #counts2
	FROM x ones,     x tens,      x hundreds,       x thousands

	SELECT
		lookupTable.counts
		, dataTable.begin_date
		, ISNULL(dataTable.end_date, CAST(GETDATE() AS DATE)) AS end_date
		,CASE WHEN dataTable.agent_group = 'LX' THEN dataTable.tier_value END AS LX_Limit
		INTO #lookup2
		FROM #BPO_scales2  dataTable RIGHT JOIN
		( SELECT 
			DISTINCT c.counts AS counts
			, max(t.tier_value) AS maxCount
			FROM #counts2 c
			LEFT JOIN #BPO_scales2 t
			ON c.counts >= t.tier_value
			GROUP by c.counts
		) as lookupTable
		ON lookupTable.maxCount = dataTable.tier_value
	ORDER BY lookupTable.counts	


select
begin_date, isnull(end_date, cast(getdate() as date)) as end_date, call_center_id, agent_group, KPI, tier
, case when KPI = 'WLPH' THEN tier_value * 100
	WHEN KPI = 'MONT_RATE' THEN tier_value * 10000
	ELSE tier_value END as tier_value
, tier_payout
into #bpo_scales3
from ledbi.dbo.bpo_scales
where call_center_id = @call_center_id
and agent_group IN ('OB') 
and (end_date IS NULL or end_date <= @end_date); 


	WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
	SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
	INTO #counts3
	FROM x ones,     x tens,      x hundreds,       x thousands

	SELECT
		lookupTable.counts
		, dataTable.begin_date
		, ISNULL(dataTable.end_date, CAST(GETDATE() AS DATE)) AS end_date
		,CASE WHEN dataTable.agent_group = 'OB' THEN dataTable.tier_value END AS OB_Limit
		INTO #lookup3
		FROM #BPO_scales3  dataTable RIGHT JOIN
		( SELECT 
			DISTINCT c.counts AS counts
			, max(t.tier_value) AS maxCount
			FROM #counts3 c
			LEFT JOIN #BPO_scales3 t
			ON c.counts >= t.tier_value
			GROUP by c.counts
		) as lookupTable
		ON lookupTable.maxCount = dataTable.tier_value
	ORDER BY lookupTable.counts	



	
select
begin_date, isnull(end_date, cast(getdate() as date)) as end_date, call_center_id, agent_group, KPI, tier
, case when KPI = 'WLPH' THEN tier_value * 100
	WHEN KPI = 'MONT_RATE' THEN tier_value * 10000
	ELSE tier_value END as tier_value
, tier_payout
into #bpo_scales_EF
from ledbi.dbo.bpo_scales
where call_center_id = @call_center_id
and agent_group IN ('EF_OB', 'BPO_EF') 
and (end_date IS NULL or end_date <= @end_date); 


	WITH x AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n))
	SELECT ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n AS counts
	INTO #counts_ef
	FROM x ones,     x tens,      x hundreds,       x thousands

	SELECT
		lookupTable.counts
		, dataTable.begin_date
		, ISNULL(dataTable.end_date, CAST(GETDATE() AS DATE)) AS end_date
		, CASE WHEN dataTable.agent_group = 'EF_OB' THEN dataTable.tier_value END AS EF_Limit
		, CASE WHEN dataTable.agent_group = 'BPO_EF' THEN dataTable.tier_value END AS EFEDU_Limit
		INTO #lookup_ef
		FROM #BPO_scales3  dataTable RIGHT JOIN
		( SELECT 
			DISTINCT c.counts AS counts
			, max(t.tier_value) AS maxCount
			FROM #counts_ef c
			LEFT JOIN #BPO_scales3 t
			ON c.counts >= t.tier_value
			GROUP by c.counts
		) as lookupTable
		ON lookupTable.maxCount = dataTable.tier_value
	ORDER BY lookupTable.counts	



	SELECT
	  DISTINCT b.agent_id AS tsr
	, b.agent_group
	, ISNULL(q.qa_score,0) AS qa_score
	, DATEADD(DAY, -DATEDIFF(DAY, @ppd, b.call_date)%7, b.call_date) AS payable_period
	, b.call_center_id
	, NULLIF((SUM(l.LTs * 2.5) + SUM(l.forms)),0) /CAST(SUM(l.prod_hours) AS FLOAT) AS WLPH
	, NULLIF(SUM(l.converts)*1.0, 0) / SUM(l.calls_to_agents) AS MONT_RATE
	INTO #performance
	FROM ledbi.dbo.AgentTime b

	LEFT JOIN #qa q
	ON q.ppd = DATEADD(DAY, -DATEDIFF(DAY, @ppd, b.call_date)%7, b.call_date)
	AND q.tsr = b.agent_id

	LEFT JOIN (
		SELECT 
		DISTINCT l.tsr
		, l.Call_Date
		, SUM(l.time_productive) AS prod_hours
		, SUM(l.tot_calls) AS calls_to_agents
		, SUM(l.tot_converts_step1) AS converts
		, SUM(l.tot_lts) AS LTs
		, SUM(l.tot_cfs) AS forms
		FROM ledbi.dbo.Realtime l
		WHERE l.Call_Date >= @begin_date
		AND l.Call_Date < @end_date
		AND l.call_center_id = @call_center_id
		GROUP BY
		l.tsr
		, l.Call_Date ) l
		ON l.Call_Date = b.call_date
		AND l.tsr = b.agent_id
	WHERE b.call_date >= @begin_date
	AND b.call_date < @end_date
	AND b.call_center_id = @call_center_id
	GROUP BY
	  b.agent_id
	, q.qa_score
	, b.agent_group
	, DATEADD(DAY, -DATEDIFF(DAY, @ppd, b.call_date)%7, b.call_date) 
	, b.call_center_id

	SELECT 
	distinct p.tsr, p.payable_period, p.agent_group, p.call_center_id
	, CASE 
		WHEN p.agent_group = 'LX_IA' 
			THEN CASE WHEN d.bonus_eligible = 1 AND p.qa_score >= d.qa_gate THEN ia.tier_payout ELSE iabase.tier_payout END
		WHEN p.agent_group = 'LX' 
			THEN CASE WHEN d.bonus_eligible = 1 AND p.qa_score >= d.qa_gate THEN lx.tier_payout ELSE lxbase.tier_payout END
		WHEN p.agent_group = 'OB' 
			THEN CASe WHEN d.bonus_eligible = 1 AND p.qa_score >= d.qa_gate THEN ob.tier_payout ELSE obbase.tier_payout END
		WHEN p.agent_group = 'EF_OB' 
			THEN CASe WHEN d.bonus_eligible = 1 AND p.qa_score >= d.qa_gate THEN efob.tier_payout ELSE efobbase.tier_payout END
		WHEN p.agent_group = 'BPO_EF' 
			THEN CASe WHEN d.bonus_eligible = 1 AND p.qa_score >= d.qa_gate THEN efedu.tier_payout ELSE efedubase.tier_payout END
		ELSE 0 END AS Rate
	, d.bonus_eligible
	INTO #rate_stage
	FROM #performance p

LEFT JOIN (
			SELECT DISTINCT counts
			, begin_date, end_date
			, MAX(ISNULL(IA_Limit,0)) AS WLPH
			FROM #lookup 
			GROUP BY counts, begin_date, end_date
			) AS wlph_s2
			ON wlph_s2.counts = (ROUND(ISNULL(p.WLPH,0) *100,0))
			AND p.agent_group = 'LX_IA'
			AND p.payable_period BETWEEN wlph_s2.begin_date and wlph_s2.end_date
	LEFT JOIN #BPO_scales ia
		ON ia.tier_value = wlph_s2.WLPH
		AND ia.KPI = 'WLPH'
		AND ia.begin_date = wlph_s2.begin_date
	
LEFT JOIN (
			SELECT DISTINCT counts
			, begin_date, end_date
			, MAX(ISNULL(LX_Limit,0)) AS mont
			FROM #lookup2 
			GROUP BY counts, begin_date, end_date
			) AS mont_lx
			ON mont_lx.counts = (ROUND(isnull(p.MONT_RATE,0) * 10000,0))
			AND p.agent_group = 'LX'
			AND p.payable_period between mont_lx.begin_date and mont_lx.end_date
	LEFT JOIN #BPO_scales2 lx
		ON lx.tier_value = mont_lx.mont
		AND lx.KPI = 'MONT_RATE'
		and lx.begin_date = mont_lx.begin_date

LEFT JOIN (
			SELECT DISTINCT counts
			, begin_date, end_date
			, MAX(ISNULL(OB_Limit,0)) AS mont
			FROM #lookup3 
			GROUP BY counts, begin_date, end_date
			) AS mont_ob
			ON mont_ob.counts = (ROUND(isnull(p.MONT_RATE,0) * 10000,0))
			AND p.agent_group = 'OB'
			AND p.payable_period between mont_ob.begin_date and mont_ob.end_date
	LEFT JOIN #BPO_scales3 ob
		ON ob.tier_value = mont_ob.mont
		AND ob.KPI = 'MONT_RATE'
		and ob.begin_date = mont_ob.begin_date

LEFT JOIN (
			SELECT DISTINCT counts
			, begin_date, end_date
			, MAX(ISNULL(EF_Limit,0)) AS mont
			FROM #lookup_ef 
			GROUP BY counts, begin_date, end_date
			) AS mont_ef
			ON mont_ef.counts = (ROUND(isnull(p.MONT_RATE,0) * 10000,0))
			AND p.agent_group = 'EF_OB'
			AND p.payable_period between mont_ef.begin_date and mont_ef.end_date
	LEFT JOIN #bpo_scales_EF efob
		ON efob.tier_value = mont_ef.mont
		AND efob.KPI = 'MONT_RATE'
		and efob.begin_date = mont_ef.begin_date

LEFT JOIN (
			SELECT DISTINCT counts
			, begin_date, end_date
			, MAX(ISNULL(EFEDU_Limit,0)) AS WLPH
			FROM #lookup_ef
			GROUP BY counts, begin_date, end_date
			) AS wlph_ef
			ON wlph_ef.counts = (ROUND(ISNULL(p.WLPH,0) *100,0))
			AND p.agent_group = 'BPO_EF'
			AND p.payable_period BETWEEN wlph_ef.begin_date and wlph_ef.end_date
	LEFT JOIN #BPO_scales efedu
		ON efedu.tier_value = wlph_ef.WLPH
		AND efedu.KPI = 'WLPH'
		AND efedu.begin_date = wlph_ef.begin_date


INNER JOIN (
	SELECT DISTINCT DATEADD(DAY, -DATEDIFF(DAY, @ppd, d.call_Date)%7, call_date) AS ppd
	, call_center_id
	, agent_group
	, MAX(qa_gate) AS qa_gate
	, MAX(bonus_eligible) AS bonus_eligible
	FROM ledbi.dbo.DailyGoals d
	WHERE d.call_Date >= @begin_date
	GROUP BY DATEADD(DAY, -DATEDIFF(DAY, @ppd, d.call_Date)%7, call_date) 
	, call_center_id
	, agent_group) d
	ON d.ppd = p.payable_period
	AND d.agent_group = p.agent_group
	AND d.call_center_id = p.call_center_id

LEFT JOIN #BPO_scales iabase
	ON iabase.agent_group = p.agent_group
	AND p.payable_period between iabase.begin_date and iabase.end_date
	AND iabase.tier = 1

LEFT JOIN #BPO_scales2 lxbase
	ON lxbase.agent_group = p.agent_group
	AND p.payable_period between lxbase.begin_date and lxbase.end_date
	AND lxbase.tier = 1

LEFT JOIN #BPO_scales3 obbase
	ON obbase.agent_group = p.agent_group
	AND p.payable_period between obbase.begin_date and obbase.end_date
	AND obbase.tier = 1

LEFT JOIN #bpo_scales_EF efobbase
	ON efobbase.agent_group = p.agent_group
	AND p.payable_period between efobbase.begin_date and efobbase.end_date
	AND efobbase.tier = 1

LEFT JOIN #bpo_scales_EF efedubase
	ON efedubase.agent_group = p.agent_group
	AND p.payable_period between efedubase.begin_date and efedubase.end_date
	AND efedubase.tier = 1

SELECT 
distinct d.doy AS call_date
, r.*
INTO #rate
FROM LEDBI.dbo._days_hours d
LEFT JOIN #rate_stage r
	on r.payable_period = DATEADD(DAY, -DATEDIFF(DAY, @ppd, d.doy)%7, d.doy)
WHERE d.doy >= @begin_date
AND d.doy < @end_date
ORDER BY r.call_center_id, r.agent_group, d.doy



INSERT INTO ledbi.dbo.bpo_daily_agent_rate 
SELECT * FROM #rate 
GO


