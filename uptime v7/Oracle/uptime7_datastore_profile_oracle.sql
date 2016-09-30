set serveroutput on;
set pagesize 1000;
set linesize 1000;
SELECT '----- STARTING: profiling your DataStore, this may take a while -----' " " FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') "- current time is -" FROM DUAL;

SELECT '----- Refresh stats on all performance tables -----' " " FROM DUAL;
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




SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') "- current time is -" FROM DUAL;

SELECT '----- archive policy settings -----' " " FROM DUAL;
column type format a30;
column last_run format a9;
select * from archive_policy;

SELECT '----- finding oldest data in performance tables -----' " " FROM DUAL;
column "aggregate oldest sample time" format a30;
column "cpu oldest sample time" format a30;
column "disk oldest sample time" format a30;
column "disk_total oldest sample time" format a30;
column "esx3_workload oldest smpl time" format a30;
column "fscap oldest sample time" format a30;
column "lpar_workload oldest smpl time" format a30;
column "network oldest sample time" format a30;
column "nrm oldest sample time" format a30;
column "psinfo oldest sample time" format a30;
column "vxvol oldest sample time" format a30;
column "who oldest sample time" format a30;
column "decimal_data oldest smpl time" format a30;
column "int_data oldest sample time" format a30;
column "string_data oldest sampl time" format a30;
column "ranged_data oldest sampl time" format a30;

column "vmware_perf_aggregate" format a30;
column "vmware_perf_cluster" format a30;
column "vmware_perf_datastore_usage" format a30;
column "vmware_perf_datastore_vm_usage" format a30;
column "vmware_perf_disk_rate" format a30;
column "vmware_perf_entitlement" format a30;
column "vmware_perf_host_cpu" format a30;
column "vmware_perf_host_disk_io" format a30;
column "vmware_perf_host_disk_io_adv" format a30;
column "vmware_perf_host_network" format a30;
column "vmware_perf_host_power_state" format a30;
column "vmware_perf_mem" format a30;
column "vmware_perf_mem_advanced" format a30;
column "vmware_perf_network_rate" format a30;
column "vmware_perf_vm_cpu" format a30;
column "vmware_perf_vm_disk_io" format a30;
column "vmware_perf_vm_network" format a30;
column "vmware_perf_vm_power_state" format a30;
column "vmware_perf_vm_storage_usage" format a30;
column "vmware_perf_vm_vcpu" format a30;
column "vmware_perf_watts" format a30;

column "net_device_perf_ping" format a30;
column "net_device_perf_port" format a30;

select ps.sample_time "aggregate oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_aggregate);
select ps.sample_time "cpu oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_cpu);
select ps.sample_time "disk oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_disk);
select ps.sample_time "disk_total oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_disk_total);
select ps.sample_time "esx3_workload oldest smpl time" from performance_sample ps where ps.id = (select min(sample_id) from performance_esx3_workload);
select ps.sample_time "fscap oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_fscap);
select ps.sample_time "lpar_workload oldest smpl time" from performance_sample ps where ps.id = (select min(sample_id) from performance_lpar_workload);
select ps.sample_time "network oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_network);
select ps.sample_time "nrm oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_nrm);
select ps.sample_time "psinfo oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_psinfo);
select ps.sample_time "vxvol oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_vxvol);
select ps.sample_time "who oldest sample time" from performance_sample ps where ps.id = (select min(sample_id) from performance_who);
select sampletime "decimal_data oldest smpl time" from erdc_decimal_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_decimal_data);
select sampletime "int_data oldest sample time" from erdc_int_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_int_data);
select sampletime "string_data oldest sampl time" from erdc_string_data where erdc_int_data_id = (select min(erdc_int_data_id) from erdc_string_data);
select sample_time "ranged_data oldest sampl time" from ranged_object_value where id = (select min(id) from ranged_object_value);

select sample_time "vmware_perf_aggregate" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_aggregate);
select sample_time "vmware_perf_cluster" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_cluster);
select sample_time "vmware_perf_datastore_usage" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_datastore_usage);
select sample_time "vmware_perf_datastore_vm_usage" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_datastore_vm_usage);
select sample_time "vmware_perf_disk_rate" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_disk_rate);
select sample_time "vmware_perf_entitlement" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_entitlement);
select sample_time "vmware_perf_host_cpu" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_cpu);
select sample_time "vmware_perf_host_disk_io" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_disk_io);
select sample_time "vmware_perf_host_disk_io_adv" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_disk_io_adv);
select sample_time "vmware_perf_host_network" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_network);
select sample_time "vmware_perf_host_power_state" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_host_power_state);
select sample_time "vmware_perf_mem" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem);
select sample_time "vmware_perf_mem_advanced" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_mem_advanced);
select sample_time "vmware_perf_network_rate" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_network_rate);
select sample_time "vmware_perf_vm_cpu" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_cpu);
select sample_time "vmware_perf_vm_disk_io" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_disk_io);
select sample_time "vmware_perf_vm_network" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_network);
select sample_time "vmware_perf_vm_power_state" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_power_state);
select sample_time "vmware_perf_vm_storage_usage" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_storage_usage);
select sample_time "vmware_perf_vm_vcpu" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_vm_vcpu);
select sample_time "vmware_perf_watts" from vmware_perf_sample where sample_id = (select min(sample_id) from vmware_perf_watts);

select sample_time "net_device_perf_ping" from net_device_perf_sample where id = (select min(sample_id) from net_device_perf_ping);
select sample_time "net_device_perf_port" from net_device_perf_sample where id = (select min(sample_id) from net_device_perf_port);

SELECT '----- finding total collected samples for recent months -----' " " FROM DUAL;
column "year" format a5;
column "month" format a5;
select TO_CHAR(ps.sample_time, 'YYYY') "YEAR", TO_CHAR(ps.sample_time, 'MM') "MONTH", count(id) "SAMPLES"
from performance_sample ps
group by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM')
order by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM');

SELECT '----- finding sample_id by month -----' " " FROM DUAL;
select TO_CHAR(ps.sample_time, 'YYYY') "YEAR", TO_CHAR(ps.sample_time, 'MM') "MONTH", min(id) "MIN ID"
from performance_sample ps
group by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM')
order by TO_CHAR(ps.sample_time, 'YYYY'), TO_CHAR(ps.sample_time, 'MM');

SELECT '----- table info -----' " " FROM DUAL;
column table_name format a30;
column tablespace_name format a30;
select table_name, tablespace_name, num_rows, avg_row_len, last_analyzed "ANALYZED", partitioned from user_tables 
order by table_name;

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') "- current time is -" FROM DUAL;

SELECT '----- FINISHED please send output to support -----' " " FROM DUAL;

