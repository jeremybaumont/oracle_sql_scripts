column day format a10
column Switches_per_day format 9999
column 00 format 999
column 01 format 999
column 02 format 999
column 03 format 999
column 04 format 999
column 05 format 999
column 06 format 999
column 07 format 999
column 08 format 999
column 09 format 999
column 10 format 999
column 11 format 999
column 12 format 999
column 13 format 999
column 14 format 999
column 15 format 999
column 16 format 999
column 17 format 999
column 18 format 999
column 19 format 999
column 20 format 999
column 21 format 999
column 22 format 999
column 23 format 999

select to_char(first_time,'DD-MON') day,
sum(decode(to_char(first_time,'hh24'),'00',1,0)) "00",
sum(decode(to_char(first_time,'hh24'),'01',1,0)) "01",
sum(decode(to_char(first_time,'hh24'),'02',1,0)) "02",
sum(decode(to_char(first_time,'hh24'),'03',1,0)) "03",
sum(decode(to_char(first_time,'hh24'),'04',1,0)) "04",
sum(decode(to_char(first_time,'hh24'),'05',1,0)) "05",
sum(decode(to_char(first_time,'hh24'),'06',1,0)) "06",
sum(decode(to_char(first_time,'hh24'),'07',1,0)) "07",
sum(decode(to_char(first_time,'hh24'),'08',1,0)) "08",
sum(decode(to_char(first_time,'hh24'),'09',1,0)) "09",
sum(decode(to_char(first_time,'hh24'),'10',1,0)) "10",
sum(decode(to_char(first_time,'hh24'),'11',1,0)) "11",
sum(decode(to_char(first_time,'hh24'),'12',1,0)) "12",
sum(decode(to_char(first_time,'hh24'),'13',1,0)) "13",
sum(decode(to_char(first_time,'hh24'),'14',1,0)) "14",
sum(decode(to_char(first_time,'hh24'),'15',1,0)) "15",
sum(decode(to_char(first_time,'hh24'),'16',1,0)) "16",
sum(decode(to_char(first_time,'hh24'),'17',1,0)) "17",
sum(decode(to_char(first_time,'hh24'),'18',1,0)) "18",
sum(decode(to_char(first_time,'hh24'),'19',1,0)) "19",
sum(decode(to_char(first_time,'hh24'),'20',1,0)) "20",
sum(decode(to_char(first_time,'hh24'),'21',1,0)) "21",
sum(decode(to_char(first_time,'hh24'),'22',1,0)) "22",
sum(decode(to_char(first_time,'hh24'),'23',1,0)) "23",
count(to_char(first_time,'MM-DD')) Switches_per_day
from v$log_history
where trunc(first_time) between trunc(sysdate) - 6 and trunc(sysdate)
group by to_char(first_time,'DD-MON') 
order by to_char(first_time,'DD-MON') ;

