exec sp_configure @configname = 'polybase enabled', @configvalue = 1;
RECONFIGURE;

SELECT SERVERPROPERTY ('IsPolyBaseInstalled') AS IsPolyBaseInstalled;