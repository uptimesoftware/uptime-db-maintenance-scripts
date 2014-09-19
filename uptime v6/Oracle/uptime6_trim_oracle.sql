CREATE OR REPLACE
PROCEDURE trim_uptime_data IS
	retaindays	NUMBER;
	trimdate	DATE;
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
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'PERFORMANCE_%' AND table_name != 'PERFORMANCE_SAMPLE');
	
	CURSOR cur_edtable IS
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'ERDC_%_DATA');
		
	CURSOR cur_vmperftable IS
		SELECT table_name FROM user_tables WHERE (table_name LIKE 'VMWARE_PERF_%' AND table_name != 'VMWARE_PERF_SAMPLE');
			
	BEGIN
	
	
-- ----------------------------------- Client modifiable variables ---------------------------------------------------
		retaindays :=  365; -- 1 year retention period.  For last 3 months set to 90 
		rownumber := 10000; -- # of rows to delete at a time.  Setting this too high may cause redo logs to get full
-- -------------------------------------------------------------------------------------------------------------------
		
		
		rindex := dbms_application_info.set_session_longops_nohint; -- for logging purposes
		
		trimdate := (sysdate-retaindays); -- date to trim up to
		SELECT MAX(id) INTO trimid FROM performance_sample WHERE sample_time < trimdate; -- corresponding id in perf_sample
		
		IF trimid IS NOT NULL THEN
			-- BEGIN process performance tables
			FOR line IN cur_perftable
			LOOP
				-- log 'calculating iterations'
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
				
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
			remainder := mod(samplesnum, rownumber);
			iterations := ((samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming performance_sample', 'row delete iterations');
				
				-- delete from performance_sample
				sql_stmt := 'DELETE FROM performance_sample WHERE id <= ' || trimid || ' AND ROWNUM <= ' || rownumber;
				-- DBMS_OUTPUT.put_line(sql_stmt);
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			-- END process performance_sample
			DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimdate || '.');			
		ELSE
			DBMS_OUTPUT.put_line('Exiting: No performance data found prior to ' || trimdate || '.');
			DBMS_OUTPUT.put_line('Try reducing the retaindays variable in procedure and running again.');
		END IF;
			
			-- BEGIN process vmware_perf tables
			SELECT MAX(sample_id) INTO trimid FROM vmware_perf_sample WHERE sample_time < trimdate; -- corresponding id in vmware_perf_sample

			IF trimid IS NOT NULL THEN
				FOR line IN cur_vmperftable
				LOOP
					-- log 'calculating iterations'
					dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
					
					-- Getting number of rows to delete for current vmware_perf table
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
						
						-- delete from vmware_perf table
						sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE sample_id <= ' || trimid || ' AND ROWNUM <= ' || rownumber;
						-- DBMS_OUTPUT.put_line(sql_stmt);
						EXECUTE IMMEDIATE sql_stmt;
						COMMIT;
						
						-- increment iteration counter
						i := i + 1;
					END LOOP;
				END LOOP;			
			-- END process vmware_perf tables
	
			-- END process vmware_perf_sample
			
			-- BEGIN process vmware_perf_sample
				-- log 'calculating iterations'
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in VMWARE_PERF_SAMPLE', 'rows');
				
				-- Getting number of rows to delete for vmware_perf_sample
				SELECT count(*) INTO samplesnum FROM vmware_perf_sample WHERE sample_time < trimdate;			
							
				-- set iteration counter to zero
				i := 0;
				
				-- calculate total number of iterations
				remainder := mod(samplesnum, rownumber);
				iterations := ((samplesnum - remainder)/rownumber) + 1;			
				
				WHILE i < iterations LOOP
					-- log progress to v$session_longops
					dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming vmware_perf_sample', 'row delete iterations');
					
					-- delete from vmware_perf_sample
					sql_stmt := 'DELETE FROM vmware_perf_sample WHERE sample_id <= ' || trimid || ' AND ROWNUM <= ' || rownumber;
					-- DBMS_OUTPUT.put_line(sql_stmt);
					EXECUTE IMMEDIATE sql_stmt;
					COMMIT;
					
					-- increment iteration counter
					i := i + 1;
				END LOOP;
					DBMS_OUTPUT.put_line('Finished deleting historical data older than ' || trimdate || '.');			
		ELSE
			DBMS_OUTPUT.put_line('Exiting: No performance data found prior to ' || trimdate || '.');
			DBMS_OUTPUT.put_line('Try reducing the retaindays variable in procedure and running again.');
		END IF;
			-- END process vmware_perf_sample
			
			
			-- BEGIN process retained data tables
			FOR line IN cur_edtable
			LOOP
				-- log 'calculating iterations'
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, 1, 1, 'rows in ' || line.table_name, 'rows');
				
				-- Getting number of rows to delete for current retained data table
				sql_stmt := 'SELECT count(*) FROM ' || line.table_name || ' WHERE sampletime < ''' || trimdate || '''';
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
					sql_stmt := 'DELETE FROM ' || line.table_name || ' WHERE (sampletime < ''' || trimdate || ''') AND ROWNUM <= ' || rownumber;
					-- DBMS_OUTPUT.put_line(sql_stmt);
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
			remainder := mod(samplesnum, rownumber);
			iterations := ((samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations LOOP
				-- log progress to v$session_longops
				dbms_application_info.set_session_longops(rindex, slno, 'up.time Trim', obj, 0, i+1, iterations, 'Trimming ranged_object_value', 'row delete iterations');
				
				-- delete from ranged_object_value
				sql_stmt := 'DELETE FROM ranged_object_value WHERE (sample_time < ''' || trimdate || ''') AND ROWNUM <= ' || rownumber;
				-- DBMS_OUTPUT.put_line(sql_stmt);
				EXECUTE IMMEDIATE sql_stmt;
				COMMIT;
				
				-- increment iteration counter
				i := i + 1;
			END LOOP;
			-- END process ranged_object_value
			
			-- clean up archive_delenda
			EXECUTE IMMEDIATE 'TRUNCATE TABLE archive_delenda';
			COMMIT;
			
	END trim_uptime_data;
/
