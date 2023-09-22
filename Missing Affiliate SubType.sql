SELECT
DISTINCT i.AffiliateLocationID
, ast.AffiliateSubTypeID
, st.Name AS AffiliateSubType
, l.Name

FROM EnterpriseODS.dbo.inquiry i (NOLOCK)

LEFT JOIN Plattform_db.dbo.Affiliate_AffiliateSubTypeXref ast (NOLOCK)
	ON ast.LocationID = i.AffiliateLocationId

LEFT JOIN Plattform_DB.dbo.AffiliateSubType st (NOLOCK)
	ON st.AffiliateSubTypeID = ast.AffiliateSubTypeID

LEFT JOIN Plattform_db.dbo.location l (NOLOCK) 
	ON l.LocationID = i.AffiliateLocationId

WHERE i.leaddatecreated >= DATEADD(DAY ,DATEDIFF(DAY ,7  ,GETDATE()) ,0)  
AND i.AffiliateTypeID = 2 
AND i.IsTest = 0 
AND i.LeadStateCode IN ('Billed', 'Delivered') 
AND i.LeadStatusCode IN ('OK', 'Credited', 'Error') 
AND i.UnauditedRevenue > 0
AND i.IsRepostedFlag = 0

AND ast.AffiliateSubTypeID IS NULL

