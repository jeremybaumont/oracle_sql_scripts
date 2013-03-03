-- File name:   oem_stop_job.sql
-- Purpose:     Stop oem job even if status is running
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
-- Usage:       @oem_stop_job <owner> <oem_job_name>
--              @oem_stop_job TEST TEST_RMANBACKUP_LOGDISKBACKUP
--------------------------------------------------------------------------------

set serveroutput on
set feedb off
SET verify OFF 
SET linesize 255 
SET pagesize 128 
set pages 999
SET trimout ON 
SET trimspool ON 
ALTER SESSION SET nls_date_format='MON-DD-YYYY hh:mi:ss pm'; 
 
COLUMN status format a15 
 
COLUMN job_name FORMAT a54 
COLUMN job_type FORMAT a22 
COLUMN job_owner FORMAT a22 
COLUMN job_status format 99 
COLUMN target_type format a24 
 
COLUMN frequency_code format a20 
COLUMN interval format 99999999


COLUMN parameter_name format a30
COLUMN SCALAR_VALUE format a25
COLUMN vector_value format a25

COLUMN target_name for a54
column target_type for a30

create or replace directory tmp as '/var/tmp';
set feedb on

VARIABLE JOBID VARCHAR2(64); 

SPOOL /var/tmp/jobdump.log


PROMPT  ***************************************************************
PROMPT *********************** JOB INFO ********************************
PROMPT  ***************************************************************

BEGIN 
    SELECT job_id INTO :JOBID 
    FROM MGMT_JOB 
    WHERE job_name='&&2' 
    AND job_owner='&&1' 
    AND nested=0; 
 
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    BEGIN 
        DBMS_OUTPUT.put_line('JOB NOT FOUND, TRYING NAME ONLY'); 
        SELECT job_id INTO :JOBID 
        FROM MGMT_JOB 
        WHERE job_name='&&jobName' 
        AND nested=0 
        AND ROWNUM=1; 
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.put_line('JOB NOT FOUND'); 
    END; 
END; 
/ 
 
SELECT job_name, job_owner, job_type, system_job, job_status, target_type 
FROM MGMT_JOB 
WHERE job_id=HEXTORAW(:JOBID); 
 
PROMPT  ***************************************************************
PROMPT *********************** JOB SCHEDULE **************************** 
PROMPT  ***************************************************************
SELECT DECODE(frequency_code, 
1, 'Once', 
2, 'Interval', 
3, 'Daily', 
4, 'Day of Week', 
5, 'Day of Month', 
6, 'Day of Year', frequency_code) "FREQUENCY_CODE", 
start_time, end_time, execution_hours, execution_minutes, 
interval,  timezone_info,  
 timezone_region 
FROM MGMT_JOB_SCHEDULE s, MGMT_JOB j 
WHERE s.schedule_id=j.schedule_id 
AND j.job_id=HEXTORAW(:JOBID); 
 
PROMPT  ***************************************************************
PROMPT ********************** PARAMETERS ******************************** 
PROMPT  ***************************************************************
SELECT parameter_name, 
decode(parameter_type, 
0, 'Scalar', 
1, 'Vector', 
2, 'Large', parameter_type) "PARAMETER_TYPE", 
scalar_value, vector_value 
FROM MGMT_JOB_PARAMETER 
WHERE job_id=HEXTORAW(:JOBID) 
AND execution_id=HEXTORAW('0000000000000000') 
ORDER BY parameter_name; 
 
PROMPT  ***************************************************************
PROMPT ********************** TARGETS ******************************** 
PROMPT  ***************************************************************
SELECT target_name, target_type 
FROM MGMT_JOB_TARGET jt, MGMT_TARGETS t 
WHERE job_id=HEXTORAW(:JOBID) 
AND execution_id=HEXTORAW('0000000000000000') 
AND jt.target_guid=t.target_guid 
ORDER BY target_type, target_name; 
 
PROMPT ************************ EXECUTIONS ******************************* 
SELECT execution_id, 
DECODE(status, 
1, 'SCHEDULED', 
2, 'RUNNING', 
3, 'FAILED INIT', 
4, 'FAILED', 
5, 'SUCCEEDED', 
6, 'SUSPENDED', 
7, 'AGENT DOWN', 
8, 'STOPPED', 
9, 'SUSPENDED/LOCK', 
10, 'SUSPENDED/EVENT', 
11, 'SUSPENDED/BLACKOUT', 
12, 'STOP PENDING', 
13, 'SUSPEND PENDING', 
14, 'INACTIVE', 
15, 'QUEUED', 
16, 'FAILED/RETRIED', 
17, 'WAITING', 
18, 'SKIPPED', status) "STATUS", 
scheduled_time, start_time, end_time 
FROM MGMT_JOB_EXEC_SUMMARY e 
WHERE job_id=HEXTORAW(:JOBID) 
ORDER BY scheduled_time; 
 
PROMPT ************************ RUNNING EXECUTIONS ******************************* 
SELECT execution_id, 
DECODE(status, 
2, 'RUNNING', 
status) "STATUS", 
scheduled_time, start_time, end_time 
FROM MGMT_JOB_EXEC_SUMMARY e 
WHERE job_id=HEXTORAW(:JOBID) 
and status = 2
ORDER BY scheduled_time; 
 


DECLARE 
    count_job NUMBER(5);

    inFile utl_file.file_type;
    outFile utl_file.file_type;
    x varchar2(40);

    CURSOR c_job is
    SELECT job_id 
    FROM mgmt_job
    WHERE job_name = '&&2' 
    AND job_owner = '&&1'
    AND nested = 0;

BEGIN

    FOR j in c_job
    LOOP
        dbms_output.put_line('Deleting OEM Job: '|| j.job_id ||' , name: ' || '&&1' ||', owner: '|| '&&2'); 
        
--        inFile := utl_file.fopen('TMP','in','R');
--        outFile := utl_file.fopen('TMP','out','W');
--        utl_file.put_line(outFile,'Would you want to go on deleting (y/n) ? : ');

--        utl_file.fflush(outFile);
--        utl_file.get_line(inFile,x);
--        utl_file.put_line(outFile,'you enterred '||x);
        
--        case x 
--        when 'y' then dbms_output.put_line('deleting confirmed...');
--        when 'Y' then dbms_output.put_line('deleting confirmed...');
--        when 'n' then exit;
--        when 'N' then exit;
--        else        
--                dbms_output.put_line('Your input is not y or n, try again.');
--                exit;
--        end case;              

--        utl_file.fclose(inFile);
--        utl_file.fclose(outFile);


        SYSMAN.mgmt_job_engine.stop_all_executions_with_id(j.job_id,TRUE);
        COMMIT;

    END LOOP;
END;
/
