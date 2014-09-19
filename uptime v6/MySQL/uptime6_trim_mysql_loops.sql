DROP PROCEDURE IF EXISTS trim_uptime_data;

DELIMITER //

CREATE PROCEDURE trim_uptime_data()
BEGIN
	DECLARE retaindays		INT; -- could also use MEDIUMINT UNSIGNED
	DECLARE trimdate		DATE;
	DECLARE trimid			INT;
	DECLARE rownumber		INT;
	DECLARE remainder		INT;
	DECLARE iterations		INT;
	DECLARE i				INT;
	DECLARE cur_table_name	VARCHAR(255);
	DECLARE done			INT DEFAULT FALSE;
	
	DECLARE cur_perftable   CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema='uptime' AND table_name LIKE 'performance_%' AND table_name != 'performance_sample';
	DECLARE cur_edtable     CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema='uptime' AND table_name LIKE 'erdc_%_data';
	DECLARE cur_vmperftable CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema='uptime' AND table_name LIKE 'vmware_perf_%' AND table_name != 'vmware_perf_sample';
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur_perftable;
	OPEN cur_edtable;
	OPEN cur_vmperftable;
	
	
-- ------------------------------ Client modifiable variables ---------------------------------------------------------
	SET retaindays =   365; -- 1 year retention period.  For last 3 months, set to 90 
	SET rownumber  = 10000; -- # of rows to delete at a time.  Setting this too high may cause prohibitive table locks
-- --------------------------------------------------------------------------------------------------------------------


	SET trimdate = DATE_SUB(CURDATE(), INTERVAL retaindays DAY); -- date to trim up to
	SELECT MAX(id) INTO trimid FROM performance_sample WHERE sample_time < trimdate; -- corresponding id in perf_sample
		
	IF trimid IS NOT NULL THEN
	
		-- BEGIN process performance tables					
		loop_cur_perftable: LOOP
			FETCH cur_perftable INTO cur_table_name;
			
			IF done THEN
				LEAVE loop_cur_perftable;
			END IF;
			
			-- skip if table is performance_sample
			-- IF cur_table_name = 'performance_sample' THEN 
			-- 	ITERATE loop_cur_perftable; 
			-- END IF;

			-- Getting number of rows to delete for current performance table
			SET @count_text = CONCAT('SELECT count(*) INTO @samplesnum FROM ', cur_table_name, ' WHERE sample_id <= ', trimid);
			PREPARE count_stmt FROM @count_text;
			EXECUTE count_stmt;
			DEALLOCATE PREPARE count_stmt;
			
			-- set iteration counter to zero
			SET i = 0;
			
			-- calculate total number of iterations
			SET remainder = MOD(@samplesnum, rownumber);
			SET iterations = ((@samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations DO
				-- log progress to STDOUT
				SELECT CONCAT('Trimming data in ', cur_table_name, ' older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';
									
				-- delete from performance table
				SET @delete_text = CONCAT('DELETE FROM ', cur_table_name, ' WHERE sample_id <= ', trimid, ' LIMIT ', rownumber);
				PREPARE delete_stmt FROM @delete_text;
				EXECUTE delete_stmt;
				DEALLOCATE PREPARE delete_stmt;				
				
				-- increment iteration counter
				SET i = i + 1;
			END WHILE;
		END LOOP loop_cur_perftable;
		-- END process performance tables
			
			
		-- BEGIN process performance_sample
		-- Getting number of rows to delete for performance_sample
		SELECT count(*) INTO @samplesnum FROM performance_sample WHERE sample_time < trimdate;			
					
		-- set iteration counter to zero
		SET i = 0;
		
		-- calculate total number of iterations
		SET remainder = MOD(@samplesnum, rownumber);
		SET iterations = ((@samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations DO
			-- log progress to STDOUT
			SELECT CONCAT('Trimming data in performance_sample older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';
			
			-- delete from performance_sample
			SET @delete_text = CONCAT('DELETE FROM performance_sample WHERE id <= ', trimid, ' LIMIT ', rownumber);
			PREPARE delete_stmt FROM @delete_text;
			EXECUTE delete_stmt;
			DEALLOCATE PREPARE delete_stmt;				
			
			-- increment iteration counter
			SET i = i + 1;
		END WHILE;
		-- END process performance_sample
				
		SELECT CONCAT('Finished deleting historical data older than ', trimdate, '.') AS 'Complete';		
	ELSE
		SELECT CONCAT('Exiting: No performance data found prior to ', trimdate, '.  Try reducing retaindays variable in procedure and running again.') AS 'Complete';
	END IF;
	
	
	SET trimdate = DATE_SUB(CURDATE(), INTERVAL retaindays DAY); -- date to trim up to
	SELECT MAX(sample_id) INTO trimid FROM vmware_perf_sample WHERE sample_time < trimdate; -- corresponding id in perf_sample
		
	IF trimid IS NOT NULL THEN
		
			
		-- BEGIN process vmware_perf tables
		
		SET done = FALSE;
			
		loop_cur_vmperftable: LOOP
			FETCH cur_vmperftable INTO cur_table_name;
			
			IF done THEN
				LEAVE loop_cur_vmperftable;
			END IF;
			
			-- skip if table is vmware_performance_sample
			-- IF cur_table_name = 'vmware_perf_sample' THEN 
			-- 	ITERATE loop_cur_vmperftable; 
			-- END IF;

			-- Getting number of rows to delete for current vmware performance table
			SET @count_text = CONCAT('SELECT count(*) INTO @samplesnum FROM ', cur_table_name, ' WHERE sample_id <= ', trimid);
			PREPARE count_stmt FROM @count_text;
			EXECUTE count_stmt;
			DEALLOCATE PREPARE count_stmt;	
			
			-- set iteration counter to zero
			SET i = 0;
			
			-- calculate total number of iterations
			SET remainder = MOD(@samplesnum, rownumber);
			SET iterations = ((@samplesnum - remainder)/rownumber) + 1;			
			
			WHILE i < iterations DO
				-- log progress to STDOUT
				SELECT CONCAT('Trimming data in ', cur_table_name, ' older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';
									
				-- delete from performance table
				SET @delete_text = CONCAT('DELETE FROM ', cur_table_name, ' WHERE sample_id <= ', trimid, ' LIMIT ', rownumber);
				PREPARE delete_stmt FROM @delete_text;
				EXECUTE delete_stmt;
				DEALLOCATE PREPARE delete_stmt;				
				
				-- increment iteration counter
				SET i = i + 1;
			END WHILE;
		END LOOP loop_cur_vmperftable;
		-- END process vmware_perf tables
	
		-- BEGIN process vmware_perf_sample
		-- Getting number of rows to delete for vmware_perf_sample
		SELECT count(*) INTO @samplesnum FROM vmware_perf_sample WHERE sample_time < trimdate;			
					
		-- set iteration counter to zero
		SET i = 0;
		
		-- calculate total number of iterations
		SET remainder = MOD(@samplesnum, rownumber);
		SET iterations = ((@samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations DO
			-- log progress to STDOUT
			SELECT CONCAT('Trimming data in vmware_perf_sample older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';
			
			-- delete from performance_sample
			SET @delete_text = CONCAT('DELETE FROM vmware_perf_sample WHERE sample_id <= ', trimid, ' LIMIT ', rownumber);
			PREPARE delete_stmt FROM @delete_text;
			EXECUTE delete_stmt;
			DEALLOCATE PREPARE delete_stmt;				
			
			-- increment iteration counter
			SET i = i + 1;
		END WHILE;
		-- END process vmware_perf_sample
			
		SELECT CONCAT('Finished deleting historical data older than ', trimdate, '.') AS 'Complete';		
	ELSE
		SELECT CONCAT('Exiting: No performance data found prior to ', trimdate, '.  Try reducing retaindays variable in procedure and running again.') AS 'Complete';
	END IF;
	
	
			
	-- BEGIN process retained data tables
	SET done = FALSE;

	loop_cur_edtable: LOOP
		FETCH cur_edtable INTO cur_table_name;
		
		IF done THEN
			LEAVE loop_cur_edtable;
		END IF;

		-- Getting number of rows to delete for current vmware performance table
		SET @count_text = CONCAT('SELECT count(*) INTO @samplesnum FROM ', cur_table_name, ' WHERE sampletime < ', trimdate);
		PREPARE count_stmt FROM @count_text;
		EXECUTE count_stmt;
		DEALLOCATE PREPARE count_stmt;
			
		-- set iteration counter to zero
		SET i = 0;
		
		-- calculate total number of iterations
		SET remainder = MOD(@samplesnum, rownumber);
		SET iterations = ((@samplesnum - remainder)/rownumber) + 1;			
		
		WHILE i < iterations DO
			-- log progress to STDOUT
			SELECT CONCAT('Trimming data in ', cur_table_name, ' older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';
								
			-- delete from performance table
			SET @delete_text = CONCAT('DELETE FROM ', cur_table_name, ' WHERE sampletime < ', trimdate, ' LIMIT ', rownumber);
			PREPARE delete_stmt FROM @delete_text;
			EXECUTE delete_stmt;
			DEALLOCATE PREPARE delete_stmt;				
			
			-- increment iteration counter
			SET i = i + 1;
		END WHILE;
	END LOOP loop_cur_edtable;
	-- END process retained data tables
		
		
	-- BEGIN process ranged_object_value
	-- Getting number of rows to delete for ranged_object_value
	SELECT count(*) INTO @samplesnum FROM ranged_object_value WHERE sample_time < trimdate;			
	
	-- set iteration counter to zero
	SET i = 0;
	
	-- calculate total number of iterations
	SET remainder = MOD(@samplesnum, rownumber);
	SET iterations = ((@samplesnum - remainder)/rownumber) + 1;				
	
	WHILE i < iterations DO
		-- log progress to STDOUT
		SELECT CONCAT('Trimming data in ranged_object_value older than ', trimdate, '.  Iteraion ', i+1, ' of ', iterations) as 'Trimming';

		-- delete from ranged_object_value
		SET @delete_text = CONCAT('DELETE FROM ranged_object_value WHERE sample_time < ', trimdate, ' LIMIT ', rownumber);
		PREPARE delete_stmt FROM @delete_text;
		EXECUTE delete_stmt;
		DEALLOCATE PREPARE delete_stmt;
		
		-- increment iteration counter
		SET i = i + 1;
	END WHILE;
	-- END process ranged_object_value
		
	-- clean up archive_delenda
	TRUNCATE TABLE archive_delenda;
			
	
	CLOSE cur_perftable;
	CLOSE cur_edtable;
	CLOSE cur_vmperftable;
END//

DELIMITER ;