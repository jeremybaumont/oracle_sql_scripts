set lines 1000
col username for a25
col machine for a25
col sid for 999999999
col serial# for 99999999999


prompt Details of open cursors per sessions
prompt

select a.value, s.username, s.sid, s.serial#,s.username,s.machine, s.status
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic# and s.sid=a.sid
and b.name = 'opened cursors current'
order by  a.value;

prompt Summary of open cursors
prompt

select sum(a.value) total_cur, avg(a.value) avg_cur, max(a.value) max_cur,
s.username, s.machine
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#  and s.sid=a.sid
and b.name = 'opened cursors current'
group by s.username, s.machine
order by 1 desc;

col sid for 99999999
col  cursor_type for a40

prompt open cursors type and numbers per SID
prompt
select * from
(
select sid, cursor_type, count(*) as num_open_cursors from v$open_cursor 
group by sid, cursor_type
order by num_open_cursors desc
)
where  rownum <=20
/


col sql_text for a80
prompt Open cursors numbers per sql text per cursor type 
prompt
select * from
(select  sql_text, cursor_type,  count(*) as num_open_cursors from
v$open_cursor 
group by  sql_text, cursor_type 
order by  num_open_cursors desc
) where rownum <= 10
/

prompt Open cursors numbers per sql id per cursor type
prompt
select * from
(select  sql_id, cursor_type,  count(*) as num_open_cursors from
v$open_cursor 
group by  sql_id, cursor_type 
order by  num_open_cursors desc
) where rownum <= 10
/


prompt Open cursors numbers per sql id per cursor type in the last hour
prompt
select * from
(select  sql_id, cursor_type,  count(*) as num_open_cursors from
v$open_cursor 
where LAST_SQL_ACTIVE_TIME > sysdate -1/24
group by  sql_id, cursor_type 
order by  num_open_cursors desc
) where rownum <= 10
/
