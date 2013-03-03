-- File name:   awr_bas.sql  
-- Purpose:     generate AWR report between two baselines id
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0                                                                                                                                     
-- Usage:       @awr_bas
-- Parameters:  first_baseline_id: baseline id 
--              second_baseline_id: baseline id
--------------------------------------------------------------------------------  
set feedback off
set sqlblanklines on

accept first_baseline_id -
    prompt 'Enter value for first baseline id (Default: 1): ' -
    default 1
accept second_baseline_id -
    prompt 'Enter value for second baseline id (Default: 2): ' -
    default 2

CREATE OR REPLACE DIRECTORY awr_reports_dir AS '/var/tmp';
GRANT READ ON DIRECTORY awr_reports_dir TO DBA;
GRANT WRITE ON DIRECTORY awr_reports_dir TO DBA;

set serveroutput on

DECLARE
    l_dbid1 NUMBER;
    l_inst_num1 NUMBER;
    l_bid1 NUMBER;
    l_eid1 NUMBER;
    l_inst_nam1 VARCHAR2(4000);

    l_dbid2 NUMBER;
    l_inst_num2 NUMBER;
    l_bid2 NUMBER;
    l_eid2 NUMBER;
    l_inst_nam2 VARCHAR2(4000);

    l_file             UTL_FILE.file_type;
    l_file_name        VARCHAR(50);
    
BEGIN
    BEGIN
        SELECT dbid, start_snap_id, end_snap_id
        INTO l_dbid1, l_bid1, l_eid1
        FROM
            dba_hist_baseline
        WHERE 
            baseline_id = &first_baseline_id;

        SELECT value
        INTO l_inst_nam1 
        FROM
            v$parameter
        WHERE
            name = 'instance_name';
            
        SELECT instance_number
        INTO l_inst_num1
        FROM
            v$instance
        WHERE 
            instance_name = l_inst_nam1;

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(' ');
        dbms_output.put_line('ERROR: can not retrieve info ' 
            || 'for baseline id: ' || &first_baseline_id);
        dbms_output.put_line(' ');
    END;

    BEGIN
        SELECT dbid, start_snap_id, end_snap_id
        INTO l_dbid2, l_bid2, l_eid2
        FROM
            dba_hist_baseline
        WHERE 
            baseline_id = &second_baseline_id;

        SELECT value
        INTO l_inst_nam2 
        FROM
            v$parameter
        WHERE
            name = 'instance_name';
            
        SELECT instance_number
        INTO l_inst_num2
        FROM
            v$instance
        WHERE 
            instance_name = l_inst_nam2;

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(' ');
        dbms_output.put_line('ERROR: can not retrieve info ' 
            || 'for baseline id: ' || &second_baseline_id);
        dbms_output.put_line(' ');
    END;

    l_file := UTL_FILE.fopen('AWR_REPORTS_DIR', 'awr_bl_' || &first_baseline_id || '_' 
        || &second_baseline_id || '.htm', 'w', 32767);

    FOR cur_rep IN (
        SELECT output
        FROM
            TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_html(
                l_dbid1,
                l_inst_num1,
                l_bid1,
                l_eid1,
                l_dbid2,
                l_inst_num2,
                l_bid2,
                l_eid2
                )
            )
    )
    LOOP
        UTL_FILE.put_line(l_file, cur_rep.output);
    END LOOP;
    UTL_FILE.fclose(l_file);

    dbms_output.put_line(' ');                                                                                                                                                        
    dbms_output.put_line('AWR baseline report created at:  ' ||                                                                                                                
         'awr_bl_' || &first_baseline_id || '_' 
        || &second_baseline_id || '.htm');
    dbms_output.put_line(' '); 

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(' ');
        dbms_output.put_line('ERROR: can not generate AWR report');
        dbms_output.put_line(' ');

END;
/

undef start_time
undef end_time
undef baseline_name
undef dbid
undef expiration

set serveroutput off
set sqlblanklines off
set feedback on
