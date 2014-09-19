CREATE OR REPLACE PROCEDURE "TRIM_UPTIME_DATA" IS
-- --------------------------------------Details for this Script------------------------------------------------------
-- The way this script works is for all the normal tables we archive it looks at the archive policy table to find 
-- out how many months it is supposed to keep then it subtracts that many months off current date and deletes the rows. 
-- 
-- The way it handles the 3 sample tables is to find the highest number of months for the tables under it and then 
-- use that value. So that way you shouldn’t have any issues with trimming those tables either as always will keep 
-- as much data as whichever table has the longest retention policy.
-- 
-- The difference between this and the built in archiving is this archives exactly the number of months from today 
-- rather than the first of the month and this currently doesn’t do the following as none of our trim scripts do them:
-- Vsync_update in the “vSphere performance data” and both tables in “vSphere inventory updates” 
-- (virtual_inventory_update, vmware_event)
-- Also we trim performance sample tables that archiving doesn't do. 
-- 
-- Can you use this query to look at where this is as it should log its progress to the longops table.
-- select TO_CHAR( start_time, 'MM/DD/YYYY HH24:MI:SS' ) start_ti, target_desc, sofar, totalwork 
-- from v$session_longops WHERE opname='up.time Trim'; 
--
-- Steps to run this script: 
-- 1. Run this sql file so it will create the procedure. 
-- 2. Verify the archive policy settings are correct in GUI (Config > Archive Policy > Verify months values are 
-- correct and that "Enable Archiving" is unchecked. 
-- 3. Then call the procedure "TRIM_UPTIME_DATA" to have it actually run and delete the data.
-- -------------------------------------------------------------------------------------------------------------------
	trimOverallCPUdate	DATE;
	trimMultiCPUdate	DATE;
	trimProcessdate	DATE;
	trimDiskdate	DATE;
	trimFSdate	DATE;
	trimNetworkdate	DATE;
	trimUserdate	DATE;
	trimVolumedate	DATE;
	trimRetaineddate	DATE;
	trimVPerfdate	DATE;
	trimNDPerfdate	DATE;
	trimPSdate	DATE;
	trimVMSdate	DATE;
	trimNDSdate	DATE;
	trimOverallCPUid		NUMBER;
	trimMultiCPUid		NUMBER;
	trimProcessid		NUMBER;
	trimDiskid		NUMBER;
	trimFSid		NUMBER;
	trimNetworkid		NUMBER;
	trimUserid		NUMBER;
	trimVolumeid		NUMBER;
	trimRetainedid		NUMBER;
	trimVPerfid		NUMBER;
	trimNDPerfid		NUMBER;
	trimPSid		NUMBER;
	trimVMSid		NUMBER;
	trimNDSid		NUMBER;
	trimid		NUMBER;
	rownumber	NUMBER;
	samplesnum	NUMBER;
	remainder	NUMBER;
	iterations	NUMBER;
	i			NUMBER;
	sql_stmt	VARCHAR2(150);
	rindex		BINARY_INTEGER;
	slno		BINARY_INTEGER;
	totalwork	NUMBER;
	obj			BINARY_INTEGER;
	
	CURSOR cur_perftable IS
		SELECT * FROM user_tables WHERE (table_name LIKE 'PERFORMANCE_%' AND table_name != 'PERFORMANCE_SAMPLE') or (table_name LIKE 'VMWARE_PERF_%' AND table_name != 'VMWARE_PERF_SAMPLE') or (table_name = 'NET_DEVICE_PERF_PING' OR table_name = 'NET_DEVICE_PERF_PORT');
		
	CURSOR cur_edtable IS
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'ERDC_%_DATA');
	BEGIN
	
	
-- ----------------------------------- Client modifiable variables ---------------------------------------------------
		rownumber := 10000; -- # of rows to delete at a time.  Setting this too high may cause redo logs to get full
-- -------------------------------------------------------------------------------------------------------------------
		
		
		rindex := dbms_application_info.set_session_longops_nohint; -- for logging purposes
		
		select add_months(sysdate,-ap.MONTHS) into trimOverallCPUdate from archive_policy ap where ap.TYPE = 'cpustats'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimMultiCPUdate from archive_policy ap where ap.TYPE = 'cpus'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimProcessdate from archive_policy ap where ap.TYPE = 'processes'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimDiskdate from archive_policy ap where ap.TYPE = 'disks'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimFSdate from archive_policy ap where ap.TYPE = 'filesystems'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimNetworkdate from archive_policy ap where ap.TYPE = 'networks'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimUserdate from archive_policy ap where ap.TYPE = 'who'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimVolumedate from archive_policy ap where ap.TYPE = 'vxvols'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimRetaineddate from archive_policy ap where ap.TYPE = 'retained'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimVPerfdate from archive_policy ap where ap.TYPE = 'vmwarePerformance'; -- date to trim up to
		select add_months(sysdate,-ap.MONTHS) into trimNDPerfdate from archive_policy ap where ap.TYPE = 'networkDevicePerformance'; -- date to trim up to
		select add_months(sysdate,-max(ap.MONTHS)) into trimPSdate from archive_policy ap where ap.TYPE in ('cpus', 'cpustats', 'cpus', 'processes', 'disks', 'filesystems', 'networks', 'who', 'vxvols', 'retained'); -- date to trim up to
		select add_months(sysdate,-max(ap.MONTHS)) into trimVMSdate from archive_policy ap where ap.TYPE in ('vmwarePerformance', 'vmwareInventoryUpdates'); -- date to trim up to
		select add_months(sysdate,-max(ap.MONTHS)) into trimNDSdate from archive_policy ap where ap.TYPE in ('networkDevicePerformance'); -- date to trim up to
		SELECT MAX(id) INTO trimOverallCPUid FROM performance_sample WHERE sample_time < trimOverallCPUdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimMultiCPUid FROM performance_sample WHERE sample_time < trimMultiCPUdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimProcessid FROM performance_sample WHERE sample_time < trimProcessdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimDiskid FROM performance_sample WHERE sample_time < trimDiskdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimFSid FROM performance_sample WHERE sample_time < trimFSdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimNetworkid FROM performance_sample WHERE sample_time < trimNetworkdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimUserid FROM performance_sample WHERE sample_time < trimUserdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimVolumeid FROM performance_sample WHERE sample_time < trimVolumedate; -- corresponding id in perf_sample	
		SELECT MAX(sample_id) INTO trimVPerfid FROM VMWARE_PERF_SAMPLE WHERE sample_time < trimVPerfdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimNDPerfid FROM NET_DEVICE_PERF_SAMPLE WHERE sample_time < trimNDPerfdate; -- corresponding id in perf_sample	
		
		SELECT MAX(id) INTO trimPSid FROM performance_sample WHERE sample_time < trimPSdate; -- corresponding id in perf_sample	
		SELECT MAX(sample_id) INTO trimVMSid FROM VMWARE_PERF_SAMPLE WHERE sample_time < trimVMSdate; -- corresponding id in perf_sample	
		SELECT MAX(id) INTO trimNDSid FROM NET_DEVICE_PERF_SAMPLE WHERE sample_time < trimNDSdate; -- corresponding id in perf_sample	
		
		
		-- BEGIN process performance tables
		FOR line IN cur_perftable
		LOOP
			-- log 'calculating iterations'
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
			
			if lower(line.table_name) = 'performance_cpu' THEN
				trimid := trimMultiCPUid;
			elsif lower(line.table_name) = 'performance_aggregate' or lower(line.table_name) = 'performance_nrm' THEN
				trimid := trimOverallCPUid;
			elsif lower(line.table_name) = 'performance_psinfo' or lower(line.table_name) = 'performance_lpar_workload' or lower(line.table_name) = 'performance_esx3_workload' THEN
				trimid := trimProcessid;
			elsif lower(line.table_name) = 'performance_disk' or lower(line.table_name) = 'performance_disk_total' THEN
				trimid := trimDiskid;
			elsif lower(line.table_name) = 'performance_fscap' THEN
				trimid := trimFSid;
			elsif lower(line.table_name) = 'performance_network' THEN
				trimid := trimNetworkid;
			elsif lower(line.table_name) = 'performance_who' THEN
				trimid := trimUserid;
			elsif lower(line.table_name) = 'performance_vxvol' THEN
				trimid := trimVolumeid;
			elsif lower(line.table_name) like 'vmware_perf%' THEN
				trimid := trimVPerfid;
			elsif lower(line.table_name) like 'net_device_perf%' THEN
				trimid := trimNDPerfid;
			else 
				trimid := 0;
			end if;
			
			IF trimid IS NULL THEN
				trimid := 0;
			end if;
		
			-- Getting number of rows to delete for current performance table
			sql_stmt := 'SELECT count(*) FROM ' || line.table_name || ' WHERE sample_id <= ' || trimid;
			EXECUTE IMMEDIATE sql_stmt INTO samplesnum;
			
			-- set iteration counter to zero
			i := 0;
			
			-- calculate total number of iterations
			remainder := mod(samplesnum, rownumber);
			iterations := ((samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ' || line.table_name, 'row delete iterations');
				
				-- delete from performance table
				sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE sample_id <= ' || trimid || ' AND ROWNUM <= ' || rownumber;
				-- DBMS_OUTPUT.put_line(sql_stmt);
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			DBMS_OUTPUT.put_line('Finished deleting historical data in '|| line.table_name ||' with id less then ' || trimid || '.');
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data in performance tables.');
		-- END process performance tables
		
		
		-- BEGIN process performance_sample
		-- log 'calculating iterations'
		dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in PERFORMANCE_SAMPLE', 'rows');
		
		-- Getting number of rows to delete for performance_sample
		SELECT count(*) INTO samplesnum FROM performance_sample WHERE sample_time < trimPSdate;			
					
		-- set iteration counter to zero
		i := 0;
		
		IF trimPSid IS NULL THEN
			trimPSid := 0;
		end if;
		
		-- calculate total number of iterations
		remainder := mod(samplesnum, rownumber);
		iterations := ((samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations LOOP
			-- log progress to v$session_longops
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming performance_sample', 'row delete iterations');
			
			-- delete from performance_sample
			sql_stmt := 'DELETE FROM performance_sample WHERE id <= ' || trimPSid || ' AND ROWNUM <= ' || rownumber;
			-- DBMS_OUTPUT.put_line(sql_stmt);
			EXECUTE IMMEDIATE sql_stmt;
			COMMIT;
			
			-- increment iteration counter
			i := i + 1;
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimPSdate || ' in performance_sample.');
		-- END process performance_sample
				
		-- BEGIN process vmware_perf_sample
		-- log 'calculating iterations'
		dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in VMWARE_PERF_SAMPLE', 'rows');
		
		-- Getting number of rows to delete for vmware_perf_sample
		SELECT count(*) INTO samplesnum FROM vmware_perf_sample WHERE sample_time < trimVMSdate;			
					
		-- set iteration counter to zero
		i := 0;
		
		IF trimVMSid IS NULL THEN
			trimVMSid := 0;
		end if;
		
		-- calculate total number of iterations
		remainder := mod(samplesnum, rownumber);
		iterations := ((samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations LOOP
			-- log progress to v$session_longops
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming vmware_perf_sample', 'row delete iterations');
			
			-- delete from vmware_perf_sample
			sql_stmt := 'DELETE FROM vmware_perf_sample WHERE sample_id <= ' || trimVMSid || ' AND ROWNUM <= ' || rownumber;
			-- DBMS_OUTPUT.put_line(sql_stmt);
			EXECUTE IMMEDIATE sql_stmt;
			COMMIT;
			
			-- increment iteration counter
			i := i + 1;
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimVMSdate || ' in vmware_perf_sample.');
		
		-- BEGIN process net_device_perf_sample
		-- log 'calculating iterations'
		dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in NET_DEVICE_PERF_SAMPLE', 'rows');
		
		-- Getting number of rows to delete for net_device_perf_sample
		SELECT count(*) INTO samplesnum FROM net_device_perf_sample WHERE sample_time < trimNDSdate;			
					
		-- set iteration counter to zero
		i := 0;
		
		IF trimNDSid IS NULL THEN
			trimNDSid := 0;
		end if;
		
		-- calculate total number of iterations
		remainder := mod(samplesnum, rownumber);
		iterations := ((samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations LOOP
			-- log progress to v$session_longops
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming net_device_perf_sample', 'row delete iterations');
			
			-- delete from net_device_perf_sample
			sql_stmt := 'DELETE FROM net_device_perf_sample WHERE id <= ' || trimNDSid || ' AND ROWNUM <= ' || rownumber;
			-- DBMS_OUTPUT.put_line(sql_stmt);
			EXECUTE IMMEDIATE sql_stmt;
			COMMIT;
			
			-- increment iteration counter
			i := i + 1;
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimNDSdate || ' in net_device_perf_sample.');
				
				
		-- BEGIN process retained data tables
		FOR line IN cur_edtable
		LOOP
			-- log 'calculating iterations'
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
			
			-- Getting number of rows to delete for current retained data table
			sql_stmt := 'SELECT count(*) FROM ' || line.table_name || ' WHERE sampletime < ''' || trimRetaineddate || '''';
			EXECUTE IMMEDIATE sql_stmt INTO samplesnum;
			
			-- set iteration counter to zero
			i := 0;
			
			-- calculate total number of iterations
			remainder := mod(samplesnum, rownumber);
			iterations := ((samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ' || line.table_name, 'row delete iterations');
				
				-- delete from retained data table
				sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE (sampletime < ''' || trimRetaineddate || ''') AND ROWNUM <= ' || rownumber;
				-- DBMS_OUTPUT.put_line(sql_stmt);
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			DBMS_OUTPUT.put_line('Finished deleting historical data in '|| line.table_name ||' with id less then ' || trimid || '.');
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimRetaineddate || ' in retained data tables.');
		-- END process retained data tables
		
		
		-- BEGIN process ranged_object_value
		-- log 'calculating iterations'
		dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in RANGED_OBJECT_VALUE', 'rows');
		
		-- Getting number of rows to delete for ranged_object_value
		SELECT count(*) INTO samplesnum FROM ranged_object_value WHERE sample_time < trimRetaineddate;			
		
		-- set iteration counter to zero
		i := 0;
		
		-- calculate total number of iterations
		remainder := mod(samplesnum, rownumber);
		iterations := ((samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations LOOP
			-- log progress to v$session_longops
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ranged_object_value', 'row delete iterations');
			
			-- delete from ranged_object_value
			sql_stmt := 'DELETE FROM ranged_object_value WHERE (sample_time < ''' || trimRetaineddate || ''') AND ROWNUM <= ' || rownumber;
			-- DBMS_OUTPUT.put_line(sql_stmt);
			EXECUTE IMMEDIATE sql_stmt;
			COMMIT;
			
			-- increment iteration counter
			i := i + 1;
		END LOOP;
		DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimRetaineddate || ' in ranged data table.');
		-- END process ranged_object_value
		
		-- clean up archive_delenda
		EXECUTE IMMEDIATE 'TRUNCATE TABLE archive_delenda';
		COMMIT;
		
	END trim_uptime_data;
/
