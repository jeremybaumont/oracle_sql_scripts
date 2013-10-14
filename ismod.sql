SELECT name,
(
    CASE WHEN ISSES_MODIFIABLE='TRUE' 
	THEN 'Yes'
    ELSE 'No'
END
) AS "Session Modifiable",
(
    CASE WHEN ISSYS_MODIFIABLE='IMMEDIATE' THEN 'With Immediate Effect'
WHEN ISSYS_MODIFIABLE='DEFERRED' THEN 'New Sessions'
ELSE 'No'
END) AS "System Modifiable",
(CASE WHEN ISINSTANCE_MODIFIABLE='TRUE' THEN 'Yes'
ELSE 'No'
END) AS "Instance Modifiable"
FROM v$parameter
WHERE name like '%&parameter_name%'
;
