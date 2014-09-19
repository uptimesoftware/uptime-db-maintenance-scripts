--Number of days you want to keep
Set @Days:=180;

select min(id) into @ID from performance_sample where date(sample_time) like DATE_SUB(CURDATE(), INTERVAL @Days DAY);

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