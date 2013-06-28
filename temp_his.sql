-- SQL to find TOP lit of sessions ( available from ACTIVE_SESS_HISTORY) that used more than 100MB:
col GB_TEMP_USED for 999999
col END_INTERVAL_TIME for a15
col sample_time for a15
col program for a15
col module for a15
col machine for a15
col sql_id for a20

prompt "Enter start and end times in format YYYY-MON-DD HH24:MI:"

select  
  st.session_id, 
  max(st.TEMP_SPACE_ALLOCATED)/1024/1024/1024 as GB_TEMP_USED
from 
  DBA_HIST_ACTIVE_SESS_HISTORY ST, dba_hist_snapshot dhs
where 1=1
  and st.snap_id = dhs.snap_id 
  and st.TEMP_SPACE_ALLOCATED > 100*1024
  and dhs.begin_interval_time between TO_DATE('&&start_time', 'YYYY-MON-DD HH24:MI')
        and  TO_DATE('&&end_time', 'YYYY-MON-DD HH24:MI')
group by 
  st.instance_number, st.session_id
order by 
  max(st.TEMP_SPACE_ALLOCATED) desc;

-- Details on the session that consumed the TEMP

prompt "Choose sid of the suspected temper:"
col snap_id for 9999999
col GB_TEMP_USED for 999
col end_interval_time for a26
col module for a26
col machine for a18
col program for a26

set lines 3000
select 
  sh.snap_id,
  st.TEMP_SPACE_ALLOCATED/1024/1024/1024 as GB_TEMP_USED,
  sh.END_INTERVAL_TIME,
  st.program, st.module,u.username, st.machine, st.sql_id
from 
  DBA_HIST_ACTIVE_SESS_HISTORY ST, dba_hist_snapshot sh,dba_users u
where 1=1
and st.user_id = u.user_id
and st.SNAP_ID=sh.SNAP_ID and st.DBID=sh.DBID and st.INSTANCE_NUMBER=sh.INSTANCE_NUMBER
and st.session_id=&temper_sid and st.instance_number=1
  and sh.begin_interval_time between TO_DATE('&&start_time', 'YYYY-MON-DD HH24:MI')
        and  TO_DATE('&&end_time', 'YYYY-MON-DD HH24:MI')
order by st.SAMPLE_TIME;
