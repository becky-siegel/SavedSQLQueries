USE [LEDBI]
GO

/****** Object:  StoredProcedure [dbo].[usp_IA_BigTable_AllAgents_Merge]    Script Date: 8/29/2023 2:32:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO























-- table history back to 3/1/2020 and no updates
-- stored proc to run on days not locked, Becky will lock them
-- add column to _days_hours table

-- select * from dbo.IA_BigTable_AllAgents order by 3 desc, 1
-- 11,158

-- truncate table dbo.IA_BigTable_AllAgents
-- delete from dbo.IA_BigTable_AllAgents where pay_date >= '2020-09-16'
-- update dbo.IA_BigTable_AllAgents set IA_Pay_Locked = 1 where pay_date < '8/1/2020'



ALTER procedure [dbo].[usp_IA_BigTable_AllAgents_Merge]

--(

--	@Active int = 0

--)

as


--declare @Active int = 0
--       ,@begin_date DATETIME = CAST(DATEADD(MONTH, -2, DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE())) as date)

--select iba.* 
--from dbo.IA_BigTable_AllAgents iba (nolock)
--	-----------------------------------------------------------------------
---- this join along with the where clause will be just active (today) agents

--	left outer join LEDBI.dbo.tsrmaster t (NOLOCK) ON (iba.pay_date >= t.hire_date
--									AND iba.pay_date < COALESCE(t.term_date, '2099-01-01')
--									AND t.CallCenterID = 17
--									and iba.tsr = t.tsr)

--where ((@Active = 1 and t.tsr is not null) or (@Active = 0 and iba.tsr is not null))
--	and iba.pay_date >= @begin_date
-----------------------------------------------------------------
--order by iba.pay_date desc
--		,iba.tsr


SET NOCOUNT ON 
SET ANSI_NULLS OFF
--SET ANSI_WARNINGS on

set transaction isolation level read uncommitted

IF OBJECT_ID('tempdb..#tsrmaster') IS NOT NULL DROP TABLE #tsrmaster
IF OBJECT_ID('tempdb..#agent_days') IS NOT NULL DROP TABLE #agent_days
IF OBJECT_ID('tempdb..#adp') IS NOT NULL DROP TABLE #adp
--IF OBJECT_ID('tempdb..#wage_load_factors') IS NOT NULL DROP TABLE #wage_load_factors
--IF OBJECT_ID('tempdb..#standard_agent_costs') IS NOT NULL DROP TABLE #standard_agent_costs
IF OBJECT_ID('tempdb..#agent_rev_adjustment') IS NOT NULL DROP TABLE #agent_rev_adjustment
IF OBJECT_ID('tempdb..#production') IS NOT NULL DROP TABLE #production
IF OBJECT_ID('tempdb..#results') IS NOT NULL DROP TABLE #results
IF OBJECT_ID('tempdb..#qa') IS NOT NULL DROP TABLE #qa
IF OBJECT_ID('tempdb..#final') IS NOT NULL DROP TABLE #final
IF OBJECT_ID('tempdb..#return_results') IS NOT NULL DROP TABLE #return_results

IF OBJECT_ID('tempdb..#fmla_cost') IS NOT NULL DROP TABLE #fmla_cost
CREATE TABLE #fmla_cost (tsr varchar(50), call_date datetime, cost int) 
INSERT INTO #fmla_cost (tsr, call_Date, cost) values
 ('edu_jknight', '2023-08-15', -112.5)
,('edu_kanglin', '2023-08-15', -112.5)
,('edu_tpaschka', '2023-08-15', -112.5)
,('edu_amccown', '2023-08-15', -112.5)
,('edu_jforeman', '2023-08-15', -112.5)
,('edu_dbrown', '2023-08-15', -168.75)
,('edu_pmason', '2023-08-15', -168.75)
,('edu_mjohnson', '2023-08-15', -168.75)
,('edu_dMcMullen', '2023-08-15', -168.75)
,('edu_pmorgan', '2023-08-15', -168.75)
,('edu_droberson', '2023-08-15', -168.75)
,('edu_glanzafame', '2023-08-15', -168.75)
,('edu_kguentheryamaguchi', '2023-08-15', -168.75)
,('edu_aayton', '2023-08-15', -168.75)
,('edu_tdennemann', '2023-08-15', -168.75)
,('edu_agaymon', '2023-08-15', -168.75)
,('edu_ssignori', '2023-08-15', -168.75)
,('edu_tnugent', '2023-08-15', -168.75)
,('edu_zchoudhry', '2023-08-15', -168.75)
,('edu_kcline', '2023-08-15', -168.75)
,('edu_kmangold', '2023-08-15', -168.75)
,('edu_gallen', '2023-08-15', -168.75)
,('edu_ddieppa', '2023-08-15', -168.75)
,('edu_fdennis', '2023-08-15', -168.75)
,('edu_ngrieco', '2023-08-15', -168.75)
,('edu_dpelatti', '2023-08-15', -168.75)
,('edu_tnabil', '2023-08-15', -168.75)
,('edu_majackson', '2023-08-15', -168.75)
,('edu_gyoung', '2023-08-15', -168.75)
,('edu_vrenta', '2023-08-15', -168.75)
,('edu_dgarcia', '2023-08-15', -168.75)
,('edu_ghall', '2023-08-15', -168.75)
,('edu_apolanco', '2023-08-15', -168.75)
,('edu_dbarker', '2023-08-15', -168.75)
,('edu_klackey', '2023-08-15', -168.75)
,('edu_rthweatt', '2023-08-15', -168.75)
,('edu_sowens', '2023-08-15', -168.75)
,('edu_lbrewer', '2023-08-15', -168.75)
,('edu_llucas', '2023-08-15', -168.75)
,('edu_jcurry', '2023-08-15', -168.75)
,('edu_sjarrett', '2023-08-15', -168.75)


IF OBJECT_ID('tempdb..#fmla_seat') IS NOT NULL DROP TABLE #fmla_seat
CREATE TABLE #fmla_seat (tsr varchar(50), call_date datetime, seat_cost int) 
INSERT INTO #fmla_seat (tsr, call_Date, seat_cost) values
('edu_kthomas','2022-11-18', -40)
, ('edu_kthomas','2022-11-21', -40)
, ('edu_kthomas','2022-11-22', -40)
, ('edu_kthomas','2022-11-23', -40)
, ('edu_kthomas','2022-11-28', -40)
, ('edu_kthomas','2022-11-29', -40)
, ('edu_kthomas','2022-11-30', -40)




DECLARE @pperiodepoch DATETIME = '2018-01-07'
DECLARE @current_pperiod_start DATETIME = DATEADD(DAY, -DATEDIFF(DAY, @pperiodepoch, CAST(GETDATE() AS DATE))%14, CAST(GETDATE() AS DATE))
DECLARE @begin_date DATETIME = CAST(DATEADD(MONTH, -2, DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE())) as date) -- set to '2020-06-01' by Becky, not sure if there was a resaon.
DECLARE @end_date DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
DECLARE @bbegin_date DATETIME = '2020-06-01'
SET @begin_date = CASE WHEN @begin_date < @bbegin_date THEN @bbegin_date ELSE @begin_date END

SELECT
DISTINCT t.tsr AS tsr
, t.email
INTO #tsrmaster
FROM LEDBI.dbo.tsrmgr t (NOLOCK)
WHERE t.day_date >= @begin_date
AND t.email IS NOT NULL
AND t.CallCenterID = 17


SELECT DISTINCT
  dh.doy AS pay_date
, a.tsr
, a.Payroll_ID
, a.CallCenterID
INTO #agent_days
FROM 
LEDBI.dbo._days_hours dh (NOLOCK)
INNER JOIN LEDBI.dbo.tsrmgr a (NOLOCK) ON 
        1 = 1
    AND dh.doy >= a.hire_date
	AND dh.doy = a.day_date
    --AND dh.doy < COALESCE(a.term_date, '2099-01-01') 
    AND a.CallCenterID = 17
	and a.term_date is null
                            
WHERE
    dh.doy >= @begin_date
AND dh.doy < @end_date
and dh.IA_Pay_Locked = 0


SELECT 
iq.tsr
, CAST(iq.LeadDateCreated AS DATE) AS LeadDateCreated
--, iq.UnauditedRevenue
--, iq.UnauditedRevenue*sac.agent_rev_pct AS agent_revenue
--, SUM(CASE WHEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) > sac.agent_rev_ceiling THEN
--		(COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - sac.agent_rev_ceiling ELSE 0 END) AS adjustment
, SUM(CASE WHEN (iq.ListCode like 'WTT%' AND iq.LeadDateCreated >= '2020-09-01') THEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - 75 ELSE
       
	   CASE WHEN iq.LT = 1 AND iq.LeadDateCreated >= '2023-06-08' and iq.leadDateCreated < '2023-07-01' 
			THEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - 73  --for June LT incentive
	   
	   WHEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) > sac.agent_rev_ceiling THEN
             (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - sac.agent_rev_ceiling ELSE 0 END END) AS adjustment

INTO #agent_rev_adjustment
FROM
LEDBI.dbo.inquiry_ref iq (NOLOCK)
INNER JOIN LEDBI.dbo.rconf_standard_agent_costs sac (NOLOCK) ON
        sac.begin_date <= iq.LeadDateCreated
    AND COALESCE(sac.end_date, '2099-01-01') > iq.LeadDateCreated
    AND sac.day_of_week = DATEPART(WEEKDAY, iq.LeadDateCreated)
	AND iq.CallCenterID = sac.call_center_id
	AND sac.agent_rev_ceiling IS NOT NULL
WHERE iq.LeadDateCreated >= @begin_date
GROUP BY 
iq.tsr
, CAST(iq.LeadDateCreated AS DATE) --AS LeadDateCreated
HAVING SUM(CASE WHEN (iq.ListCode like 'WTT%' AND iq.LeadDateCreated >= '2020-09-01') THEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - 75 ELSE
       CASE WHEN (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) > sac.agent_rev_ceiling THEN
             (COALESCE(iq.UnauditedRevenue, 0)*COALESCE(sac.agent_rev_pct, .6)) - sac.agent_rev_ceiling ELSE 0 END END) > 0


create table #production
(

	tsr varchar(50),
	CallCenterID int,
	LeadDate datetime,
	UnauditedRevenue numeric(38,2),
	AgentRevenue float,
	time_productive numeric(38,10),
	time_deassigned numeric(38,10),
	time_paused numeric(38,10),
	time_total numeric(38,10),
	tot_calls int,
	tot_connects int,
	tot_lts int,
	tot_converts_step2 int,
	tot_leads_step2 int,
	MaxCallDateTime datetime,
	MaxLeadDateTime datetime


)
insert into #production
SELECT
  rt.tsr
, rt.call_center_id AS CallCenterID
, rt.Call_Date AS LeadDate
, SUM(rt.UnauditedRevenue) AS UnauditedRevenue
, SUM(rt.UnauditedRevenue)*COALESCE(rdo.agent_rev_pct, sac.agent_rev_pct, .6) AS AgentRevenue
, SUM(rt.time_productive) AS time_productive
, SUM(rt.time_deassigned) AS time_deassigned
, SUM(rt.time_paused) AS time_paused
, SUM(rt.time_total) AS time_total
, SUM(rt.tot_calls) AS tot_calls
, SUM(rt.tot_connects) AS tot_connects
, SUM(rt.tot_lts) AS tot_lts
, SUM(rt.tot_converts_step2) AS tot_converts_step2
, SUM(rt.tot_leads_step2) AS tot_leads_step2
, MAX(rt.MaxCallDateTime) AS MaxCallDateTime
, MAX(rt.MaxLeadDateTime) AS MaxLeadDateTime
--INTO #production
FROM 
LEDBI.dbo.Realtime rt (NOLOCK)
LEFT JOIN LEDBI.dbo.rconf_standard_agent_costs sac (NOLOCK) ON
        sac.begin_date <= rt.Call_Date
    AND COALESCE(sac.end_date, '2099-01-01') > rt.Call_Date
    AND sac.day_of_week = DATEPART(WEEKDAY, rt.Call_Date)

LEFT JOIN LEDBI.dbo.rconf_date_overrides rdo (NOLOCK) ON
        rdo.override_date = CAST(rt.Call_date AS DATE)
		AND rdo.call_center_id = rt.call_center_id

WHERE
rt.Call_Date > CASE WHEN @begin_date > '2020-06-01' THEN @begin_date ELSE '2020-05-31' END
AND rt.Call_Date < @end_date

AND rt.call_center_id = 17
GROUP BY 
  rt.tsr
, rt.call_center_id --AS CallCenterID
, rt.Call_Date
, COALESCE(rdo.agent_rev_pct, sac.agent_rev_pct, .6)


UPDATE p
SET p.AgentRevenue = p.AgentRevenue - ra.adjustment
FROM 
#production p 
INNER JOIN #agent_rev_adjustment ra ON
		ra.tsr = p.tsr
	AND ra.LeadDateCreated = p.LeadDate

--SELECT
--*
--FROM #production
--ORDER BY MaxCallDateTime DESC


SELECT
  ad.Payroll_ID AS employee
, ad.tsr
, ad.CallCenterID
, ad.pay_date
, DATEADD(DAY, -DATEDIFF(DAY, @pperiodepoch, ad.pay_date)%14, ad.pay_date) AS pperiod_start
, in_time.in_time
, wlf.wage_inflator
, SUM(CASE WHEN adp.EarningCode     IN ('R', 'O') THEN adp.[hours] ELSE 0 END) AS wage_hours_productive
, SUM(CASE WHEN adp.EarningCode NOT IN ('R', 'O') THEN adp.[hours] ELSE 0 END) AS wage_hours_non_productive
, SUM(CASE WHEN adp.EarningCode     IN ('R', 'O') THEN adp.Amount ELSE 0 END) AS dollars_productive_base
, SUM(CASE WHEN adp.EarningCode NOT IN ('R', 'O') THEN adp.Amount ELSE 0 END) AS dollars_non_productive_base
, SUM(CASE WHEN adp.EarningCode     IN ('R', 'O') THEN adp.Amount ELSE 0 END) * wlf.wage_inflator AS dollars_productive_base_loaded
, SUM(CASE WHEN adp.EarningCode NOT IN ('R', 'O') THEN adp.Amount ELSE 0 END) * wlf.wage_inflator AS dollars_non_productive_base_loaded
, SUM(CASE WHEN adp.EarningCode = 'VLP' THEN adp.[hours] ELSE 0 END) AS VTO_hours
, SUM(CASE WHEN adp.EarningCode IN ('PTO', 'QFH', 'SWA') THEN adp.[hours] ELSE 0 END) AS PTO_hours
, COALESCE(SUM(CASE WHEN adp.EarningCode NOT IN ('R', 'O', 'HOL') THEN adp.[hours] ELSE 0 END) - SUM(CASE WHEN adp.EarningCode = 'VLP' THEN adp.[hours] ELSE 0 END), 0) AS discount_hours

INTO #adp
FROM #agent_days ad (NOLOCK)

LEFT JOIN LEDBI.dbo.TimecardPaycom AS adp (NOLOCK) ON
        adp.EECode = ad.Payroll_ID
    AND adp.[Date] = ad.pay_date
	AND DATENAME(WEEKDAY, [Date]) NOT IN ('Saturday', 'Sunday')

LEFT JOIN LEDBI.dbo.rconf_wage_load_factor wlf (NOLOCK) ON
        wlf.call_center_id = ad.CallCenterID
    AND wlf.begin_date <= ad.pay_date
    AND COALESCE(wlf.end_date, '2099-01-01') > ad.pay_date

LEFT JOIN (
        SELECT 
          t.EECode
        , t.[Date] AS pay_date
        , MIN(t.[Date]) AS in_time
        FROM ledbi.dbo.TimecardPaycom t (NOLOCK)
        WHERE 
            t.[Date] >= @begin_date
        AND t.[Date] < @end_date
        GROUP BY 
            t.EECode
        , t.[Date]
    ) in_time ON
        in_time.EECode = adp.EECode 
    AND in_time.pay_date = adp.[Date]

WHERE 
    ad.pay_date >= @begin_date
AND ad.pay_date < @end_date

GROUP BY 
  ad.Payroll_ID --AS employee
, ad.tsr
, ad.CallCenterID --AS CallCenterID
, ad.pay_date
, DATEADD(DAY, -DATEDIFF(DAY, @pperiodepoch, ad.pay_date)%14, ad.pay_date) --AS pperiod_start
, in_time.in_time
, wlf.wage_inflator

ORDER BY
  ad.Payroll_ID
, ad.pay_date




SELECT DISTINCT c.tsr
, CAST(c.call_Datetime AS DATE) AS call_date
, COUNT(DISTINCT q.DialerSessionID) * 1.000 AS score_count
, CAST(COUNT(DISTINCT CASE WHEN q.QualityScore >= 100 THEN q.DialerSessionID END) AS FLOAT) AS score_pass
INTO #qa

FROM ledbi.dbo.leadHOOP_QualityLeads q (NOLOCK) 

LEFT JOIN ledbi.dbo.CallLog c
	ON c.d_record_id = q.dialersessionid

WHERE c.call_datetime >= @begin_date
AND c.call_datetime < @end_date
GROUP BY c.tsr, cast(c.call_Datetime as date) 



SELECT
  adp.tsr
, t.email
, adp.pay_date
, adp.CallCenterID
, adp.wage_inflator
, sac.day_of_week
, COALESCE(rdo.seat_cost, sac.seat_cost) + ISNULL(fs.seat_cost, 0) AS seat_cost
, COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) AS data_cost
, COALESCE(rdo.target_hours, sac.target_hours) AS target_hours
, adp.wage_hours_productive
, adp.wage_hours_non_productive
, adp.dollars_productive_base
, adp.dollars_non_productive_base
, CASE WHEN SUM(p.time_total) > 0 AND COALESCE(adp.wage_hours_productive, 0) = 0
                THEN SUM(p.time_total) * dflt.wage_rate * adp.wage_inflator
                ELSE (adp.dollars_productive_base_loaded) END AS dollars_productive_base_loaded
, adp.dollars_non_productive_base_loaded
, adp.VTO_hours
, adp.PTO_hours
, adp.discount_hours
, (COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) + ISNULL(fs.seat_cost,0) ) AS applied_costs
, ((COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) + ISNULL(fs.seat_cost,0))
				/COALESCE(rdo.target_hours, sac.target_hours)) AS applied_costs_per_hour
, adp.discount_hours * ((COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) + ISNULL(fs.seat_cost,0) )
				/COALESCE(rdo.target_hours, sac.target_hours)) AS cost_discounts
, (COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) + ISNULL(fs.seat_cost,0) ) 
			- adp.discount_hours * ((COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost,0) +ISNULL(fs.seat_cost,0))
			/COALESCE(rdo.target_hours, sac.target_hours))
+ CASE WHEN SUM(p.time_total) > 0 AND COALESCE(adp.wage_hours_productive, 0) = 0
                THEN SUM(p.time_total) * dflt.wage_rate * adp.wage_inflator
                ELSE (adp.dollars_productive_base_loaded) END AS total_applied_agent_costs
, SUM(p.time_total) AS dlr_time_total
, SUM(p.time_productive) AS dlr_time_productive
, SUM(p.time_deassigned) AS dlr_time_deassigned
, SUM(p.time_paused) AS dlr_time_paused
, SUM(p.tot_calls) AS tot_calls
, SUM(p.tot_connects) AS tot_connects
, SUM(p.tot_converts_step2) AS tot_converts_step2
, SUM(p.tot_leads_step2) AS tot_leads_step2
, SUM(p.tot_lts) AS tot_lts
, SUM(COALESCE(p.UnauditedRevenue, 0)) AS UnauditedRevenue
, SUM(COALESCE(p.AgentRevenue, 0)) AS AgentRevenue
, SUM(COALESCE(p.AgentRevenue, 0)) 
- (COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost, 0) + ISNULL(fs.seat_cost,0)) 
+ adp.discount_hours * ((COALESCE(rdo.seat_cost, sac.seat_cost) + COALESCE(rdo.data_cost, sac.data_cost) + ISNULL(bf.cost, 0) + ISNULL(fs.seat_cost,0) )
	/COALESCE(rdo.target_hours, sac.target_hours))
	- (CASE WHEN SUM(p.time_total) > 0 AND COALESCE(adp.wage_hours_productive, 0) = 0
                THEN SUM(p.time_total) * dflt.wage_rate * adp.wage_inflator
                ELSE (adp.dollars_productive_base_loaded) END) 
  AS agent_daily_profit
, cast(MAX(p.MaxCallDateTime) as datetime) AS MaxCalLDateTime
, cast(MAX(p.MaxLeadDateTime) as datetime) AS MaxLeadDateTime

INTO #results
FROM 
#adp adp
INNER JOIN #tsrmaster t (NOLOCK) ON
                                t.tsr = adp.tsr
LEFT JOIN #production p ON 
                                p.tsr = adp.tsr
                AND p.CallCenterID = adp.CallCenterID
                AND p.LeadDate = adp.pay_date
LEFT JOIN LEDBI.dbo.rconf_standard_agent_costs sac (NOLOCK) ON
                                sac.call_center_id = adp.CallCenterID
                AND sac.begin_date <= adp.pay_date
                AND COALESCE(sac.end_date, '2099-01-01') > adp.pay_date
                AND sac.day_of_week = DATEPART(WEEKDAY, adp.pay_date)
LEFT JOIN LEDBI.dbo.rconf_date_overrides rdo (NOLOCK) ON
        rdo.override_date = CAST(adp.pay_date AS DATE)
		and rdo.call_center_id = adp.CallCenterID
LEFT JOIN (
        SELECT 
            t.EECode
        , AVG(t.rate) AS wage_rate
        FROM ledbi.dbo.TimecardPaycom t (NOLOCK)
        WHERE 
            t.[Date] >= @begin_date
        AND t.[Date] < @end_date
        AND t.EarningCode = 'R'
		AND DATENAME(WEEKDAY, [Date]) NOT IN ('Saturday', 'Sunday')
        GROUP BY 
            t.EECode
                ) dflt ON
                                dflt.EECode = adp.employee 

LEFT JOIN #fmla_cost bf
		ON bf.call_date = adp.pay_date
		AND bf.tsr = adp.Tsr

LEFT JOIN #fmla_seat fs
		ON fs.call_date = adp.pay_date
		AND fs.tsr = adp.Tsr


WHERE 
adp.callCenterID = 17
GROUP BY 
  adp.tsr
, t.email
, adp.pay_date
, adp.CallCenterID
, adp.wage_inflator
, sac.day_of_week
, COALESCE(rdo.seat_cost, sac.seat_cost) --AS seat_cost
, ISNULL(fs.seat_cost, 0)
, COALESCE(rdo.data_cost, sac.data_cost) 
, ISNULL(bf.cost,0) --AS data_cost
, COALESCE(rdo.target_hours, sac.target_hours) --AS target_hours
, dflt.wage_rate
, adp.wage_hours_productive
, adp.wage_hours_non_productive
, adp.dollars_productive_base
, adp.dollars_non_productive_base
, adp.dollars_productive_base_loaded
, adp.dollars_non_productive_base_loaded
, adp.VTO_hours
, adp.PTO_hours
, adp.discount_hours
ORDER BY
  adp.tsr
, adp.pay_date


SELECT 
  r.*
, FORMAT(r.pay_date, 'yyyy-MM') AS year_month
, DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) AS week_start
, daily_qa.daily_scores AS qa_scored_calls
, daily_qa.daily_pass AS qa_passed_calls
, month_sums.total_monthly_profit
, month_sums.monthly_tot_connects
, month_sums.monthly_tot_converts_step2
, month_sums.monthly_tot_leads_step2
, month_sums.monthly_tot_lts
, week_sums.total_weekly_profit
, week_sums.weekly_tot_connects
, week_sums.weekly_tot_converts_step2
, week_sums.weekly_tot_leads_step2
, week_sums.weekly_tot_lts
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN week_sums.total_weekly_profit END AS total_weekly_profit_this 
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN week_sums.weekly_tot_connects END AS weekly_tot_connects_this 
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN week_sums.weekly_tot_converts_step2 END AS weekly_tot_converts_step2_this 
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN week_sums.weekly_tot_leads_step2 END AS weekly_tot_leads_step2_this 
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN week_sums.weekly_tot_lts END AS weekly_tot_lts_this 
, CASE WHEN DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN month_sums.total_monthly_profit END AS total_monthly_profit_this 
, CASE WHEN DATEADD(DAY, -DATEPART(DAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(DAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN month_sums.monthly_tot_connects END AS monthly_tot_connects_this 
, CASE WHEN DATEADD(DAY, -DATEPART(DAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(DAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN month_sums.monthly_tot_converts_step2 END AS monthly_tot_converts_step2_this 
, CASE WHEN DATEADD(DAY, -DATEPART(DAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(DAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN month_sums.monthly_tot_leads_step2 END AS monthly_tot_leads_step2_this 
, CASE WHEN DATEADD(DAY, -DATEPART(DAY, r.pay_date), r.pay_date) = DATEADD(DAY, -DATEPART(DAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)) THEN month_sums.monthly_tot_lts END AS monthly_tot_lts_this 
, CASE WHEN month_sums.total_monthly_profit < 1000 THEN 0.4
       WHEN month_sums.total_monthly_profit < 1375 THEN 0.41
       WHEN month_sums.total_monthly_profit < 1750 THEN 0.42
       WHEN month_sums.total_monthly_profit < 2125 THEN 0.43
       WHEN month_sums.total_monthly_profit < 2500 THEN 0.44
       WHEN month_sums.total_monthly_profit < 2800 THEN 0.45
       WHEN month_sums.total_monthly_profit < 3100 THEN 0.46
       WHEN month_sums.total_monthly_profit < 3400 THEN 0.47
       WHEN month_sums.total_monthly_profit < 3700 THEN 0.48
       WHEN month_sums.total_monthly_profit < 4000 THEN 0.49
       WHEN month_sums.total_monthly_profit < 4200 THEN 0.5
       WHEN month_sums.total_monthly_profit < 4400 THEN 0.51
       WHEN month_sums.total_monthly_profit < 4600 THEN 0.52
       WHEN month_sums.total_monthly_profit < 4800 THEN 0.53
       WHEN month_sums.total_monthly_profit < 5000 THEN 0.54
       WHEN month_sums.total_monthly_profit < 1000000 THEN 0.55
  ELSE 0 END AS profit_share
, CASE WHEN month_sums.total_monthly_profit < 1000 THEN 1000
       WHEN month_sums.total_monthly_profit < 1375 THEN 1375
       WHEN month_sums.total_monthly_profit < 1750 THEN 1750
       WHEN month_sums.total_monthly_profit < 2125 THEN 2125
       WHEN month_sums.total_monthly_profit < 2500 THEN 2500
       WHEN month_sums.total_monthly_profit < 2800 THEN 2800
       WHEN month_sums.total_monthly_profit < 3100 THEN 3100
       WHEN month_sums.total_monthly_profit < 3400 THEN 3400
       WHEN month_sums.total_monthly_profit < 3700 THEN 3700
       WHEN month_sums.total_monthly_profit < 4000 THEN 4000 
       WHEN month_sums.total_monthly_profit < 4200 THEN 4200
       WHEN month_sums.total_monthly_profit < 4400 THEN 4400
       WHEN month_sums.total_monthly_profit < 4600 THEN 4600
       WHEN month_sums.total_monthly_profit < 4800 THEN 4800
       WHEN month_sums.total_monthly_profit < 5000 THEN 5000
  ELSE NULL END AS next_tier_target
, CASE WHEN month_qa.total_monthly_scores > 0 THEN
                ROUND(COALESCE(month_qa.total_monthly_pass,0)/COALESCE(month_qa.total_monthly_scores,0), 2)
                ELSE NULL END AS month_qa_score
, CASE WHEN month_qa.total_monthly_scores > 0 THEN CASE
                                   WHEN ROUND(COALESCE(month_qa.total_monthly_pass *1.000,0)/COALESCE(month_qa.total_monthly_scores,0), 2) < .7 THEN 0
                                   WHEN ROUND(COALESCE(month_qa.total_monthly_pass *1.000,0)/COALESCE(month_qa.total_monthly_scores,0), 2) < .8 THEN .8
                                   WHEN ROUND(COALESCE(month_qa.total_monthly_pass *1.000,0)/COALESCE(month_qa.total_monthly_scores,0), 2) < .85 THEN .9
                                   WHEN ROUND(COALESCE(month_qa.total_monthly_pass *1.000,0)/COALESCE(month_qa.total_monthly_scores,0), 2) < .9 THEN .95                                                                   
                   ELSE 1 END
  ELSE NULL END AS qa_modifier
, COALESCE(month_qa.total_monthly_pass, 0) AS qa_total_monthly_pass
, COALESCE(month_qa.total_monthly_scores, 0) AS qa_total_monthly_scores
, CASE WHEN month_qa.total_monthly_scores > 0 THEN
                ROUND(COALESCE(month_qa.total_monthly_pass,0)/COALESCE(month_qa.total_monthly_scores,0), 4) END AS qa_total_monthly_average
  
INTO #final
FROM 
#results r
LEFT JOIN (
                SELECT 
                  rsum.tsr
                , FORMAT(rsum.pay_date, 'yyyy-MM') AS year_month
                , SUM(rsum.agent_daily_profit) AS total_monthly_profit
                , SUM(rsum.tot_connects) AS monthly_tot_connects
                , SUM(rsum.tot_converts_step2) AS monthly_tot_converts_step2
                , SUM(rsum.tot_leads_step2) AS monthly_tot_leads_step2
                , SUM(rsum.tot_lts) AS monthly_tot_lts
                FROM 
                #results rsum
                GROUP BY 
                  rsum.tsr
                , FORMAT(rsum.pay_date, 'yyyy-MM')
                --ORDER BY tsr, FORMAT(rsum.pay_date, 'yyyy-MM')
) month_sums ON
                                month_sums.tsr = r.tsr
                AND month_sums.year_month = FORMAT(r.pay_date, 'yyyy-MM')
LEFT JOIN (
                SELECT 
                  rsum.tsr
                , DATEADD(DAY, -DATEPART(WEEKDAY, rsum.pay_date), rsum.pay_date) AS week_start
                , SUM(rsum.agent_daily_profit) AS total_weekly_profit
                , SUM(rsum.tot_connects) AS weekly_tot_connects
                , SUM(rsum.tot_converts_step2) AS weekly_tot_converts_step2
                , SUM(rsum.tot_leads_step2) AS weekly_tot_leads_step2
                , SUM(rsum.tot_lts) AS weekly_tot_lts
                FROM 
                #results rsum
                GROUP BY 
                  rsum.tsr
                , DATEADD(DAY, -DATEPART(WEEKDAY, rsum.pay_date), rsum.pay_date) --AS week_start
                --ORDER BY tsr, FORMAT(rsum.pay_date, 'yyyy-MM')
) week_sums ON
                                week_sums.tsr = r.tsr
                AND week_sums.week_start = DATEADD(DAY, -DATEPART(WEEKDAY, r.pay_date), r.pay_date)
LEFT JOIN (
                SELECT 
                  qa.tsr
                , FORMAT(qa.call_date, 'yyyy-MM') AS year_month
                , SUM(qa.score_count) AS total_monthly_scores
                , SUM(qa.score_pass) AS total_monthly_pass
                FROM 
                #qa qa
                GROUP BY 
                  qa.tsr
                , FORMAT(qa.call_date, 'yyyy-MM')
) month_qa ON
                                month_qa.tsr = r.tsr
                AND month_qa.year_month = FORMAT(r.pay_date, 'yyyy-MM')
LEFT JOIN (
                SELECT 
                  qa.tsr
                , qa.call_date
                , SUM(qa.score_count) AS daily_scores
                , SUM(qa.score_pass) AS daily_pass
                FROM 
                #qa qa
                GROUP BY 
                  qa.tsr
                , qa.call_date
) daily_qa ON
                                daily_qa.tsr = r.tsr
                AND daily_qa.call_date = r.pay_date

SELECT
  f.*
, coalesce(term.Active_Code, t.Active_Code) as Active_Code
, t.Address1
, t.Day_Date
, t.Dept_Code
, t.Dept_Mgr
, t.Dept_Name
, t.hire_date
, t.sname
, term.term_date
--, term.term_date as term_date2
, f.total_monthly_profit * f.profit_share * f.qa_modifier AS bonus_payout
, CASE WHEN f.total_monthly_profit > 0 THEN f.total_monthly_profit * f.profit_share * 0.7 ELSE 0 END AS bonus_payout_minimum
, CASE WHEN f.total_monthly_profit > 0 THEN f.total_monthly_profit * f.profit_share * 1.0 ELSE 0 END AS bonus_payout_maximum
, f.agent_daily_profit * f.profit_share * f.qa_modifier AS bonus_payout_daily
, f.agent_daily_profit * f.profit_share * .7 AS bonus_payout_daily_minimum
--Daily = pay_date
--Weekly = weekly_tot_[METRIC]_this
--Monthly = monthly_tot_[METRICT]_this
-- connects
,row_number() over (partition by pay_date order by isnull(f.tot_connects, 0) desc) as Rank_Connects_Daily
,row_number() over (partition by pay_date order by isnull(f.weekly_tot_connects_this, 0) desc) as Rank_Connects_Week
,row_number() over (partition by pay_date order by isnull(f.monthly_tot_connects_this, 0) desc) as Rank_Connects_MTD
-- converts step 2
,row_number() over (partition by pay_date order by isnull(f.tot_converts_step2, 0) desc) as Rank_Converts_Daily
,row_number() over (partition by pay_date order by isnull(f.weekly_tot_converts_step2_this, 0) desc) as Rank_Converts_Week
,row_number() over (partition by pay_date order by isnull(f.monthly_tot_converts_step2_this, 0) desc) as Rank_Converts_MTD
-- leads
,row_number() over (partition by pay_date order by isnull(f.tot_leads_step2, 0) desc) as Rank_LeadsStep2_Daily
,row_number() over (partition by pay_date order by isnull(f.weekly_tot_leads_step2_this, 0) desc) as Rank_LeadsStep2_Week
,row_number() over (partition by pay_date order by isnull(f.monthly_tot_leads_step2_this, 0) desc) as Rank_LeadsStep2_MTD
-- lts
,row_number() over (partition by pay_date order by isnull(f.tot_lts, 0) desc) as Rank_LTs_Daily
,row_number() over (partition by pay_date order by isnull(f.weekly_tot_lts_this, 0) desc) as Rank_LTs_Week
,row_number() over (partition by pay_date order by isnull(f.monthly_tot_lts_this, 0) desc) as Rank_LTs_MTD
--, f.qa_total_monthly_pass
--, f.qa_total_monthly_scores
, CAST(CASE WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .7 THEN
                (((.7*f.qa_total_monthly_scores)-f.qa_total_monthly_pass)/(-.7+1)) + 1 ELSE 0 END AS INT) AS gap_to_qa_70
, CAST(CASE WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .8 THEN
                (((.8*f.qa_total_monthly_scores)-f.qa_total_monthly_pass)/(-.8+1)) + 1 ELSE 0 END AS INT) AS gap_to_qa_80

                                   
, CAST(CASE WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .85 THEN
                (((.85*f.qa_total_monthly_scores)-f.qa_total_monthly_pass)/(-.85+1)) + 1 ELSE 0 END AS INT) AS gap_to_qa_85

, CAST(CASE WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .9 THEN
                (((.9*f.qa_total_monthly_scores)-f.qa_total_monthly_pass)/(-.9+1)) + 1 ELSE 0 END AS INT) AS gap_to_qa_90
, CASE WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .7 THEN .7
WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .8 THEN .8
WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .85 THEN .85
WHEN f.qa_total_monthly_average IS NOT NULL AND f.qa_total_monthly_average < .9 THEN .9
END AS qa_month_to_date_next_target

INTO #return_results
FROM 
#final f
LEFT JOIN LEDBI.dbo.tsrmgr t (NOLOCK) ON
        t.tsr = f.tsr
    AND t.Day_Date = f.pay_date

--LEFT JOIN (select distinct tsr, term_date, hire_date, Active_Code from LEDBI.dbo.tsrmgr z (nolock) where z.term_date >= z.hire_date and z.Day_Date >= @begin_date) term ON
--        term.tsr = f.tsr
LEFT JOIN (select distinct tsr, term_date, hire_date, Active_Code
                    from LEDBI.dbo.tsrmgr z (nolock)
                    inner join ledbi.dbo._days_hours d (nolock)
                        on d.doy = z.Day_Date
                        and d.IA_Pay_Locked = 0
                    where z.term_date >= z.hire_date
                    and z.Day_Date >= @begin_date
                    ) term ON
        term.tsr = f.tsr
    
WHERE 
        f.pay_date >= @begin_date
    AND t.Dept_Name <> 'training'


--INSERT INTO #return_results
--EXEC LEDBI.[dbo].[usp_IA_BigTable_LegacyADP]

--insert into dbo.IA_BigTable_AllAgents
--SELECT *,0
--FROM #return_results
--ORDER BY pay_date, tsr



merge into dbo.IA_BigTable_AllAgents target 
using (

--declare @Active int = 1

SELECT rr.tsr
	  ,rr.email
	  ,pay_date
	  ,rr.CallCenterID
	  ,wage_inflator
	  ,day_of_week
	  ,seat_cost
	  ,data_cost
	  ,target_hours
	  ,isnull(wage_hours_productive, 0) as wage_hours_productive
	  ,isnull(wage_hours_non_productive, 0) as wage_hours_non_productive
	  ,isnull(dollars_productive_base, 0) as dollars_productive_base
	  ,isnull(dollars_non_productive_base, 0) as dollars_non_productive_base
	  ,isnull(dollars_productive_base_loaded, 0) as dollars_productive_base_loaded
	  ,isnull(dollars_non_productive_base_loaded, 0) as dollars_non_productive_base_loaded
	  ,VTO_hours
	  ,PTO_hours
	  ,discount_hours
	  ,applied_costs
	  ,applied_costs_per_hour
	  ,cost_discounts
	  ,total_applied_agent_costs
	  ,dlr_time_total
	  ,dlr_time_productive
	  ,dlr_time_deassigned
	  ,dlr_time_paused
	  ,tot_calls
	  ,tot_connects
	  ,tot_converts_step2
	  ,tot_leads_step2
	  ,tot_lts
	  ,UnauditedRevenue
	  ,AgentRevenue
	  ,agent_daily_profit
	  ,cast(MaxCalLDateTime as datetime) as MaxCalLDateTime
	  ,cast(MaxLeadDateTime as datetime) as MaxLeadDateTime
	  ,year_month
	  ,week_start
	  ,qa_scored_calls
	  ,qa_passed_calls
	  ,total_monthly_profit
	  ,monthly_tot_connects
	  ,monthly_tot_converts_step2
	  ,monthly_tot_leads_step2
	  ,monthly_tot_lts
	  ,total_weekly_profit
	  ,weekly_tot_connects
	  ,weekly_tot_converts_step2
	  ,weekly_tot_leads_step2
	  ,weekly_tot_lts
	  ,total_weekly_profit_this
	  ,weekly_tot_connects_this
	  ,weekly_tot_converts_step2_this
	  ,weekly_tot_leads_step2_this
	  ,weekly_tot_lts_this
	  ,total_monthly_profit_this
	  ,monthly_tot_connects_this
	  ,monthly_tot_converts_step2_this
	  ,monthly_tot_leads_step2_this
	  ,monthly_tot_lts_this
	  ,profit_share
	  ,next_tier_target
	  ,month_qa_score
	  ,qa_modifier
	  ,qa_total_monthly_pass
	  ,qa_total_monthly_scores
	  ,qa_total_monthly_average
	  ,rr.Active_Code
	  ,rr.Address1
	  ,Day_Date
	  ,Dept_Code
	  ,Dept_Mgr
	  ,Dept_Name
	  ,rr.hire_date
	  ,rr.sname
	  ,rr.term_date
	  --,term_date2
	  ,bonus_payout
	  ,bonus_payout_minimum
	  ,bonus_payout_maximum
	  ,bonus_payout_daily
	  ,bonus_payout_daily_minimum
	  ,Rank_Connects_Daily
	  ,Rank_Connects_Week
	  ,Rank_Connects_MTD
	  ,Rank_Converts_Daily
	  ,Rank_Converts_Week
	  ,Rank_Converts_MTD
	  ,Rank_LeadsStep2_Daily
	  ,Rank_LeadsStep2_Week
	  ,Rank_LeadsStep2_MTD
	  ,Rank_LTs_Daily
	  ,Rank_LTs_Week
	  ,Rank_LTs_MTD
	  ,gap_to_qa_70
	  ,gap_to_qa_80
	  ,gap_to_qa_85
	  ,gap_to_qa_90
	  ,qa_month_to_date_next_target
	  
	  ,0 as IA_Pay_Locked
--into #temp
FROM #return_results rr 
-----------------------------------------------------------------------
-- this join will be just active (today) agents

	left outer join LEDBI.dbo.tsrmaster a (NOLOCK) ON (rr.pay_date >= a.hire_date
														AND rr.pay_date < COALESCE(a.term_date, '2099-01-01')
														AND a.CallCenterID = 17
														and rr.tsr = a.tsr)

--where ((@Active = 1 and a.tsr is not null) or (@Active = 0 and rr.tsr is not null))
--where rr.tsr <> 'edu_alharrison'
--where rr.tsr <> 'edu_mjohnson'
---------------------------------------------------------------
--ORDER BY pay_date desc,tsr
) as source on (source.pay_date = target.pay_date and source.tsr = target.tsr)

--select pay_date, tsr, count(*)
--from #temp
--group by pay_date, tsr
--having count(*) > 1

when not matched then 
insert (tsr,email,pay_date,CallCenterID,wage_inflator,day_of_week,seat_cost,data_cost,target_hours,wage_hours_productive,wage_hours_non_productive,dollars_productive_base,dollars_non_productive_base,dollars_productive_base_loaded,dollars_non_productive_base_loaded,VTO_hours,PTO_hours,discount_hours,applied_costs,applied_costs_per_hour,cost_discounts,total_applied_agent_costs,dlr_time_total,dlr_time_productive,dlr_time_deassigned,dlr_time_paused,tot_calls,tot_connects,tot_converts_step2,tot_leads_step2,tot_lts,UnauditedRevenue,AgentRevenue,agent_daily_profit,MaxCalLDateTime,MaxLeadDateTime,year_month,week_start,qa_scored_calls,qa_passed_calls,total_monthly_profit,monthly_tot_connects,monthly_tot_converts_step2,monthly_tot_leads_step2,monthly_tot_lts,total_weekly_profit,weekly_tot_connects,weekly_tot_converts_step2,weekly_tot_leads_step2,weekly_tot_lts,total_weekly_profit_this,weekly_tot_connects_this,weekly_tot_converts_step2_this,weekly_tot_leads_step2_this,weekly_tot_lts_this,total_monthly_profit_this,monthly_tot_connects_this,monthly_tot_converts_step2_this,monthly_tot_leads_step2_this,monthly_tot_lts_this,profit_share,next_tier_target,month_qa_score,qa_modifier,qa_total_monthly_pass,qa_total_monthly_scores,qa_total_monthly_average,Active_Code,Address1,Day_Date,Dept_Code,Dept_Mgr,Dept_Name,hire_date,sname,term_date,bonus_payout,bonus_payout_minimum,bonus_payout_maximum,bonus_payout_daily,bonus_payout_daily_minimum,Rank_Connects_Daily,Rank_Connects_Week,Rank_Connects_MTD,Rank_Converts_Daily,Rank_Converts_Week,Rank_Converts_MTD,Rank_LeadsStep2_Daily,Rank_LeadsStep2_Week,Rank_LeadsStep2_MTD,Rank_LTs_Daily,Rank_LTs_Week,Rank_LTs_MTD,gap_to_qa_70,gap_to_qa_80,gap_to_qa_85,gap_to_qa_90,qa_month_to_date_next_target,IA_Pay_Locked)
values (source.tsr,source.email,source.pay_date,source.CallCenterID,source.wage_inflator,source.day_of_week,source.seat_cost,source.data_cost,source.target_hours,source.wage_hours_productive,source.wage_hours_non_productive,source.dollars_productive_base,source.dollars_non_productive_base,source.dollars_productive_base_loaded,source.dollars_non_productive_base_loaded,source.VTO_hours,source.PTO_hours,source.discount_hours,source.applied_costs,source.applied_costs_per_hour,source.cost_discounts,source.total_applied_agent_costs,source.dlr_time_total,source.dlr_time_productive,source.dlr_time_deassigned,source.dlr_time_paused,source.tot_calls,source.tot_connects,source.tot_converts_step2,source.tot_leads_step2,source.tot_lts,source.UnauditedRevenue,source.AgentRevenue,source.agent_daily_profit,source.MaxCalLDateTime,source.MaxLeadDateTime,source.year_month,source.week_start,source.qa_scored_calls,source.qa_passed_calls,source.total_monthly_profit,source.monthly_tot_connects,source.monthly_tot_converts_step2,source.monthly_tot_leads_step2,source.monthly_tot_lts,source.total_weekly_profit,source.weekly_tot_connects,source.weekly_tot_converts_step2,source.weekly_tot_leads_step2,source.weekly_tot_lts,source.total_weekly_profit_this,source.weekly_tot_connects_this,source.weekly_tot_converts_step2_this,source.weekly_tot_leads_step2_this,source.weekly_tot_lts_this,source.total_monthly_profit_this,source.monthly_tot_connects_this,source.monthly_tot_converts_step2_this,source.monthly_tot_leads_step2_this,source.monthly_tot_lts_this,source.profit_share,source.next_tier_target,source.month_qa_score,source.qa_modifier,source.qa_total_monthly_pass,source.qa_total_monthly_scores,source.qa_total_monthly_average,source.Active_Code,source.Address1,source.Day_Date,source.Dept_Code,source.Dept_Mgr,source.Dept_Name,source.hire_date,source.sname,source.term_date,source.bonus_payout,source.bonus_payout_minimum,source.bonus_payout_maximum,source.bonus_payout_daily,source.bonus_payout_daily_minimum,source.Rank_Connects_Daily,source.Rank_Connects_Week,source.Rank_Connects_MTD,source.Rank_Converts_Daily,source.Rank_Converts_Week,source.Rank_Converts_MTD,source.Rank_LeadsStep2_Daily,source.Rank_LeadsStep2_Week,source.Rank_LeadsStep2_MTD,source.Rank_LTs_Daily,source.Rank_LTs_Week,source.Rank_LTs_MTD,source.gap_to_qa_70,source.gap_to_qa_80,source.gap_to_qa_85,source.gap_to_qa_90,source.qa_month_to_date_next_target,0)

when matched 
and target.IA_Pay_Locked = 0
and (isnull(source.email, '') <> isnull(target.email, '') or
	 isnull(source.wage_inflator, 0) <> isnull(target.wage_inflator, 0) or
	 isnull(source.day_of_week, 0) <> isnull(target.day_of_week, 0) or
	 isnull(source.seat_cost, 0) <> isnull(target.seat_cost, 0) or 
	 isnull(source.data_cost, 0) <> isnull(target.data_cost, 0) or
	 isnull(source.target_hours, 0) <> isnull(target.target_hours, 0) or
	 isnull(source.wage_hours_productive, 0) <> isnull(target.wage_hours_productive, 0) or
	 isnull(source.wage_hours_non_productive, 0) <> isnull(target.wage_hours_non_productive, 0) or
	 isnull(source.dollars_productive_base, 0) <> isnull(target.dollars_productive_base, 0) or
	 isnull(source.dollars_non_productive_base, 0) <> isnull(target.dollars_non_productive_base, 0) or
	 isnull(source.dollars_productive_base_loaded, 0) <> isnull(target.dollars_productive_base_loaded, 0) or
	 isnull(source.dollars_non_productive_base_loaded, 0) <> isnull(target.dollars_non_productive_base_loaded, 0) or
	 isnull(source.VTO_hours, 0) <> isnull(target.VTO_hours, 0) or
	 isnull(source.PTO_hours, 0) <> isnull(target.PTO_hours, 0) or
	 isnull(source.discount_hours, 0) <> isnull(target.discount_hours, 0) or
	 isnull(source.applied_costs, 0) <> isnull(target.applied_costs, 0) or
	 isnull(source.applied_costs_per_hour, 0) <> isnull(target.applied_costs_per_hour, 0) or
	 isnull(source.cost_discounts, 0) <> isnull(target.cost_discounts, 0) or
	 isnull(source.total_applied_agent_costs, 0) <> isnull(target.total_applied_agent_costs, 0) or
	 isnull(source.dlr_time_total, 0) <> isnull(target.dlr_time_total, 0) or
	 isnull(source.dlr_time_productive, 0) <> isnull(target.dlr_time_productive, 0) or
	 isnull(source.dlr_time_deassigned, 0) <> isnull(target.dlr_time_deassigned, 0) or
	 isnull(source.dlr_time_paused, 0) <> isnull(target.dlr_time_paused, 0) or
	 isnull(source.tot_calls, 0) <> isnull(target.tot_calls, 0) or
	 isnull(source.tot_connects, 0) <> isnull(target.tot_connects, 0) or
	 isnull(source.tot_converts_step2, 0) <> isnull(target.tot_converts_step2, 0) or
	 isnull(source.tot_leads_step2, 0) <> isnull(target.tot_leads_step2, 0) or
	 isnull(source.tot_lts, 0) <> isnull(target.tot_lts, 0) or
	 isnull(source.UnauditedRevenue, 0) <> isnull(target.UnauditedRevenue, 0) or
	 isnull(source.AgentRevenue, 0) <> isnull(target.AgentRevenue, 0) or
	 isnull(source.agent_daily_profit, 0) <> isnull(target.agent_daily_profit, 0) or
	 isnull(source.MaxCalLDateTime, '') <> isnull(target.MaxCalLDateTime, '') or
	 isnull(source.MaxLeadDateTime, '') <> isnull(target.MaxLeadDateTime, '') or
	 isnull(source.year_month, 0) <> isnull(target.year_month, 0) or
	 isnull(cast(source.week_start as date), '') <> isnull(target.week_start, '') or
	 isnull(source.qa_scored_calls, 0) <> isnull(target.qa_scored_calls, 0) or
	 isnull(source.qa_passed_calls, 0) <> isnull(target.qa_passed_calls, 0) or
	 isnull(source.total_monthly_profit, 0) <> isnull(target.total_monthly_profit, 0) or
	 isnull(source.monthly_tot_connects, 0) <> isnull(target.monthly_tot_connects, 0) or
	 isnull(source.monthly_tot_converts_step2, 0) <> isnull(target.monthly_tot_converts_step2, 0) or
	 isnull(source.monthly_tot_leads_step2, 0) <> isnull(target.monthly_tot_leads_step2, 0) or
	 isnull(source.monthly_tot_lts, 0) <> isnull(target.monthly_tot_lts, 0) or
	 isnull(source.total_weekly_profit, 0) <> isnull(target.total_weekly_profit, 0) or
	 isnull(source.weekly_tot_connects, 0) <> isnull(target.weekly_tot_connects, 0) or
	 isnull(source.weekly_tot_converts_step2, 0) <> isnull(target.weekly_tot_converts_step2, 0) or
	 isnull(source.weekly_tot_leads_step2, 0) <> isnull(target.weekly_tot_leads_step2, 0) or
	 isnull(source.weekly_tot_lts, 0) <> isnull(target.weekly_tot_lts, 0) or
	 isnull(source.total_weekly_profit_this, 0) <> isnull(target.total_weekly_profit_this, 0) or
	 isnull(source.weekly_tot_connects_this, 0) <> isnull(target.weekly_tot_connects_this, 0) or
	 isnull(source.weekly_tot_converts_step2_this, 0) <> isnull(target.weekly_tot_converts_step2_this, 0) or
	 isnull(source.weekly_tot_leads_step2_this, 0) <> isnull(target.weekly_tot_leads_step2_this, 0) or
	 isnull(source.weekly_tot_lts_this, 0) <> isnull(target.weekly_tot_lts_this, 0) or
	 isnull(source.total_monthly_profit_this, 0) <> isnull(target.total_monthly_profit_this, 0) or
	 isnull(source.monthly_tot_connects_this, 0) <> isnull(target.monthly_tot_connects_this, 0) or
	 isnull(source.monthly_tot_converts_step2_this, 0) <> isnull(target.monthly_tot_converts_step2_this, 0) or
	 isnull(source.monthly_tot_leads_step2_this, 0) <> isnull(target.monthly_tot_leads_step2_this, 0) or
	 isnull(source.monthly_tot_lts_this, 0) <> isnull(target.monthly_tot_lts_this, 0) or
	 isnull(source.profit_share, 0) <> isnull(target.profit_share, 0) or
	 isnull(source.next_tier_target, 0) <> isnull(target.next_tier_target, 0) or
	 isnull(source.month_qa_score, 0) <> isnull(target.month_qa_score, 0) or
	 isnull(source.qa_modifier, 0) <> isnull(target.qa_modifier, 0) or
	 isnull(source.qa_total_monthly_pass, 0) <> isnull(target.qa_total_monthly_pass, 0) or
	 isnull(source.qa_total_monthly_scores, 0) <> isnull(target.qa_total_monthly_scores, 0) or
	 isnull(source.qa_total_monthly_average, 0) <> isnull(target.qa_total_monthly_average, 0) or
	 isnull(source.Active_Code, 0) <> isnull(target.Active_Code, 0) or
	 isnull(source.Address1, '') <> isnull(target.Address1, '') or
	 isnull(source.Day_Date, '') <> isnull(target.Day_Date, '') or
	 isnull(source.Dept_Code, '') <> isnull(target.Dept_Code, '') or
	 isnull(source.Dept_Mgr, '') <> isnull(target.Dept_Mgr, '') or
	 isnull(source.Dept_Name, '') <> isnull(target.Dept_Name, '') or
	 isnull(source.hire_date, '') <> isnull(target.hire_date, '') or
	 isnull(source.sname, '') <> isnull(target.sname, '') or
	 isnull(source.term_date, '') <> isnull(target.term_date, '') or
	 isnull(source.bonus_payout, 0) <> isnull(target.bonus_payout, 0) or
	 isnull(source.bonus_payout_minimum, 0) <> isnull(target.bonus_payout_minimum, 0) or
	 isnull(source.bonus_payout_maximum, 0) <> isnull(target.bonus_payout_maximum, 0) or
	 isnull(source.bonus_payout_daily, 0) <> isnull(target.bonus_payout_daily, 0) or
	 isnull(source.bonus_payout_daily_minimum, 0) <> isnull(target.bonus_payout_daily_minimum, 0) or
	 isnull(source.Rank_Connects_Daily, 0) <> isnull(target.Rank_Connects_Daily, 0) or
	 isnull(source.Rank_Connects_Week, 0) <> isnull(target.Rank_Connects_Week, 0) or
	 isnull(source.Rank_Connects_MTD, 0) <> isnull(target.Rank_Connects_MTD, 0) or
	 isnull(source.Rank_Converts_Daily, 0) <> isnull(target.Rank_Converts_Daily, 0) or
	 isnull(source.Rank_Converts_Week, 0) <> isnull(target.Rank_Converts_Week, 0) or
	 isnull(source.Rank_Converts_MTD, 0) <> isnull(target.Rank_Converts_MTD, 0) or
	 isnull(source.Rank_LeadsStep2_Daily, 0) <> isnull(target.Rank_LeadsStep2_Daily, 0) or
	 isnull(source.Rank_LeadsStep2_Week, 0) <> isnull(target.Rank_LeadsStep2_Week, 0) or
	 isnull(source.Rank_LeadsStep2_MTD, 0) <> isnull(target.Rank_LeadsStep2_MTD, 0) or
	 isnull(source.Rank_LTs_Daily, 0) <> isnull(target.Rank_LTs_Daily, 0) or
	 isnull(source.Rank_LTs_Week, 0) <> isnull(target.Rank_LTs_Week, 0) or
	 isnull(source.Rank_LTs_MTD, 0) <> isnull(target.Rank_LTs_MTD, 0) or
	 isnull(source.gap_to_qa_70, 0) <> isnull(target.gap_to_qa_70, 0) or
	 isnull(source.gap_to_qa_80, 0) <> isnull(target.gap_to_qa_80, 0) or
	 isnull(source.gap_to_qa_85, 0) <> isnull(target.gap_to_qa_85, 0) or
	 isnull(source.gap_to_qa_90, 0) <> isnull(target.gap_to_qa_90, 0) or
	 isnull(source.qa_month_to_date_next_target, 0) <> isnull(target.qa_month_to_date_next_target, 0) 

	 --isnull(source.IA_Pay_Locked, 0) <> isnull(target.IA_Pay_Locked, 0)

	  
)
then 
update set target.email = source.email
		  ,target.wage_inflator = source.wage_inflator
		  ,target.day_of_week = source.day_of_week
		  ,target.seat_cost = source.seat_cost
		  ,target.data_cost = source.data_cost
		  ,target.target_hours = source.target_hours
		  ,target.wage_hours_productive = source.wage_hours_productive
		  ,target.wage_hours_non_productive = source.wage_hours_non_productive
		  ,target.dollars_productive_base = source.dollars_productive_base
		  ,target.dollars_non_productive_base = source.dollars_non_productive_base
		  ,target.dollars_productive_base_loaded = source.dollars_productive_base_loaded
		  ,target.dollars_non_productive_base_loaded = source.dollars_non_productive_base_loaded
		  ,target.VTO_hours = source.VTO_hours
		  ,target.PTO_hours = source.PTO_hours
		  ,target.discount_hours = source.discount_hours
		  ,target.applied_costs = source.applied_costs
		  ,target.applied_costs_per_hour = source.applied_costs_per_hour
		  ,target.cost_discounts = source.cost_discounts
		  ,target.total_applied_agent_costs = source.total_applied_agent_costs
		  ,target.dlr_time_total = source.dlr_time_total
		  ,target.dlr_time_productive = source.dlr_time_productive
		  ,target.dlr_time_deassigned = source.dlr_time_deassigned
		  ,target.dlr_time_paused = source.dlr_time_paused
		  ,target.tot_calls = source.tot_calls
		  ,target.tot_connects = source.tot_connects
		  ,target.tot_converts_step2 = source.tot_converts_step2
		  ,target.tot_leads_step2 = source.tot_leads_step2
		  ,target.tot_lts = source.tot_lts
		  ,target.UnauditedRevenue = source.UnauditedRevenue
		  ,target.AgentRevenue = source.AgentRevenue
		  ,target.agent_daily_profit = source.agent_daily_profit
		  ,target.MaxCalLDateTime = source.MaxCalLDateTime
		  ,target.MaxLeadDateTime = source.MaxLeadDateTime
		  ,target.year_month = source.year_month
		  ,target.week_start = source.week_start
		  ,target.qa_scored_calls = source.qa_scored_calls
		  ,target.qa_passed_calls = source.qa_passed_calls
		  ,target.total_monthly_profit = source.total_monthly_profit
		  ,target.monthly_tot_connects = source.monthly_tot_connects
		  ,target.monthly_tot_converts_step2 = source.monthly_tot_converts_step2
		  ,target.monthly_tot_leads_step2 = source.monthly_tot_leads_step2
		  ,target.monthly_tot_lts = source.monthly_tot_lts
		  ,target.total_weekly_profit = source.total_weekly_profit
		  ,target.weekly_tot_connects = source.weekly_tot_connects
		  ,target.weekly_tot_converts_step2 = source.weekly_tot_converts_step2
		  ,target.weekly_tot_leads_step2 = source.weekly_tot_leads_step2
		  ,target.weekly_tot_lts = source.weekly_tot_lts
		  ,target.total_weekly_profit_this = source.total_weekly_profit_this
		  ,target.weekly_tot_connects_this = source.weekly_tot_connects_this
		  ,target.weekly_tot_converts_step2_this = source.weekly_tot_converts_step2_this
		  ,target.weekly_tot_leads_step2_this = source.weekly_tot_leads_step2_this
		  ,target.weekly_tot_lts_this = source.weekly_tot_lts_this
		  ,target.total_monthly_profit_this = source.total_monthly_profit_this
		  ,target.monthly_tot_connects_this = source.monthly_tot_connects_this
		  ,target.monthly_tot_converts_step2_this = source.monthly_tot_converts_step2_this
		  ,target.monthly_tot_leads_step2_this = source.monthly_tot_leads_step2_this
		  ,target.monthly_tot_lts_this = source.monthly_tot_lts_this
		  ,target.profit_share = source.profit_share
		  ,target.next_tier_target = source.next_tier_target
		  ,target.month_qa_score = source.month_qa_score
		  ,target.qa_modifier = source.qa_modifier
		  ,target.qa_total_monthly_pass = source.qa_total_monthly_pass
		  ,target.qa_total_monthly_scores = source.qa_total_monthly_scores
		  ,target.qa_total_monthly_average = source.qa_total_monthly_average
		  ,target.Active_Code = source.Active_Code
		  ,target.Address1 = source.Address1
		  ,target.Day_Date = source.Day_Date
		  ,target.Dept_Code = source.Dept_Code
		  ,target.Dept_Mgr = source.Dept_Mgr
		  ,target.Dept_Name = source.Dept_Name
		  ,target.hire_date = source.hire_date
		  ,target.sname = source.sname
		  ,target.term_date = source.term_date
		  ,target.bonus_payout = source.bonus_payout
		  ,target.bonus_payout_minimum = source.bonus_payout_minimum
		  ,target.bonus_payout_maximum = source.bonus_payout_maximum
		  ,target.bonus_payout_daily = source.bonus_payout_daily
		  ,target.bonus_payout_daily_minimum = source.bonus_payout_daily_minimum
		  ,target.Rank_Connects_Daily = source.Rank_Connects_Daily
		  ,target.Rank_Connects_Week = source.Rank_Connects_Week
		  ,target.Rank_Connects_MTD = source.Rank_Connects_MTD
		  ,target.Rank_Converts_Daily = source.Rank_Converts_Daily
		  ,target.Rank_Converts_Week = source.Rank_Converts_Week
		  ,target.Rank_Converts_MTD = source.Rank_Converts_MTD
		  ,target.Rank_LeadsStep2_Daily = source.Rank_LeadsStep2_Daily
		  ,target.Rank_LeadsStep2_Week = source.Rank_LeadsStep2_Week
		  ,target.Rank_LeadsStep2_MTD = source.Rank_LeadsStep2_MTD
		  ,target.Rank_LTs_Daily = source.Rank_LTs_Daily
		  ,target.Rank_LTs_Week = source.Rank_LTs_Week
		  ,target.Rank_LTs_MTD = source.Rank_LTs_MTD
		  ,target.gap_to_qa_70 = source.gap_to_qa_70
		  ,target.gap_to_qa_80 = source.gap_to_qa_80
		  ,target.gap_to_qa_85 = source.gap_to_qa_85
		  ,target.gap_to_qa_90 = source.gap_to_qa_90
		  ,target.qa_month_to_date_next_target = source.qa_month_to_date_next_target

		  --,target.IA_Pay_Locked = source.IA_Pay_Locked


;


GO


