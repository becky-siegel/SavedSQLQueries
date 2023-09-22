select e.LeadID
, e.Match
, SUBSTRING( CAST(e.URL AS NVARCHAR(max)), 
(CHARINDEX('QuestionKey":"Buyer","QuestionValue":"', CAST(URL AS NVARCHAR(max))) 
       +  LEN('QuestionKey":"Buyer","QuestionValue":"'))
, CHARINDEX('QuestionKey":"EduMax_Affiliate', CAST(URL AS NVARCHAR(max))) 
       -(CHARINDEX('QuestionKey":"Buyer","QuestionValue":"', CAST(URL AS NVARCHAR(max))) +  LEN('QuestionKey":"Buyer","QuestionValue":"') + 8)
)  AS Buyer
, SUBSTRING( CAST(e.URL AS NVARCHAR(max)), 
(CHARINDEX('QuestionKey":"School","QuestionValue":"', CAST(URL AS NVARCHAR(max))) 
       +  LEN('QuestionKey":"School","QuestionValue":"'))
, CHARINDEX('QuestionKey":"Buyer', CAST(URL AS NVARCHAR(max))) 
       -(CHARINDEX('QuestionKey":"School","QuestionValue":"', CAST(URL AS NVARCHAR(max))) +  LEN('QuestionKey":"School","QuestionValue":"') + 8)
)  AS School
, SUBSTRING( CAST(e.URL AS NVARCHAR(max)), 
(CHARINDEX('QuestionKey":"BuyerRevenue","QuestionValue":"', CAST(URL AS NVARCHAR(max))) 
       +  LEN('QuestionKey":"BuyerRevenue","QuestionValue":"'))
, 6)
AS Revenue
, DateImported AS date_posted

from ledbi.dbo.edumax_leadimport e

left join ledbi.dbo.inquiry_ref ir
	on ir.leadid = e.LeadID
	and ir.LeadDateCreated >= '2021-02-15'

where DateImported >= '2021-03-01'
and ir.leadid is null

order by DateImported