# Power BI ↔️ Dynamics 365 Sales report templates

These example reports are built to demonstrate using Power BI to report on a customer's Opportunities in Dynamics 365 CE Sales. 
- One example uses the TDS Endpoint to connect directly to Dataverse and is currently limited to 80MB per query
- The other two examples use the Dataverse Synapse Link approach for scaling to significantly larger datasets

![Sales Report](https://user-images.githubusercontent.com/6276300/199829890-550b6bbc-8465-4069-8e07-586e65874460.gif)


## Skills

1.	T-SQL – (Nothing deeper than Select/Join/Case/IsNull is needed)
2.	Power Query / Basic DAX / Power BI Data Modeling / Power BI Report development 
3.  Familiarity with Dataverse / Dynamics 365 sales entities

## Software:

1.	Access to a Dynamics 365 environment with sales data (See below for entities in scope)
2.	Current version of Power BI on your Desktop for editing
3.  If you'd like to share the reports with others, some version of Power BI Pro/Premium-per-user/Premium would be needed.
4.	Optional: [Bravo - for updating the calendar or adding time intelligence measures](https://bravo.bi/)
5.	Optional: [SSMS - SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms-19?view=sql-server-ver16)

## Report Variations:

- Contoso Sales - TDS - Opportunities.pbit
- Contoso Sales - Synapse - Opportunities.pbit
- Contoso Sales - Synapse - Opportunities with Product Lines.pbit


## Report assumptions/requirements:

1.	Custom fields and entities are entirely out of scope for the template, but nothing blocking a user from add custom fields to the existing queries/reports
2.	Opportunities customers are Accounts - Not impossible to adapt to a different use case, but be aware that it's baked into a few assumptions in the report
3.	Opportunities are owned by Users and owners have a manager for roll-up reporting
4.	Opportunity accounts (customers) are assigned a Sales Territory for roll-up reporting
6.	The DatesTimes are adjusted from GMT based on a single parameter (number of Hours) - The report does not auto-adjust to the viewers' timezone or daylight savings shifts the way Dynamics does
7.	The “…Opportunities with Product Lines” report additionally assumes: An Opportunity’s estimated and actual values are only calculated as the sum of line-items


## Dataverse TDS Endpoint based reports

1.	TDS Endpoint needs to be enabled and you need read access to the following entities:

    Territories; Accounts; Contacts; Opportunities; Campaigns; System Users; Teams
2.	Edit these four parameters in the report to meet your needs/environment:
    - <img src="https://user-images.githubusercontent.com/6276300/199821685-83d19441-56b9-46be-9549-eb1d8650c00d.png" width=600 align=center>
    

## Dataverse Azure Synapse Link for Synapse-based reports

1.	Synapse Link is operating, and you can connect to it with SSMS & Power BI. 
2.	Synapse Link is set to export (using default: append = no) with at least the following tables:
    
    Territories; Accounts; Contacts; Opportunities; Campaigns; System Users; Teams

    The “…Opportunities with Product Lines” report also needs: Opportunity Products and Products
    
3.	Edit these three parameters in the report to meet your needs/environment:
    - <img src="https://user-images.githubusercontent.com/6276300/199808416-2ddf48be-67b5-49f3-889b-0214cd4d4b72.png" width=600 align=center>
