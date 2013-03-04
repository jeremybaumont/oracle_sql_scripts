-- File name:   lock_his.sql
-- Purpose:     display history information of locks via ASH 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--                                                                                      
-- Usage:       @lock_his
--------------------------------------------------------------------------------


set lines 500
col sql_text for a70
col object_name for a25
col module for a20
col username for a20


prompt enter start and end times in format YYYY-MON-DD HH24:MI
-- select a.sample_id,a.sample_time,a.session_id,a.event,
-- a.session_state,a.event,a.sql_id,
-- a.blocking_session,a.blocking_session_status
-- from v$active_session_history a, dba_users u
-- where u.user_id = a.user_id
-- and 
--         a.sample_time between TO_DATE('&start_time', 'YYYY-MON-DD HH24:MI')
-- 	        and  TO_DATE('&end_time', 'YYYY-MON-DD HH24:MI')
-- order by a.sample_time
-- ;

WITH ash_query AS (
    SELECT substr(event,6,2) lock_type,program, h.module, h.action, object_name,
    SUM(time_waited)/1000 time_ms, COUNT( * ) waits, username, sql_text,
    RANK() OVER (ORDER BY SUM(time_waited) DESC)    AS time_rank,
    ROUND(SUM(time_waited) * 100 / SUM(SUM(time_waited))  OVER (), 2) pct_of_time
    FROM  v$active_session_history h
    JOIN  dba_users u  USING (user_id)
    LEFT OUTER JOIN dba_objects o
    ON (o.object_id = h.current_obj#)
    LEFT OUTER JOIN v$sql s USING (sql_id)
    WHERE event LIKE 'enq: %'
    AND sample_time between TO_DATE('&start_time', 'YYYY-MON-DD HH24:MI')
    and  TO_DATE('&end_time', 'YYYY-MON-DD HH24:MI')
    GROUP BY substr(event,6,2) ,program, h.module, h.action,object_name,  sql_text, username)
SELECT lock_type,module, username,  object_name, time_ms, pct_of_time, sql_text
FROM ash_query
WHERE time_rank < 11
ORDER BY time_rank;


select distinct a.sid "waiting sid",d.sql_text "waiting SQL",a.ROW_WAIT_OBJ#
"locked object",a.BLOCKING_SESSION "blocking sid",c.sql_text "SQL from blocking 
session" from v$session a, v$active_session_history b, v$sql c, v$sql d
where
a.sql_id=d.sql_id
and a.blocking_session=b.session_id
and c.sql_id=b.sql_id
and b.CURRENT_OBJ#=a.ROW_WAIT_OBJ#
and b.CURRENT_FILE#= a.ROW_WAIT_FILE#
AND b.sample_time between TO_DATE('&&start_time', 'YYYY-MON-DD HH24:MI')
    and  TO_DATE('&&end_time', 'YYYY-MON-DD HH24:MI')
and b.CURRENT_BLOCK#= a.ROW_WAIT_BLOCK#;
