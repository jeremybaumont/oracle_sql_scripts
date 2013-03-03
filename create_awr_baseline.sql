--                                     
-- File name:   create_awr_baseline.sql 
-- Purpose:     create a static AWR baseline
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0       
-- Usage:       @create_awr_baseline
-- Parameters:  start_time: Start time for the baseline
--              end_time: End time for the baseline
--              baseline_name: Name of baseline
--              dbid: Database Identifier for baseline. If NULL, this takes 
--                      the database identifier for the local database. 
--                      Defaults to NULL.
--              expiration: Expiration in number of days for the baseline. If 
--                      NULL, then expiration is infinite, meaning do not drop 
--                      baseline ever. Defaults to NULL.
--------------------------------------------------------------------------------  
set feedback off
set sqlblanklines on

accept start_time -
    prompt 'Enter value for start_time (DD-MON-YYYY HH24:MI): ' -
    default '01-JAN-1970 00:00'
accept end_time -
    prompt 'Enter value for end_time (DD-MON-YYYY HH24:MI): ' -
    default '01-JAN-1970 01:00'
accept baseline_name -
    prompt 'Enter value for baseline name(Default: bl): ' -
    default 'bl'
accept dbid - 
    prompt 'Enter value for dbid (Default: dbid for local db): ' -
    default NULL
accept expiration -
    prompt 'Enter value for expiration (Default: infinite): ' -
    default NULL

set serveroutput on

DECLARE
    l_return NUMBER;
BEGIN
    l_return := DBMS_WORKLOAD_REPOSITORY.create_baseline(
        start_time => TO_DATE('&&start_time', 'DD-MON-YYYY HH24:MI'),
        end_time => TO_DATE('&&end_time', 'DD-MON-YYYY HH24:MI'),
        baseline_name => '&&baseline_name',
        dbid => &&dbid,
        expiration => &&expiration
    );

    dbms_output.put_line(' ');                                                                                                                                                        
    dbms_output.put_line('AWR baseline created with baseline id:  ' ||                                                                                                                
        l_return);                                                                                                                                                                    
    dbms_output.put_line(' '); 

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line(' ');
        dbms_output.put_line('ERROR: can not create AWR baseline for '
            || 'start_time: ' ||'&&start_time' || ' and end_time: '
            || '&&end_time' || '.');
        dbms_output.put_line(' ');

END;
/

undef start_time
undef end_time
undef baseline_name
undef dbid
undef expiration

set serveroutput off
set sqlblanklines off
set feedback on
