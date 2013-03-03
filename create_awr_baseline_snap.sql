-- File name:   create_awr_baseline_snap.sql                                                            
-- Purpose:     create a static AWR baseline with snap id
--                                                                                                     
-- Author:      Jeremy Baumont                                                                        
-- Copyright:   Apache License v2.0                                                                  
-- Usage:       @create_awr_baseline_snap
-- Parameters:  start_snap_id: Start snapshot sequence number for the baseline
--              end_snap_id: End snapshot sequence number for the baseline
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

accept start_snap_id -
    prompt 'Enter value for start_snap_id (Default: 1): ' -
    default 1
accept end_snap_id -
    prompt 'Enter value for end_snap_id (Default: 2): ' -
    default 2
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
        start_snap_id => &&start_snap_id, 
        end_snap_id => &&end_snap_id, 
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
            || 'start_snap_id: ' ||'&&start_snap_id' || ' and end_snap_id: '
            || '&&end_snap_id' || '.');
        dbms_output.put_line(' ');

END;
/

undef start_snap_id
undef end_snap_id
undef baseline_name
undef dbid
undef expiration

set serveroutput off
set sqlblanklines off
set feedback on
