-- File name:   blocked.sql
-- Purpose:     display current locks and blocks 
--
-- Usage:       @blocked
--------------------------------------------------------------------------------



prompt Currently locked objects:
col U_NAME for a20
col OBJ_OWNER for a20
col object_name for a20
col object_type for a20
col osuser for a20
col status for a15
col mode_held for a20

 
SELECT username U_NAME, owner OBJ_OWNER,
object_name, object_type, s.osuser,
DECODE(l.block,
  0, 'Not Blocking',
  1, 'Blocking',
  2, 'Global') STATUS,
  DECODE(v.locked_mode,
    0, 'None',
    1, 'Null',
    2, 'Row-S (SS)',
    3, 'Row-X (SX)',
    4, 'Share',
    5, 'S/Row-X (SSX)',
    6, 'Exclusive', TO_CHAR(lmode)
  ) MODE_HELD
FROM gv$locked_object v, dba_objects d,
gv$lock l, gv$session s
WHERE v.object_id = d.object_id
AND (v.object_id = l.id1)
AND v.session_id = s.sid
ORDER BY username, session_id;
 
 
PROMPT List current locks
col mode_requested for a20
col blocking_others for a20
 
SELECT session_id,lock_type, 
mode_held, 
mode_requested, 
blocking_others, 
lock_id1
FROM dba_lock l
WHERE lock_type 
NOT IN ('Media Recovery', 'Redo Thread');
 
 
prompt List objects that have been  locked for 60 seconds or more: 
col "WAITING User" for a20
col "WAITING Program" for a20
col "WAITING Client" for a20
col "HOLDING User" for a20
col "HOLDING Program" for a20
col "HOLDING Client" for a20
col WSID for a10 
col WPID for 9999999
col HSID for a10
col HPID for 9999999
col "OS User" for a15
col "HOLDING Object" for a25

 
SELECT SUBSTR(TO_CHAR(w.session_id),1,5) WSID, p1.spid WPID,
SUBSTR(s1.username,1,12) "WAITING User",
SUBSTR(s1.osuser,1,8) "OS User",
--SUBSTR(s1.program,1,20) "WAITING Program",
--s1.client_info "WAITING Client",
SUBSTR(TO_CHAR(h.session_id),1,5) HSID, p2.spid HPID,
SUBSTR(s2.username,1,12) "HOLDING User",
SUBSTR(s2.osuser,1,8) "OS User",
--SUBSTR(s2.program,1,20) "HOLDING Program",
--s2.client_info "HOLDING Client",
o.object_name "HOLDING Object"
FROM gv$process p1, gv$process p2, gv$session s1,
gv$session s2, dba_locks w, dba_locks h, dba_objects o
WHERE w.last_convert > 60
AND h.mode_held != 'None'
AND h.mode_held != 'Null'
AND w.mode_requested != 'None'
AND s1.row_wait_obj# = o.object_id
AND w.lock_type(+) = h.lock_type
AND w.lock_id1(+) = h.lock_id1
AND w.lock_id2 (+) = h.lock_id2
AND w.session_id = s1.sid (+)
AND h.session_id = s2.sid (+)
AND s1.paddr = p1.addr (+)
AND s2.paddr = p2.addr (+)
ORDER BY w.last_convert DESC;
