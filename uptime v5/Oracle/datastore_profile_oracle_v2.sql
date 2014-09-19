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

SELECT '----- current time is -----' "." FROM DUAL;
select sysdate from dual;

SELECT '----- archive policy settings -----' "." FROM DUAL;
select 'policy', id, type, months, last_run from archive_policy;

SELECT '----- finding oldest data in performance tables -----' "." FROM DUAL;
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

