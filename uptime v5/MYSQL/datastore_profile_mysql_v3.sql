select '----- STARTING: profiling your DataStore, this may take a while -----';
select '----- current time is -----';
select now();
select '----- archive policy settings -----';
select 'policy', type, months, last_run from archive_policy;
select '----- finding oldest data in performance tables -----';
select 'aggregate', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_aggregate);
select 'cpu', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_cpu);
select 'disk', ps.sample_time from performance_sample ps where ps.id = (select min(sample_id) from performance_disk);
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
select '----- finding total collected samples for recent months -----';
select 'sample counts', year(sample_time) yr, month(sample_time) mn, count(*) from performance_sample ps where sample_time > DATE_SUB(now(), INTERVAL 2 MONTH) group by yr, mn;
select '----- finding sample_id by month -----';
select 'sample_id', year(sample_time) yr, month(sample_time) mn, min(id) from performance_sample ps group by yr, mn order by yr, mn;
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
