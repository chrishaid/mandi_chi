USE SPI
GO

ALTER VIEW TIME_SERIES_GRADES$student_off_track_current AS
SELECT *
FROM OPENQUERY(KIPP_NWK,
  'SELECT g.*
   FROM GRADES$TIME_SERIES_DETAIL g
   JOIN STUDENTS s
     ON g.studentid = s.id
   JOIN
     (SELECT s.schoolid
            ,MAX(g.date_value) AS date_value
      FROM grades$time_series_detail g
      JOIN STUDENTS s
        ON g.studentid = s.ID
      GROUP BY s.schoolid
      ) school_max
   ON school_max.schoolid = s.schoolid
  AND g.date_value = school_max.date_value'
)