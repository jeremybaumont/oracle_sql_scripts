-- File name:   who_temp.sql
-- Purpose:     display current temp usage per user 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @who_temp
--------------------------------------------------------------------------------


col sid_serial for a10
col module for a20
col program for a20
col user for a15
col tablespace for a15
set lines 1000

Prompt "Summary"

SELECT S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
P.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
COUNT(*) statements
FROM v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE T.session_addr = S.saddr
AND S.paddr = P.addr
AND T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
P.program, TBS.block_size, T.tablespace
ORDER BY mb_used;

Prompt "With sql text detais"

-- With sql text
SELECT sysdate,a.username, a.sid, a.serial#, a.osuser, (b.blocks*d.block_size)/1048576 MB_used, c.sql_text
FROM v$session a, v$tempseg_usage b, v$sqlarea c,
     (select block_size from dba_tablespaces where tablespace_name='TEMP') d
    WHERE b.tablespace = 'TEMP'
    and a.saddr = b.session_addr
    AND c.address= a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND (b.blocks*d.block_size)/1048576 > 1024
    ORDER BY b.tablespace, 6 desc;
