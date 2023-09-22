select 
distinct appl, max(left(record_id, 4)) AS last_record, MAX(call_datetime) AS last_start, MAX(call_datetime_terminated) AS last_end
into #last
from ledbi.dbo.CallLog
where call_datetime > '2021-04-01' and record_id like '%_BS' group by appl
/*
insert into ledbi.dbo.CallLog (record_id, d_record_id, call_datetime, call_datetime_terminated, ani, appl, tsr, STATUS, 
		time_holding, time_connect, time_acwork, call_center_id, agent_group) 
--*/
select 
concat(last_record + 2, '_BS') AS record_id, concat(last_record + 2, '_BS') AS d_record_id, DATEADD(DAY, CASE WHEN DATENAME(WEEKDAY, last_start) = 'Friday' THEN 3 ELSE 1 END, last_start) AS call_datetime
, DATEADD(DAY, CASE WHEN DATENAME(WEEKDAY, last_end) = 'Friday' THEN 3 ELSE 1 END, last_end) AS call_datetime_terminated, '9132546029' AS ani
, appl, '' AS tsr, 'No Answer' AS STATUS, 0 AS time_holding, 1 AS time_connect, 0 AS time_acwork, 72 AS call_center_id, 'OB' AS agent_group
from #last

drop table #last

select *
from ledbi.dbo.CallLog
where call_datetime >= '2021-04-01'
and record_id like '%_BS'
order by call_datetime





/*
insert into ledbi.dbo.CallLog (record_id, d_record_id, call_datetime, call_datetime_terminated, ani, appl, tsr, STATUS, 
		time_holding, time_connect, time_acwork, call_center_id, agent_group) values

('3007_BS', '3007_BS', '2021-04-08 07:01:21.000', '2021-04-08 07:03:41.000', '9132546029',
	'QDIAFLNO', '', 'No Answer', 0, 1, 0, 72, 'OB')

*/
