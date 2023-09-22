
DECLARE @begin_date AS DATETIME
SET @begin_date = '2018-06-08'


select cast(b.call_datetime as date) AS call_date
	  ,call_datetime
	  ,call_datetime_terminated
	  ,b.record_id AS d_record_id
	  ,b.appl
	  ,b.tsr AS css_tsr
	  ,b.ani
	  ,b.CallCenterID
	  ,'bpo_call_log' AS Source_table
into #BPO_call_log
from ledbi.dbo.BPO_call_log b (nolock)
	inner join ledbi.dbo.CallLogStatusMapping cl (nolock) on (cl.CallLogStatus = b.STATUS)
where b.call_datetime >= @begin_date
	and b.CallCenterID = 59
	and cl.IsConnect = 1
	
	--Look for bad dispo
	and cl.IsTransfer = 1
	


select c.ani
	  ,c.appl
	  ,c.tsr
	  ,c.STATUS
	 ,CASE WHEN ir.dialerkey is not null then 1 else 0 end as conversion
	 ,c.call_datetime
	 ,count(distinct ir.LeadID) as Leads
	 ,dense_rank() over(partition by ani order by call_datetime desc) as TheRank
	 ,c.d_record_id as DialerKey
into #call_log
from ledbi.dbo.call_log c (nolock)
	inner join ledbi.dbo.APPL_Info a (nolock) on (a.APPL = c.appl)
	inner join ledbi.dbo.CallLogStatusMapping cl (nolock) on (cl.CallLogStatus = c.STATUS)
	left join ledbi.dbo.inquiry_ref ir (nolock) on (ir.dialerkey = c.d_record_id)
where c.call_datetime >= @begin_date
	and a.bpo_transfer = 1
	and cl.IsConnect = 1
group by c.ani
	  ,c.appl
	  ,c.tsr
	  ,c.STATUS
	 ,CASE WHEN ir.dialerkey is not null then 1 else 0 end
	 ,c.call_datetime
	 ,c.d_record_id


 
select distinct bcl.call_date
	  ,bcl.d_record_id
	  ,bcl.appl
	  ,bcl.css_tsr
	  ,cl.tsr AS le_tsr
	  ,cl.STATUS
	  ,cl.conversion AS conversions
	  ,cl.Leads 
	  ,bcl.CallCenterID
	  ,cl.DialerKey
	  ,'bpo_call_log' AS Source_table 
from #BPO_call_log bcl
	inner join #call_log cl on (cl.ani = bcl.ani)
where cast(cl.call_datetime as time) > cast(bcl.call_datetime as time) and cast(cl.call_datetime as date) = cast(bcl.call_datetime as date)

	and (cast(cl.call_datetime as smalldatetime) between bcl.call_datetime and bcl.call_datetime_terminated)
	
	-- look for bad times
	--and (cast(cl.call_datetime as smalldatetime) between bcl.call_datetime and 
	--DATEADD(SECOND, datediff(second ,CAST(bcl.call_datetime AS datetime), bcl.call_datetime_terminated) + 20, CAST(bcl.call_datetime AS datetime))
	--)
	and not exists (select 1 from LEDBI.dbo.BPO_transfer_results where d_record_id = bcl.d_record_id)

order by d_record_id


 drop table #BPO_call_log
 drop table #call_log




/*
UPDATE ledbi.dbo.BPO_call_log 
SET call_datetime_terminated = 
DATEADD(SECOND, datediff(second ,CAST(call_datetime AS datetime), call_datetime_terminated) + 20, CAST(call_datetime AS datetime))

where record_id IN (

*/

--exec ledbi.dbo.usp_BPO_transfer_results