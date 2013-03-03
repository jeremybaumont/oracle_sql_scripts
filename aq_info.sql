-- File name:   aq_info.sql
-- Purpose:     display information advanced queueing 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0 
--                                                                                                                
-- Usage:       @aq_info  <OWNER>
--------------------------------------------------------------------------------




prompt " Advanced Queues "

select 
    name, max_retries, retry_delay, retention, queue_table,
    enqueue_enabled, dequeue_enabled 
from 
    dba_queues 
where
    owner = '&1';


prompt " Advanced Queues Tables"

select 
    queue_table,type,object_type,sort_order 
from 
    dba_queue_tables
where 
    owner = '&1';


prompt " Schedules "
set wrap off
col schema form a10
col qname form a15
col destination form a20
col last_error_msg form a80
select schema, qname, destination,SCHEDULE_DISABLED, last_error_date, last_error_time, last_error_msg
  from dba_queue_schedules
/

col address for a80
SELECT queue_name, consumer_name, address, protocol, delivery_mode,
queue_to_queue
FROM dba_queue_subscribers;

prompt " OS PIDs Corresponding to Job Queue Processes"
select p.SPID, p.PROGRAM 
from V$PROCESS p, DBA_JOBS_RUNNING jr, V$SESSION s, DBA_JOBS j 
where s.SID=jr.SID 
and s.PADDR=p.ADDR 
and jr.JOB=j.JOB
and j.WHAT like '%sys.dbms_aqadm.aq$_propaq(job)%';


col PROGRAM for a30
select p.SPID, p.PROGRAM, j.JOB_name
from v$PROCESS p, DBA_SCHEDULER_RUNNING_JOBS jr, V$SESSION s,
DBA_SCHEDULER_JOBS j 
where s.SID=jr.SESSION_ID 
and s.PADDR=p.ADDR
and jr.JOB_name=j.JOB_NAME 
and j.JOB_NAME like '%AQ_JOB$_%';
