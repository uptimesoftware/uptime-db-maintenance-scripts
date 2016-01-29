/*
	Sept. 3rd, 2014 - Updated  uptime7_trim_mssql.sql,v 3.0 2014/09/3 to  uptime7_trim_mssql_archive.sql to allow different values for each archive policy setting.
	
		This script will delete data from designated tables in the the up.time DataStore.

	You are strongly advised to shut down up.time and make
	a complete backup of your database before running this script.

	The up.time Data Collector / uptime_core service MUST be stopped while this script is running.

	Please see USER CONFIGURABLE PARAMETERS section below for options.

	In particular, you must set @DELETE_DATA = 1 in order to actually delete rows; 
	this is a safety precaution.

	Directions: open this file with one of the following and execute:
		SQL Server Management Studio (SQL Server 2005)
		SQL Server Management Studio (SQL Server 2008)

	Connect using the same DB login that up.time uses.

	The transaction log may fill up during this procedure if sufficient space
	is not available.  Monitor the transaction log size and usage with this command:

	dbcc sqlperf (logspace)

*/


IF OBJECT_ID('tempdb..#SUPPORT_DBCLEANUP') IS NOT NULL
	DROP TABLE #SUPPORT_DBCLEANUP
GO

SET NOCOUNT ON

DECLARE @BATCH_SIZE INT
DECLARE @CUTOFF_DATE_CPUSTATS SMALLDATETIME
DECLARE @CUTOFF_DATE_CPUS SMALLDATETIME
DECLARE @CUTOFF_DATE_PROCESSES SMALLDATETIME
DECLARE @CUTOFF_DATE_DISKS SMALLDATETIME
DECLARE @CUTOFF_DATE_FILESYSTEMS SMALLDATETIME
DECLARE @CUTOFF_DATE_NETWORKS SMALLDATETIME
DECLARE @CUTOFF_DATE_WHO SMALLDATETIME
DECLARE @CUTOFF_DATE_VXVOLS SMALLDATETIME
DECLARE @CUTOFF_DATE_RETAINED SMALLDATETIME
DECLARE @CUTOFF_DATE_VMPERF SMALLDATETIME
DECLARE @CUTOFF_DATE_VMINVENTORY SMALLDATETIME
DECLARE @CUTOFF_DATE_NDPERF SMALLDATETIME
DECLARE @CUTOFF_DATE_S_RETAINED NVARCHAR(60)
DECLARE @CUTOFF_CPUSTATSID VARCHAR(30) 
DECLARE @CUTOFF_CPUSID VARCHAR(30)
DECLARE @CUTOFF_PROCESSESID VARCHAR(30)
DECLARE @CUTOFF_DISKSID VARCHAR(30)
DECLARE @CUTOFF_FILESYSTEMSID VARCHAR(30)
DECLARE @CUTOFF_NETWORKSID VARCHAR(30)
DECLARE @CUTOFF_WHOID VARCHAR(30)
DECLARE @CUTOFF_VXVOLSID VARCHAR(30)
DECLARE @CUTOFF_VMSAMPLEID VARCHAR(30)
DECLARE @CUTOFF_DATE_S_VMSYNC VARCHAR(30)
DECLARE @CUTOFF_NDSAMPLEID VARCHAR(30)
DECLARE @DELETE_DATA BIT
DECLARE @CNT INT
DECLARE @TOT INT
DECLARE @SQL NVARCHAR(900)
DECLARE @FROM_VAL NVARCHAR(60)
DECLARE @WHERE_VAL NVARCHAR(900)

-- ######### USER CONFIGURABLE PARAMETERS ######################## 
-- 0 = SUMMARY ONLY; 1 = DELETE ROWS
SET @DELETE_DATA = 0

-- Set these different date values to be the value for number of days to keep each archive policy setting:
-- Overall CPU/Memory Statistics
SET @CUTOFF_DATE_CPUSTATS = GETUTCDATE()-334
-- Multi-CPU Statistics
SET @CUTOFF_DATE_CPUS = GETUTCDATE()-334
-- Detailed Process Statistics
SET @CUTOFF_DATE_PROCESSES = GETUTCDATE()-30
-- Disk Performance Statistics
SET @CUTOFF_DATE_DISKS = GETUTCDATE()-30
-- File System Capacity Statistics
SET @CUTOFF_DATE_FILESYSTEMS = GETUTCDATE()-30
-- Network Statistics
SET @CUTOFF_DATE_NETWORKS = GETUTCDATE()-30
-- User Information Statistics
SET @CUTOFF_DATE_WHO = GETUTCDATE()-30
-- Volume Manager Statistics
SET @CUTOFF_DATE_VXVOLS = GETUTCDATE()-30
-- Retained Data
SET @CUTOFF_DATE_RETAINED = GETUTCDATE()-30
-- vSphere Performance Data
SET @CUTOFF_DATE_VMPERF = GETUTCDATE()-180
-- vSphere Inventory Updates
SET @CUTOFF_DATE_VMINVENTORY = GETUTCDATE()-90
-- Network Device Performance Data
SET @CUTOFF_DATE_NDPERF = GETUTCDATE()-30


-- Number of rows to delete per transaction
SET @BATCH_SIZE = 10000

-- ######### END USER CONFIGURABLE PARAMETERS #################### 


-- get the sample_id that most closely matches our cut off dates

SELECT @CUTOFF_CPUSTATSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_CPUSTATS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_CPUSTATSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_CPUSTATSID = 0
END

SELECT @CUTOFF_CPUSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_CPUS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_CPUSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_CPUSID = 0
END

SELECT @CUTOFF_PROCESSESID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_PROCESSES
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_PROCESSESID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_PROCESSESID = 0
END

SELECT @CUTOFF_DISKSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_DISKS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_DISKSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_DISKSID = 0
END

SELECT @CUTOFF_FILESYSTEMSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_FILESYSTEMS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_FILESYSTEMSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_FILESYSTEMSID = 0
END

SELECT @CUTOFF_NETWORKSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_NETWORKS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_NETWORKSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_NETWORKSID = 0
END

SELECT @CUTOFF_WHOID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_WHO
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_WHOID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_WHOID = 0
END

SELECT @CUTOFF_VXVOLSID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE_VXVOLS
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_VXVOLSID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_VXVOLSID = 0
END

-- CONVERT THIS DATE TO A STRING WITH QUOTES FOR EFFICIENCY LATER
SET @CUTOFF_DATE_S_RETAINED = '''' + CONVERT(NVARCHAR, @CUTOFF_DATE_RETAINED, 111) + ''''

--Added for v6 vm tables 
SELECT @CUTOFF_VMSAMPLEID = max(sample_id) from vmware_perf_sample WHERE sample_time < @CUTOFF_DATE_VMPERF
-- check if the CUTOFF_DATE is out of range of the available vmware_perf_sample.id's. 
IF ISNULL(@CUTOFF_VMSAMPLEID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_VMSAMPLEID = 0
END

-- CONVERT THIS DATE TO A STRING WITH QUOTES FOR EFFICIENCY LATER
SET @CUTOFF_DATE_S_VMSYNC = '''' + CONVERT(NVARCHAR, @CUTOFF_DATE_VMINVENTORY, 111) + ''''


--added for v7 network tables
SELECT @CUTOFF_NDSAMPLEID = max(id) from net_device_perf_sample WHERE sample_time < @CUTOFF_DATE_NDPERF
-- check if the CUTOFF_DATE is out of range of the available net_device_perf_sample.id's. 
IF ISNULL(@CUTOFF_NDSAMPLEID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_NDSAMPLEID = 0
END

PRINT 'Cutoff date Overall CPU/Memory Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_CPUSTATS, 111)
PRINT 'Cutoff date Multi-CPU Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_CPUS, 111)
PRINT 'Cutoff date Detailed Process Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_PROCESSES, 111)
PRINT 'Cutoff date Disk Performance Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_DISKS, 111)
PRINT 'Cutoff date File System Capacity Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_FILESYSTEMS, 111)
PRINT 'Cutoff date Network Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_NETWORKS, 111)
PRINT 'Cutoff date User Information Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_WHO, 111)
PRINT 'Cutoff date Volume Manager Statistics: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_VXVOLS, 111)
PRINT 'Cutoff date Retained Data: ' + @CUTOFF_DATE_S_RETAINED
PRINT 'Cutoff date vSphere Performance Data: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_VMPERF, 111)
PRINT 'Cutoff date vSphere Inventory Updates: ' + @CUTOFF_DATE_S_VMSYNC
PRINT 'Cutoff date Network Device Performance Data: ' + CONVERT(NVARCHAR, @CUTOFF_DATE_NDPERF, 111)


--PRINT 'Cutoff sample id: ' + @CUTOFF_CPUSTATSID
--PRINT 'Cutoff sample id: ' + @CUTOFF_CPUSID
--PRINT 'Cutoff sample id: ' + @CUTOFF_PROCESSESID
--PRINT 'Cutoff sample id: ' + @CUTOFF_DISKSID
--PRINT 'Cutoff sample id: ' + @CUTOFF_FILESYSTEMSID
--PRINT 'Cutoff sample id: ' + @CUTOFF_NETWORKSID
--PRINT 'Cutoff sample id: ' + @CUTOFF_WHOID
--PRINT 'Cutoff sample id: ' + @CUTOFF_VXVOLSID

--v6 info
--PRINT 'Cutoff sample id: ' + @CUTOFF_VMSAMPLEID
--PRINT 'Cutoff sample id: ' + @CUTOFF_VMINVENTORYID
--v7 info
--PRINT 'Cutoff sample id: ' + @CUTOFF_NDSAMPLEID
PRINT 'Batch size: ' + CONVERT(NVARCHAR, @BATCH_SIZE)

PRINT CONVERT(NVARCHAR, getdate(), 120) + ' starting...' 

CREATE TABLE #SUPPORT_DBCLEANUP (PERFTABLE NVARCHAR(40), CRITERIA NVARCHAR(250), TOTAL_CNT INT, INITIAL_CNT INT, DELETE_CNT INT)

-- REMOVE ANY OF THE FOLLOWING LINES IF DATA DELETION IS NOT DESIRED FROM A PARTICULAR TABLE


-- Overall CPU/Memory Statistics -cpustats
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_AGGREGATE', 'SAMPLE_ID < ' + @CUTOFF_CPUSTATSID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_NRM', 'SAMPLE_ID < ' + @CUTOFF_CPUSTATSID , 0, 0, 0 )

-- Multi-CPU Statistics - cpus
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_CPU', 'SAMPLE_ID < ' + @CUTOFF_CPUSID , 0, 0, 0 )

-- Detailed Process Statistics -processes
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_PSINFO', 'SAMPLE_ID < ' + @CUTOFF_PROCESSESID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_LPAR_WORKLOAD', 'SAMPLE_ID < ' + @CUTOFF_PROCESSESID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_ESX3_WORKLOAD', 'SAMPLE_ID < ' + @CUTOFF_PROCESSESID , 0, 0, 0 )

-- Disk Performance Statistics - disks
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_DISK', 'SAMPLE_ID < ' + @CUTOFF_DISKSID , 0, 0, 0 )

-- Disk Total Performance Statistics - disks
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_DISK_TOTAL', 'SAMPLE_ID < ' + @CUTOFF_DISKSID , 0, 0, 0 )

-- File System Capacity Statistics	 - filesystems
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_FSCAP', 'SAMPLE_ID < ' + @CUTOFF_FILESYSTEMSID , 0, 0, 0 )

-- Network Statistics - networks
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_NETWORK', 'SAMPLE_ID < ' + @CUTOFF_NETWORKSID , 0, 0, 0 )

-- User Information Statistics - who
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_WHO', 'SAMPLE_ID < ' + @CUTOFF_WHOID , 0, 0, 0 )

-- Volume Manager Statistics - vxvols
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_VXVOL', 'SAMPLE_ID < ' + @CUTOFF_VXVOLSID , 0, 0, 0 )

-- Retained Data - retained
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_INT_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S_RETAINED , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_STRING_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S_RETAINED , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_DECIMAL_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S_RETAINED , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('RANGED_OBJECT_VALUE', 'SAMPLE_TIME < ' + @CUTOFF_DATE_S_RETAINED , 0, 0, 0 )

-- vSphere Performance Data - VMPERF
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_aggregate', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_cluster', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_datastore_usage', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_datastore_vm_usage', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_disk_rate', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_entitlement', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_host_cpu', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_host_disk_io', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_host_disk_io_adv', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_host_network', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_host_power_state', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_mem', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_mem_advanced', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_network_rate', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_cpu', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_disk_io', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_network', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_power_state', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_storage_usage', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_vm_vcpu', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_watts', 'SAMPLE_ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0 )

-- vSphere Inventory Updates - vmwareinventoryupdates
INSERT #SUPPORT_DBCLEANUP VALUES ('vsync_update', 'timestamp < ' + @CUTOFF_DATE_S_VMSYNC , 0, 0, 0 )

-- Network Device Performance Data - NDPERF
INSERT #SUPPORT_DBCLEANUP VALUES ('net_device_perf_ping', 'SAMPLE_ID < ' + @CUTOFF_NDSAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('net_device_perf_port', 'SAMPLE_ID < ' + @CUTOFF_NDSAMPLEID , 0, 0, 0 )

-- ENABLE THESE TABLES AT YOUR OWN RISK ##############
-- INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_STATUS_TRANSITION_LOG', 'SAMPLETIME < ' + @CUTOFF_DATE_S_RETAINED , 0, 0, 0 )
-- INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORAMANCE_SAMPLE', 'ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0)
--v6 table
-- INSERT #SUPPORT_DBCLEANUP VALUES ('vmware_perf_sample', 'ID < ' + @CUTOFF_VMSAMPLEID , 0, 0, 0)
--v7 table
-- INSERT #SUPPORT_DBCLEANUP VALUES ('net_device_perf_sample', 'ID < ' + @CUTOFF_NDSAMPLEID , 0, 0, 0)

DECLARE curse CURSOR FOR
SELECT PERFTABLE, CRITERIA FROM #SUPPORT_DBCLEANUP

OPEN curse
FETCH NEXT FROM curse INTO @FROM_VAL, @WHERE_VAL

WHILE (@@FETCH_STATUS = 0)
BEGIN
        -- get the total # of rows in the table
	SET @SQL = 'SELECT @CNT= COUNT(1) FROM ' + @FROM_VAL
	EXEC sp_executesql @SQL, N'@CNT INT OUTPUT', @CNT = @CNT OUTPUT

	SET @SQL = 'UPDATE #SUPPORT_DBCLEANUP SET TOTAL_CNT = ' + CONVERT(NVARCHAR, @CNT) + ' WHERE CURRENT OF curse ' 
	EXEC(@SQL)

        PRINT CONVERT(NVARCHAR, getdate(), 120) + ' ' + @FROM_VAL + ': found ' + CONVERT(NVARCHAR, @CNT) + ' total rows.'

        -- get the # of rows that will be deleted
	SET @SQL = 'SELECT @CNT= COUNT(1) FROM ' + @FROM_VAL + ' WHERE ' + @WHERE_VAL
	EXEC sp_executesql @SQL, N'@CNT INT OUTPUT', @CNT = @CNT OUTPUT

	SET @SQL = 'UPDATE #SUPPORT_DBCLEANUP SET INITIAL_CNT = ' + CONVERT(NVARCHAR, @CNT) + ' WHERE CURRENT OF curse ' 
	EXEC(@SQL)

	IF (@CNT = 0)
	BEGIN
		PRINT CONVERT(NVARCHAR, getdate(), 120) + ' ' + @FROM_VAL + ': no matching rows to delete.'
		FETCH NEXT FROM curse INTO @FROM_VAL, @WHERE_VAL
		CONTINUE
	END

	PRINT CONVERT(NVARCHAR, getdate(), 120) + ' ' + @FROM_VAL + ': will attempt to delete ' + CONVERT(NVARCHAR, @CNT) + ' rows.'

	IF @DELETE_DATA = 1
	BEGIN
		SET @CNT = 0
		SET @TOT = 0

		SET ROWCOUNT @BATCH_SIZE

		WHILE 1=1
		BEGIN
			BEGIN TRAN
			SET @SQL = 'DELETE FROM ' + @FROM_VAL + ' WHERE ' + @WHERE_VAL
			EXEC(@SQL)

			SET @CNT = @@ROWCOUNT
			SET @TOT = @TOT + @CNT

			COMMIT TRAN
			
			IF @CNT < @BATCH_SIZE BREAK
			PRINT CONVERT(NVARCHAR, getdate(), 120) + ' completed ' + CONVERT(nvarchar, @TOT) + ' rows...'
		END --ROW BATCH LOOP

		SET ROWCOUNT 0
		PRINT CONVERT(NVARCHAR, getdate(), 120) + ' ' + @FROM_VAL + ': deleted ' + CONVERT(nvarchar, @TOT) + ' total rows.'
		
		SET @SQL = 'UPDATE #SUPPORT_DBCLEANUP SET DELETE_CNT = ' + CONVERT(NVARCHAR, @TOT) + ' WHERE CURRENT OF curse ' 
		EXEC(@SQL)

	END -- DELETE DATA SECTION
	ELSE
	BEGIN
		PRINT CONVERT(NVARCHAR, getdate(), 120) + ' ' + @FROM_VAL + ': This is a test run, no data was deleted.'
	END

	FETCH NEXT FROM curse INTO @FROM_VAL, @WHERE_VAL
END -- END CURSOR LOOP

CLOSE curse
DEALLOCATE curse

IF @DELETE_DATA = 1
BEGIN
	PRINT ' '
	PRINT '****************** RESULTS *******************' 

	DECLARE curse CURSOR FOR
	SELECT PERFTABLE, INITIAL_CNT, DELETE_CNT FROM #SUPPORT_DBCLEANUP

	DECLARE @INITIAL_VAL INT, @DELETE_VAL INT

	OPEN curse
	FETCH NEXT FROM curse INTO @FROM_VAL, @INITIAL_VAL, @DELETE_VAL

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF (@INITIAL_VAL <> @DELETE_VAL)
		BEGIN
			PRINT 'Potential error attempting to delete ' + CONVERT(NVARCHAR, @INITIAL_VAL) 
			+ ' rows from ' + CONVERT(NVARCHAR, @FROM_VAL) + ' but only ' + CONVERT(NVARCHAR, @DELETE_VAL) + ' were deleted.'
		END
		ELSE
		BEGIN
			PRINT 'Successfully deleted ' + CONVERT(NVARCHAR, @DELETE_VAL) 
			+ ' rows from ' + CONVERT(NVARCHAR, @FROM_VAL) + ' table.'
		END

	FETCH NEXT FROM curse INTO @FROM_VAL, @INITIAL_VAL, @DELETE_VAL
	END

	CLOSE curse
	DEALLOCATE curse

END --DELETE DATA CHECK

DROP TABLE #SUPPORT_DBCLEANUP

PRINT CONVERT(NVARCHAR, getdate(), 120) + ' finished...' 

