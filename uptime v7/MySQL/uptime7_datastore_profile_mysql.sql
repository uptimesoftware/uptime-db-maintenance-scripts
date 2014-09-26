-- --------------------------------------Details for this Script------------------------------------------------------
-- Instructions to run dbprofiler script against MySQL bundled database. 
--  For LINUX
--
--  1. Save the dbprofiler script in the mysql/bin directory (full path <uptime dir>/uptime/mysql/bin)
--  2. Run the below command from this directory:
-- ./mysql -uroot -puptimerocks -P3308 --protocol=TCP --database=uptime <uptime7_datastore_profile_mysql.sql>result.txt
--  
--  For Windows
--  1. Save the dbprofiler script to mysql\bin folder (full path <uptime dir>\uptime\mysql\bin)
--  2. Open a command prompt and cd to mysql\bin directory and run the below command
--
--  mysql -uroot -puptimerocks -P3308 --protocol=TCP --database=uptime <uptime7_datastore_profile_mysql.sql>result.txt
--
--  Now you should be able to review the results in the reslut.txt file which should be located in mysql\bin directory. 
--
--  The information about archiving settings policy should be below this line
--  ----- Archive policy settings -----
-- 
--  This information about historical data should be below this line
--  ----- Finding oldest data in performance tables -----
-- -------------------------------------------------------------------------------------------------------------------
select '----- STARTING: profiling your DataStore, this may take a while -----';
select '----- current time is -----';
select now();
select '----- size of uptime schema -----';
select table_schema "Data Base Name", sum(data_length+index_length)/1024/1024 "Data Base Size in MB" from information_schema.TABLES where table_schema = "uptime" group by table_schema;
select '----- archive policy settings -----';
select 'policy', type, months, last_run from archive_policy;
select '----- finding oldest data in performance tables -----';
select 'aggregate', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_aggregate);
select 'cpu', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_cpu);
select 'disk', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_disk);
select 'disk_total', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_disk_total);
select 'esx3_workload', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_esx3_workload);
select 'fscap', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_fscap);
select 'lpar_workload', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_lpar_workload);
select 'network', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_network);
select 'nrm', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_nrm);
select 'psinfo', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_psinfo);
select 'vxvol', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_vxvol);
select 'who', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_who);
select 'decimal_data', sampletime from erdc_decimal_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_decimal_data);
select 'int_data', sampletime from erdc_int_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_int_data);
select 'string_data', sampletime from erdc_string_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_string_data);
select 'ranged_data', sample_time from ranged_object_value where id = (select min(id) from ranged_object_value);

select 'vmware_perf_aggregate', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_aggregate);
select 'vmware_perf_cluster', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_cluster);
select 'vmware_perf_datastore_usage', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_datastore_usage);
select 'vmware_perf_datastore_vm_usage', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_datastore_vm_usage);
select 'vmware_perf_disk_rate', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_disk_rate);
select 'vmware_perf_entitlement', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_entitlement);
select 'vmware_perf_host_cpu', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_cpu);
select 'vmware_perf_host_disk_io', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_disk_io);
select 'vmware_perf_host_disk_io_adv', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_disk_io_adv);
select 'vmware_perf_host_network', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_network);
select 'vmware_perf_host_power_state', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_power_state);
select 'vmware_perf_mem', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem);
select 'vmware_perf_mem_advanced', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem_advanced);
select 'vmware_perf_network_rate', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_network_rate);
select 'vmware_perf_vm_cpu', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_cpu);
select 'vmware_perf_vm_disk_io', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_disk_io);
select 'vmware_perf_vm_network', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_network);
select 'vmware_perf_vm_power_state', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_power_state);
select 'vmware_perf_vm_storage_usage', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_storage_usage);
select 'vmware_perf_vm_vcpu', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_vcpu);
select 'vmware_perf_watts', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_watts);

select 'net_device_perf_ping', sample_time from net_device_perf_sample where id = (select min(sample_id) from net_device_perf_ping);
select 'net_device_perf_port', sample_time from net_device_perf_sample where id = (select min(sample_id) from net_device_perf_port);


select '----- finding total collected samples for recent months -----';
select 'sample counts', year(sample_time) yr, month(sample_time) mn, count(*) from performance_sample ps where sample_time > DATE_SUB(now(), INTERVAL 2 MONTH) group by yr, mn;
select 'vmware sample counts', year(sample_time) yr, month(sample_time) mn, count(*) from vmware_perf_sample ps where sample_time > DATE_SUB(now(), INTERVAL 2 MONTH) group by yr, mn;

select '----- finding sample_id by month -----';
select 'sample_id', year(sample_time) yr, month(sample_time) mn, min(id) from performance_sample ps group by yr, mn order by yr, mn;
select 'vmware sample_id', year(sample_time) yr, month(sample_time) mn, min(sample_id) from vmware_perf_sample ps group by yr, mn order by yr, mn;

select '------- # of monitored elements --------';
select 'elements', count(*) from entity where monitored = 1;
select '------- # of running service monitors --------';
select 'service monitors', count(*) from erdc_instance where monitored = 1;
select '------- check intervals summary --------';
select 'check intervals', check_interval, count(*) from erdc_configuration group by check_interval;
select '----- innodb info -----';
show table status;
select '----- current time is -----';
select now();
select '----- FINISHED please send output to support -----';
