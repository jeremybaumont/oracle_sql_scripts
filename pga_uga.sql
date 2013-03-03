-- File name:   pga_uga.sql
-- Purpose:     display pga and uga information 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @pga_uga  <OWNER>
--------------------------------------------------------------------------------

/***********************************************************************
This script is used for monitoring UGA, PGA allocated.
From Oracle Metalink note: 469521.1
************************************************************************/

/***************************************************************************
query the historical information from v$sesstat,v$statname, v$session
and provide a way to monitor the UGA, PGA and Cursor usage per session.
****************************************************************************/

set pages500 lines110 trims on 
clear col 
col name format a30  
col username format a20 
break on username nodup skip 1 

select vses.username||':'||vsst.sid||','||vses.serial# username, vstt.name, max(vsst.value) value  
from v$sesstat vsst, v$statname vstt, v$session vses 
where vstt.statistic# = vsst.statistic# and vsst.sid = vses.sid and vstt.name in  
('session pga memory','session pga memory max','session uga memory','session uga memory max',  
'session cursor cache count','session cursor cache hits','session stored procedure space', 
'opened cursors current','opened cursors cumulative') and vses.username is not null 
group by vses.username, vsst.sid, vses.serial#, vstt.name order by vses.username, vsst.sid, vses.serial#, vstt.name; 
/

col name format a45
select name, value/(1024*1024) as Mb from v$PGASTAT where name like '%PGA%'
/
