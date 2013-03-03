-- File name:   check_scn_health.sql
-- Purpose:     display information about the scn health 
--
--              display information about the scn health over the scn
--              headroom being the difference between current scn and
--              scn soft limit (number of seconds between now and 
--              1988/01/01 00:00:00 
--
-- Author:      Jeremy Baumont
-- Copyright:   Apache License v2.0
--
-- Usage:       @check_scn_health  
--------------------------------------------------------------------------------

set serveroutput on

DECLARE
   right_now TIMESTAMP; one_second_ago TIMESTAMP; one_day_ago TIMESTAMP; 
   soft_limit_date DATE DEFAULT TO_DATE('12:00:00 19880101','HH:MI:SS YYYYMMDD');
   scn1 INTEGER; scn2 INTEGER; scn3 INTEGER; scndiff INTEGER;
   scndiffaday INTEGER; 
   soft_limit INTEGER;
   indicator INTEGER;
   scnheadroom INTEGER;

    FUNCTION time_diff (
    DATE_1 IN DATE, DATE_2 IN DATE) RETURN NUMBER IS
 
    NDATE_1   NUMBER;
    NDATE_2   NUMBER;
    NSECOND_1 NUMBER(5,0);
    NSECOND_2 NUMBER(5,0);
 
    BEGIN
        NDATE_1 := TO_NUMBER(TO_CHAR(DATE_1, 'J'));
        NDATE_2 := TO_NUMBER(TO_CHAR(DATE_2, 'J'));
        NSECOND_1 := TO_NUMBER(TO_CHAR(DATE_1, 'SSSSS'));
        NSECOND_2 := TO_NUMBER(TO_CHAR(DATE_2, 'SSSSS'));
 
        RETURN (((NDATE_2 - NDATE_1) * 86400)+(NSECOND_2 - NSECOND_1));
    END time_diff;



BEGIN
-- Calculating soft limit
   soft_limit := time_diff(soft_limit_date, sysdate)*16384;
   dbms_output.put_line('Soft limit value of the SCNs is ' || soft_limit);

-- Get the current SCN.
   right_now := SYSTIMESTAMP;
   scn1 := TIMESTAMP_TO_SCN(right_now);
   dbms_output.put_line('Current SCN is ' || scn1);
   one_day_ago := right_now - 1;
   scn3 := TIMESTAMP_TO_SCN(one_day_ago);
   scndiffaday := (scn1 - scn3);

-- Get the SCN from exactly 1 day ago.
   one_second_ago := right_now - 1/3600;
   scn2 := TIMESTAMP_TO_SCN(one_second_ago);
   dbms_output.put_line('SCN from one_second_ago is ' || scn2);

-- Find an arbitrary SCN somewhere between one_second_ago and today.
-- (In a real program we would have stored the SCN at some significant
-- moment.)
   scndiff := (scn1 - scn2);
   dbms_output.put_line('SCN increase in the last second: ' || scndiff); 

-- Estimation before impact of the soft limit
   scnheadroom := soft_limit -scn1;
   indicator := scnheadroom/(16384*86400); 
   dbms_output.put_line('SCN Headroom: ' || scnheadroom); 
   dbms_output.put_line('Average SCN increase per second in the last day: ' || round(scndiffaday/86400) || ' should not be more that 16384.'); 
   dbms_output.put_line('Health Indicator: ' || indicator || ' should be more than 62.'); 

END;
/
