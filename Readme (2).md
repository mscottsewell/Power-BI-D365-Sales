# Sample Dataverse Sales Report - Three flavors of the same report
* One version connects to the data in the Fabric lakehouse using a Power Query 'native query' (SQL) stored in the report.
* The second version uses views created in the Fabric SQL Endpoint, and has a simple reference to them in the report.
* The third version connects directly to the Dataverse TDS endpoint (no Fabric)

All three reports have the same front-end / visuals / data model - it's just a difference in where the queries are stored.  

The advantage to the first is that it's 100% self-contained with the data in Fabric.
  
The advantage to the 2nd is that the queries (Views) can be shared across multiple reports as a curated source for the team/department/company.

The third version uses the TDS endpoint, so it's simpler, but would be appropriate for a smaller dataset since the TDS endpoint is hitting the operational datastore and is not as well-suited for very fast, high-volume queries as the ones based on Fabric.

It's all a matter of what works well for your scenario.
