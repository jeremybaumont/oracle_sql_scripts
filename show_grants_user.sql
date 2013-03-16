-- File name:   show_grants_user.sql 
-- Purpose:     display grants of an application user 
-- Author:      Laurent Schneider 
--                                                                                      
-- Usage:       @show_grants_user.sql <USERNAME>
--------------------------------------------------------------------------------

COL roles FOR a60
COL table_name FOR a30
col privilege for a9
set lin 200 trims on pages 0 emb on hea on newp none

  SELECT *
    FROM (    SELECT CONNECT_BY_ROOT grantee grantee,
                     privilege,
                     REPLACE (
                        REGEXP_REPLACE (SYS_CONNECT_BY_PATH (granteE, '/'),
                                        '^/[^/]*'),
                        '/',
                        ' --> ')
                        ROLES,
                     owner,
                     table_name,
                     column_name
                FROM (SELECT PRIVILEGE,
                             GRANTEE,
                             OWNER,
                             TABLE_NAME,
                             NULL column_name
                        FROM DBA_TAB_PRIVS
                       WHERE owner NOT IN
                                ('SYS',
                                 'SYSTEM',
                                 'WMSYS',
                                 'SYSMAN',
                                 'MDSYS',
                                 'ORDSYS',
                                 'XDB',
                                 'WKSYS',
                                 'EXFSYS',
                                 'OLAPSYS',
                                 'DBSNMP',
                                 'DMSYS',
                                 'CTXSYS',
                                 'WK_TEST',
                                 'ORDPLUGINS',
                                 'OUTLN',
                                 'ORACLE_OCM',
                                 'APPQOSSYS')
                      UNION ALL
                      SELECT PRIVILEGE,
                             GRANTEE,
                             OWNER,
                             TABLE_NAME,
                             column_name
                        FROM DBA_COL_PRIVS
                       WHERE owner NOT IN
                                ('SYS',
                                 'SYSTEM',
                                 'WMSYS',
                                 'SYSMAN',
                                 'MDSYS',
                                 'ORDSYS',
                                 'XDB',
                                 'WKSYS',
                                 'EXFSYS',
                                 'OLAPSYS',
                                 'DBSNMP',
                                 'DMSYS',
                                 'CTXSYS',
                                 'WK_TEST',
                                 'ORDPLUGINS',
                                 'OUTLN',
                                 'ORACLE_OCM',
                                 'APPQOSSYS')
                      UNION ALL
                      SELECT GRANTED_ROLE,
                             GRANTEE,
                             NULL,
                             NULL,
                             NULL
                        FROM DBA_ROLE_PRIVS
                       WHERE GRANTEE NOT IN
                                ('SYS',
                                 'SYSTEM',
                                 'WMSYS',
                                 'SYSMAN',
                                 'MDSYS',
                                 'ORDSYS',
                                 'XDB',
                                 'WKSYS',
                                 'EXFSYS',
                                 'OLAPSYS',
                                 'DBSNMP',
                                 'DMSYS',
                                 'CTXSYS',
                                 'WK_TEST',
                                 'ORDPLUGINS',
                                 'OUTLN',
                                 'ORACLE_OCM',
                                 'APPQOSSYS')) T
          START WITH grantee IN (SELECT username FROM dba_users)
          CONNECT BY NOCYCLE PRIOR PRIVILEGE = GRANTEE)
   WHERE table_name IS NOT NULL AND grantee != OWNER
AND grantee like '%&1%'
ORDER BY grantee,
         owner,
         table_name,
         column_name,
         privilege;

