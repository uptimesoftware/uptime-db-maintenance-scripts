/*
	uptime_cleanup_mssql.sql,v 2.0 2010/08/10 

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
DECLARE @CUTOFF_DATE SMALLDATETIME
DECLARE @CUTOFF_DATE_S NVARCHAR(60)
DECLARE @CUTOFF_SAMPLEID VARCHAR(30) 
DECLARE @DELETE_DATA BIT
DECLARE @CNT INT
DECLARE @TOT INT
DECLARE @SQL NVARCHAR(900)
DECLARE @FROM_VAL NVARCHAR(60)
DECLARE @WHERE_VAL NVARCHAR(900)

-- ######### USER CONFIGURABLE PARAMETERS ######################## 
-- 0 = SUMMARY ONLY; 1 = DELETE ROWS
SET @DELETE_DATA = 0

-- Use one of these methods to specifiy the data cutoff date
-- OPTION #1 - today minus X days (180 assumed by default)
SET @CUTOFF_DATE = GETUTCDATE()-180
-- OPTION #2 - static date in YYYY/MM/DD format
-- SET @CUTOFF_DATE = '2009/11/28'

-- Number of rows to delete per transaction
SET @BATCH_SIZE = 10000

-- ######### END USER CONFIGURABLE PARAMETERS #################### 

-- CONVERT THIS DATE TO A STRING WITH QUOTES FOR EFFICIENCY LATER
SET @CUTOFF_DATE_S = '''' + CONVERT(NVARCHAR, @CUTOFF_DATE, 111) + ''''

-- get the sample_id that most closely matches our cut off date

SELECT @CUTOFF_SAMPLEID = max(id) from performance_sample WHERE sample_time < @CUTOFF_DATE
-- check if the CUTOFF_DATE is out of range of the available performance_sample.id's. 
IF ISNULL(@CUTOFF_SAMPLEID,0) = 0
BEGIN
	PRINT 'Selected CUTOFF_DATE is older than the available data'
	SET @CUTOFF_SAMPLEID = 0
END

PRINT 'Cutoff date: ' + @CUTOFF_DATE_S
PRINT 'Cutoff sample id: ' + @CUTOFF_SAMPLEID
PRINT 'Batch size: ' + CONVERT(NVARCHAR, @BATCH_SIZE)

PRINT CONVERT(NVARCHAR, getdate(), 120) + ' starting...' 

CREATE TABLE #SUPPORT_DBCLEANUP (PERFTABLE NVARCHAR(40), CRITERIA NVARCHAR(250), TOTAL_CNT INT, INITIAL_CNT INT, DELETE_CNT INT)

-- REMOVE ANY OF THE FOLLOWING LINES IF DATA DELETION IS NOT DESIRED FROM A PARTICULAR TABLE



INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_AGGREGATE', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_CPU', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_DISK', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_ESX3_WORKLOAD', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_FSCAP', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_LPAR_WORKLOAD', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_NETWORK', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_NRM', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_PSINFO', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_VXVOL', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORMANCE_WHO', 'SAMPLE_ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_INT_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_STRING_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_DECIMAL_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_INT_DATA', 'SAMPLETIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )
INSERT #SUPPORT_DBCLEANUP VALUES ('RANGED_OBJECT_VALUE', 'SAMPLE_TIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )

-- ENABLE THESE TABLES AT YOUR OWN RISK ##############
-- INSERT #SUPPORT_DBCLEANUP VALUES ('ERDC_STATUS_TRANSITION_LOG', 'SAMPLETIME < ' + @CUTOFF_DATE_S , 0, 0, 0 )
-- INSERT #SUPPORT_DBCLEANUP VALUES ('PERFORAMANCE_SAMPLE', 'ID < ' + @CUTOFF_SAMPLEID , 0, 0, 0)

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

