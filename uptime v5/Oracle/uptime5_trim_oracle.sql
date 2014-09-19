CREATE OR REPLACE
PROCEDURE trim_uptime_data IS
	retaindays NUMBER;
	trimdate   DATE;
	trimid     NUMBER;
	rownum     NUMBER;
	samplesnum NUMBER;
	remainder  NUMBER;
	iterations NUMBER;
	i          NUMBER;
	sql_stmt   VARCHAR2(150);
	rindex     BINARY_INTEGER;
	slno       BINARY_INTEGER;
	totalwork  NUMBER;
	obj        BINARY_INTEGER;
	
	CURSOR cur_perftable IS
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'PERFORMANCE_%' AND table_name != 'PERFORMANCE_SAMPLE');
	
	CURSOR cur_edtable IS
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'ERDC_%_DATA');
			
	BEGIN
	
--------------------------------- Client modifiable variables ---------------------------------------------------
		retaindays :=365; -- 1 year retention period.  For last 3 months set to 90 
		rownum := 10000; -- # of rows to delete at a time.  Setting this too high may cause redo logs to get full
-----------------------------------------------------------------------------------------------------------------

		
		
		trimdate := (sysdate-retaindays); -- date to trim up to
		SELECT MAX(id) INTO trimid FROM performance_sample WHERE sample_time < trimdate; -- corresponding id in perf_sample

		rindex := dbms_application_info.set_session_longops_nohint; -- for logging purposes		
		
		IF trimid IS NOT NULL THEN
			-- BEGIN process performance tables
			FOR line IN cur_perftable
			LOOP
				-- log 'calculating iterations'
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
				
				-- Getting number of rows to delete for current performance table (using if block because of limitation to sub line.table_name for px in where clause)
				IF line.table_name = 'PERFORMANCE_AGGREGATE' THEN SELECT count(*) INTO samplesnum FROM performance_aggregate px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_CPU' THEN SELECT count(*) INTO samplesnum FROM performance_cpu px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_DISK' THEN SELECT count(*) INTO samplesnum FROM performance_disk px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_DISK_TOTAL' THEN SELECT count(*) INTO samplesnum FROM performance_disk_total px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_ESX3_WORKLOAD' THEN SELECT count(*) INTO samplesnum FROM performance_esx3_workload px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_FSCAP' THEN SELECT count(*) INTO samplesnum FROM performance_fscap px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_LPAR_WORKLOAD' THEN SELECT count(*) INTO samplesnum FROM performance_lpar_workload px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_NETWORK' THEN SELECT count(*) INTO samplesnum FROM performance_network px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_NRM' THEN SELECT count(*) INTO samplesnum FROM performance_nrm px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_PSINFO' THEN SELECT count(*) INTO samplesnum FROM performance_psinfo px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_VXVOL' THEN SELECT count(*) INTO samplesnum FROM performance_vxvol px WHERE px.sample_id <= trimid;
				ELSIF line.table_name = 'PERFORMANCE_WHO' THEN SELECT count(*) INTO samplesnum FROM performance_who px WHERE px.sample_id <= trimid;
				END IF;
				
				-- set iteration counter to zero
				i := 0;
				
				-- calculate total number of iterations
				remainder := mod(samplesnum, rownum);
				iterations := ((samplesnum - remainder)/rownum) + 1;			
				
				WHILE i < iterations LOOP
					-- log progress to v$session_longops
					dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ' || line.table_name, 'row delete iterations');
					
					-- delete from performance table
					sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE sample_id < ' || trimid || ' AND ROWNUM <= ' || rownum;
					EXECUTE IMMEDIATE sql_stmt;
					COMMIT;
					
					-- increment iteration counter
					i := i + 1;
				END LOOP;
			END LOOP;
			-- END process performance tables
			
			
			-- BEGIN process performance_sample
			-- log 'calculating iterations'
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in PERFORMANCE_SAMPLE', 'rows');
			
			-- Getting number of rows to delete for performance_sample
			SELECT count(*) INTO samplesnum FROM performance_sample WHERE sample_time < trimdate;			
						
			-- set iteration counter to zero
			i := 0;
			
			-- calculate total number of iterations
			remainder := mod(samplesnum, rownum);
			iterations := ((samplesnum - remainder)/rownum) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming performance_sample', 'row delete iterations');
				
				-- delete from performance_sample
				sql_stmt := 'DELETE FROM performance_sample WHERE id < ' || trimid || ' AND ROWNUM <= ' || rownum;
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			-- END process performance_sample
			
			
			-- BEGIN process retained data tables
			FOR line IN cur_edtable
			LOOP
				-- log 'calculating iterations'
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
				
				-- Getting number of rows to delete for current retained data table
				IF line.table_name = 'erdc_decimal_data' THEN SELECT count(*) INTO samplesnum FROM erdc_decimal_data WHERE sampletime < trimdate;
				ELSIF line.table_name = 'erdc_int_data' THEN SELECT count(*) INTO samplesnum FROM erdc_int_data WHERE sampletime < trimdate;
				ELSIF line.table_name = 'erdc_string_data' THEN SELECT count(*) INTO samplesnum FROM erdc_string_data WHERE sampletime < trimdate;
				END IF;
				
				-- set iteration counter to zero
				i := 0;
				
				-- calculate total number of iterations
				remainder := mod(samplesnum, rownum);
				iterations := ((samplesnum - remainder)/rownum) + 1;			
				
				WHILE i < iterations LOOP
					-- log progress to v$session_longops
					dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ' || line.table_name, 'row delete iterations');
					
					-- delete from retained data table
					sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE (sampletime < ''' || trimdate || ''') AND ROWNUM <= ' || rownum;
					EXECUTE IMMEDIATE sql_stmt;
					COMMIT;
					
					-- increment iteration counter
					i := i + 1;
				END LOOP;
			END LOOP;
			-- END process retained data tables
			
			
			-- BEGIN process ranged_object_value
			-- log 'calculating iterations'
			dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in RANGED_OBJECT_VALUE', 'rows');
			
			-- Getting number of rows to delete for ranged_object_value
			SELECT count(*) INTO samplesnum FROM ranged_object_value WHERE sample_time < trimdate;			
			
			-- set iteration counter to zero
			i := 0;
			
			-- calculate total number of iterations
			remainder := mod(samplesnum, rownum);
			iterations := ((samplesnum - remainder)/rownum) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ranged_object_value', 'row delete iterations');
				
				-- delete from ranged_object_value
				sql_stmt := 'DELETE FROM ranged_object_value WHERE (sample_time < ''' || trimdate || ''') AND ROWNUM <= ' || rownum;
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			-- END process ranged_object_value
			
			-- clean up archive_delenda
			EXECUTE IMMEDIATE 'TRUNCATE TABLE archive_delenda';
			COMMIT;
			
			DBMS_OUTPUT.put_line('Finished deleting performance data older than ' || trimdate || '.');
			
		ELSE
			DBMS_OUTPUT.put_line('No performance data found prior to ' || trimdate || ', skipping DELETEs.  Modify retaindays in script.');
		END IF;
	END trim_uptime_data;
/
