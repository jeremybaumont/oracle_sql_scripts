-- File name:   aq_prop_sched.sql
-- Purporse: check Advanced Queueing propagation schedules
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @aq_prop_sched  
--------------------------------------------------------------------------------



-- Script made from metalink id 233099.1

set lines 400
col schema form a10
col NEXT_RUN_TIME for a30
col NEXT_RUN_DATE for a45
col qname form a25
col destination form a20
col last_error_msg for a30
col name for a30
col value for a30
col display_value for a30

prompt ### Job Queue Processes in parameter file
prompt ###
select
	name, value, display_value, isdefault, ismodified
from
	v$parameter
where 
	upper(name) = 'JOB_QUEUE_PROCESSES'
/


prompt ### Last errors in a propagation schedule 
prompt ###
select 
	schema, qname, schedule_disabled as Is_schedule_disabled, destination,
         to_char(next_run_date,'HH24:MI:SS MM/DD/YY') next_time,
	last_error_date, last_error_time, last_error_msg 
from dba_queue_schedules
order by  next_run_date
/


Prompt ### Next propagation schedules runs
prompt ###
column start_date                            format a20
column propagation_window                    format 99999
column next_time heading 'Next Window'       format a25
column latency                               format 99999
column schedule_disabled heading 'Disabled?' format a10
column process_name                          format a12
column failures                              format 99
select process_name, 
          schedule_disabled as Is_schedule_disabled,
          propagation_window Duration,
          latency,
          failures,
          to_char(start_date,'HH24:MI:SS MM/DD/YY') start_date,
          to_char(next_run_date,'HH24:MI:SS MM/DD/YY') next_time
from dba_queue_schedules
order by next_run_date
/

prompt ### Current running job for propagation: OS PIDs Corresponding to Job Queue Processes
prompt ###
select p.spid, p.program, s.sid, j.what 
from 
	v$process p,dba_jobs_running jr, 
	v$session s, dba_jobs j 
where s.sid=jr.sid 
and s.paddr=p.addr 
and jr.job=j.job 
and j.what like '%sys.dbms_aqadm.aq$_propaq(job)%';

col PROGRAM for a30
select p.SPID, p.PROGRAM, s.sid, j.JOB_name
from v$PROCESS p, DBA_SCHEDULER_RUNNING_JOBS jr, V$SESSION s, DBA_SCHEDULER_JOBS j 
where s.SID=jr.SESSION_ID 
and s.PADDR=p.ADDR
and jr.JOB_name=j.JOB_NAME 
and j.JOB_NAME like '%AQ_JOB$_%'
/

