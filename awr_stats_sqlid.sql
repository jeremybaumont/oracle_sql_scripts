-- File name:   awr_stats_sqlid.sql
-- Purpose:     display historical awr stats for an sqlid
--                                                                                                                
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0 
--                                                                                                                
-- Usage:       @awr_stats_sqlid  <SQLID>
--------------------------------------------------------------------------------



prompt enter start and end times in format DD-MON-YYYY [HH24:MI]
 
column sample_end format a21
select to_char(min(s.end_interval_time),'DD-MON-YYYY DY HH24:MI') sample_end
, q.sql_id
, q.plan_hash_value
, sum(q.EXECUTIONS_DELTA) executions
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) pio_per_exec
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_exec
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.SQL_ID=trim('&sqlid.')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
and s.end_interval_time >= to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and s.begin_interval_time <= to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
and substr(to_char(s.end_interval_time,'DD-MON-YYYY DY HH24:MI'),13,2) like '%&hr24_filter.%'
group by s.snap_id
, q.sql_id
, q.plan_hash_value
order by s.snap_id, q.sql_id, q.plan_hash_value
/

