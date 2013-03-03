-- File name:   mount_files_space.sql
-- Purpose:     display filesystem space usage according to mount points 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
-- Usage:       @mount_files_space.sql
--------------------------------------------------------------------------------

col "Datafiles Size Mb" for 999G999G999  
col "Redo Log Size Mb" for 999999999  
col "Control File Size Mb" for 999999999  
col "Total Size Mb" for 999999999.99 

prompt  *********************************************************
prompt ************** Space Usage per type of files *************
prompt  *********************************************************

select
    DF.TOTAL/1048576 "DataFile Size Mb",
    LOG.TOTAL/1048576 "Redo Log Size Mb",
    CONTROL.TOTAL/1048576 "Control File Size Mb",
    (DF.TOTAL + LOG.TOTAL + CONTROL.TOTAL)/1048576 "Total Size Mb" from dual,
    (select sum(a.bytes) TOTAL from dba_data_files a) DF,
    (select sum(b.bytes) TOTAL from v$log b) LOG,
    (select c.num * d.value * (1 + 2 * sum(ceil(record_size * records_total / (d.value - 24)))) total from sys.v_$controlfile_record_section,
    (select value from v$parameter where name = 'db_block_size' ) d, (select count(*) as num from v$controlfile) c group by (d.value, c.num)) CONTROL
/


prompt  *********************************************************
prompt ************** Space per OFA mount points *****************
prompt  *********************************************************

col mount for a84
col "Size Mb" for 999999999.99

select
--    df.mount, log.mount, control.mount,
--    DF.TOTAL/1048576 "DataFile Size Mb",
--    LOG.TOTAL/1048576 "Redo Log Size Mb",
--    CONTROL.TOTAL/1048576 "Control File Size Mb",
--    (DF.TOTAL + LOG.TOTAL + CONTROL.TOTAL)/1048576 "Total Size Mb" 
mount, sum(total/1048576 ) "Size Mb"
from( 
    (
        select 
            sum(a.bytes) TOTAL, 
            substr(a.file_name,0, instr(a.file_name, '/', 1, 2) -1)  as MOUNT 
        from 
            dba_data_files a 
        group by  substr(a.file_name,0, instr(a.file_name, '/', 1, 2) -1) 
    )  
union    (
        select 
            sum(b.bytes) TOTAL, 
            substr(l.member,0, instr(l.member, '/', 1, 2) -1)  as MOUNT 
        from 
            v$log b, 
            v$logfile l 
        where 
            l.group# = b.group# 
        group by  substr(l.member,0, instr(l.member, '/', 1, 2) -1)
    ) 
union    (
    select 
        c.num * d.value * (1 + 2 * sum(ceil(record_size * records_total / (d.value - 24)))) total, 
        c.mount as MOUNT 
    from                                                                                                                                                                             
        sys.v_$controlfile_record_section,                                                                                                                                            
        (select value from v$parameter where name = 'db_block_size' ) d,                                                                                                              
        (select count(*) as num,substr(name,0, instr(name, '/', 1, 2) -1) as mount from v$controlfile group by substr(name,0, instr(name, '/', 1, 2) -1)) c                                                                
    group by (d.value, c.num, c.mount)
    ) 
) mount_space
group by mount 
/

