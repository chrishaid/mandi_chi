USE KIPP_NJ
GO

ALTER VIEW REPORTING$reading_log#NCA AS

WITH curterm AS (
  SELECT time_per_name
  FROM REPORTING$dates WITH(NOLOCK)
  WHERE schoolid = 73253
    AND identifier = 'RT'
    AND GETDATE() >= start_date
    AND GETDATE() <= end_date
 )

SELECT s.LASTFIRST
      ,s.FIRST_NAME
      ,s.LAST_NAME
      ,cs.ADVISOR
      ,s.GRADE_LEVEL
      ,cs.SPEDLEP
      ,ar_Q1.points_goal AS AR_goal_Q1
      ,ar_q2.points_goal AS AR_goal_Q2
      ,ar_q3.points_goal AS AR_goal_Q3
      ,ar_q4.points_goal AS AR_goal_Q4
      ,ar_yr.points_goal AS AR_goal_Yr
      ,ar_Q1.points AS AR_Pts_Q1
      ,ar_q2.points AS AR_Pts_Q2
      ,ar_q3.points AS AR_Pts_Q3
      ,ar_q4.points AS AR_Pts_Q4
      ,ar_yr.points AS AR_Pts_Yr      
      ,CASE WHEN (ar_q1.points_goal - ar_q1.points) <= 0 THEN 0 ELSE (ar_q1.points_goal - ar_q1.points) END AS AR_pts_to_goal_Q1
      ,CASE WHEN (ar_q2.points_goal - ar_q2.points) <= 0 THEN 0 ELSE (ar_q2.points_goal - ar_q2.points) END AS AR_pts_to_goal_Q2
      ,CASE WHEN (ar_q3.points_goal - ar_q3.points) <= 0 THEN 0 ELSE (ar_q3.points_goal - ar_q3.points) END AS AR_pts_to_goal_Q3
      ,CASE WHEN (ar_q4.points_goal - ar_q4.points) <= 0 THEN 0 ELSE (ar_q4.points_goal - ar_q4.points) END AS AR_pts_to_goal_Q4
      ,CASE WHEN (ar_yr.points_goal - ar_yr.points) <= 0 THEN 0 ELSE (ar_yr.points_goal - ar_yr.points) END AS AR_pts_to_goal_Yr
      ,CONVERT(FLOAT,ROUND((ar_q1.points / ar_q1.points_goal * 100),1)) AS AR_pct_of_goal_Q1
      ,CONVERT(FLOAT,ROUND((ar_q2.points / ar_q2.points_goal * 100),1)) AS AR_pct_of_goal_Q2
      ,CONVERT(FLOAT,ROUND((ar_Q3.points / ar_Q3.points_goal * 100),1)) AS AR_pct_of_goal_Q3
      ,CONVERT(FLOAT,ROUND((ar_Q4.points / ar_Q4.points_goal * 100),1)) AS AR_pct_of_goal_Q4
      ,CONVERT(FLOAT,ROUND((ar_Yr.points / ar_Yr.points_goal * 100),1)) AS AR_pct_of_goal_Yr
      ,base.lexile_score AS lexile_base
      ,base.lexile_score AS lexile_fall
      ,lex_winter.rittoreadingscore AS lexile_winter
      ,lex_spring.rittoreadingscore AS lexile_spring
      ,lex_cur.rittoreadingscore AS lexile_current
      ,CONVERT(VARCHAR,lex_cur.rittoreadingmin) + ' - ' + CONVERT(VARCHAR,lex_cur.rittoreadingmax) AS lexile_range_current
      ,base.testritscore AS RIT_base
      ,lex_winter.testritscore AS RIT_winter
      ,lex_spring.testritscore AS RIT_spr
      ,rr.keep_up_rit
      ,rr.rutgers_ready_rit
      ,ar_yr.mastery AS mastery_yr      
      ,eng1.COURSE_NAME AS eng1_course
      ,eng1.SECTION_NUMBER AS eng1_section
      ,CASE        
        WHEN eng1.expression = '1(A)' THEN 'HR'
        WHEN eng1.expression = '2(A)' THEN '1'
        WHEN eng1.expression = '3(A)' THEN '2'
        WHEN eng1.expression = '4(A)' THEN '3'
        WHEN eng1.expression = '5(A)' THEN '4A'
        WHEN eng1.expression = '6(A)' THEN '4B'
        WHEN eng1.expression = '7(A)' THEN '4C'
        WHEN eng1.expression = '8(A)' THEN '4D'
        WHEN eng1.expression = '9(A)' THEN '5A'
        WHEN eng1.expression = '10(A)' THEN '5B'
        WHEN eng1.expression = '11(A)' THEN '5C'
        WHEN eng1.expression = '12(A)' THEN '5D'
        WHEN eng1.expression = '13(A)' THEN '6'
        WHEN eng1.expression = '14(A)' THEN '7'
        ELSE NULL
       END AS eng1_period
      ,eng1.LASTFIRST AS eng1_teacher
      ,eng2.COURSE_NAME AS eng2_course
      ,eng2.SECTION_NUMBER AS eng2_section
      ,CASE        
        WHEN eng2.expression = '1(A)' THEN 'HR'
        WHEN eng2.expression = '2(A)' THEN '1'
        WHEN eng2.expression = '3(A)' THEN '2'
        WHEN eng2.expression = '4(A)' THEN '3'
        WHEN eng2.expression = '5(A)' THEN '4A'
        WHEN eng2.expression = '6(A)' THEN '4B'
        WHEN eng2.expression = '7(A)' THEN '4C'
        WHEN eng2.expression = '8(A)' THEN '4D'
        WHEN eng2.expression = '9(A)' THEN '5A'
        WHEN eng2.expression = '10(A)' THEN '5B'
        WHEN eng2.expression = '11(A)' THEN '5C'
        WHEN eng2.expression = '12(A)' THEN '5D'
        WHEN eng2.expression = '13(A)' THEN '6'
        WHEN eng2.expression = '14(A)' THEN '7'
        ELSE NULL
       END AS eng2_period
      ,eng2.LASTFIRST AS eng2_teacher
      ,diff.COURSE_NAME AS fourth_per_class
      ,diff.LASTFIRST AS fourth_per_teacher
      ,CASE        
        WHEN diff.expression = '5(A)' THEN '4B'
        WHEN diff.expression = '6(A)' THEN '4A'
        WHEN diff.expression = '7(A)' THEN '4D'
        WHEN diff.expression = '8(A)' THEN '4C'        
        ELSE NULL
       END AS diff_block_period
      ,diff.COURSE_NAME AS diff_block_assignment
      ,CASE
        WHEN ar_q1.points = 0 THEN 'Tied for last place with 0 points'
        ELSE CONVERT(VARCHAR,ar_q1.rank_points_grade_in_school)
       END AS AR_graderank_Q1
      ,CASE
        WHEN ar_q2.points = 0 THEN 'Tied for last place with 0 points'
        ELSE CONVERT(VARCHAR,ar_q2.rank_points_grade_in_school)
       END AS AR_graderank_q2
      ,CASE
        WHEN ar_q3.points = 0 THEN 'Tied for last place with 0 points'
        ELSE CONVERT(VARCHAR,ar_q3.rank_points_grade_in_school)
       END AS AR_graderank_q3
      ,CASE
        WHEN ar_q4.points = 0 THEN 'Tied for last place with 0 points'
        ELSE CONVERT(VARCHAR,ar_q4.rank_points_grade_in_school)
       END AS AR_graderank_q4
      ,CASE
        WHEN ar_yr.points = 0 THEN 'Tied for last place with 0 points'
        ELSE CONVERT(VARCHAR,ar_yr.rank_points_grade_in_school)
       END AS AR_graderank_yr
      ,ar_q1.rank_points_overall_in_school AS AR_schoolrank_Q1
      ,ar_q2.rank_points_overall_in_school AS AR_schoolrank_Q2
      ,ar_q3.rank_points_overall_in_school AS AR_schoolrank_Q3
      ,ar_q4.rank_points_overall_in_school AS AR_schoolrank_Q4
      ,ar_yr.rank_points_overall_in_school AS AR_schoolrank_Yr      
      ,ROUND(((ar_cur.points / ar_cur.points_goal) * 100),0) AS AR_progress_cur
      ,ROUND(((ar_q1.points / ar_q1.points_goal) * 100),0) AS AR_progress_q1
      ,ROUND(((ar_q2.points / ar_q2.points_goal) * 100),0) AS AR_progress_q2
      ,ROUND(((ar_q3.points / ar_q3.points_goal) * 100),0) AS AR_progress_q3
      ,ROUND(((ar_q4.points / ar_q4.points_goal) * 100),0) AS AR_progress_q4
      ,ROUND(((ar_yr.points / ar_yr.points_goal) * 100),0) AS AR_progress_yr
      ,CASE WHEN ROUND(((ar_cur.points / ar_cur.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_cur
      ,CASE WHEN ROUND(((ar_q1.points / ar_q1.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q1
      ,CASE WHEN ROUND(((ar_q2.points / ar_q2.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q2
      ,CASE WHEN ROUND(((ar_q3.points / ar_q3.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q3
      ,CASE WHEN ROUND(((ar_q4.points / ar_q4.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_q4
      ,CASE WHEN ROUND(((ar_yr.points / ar_yr.points_goal) * 100),0) >= 100 THEN 'Yes' ELSE 'No' END AS met_AR_goal_yr      
      --,CASE
      --  --WHEN (intv_block.group_name LIKE ('%math rti%') OR intv_block.group_name LIKE ('%readlive%')) THEN 'Attends RTI'
      --  WHEN (eng1.COURSE_NAME LIKE ('%Eng Foundations%') OR eng2.COURSE_NAME LIKE ('%Eng Foundations%')) THEN CONVERT(VARCHAR,ROUND(((ar_cur.points / ar_cur.points_goal) * 100),0))
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points >= 25 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points >= 20 AND ar_cur.points < 25 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points >= 15 AND ar_cur.points < 20 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points >= 10 AND ar_cur.points < 15 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points > 0 AND ar_cur.points < 10 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_cur.points = 0 THEN '0'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points >= 30 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points >= 25 AND ar_cur.points < 30 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points >= 20 AND ar_cur.points < 25 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points >= 15 AND ar_cur.points < 20 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points >= 10 AND ar_cur.points < 15 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points > 0 AND ar_cur.points < 10 THEN '50'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_cur.points = 0 THEN '0'
      -- END AS ar_grade_cur
      --,CASE
      --  --WHEN (intv_block.group_name LIKE ('%math rti%') OR intv_block.group_name LIKE ('%readlive%')) THEN 'Attends RTI'
      --  WHEN (eng1.COURSE_NAME LIKE ('%Eng Foundations%') OR eng2.COURSE_NAME LIKE ('%Eng Foundations%')) THEN CONVERT(VARCHAR,ROUND(((ar_q1.points / ar_q1.points_goal) * 100),0))
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points >= 25 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points >= 20 AND ar_q1.points < 25 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points >= 15 AND ar_q1.points < 20 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points >= 10 AND ar_q1.points < 15 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points > 0 AND ar_q1.points < 10 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q1.points = 0 THEN '0'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points >= 30 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points >= 25 AND ar_q1.points < 30 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points >= 20 AND ar_q1.points < 25 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points >= 15 AND ar_q1.points < 20 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points >= 10 AND ar_q1.points < 15 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points > 0 AND ar_q1.points < 10 THEN '50'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q1.points = 0 THEN '0'
      -- END AS ar_grade_q1
      --,CASE
      --  --WHEN (intv_block.group_name LIKE ('%math rti%') OR intv_block.group_name LIKE ('%readlive%')) THEN 'Attends RTI'
      --  WHEN (eng1.COURSE_NAME LIKE ('%Eng Foundations%') OR eng2.COURSE_NAME LIKE ('%Eng Foundations%')) THEN CONVERT(VARCHAR,ROUND(((ar_q2.points / ar_q2.points_goal) * 100),0))
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points >= 25 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points >= 20 AND ar_q2.points < 25 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points >= 15 AND ar_q2.points < 20 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points >= 10 AND ar_q2.points < 15 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points > 0 AND ar_q2.points < 10 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q2.points = 0 THEN '0'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points >= 30 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points >= 25 AND ar_q2.points < 30 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points >= 20 AND ar_q2.points < 25 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points >= 15 AND ar_q2.points < 20 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points >= 10 AND ar_q2.points < 15 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points > 0 AND ar_q2.points < 10 THEN '50'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q2.points = 0 THEN '0'
      -- END AS ar_grade_q2
      --,CASE
      --  --WHEN (intv_block.group_name LIKE ('%math rti%') OR intv_block.group_name LIKE ('%readlive%')) THEN 'Attends RTI'
      --  WHEN (eng1.COURSE_NAME LIKE ('%Eng Foundations%') OR eng2.COURSE_NAME LIKE ('%Eng Foundations%')) THEN CONVERT(VARCHAR,ROUND(((ar_q3.points / ar_q3.points_goal) * 100),0))
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points >= 25 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points >= 20 AND ar_q3.points < 25 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points >= 15 AND ar_q3.points < 20 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points >= 10 AND ar_q3.points < 15 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points > 0 AND ar_q3.points < 10 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q3.points = 0 THEN '0'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points >= 30 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points >= 25 AND ar_q3.points < 30 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points >= 20 AND ar_q3.points < 25 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points >= 15 AND ar_q3.points < 20 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points >= 10 AND ar_q3.points < 15 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points > 0 AND ar_q3.points < 10 THEN '50'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q3.points = 0 THEN '0'
      -- END AS ar_grade_q3
      --,CASE
      --  --WHEN (intv_block.group_name LIKE ('%math rti%') OR intv_block.group_name LIKE ('%readlive%')) THEN 'Attends RTI'
      --  WHEN (eng1.COURSE_NAME LIKE ('%Eng Foundations%') OR eng2.COURSE_NAME LIKE ('%Eng Foundations%')) THEN CONVERT(VARCHAR,ROUND(((ar_q4.points / ar_q4.points_goal) * 100),0))
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points >= 25 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points >= 20 AND ar_q4.points < 25 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points >= 15 AND ar_q4.points < 20 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points >= 10 AND ar_q4.points < 15 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points > 0 AND ar_q4.points < 10 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG10','ENG20') AND ar_q4.points = 0 THEN '0'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points >= 30 THEN '100'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points >= 25 AND ar_q4.points < 30 THEN '90'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points >= 20 AND ar_q4.points < 25 THEN '80'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points >= 15 AND ar_q4.points < 20 THEN '70'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points >= 10 AND ar_q4.points < 15 THEN '60'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points > 0 AND ar_q4.points < 10 THEN '50'
      --  WHEN eng1.COURSE_NUMBER IN ('ENG30','ENG40','ENG45') AND ar_q4.points = 0 THEN '0'
      -- END AS ar_grade_q4
FROM STUDENTS s WITH (NOLOCK)
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH (NOLOCK)
  ON s.ID = cs.STUDENTID
LEFT OUTER JOIN curterm
  ON 1 = 1
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON s.id = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year'
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q1 WITH (NOLOCK)
  ON s.id = ar_q1.studentid 
 AND ar_q1.time_period_name = 'RT1'
 AND ar_q1.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q2 WITH (NOLOCK)
  ON s.id = ar_q2.studentid
 AND ar_q2.time_period_name = 'RT2'
 AND ar_q2.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q3 WITH (NOLOCK)
  ON s.id = ar_q3.studentid
 AND ar_q3.time_period_name = 'RT3'
 AND ar_q3.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_q4 WITH (NOLOCK)
  ON s.id = ar_q4.studentid
 AND ar_q4.time_period_name = 'RT4'
 AND ar_q4.yearid = dbo.fn_Global_Term_Id() 
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_cur WITH (NOLOCK)
  ON s.id = ar_cur.studentid
 AND ar_cur.time_period_name = curterm.time_per_name
 AND ar_cur.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_cur WITH (NOLOCK)
  ON s.id = lex_cur.ps_studentid
 AND lex_cur.measurementscale  = 'Reading'
 AND lex_cur.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_cur.rn_curr = 1
LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
  ON s.ID = rr.studentid
 AND s.schoolid = rr.schoolid 
 AND rr.measurementscale = 'Reading'
 AND rr.year = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$best_baseline#static base WITH(NOLOCK)
  ON s.ID = base.studentid
 AND s.schoolid = base.schoolid 
 AND base.measurementscale = 'Reading'
 AND base.year = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_winter WITH (NOLOCK)
  ON s.id = lex_winter.ps_studentid
 AND lex_winter.measurementscale  = 'Reading'
 AND lex_winter.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_winter.fallwinterspring = 'Winter'
 AND lex_winter.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers lex_spring WITH (NOLOCK)
  ON s.id = lex_spring.ps_studentid
 AND lex_spring.measurementscale  = 'Reading'
 AND lex_spring.map_year_academic = dbo.fn_Global_Academic_Year()
 AND lex_spring.fallwinterspring = 'Spring'
 AND lex_spring.rn = 1
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID
                       ,c.COURSE_NAME
                       ,c.COURSE_NUMBER
                       ,cc.SECTION_NUMBER
                       ,cc.EXPRESSION
                       ,t.LASTFIRST
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY c.course_name) AS rn
                 FROM COURSES c WITH (NOLOCK)
                 JOIN CC WITH (NOLOCK)
                   ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                  AND cc.TERMID >= dbo.fn_Global_Term_Id()
                  AND cc.SCHOOLID = 73253
                 JOIN TEACHERS t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID
                 WHERE CREDITTYPE = 'ENG'
                   AND c.course_number NOT LIKE 'ENG0%'
                ) eng1
  ON s.ID = eng1.STUDENTID
 AND eng1.rn = 1
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID
                       ,c.COURSE_NAME
                       ,c.COURSE_NUMBER
                       ,cc.SECTION_NUMBER                       
                       ,cc.EXPRESSION
                       ,t.LASTFIRST
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY c.course_name) AS rn
                 FROM COURSES c WITH (NOLOCK)
                 JOIN CC WITH (NOLOCK)
                   ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                  AND cc.TERMID >= dbo.fn_Global_Term_Id()
                  AND cc.SCHOOLID = 73253
                 JOIN TEACHERS t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID
                 WHERE c.CREDITTYPE = 'ENG'
                   AND c.course_number NOT LIKE 'ENG0%'
                ) eng2
  ON s.ID = eng2.STUDENTID
 AND eng2.rn = 2
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID     
                       ,cc.TERMID                         
                       ,cc.COURSE_NUMBER
                       ,c.COURSE_NAME                       
                       ,cc.SECTION_NUMBER
                       ,t.TEACHERNUMBER
                       ,t.LASTFIRST
                       ,CC.EXPRESSION
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY cc.termid DESC) AS rn
                 FROM CC WITH (NOLOCK)   
                 JOIN COURSES c WITH(NOLOCK)
                   ON cc.COURSE_NUMBER = c.COURSE_NUMBER
                 JOIN TEACHERS t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID                  
                 WHERE cc.TERMID >= dbo.fn_Global_Term_Id()
                   AND cc.SCHOOLID = 73253
                   AND cc.EXPRESSION IN ('5(A)','6(A)','7(A)','8(A)')
                   AND (cc.COURSE_NUMBER LIKE 'ENG0%' OR cc.COURSE_NUMBER LIKE 'MATH0%')
                ) diff
  ON s.id = diff.studentid
 AND diff.rn = 1
--intervention block
--LEFT OUTER JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv_block WITH(NOLOCK)
--  ON s.id = intv_block.studentid
WHERE s.SCHOOLID = 73253
  AND s.ENROLL_STATUS = 0
