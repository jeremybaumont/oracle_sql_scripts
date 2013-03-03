-- File name:   high_water_mark.sql
-- Purpose:     display information about high water mark 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License, Version 2.0
--
-- Usage:       @high_water_mark.sql
--------------------------------------------------------------------------------

select uts.table_name, uts.blocks                                     blks_used
      ,uts.avg_space
      ,uts.num_rows
      ,uts.avg_row_len
      ,uts.empty_blocks                               empty_blks
      ,usse.blocks                                    alloc_blks
      ,greatest(uts.blocks,1)/greatest(usse.blocks,1) pct_hwm
      ,uts.num_rows*uts.avg_row_len                   data_in_bytes
      ,(uts.num_rows*uts.avg_row_len)/8192            data_in_blks
      ,((uts.num_rows*uts.avg_row_len)/8192)*1.25     mod_data_in_blks
      ,(((uts.num_rows*uts.avg_row_len)/8192)*1.25)/usse.blocks pct_spc_used
from dba_tab_statistics uts
    ,dba_segments       usse
where uts.table_name ='&1'
and   uts.table_name=usse.segment_name
/

