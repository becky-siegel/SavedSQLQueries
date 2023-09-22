/* Run commented pieces first, then the rest
--set these to Monday after running weekend
DELETE
FROM LEDBI.dbo.Realtime
WHERE Call_Date >= '2020-10-19'
and tsr like 'csr_%'	
DELETE 
FROM LEDBI.dbo.AgentHourDailyInfo
WHERE Call_Date >= '2020-10-19'
and tsr like 'csr_%'

--run for current payable week
delete from highlander_d.dbo.enterprise_billableactionpayabledetail
where action_timestamp >= '2020-10-16'
and action_timestamp < CAST(GETDATE() AS DATE)
and cost_to_callcenter_id = 59
*/

--exec ledbi.dbo.usp_TransferResults



IF OBJECT_ID('tempdb..#agents') IS NOT NULL DROP TABLE #agents
CREATE TABLE #agents (ccfh_tsr VARCHAR(50), tsr VARCHAR(50), CallCenterID INT, CallCenter VARCHAR(50))

--set this to monday after running for the weekend
DECLARE @begin_date AS DATE  SET @begin_date = '2020-10-05'

INSERT INTO #agents (ccfh_tsr, tsr, CallCenterID, CallCenter) VALUES
 ('csr_mjones_', 'csr_mjones', 71, 'Internal CSR Team')
, ('csr_bgranger_', 'csr_bgranger', 71, 'Internal CSR Team')
, ('csr_jgivensdean_', 'csr_jgivensdean', 71, 'Internal CSR Team')
, ('csr_apazcoronel_', 'csr_apazcoronel', 71, 'Internal CSR Team')
, ('csr_djoas_', 'csr_djoas', 71, 'Internal CSR Team')
, ('csr_smceachern_', 'csr_smceachern', 71, 'Internal CSR Team')
, ('csr_tnkomo_', 'csr_tnkomo', 71, 'Internal CSR Team')

UPDATE c
SET c.tsr = a.tsr, c.call_center_id = a.CallCenterID
FROM LEDBI.dbo.CallLog c
INNER JOIN #agents a
	ON a.ccfh_tsr = c.tsr
WHERE c.call_datetime >= @begin_date
and c.call_datetime < CAST(GETDATE() AS DATE)


UPDATE c
SET c.tsr = a.tsr, c.call_center_id = a.CallCenterID
FROM LEDBI.dbo.AgentStates c
INNER JOIN #agents a
	ON a.ccfh_tsr = c.tsr
WHERE c.call_date >= @begin_date
and  c.call_date < CAST(GETDATE() AS DATE)


UPDATE c
SET c.agent_id = a.tsr, c.call_center_id = a.CallCenterID
FROM LEDBI.dbo.AgentTime c
INNER JOIN #agents a
	ON a.ccfh_tsr = c.agent_id
WHERE c.call_date >=  @begin_date
and c.call_date < CAST(GETDATE() AS DATE)