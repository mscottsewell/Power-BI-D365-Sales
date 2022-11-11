# Power BI ❤️ Dynamics 365 Sales! <br /> Report Templates (Beta)

These report templates are built to demonstrate using Power BI to report on Opportunities in Dynamics 365 CE Sales. 

These templates are intended to be idea generators and examples of Power BI features that you can 'steal' to make your own reports shine. Few organizations will find them complete enough to use without some modification/expansion.

The data model of the report follows best-practices from my documentation: [Power BI modeling guidance for Power Platform.](https://learn.microsoft.com/en-us/power-bi/guidance/powerbi-modeling-guidance-for-power-platform) 

## Quick Demo
![Sales Report](https://user-images.githubusercontent.com/6276300/199860167-026229c5-8a73-4cad-907c-763dfc49eeef.gif)
*Note: if you're testing this in the desktop, remember to hold down the <ctrl> key when clicking on bookmarks, but not slicers. - Once published to the service, both bookmarks and slicers work with a single click.*

## Software:

1.	Access to a Dynamics 365 environment with sales data (See below for entities in scope)
2.	Current version of Power BI on your Desktop for editing (With "Field Parameters" enabled in Options/Preview.)<br />Note that if you see an alert telling you that the report can't be opened because it's is in a newer version, as long as you're on the latest released version you can continue opening the report, there should be no incompatible/unreleased features in this report.<br /><img width="200" alt="Newer Version Error" src="https://user-images.githubusercontent.com/6276300/200124170-738a60eb-5922-4f27-aeb3-8d33d1935d18.png">
3.  If you'd like to share the reports with others, some version of Power BI Pro/Premium-per-user/Premium would be needed.
4.	Optional: [Bravo - for updating the calendar or modifying/adding time intelligence measures](https://bravo.bi/)
5.	Optional: [SSMS - SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms-19?view=sql-server-ver16)

## Skills

1.	T-SQL – (Nothing deeper than Select/Join/Case/IsNull is needed)
2.	Power Query / Basic DAX / Power BI Data Modeling / Power BI Report development 
3.  Familiarity with Dataverse / Dynamics 365 sales entities

# Report assumptions/requirements:

1.	Custom fields and entities are entirely out of scope for the template, but nothing blocking a user from add custom fields to the existing queries/reports
2.	Opportunities owners (either users or ownership teams) have a manager for roll-up reporting
3.	Opportunity customers (specifically accounts) are assigned a Sales Territory for roll-up reporting
4.  Territories may have a parent territory for grouping / roll-up
5.	The DatesTimes are adjusted from GMT based on a single parameter (number of Hours) - e.g. Central timezone in the US is GMT "-6" hours (Or -5 hours during Daylight Savings Time.) The datetimes in Dataverse are stored in GMT timezone but displayed in a user's local time based on their user settings, so this adjustment is needed to help offset date drift due to user's timezone delta from GMT. 
6.	The “Contoso Sales - Synapse - Opportunities with Product Lines” report additionally assumes: An Opportunity’s estimated and actual values are only calculated as the sum of line-items
7.  All ***Open*** opportunities will be imported, but only opportunities that have ***closed*** within the past 'X' number of months will be imported. Selecting a smaller number of months of history will avoid longer refresh cycles or timeouts, especially with large datasets using TDS. - *(It's helpful to include 1 more month than you plan to display. This gives the month-over-month calculations a baseline for the first month you display.)*   
8.  The report will initially ask for authentication and then ask you to approve running native database queryies. - Click 'Run' to approve running each of these read-only queryies.<br /><img src="https://user-images.githubusercontent.com/6276300/201372146-d3857d0a-2987-42da-b2e6-4bb7e46dc5c8.png" width=400 align=center>
    

# Report Variations:

### Dataverse TDS Endpoint based report
Try out the ***Dataverse TDS Endpoint*** version of the report for the easiest setup.
- Contoso Sales - TDS - Opportunities.pbit

*Requirements*
1.	TDS Endpoint needs to be enabled and you need read access to the following entities:<br /> *Territories; Accounts; Contacts; Opportunities; Campaigns; System Users; Teams* 
2.	Edit these three parameters in the report to meet your needs/environment<br /><img src="https://user-images.githubusercontent.com/6276300/201371158-64dbd1ca-6783-46cc-b573-8c8876e0cab5.png" width=400 align=center>
    - *GMTOffset* - set this to the difference (in hours) from GMT for the report datetime adjustments. 
    - *TDSEndPoint* - The server url/name for the Dynamics 365 environment. *(without the https:// prefix) *
    - *MonthsOfHistory* - Number of months of closed opportunites to import.

### Dataverse Azure Synapse Link for Synapse-based reports
If you have an ***Azure Synapse Link*** deployed, use these versions to report on much larger datasets. 
- Contoso Sales - Synapse - Opportunities.pbit
- Contoso Sales - Synapse - Opportunities with Product Lines.pbit

*Requirements*
1.	[Azure Synapse Link](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/export-to-data-lake) is operating, and you can connect to it with SSMS & Power BI. 
2.	Synapse Link is set to export (using default: append = no) with at least the following tables[^note]:<br /> *Territories; Accounts; Contacts; Opportunities; Campaigns; System Users;Teams*  <br />
The “…Opportunities with Product Lines” report also needs: *Opportunity Products* and *Products*
3.	Edit these four parameters in the report to meet your needs/environment:<br /><img src="https://user-images.githubusercontent.com/6276300/200717333-6b8329cc-c7cf-4392-8d00-2269d0a0a77f.png" width=400 align=center>
    - *GMTOffset* - set this to the difference (in hours) from GMT for the report datetime adjustments. 
    - *SynapseSQLEndPoint* - The server url/name for the Synapse Workspace SQL endpoint. Open the workspace and click on ***Manage*** - Under SQL Pools, click on ***Built-in*** to open the properties - copy the ***Workspace SQL endpoint*** to the _SynapseSQLEndPoint_ variable. 
    - *SynapseLakeDatabase* - This is the lake database name in the Synapse Workspace. Open the make.PowerApps.com Portal and under ***Dataverse / Azure Synapse Link*** highlight the listed Synapse Link, then from the ribbon choose ***Details* to open the Azure resource details page. - Copy the ***Azure Synapse Analytics database*** name (Note: you only want the text displayed, and *not* the underlying url.)
    - *MonthsOfHistory* - Number of months of closed opportunites to import.

[^note]: To ensure the report doesn't encounter read-contention during refresh cycles, it queries the '_snapshot' version of the tables. Be aware that these tables/views are not created in Synapse if the corresponding table in Dataverse is completely empty. Ensure at least one record is in the source tables for each of the selected entities to trigger the sync to setup these snapshot views.  <br />
