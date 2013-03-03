-- File name:   i_struct_stats.sql
-- Purpose:     brief summary on the structure and statistics of an index
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
--                                                                                                                                                                                    
-- Usage:       @i_struct_stats <index_name>
--------------------------------------------------------------------------------

set lines 220
col num_rows for 999G999G999G999
col clustering_factor for 999G999G999G999
col leaf_block for 999G999G999G999

prompt "Summary structur metrics of the index"
select
    i.index_name,
    i.table_name,
    i.status,
    i.leaf_blocks,
    i.clustering_factor,
    i.num_rows,
    (i.blevel + 1) as height,
    i.partitioned,
    nvl(pi.partitioning_type,'NON APPLICABLE') as PARTITION_TYPE,
    nvl(pi.subpartitioning_type,'NON APPLICABLE') as SUBPARTITION_TYPE,
    nvl(pi.locality,'NON APPLICABLE') as LOCALITY
from
    dba_indexes i,
    dba_part_indexes pi
where
    i.index_name = pi.index_name (+) and
    i.index_name like '%&1%'
/

prompt "If you want to analyze the index run following script spooled"
prompt "but could consume a lot of resources and degrade performance"
prompt
set headinf off
set feedback off
prompt "spooling analyse script in /var/tmp/i_analyze.sql"
spool /var/tmp/i_analyse.sql    
select 'var owner varchar2(30);' from dual;
select 'select owner into :owner from dba_indexes where index_name = ''' || &1 ||''';' from dual;
select 'prompt "analyzing index with owner: "' from dual;
select 'print :owner;' from dual;
select 'analyze index :owner.' || &1 ||' validate structure;' from dual;
spool off

prompt "Summary statistics of the index"
prompt "Be careful, it will return no rows if index not analyzed"
select
    i.name,
    i.height,
    i.blocks,
    i.partition_name,
    i.lf_rows,
    i.del_lf_rows,
    i.rows_per_key,
    i.blks_gets_per_access
from
    index_stats i
where
    i.name like '%&1%'
/


