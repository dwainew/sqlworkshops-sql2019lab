USE master
GO  
-- Create the server audit.   
-- Note: Remember for Linux installations, the default path is /var/opt/mssql/data
declare @strSQL NVARCHAR(500) = N'CREATE SERVER AUDIT GDPR_Audit TO FILE (FILEPATH = '''
	, @Path nvarchar(300)

select @Path = left(mf.physical_name, len(mf.physical_name) - charindex('\', reverse(mf.physical_name))) 
	,@strSQL = @strSQL + @Path + N''')'
from sys.master_files mf join sys.databases db on mf.database_id = db.database_id
where db.name = 'WideWorldImporters'
and mf.file_id = 1;

print @path;
print @strSQL;

EXEC sp_executesql @strSQL

--CREATE SERVER AUDIT GDPR_Audit
--    TO FILE (FILEPATH = @Path)
GO  
-- Enable the server audit.   
ALTER SERVER AUDIT GDPR_Audit
WITH (STATE = ON)
GO
USE WideWorldImporters
GO  
-- Create the database audit specification.   
CREATE DATABASE AUDIT SPECIFICATION People_Audit
FOR SERVER AUDIT GDPR_Audit
ADD (SELECT ON Application.People BY public )   
WITH (STATE = ON) 
GO
