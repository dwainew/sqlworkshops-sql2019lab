EXEC master.dbo.sp_addlinkedserver 
      @server = N'AzureSQLDatabase'
     ,@srvproduct = N''
     ,@provider = N'SQLNCLI'
     ,@datasrc = N'datahatter-vsem.database.windows.net'
     ,@catalog = N'wwiazure'
    
   
 EXEC master.dbo.sp_addlinkedsrvlogin 
      @rmtsrvname = N'AzureSQLDatabase'
     ,@useself = N'False'
     ,@locallogin = NULL
     ,@rmtuser = N'polybase_user' /* SQL UserName */
     ,@rmtpassword = '<pwd>'   /* Password */
 GO

select * from sys.servers

select * from  AzureSQLDatabase.wwiazure.[dbo].[ModernStockItems]


