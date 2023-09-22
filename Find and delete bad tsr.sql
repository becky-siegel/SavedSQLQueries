/*
select 
distinct tsr, agent_group
into #agents
from ledbi.dbo.CallLog
where call_datetime >= cast(getdate() as date)
select distinct tsr from #agents group by tsr having count(*) > 1
drop table #agents
*/

DECLARE @TSR as VARCHAR(50)
SET @TSR = 'EF_ljoseph'

--/*
select * FROM LEDBI.DBO.CallLog
where tsr = @TSR
and cast(call_datetime as date) = cast(getdate() as date)
SELECT * FROM LEDBI.dbo.AgentHourDailyInfo
where tsr = @TSR
and Call_Date = cast(getdate() as date)
SELECT * FROM LEDBI.dbo.Realtime
WHERE tsr = @TSR
and Call_Date = cast(getdate() as date)
--*/

/*
delete FROM LEDBI.DBO.CallLog
where tsr = @TSR
and cast(call_datetime as date) = cast(getdate() as date)
delete FROM LEDBI.dbo.AgentHourDailyInfo
where tsr = @TSR
and Call_Date = cast(getdate() as date)
delete FROM LEDBI.dbo.Realtime
WHERE tsr = @TSR
and Call_Date = cast(getdate() as date)
delete from ledbi.dbo.AgentTime
where agent_id = @TSR
and call_date = cast(getdate() as date)
delete from ledbi.dbo.AgentStates
where tsr = @TSR
and call_date = cast(getdate() as date)
--*/
