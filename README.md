# Alpha test of Power BI Sales report

## Skills

1.	Comfortable with Basic T-SQL – (Nothing deeper than Select/Join/Case/IsNull is needed)
2.	Comfortable with Power Query / Basic DAX / Power BI Data Modeling / Power BI Report dev

## Software:

1.	Access to a Dynamics 365 environment with *hopefully* lots of sales data
2.	Current version of Power BI on your Desktop
3.	Optional: [Bravo - for Caledar or Time Intelligence updates](https://bravo.bi/)
4.	Optional: [SSMS - SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms-19?view=sql-server-ver16)

## Variations:

- Contoso Sales - TDS - Opportunities.pbit
- Contoso Sales - Synapse - Opportunities.pbit
- Contoso Sales - Synapse - Opportunities with Product Lines.pbit

## Report assumptions/requirements:

1.	Custom fields and entities are entirely out of scope.
2.	Opportunities customers are Accounts
3.	Opportunities are owned by Users
4.	Any accounts (customers) are assigned to a Sales Territory
5.	The “…Opportunities with Product Lines” report additionally assumes: An Opportunity’s estimated or actual values is calculated as the sum of line-items

## Dataverse TDS Endpoint based reports

1.	TDS Endpoint needs to be enabled and you need read access to the following entities: Territories; Accounts; Contacts; Opportunities; Campaigns; System Users; Teams
2.	Edit these four parameters in the report to meet your needs/environment:
    - <img src="https://user-images.githubusercontent.com/6276300/199805803-2dccf5f2-85c9-463b-bb40-faf347958d80.png" width=600 align=center>


## Dataverse Azure Synapse Link for Synapse-based reports

1.	Synapse Link is operating, and you can connect to it with SSMS & Power BI. 
2.	Synapse Link is set to export (using default: append = no) with at least the following tables:
    -	Territories
    -	Accounts
    -	Contacts
    -	Opportunities
    -	Campaigns
    -	System Users
    -	Teams	

    The “…Opportunities with Product Lines” report also needs:
    -	Opportunity Products
    -	Products
3.	Edit these three parameters in the report to meet your needs/environment:
    - <img src="https://user-images.githubusercontent.com/6276300/199808416-2ddf48be-67b5-49f3-889b-0214cd4d4b72.png" width=600 align=center>

