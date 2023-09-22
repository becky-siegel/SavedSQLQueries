/* run to find record/date causing the issue (from the SSISDB report)
select *
from ledbi.dbo.CallLog
where record_id like '19856014%'
-- */ 

--/*  Run to get a count before updating
select distinct datepart(month, call_datetime) as callmonth
, datepart(year, call_datetime) as call_year
,  min(cast(call_datetime as date)) as lastdate, count(*) from ledbi.dbo.CallLog (nolock)
where call_datetime >= '2021-01-01'
and call_datetime < '2023-01-01'
and record_id NOT LIKE '%/_%' ESCAPE '/'
group by datepart(month, call_datetime), datepart(year, call_datetime)
order by datepart(year, call_datetime), datepart(month, call_datetime)
--*/

/* update records on day in question
update ledbi.dbo.calllog
set record_id = CONCAT(record_id, '_', call_center_id)
--select top 1 * from ledbi.dbo.CallLog (nolock)
where call_datetime >= '2021-01-01'
and call_datetime < '2022-01-01'
and record_id NOT LIKE '%/_%' ESCAPE '/'
--and call_center_id IN (21) --add if too many total records
--*/


