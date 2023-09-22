IF OBJECT_ID('tempdb..#thedate') IS NOT NULL DROP TABLE #thedate
IF OBJECT_ID('tempdb..#count') IS NOT NULL DROP TABLE #count


select case when datename(weekday, min(cast(call_datetime as date))) = 'Saturday'
		then dateadd(day, -1, min(cast(call_datetime as date)))
	when datename(weekday, min(cast(call_datetime as date))) = 'Sunday'
		then dateadd(day, -2, min(cast(call_datetime as date)))
		else min(cast(call_datetime as date)) end as thedate 
into #thedate
from ledbi.dbo.CallLog 
where call_datetime >= '2023-06-01'  
and call_datetime < '2023-07-01'
and record_id NOT LIKE '%/_%' ESCAPE '/'
--the loop will run through all of the records between these dates


declare @begindate as datetime
set @begindate = (select thedate from #thedate)
declare @enddate as datetime
set @enddate = DATEADD(MONTH, 1, DATEADD(DAY, 1, EOMONTH(@begindate)))

--select @begindate, @enddate

select 
  count(*) as calls
,  case when count(*) < 10000 then count(*) else round(count(*) / 10000,0) end as thecount
into #count
from ledbi.dbo.CallLog (nolock)
where cast(call_datetime as date) >= @begindate
and cast(call_datetime as date) < @enddate
and record_id NOT LIKE '%/_%' ESCAPE '/'


DECLARE @i int = 0

WHILE @i < (select thecount from #count)
BEGIN
    SET @i = @i + 1
/*
    PRINT 'The counter value is = ' + CONVERT(VARCHAR,@Counter)
    SET @Counter  = @Counter  + 1
*/
;WITH CTE AS 
( 
select top 10000 *
from ledbi.dbo.calllog
where call_datetime >= @begindate 
and call_datetime < @enddate
and record_id NOT LIKE '%/_%' ESCAPE '/'
order by call_datetime
) 
UPDATE CTE set record_id = CONCAT(record_id, '_', call_center_id, '_', DATEPART(YEAR, call_datetime))

END