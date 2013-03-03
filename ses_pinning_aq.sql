--------------------------------------------------------------------------------     
--    
-- File name:   ses_pinning_aq.sql
-- Purpose:     identify user sessions pinning Advanced Queue objects
--
--		Used to troubleshoot on OWB the ORA-04020 deadlock
--		detected while trying to lock object or ORA-04021
--		timeout occured while waiting to lock object
--		See Oracle documentation for details:
--              http://download.oracle.com/docs/cd/B31080_01/doc/install.102/b28224/diagnose_06.htm              
--
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
--                                                                                  
-- Usage:       @ses_pinning_aq.sql
--------------------------------------------------------------------------------
column s.sid format a5
column s.serial# format a8
column s.username format a10
column objectname format a10


prompt " User session pinning Advanced Queue objets "
select distinct (s.sid),
    s.serial#,
    s.username,
    x.kglnaobj as objectname
from 
    dba_kgllock l,
    v$session s,
    x$kgllk x
where
    l.kgllktype = 'Pin' and
    s.saddr = l.kgllkuse and
    s.saddr = x.kgllkuse and
    x.kglnaobj in ('DBMS_AQ', 'DBMS_AQADM');

prompt " Alter kill sqls corresponding to kill previous sessions "
set heading off
set feedback off
prompt " spooling in /var/tmp/kill_ses_pinning_aq.sql "
spool /var/tmp/kill_ses_pinning_aq.sql
select 
	'ALTER SYSTEM KILL SESSION '''
	|| ssid 
	||','
	||sserial# || ''';'
from(
select distinct(s.sid) as ssid,
	s.serial# as sserial#
from
    dba_kgllock l,
    v$session s,
    x$kgllk x
where
    l.kgllktype = 'Pin' and
    s.saddr = l.kgllkuse and
    s.saddr = x.kgllkuse and
    x.kglnaobj in ('DBMS_AQ', 'DBMS_AQADM')
);
spool off
