SET NOCOUNT ON

IF OBJECT_ID('tempdb..#agents') IS NOT NULL DROP TABLE #agents
IF OBJECT_ID('tempdb..#cc_tsr') IS NOT NULL DROP TABLE #cc_tsr
IF OBJECT_ID('tempdb..#cc_sms_ob') IS NOT NULL DROP TABLE #cc_sms_ob
IF OBJECT_ID('tempdb..#at_tsr') IS NOT NULL DROP TABLE #at_tsr

DECLARE @begin_date AS DATETIME
SET @begin_date = DATEADD(DAY ,DATEDIFF(DAY ,5  ,GETDATE()) ,0) 

CREATE TABLE #agents (tsr VARCHAR(50), sname VARCHAR(50), sname2 VARCHAR(50), agent_type VARCHAR(10), campaign VARCHAR(5)) 

INSERT INTO #agents (tsr, sname, sname2, agent_type, campaign) VALUES
('apanotes','AldrinP_0117TLSA P.','AldrinP_0117TLSA','PP','SMS')
,('jfmanalang','JeremyFeM_0118TLSA','JeremyFeM_0118T','PP','SMS')
,('jjganzo','JohnJaronG_1117TLSA G.','JohnJaronG_1117TLSA','PP','SMS')
,('tsakay','ToshioS_0118TLSA S.','ToshioS_0118TLSA','PP','SMS')
,('vvargas','VanjohV_0118TLSA V.','VanjohV_0118TLSA','PP','SMS')
,('kkarenas','KyleKevinA_1117SLG A.','KyleKevinA_1117SLG','PP','SMS')
,('rjaguilar','RuthJenineA_1117SLG A.','RuthJenineA_1117SLG','PP','SMS')
,('cvillanueva','CamilleV_0117REAL V.','CamilleV_0117REAL','PP','SMS')
,('cavidal','CarolV_0517REAL V.','CarolV_0517REAL','PP','SMS')
,('dbautista','DarwinB_0817REAL B.','DarwinB_0817REAL','PP','SMS')
,('emmanuel','EdMark_0118REAL M.','EdMark_0118REAL','PP','SMS')
,('kbanila','KhaelAngeloB_0118REAL B.','KhaelAngeloB_0118REAL','PP','SMS')
,('mturgo','MathewT_0917REAL T.','MathewT_0917REAL','PP','SMS')
,('lmasdo','LauranceM_1117REAL M.','LauranceM_1117REAL','PP','SMS')
,('rafernandez','RojieannF_0715REAL F.','RojieannF_0715REAL','PP','SMS')
,('jpato','JherinaP_0215Ort P.','JherinaP_0215Ort','PP','SMS')
,('qmisip','QianeMarkI_0315Ort I.','QianeMarkI_0315Ort','PP','SMS')
,('alariate','AngeloLuigiA_1016LGP L.','AngeloLuigiA_1016LGP','PP','SMS')
,('bmcredo','BenMichaelC_0118LGP C.','BenMichaelC_0118LGP','PP','SMS')
,('dllaguno','DianeL_0117LGP L.','DianeL_0117LGP','PP','SMS')
,('jbaroga','JayB_0217LGP N.','JayB_0217LGP','PP','SMS')
,('mlonosa','MariconL_0217LGP L.','MariconL_0217LGP','PP','SMS')
,('melaringo','MelanieA_1016LGP N.','MelanieA_1016LGP','PP','SMS')
,('rballon','RenelB_0316LGP B.','RenelB_0316LGP','PP','SMS')
,('rSerrano','RichmondS_0317LGP S.','RichmondS_0317LGP','PP','SMS')
,('rjmarbella','RubenJasonM_0317LGP n.','RubenJasonM_0317LGP','PP','SMS')
,('vgrando','VenzG_0117LGP G.','VenzG_0117LGP','PP','SMS')
,('abarrion','AlnieB_0217LGP B.','AlnieB_0217LGP','PP','SMS')
,('dmabino','DinahMarieA_1016LGP M.','DinahMarieA_1016LGP','PP','SMS')
,('mmarcos','McFelixM_0714LGP M.','McFelixM_0714LGP','PP','SMS')
,('jrcardana','JemzC_1217SLG C.','JemzC_1217SLG','Live voice','SMS')
,('acardana','AlegriaC_1217SLG C.','AlegriaC_1217SLG','Live voice','SMS')
,('alarsolega','ArnieA_0118SLG A.','ArnieA_0118SLG','Live voice','SMS')
,('agaron','AgapitoG_0118SLG G.','AgapitoG_0118SLG','Live voice','SMS')
,('jbajar','JervieB_1117SLG B.','JervieB_1117SLG','Live voice','SMS')
,('enaval','EugeneN_0118SLG N.','EugeneN_0118SLG','Live voice','SMS')
,('csantos','CortezaS_0118SLG S.','CortezaS_0118SLG','Live voice','SMS')
,('sambita','SheenAndreaA_0118SLG A.','SheenAndreaA_0118SLG','Live voice','SMS')
,('afrias','AdrianaF_0717PVR F.','AdrianaF_0717PVR','Live voice','SMS')
,('agonzalez','AlanM_0117PVR M.','AlanM_0117PVR','Live voice','SMS')
,('Alan_Mendoza','AngelG_1217PVR G.','AngelG_1217PVR','Live voice','SMS')
,('bcontreras','BrianC_0118PVR C.','BrianC_0118PVR','Live voice','SMS')
,('carlos','CarlosC_1117PVR D.','CarlosC_1117PVR','Live voice','SMS')
,('ezepeda','EldaZ_0917PVR Z.','EldaZ_0917PVR','Live voice','SMS')
,('jhernandez','Johnathan_0616PVR H.','Johnathan_0616PVR','Live voice','SMS')
,('Mary_Castillo','MaryC_0117PVR n.','MaryC_0117PVR','Live voice','SMS')
,('miguel_ramirez','MiguelR_0117PVR R.','MiguelR_0117PVR','Live voice','SMS')
,('mmercado','MarcoM_1117PVR M.','MarcoM_1117PVR','Live voice','SMS')
,('mvelarde','MichelleG_0118PVR V.','MichelleG_0118PVR','Live voice','SMS')
,('nataly','NatalyT_0417PVR T.','NatalyT_0417PVR','Live voice','SMS')
,('oduran1','OmarD1_1116PVR D.','OmarD1_1116PVR','Live voice','SMS')
,('ofigueroa','OlgaF_0118PVR F.','OlgaF_0118PVR','Live voice','SMS')
,('OQuero1','OmarQ1_0822PVR Q.','OmarQ1_0822PVR','Live voice','SMS')
,('sferrant','ScottP_1017PVR F.','ScottP_1017PVR','Live voice','SMS')
,('wchung','WillC_1117PVR C.','WillC_1117PVR','Live voice','SMS')
,('ygarcia','YenyB_0917PVR B.','YenyB_0917PVR','Live voice','SMS')
,('daguirre','DiomhelA_0118TLSA A.','DiomhelA_0118TLSA','PP','OB')
,('rabejuela','RachelleA_0717LGP A.','RachelleA_0717LGP','PP','OB')
,('mdelacruz','MayraDC_0616LGP D.','MayraDC_0616LGP','PP','OB')
,('emapula','ERicM_0815LGP n.','ERicM_0815LGP','PP','OB')
,('ccarino1','ChristinaC_0515Ort C.','ChristinaC_0515Ort','PP','OB')
,('mgrateja','MitchelleG_0516Ort G.','MitchelleG_0516Ort','PP','OB')
,('mtigue','MichaelT_0916TLSA T.','MichaelT_0916TLSA','PP','OB')
,('aibuyan','ArianI_0817ORT I.','ArianI_0817ORT','PP','OB')
,('fgaffud','FidelG_0815LGP G.','FidelG_0815LGP','PP','OB')
,('jmanasco','JuanMiguelA_0717TLSA A.','JuanMiguelA_0717TLSA','PP','OB')
,('alique','AlmaL_0117LGP L.','AlmaL_0117LGP','PP','OB')
,('cmreyes','ChanceMarielR_0617Ort R.','ChanceMarielR_0617Ort','PP','OB')
,('crosario','ChrishaDelR_0116TLSA R.','ChrishaDelR_0116TLSA','PP','OB')
,('rmabuti','RaymondM_0915TLSA M.','RaymondM_0915TLSA','PP','OB')
,('lcsalazar','LianCarloS_0717TLSA S.','LianCarloS_0717TLSA','PP','OB')
,('jtumbaga','JessicaT_0415LGP T.','JessicaT_0415LGP','PP','OB')
,('chbermejo','CarlHendrixB_0116Ort B.','CarlHendrixB_0116Ort','PP','OB')
,('mblazo','MarvinB_0514LGP B.','MarvinB_0514LGP','PP','OB')
,('kprotacio','KimberlyP_0717TLSA P.','KimberlyP_0717TLSA','PP','OB')
,('cmercado','CharmaineM_1116LGP M.','CharmaineM_1116LGP','PP','OB')
,('rbacay','script','script','script','NA')
,('smbriones','script','script','script','NA')
,('zcendana','script','script','script','NA')
,('None','None','None','PP','OB')
,('hflores','HaroldF_0415LGP','HaroldF_0415LGP','PP','OB')
,('cavidal','CarolV_0517REAL V.','CarolV_0517REAL','PP','SMS')
,('jfmanalang','JeremyFeM_0118TLSA','JeremyFeM_0118TLSA','PP','SMS')
,('cmercadero','CharmaineM_1116LGP M.','CharmaineM_1116LGP','PP','OB')
,('agaron','Agapito_0118SLG','Agapito_0118SLG','Live voice','SMS')
,('alarsolega','ArnieLynA_0118SLG','ArnieA_0118SLG','Live voice','SMS')
,('jrcardana','JemzRoldanC_1217SLG','JemzC_1217SLG','Live voice','SMS')
,('jfmanalang','jermyFeM_0122TLSA','JeremyFeM_0118T','PP','SMS')
,('traineelgp','script','script','script','NA')
,('cbparrenas','cbparrenas','cbparrenas','PP','OB')
,('rdetera','rdetera','rdetera','PP','SMS')
,('gmalicdem','gmalicdem','gmalicdem','PP','SMS')
,('anreyes','anreyes','anreyes','Live voice','SMS')
,('ffrancisco','ffrancisco','ffrancisco','Live voice','SMS')
,('craquid','craquid','craquid','Live voice','SMS')
,('fernando','fernando','fernando','Live voice','SMS')
,('corapi','corapi','corapi','Live voice','SMS')
,('marnaldo','MarkA_0217LGP','MarkA_0217LGP','PP','SMS')
,('sserilla','SharmaineS_1116LGP','SharmaineS_1116LGP','PP','SMS')
,('jaltarejos','JackelynA_0118LGP','jaltarejos','PP','SMS')
,('ajbuted','AxellJohnB_1016Ort','ajbuted','PP','SMS')
,('kmevangelista','KarlaMaeE_0717Ort','KarlaMaeE_0717Ort','PP','SMS')

SELECT 
distinct b.tsr
, CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END AS correct_user
, SUM(1) AS calls
INTO #cc_tsr
FROM LEDBI.dbo.bpo_call_log b
LEFT JOIN #agents a
	ON a.tsr = b.tsr
LEFT JOIN #agents a1
	ON a1.sname = b.tsr
LEFT JOIN #agents a2
	ON a2.sname2 = b.tsr
WHERE b.call_datetime >= @begin_date
AND b.CallCenterID = 49
AND a.tsr is null
GROUP BY
b.tsr
, CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END 


SELECT 
distinct b.record_id
, b.d_record_id
, CASE WHEN a1.campaign IS NULL THEN a2.campaign ELSE a1.campaign END AS call_type
INTO #cc_sms_ob
FROM LEDBI.dbo.bpo_call_log b
LEFT JOIN #agents a
	ON a.tsr = b.tsr
LEFT JOIN #agents a1
	ON a1.tsr = b.tsr
LEFT JOIN #agents a2
	ON a2.tsr = b.tsr
WHERE b.call_datetime >= @begin_date
AND b.CallCenterID = 49
AND a.tsr is not null
AND b.d_record_id NOT IN ('OB', 'SMS', 'NA')

SELECT 
distinct b.agent_id
, CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END AS correct_user

, SUM(1) AS calls
INTO #at_tsr
FROM LEDBI.dbo.BPO_agent_time b
LEFT JOIN #agents a
	ON a.tsr = b.agent_id
LEFT JOIN #agents a1
	ON a1.sname = b.agent_id
LEFT JOIN #agents a2
	ON a2.sname2 = b.agent_id
WHERE b.call_date >= @begin_date
AND b.call_center_id = 49
AND a.tsr is null
GROUP BY
b.agent_id
, CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END 





/*  update tsr values
UPDATE b
SET b.tsr = CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END 
FROM LEDBI.dbo.bpo_call_log b
LEFT JOIN #agents a
	ON a.tsr = b.tsr
LEFT JOIN #agents a1
	ON a1.sname = b.tsr
LEFT JOIN #agents a2
	ON a2.sname2 = b.tsr
WHERE b.call_datetime >= @begin_date
AND b.CallCenterID = 49
AND a.tsr is null
AND (a1.tsr IS NOT NULL or a2.tsr IS NOT NULL)  
*/

/*update sms/ob
UPDATE b
SET b.d_record_id = CASE WHEN a1.campaign IS NULL THEN a2.campaign ELSE a1.campaign END 
FROM LEDBI.dbo.bpo_call_log b
LEFT JOIN #agents a
	ON a.tsr = b.tsr
LEFT JOIN #agents a1
	ON a1.tsr = b.tsr
LEFT JOIN #agents a2
	ON a2.tsr = b.tsr
WHERE b.call_datetime >= @begin_date
AND b.CallCenterID = 49
AND a.tsr is not null
AND b.d_record_id NOT IN ('OB', 'SMS', 'NA')
*/

/*update agent_time
UPDATE b
SET b.agent_id = CASE WHEN a1.tsr IS NULL THEN a2.tsr ELSE a1.tsr END 
FROM LEDBI.dbo.BPO_agent_time b
LEFT JOIN #agents a
	ON a.tsr = b.agent_id
LEFT JOIN #agents a1
	ON a1.sname = b.agent_id
LEFT JOIN #agents a2
	ON a2.sname2 = b.agent_id
WHERE b.call_date >= @begin_date
AND b.call_center_id = 49
AND a.tsr is null
*/

--/*
SELECT * FROM #cc_tsr
SELECT * FROM #cc_sms_ob
SELECT * FROM #at_tsr
--*/