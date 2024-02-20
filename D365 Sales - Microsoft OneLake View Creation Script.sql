/*

This script creates the following four views in the lakehouse:
- Campaigns - for OOB Campaigns associated with Opportunities
- Customers - for OOB Accounts and Contacts associated with Opportunities
- Opportunities
- Owners - for OOB Teams and Users associated with Opportunities


Before running this script, be sure that the following Dataverse shortcuts are already in the lakehouse:
- account
- contact
- opportunity
- team
- systemuser
- territory
- stringmap
- campaign

- This model also assumes you're using the Dynamics 365 Dynamics 365 Sales Premium or Dynamics 365 Sales Enterprise, 
- both of which which includes the "territory" entity. 
- If you're using a different license, you'll need to replace the "territory" entity with the "salesterritory" 
- choice value in the "Customers" view.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- Campaign View
--
IF EXISTS(SELECT 'view exists' FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'Campaigns'AND TABLE_SCHEMA = 'dbo')
BEGIN
    DROP VIEW [dbo].[Campaigns]
END
GO
CREATE VIEW [dbo].[Campaigns]
AS
SELECT  [Base].[campaignid]
      , [Base].[name] [Campaign Name]
      , campaign_statecode.value [Campaign StateCode]
      , campaign_typecode.value [Campaign Type]
    FROM [campaign]       AS Base
    LEFT JOIN [stringmap] AS campaign_statecode
        ON  campaign_statecode.langid = 1033
        AND campaign_statecode.objecttypecode = 'campaign'
        AND campaign_statecode.attributename = 'statecode'
        AND campaign_statecode.attributevalue = [Base].statecode
    LEFT JOIN [stringmap] AS campaign_typecode
        ON  campaign_typecode.langid = 1033
        AND campaign_typecode.objecttypecode = 'campaign'
        AND campaign_typecode.attributename = 'typecode'
        AND campaign_typecode.attributevalue = [Base].typecode
    WHERE
        [Base].statecode = 0
        AND [Base].IsDelete IS NULL
GO
--
-- Customer View
-- Because the Opportunity entity has "Potential customer" as a customer lookup to both the account and contact entities,
-- the Customers view will be a union of the two entities, and ultimately a single dimension in the semantic layer.
--
IF EXISTS(SELECT 'view exists' FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'Customers'AND TABLE_SCHEMA = 'dbo')
BEGIN
    DROP VIEW [dbo].[Customers]
END
GO
CREATE VIEW [dbo].[Customers]
AS
SELECT  [Base].accountid customerid
      , 1 AS [CustomerEntityType]
      , [Base].name [Customer Name]
      , [Base].parentaccountidname [Parent Account]
      , [Base].address1_city [City]
      , [Base].address1_stateorprovince [State or Province]
      , [Base].address1_country [Country]
      , [Base].owneridname [Customer Owner]
      , ISNULL(account_industrycode.value,'N/A') [Industry]
      , [T].name AS [Territory]
      , [T].[parentterritoryidname] [Parent Territory]
      , ISNULL([T].[manageridname], 'No Territory Manager') [Territory Manager]
      , [T].territoryid
      , [Base].accountnumber AS [Customer ID]
      , account_businesstypecode.value [Business Type]
    FROM [account]              AS Base
    LEFT OUTER JOIN [territory] AS T
        ON  T.territoryid = Base.territoryid
    LEFT JOIN [stringmap] AS account_industrycode
        ON  account_industrycode.langid = 1033
        AND account_industrycode.objecttypecode = 'account'
        AND account_industrycode.attributename = 'industrycode'
        AND account_industrycode.attributevalue = [Base].industrycode
    LEFT JOIN [stringmap] AS account_businesstypecode
        ON  account_businesstypecode.langid = 1033
        AND account_businesstypecode.objecttypecode = 'account'
        AND account_businesstypecode.attributename = 'businesstypecode'
        AND account_businesstypecode.attributevalue = [Base].businesstypecode
    WHERE
        [Base].IsDelete IS NULL
        AND EXISTS
        (
            SELECT  *
                FROM [dbo].[opportunity] AS O
                WHERE
                    O.customerid = Base.accountid
                    and O.customerid_entitytype = 'account'
                    AND O.IsDelete IS NULL )     
UNION ALL

SELECT  [Base].contactid customerid
      , 2 AS [CustomerEntityType]
      , [Base].fullname [Customer Name]
      , [Parent].name [Parent Account]
      , [Base].address1_city
      , [Base].address1_stateorprovince
      , [Base].address1_country
      , [Parent].owneridname
      , ISNULL(account_industrycode.value,'N/A') industrycodename
      , [T].name AS [Territory]
      , [T].[parentterritoryidname] [Parent Territory]
      , ISNULL([T].[manageridname], 'No Territory Manager') [Territory Manager]
      , [T].territoryid
      , [Base].employeeid AS [Customer ID]
      , 'Retail Customer' AS [Business Type]
    FROM [contact]        AS Base
    LEFT JOIN [account]   AS Parent
        ON  Base.parentcustomerid = Parent.accountid
    LEFT OUTER JOIN [territory] AS T
        ON  T.territoryid = Parent.territoryid
    LEFT JOIN [stringmap] AS account_industrycode
        ON  account_industrycode.langid = 1033
        AND account_industrycode.objecttypecode = 'account'
        AND account_industrycode.attributename = 'industrycode'
        AND account_industrycode.attributevalue = [Parent].industrycode
    WHERE
        [Base].IsDelete IS NULL
        AND EXISTS
        (
            SELECT  *
                FROM [dbo].[opportunity] AS O
                WHERE
                    O.customerid = Base.contactid
                    and O.customerid_entitytype = 'contact'
                    AND O.IsDelete IS NULL )        
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- Opportunity View
--
IF EXISTS(SELECT 'view exists' FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'Opportunities'AND TABLE_SCHEMA = 'dbo')
BEGIN
    DROP VIEW [dbo].[Opportunities]
END
GO
CREATE VIEW [dbo].[Opportunities]
AS
SELECT  [Base].opportunityid
      , CAST(DATEADD(hh,-8, [Base].createdon) AS DATE) [Created Date]
      , [Base].[name] [Opportunity Name]
      , [Base].ownerid
      , ownerid_entitytype
      , [Base].customerid
      , [Base].customerid_entitytype
      , [Base].estimatedvalue_base
      , [Base].actualvalue_base
      , [Base].closeprobability [Close Probability]
      , opportunity_opportunityratingcode.value [Rating]
      , opportunity_purchaseprocess.value [Purchase Process]
      , [Base].decisionmaker [Decision Maker Identified?]
      , [Base].discountpercentage/100 [Discount Percentage]
      , [Base].discountamount_base [Discount Amount]
      , [Base].stepname [Sales Stage]
      , [Base].campaignid
      , [Base].customerneed [Customer Need]
      , [Base].proposedsolution [Proposed Solution]
      , opportunity_statecode.value [Status]
      , opportunity_statuscode.value [Status Reason]
      , [Base].statecode
      , [Base].statuscode
      , CAST(DATEADD(hh,-8, ISNULL([Base].estimatedclosedate, [Base].createdon)) AS DATE) [Estimated Close Date]
      , CAST(DATEADD(hh,-8, [Base].actualclosedate) AS DATE) [Actual Close Date]
    FROM [opportunity] [Base]
    LEFT JOIN [stringmap] opportunity_opportunityratingcode
        ON  opportunity_opportunityratingcode.langid = 1033
        AND opportunity_opportunityratingcode.objecttypecode = 'opportunity'
        AND opportunity_opportunityratingcode.attributename = 'opportunityratingcode'
        AND opportunity_opportunityratingcode.attributevalue = [Base].opportunityratingcode
    LEFT JOIN [stringmap] opportunity_purchaseprocess
        ON  opportunity_purchaseprocess.langid = 1033
        AND opportunity_purchaseprocess.objecttypecode = 'opportunity'
        AND opportunity_purchaseprocess.attributename = 'purchaseprocess'
        AND opportunity_purchaseprocess.attributevalue = [Base].purchaseprocess
    LEFT JOIN [stringmap] opportunity_statecode
        ON  opportunity_statecode.langid = 1033
        AND opportunity_statecode.objecttypecode = 'opportunity'
        AND opportunity_statecode.attributename = 'statecode'
        AND opportunity_statecode.attributevalue = [Base].statecode
    LEFT JOIN [stringmap] opportunity_statuscode
        ON  opportunity_statuscode.langid = 1033
        AND opportunity_statuscode.objecttypecode = 'opportunity'
        AND opportunity_statuscode.attributename = 'statuscode'
        AND opportunity_statuscode.attributevalue = [Base].statuscode
    WHERE
        [Base].IsDelete IS NULL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
-- Owner View
-- Because the Opportunity entity's "Owner" can lookup to either a team or a user,
-- the Owners view will be a union of those two entities, and ultimately a single dimension in the semantic layer.
--
IF EXISTS(SELECT 'view exists' FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'Owners'AND TABLE_SCHEMA = 'dbo')
BEGIN
    DROP VIEW [dbo].[Owners]
END
GO
CREATE VIEW [dbo].[Owners]
AS
SELECT  [Base].[teamid] ownerid
      , 'Team' [Owner Type]
      , 9 AS OwnerEntityTypeCode
      , [Base].[name] [Owner Name]
      , [Base].administratoridname [Manager Name]
    FROM [dbo].[team] AS Base
    WHERE
        [Base].IsDelete IS NULL
        AND EXISTS
        (
            SELECT  *
                FROM [dbo].[opportunity] AS O
                WHERE
                    O.ownerid = Base.teamid
                    AND O.IsDelete IS NULL )

UNION ALL

SELECT  [Base].systemuserid
      , 'User'
      , 8 AS OwnerEntityTypeCode
      , [Base].fullname
      , [Manager].fullname
    FROM [dbo].[systemuser] [Base]
    LEFT OUTER JOIN [dbo].[systemuser] Manager
        ON  [Manager].systemuserid = [Base].parentsystemuserid
    WHERE
        [Base].IsDelete IS NULL
        AND EXISTS
        (
            SELECT  *
                FROM [dbo].[opportunity] AS O
                WHERE
                    O.ownerid = Base.systemuserid
                    AND O.IsDelete IS NULL )
GO