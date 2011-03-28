--------------------------------------------------------------------------------                                                                                                      
--                                                                                                                                                                                    
-- File name:   eph.sql
-- Purpose:     display explain plan history and the PLAN_HASH_VALUE of
--              each change of the exec plan
--                                                                                                                                                                                    
-- Author:      Jeremy Baumont
-- Copyright:   (c) http://www.jeremy.baumont.org
--                                                                                                                                                                                    
-- Usage:       @eph <sql_id>
--              @eph 881tdtvd4gh68                                                                                                                                                                     
--------------------------------------------------------------------------------




prompt "Explain Plan History"

select sql_id, PLAN_HASH_VALUE, to_char(timestamp,'DD-MON-YYYY HH24:MI:SS')
from DBA_HIST_SQL_PLAN where sql_id='&1'
;

prompt "Current Explain Plan"

SELECT tf.* FROM DBA_HIST_SQLTEXT ht, table
(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf
WHERE ht.sql_id='&1';
