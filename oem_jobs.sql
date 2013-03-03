--                                                                                                                                                            
-- File name:   oem_job.sql
-- Purpose:     display a daily check of OEM job failures 
--                                                                                                                                                            
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0 
--                                                                                                                                                            
-- Usage:       @oem_job 
--------------------------------------------------------------------------------

set lines 330
col job_name format a55
col "EXECUTION_STATUS" format a20
col target_name format a45

SELECT
    to_char(  
        decode(
            lag(target_name) over(order by target_name),
            target_name, null, target_name
        )  
    ) target_name, job_name
FROM
(SELECT
        j.job_name,
        ma.target_name
--    t.target_name
--    DECODE(e.STATUS,
--	1, 'SCHEDULED',
--	2, 'RUNNING',
--	3, 'FAILED INIT',
--	4, 'FAILED',
--	5, 'SUCCEEDED',
--	6, 'SUSPENDED',
--	7, 'AGENT DOWN',
--	8, 'STOPPED',
--	9, 'SUSPENDED/LOCK',
--	10, 'SUSPENDED/EVENT',
--	11, 'SUSPENDED/BLACKOUT',
--	12, 'STOP PENDING',
--	13, 'SUSPEND PENDING',
--	14, 'INACTIVE',
--	15, 'QUEUED',
--	16, 'FAILED/RETRIED',
--	17, 'WAITING',
--	18, 'SKIPPED', STATUS) "EXECUTION_STATUS"
FROM
    MGMT_JOB_EXEC_SUMMARY e, 
    MGMT_JOB j,
    MGMT_TARGETS t,
    MGMT_JOB_TARGET jt,
  (
    select host_name,
            nvl(
                substr(target_name, 0, instr(target_name,'.') - 1) ,
                target_name) as target_name
    from sysman.mgmt_targets
    where target_type = 'oracle_database'
) ma
WHERE 
    e.STATUS NOT IN (1,5,14,15,18)
    AND ma.host_name = t.host_name
    AND e.END_TIME > sysdate - 1
    AND e.job_id (+) = j.job_id
    AND t.target_guid = jt.target_guid
    AND e.execution_id = jt.execution_id
GROUP BY j.job_name, ma.target_name
) 
/
