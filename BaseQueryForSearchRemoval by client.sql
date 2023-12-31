
IF OBJECT_ID('tempdb..#displayed') IS NOT NULL DROP TABLE #displayed
IF OBJECT_ID('tempdb..#active') IS NOT NULL DROP TABLE #active
IF OBJECT_ID('tempdb..#products') IS NOT NULL DROP TABLE #products
IF OBJECT_ID('tempdb..#clients') IS NOT NULL DROP TABLE #clients
IF OBJECT_ID('tempdb..#search') IS NOT NULL DROP TABLE #search

CREATE TABLE #clients (client VARCHAR(150))
INSERT INTO #clients (client) VALUES
--client_list '
 ('Florida Career College') 
--'/*catch*/
	
DECLARE @begin_date AS DATETIME
SET @begin_date =  '2021-09-08'
DECLARE @end_date AS DATETIME
SET @end_date = '2021-09-10'


SELECT
i.Name AS Institution
, l.TrackId
, pt.ProductName
INTO #products
FROM Nexus.dbo.LeadTbl l (NOLOCK)
INNER JOIN Nexus.dbo.CallCenterLead ccl (NOLOCK)
	ON ccl.LeadId = l.LeadId
	and ccl.CallCenterId IN (1, 17)
LEFT JOIN Nexus.dbo.ClientRelationship cr (NOLOCK)
	ON cr.ClientRelationshipId = l.ClientRelationshipId
LEFT JOIN Nexus.dbo.Institution i (NOLOCK)
	ON i.InstitutionId = cr.InstitutionId
LEFT JOIN Nexus.dbo.Product pt (NOLOCK)
	ON pt.ProductId = l.ProductID
WHERE l.CreatedDate_EST >= @begin_date
AND l.CreatedDate_EST < @end_date
AND CASE WHEN CHARINDEX(',', i.Name) = 0 THEN 
		CASE WHEN CHARINDEX('-', i.Name) = 0 THEN i.Name 
			ELSE LEFT(i.Name, CHARINDEX('-', i.Name)-1) END
		ELSE LEFT(i.Name, CHARINDEX(',', i.Name)-1) END 
		IN (select * from #clients)

SELECT
distinct InstitutionName, MatchResponseSearchId
into #active
FROM Reporting.active.MatchResponseSearchHistory m (NOLOCK)
WHERE TheDate >= @begin_date
AND TheDate < @end_date
AND m.Displayed = 1
AND CASE WHEN CHARINDEX(',', m.InstitutionName) = 0 THEN 
		CASE WHEN CHARINDEX('-', m.InstitutionName) = 0 THEN m.InstitutionName 
			ELSE LEFT(m.InstitutionName, CHARINDEX('-', m.InstitutionName)-1) END
		ELSE LEFT(m.InstitutionName, CHARINDEX(',', m.InstitutionName)-1) END 
		IN (select * from #clients)


SELECT DISTINCT mrs.MatchResponseSearchId, mr.CreatedDate as SearchDate, mrs.Email, mrs.TrackId
INTO #Search
from eddytracking.dbo.matchresponsesearch mrs with (nolock)
inner join eddytracking.dbo.matchresponse mr with (nolock)
       on mr.MatchResponseId = mrs.MatchResponseId
LEFT JOIN reporting.Active.SearchRemoval F with (nolock) ON F.SearchId = mrs.MatchResponseSearchId
INNER JOIN #active a
	ON a.MatchResponseSearchId = mrs.MatchResponseSearchId
where mr.CreatedDate >=  @begin_date
and  mr.CreatedDate <  @end_date



select DISTINCT
mrs.MatchResponseSearchId as SearchId, 
mrs.SearchDate,
 i.name
, c.Name as Campus
, case when crpm.ClientRelationProductMappingId is not null then 'Institution Level'
       when ccpm.ClientCampusProductMappingId is not null then 'Campus Level'
       when psi.PsiId is not null then 'Psi Level'
       when p.ProgramId is not null OR pp.ProgramProductId is not null then 'Program Level' end as RuleLevel
, coalesce(crpr.ProductName,cpr.ProductName,ppp.ProductName, psip.ProductName) as ProductName
, psi.PSIName
, coalesce(p.ProgramName, prog.ProgramName) as ProgramName
, mrsr.RuleName, mrsr.BaseRuleType, mrs.Email, mrs.TrackId

FROM  #Search mrs
inner join eddytracking.dbo.MatchResponseSearchRemoval mrsr with (nolock)
       on mrs.MatchResponseSearchId = mrsr.MatchResponseSearchId
inner join nexus.dbo.institution i with (nolock)
       on i.InstitutionId = mrsr.InstitutionId
left join nexus.dbo.ClientRelationProductMapping crpm with (nolock)
       on crpm.ClientRelationProductMappingId = mrsr.ClientRelationProductMappingId
left join nexus.dbo.product crpr with (nolock)
       on crpr.ProductId = crpm.ProductId
left join nexus.dbo.ClientCampusProductMapping ccpm with (nolock)
       on ccpm.ClientCampusProductMappingId = mrsr.ClientCampusProductMappingId
left JOIN nexus.dbo. product cpr with (nolock)
       on cpr.ProductId = ccpm.ProductId
left join nexus.dbo.ClientCampusProgramRelationship ccpr with (nolock)
       on ccpr.ClientCampusRelationshipId = ccpm.ClientCampusRelationshipId
left join nexus.dbo.ClientCampusRelationship ccr with (nolock)
       on ccr.ClientCampusRelationshipId = ccpr.ClientCampusRelationshipId
left join nexus.dbo.Campus c with (nolock)
       on c.CampusId = ccr.CampusId
left join nexus.dbo.psi with (nolock)
       on psi.PsiId = mrsr.PsiId
left join nexus.dbo.product psip with (nolock)
       on psip.productid = psi.productid
left join nexus.dbo.program p with (nolock)
       on p.ProgramId = mrsr.ProgramId
left join nexus.dbo.programproduct pp with (nolock)
       on pp.ProgramProductId = mrsr.ProgramProductId
left join nexus.dbo.product ppp with (nolock)
       on ppp.ProductId = pp.ProductId
left join nexus.dbo.ClientCampusProgramRelationship ccprel with (nolock)
       on ccprel.ClientCampusProgramRelationshipId = pp.ClientCampusProgramRelationshipID
left join nexus.dbo.CampusProgram cp with (nolock)
       on cp.CampusProgramId = ccprel.CampusProgramId
left join nexus.dbo.program prog with (nolock)
       on prog.ProgramId = cp.ProgramId

inner join #products pd
	ON pd.ProductName = coalesce(crpr.ProductName,cpr.ProductName,ppp.ProductName, psip.ProductName) 