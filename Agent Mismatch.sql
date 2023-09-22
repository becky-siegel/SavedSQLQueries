USE LEDBI 

declare @TheDate as datetime = dateadd(hour, -1, getdate()) -- EST


declare @Today as date = @TheDate, --getdate(),
        @LastBusinessDay as date = dateadd(day, case (datepart(weekday, @TheDate)) 
                                        when 1 then -2 
                                        when 2 then -3 
                                        else -1 
                                        end, datediff(day, 0, @TheDate)),
        @SameDayLastWeek as date = dateadd(day,-7, @TheDate),
        @SameDay4WeeksAgo as date = dateadd(day,-28, @TheDate),
        @TheHour int = datepart(hour, @TheDate),
              @TSR varchar(50),
              @CorrectCallCenterID int,
              @InCorrectCallCenterID int


select @tsr = t.tsr, @CorrectCallCenterID = t.CallCenterID, @InCorrectCallCenterID = cl.call_center_id
         --,cast(getdate() as date) as Day_Date
from TSRMGR t (nolock)
       --left outer join LEDBI.dbo.tsrmaster tmstr (nolock) on (t.tsr = tmstr.tsr and t.CallCenterID = tmstr.CallCenterID AND t.Day_Date = tmstr.date_updated)
       left outer join LEDBI.dbo.CallLog cl (nolock) on (cl.tsr = t.Tsr and cast(cl.call_datetime as date) = t.Day_Date)
where t.Day_Date in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)--= cast(getdate() as date)
and cast(cl.call_datetime as date) in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
--and t.CallCenterID in (1,17)
--and cl.call_center_id in (1,17)
--and t.address1 <> 'CSR'
and t.CallCenterID <> cl.call_center_id
and t.sname <> ''
order by t.tsr

select @tsr, @CorrectCallCenterID, @InCorrectCallCenterID

select *
from TSRMGR t (nolock)
where t.Day_Date in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
and t.Tsr = @tsr

select *
--delete x
from AgentHourDailyInfo x
where cast(x.Call_Date as date) in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
       and x.Tsr = @tsr
       and x.call_center_id = @InCorrectCallCenterID


select *
--delete x
from AgentStates x
where cast(x.Call_Date as date) in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
       and x.Tsr = @tsr
       and x.call_center_id = @InCorrectCallCenterID

select *
--delete x
from AgentTime x
where cast(x.Call_Date as date) in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
       and x.agent_id = @tsr
       and x.call_center_id = @InCorrectCallCenterID

select *
--delete x
from CallLog x
where cast(x.call_datetime as date) in (@Today, @LastBusinessDay, @SameDayLastWeek, @SameDay4WeeksAgo)
       and x.Tsr = @tsr
       and x.call_center_id = @InCorrectCallCenterID
