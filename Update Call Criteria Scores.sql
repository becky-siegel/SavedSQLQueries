declare @sessionid VARCHAR(100) = '31787959'

--/*
select * from ledbi.dbo.call_criteria_scorecard_response where session_id = @sessionid and result = 'No'
select * from ledbi.dbo.call_criteria_scorecard  where session_id = @sessionid
select * from ledbi.dbo.ScoreCard_Overall_2019 where session_id = @sessionid
--*/

/*
update ledbi.dbo.call_criteria_scorecard
set value = 'pass' where session_id = @sessionid and keyname = 'pass_fail'
update ledbi.dbo.call_criteria_scorecard
set value = '100' where session_id = @sessionid and keyname = 'total_score_with_fails'
update ledbi.dbo.call_criteria_scorecard
set value = '100' where session_id = @sessionid and keyname = 'total_score'
update ledbi.dbo.call_criteria_scorecard
set value = 0 where session_id = @sessionid and keyname = 'num_missed'
update ledbi.dbo.call_criteria_scorecard_response
set result = 'yes' where session_id = @sessionid and result = 'No'
update ledbi.dbo.ScoreCard_Overall_2019 
set new_step2_pass_fail = 1 where session_id = @sessionid
--*/

/*
select *
from ledbi.dbo.CallLog
where d_record_id = '5D007677EE344D619C4AEBEECB971E0A'
*/

--EXEC LEDBI.dbo.usp_ScorecardOverall_Merge
--EXEC LEDBI.dbo.usp_ScorecardOverall_Merge_IA
