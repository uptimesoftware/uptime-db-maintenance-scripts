DROP PROCEDURE IF EXISTS trim_uptime_data;

DELIMITER //

CREATE PROCEDURE trim_uptime_data()
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
-- Steps to run this script: 
-- 1. Run this sql file so it will create the procedure. 
-- 2. Verify the archive policy settings are correct in GUI (Config > Archive Policy > Verify months values are 
-- correct and that "Enable Archiving" is unchecked. 
-- 3. Then call the procedure "TRIM_UPTIME_DATA" to have it actually run and delete the data.
--
-- Note: This uses the database name in the script on 2 lines so if you have a database name other then uptime will 
-- need to update this value can search for "table_schema=" and update the value uptime just after that.
-- -------------------------------------------------------------------------------------------------------------------
BEGIN
    DECLARE trimdate       DATE;
	
	DECLARE trimOverallCPUdate	DATE;
	DECLARE trimMultiCPUdate	DATE;
	DECLARE trimProcessdate	DATE;
	DECLARE trimDiskdate	DATE;
	DECLARE trimFSdate	DATE;
	DECLARE trimNetworkdate	DATE;
	DECLARE trimUserdate	DATE;
	DECLARE trimVolumedate	DATE;
	DECLARE trimRetaineddate	DATE;
	DECLARE trimVPerfdate	DATE;
	DECLARE trimNDPerfdate	DATE;
	DECLARE trimPSdate	DATE;
	DECLARE trimVMSdate	DATE;
	DECLARE trimNDSdate	DATE;
	DECLARE trimOverallCPUid		INT;
	DECLARE trimMultiCPUid		INT;
	DECLARE trimProcessid		INT;
	DECLARE trimDiskid		INT;
	DECLARE trimFSid		INT;
	DECLARE trimNetworkid		INT;
	DECLARE trimUserid		INT;
	DECLARE trimVolumeid		INT;
	DECLARE trimRetainedid		INT;
	DECLARE trimVPerfid		INT;
	DECLARE trimNDPerfid		INT;
	DECLARE trimPSid		INT;
	DECLARE trimVMSid		INT;
	DECLARE trimNDSid		INT;
	
    DECLARE trimid         INT;
    DECLARE rownumber      INT;
    DECLARE remainder      INT;
    DECLARE iterations     INT;
    DECLARE i              INT;
    DECLARE cur_table_name VARCHAR(255);
    DECLARE done           INT DEFAULT FALSE;
    
    DECLARE cur_perftable   CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema='uptime' AND ((table_name LIKE 'performance_%' AND table_name != 'performance_sample') or (table_name LIKE 'vmware_perf_%' AND table_name != 'vmware_perf_sample') or (table_name LIKE 'net_device_perf_%' AND table_name != 'net_device_perf_sample' AND table_name != 'net_device_perf_latest_sample'));
    DECLARE cur_edtable     CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema='uptime' AND table_name LIKE 'erdc_%_data';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_perftable;
    OPEN cur_edtable;
    
    
-- ------------------------------ Client modifiable variables ---------------------------------------------------------
    SET rownumber  = 10000; -- # of rows to delete at a time.  Setting this too high may cause prohibitive table locks
-- --------------------------------------------------------------------------------------------------------------------

    select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimOverallCPUdate from archive_policy ap where ap.TYPE = 'cpustats'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimMultiCPUdate from archive_policy ap where ap.TYPE = 'cpus'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimProcessdate from archive_policy ap where ap.TYPE = 'processes'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimDiskdate from archive_policy ap where ap.TYPE = 'disks'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimFSdate from archive_policy ap where ap.TYPE = 'filesystems'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimNetworkdate from archive_policy ap where ap.TYPE = 'networks'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimUserdate from archive_policy ap where ap.TYPE = 'who'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimVolumedate from archive_policy ap where ap.TYPE = 'vxvols'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimRetaineddate from archive_policy ap where ap.TYPE = 'retained'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimVPerfdate from archive_policy ap where ap.TYPE = 'vmwarePerformance'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL ap.months MONTH) into trimNDPerfdate from archive_policy ap where ap.TYPE = 'networkDevicePerformance'; -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL max(ap.months) MONTH) into trimPSdate from archive_policy ap where ap.TYPE in ('cpus', 'cpustats', 'cpus', 'processes', 'disks', 'filesystems', 'networks', 'who', 'vxvols', 'retained'); -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL max(ap.months) MONTH) into trimVMSdate from archive_policy ap where ap.TYPE in ('vmwarePerformance', 'vmwareInventoryUpdates'); -- date to trim up to
	select DATE_SUB(CURDATE(), INTERVAL max(ap.months) MONTH) into trimNDSdate from archive_policy ap where ap.TYPE in ('networkDevicePerformance'); -- date to trim up to
   
    SELECT MAX(id) INTO trimOverallCPUid FROM performance_sample WHERE sample_time < trimOverallCPUdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimMultiCPUid FROM performance_sample WHERE sample_time < trimMultiCPUdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimProcessid FROM performance_sample WHERE sample_time < trimProcessdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimDiskid FROM performance_sample WHERE sample_time < trimDiskdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimFSid FROM performance_sample WHERE sample_time < trimFSdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimNetworkid FROM performance_sample WHERE sample_time < trimNetworkdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimUserid FROM performance_sample WHERE sample_time < trimUserdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimVolumeid FROM performance_sample WHERE sample_time < trimVolumedate; -- corresponding id in perf_sample	
	SELECT MAX(sample_id) INTO trimVPerfid FROM vmware_perf_sample WHERE sample_time < trimVPerfdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimNDPerfid FROM net_device_perf_sample WHERE sample_time < trimNDPerfdate; -- corresponding id in perf_sample	
	
	SELECT MAX(id) INTO trimPSid FROM performance_sample WHERE sample_time < trimPSdate; -- corresponding id in perf_sample	
	SELECT MAX(sample_id) INTO trimVMSid FROM vmware_perf_sample WHERE sample_time < trimVMSdate; -- corresponding id in perf_sample	
	SELECT MAX(id) INTO trimNDSid FROM net_device_perf_sample WHERE sample_time < trimNDSdate; -- corresponding id in perf_sample	
	
    --     process all performance tables except performance_sample        
	loop_cur_perftable: LOOP
		FETCH cur_perftable INTO cur_table_name;
		
		if lower(cur_table_name) = 'performance_cpu' THEN
			SET trimid = trimMultiCPUid;
		elseif lower(cur_table_name) = 'performance_aggregate' or lower(cur_table_name) = 'performance_nrm' THEN
			SET trimid = trimOverallCPUid;
		elseif lower(cur_table_name) = 'performance_psinfo' or lower(cur_table_name) = 'performance_lpar_workload' or lower(cur_table_name) = 'performance_esx3_workload' THEN
			SET trimid = trimProcessid;
		elseif lower(cur_table_name) = 'performance_disk' or lower(cur_table_name) = 'performance_disk_total' THEN
			SET trimid = trimDiskid;
		elseif lower(cur_table_name) = 'performance_fscap' THEN
			SET trimid = trimFSid;
		elseif lower(cur_table_name) = 'performance_network' THEN
			SET trimid = trimNetworkid;
		elseif lower(cur_table_name) = 'performance_who' THEN
			SET trimid = trimUserid;
		elseif lower(cur_table_name) = 'performance_vxvol' THEN
			SET trimid = trimVolumeid;
		elseif lower(cur_table_name) like 'vmware_perf%' THEN
			SET trimid = trimVPerfid;
		elseif lower(cur_table_name) like 'net_device_perf%' THEN
			SET trimid = trimNDPerfid;
		else 
			SET trimid = 0;
		end if;
		
		IF trimid IS NULL THEN
			SET trimid = 0;
		end if;
		
		IF done THEN
			LEAVE loop_cur_perftable;
		END IF;
		
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
			SELECT CONCAT('Trimming data in ', cur_table_name, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';
								
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
	
	-- process performance_sample table
	-- Getting number of rows to delete for performance_sample
	SELECT count(*) INTO @samplesnum FROM performance_sample WHERE sample_time < trimPSdate;            
				
	-- set iteration counter to zero
	SET i = 0;
	
	IF trimPSid IS NULL THEN
		set trimPSid = 0;
	end if;
	
	-- calculate total number of iterations
	SET remainder = MOD(@samplesnum, rownumber);
	SET iterations = ((@samplesnum - remainder)/rownumber) + 1;            
	
	WHILE i < iterations DO
		-- log progress to STDOUT
		SELECT CONCAT('Trimming data in performance_sample older than ', trimPSdate, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';
		
		-- delete from performance_sample
		SET @delete_text = CONCAT('DELETE FROM performance_sample WHERE id <= ', trimPSid, ' LIMIT ', rownumber);
		PREPARE delete_stmt FROM @delete_text;
		EXECUTE delete_stmt;
		DEALLOCATE PREPARE delete_stmt;                
		
		-- increment iteration counter
		SET i = i + 1;
	END WHILE;
    
	-- END process performance_sample
	
    -- process vmware_perf_sample
	-- Getting number of rows to delete for vmware_perf_sample
	SELECT count(*) INTO @samplesnum FROM vmware_perf_sample WHERE sample_time < trimVMSdate;            
				
	-- set iteration counter to zero
	SET i = 0;
	
	IF trimVMSid IS NULL THEN
		set trimVMSid = 0;
	end if;
		
	-- calculate total number of iterations
	SET remainder = MOD(@samplesnum, rownumber);
	SET iterations = ((@samplesnum - remainder)/rownumber) + 1;            
	
	WHILE i < iterations DO
		-- log progress to STDOUT
		SELECT CONCAT('Trimming data in vmware_perf_sample older than ', trimVMSdate, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';
		
		-- delete from performance_sample
		SET @delete_text = CONCAT('DELETE FROM vmware_perf_sample WHERE sample_id <= ', trimVMSid, ' LIMIT ', rownumber);
		PREPARE delete_stmt FROM @delete_text;
		EXECUTE delete_stmt;
		DEALLOCATE PREPARE delete_stmt;                
		
		-- increment iteration counter
		SET i = i + 1;
	END WHILE;
    
	-- END process vmware_perf_sample

	-- Process net_device_perf_sample
	-- Getting number of rows to delete for vmware_perf_sample
	SELECT count(*) INTO @samplesnum FROM net_device_perf_sample WHERE sample_time < trimNDSdate;            
				
	-- set iteration counter to zero
	SET i = 0;
	
	IF trimNDSid IS NULL THEN
		set trimNDSid = 0;
	end if;
		
	-- calculate total number of iterations
	SET remainder = MOD(@samplesnum, rownumber);
	SET iterations = ((@samplesnum - remainder)/rownumber) + 1;            
	
	WHILE i < iterations DO
		-- log progress to STDOUT
		SELECT CONCAT('Trimming data in net_device_perf_sample older than ', trimNDSdate, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';
		
		-- delete from performance_sample
		SET @delete_text = CONCAT('DELETE FROM net_device_perf_sample WHERE id <= ', trimNDSid, ' LIMIT ', rownumber);
		PREPARE delete_stmt FROM @delete_text;
		EXECUTE delete_stmt;
		DEALLOCATE PREPARE delete_stmt;                
		
		-- increment iteration counter
		SET i = i + 1;
	END WHILE;

    -- END process net_device_perf_sample
            
            
    -- BEGIN process retained data tables
    SET done = FALSE;

    loop_cur_edtable: LOOP
        FETCH cur_edtable INTO cur_table_name;
        
        IF done THEN
            LEAVE loop_cur_edtable;
        END IF;

        -- Getting number of rows to delete for current retained data table
        SET @count_text = CONCAT('SELECT count(*) INTO @samplesnum FROM ', cur_table_name, ' WHERE sampletime < ', trimRetaineddate);
        PREPARE count_stmt FROM @count_text;
        EXECUTE count_stmt;
        DEALLOCATE PREPARE count_stmt;
            
        IF @samplesnum > 0 THEN
            -- set iteration counter to zero
            SET i = 0;
            
            -- calculate total number of iterations
            SET remainder = MOD(@samplesnum, rownumber);
            SET iterations = ((@samplesnum - remainder)/rownumber) + 1;            
            
            WHILE i < iterations DO
                -- log progress to STDOUT
                SELECT CONCAT('Trimming data in ', cur_table_name, ' older than ', trimRetaineddate, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';
                                    
                -- delete from performance table
                SET @delete_text = CONCAT('DELETE FROM ', cur_table_name, ' WHERE sampletime < ', trimRetaineddate, ' LIMIT ', rownumber);
                PREPARE delete_stmt FROM @delete_text;
                EXECUTE delete_stmt;
                DEALLOCATE PREPARE delete_stmt;                
                
                -- increment iteration counter
                SET i = i + 1;
            END WHILE;
        ELSE
            SELECT CONCAT('No ', cur_table_name, ' data found prior to ', trimRetaineddate, '.  No entries to trim.') AS 'Retained Data Tables';
        END IF;
    END LOOP loop_cur_edtable;
    -- END process retained data tables
        
        
    -- BEGIN process ranged_object_value
    -- Getting number of rows to delete for ranged_object_value
    SELECT count(*) INTO @samplesnum FROM ranged_object_value WHERE sample_time < trimRetaineddate;            
    
    -- set iteration counter to zero
    SET i = 0;
    
    IF @samplesnum > 0 THEN
        -- calculate total number of iterations
        SET remainder = MOD(@samplesnum, rownumber);
        SET iterations = ((@samplesnum - remainder)/rownumber) + 1;                

        WHILE i < iterations DO
            -- log progress to STDOUT
            SELECT CONCAT('Trimming data in ranged_object_value older than ', trimRetaineddate, '.  Iteration ', i+1, ' of ', iterations) as 'Trimming';

            -- delete from ranged_object_value
            SET @delete_text = CONCAT('DELETE FROM ranged_object_value WHERE sample_time < ', trimRetaineddate, ' LIMIT ', rownumber);
            PREPARE delete_stmt FROM @delete_text;
            EXECUTE delete_stmt;
            DEALLOCATE PREPARE delete_stmt;
            
            -- increment iteration counter
            SET i = i + 1;
        END WHILE;
    ELSE
        SELECT CONCAT('No ranged_object_value data found prior to ', trimRetaineddate, '.  No entries to trim.') AS 'Ranged Object Value Table';
    END IF;
    -- END process ranged_object_value
        
    -- clean up archive_delenda
    TRUNCATE TABLE archive_delenda;
        
    SELECT CONCAT('Finished trimming historical data older than ', trimRetaineddate, '.') AS 'Complete';        
    
    CLOSE cur_perftable;
    CLOSE cur_edtable;
END//

DELIMITER ;