USE LEDBI 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--set this to monday after running for the weekend
declare @StartDate date = '2020-10-12'
	   ,@EndDate date = getdate()


merge into dbo.AgentHourDailyInfo target
using (

select bcl.tsr
	  ,bcl.APPL
	  ,cast(bcl.call_datetime as date) as Call_Date
	  ,datepart(hour, bcl.call_datetime) as Call_Hour
	  ,sum(bcl.time_connect) as Time_Connect
	  ,0 as Time_Paused
	  ,0 as Time_waiting 
	  ,sum(bcl.time_acwork) as Time_Acw
	  ,0 as Time_Deassigned
	  --,affloc.AffiliateLocationID as Affiliate_Location_ID 
	  ,0 as Affiliate_Location_ID
	  ,count(distinct bcl.record_id) as Total_Calls
	  ,bcl.call_center_id 
	  ,bcl.agent_group
	  ,1 as SortOrder
from CallLog bcl (nolock)
	--inner join (SELECT cal.ListCode, casf.AffiliateLocationID 
	--	        FROM plattform.Plattform_DB.dbo.CAList cal (NOLOCK)
	--				INNER JOIN plattform.Plattform_DB.dbo.CASearchAffiliate casf (NOLOCK) ON (casf.CAListID = cal.CAListID AND casf.CallCenterID = 1)
	--				inner join plattform.plattform_db.dbo.location lo (nolock) on (lo.locationid = casf.affiliatelocationid and lo.statusid = 2)) affloc on (affloc.ListCode = bcl.appl)
where cast(bcl.call_datetime as date) between @StartDate and @EndDate
	and tsr <> ''
	and appl is not null
	--and bcl.agent_group <> 'OB'
	AND tsr like 'csr_%'

group by bcl.tsr
		,bcl.APPL
		,cast(bcl.call_datetime as date)
		,datepart(hour, bcl.call_datetime)
		,bcl.call_center_id
		,bcl.agent_group

union all


--declare @StartDate date = dateadd(week, -1, getdate())
--	   ,@EndDate date = getdate()

select bat.tsr
	  ,'Agnt' as Appl
	  ,bat.call_date as Call_Date
	  ,datepart(hour, state_time) as Call_Hour
	  ,0 as Time_Connect
	  ,sum(case when state_name <> 'Ready' then bat.duration else 0 end) as Time_Paused
	  ,0 as Time_waiting 
	  ,0 as Time_Acw
	  ,sum(case when state_name = 'Ready' then bat.duration else 0 end)	 as time_deassigned
	  ,0 as Affiliate_Location_ID 
	  ,0 as Total_Calls
	  ,bat.call_center_id
	  ,bat.agent_group
	  ,2 as SortOrder
FROM AgentStates bat (NOLOCK)
where state_name not in ('On Call', 'After Call Work', 'Ringing', 'On Hold', 'On Park')
	and bat.login_event = 0
	and bat.call_date between @StartDate and @EndDate
	AND bat.tsr like 'csr_%'
group by bat.tsr
		,bat.call_date
		,datepart(hour, state_time)
		--,bat.pause_time
		--,bat.time_ready
		--,bat.time_deassigned
		,bat.call_center_id
		,bat.agent_group


) as source on (source.tsr = target.tsr and source.appl = target.appl and source.call_date = target.call_date and source.call_center_id = target.call_center_id and source.Call_Hour = target.Call_Hour and source.agent_group = target.agent_group)

when not matched then 
insert (Tsr, Appl, Call_Date, Time_Connect, Time_Paused, Time_Waiting, Time_Acw, Total_Calls, Time_Deassigned, Affiliate_Location_ID, call_center_id, Call_Hour, agent_group)
values (source.Tsr, source.Appl, source.Call_Date, source.Time_Connect, source.Time_Paused, source.Time_Waiting, source.Time_Acw, source.Total_Calls, source.Time_Deassigned, source.Affiliate_Location_ID, source.call_center_id, source.Call_Hour, source.agent_group)

when matched 
and (source.Time_Connect <> target.Time_Connect or
	 source.Time_Paused <> target.Time_Paused or
	 source.Time_Waiting <> target.Time_Waiting or
	 source.Time_Acw <> target.Time_Acw or 
	 source.Total_Calls <> target.Total_Calls or
	 source.Time_Deassigned <> target.Time_Deassigned or
	 source.Affiliate_Location_ID <> target.Affiliate_Location_ID 
	 --source.call_center_id <> target.call_center_id
)
then 
update set target.Time_Connect = source.Time_Connect
		  ,target.Time_Paused = source.Time_Paused
		  ,target.Time_Waiting = source.Time_Waiting
		  ,target.Time_Acw = source.Time_Acw
		  ,target.Total_Calls = source.Total_Calls
		  ,target.Time_Deassigned = source.Time_Deassigned
		  ,target.Affiliate_Location_ID = source.Affiliate_Location_ID
		  --,target.call_center_id = source.call_center_id
;

GO


