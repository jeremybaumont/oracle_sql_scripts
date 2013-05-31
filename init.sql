--------------------------------------------------------------------------------
--
-- Name:	init.sql
-- Purpose:	Initializes sqlplus variables for 156 character terminal
--		width and other settings.
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Other:	Some settings Windows specific
--		Assumes SQLPATH variable set to point to TPT script directory
--
--------------------------------------------------------------------------------

-- this must be here to avoid logon problems when SQLPATH env variable is unset
def SQLPATH=""


-- set SQLPATH variable to either Unix or Windows format

-- def SQLPATH=$SQLPATH -- (Unix)
def SQLPATH=%SQLPATH%


-- def _start=start   -- Windows
def _start=firefox -- Unix/Linux
-- def _start=open -- MacOS

def _delete="del"

def _tpt_tempdir=&SQLPATH/tmp

-- some internal variables required for TPT scripts

define _ti_sequence=0
define _tptmode=normal
define _xt_seq=0

define all='"select /*+ no_merge */ sid from v$session"'

-- you should change linesize to match terminal width - 1 only 
-- if you don't have a terminal with horizontal scrolling
-- capability (cmd.exe and Terminator terminal do have horizontal scrolling)

set linesize 999

-- set truncate after linesize on

-- set truncate on

-- set pagesize larger to avoid repeting headings

set pagesize 5000

-- fetch 10000000 bytes of long datatypes. good for
-- querying DBA_VIEWS and DBA_TRIGGERS

set long 10000000
set longchunksize 10000000

-- larger arraysize for faster fetching of data
-- note that arraysize can affect outcome of experiments
-- like buffer gets for select statements etc.

set arraysize 500

-- normally I keep this commented out, otherwise
-- a DBMS_OUTPUT.GET_LINES call is made after all
-- PL/SQL executions from sqlplus. this may distort
-- execution statistics for experiments

--set serveroutput on size unlimited

-- to have less garbage on screen

set verify off

-- to trim trailing spaces from spool files

set trimspool on

-- to trim trailing spaces from screen output

set trimout on

-- don't use tabs instead of spaces for "wide blanks"
-- this can mess up the vertical column locations in output

set tab off

-- this makes describe command better to read and more
-- informative in case of complex datatypes in columns

set describe depth 1 linenum on indent on

-- you can make sqlplus run any command as your editor
-- I could use "start notepad" on windows if you want to 
-- return control back to sqlplus immediately after launching
-- notepad (so that you can continue typing in sqlplus

    --define _editor="notepad"  
    define _editor="/usr/bin/vi"
    --	define _external_editor="/Applications/Terminator.app/Contents/MacOS/Terminator vi "  

    -- assign the tracefile name to trc variable

    def trc=unknown

    column tracefile noprint new_value trc

    -- its nice to have termout off here as otherwise this would be
    -- displayed on the screen
    set termout off

    select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
    (select spid||case when traceid is not null then '_'||traceid else null end
	from v$process where addr = (select paddr from v$session
	    where sid = (select sid from v$mystat
		where rownum = 1
	    )
	)
    ) || '.trc' tracefile
    from v$parameter where name = 'user_dump_dest';

    -- make default date format nicer

    alter session set nls_date_format = 'YYYYMMDD HH24:MI:SS';

    -- include username and connect identifier in prompt

    --	column pr new_value _pr
    --	select initcap('&_user@&_connect_identifier> ') pr from dual;
    --	set sqlprompt "&_pr"
    --	columqn _pr clear

COLUMN  host_col  NEW_VALUE host_col

SELECT  ( 
	CASE
        when sys_context('USERENV', 'DB_NAME') like '%PRO' 
	THEN  chr(27)||'[40m'||chr(27)||'[1;31m'
    	else 
		CASE 
		WHEN sys_context('USERENV', 'DB_NAME') like '%XPR'
		THEN chr(27)||'[40m'||chr(27)||'[1;36m' 
		ELSE chr(27)||'[40m'||chr(27)||'[1;32m'
		END
    	END) host_col
FROM dual;

COLUMN  user_col  NEW_VALUE user_col

SELECT  (
        CASE
        when sys_context('USERENV', 'SESSION_USER') in ( 'SBP_DBA')
        THEN chr(27)||'[40m'||chr(27)||'[1;33m'||sys_context('USERENV', 'SESSION_USER')||chr(27)||'[0m'
        else chr(27)||'[40m'||chr(27)||'[1;32m'||sys_context('USERENV', 'SESSION_USER')||chr(27)||'[0m'
        END) user_col
FROM dual;


COLUMN end_col new_value end_col
SELECT chr(27)||'[0m' end_col from dual;

define _myprompt="&user_col@&host_col&_connect_identifier&end_col"

set sqlprompt "&_myprompt > "
--set sqlprompt "&user_col '@'&host_col _connect_identifier&end_col > "
set time on


-- format some more columns for common DBA queries

col first_change# for 99999999999999999
col next_change# for 99999999999999999
col checkpoint_change# for 99999999999999999
col resetlogs_change# for 99999999999999999
col plan_plus_exp for a100
col value_col_plus_show_param ON HEADING  'VALUE'  FORMAT a100

-- set html format

@@htmlset nowrap "&_user@&_connect_identifier report"

-- set seminar logging file

DEF _tpt_tempfile=sqlplus_tmpfile

col seminar_logfile new_value seminar_logfile
col tpt_tempfile new_value _tpt_tempfile

select 
to_char(sysdate, 'YYYYMMDD-HH24MISS') seminar_logfile 
, instance_name||'-'||to_char(sysdate, 'YYYYMMDD-HH24MISS') tpt_tempfile
from v$instance;

def seminar_logfile=&SQLPATH/logs/&_tpt_tempfile..log

-- spool sqlplus output
-- spool &seminar_logfile append

set editfile afiedit.sql

-- reset termout back to normal

set termout on

