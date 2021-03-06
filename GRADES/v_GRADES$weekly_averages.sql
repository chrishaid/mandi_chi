USE KIPP_NJ
GO

ALTER VIEW GRADES$weekly_averages AS

WITH enrollments AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst
        ,cc.sectionid
        ,cc.section_number
        ,cc.course_number        
        ,cou.course_name
        ,cou.credittype
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN cc WITH(NOLOCK)
    ON co.studentid = cc.studentid
   AND co.schoolid = cc.SCHOOLID
   AND cc.TERMID >= dbo.fn_Global_Term_id() 
  JOIN courses cou WITH(NOLOCK)
    ON cc.course_number = cou.course_number 
   AND cou.credittype NOT IN ('COCUR', 'PHYSED')
  WHERE co.year = dbo.fn_Global_Academic_Year()
    --AND co.schoolid = 73252
    --AND co.grade_level = 8
    AND co.rn = 1
 )

,weeks AS (
  SELECT week
        ,weekday_start
        ,weekday_end
  FROM UTIL$reporting_weeks_days WITH(NOLOCK)
  WHERE academic_year = dbo.fn_Global_Academic_Year()
 )

SELECT enr.student_number      
      ,enr.course_number
      ,weeks.week
      ,weeks.weekday_start
      --,asmt.assign_date      
      --,asmt.assign_name
      ,asmt.category
      ,dbo.GROUP_CONCAT_D(asmt.assign_name, '  |  ') AS assign_names
      ,ROUND(AVG(CONVERT(FLOAT,scores.score) / CONVERT(FLOAT,asmt.pointspossible)) * 100,0) AS score
FROM enrollments enr
JOIN GRADES$assignments#static asmt WITH(NOLOCK)
  ON enr.sectionid = asmt.sectionid
 AND asmt.pointspossible != 0
 --AND asmt.category LIKE 'H%'
JOIN GRADES$assignment_scores#static scores WITH(NOLOCK)
  ON enr.student_number = scores.student_number
 AND asmt.assignmentid = scores.assignmentid
 AND scores.exempt = 0
JOIN weeks
  ON asmt.assign_date >= weeks.weekday_start
 AND asmt.assign_date <= weeks.weekday_end
GROUP BY enr.student_number      
        ,enr.course_number
        ,weeks.week
        ,weeks.weekday_start
        ,asmt.category