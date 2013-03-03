-- File name:   show_sched_job.sql
-- Purpose:     display information about scheduler jobs 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @show_sched_job
--------------------------------------------------------------------------------


undefine sched_job_name

set lines 666
prompt -- Enter the scheduler job name:
set termout off
select '&&sched_job_name' from dual;
set termout on

prompt
prompt -- Check is the job is disable
select 
	job_name, 
	state 
from 
	dba_scheduler_jobs 
where 
	job_name in ('&&sched_job_name');

col schedule_name for a35
prompt
prompt -- Display job details
select 
	owner, job_name 
	program_name,
	schedule_name,
	schedule_type,
	job_class,
	restartable,
	state
from
	dba_scheduler_jobs
where
	job_name in ('&&sched_job_name');
	
set termout off
column prog new_value prog noprint
select program_name prog 
from
	dba_scheduler_jobs
where
	job_name = '&&sched_job_name';

column schedule new_value schedule noprint
select schedule_name schedule
from 
	dba_scheduler_jobs
where
	job_name = '&&sched_job_name';
set termout on


col program_action for a80
set lines 666
prompt
prompt -- Display the program details.
SELECT 
	owner, 
	program_name, 
	enabled, 
	program_action
FROM 
	dba_scheduler_programs
WHERE
	program_name in ('&&prog');

col repeat_interval for a80
col start_date for a35
prompt
prompt -- Display the schedule details.
SELECT 
	owner, 
	schedule_name,
	schedule_type,
	start_date,
	repeat_interval 
FROM 
	dba_scheduler_schedules 
where 
	schedule_name in ('&&schedule');

prompt
prompt -- Display the window group details.
SELECT 
	window_group_name, enabled, number_of_windows
FROM   
	dba_scheduler_window_groups
where window_group_name in ('&&schedule');


prompt
prompt -- Display the window group members.
SELECT window_group_name, window_name
FROM   dba_scheduler_wingroup_members
where window_group_name in ('&&schedule');

prompt
prompt -- Display the window details.
SELECT 
	window_name, resource_plan, enabled, active,repeat_interval
FROM   
	dba_scheduler_windows
where window_name in (
SELECT  window_name
FROM   dba_scheduler_wingroup_members
where window_group_name in ('&&schedule')
);
