/*NOTE:
For this to work correctly, you must connect to the local SQL server with a SQL Login (same account??).
If connected to the local DB with windows authentication, the "CREATE EXTERNAL DATA SOURCE" command will fail with the following error message:

drop DATABASE SCOPED CREDENTIAL AzureSQLDatabaseCredentials

drop EXTERNAL data source AzureSQLDatabaseBUCK

drop EXTERNAL data source AzureSQLWithDatabaseOption

*/
CREATE DATABASE SCOPED CREDENTIAL AzureSQLDatabaseCredentials
WITH IDENTITY = 'polybase_user',
     SECRET = '@XfHp$D3z7@sr5g526*1'
GO

SELECT *
FROM sys.database_scoped_credentials

-- BUCK's version
CREATE EXTERNAL DATA SOURCE AzureSQLDatabaseBUCK
WITH ( 
LOCATION = 'sqlserver://datahatter-vsem.database.windows.net',
PUSHDOWN = ON,
CREDENTIAL = AzureSQLDatabaseCredentials
)

CREATE EXTERNAL DATA SOURCE AzureSQLWithDatabaseOption
WITH (
LOCATION = 'sqlserver://datahatter-vsem.database.windows.net',
Connection_OPTIONS = 'database=wwiazure',
PUSHDOWN = ON,
CREDENTIAL = AzureSQLDatabaseCredentials
)
GO 

-- verify
select * from sys.external_data_sources eds
    join sys.database_scoped_credentials dsc
    on eds.credential_id = dsc.credential_id

CREATE SCHEMA azuresqldb
GO

CREATE EXTERNAL TABLE azuresqldb.ModernStockItemsBUCK
(
	[StockItemID] [int] NOT NULL,
	[StockItemName] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
	[SupplierID] [int] NOT NULL,
	[ColorID] [int] NULL,
	[UnitPackageID] [int] NOT NULL,
	[OuterPackageID] [int] NOT NULL,
	[Brand] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NULL,
	[Size] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
	[LeadTimeDays] [int] NOT NULL,
	[QuantityPerOuter] [int] NOT NULL,
	[IsChillerStock] [bit] NOT NULL,
	[Barcode] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[RecommendedRetailPrice] [decimal](18, 2) NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL,
	[LastEditedBy] [int] NOT NULL
)
 WITH (
 LOCATION='wwiazure.dbo.ModernStockItems',
 DATA_SOURCE=AzureSQLDatabaseBUCK
)
GO

CREATE EXTERNAL TABLE azuresqldb.ModernStockItemsDBOption
(
	[StockItemID] [int] NOT NULL,
	[StockItemName] [nvarchar](100) COLLATE Latin1_General_100_CI_AS NOT NULL,
	[SupplierID] [int] NOT NULL,
	[ColorID] [int] NULL,
	[UnitPackageID] [int] NOT NULL,
	[OuterPackageID] [int] NOT NULL,
	[Brand] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NULL,
	[Size] [nvarchar](20) COLLATE Latin1_General_100_CI_AS NULL,
	[LeadTimeDays] [int] NOT NULL,
	[QuantityPerOuter] [int] NOT NULL,
	[IsChillerStock] [bit] NOT NULL,
	[Barcode] [nvarchar](50) COLLATE Latin1_General_100_CI_AS NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[RecommendedRetailPrice] [decimal](18, 2) NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL,
	[LastEditedBy] [int] NOT NULL
)
 WITH (
 LOCATION='wwiazure.dbo.ModernStockItems',
 DATA_SOURCE=AzureSQLWithDatabaseOption
)

GO

select * from sys.external_tables et 
    join  sys.external_data_sources eds
        on et.data_source_id = eds.data_source_id
    join sys.database_scoped_credentials dsc
        on eds.credential_id = dsc.credential_id

CREATE STATISTICS ModernStockItemsStats ON azuresqldb.ModernStockItemsBUCK ([StockItemID]) WITH FULLSCAN
GO
CREATE STATISTICS ModernStockItemsStats ON azuresqldb.ModernStockItemsDBOption ([StockItemID]) WITH FULLSCAN
GO

select * from  azuresqldb.ModernStockItemsBUCK
select * from  azuresqldb.ModernStockItemsDBOption

SELECT msi.StockItemName, msi.Brand, c.ColorName
FROM azuresqldb.ModernStockItemsBUCK msi
JOIN [Purchasing].[Suppliers] s
ON msi.SupplierID = s.SupplierID
and s.SupplierName = 'Graphic Design Institute'
JOIN [Warehouse].[Colors] c
ON msi.ColorID = c.ColorID
UNION
SELECT si.StockItemName, si.Brand, c.ColorName
FROM [Warehouse].[StockItems] si
JOIN [Purchasing].[Suppliers] s
ON si.SupplierID = s.SupplierID
and s.SupplierName = 'Graphic Design Institute'
JOIN [Warehouse].[Colors] c
ON si.ColorID = c.ColorID
GO