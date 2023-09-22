
IF OBJECT_ID('tempdb..#logs') IS NOT NULL DROP TABLE #logs
IF OBJECT_ID('tempdb..#last') IS NOT NULL DROP TABLE #last
IF OBJECT_ID('tempdb..#out') IS NOT NULL DROP TABLE #out

SELECT 
sm_res_state_fact_key
, states.tsr
, end_datetime
INTO #logs
FROM ledbi.dbo.agent_states states with (NOLOCK)

LEFT JOIN ledbi.dbo.tsrmaster tsr with (NOLOCK)
	ON tsr.tsr = states.tsr

LEFT JOIN ledbi.dbo.TSRMGR mgr with (NOLOCK)
	ON mgr.tsr = states.tsr
	AND mgr.Day_Date = CAST(states.start_datetime AS DATE)

WHERE states.login_event = 1
AND CAST(states.start_datetime AS DATE) = '2019-01-02'
AND mgr.Address1 = 'DMI'

SELECT
tsr
, MAX(sm_res_state_fact_key) AS sm_res_state_fact_key
INTO #last
FROM #logs
GROUP BY
tsr

SELECT 
 states.tsr
, MAX(end_datetime) AS logout
INTO #out
FROM ledbi.dbo.agent_states states with (NOLOCK)

LEFT JOIN ledbi.dbo.tsrmaster tsr with (NOLOCK)
	ON tsr.tsr = states.tsr

LEFT JOIN ledbi.dbo.TSRMGR mgr with (NOLOCK)
	ON mgr.tsr = states.tsr
	AND mgr.Day_Date = CAST(states.start_datetime AS DATE)

WHERE CAST(states.start_datetime AS DATE) = '2019-01-02'
AND mgr.Address1 = 'DMI'

GROUP BY states.tsr


SELECT 
lt.*
, l.end_datetime
, o.logout


FROM ledbi.dbo.agent_states l

INNER join #last lt
on l.sm_res_state_fact_key = lt.sm_res_state_fact_key

left join #out o	
on o.tsr = lt.tsr