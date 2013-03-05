-- SQL to find TOP lit of sessions ( available from ACTIVE_SESS_HISTORY) that used more than 100MB:

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

select 
  sh.snap_id,
  sh.END_INTERVAL_TIME,
  st.SAMPLE_TIME,
  st.TEMP_SPACE_ALLOCATED/1024/1024/1024,
  st.program, st.module, st.machine, st.sql_id
from 
  DBA_HIST_ACTIVE_SESS_HISTORY ST, dba_hist_snapshot sh
where 1=1
and st.SNAP_ID=sh.SNAP_ID and st.DBID=sh.DBID and st.INSTANCE_NUMBER=sh.INSTANCE_NUMBER
and st.session_id=&temper_sid and st.instance_number=1
  and sh.begin_interval_time between TO_DATE('&&start_time', 'YYYY-MON-DD HH24:MI')
        and  TO_DATE('&&end_time', 'YYYY-MON-DD HH24:MI')
order by st.SAMPLE_TIME;
