--------------------------------------------------------------------------------                                                                              
--                                                                                                                                                            
-- File name:   oem_alert.sql
-- Purpose:     display a daily check of OEM alerts
--                                                                                                                                                            
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0 
--                                                                                                                                                            
-- Usage:       @oem_alert 
--------------------------------------------------------------------------------

set lines 330
col target_name format a45
col message format a120

SELECT
    to_char(  
        decode(
            lag(alert_target_name) over(order by alert_target_name),
            alert_target_name, null, alert_target_name
        )  
    ) target_name, message 
FROM
(
SELECT  
DECODE (
substr(
  substr(
    t.target_name, 
    0, 
    decode(instr(t.target_name,':'),0,length(t.target_name),instr(t.target_name,':')-1)
  ),
  decode(instr(substr(
    t.target_name, 
    0, 
    decode(instr(t.target_name,':'),0,length(t.target_name),instr(t.target_name,':')-1)
  ),'_'), 0, 0, instr(substr(
    t.target_name, 
    0, 
    decode(instr(t.target_name,':'),0,length(t.target_name),instr(t.target_name,':')-1)
  ), '_') + 1 ),
  length(substr(
    t.target_name, 
    0, 
    decode(instr(t.target_name,':'),0,length(t.target_name),instr(t.target_name,':') -1)
  ))),
ma.host_name,ma.target_name,
substr(t.target_name, 0, instr(t.target_name,'.') - 1) )  as alert_target_name,
  c.message as message
FROM sysman.mgmt_targets t,
  sysman.mgmt_metrics m,
  sysman.mgmt_current_severity c,
  (
    select host_name,
            nvl(
                substr(target_name, 0, instr(target_name,'.') - 1) ,
                target_name) as target_name
    from sysman.mgmt_targets
    where target_type = 'oracle_database'
) ma
WHERE t.target_guid    = c.target_guid
AND ma.host_name       = t.host_name
AND m.metric_guid      = c.metric_guid
AND t.target_type      = m.target_type
AND t.type_meta_ver    = m.type_meta_ver
AND (t.category_prop_1 = m.category_prop_1
OR m.category_prop_1   = ' ')
AND (t.category_prop_2 = m.category_prop_2
OR m.category_prop_2   = ' ')
AND (t.category_prop_3 = m.category_prop_3
OR m.category_prop_3   = ' ')
AND (t.category_prop_4 = m.category_prop_4
OR m.category_prop_4   = ' ')
AND (t.category_prop_5 = m.category_prop_5
OR m.category_prop_5   = ' ')
  --and target_name = 'mdb01ykf'
AND --m.target_type = 'host'
  -- m.metric_column != 'pctAvailable'
  m.metric_name != 'invalid_objects'
  -- and m.metric_name != 'Response'
AND m.metric_name != 'UserAudit'
AND m.metric_name != 'alertLog'
AND NOT EXISTS
  (SELECT NULL
  FROM sysman.mgmt_blackout_state b
  WHERE collection_timestamp =
    (SELECT MAX(collection_timestamp)
    FROM sysman.mgmt_blackout_state x
    WHERE x.BLACKOUT_GUID = b.blackout_guid
    )
  AND blackout_code = 1
  AND b.target_guid = t.target_guid
  )
AND NOT EXISTS
  (SELECT NULL
  FROM sysman.mgmt_severity_annotation a
  WHERE a.severity_guid = c.severity_guid
  AND user_name        != '<SYSTEM>'
  )
AND c.collection_timestamp > sysdate - 1
ORDER BY alert_target_name
)
/
