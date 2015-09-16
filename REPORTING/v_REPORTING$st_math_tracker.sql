USE KIPP_Silo
GO

CREATE VIEW REPORTING$st_math_tracker AS
WITH observed_completion AS
    (SELECT studentid
           ,SUM(K_5_Progress) AS total_completion
     FROM ST_Math..prep_blended_tracker_long
     WHERE comp_type = 'Observed'
       AND school_year = 2014
     GROUP BY studentid
    )
   ,max_week AS
   (SELECT MAX(w.week_num) AS max_week
    FROM ST_Math..completion_by_week w
   )
   ,prev_week_completion AS
   (SELECT studentid
          ,SUM(progress) AS total_completion
    FROM
          (SELECT st.studentid
                 ,st.start_year
                 ,st.gcd_sort
                 ,CAST(MAX(K_5_Progress) AS NUMERIC(4,1)) AS progress
           FROM ST_Math..completion_by_week st
           JOIN max_week
             ON st.week_num <= max_week.max_week - 1
            AND st.start_year = 2014
           GROUP BY st.studentid
                   ,st.start_year
                   ,st.gcd_sort
          ) sub
    GROUP BY studentid
   )
SELECT sub.studentid
      ,s.student_number
      ,s.grade_level
      ,s.schoolid
      ,s.lastfirst
      ,observed_completion.total_completion
      ,prev_week_completion.total_completion AS prev_week
      ,observed_completion.total_completion - prev_week_completion.total_completion AS one_week_change
      ,sub.lib_K
      ,sub.lib_1st
      ,sub.lib_2nd
      ,sub.lib_3rd
      ,sub.lib_4th
      ,sub.lib_5th
      ,sub.lib_6th 
FROM
      (SELECT *
       FROM
              (SELECT studentid
                     ,short_code
                     ,K_5_Progress
               FROM ST_Math..prep_blended_tracker_long
              ) sub
       PIVOT(
         MAX(K_5_Progress)
         FOR short_code
         IN (lib_K, lib_1st, lib_2nd, lib_3rd, lib_4th, lib_5th, lib_6th)
       ) AS st_wide
       ) sub
JOIN observed_completion
  ON sub.studentid = observed_completion.studentid
LEFT OUTER JOIN prev_week_completion
  ON sub.studentid = prev_week_completion.studentid
JOIN PS_mirror..STUDENTS s
  ON sub.studentid = s.id