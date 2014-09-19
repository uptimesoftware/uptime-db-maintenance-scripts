CREATE OR REPLACE PROCEDURE rebuild_uptime_indexes IS
	CURSOR cur_index IS
		SELECT index_name
		FROM user_indexes
		WHERE index_type = 'NORMAL'
		AND (table_name like 'PERFORMANCE_%'
		OR table_name like 'ERDC_%_DATA'
		OR table_name like 'RANGED_OBJECT_VALUE')
		;
BEGIN
	FOR line IN cur_index
	LOOP
		DBMS_OUTPUT.put_line('Rebuilding index ' || line.index_name);
		EXECUTE IMMEDIATE 'ALTER INDEX ' || line.index_name || ' REBUILD';
	END LOOP;
END rebuild_uptime_indexes;
/
