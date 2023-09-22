SELECT 
ir.LeadID
, ir.ListCode
, ir.DialerKey
, case when (ir.ListCode = 'IHNV' AND ir.LT = 1) THEN 65
	WHEN (ir.ListCode = 'IHNV' AND ir.LT = 0) THEN 26 ELSE
	CASE	WHEN a_edu.rpc IS NULL THEN a_moat.rpc ELSE a_edu.rpc END 
	END AS RPC

FROM ledbi.dbo.inquiry_ref ir

LEFT JOIN ledbi.dbo.inquiry_ref_extended_info ire
	on ire.LeadID = ir.LeadID

LEFT JOIN ledbi.dbo.nv_agent_rpc a_edu
	ON a_edu.affiliatelocationid = ir.AffiliateLocationID
	AND a_edu.LocationID = ire.LocationId
	AND a_edu.LT = ir.lt

LEFT JOIN ledbi.dbo.nv_agent_rpc a_moat
	ON a_moat.affiliatelocationid = ir.AffiliateLocationID
	AND a_moat.organizationid = ir.OrganizationID
	AND a_moat.lt = ir.lt

WHERE ir.LeadDateCreated >= '2018-11-01'
AND ir.CallCenterID = 21
