set pagesize 400
set linesize 140
col name for a25
col program for a50
col username for a12
col osuser for a12
SELECT a.inst_id, a.sid, c.username, c.osuser, c.program, b.name,
a.value, d.used_urec, d.used_ublk
FROM gv$sesstat a, v$statname b, gv$session c, gv$transaction d
WHERE a.statistic# = b.statistic#
AND a.inst_id = c.inst_id
AND a.sid = c.sid
AND c.inst_id = d.inst_id
AND c.saddr = d.ses_addr
AND a.statistic# = 284
AND a.value > 0
ORDER BY a.value DESC


-- set pagesize 400
-- set linesize 140
-- col name for a25
-- col program for a50
-- col username for a12
-- col osuser for a12
-- SELECT a.inst_id, a.sid, c.username, c.osuser, c.program, b.name,
-- a.value, d.used_urec, d.used_ublk
-- FROM gv$sesstat a, v$statname b, gv$session c, gv$transaction d
-- WHERE a.statistic# = b.statistic#
-- AND a.inst_id = c.inst_id
-- AND a.sid = c.sid
-- AND c.inst_id = d.inst_id
-- AND c.saddr = d.ses_addr
-- AND b.name = 'undo change vector size'
-- AND a.value > 0
-- ORDER BY a.value DESC
