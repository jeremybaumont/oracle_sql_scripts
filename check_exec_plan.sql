set lines 500
with sliders as (
    SELECT DISTINCT A.SQL_ID ,A.PLAN_HASH_VALUE , B.SQL_TEXT
    FROM V$SQL_PLAN A, V$SQL B
    WHERE A.SQL_ID IN (
	SELECT SQL_ID  FROM V$SQL_PLAN
	WHERE OBJECT_OWNER='SDD'
	AND TIMESTAMP>SYSDATE-1/24
	GROUP BY SQL_ID
	HAVING COUNT (DISTINCT PLAN_HASH_VALUE) >1)
    AND A.SQL_ID=B.SQL_ID
),
sliders_hist_sqlstat as (
SELECT
 ss.snap_id, ss.begin_interval_time, s.sql_id, s.plan_hash_value,
(s.elapsed_time_delta/decode(nvl(s.executions_delta,0),0,1,s.executions_delta))/1000000 avg_etime,
(s.buffer_gets_delta/decode(nvl(s.buffer_gets_delta,0),0,1,s.executions_delta)) avg_lio	
FROM
	sliders sl, dba_hist_sqlstat s, dba_hist_snapshot ss
WHERE
s.sql_id = sl.sql_id
and ss.snap_id = S.snap_id
and s.executions_delta > 0
and ss.begin_interval_time > sysdate -4/24
order by  1,2)
SELECT distinct(sql_id), 1 as thl 
FROM
(SELECT 
	sql_id, snap_id, begin_interval_time,  plan_hash_value, avg_etime, 
	 lag(avg_etime, 1, avg_etime) over (partition by snap_id, begin_interval_time, sql_id 
						order by snap_id, begin_interval_time) * 35 as  lim_avg_etime,
	 lag(avg_etime, 1, avg_etime) over (partition by snap_id, begin_interval_time, sql_id 
						order by snap_id, begin_interval_time)  as  prior_avg_etime
FROM
	sliders_hist_sqlstat
) s
WHERE s.avg_etime > s.lim_avg_etime
;
