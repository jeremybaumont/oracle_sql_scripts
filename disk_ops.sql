-- File name:   disk_ops.sql
-- Purpose:     display disk file operations 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @disk_ops  <OWNER>
--------------------------------------------------------------------------------

col file_type for a20
col file_operation for a20
select
    decode(p3,0 ,'Other',
              1 ,'Control File',
              2 ,'Data File',
              3 ,'Log File',
              4 ,'Archive Log',
              6 ,'Temp File',
              9 ,'Data File Backup',
              10,'Data File Incremental Backup',
              11,'Archive Log Backup',
              12,'Data File Copy',
              17,'Flashback Log',
              18,'Data Pump Dump File',
                  'unknown '||p1)  file_type,
    decode(p1,1 ,'file creation',
              2 ,'file open',
              3 ,'file resize',
              4 ,'file deletion',
              5 ,'file close',
              6 ,'wait for all aio requests to finish',
              7 ,'write verification',
              8 ,'wait for miscellaneous io (ftp, block dump, passwd file)',
              9 ,'read from snapshot files',
                 'unknown '||p3) file_operation,
    decode(p3,2,-1,p2) file#,
    count(*)
from dba_hist_active_sess_history
where event ='Disk file operations I/O'
group by p1,p3,
    decode(p3,2,-1,p2)
/
