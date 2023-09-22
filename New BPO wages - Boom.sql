-- DO NOT CHANGE THESE LINES ---------------------------------------------------
    SET NOCOUNT ON
    DECLARE @begin_date DATETIME = '2023-04-01'--'{begin_date}'
    DECLARE @end_date DATETIME = '2023-05-01'--'{end_date}'
--------------------------------------------------------------------------------
DECLARE @call_center_id INT = 49

 SELECT
          CASE WHEN b.agent_group = 'LX_IA' THEN 'BPO_Hours_BPO_IA'
		  WHEN b.agent_group = 'LX' THEN 'BPO_Hours_Step_1'
		  ELSE 'Error' END AS ext_datasource
        , CONCAT(b.agent_id,'_',b.call_date,'_',b.agent_group)     AS ext_uid 
        , b.call_center_id AS callcenter_id
         , b.call_date          AS action_timestamp 
         , CASE WHEN b.agent_group = 'LX_IA' THEN 'COSTBOOMIA'
		  WHEN b.agent_group = 'LX' THEN 'COSTBOOM'
		  ELSE 'Error' END AS listcode
		, CAST(CAST(SUM(b.time_connect + b.time_deassigned + b.time_acw)/60 AS FLOAT) /60 AS FLOAT) AS payable_qty
		, CAST(CAST(SUM(b.time_connect + b.time_deassigned + b.time_acw)/60 AS FLOAT) /60 AS FLOAT) *  r.daily_rate AS payable_amount

		--, r.daily_rate
		--, b.agent_group

	FROM ledbi.dbo.AgentTime b (NOLOCK)

	LEFT JOIN LEDBI.dbo.bpo_daily_agent_rate r
	ON r.Call_Date = b.call_date
	AND r.tsr = b.agent_id

	WHERE b.call_date >= @begin_date
	AND b.call_date < @end_date
    AND b.call_date <> CAST(GETDATE() AS DATE)
	AND DATENAME(WEEKDAY, b.call_date) NOT IN ('Saturday', 'Sunday')
	AND b.call_center_id = @call_center_id
	AND b.time_connect > 0
	AND b.agent_group NOT IN ('EF_OB_AV', 'EF_OB', 'LXP')

	GROUP BY
	  b.call_date
	, CONCAT(b.agent_id,'_',b.call_date,'_',b.agent_group)     
	, b.call_center_id
	, b.agent_group
	, r.daily_rate
