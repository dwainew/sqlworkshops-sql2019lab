-- Scan the table and see if the sensitivity columns were audited
USE WideWorldImporters
GO
SELECT * FROM [Application].[People]
GO

declare  @Path nvarchar(300)
select @Path = left(mf.physical_name, len(mf.physical_name) - charindex('\', reverse(mf.physical_name))) + '\*.sqlaudit'
from sys.master_files mf join sys.databases db on mf.database_id = db.database_id
where db.name = 'WideWorldImporters'
and mf.file_id = 1;
print @path;

-- The audit may now show up EXACTLY right after the query but within a few seconds.
-- Note: Remember for Linux installations, the default path is /var/opt/mssql/data
SELECT event_time, session_id, server_principal_name,
database_name, object_name, 
cast(data_sensitivity_information as XML) as data_sensitivity_information, 
client_ip, application_name
FROM sys.fn_get_audit_file (@Path,default,default)
GO
