select '----- STARTING: profiling your DataStore, this may take a while -----';
select '----- current time is -----';
select getdate();
select '----- archive policy settings -----';
select 'policy', type, months, last_run from archive_policy;


select '----- finding oldest data in performance tables -----';
select 'aggregate', min(sample_time) 'sample_time' from performance_sample ps, performance_aggregate pt where ps.id = pt.sample_id;
select 'cpu', min(sample_time) 'sample_time' from performance_sample ps, performance_cpu pt where ps.id = pt.sample_id;
select 'disk', min(sample_time) 'sample_time' from performance_sample ps, performance_disk pt where ps.id = pt.sample_id;
select 'esx3_workload', min(sample_time) 'sample_time' from performance_sample ps, performance_esx3_workload pt where ps.id = pt.sample_id;
select 'fscap', min(sample_time) 'sample_time' from performance_sample ps, performance_fscap pt where ps.id = pt.sample_id;
select 'lpar_workload', min(sample_time) 'sample_time' from performance_sample ps, performance_lpar_workload pt where ps.id = pt.sample_id;
select 'network', min(sample_time) 'sample_time' from performance_sample ps, performance_network pt where ps.id = pt.sample_id;
select 'nrm', min(sample_time) 'sample_time' from performance_sample ps, performance_nrm pt where ps.id = pt.sample_id;
select 'psinfo', min(sample_time) 'sample_time' from performance_sample ps, performance_psinfo pt where ps.id = pt.sample_id;
select 'vxvol', min(sample_time) 'sample_time' from performance_sample ps, performance_vxvol pt where ps.id = pt.sample_id;
select 'who', min(sample_time) 'sample_time' from performance_sample ps, performance_who pt where ps.id = pt.sample_id;
select 'decimal_data', min(sampletime) 'sample_time' from erdc_decimal_data;
select 'int_data', min(sampletime) 'sample_time' from erdc_int_data;
select 'string_data', min(sampletime) 'sample_time' from erdc_string_data;

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
select 'vmware_perf_host_power_state', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_power_state);
select 'vmware_perf_mem', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem);
select 'vmware_perf_mem_advanced', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem_advanced);
select 'vmware_perf_network_rate', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_network_rate);
select 'vmware_perf_vm_cpu', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_cpu);
select 'vmware_perf_vm_disk_io', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_disk_io);
select 'vmware_perf_vm_network', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_network);
select 'vmware_perf_vm_power_state', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_power_state);
select 'vmware_perf_vm_storage_usage', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_storage_usage);
select 'vmware_perf_vm_vcpu', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_vcpu);
select 'vmware_perf_watts', sample_time from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_watts);


select '----- finding total collected samples for recent months -----';
select 'sample counts', year(sample_time) 'yr', month(sample_time) 'mn', count(*) 'sample count' from performance_sample ps where sample_time > DATEADD(mm, -2, getdate()) group by year(sample_time), month(sample_time);
select '----- finding sample_id by month -----';
select 'sample_id', year(sample_time) 'yr', month(sample_time) 'mn', min(id) 'min id' from performance_sample ps group by year(sample_time), month(sample_time) order by year(sample_time), month(sample_time);
select '----- db space info -----';
exec sp_spaceused;
select '----- current time is -----';
select getdate();
select '----- FINISHED please send output to support -----';
