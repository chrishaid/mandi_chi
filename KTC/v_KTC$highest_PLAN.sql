USE KIPP_NJ
GO

ALTER VIEW KTC$highest_PLAN AS

SELECT STUDENT_NUMBER
      ,highest_english
      ,highest_math
      ,highest_reading
      ,highest_science
      ,highest_composite
FROM
     (
      SELECT s.student_number
            ,act.english AS highest_english
            ,act.math AS highest_math
            ,act.reading AS highest_reading
            ,act.science AS highest_science
            ,act.composite AS highest_composite
            ,ROW_NUMBER() OVER(
                PARTITION BY s.student_number
                    ORDER BY act.composite DESC) AS rn
      FROM STUDENTS s WITH(NOLOCK)      
      JOIN NAVIANCE$ACT_clean act WITH(NOLOCK)
        ON s.STUDENT_NUMBER = act.student_number
      WHERE act.is_plan = 1
     ) sub
WHERE rn = 1     