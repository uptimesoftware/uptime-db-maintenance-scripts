set serveroutput on;
set pagesize 1000;
set linesize 1000;
SELECT '----- STARTING: profiling your DataStore, this may take a while -----' "." FROM DUAL;
SELECT '----- current time is -----' "." FROM DUAL;
select sysdate from dual;

SELECT '----- Refresh stats on all performance tables -----' "." FROM DUAL;
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_SAMPLE', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_AGGREGATE', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_CPU', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_DISK', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_DISK_TOTAL', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_ESX3_WORKLOAD', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_FSCAP', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_LPAR_WORKLOAD', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_NETWORK', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_NRM', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_PSINFO', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_VXVOL', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'PERFORMANCE_WHO', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'ERDC_INT_DATA', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'ERDC_DECIMAL_DATA', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'ERDC_STRING_DATA', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'RANGED_OBJECT_VALUE', cascade => TRUE);

EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_aggregate', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_cluster', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_datastore_usage', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_datastore_vm_usage', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_disk_rate', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_entitlement', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_host_cpu', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_host_disk_io', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_host_disk_io_adv', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_host_network', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_host_power_state', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_mem', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_mem_advanced', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_network_rate', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_cpu', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_disk_io', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_network', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_power_state', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_storage_usage', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_vm_vcpu', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'vmware_perf_watts', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'net_device_perf_ping', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'net_device_perf_port', cascade => TRUE);




SELECT '----- current time is -----' "." FROM DUAL;
select sysdate from dual;

SELECT '----- archive policy settings -----' "." FROM DUAL;
select 'policy', id, type, months, last_run from archive_policy;

SELECT '----- finding oldest data in performance tables -----' "." FROM DUAL;
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

SELECT '----- finding total collected samples for recent months -----' "." FROM DUAL;
select 'sample_counts:', TO_CHAR(ps.sample_time, 'YYYY') "Year", TO_CHAR(ps.sample_time, 'MM') "Month", count(id)
from performance_sample ps
group by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM')
order by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM');

SELECT '----- finding sample_id by month -----' "." FROM DUAL;
select 'sample_id:', TO_CHAR(ps.sample_time, 'YYYY') "Year", TO_CHAR(ps.sample_time, 'MM') "Month", min(id)
from performance_sample ps
group by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM')
order by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM');

SELECT '----- table info -----' "." FROM DUAL;
select table_name, tablespace_name, num_rows, avg_row_len, last_analyzed, partitioned from user_tables;

SELECT '----- current time is -----' "." FROM DUAL;
select sysdate from dual;

SELECT '----- FINISHED please send output to support -----' "." FROM DUAL;

