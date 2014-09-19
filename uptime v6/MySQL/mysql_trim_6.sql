--Number of days you want to keep
Set @Days:=360;

select CONCAT('deleting data older than ', DATE_SUB(CURDATE(), INTERVAL @Days DAY)) as 'deleting';

select min(id) into @ID from performance_sample where date(sample_time) like DATE_SUB(CURDATE(), INTERVAL @Days DAY);
select @id as 'perf_sample_id', sample_time from performance_sample where id = @id;

--Does the deletes for each table based off the sample id from performance sample
delete from performance_aggregate where sample_id <@ID; 
delete from performance_cpu where sample_id <@ID;
delete from performance_disk where sample_id <@ID;
delete from performance_disk_total where sample_id <@ID;
delete from performance_esx3_workload where sample_id <@ID;
delete from performance_fscap where sample_id <@ID;
delete from performance_lpar_workload where sample_id <@ID;
delete from performance_network where sample_id <@ID;
delete from performance_nrm where sample_id <@ID;
delete from performance_psinfo where sample_id <@ID;
delete from performance_vxvol where sample_id <@ID;
delete from performance_who where sample_id <@ID;

--Does these deletes based off the current date - @Days
delete from ranged_object_value where sample_time < DATE_SUB(CURDATE(), INTERVAL @Days DAY); 
delete from erdc_decimal_data where sampletime < DATE_SUB(CURDATE(), INTERVAL @Days DAY); 
delete from erdc_string_data where sampletime < DATE_SUB(CURDATE(), INTERVAL @Days DAY); 
delete from erdc_int_data where sampletime < DATE_SUB(CURDATE(), INTERVAL @Days DAY); 


-- deletes for vware_perf_ tables added in 6
select min(sample_id) into @vmware_perf_ID from vmware_perf_sample where date (sample_time) like DATE_SUB(CURDATE(), INTERVAL @days DAY);
select @vmware_perf_id as 'vmware_perf_id', sample_time from vmware_perf_sample where sample_id = @vmware_perf_id;


delete from vmware_perf_aggregate where sample_id < @vmware_perf_ID;
delete from vmware_perf_cluster where sample_id < @vmware_perf_ID;
delete from vmware_perf_datastore_usage where sample_id < @vmware_perf_ID;
delete from vmware_perf_datastore_vm_usage where sample_id < @vmware_perf_ID;
delete from vmware_perf_disk_rate where sample_id < @vmware_perf_ID;
delete from vmware_perf_entitlement where sample_id < @vmware_perf_ID;
delete from vmware_perf_host_cpu where sample_id < @vmware_perf_ID;
delete from vmware_perf_host_disk_io where sample_id < @vmware_perf_ID;
delete from vmware_perf_host_disk_io_adv where sample_id < @vmware_perf_ID;
delete from vmware_perf_host_network where sample_id < @vmware_perf_ID;
delete from vmware_perf_host_power_state where sample_id < @vmware_perf_ID;
delete from vmware_perf_mem where sample_id < @vmware_perf_ID;
delete from vmware_perf_mem_advanced where sample_id < @vmware_perf_ID;
delete from vmware_perf_network_rate where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_cpu where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_disk_io where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_network where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_power_state where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_storage_usage where sample_id < @vmware_perf_ID;
delete from vmware_perf_vm_vcpu where sample_id < @vmware_perf_ID;
delete from vmware_perf_watts where sample_id < @vmware_perf_ID;



