-- File name:   objects_keep_pool.sql
-- Purpose:     display objects in keep pool in the buffer cache 
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
-- Usage:       @objects_keep_pool.sql
--------------------------------------------------------------------------------

select 
    name, block_size, current_size
from v$buffer_pool
where
    name = 'KEEP';

SELECT ds.buffer_pool, SUBSTR(do.object_name,1,9) OBJECT_NAME,
ds.blocks OBJECT_BLOCKS, COUNT(*) CACHED_BLOCKS
FROM dba_objects do, dba_segments ds, v$bh v
WHERE do.data_object_id=V.OBJD
AND do.owner=ds.owner(+)
AND do.object_name=ds.segment_name(+)
AND DO.OBJECT_TYPE=DS.SEGMENT_TYPE(+)
AND ds.buffer_pool IN ('KEEP','RECYCLE')
GROUP BY ds.buffer_pool, do.object_name, ds.blocks
ORDER BY do.object_name, ds.buffer_pool;
