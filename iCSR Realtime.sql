use LEDBI

/*  --check for converts for yesterday
select top 5*
from ledbi.dbo.realtime
where call_center_id = 71
and tot_converts_step1 > 0
order by call_date desc
*/

--set this to monday after running for the weekend
declare @StartDate date = '2020-10-12'
	   ,@EndDate date = getdate()


set transaction isolation level read uncommitted 

IF OBJECT_ID('tempdb..#CallLog') IS NOT NULL DROP TABLE #CallLog  -- formerly ibl
IF OBJECT_ID('tempdb..#AgentHourDailyInfo') IS NOT NULL DROP TABLE #AgentHourDailyInfo -- formerly adi
IF OBJECT_ID('tempdb..#InquiryRef') IS NOT NULL DROP TABLE #InquiryRef
IF OBJECT_ID('tempdb..#tr') IS NOT NULL DROP TABLE #tr
IF OBJECT_ID('tempdb..#bpotr') IS NOT NULL DROP TABLE #bpotr
IF OBJECT_ID('tempdb..#Stage_1') IS NOT NULL DROP TABLE #Stage_1


------------------------------------------------------------------------------------------------------------------------------------------------------

select distinct cl.tsr, cl.call_datetime, cl.appl, cl.record_id, cl.d_record_id, cl.[STATUS], cl.time_connect, cl.time_acwork, cl.call_center_id
into #CallLog
from LEDBI.dbo.CallLog cl (nolock)
	inner join LEDBI.dbo.CallCenter cc (nolock) on (cc.CallCenterID = cl.call_center_id)
where call_datetime >= @StartDate
	and cl.tsr <> ''
    --and cl.call_center_id in (select value from string_split(@CallCenterIDs, ','))
	and cc.IsActive = 1
	AND cl.tsr like 'csr_%'
	--and cl.agent_group <> 'OB'
	--and call_datetime >= @AnchorDate


select distinct ahdi.tsr, ahdi.appl, ahdi.Call_Date, ahdi.time_deassigned, ahdi.Time_Paused, ahdi.call_center_id, ahdi.call_hour, t.active_code, t.Dept_Name
, case when ahdi.call_center_id = 49 then ahdi.agent_group else  t.address1 end as Agent_Type
, t.hire_date, t.sname
into #AgentHourDailyInfo
from LEDBI.dbo.AgentHourDailyInfo ahdi (nolock)
	inner join CallCenter cc (nolock) on (cc.CallCenterID = ahdi.call_center_id)
	--left outer join LEDBI.dbo.tsrmaster tmstr (nolock) on (tmstr.tsr = ahdi.Tsr and tmstr.callcenterid = ahdi.call_center_id)
	left outer join TSRMGR t (nolock) on (t.tsr = ahdi.tsr and t.CallCenterID = ahdi.call_center_id AND t.Day_Date = ahdi.Call_Date) -- swapped out tsrmaster
where Call_Date >= @StartDate
	and cc.IsActive = 1
	and ahdi.tsr like 'csr_%'



select distinct ir.DialerKey, ir.leadid, lt, right(ir.SourceType, len(ir.SourceType) - charindex('_', ir.SourceType)) as SourceType, ir.UnauditedRevenue, ir.LeadDateCreated
into #InquiryRef
from inquiry_ref ir (nolock)
	inner join CallCenter cc (nolock) on (cc.CallCenterID = ir.CallCenterID)
where ir.LeadDateCreated >= @StartDate
	--and ir.CallCenterID in (select value from string_split(@CallCenterIDs, ','))
	and cc.IsActive = 1
	--and ir.LeadDateCreated >= @AnchorDate

select distinct d_record_id, css_tsr, conversions, leads
INTO #tr
from LEDBI.dbo.TransferResults tr (nolock)
	inner join CallCenter cc (nolock) on (cc.CallCenterID = tr.call_center_id)
where call_date >= @StartDate
--and tr.call_center_id in (select value from string_split(@CallCenterIDs_Transfers, ','))
	and cc.IsActive = 1
	and cc.IsBPO = 1

--and call_date >= @AnchorDate

------------------------------------------------------------------------------------------------------------------------------------------------------
-- identify types of calls
select distinct cl.tsr
	  ,cl.appl
	  ,cl.call_center_id
	  ,cast(cl.call_datetime as date) as call_date
	  ,datepart(hour, cast(cl.call_datetime as time)) as call_hour
	  ,amd.IsStep1
	  ,ir.SourceType
	  ,amd.CallType

	  ,cl.d_record_id
	  ,ir.leadid
	  ,ir.LT

	  ,cl.d_record_id as calls
	  ,case when clsm.isconnect = 1 then cl.d_record_id else null end  as connects
	  ,case when amd.IsStep1 = 1 then cl.d_record_id end as step1_calls
	  ,case when amd.IsStep1 = 0  then cl.d_record_id end as step2_calls
	  ,case when amd.IsStep1 =  1 and clsm.isconnect = 1 then cl.d_record_id end as step1_connects
	  ,case when amd.IsStep1 = 0 and clsm.isconnect = 1 then cl.d_record_id end as step2_connects
	  ,tr.d_record_id as transfers_to_step2
	  ,case when amd.IsStep1 = 1 then isnull(tr.leads, 0) end as leads_step1
      ,case when amd.IsStep1 = 0 then ir.LeadID end as leads_step2
	  ,tr.conversions  AS converts_step1
	  ,ir.DialerKey AS converts_step2
	  ,CASE WHEN ir.lt = 1 THEN ir.DialerKey END AS lts
	  ,CASE WHEN ir.lt = 0 THEN ir.DialerKey END AS cfs

	  ,(select distinct sum(isnull(cl2.time_connect, 0)) from #CallLog cl2 where cl2.d_record_id = cl.d_record_id) as time_connect
	  ,(select distinct sum(isnull(cl3.time_acwork, 0))from #CallLog cl3 where cl3.d_record_id = cl.d_record_id) as time_acw

	  ,isnull(ir.UnauditedRevenue, 0) as UnauditedRevenue
	  ,isnull(case when ir.LT = 0 then ir.UnauditedRevenue end, 0) as CF_UnauditedRevenue
	  ,isnull(case when ir.LT = 1 then ir.UnauditedRevenue end, 0) as LT_UnauditedRevenue

	  ,cl.call_datetime 
	  ,ir.LeadDateCreated


into #Stage_1 -- used to be into #perf
from #CallLog cl
	inner join CallLogStatusMapping clsm (nolock) on (clsm.CallLogStatus = cl.[STATUS] and clsm.IsActive = 1)
	inner join APPL_MasterDetail amd (nolock) ON (amd.appl = cl.appl and amd.IsActive = 1)
	left outer join #InquiryRef ir on (ir.DialerKey = cl.d_record_id)
	left outer join #tr tr on (tr.d_record_id = cl.d_record_id and tr.css_tsr = cl.tsr)

where cl.tsr like 'csr_%'



-- select distinct * from #Stage_1 where tsr = 'AB07' and appl = 'LTBPOELLE' and call_Date = '2019-10-01' and call_hour = 11


------------------------------------------------------------------------------------------------------------------------------------------------------

merge into dbo.Realtime target
using (

select distinct ahdi.tsr
	  ,ahdi.active_code
      ,ahdi.Agent_Type
	  ,ahdi.Dept_Name
	  ,ahdi.hire_date
	  ,ahdi.sname
	  ,ahdi.appl
	  ,ahdi.call_center_id
	  ,ahdi.Call_Date
	  ,ahdi.call_hour
	  --,case when amd.IsStep1 = 1 then 'Step 1' else 'Step 2' end as call_type -- BOOM, IA, NV
	  --,case when amd.IsStep1 = 1 then 'Step 1' when ahdi.appl = 'Agnt' THEN 'Non-prod' else LEFT(amd.description, CHARINDEX(' ', amd.description)-1) end as call_type  -- LX
	  ,case when ahdi.call_center_id = 1 then case when s1.IsStep1 = 1 then 'Step 1' when ahdi.appl = 'Agnt' THEN 'Non-prod' else s1.CallType end 
		    when ahdi.call_center_id <> 1 then case when s1.IsStep1 = 1 then 'Step 1' else 'Step 2' end
			else 'Not Available'
			end as call_type

	  ,sum(isnull(s1.UnauditedRevenue, 0)) as UnauditedRevenue
	  ,sum(isnull(s1.CF_UnauditedRevenue, 0)) as CF_UnauditedRevenue
	  ,sum(isnull(s1.LT_UnauditedRevenue, 0)) as LT_UnauditedRevenue

	  ,isnull(count(distinct s1.step1_calls), 0) as step1_calls
	  ,isnull(count(distinct s1.step1_connects), 0) as step1_connects
	  ,isnull(((sum(distinct case when s1.IsStep1 = 1 then isnull(s1.time_connect, 0) + isnull(s1.time_acw, 0) end)/60.0)/60.0), 0) as step1_time_productive
	  ,isnull(count(distinct s1.step2_calls), 0) as step2_calls
	  ,isnull(count(distinct s1.step2_connects), 0) as step2_connects
	  ,isnull(((sum(distinct case when s1.IsStep1 = 0 then isnull(s1.time_connect, 0) + isnull(s1.time_acw, 0) end)/60.0)/60.0), 0) step2_time_productive
	  ,((sum(isnull(s1.Time_Acw, 0))/60.0)/60.0) as time_acw
	  ,((sum(distinct isnull(ahdi.time_deassigned, 0))/60.0)/60.0) as time_deassigned
	  ,((sum(distinct isnull(ahdi.Time_Paused, 0))/60.0)/60.0) as time_paused
	  ,((sum(distinct isnull(s1.time_connect, 0) + isnull(s1.time_acw, 0))/60.0)/60.0) as time_productive
	  ,((sum(distinct isnull(s1.time_connect, 0) + isnull(ahdi.Time_Paused, 0) + isnull(ahdi.Time_Deassigned, 0) + isnull(s1.time_acw, 0))/60.0)/60.0) as time_total
	  ,isnull(count(distinct s1.calls), 0) as tot_calls
	  ,isnull(count(distinct case when s1.LT = 0 then s1.LeadID else null end), 0) as tot_cfs
	  ,isnull(count(distinct case when s1.LT = 1 then s1.LeadID else null end), 0) as tot_lts
	  ,isnull(count(distinct s1.connects), 0) as tot_connects
	  ,isnull(sum(s1.converts_step1), 0) as tot_converts_step1
	  ,isnull(count(distinct s1.converts_step2), 0) as tot_converts_step2
	  ,isnull(sum(s1.leads_step1), 0) as tot_leads_step1
	  ,isnull(count(distinct s1.leads_step2), 0) as tot_leads_step2
	  ,isnull(count(distinct case when s1.SourceType = 'ThirdParty' then s1.LeadID else null end), 0) as tot_third_party_leads
	  ,isnull(count(distinct s1.transfers_to_step2), 0) as transfers_to_step2
	  ,datediff(week, ahdi.hire_date, ahdi.call_date) as weeks_tenure
	  ,max(s1.call_datetime) as MaxCallDateTime
	  ,max(s1.LeadDateCreated) as MaxLeadDateTime
from #AgentHourDailyInfo ahdi
	left outer join #Stage_1 s1 on (s1.tsr = ahdi.Tsr and s1.call_date = ahdi.Call_Date and s1.appl = ahdi.appl and s1.call_hour = ahdi.call_hour and s1.call_center_id = ahdi.call_center_id)
--where ahdi.call_center_id = 1
group by ahdi.tsr
	  ,ahdi.active_code
      ,ahdi.Agent_Type
	  ,ahdi.Dept_Name
	  ,ahdi.hire_date
	  ,ahdi.sname
	  ,ahdi.appl
	  ,ahdi.call_center_id
	  ,ahdi.Call_Date
	  ,ahdi.call_hour
	  ,case when ahdi.call_center_id = 1 then case when s1.IsStep1 = 1 then 'Step 1' when ahdi.appl = 'Agnt' THEN 'Non-prod' else s1.CallType end 
		    when ahdi.call_center_id <> 1 then case when s1.IsStep1 = 1 then 'Step 1' else 'Step 2' end
			else 'Not Available'
			end

) as source on (source.tsr = target.tsr 
			and source.appl = target.appl
			and source.call_Date = target.call_Date
			and source.call_hour = target.call_hour
			and source.call_center_id = target.call_center_id -- check this one
			)

when not matched then 
insert (active_code, Agent_Type, appl, call_center_id, Call_Date, call_hour, call_type, CF_UnauditedRevenue, Dept_Name, hire_date
       ,LT_UnauditedRevenue, sname, step1_calls, step1_connects, step1_time_productive , tot_converts_step1, tot_leads_step1, step2_calls
	   ,step2_connects, step2_time_productive, tot_converts_step2, tot_leads_step2, transfers_to_step2, time_acw, time_deassigned, time_paused
	   ,time_productive, time_total, tot_calls, tot_connects, tot_cfs, tot_lts, tot_third_party_leads, tsr, UnauditedRevenue, weeks_tenure
	   ,MaxCallDateTime, MaxLeadDateTime)
values (source.active_code, source.Agent_Type, source.appl, source.call_center_id, source.Call_Date, source.call_hour, source.call_type, source.CF_UnauditedRevenue, source.Dept_Name, source.hire_date
       ,source.LT_UnauditedRevenue, source.sname, source.step1_calls, source.step1_connects, source.step1_time_productive, source.tot_converts_step1, source.tot_leads_step1, source.step2_calls
	   ,source.step2_connects, source.step2_time_productive, source.tot_converts_step2, source.tot_leads_step2, source.transfers_to_step2, source.time_acw, source.time_deassigned, source.time_paused
	   ,source.time_productive, source.time_total, source.tot_calls, source.tot_connects,source.tot_cfs, source.tot_lts, source.tot_third_party_leads, source.tsr, source.UnauditedRevenue, source.weeks_tenure
	   ,source.MaxCallDateTime, source.MaxLeadDateTime)


when matched 
and (
	 isnull(source.active_code, 0) <> isnull(target.active_code, 0)
  or isnull(source.Agent_Type, '') <> isnull(target.Agent_Type, '')
  or isnull(source.call_type, '') <> isnull(target.call_type, '')
  or isnull(source.CF_UnauditedRevenue, 0) <> isnull(target.CF_UnauditedRevenue, 0)
  or isnull(source.Dept_Name, '') <> isnull(target.Dept_Name, '')
  or isnull(source.hire_date, '') <> isnull(target.hire_date, '')
  or isnull(source.LT_UnauditedRevenue, 0) <> isnull(target.LT_UnauditedRevenue, 0)
  or isnull(source.sname, '') <> isnull(target.sname, '')
  or isnull(source.step1_calls, 0) <> isnull(target.step1_calls, 0)
  or isnull(source.step1_connects, 0) <> isnull(target.step1_connects, 0)
  or isnull(source.step1_time_productive, 0) <> isnull(target.step1_time_productive, 0)
  or isnull(source.tot_converts_step1, 0) <> isnull(target.tot_converts_step1, 0)
  or isnull(source.tot_leads_step1, 0) <> isnull(target.tot_leads_step1, 0)
  or isnull(source.step2_calls, 0) <> isnull(target.step2_calls, 0)
  or isnull(source.step2_connects, 0) <> isnull(target.step2_connects, 0)
  or isnull(source.step2_time_productive, 0) <> isnull(target.step2_time_productive, 0)
  or isnull(source.tot_converts_step2, 0) <> isnull(target.tot_converts_step2, 0)
  or isnull(source.tot_leads_step2, 0) <> isnull(target.tot_leads_step2, 0)
  or isnull(source.transfers_to_step2, 0) <> isnull(target.transfers_to_step2, 0)
  or isnull(source.time_acw, 0) <> isnull(target.time_acw, 0)
  or isnull(source.time_deassigned, 0) <> isnull(target.time_deassigned, 0)
  or isnull(source.time_paused, 0) <> isnull(target.time_paused, 0)
  or isnull(source.time_productive, 0) <> isnull(target.time_productive, 0)
  or isnull(source.time_total, 0) <> isnull(target.time_total, 0)
  or isnull(source.tot_calls, 0) <> isnull(target.tot_calls, 0)
  or isnull(source.tot_connects, 0) <> isnull(target.tot_connects, 0)
  or isnull(source.tot_cfs, 0) <> isnull(target.tot_cfs, 0)
  or isnull(source.tot_lts, 0) <> isnull(target.tot_lts, 0)
  or isnull(source.tot_third_party_leads, 0) <> isnull(target.tot_third_party_leads, 0)
  or isnull(source.UnauditedRevenue, ' ') <> isnull(target.UnauditedRevenue, ' ')
  or isnull(source.weeks_tenure, 0) <> isnull(target.weeks_tenure, 0)  
  or isnull(source.MaxCallDateTime, '') <> isnull(target.MaxCallDateTime, '')  
  or isnull(source.MaxLeadDateTime, '') <> isnull(target.MaxLeadDateTime, '')  
)

then 
update set target.active_code = source.active_code
		  ,target.Agent_Type = source.Agent_Type
		  ,target.call_type = source.call_type
		  ,target.CF_UnauditedRevenue = source.CF_UnauditedRevenue
		  ,target.Dept_Name = source.Dept_Name
		  ,target.hire_date = source.hire_date
		  ,target.LT_UnauditedRevenue = source.LT_UnauditedRevenue
		  ,target.sname = source.sname
		  ,target.step1_calls = source.step1_calls
		  ,target.step1_connects = source.step1_connects
		  ,target.step1_time_productive = source.step1_time_productive
		  ,target.tot_converts_step1 = source.tot_converts_step1
		  ,target.tot_leads_step1 = source.tot_leads_step1
		  ,target.step2_calls = source.step2_calls
		  ,target.step2_connects = source.step2_connects
		  ,target.step2_time_productive = source.step2_time_productive
		  ,target.tot_converts_step2 = source.tot_converts_step2
		  ,target.tot_leads_step2 = source.tot_leads_step2
		  ,target.transfers_to_step2 = source.transfers_to_step2
		  ,target.time_acw = source.time_acw
		  ,target.time_deassigned = source.time_deassigned
		  ,target.time_paused = source.time_paused
		  ,target.time_productive = source.time_productive
		  ,target.time_total = source.time_total
		  ,target.tot_calls = source.tot_calls
		  ,target.tot_connects = source.tot_connects
		  ,target.tot_cfs = source.tot_cfs
		  ,target.tot_lts = source.tot_lts
		  ,target.tot_third_party_leads = source.tot_third_party_leads
		  ,target.UnauditedRevenue = source.UnauditedRevenue
		  ,target.weeks_tenure = source.weeks_tenure
		  ,target.MaxCallDateTime = source.MaxCallDateTime
		  ,target.MaxLeadDateTime = source.MaxLeadDateTime
		  ;
GO


