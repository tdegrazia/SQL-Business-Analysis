SELECT
    subquery.dates,
    subquery.first_name,
    subquery.last_name,
    subquery.hourly_rate,
    subquery.actual_in,
    subquery.actual_out,
    subquery.scheduled_in,
    subquery.scheduled_out,
    COALESCE(subquery.real_shift_time, '00:00:00') AS real_shift_time,
    subquery.supposed_shift_time,
		ROUND(COALESCE(subquery.shift_cost, 0),2) AS shift_cost,
    subquery.supposed_shift_cost,
    TIME_FORMAT(
        TIMEDIFF(IFNULL(subquery.supposed_shift_time, '00:00:00'), IFNULL(subquery.real_shift_time, '00:00:00')),
        '%H:%i:%s'
    ) AS shift_variance
FROM
    (SELECT
        s.dates,
        s.first_name,
        s.last_name,
        s.hourly_rate,
        sh.actual_in,
        sh.actual_out,
        sh.scheduled_in,
        sh.scheduled_out,
        TIMEDIFF(IF(sh.actual_out < sh.actual_in, ADDTIME(sh.actual_out, '24:00:00'), sh.actual_out), sh.actual_in) AS real_shift_time,
        TIMEDIFF(IF(sh.scheduled_out < sh.scheduled_in, ADDTIME(sh.scheduled_out, '24:00:00'), sh.scheduled_out), sh.scheduled_in) AS supposed_shift_time,
        (
            (HOUR(TIMEDIFF(IF(sh.actual_out < sh.actual_in, ADDTIME(sh.actual_out, '24:00:00'), sh.actual_out), sh.actual_in)) * 60) +
            MINUTE(TIMEDIFF(IF(sh.actual_out < sh.actual_in, ADDTIME(sh.actual_out, '24:00:00'), sh.actual_out), sh.actual_in))
        ) / 60 * s.hourly_rate AS shift_cost,
        (
            (HOUR(TIMEDIFF(IF(sh.scheduled_out < sh.scheduled_in, ADDTIME(sh.scheduled_out, '24:00:00'), sh.scheduled_out), sh.scheduled_in)) * 60) +
            MINUTE(TIMEDIFF(IF(sh.scheduled_out < sh.scheduled_in, ADDTIME(sh.scheduled_out, '24:00:00'), sh.scheduled_out), sh.scheduled_in))
        ) / 60 * s.hourly_rate AS supposed_shift_cost
    FROM
        staff s
        LEFT JOIN Shift sh ON s.staff_id = sh.staff_id) AS subquery;
