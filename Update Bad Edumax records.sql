SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
	
DECLARE @begin_date AS DATETIME
SET @begin_date = '2021-03-01'



--Missing ProspectFlowID 
--/*
SELECT 
f.[Match], f.CCRepId, f.DateEntered, f.ProspectFlowID, f.Reprocess, ISNULL(e.ProspectFlowID, ei.ProspectFlowID) AS ProspectFlowID

, f.FirstName, f.LastName, f.EmailAddress, f.Phone1, f.Address1
FROM LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads f
LEFT JOIN LEDBI.dbo.EddyProspectInfo e	ON e.Email = f.EmailAddress
LEFT JOIN LEDBI.dbo.EddyProspectInfo_IA ei 	ON ei.Email = f.EmailAddress
LEFT JOIN LEDBI.dbo.CallLog c	on c.d_record_id = f.SessionId 	AND c.call_center_id = 1
LEFT JOIN ledbi.dbo.APPL_MasterDetail a	on a.appl = c.appl	and a.IsActive = 1
WHERE CAST(f.DateEntered AS DATE) >= @begin_date AND f.response = 'Something Else' AND f.Reprocess IS NULL
ORDER BY CAST(f.DateEntered AS DATE), f.EmailAddress

--Take the email from the above results and find a ProspectFlowID using 'Find a Prospect Record' query
--Enter ProspectFlowID and Match below; leave Reprocess = 1
/*
UPDATE LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads
SET ProspectFlowID = 27996786, Reprocess = 1
WHERE [Match] = '999A7C9C-2CAD-4B5F-8D73-88132806B70C_29770'
--*/

--*/


--Missing BuyerRevenue   
--/*  
SELECT   f.[Match], f.DateEntered, f.Buyer, f.BuyerRevenue, f.School, f.WarmTransferSchool, ir.avg_cpi, f.Reprocess  
FROM LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads f  
LEFT JOIN LEDBI.dbo.third_party_school_mapping tt ON tt.PortalSchoolName = f.School  
LEFT JOIN (   
	SELECT DISTINCT   t.MappedSchoolName AS PortalSchool   , ir.lt   , AVG(ir.UnauditedRevenue) AS avg_cpi   
	FROM LEDBI.dbo.inquiry_ref ir (NOLOCK)   
	LEFT JOIN LEDBI.dbo.third_party_school_mapping t (NOLOCK) ON t.PortalSchoolName = ir.PortalSchoolName   
	WHERE ir.LeadDateCreated >= @begin_date AND SourceType <> 'Direct'   
	GROUP BY t.MappedSchoolName, ir.lt 
				) ir   ON ir.PortalSchool = tt.MappedSchoolName   AND ir.lt = f.WarmTransferSchool    
				
WHERE CAST(f.DateEntered AS DATE) >= @begin_date AND f.response = 'Missing BuyerRevenue' AND f.Reprocess IS NULL   
ORDER BY CAST(f.DateEntered AS DATE), f.EmailAddress    

--Round down and enter avg_cpi and Match below; leave Reprocess = 1  
/*  UPDATE LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads  
SET BuyerRevenue = 17, Reprocess = 1  WHERE [Match] = 'C3E7B73B-2CD5-4169-8D87-D862C4B8450B_2839'  
--*/  
--*/   

--Missing RepID; wait a day to resolve
/*
SELECT 
f.[Match]
, f.response
, f.DateEntered
, f.CCRepId
, c.tsr 
, c.d_record_id
, f.Reprocess
FROM LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads f
LEFT JOIN LEDBI.dbo.CallLog c
	ON c.call_datetime >= @begin_date
	AND c.d_record_id = f.SessionId
WHERE CAST(f.DateEntered AS DATE) >= @begin_date
AND f.response IN ('Missing CCRepID or Bad Value', 'MissingSessionID')
ORDER BY CAST(f.DateEntered AS DATE)

--update values, change Reprocess from NULL to 1
--take CCRepID and Match value from above, and paste below; keep Reprocess = 1

/*
UPDATE LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads 
SET CCRepId = 'edu_dyennerell', Reprocess = 1
WHERE [Match] = '910B0A7F-42FC-4EC4-B893-B93DE176F01A_CLUOHLEREV'
--*/
--*/




--Everything else - Program = Buyer 
/*
SELECT 
f.[Match]
, f.EmailAddress
, f.DateEntered
, f.ProspectFlowID
, f.Buyer
, f.TrackID
FROM LEDBI_Staging.dbo.EduMax_LeadImport_FailedLeads f
WHERE CAST(f.DateEntered AS DATE) >= @begin_date
AND f.response NOT in ('Something Else', 'Missing CCRepID or Bad Value',  'MissingSessionID')
ORDER BY CAST(f.DateEntered AS DATE), f.EmailAddress
--*/

