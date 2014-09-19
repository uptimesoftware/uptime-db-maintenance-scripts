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
select 'aggregate', min(sample_time) from performance_sample ps, performance_aggregate pt where ps.id = pt.sample_id;
select 'cpu', min(sample_time) from performance_sample ps, performance_cpu pt where ps.id = pt.sample_id;
select 'disk', min(sample_time) from performance_sample ps, performance_disk pt where ps.id = pt.sample_id;
select 'esx3_workload', min(sample_time) from performance_sample ps, performance_esx3_workload pt where ps.id = pt.sample_id;
select 'fscap', min(sample_time) from performance_sample ps, performance_fscap pt where ps.id = pt.sample_id;
select 'lpar_workload', min(sample_time) from performance_sample ps, performance_lpar_workload pt where ps.id = pt.sample_id;
select 'network', min(sample_time) from performance_sample ps, performance_network pt where ps.id = pt.sample_id;
select 'nrm', min(sample_time) from performance_sample ps, performance_nrm pt where ps.id = pt.sample_id;
select 'psinfo', min(sample_time) from performance_sample ps, performance_psinfo pt where ps.id = pt.sample_id;
select 'vxvol', min(sample_time) from performance_sample ps, performance_vxvol pt where ps.id = pt.sample_id;
select 'who', min(sample_time) from performance_sample ps, performance_who pt where ps.id = pt.sample_id;
select 'decimal_data', min(sampletime) from erdc_decimal_data;
select 'int_data', min(sampletime) from erdc_int_data;
select 'string_data', min(sampletime) from erdc_string_data;

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

