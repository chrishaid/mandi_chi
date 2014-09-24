USE KIPP_NJ
GO

ALTER VIEW TABLEAU$710_dashboard AS
 
WITH enrollments AS (
  SELECT cc.SCHOOLID
        ,cc.STUDENTID
        ,cc.TERMID
        ,cou.CREDITTYPE
        ,cc.COURSE_NUMBER
        ,cou.course_name
        ,cc.SECTION_NUMBER
        ,cc.SECTIONID
        ,t.last_name AS teacher_name
        ,CASE        
          WHEN cc.SCHOOLID != 73253 THEN cc.EXPRESSION
          WHEN cc.expression = '1(A)' THEN 'HR'
          WHEN cc.expression = '2(A)' THEN '1'
          WHEN cc.expression = '3(A)' THEN '2'
          WHEN cc.expression = '4(A)' THEN '3'
          WHEN cc.expression = '5(A)' THEN '4A'
          WHEN cc.expression = '6(A)' THEN '4B'
          WHEN cc.expression = '7(A)' THEN '4C'
          WHEN cc.expression = '8(A)' THEN '4D'
          WHEN cc.expression = '9(A)' THEN '5A'
          WHEN cc.expression = '10(A)' THEN '5B'
          WHEN cc.expression = '11(A)' THEN '5C'
          WHEN cc.expression = '12(A)' THEN '5D'
          WHEN cc.expression = '13(A)' THEN '6'
          WHEN cc.expression = '14(A)' THEN '7'       
         END AS nca_period
  FROM CC WITH(NOLOCK)
  JOIN COURSES cou WITH(NOLOCK)
    ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
   AND cou.CREDITTYPE IS NOT NULL
   AND cou.CREDITTYPE NOT IN ('LOG')
  JOIN TEACHERS t WITH(NOLOCK)
    ON cc.TEACHERID = t.ID
  WHERE cc.TERMID >= dbo.fn_Global_Term_Id()
    AND cc.STUDENTID IN (SELECT studentid 
                         FROM COHORT$comprehensive_long#static co WITH(NOLOCK) 
                         WHERE co.year = dbo.fn_Global_Academic_Year() AND co.grade_level >= 5 AND co.grade_level <= 12)
 )

,reporting_weeks AS (
  SELECT rw.reporting_hash
        ,rw.week
        ,CONVERT(DATE,rw.weekday_start) AS week_of
        ,dt.alt_name
        ,dt.termid
        ,dt.schoolid
  FROM UTIL$reporting_weeks_days rw WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) >= ((DATEPART(YEAR,dt.start_date) * 100) + DATEPART(WEEK,dt.start_date))
   AND ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) <= ((DATEPART(YEAR,dt.end_date) * 100) + DATEPART(WEEK,dt.end_date))
   AND rw.academic_year = dt.academic_year
   AND dt.identifier = 'RT'
   AND dt.school_level != 'ES'
  WHERE rw.academic_year = dbo.fn_Global_Academic_Year()
    AND rw.weekday_start <= GETDATE()
 )

,course_scaffold AS (
  SELECT DISTINCT 
         rw.schoolid
        ,rw.week        
        ,rw.week_of
        ,rw.reporting_hash
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,SECTIONID
        ,CASE WHEN enr.schoolid = 73253 THEN enr.nca_period ELSE enr.SECTION_NUMBER END AS section        
        ,teacher_name        
        ,rw.alt_name AS term
  FROM enrollments enr WITH(NOLOCK)
  JOIN reporting_weeks rw WITH(NOLOCK)
    ON enr.SCHOOLID = rw.schoolid
 )

,finalgrades_long AS ( 
  SELECT sectionid
        ,term
        ,ROUND(AVG(termgrade),0) AS termgrade
  FROM
      (
       SELECT DISTINCT 
              STUDENT_NUMBER             
             ,sectionid
             ,T1
             ,T2
             ,T3
             ,Q1
             ,Q2
             ,Q3
             ,Q4
             ,E1
             ,E2
             ,Y1
       FROM
           (
            SELECT STUDENT_NUMBER
                  ,T1
                  ,T2
                  ,T3             
                  ,NULL AS Q1
                  ,NULL AS Q2
                  ,NULL AS Q3
                  ,NULL AS Q4
                  ,NULL AS E1
                  ,NULL AS E2
                  ,Y1
                  ,T1_ENR_SECTIONID AS rt1_sectionid
                  ,T2_ENR_SECTIONID AS rt2_sectionid
                  ,T3_ENR_SECTIONID AS rt3_sectionid
                  ,NULL AS rt4_sectionid
            FROM GRADES$DETAIL#MS WITH(NOLOCK)

            UNION ALL

            SELECT STUDENT_NUMBER
                  ,NULL AS T1
                  ,NULL AS T2
                  ,NULL AS T3
                  ,q1
                  ,q2
                  ,q3
                  ,q4
                  ,e1
                  ,e2
                  ,Y1
                  ,q1_enr_sectionid AS rt1_sectionid
                  ,q2_enr_sectionid AS rt2_sectionid
                  ,q3_enr_sectionid AS rt3_sectionid
                  ,q4_enr_sectionid AS rt4_sectionid
            FROM GRADES$DETAIL#NCA WITH(NOLOCK)
           ) sub

       UNPIVOT (
         sectionid
         FOR term IN (rt1_sectionid, rt2_sectionid, rt3_sectionid, rt4_sectionid)
        ) u
      ) sub

  UNPIVOT (
    termgrade
    FOR term IN (T1
                ,T2
                ,T3
                ,Q1
                ,Q2
                ,Q3
                ,Q4
                ,Y1
                ,E1
                ,E2)
   ) u2

  GROUP BY sectionid
          ,term
 )

,attendance_weekly AS (
  SELECT sectionid
        ,week
        ,SUM(is_absent) AS n_absent
  FROM
      (
       SELECT studentid
             ,sectionid
             ,DATEPART(WEEK,att_date) AS week
             ,att_code
             ,CASE WHEN att_code IS NULL OR att_code IN ('T','T10','TE') THEN 0.0 ELSE 1.0 END AS is_absent
       FROM ATT_MEM$meeting_attendance#static WITH(NOLOCK)
      ) sub
  GROUP BY sectionid
          ,week
 )

,membership_weekly AS (
  SELECT sectionid
        ,week
        ,SUM(MEMBERSHIPVALUE) AS n_mem
  FROM
      (
       SELECT mem.STUDENTID      
             ,mem.STUDENT_NUMBER      
             ,ABS(cc.SECTIONID) AS sectionid
             ,DATEPART(WEEK,mem.CALENDARDATE) AS week
             ,CONVERT(FLOAT,mem.MEMBERSHIPVALUE) AS membershipvalue
       FROM MEMBERSHIP mem WITH(NOLOCK)
       JOIN CC WITH(NOLOCK)
         ON mem.STUDENTID = cc.STUDENTID
        AND mem.CALENDARDATE >= cc.DATEENROLLED
        AND mem.CALENDARDATE <= cc.DATELEFT 
       WHERE mem.CALENDARDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')
         AND mem.SCHOOLID IN (73253,73252,133570965)  
      ) sub
  GROUP BY sectionid
          ,week
 )

,butts_in_seats AS (
  SELECT mem.sectionid
        ,mem.week
        ,mem.n_mem
        ,ISNULL(att.n_absent,0) AS n_absent
        ,ROUND(((mem.n_mem - ISNULL(att.n_absent,0)) / mem.n_mem) * 100,0) AS butts_in_seats_pct
  FROM membership_weekly mem
  LEFT OUTER JOIN attendance_weekly att
    ON mem.sectionid = att.sectionid
   AND mem.week = att.week
 )

SELECT schoolid
      ,week
      ,week_of
      ,reporting_hash
      ,CREDITTYPE
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,sectionid
      ,SECTION      
      ,teacher_name
      ,term
      ,finalgrade
      ,category
      ,ROUND(AVG(pct),0) AS pct
      ,ISNULL(COUNT(DISTINCT assign_name),0) AS n_assign
FROM
    (
     SELECT enr.*            
           ,gr.ASSIGNMENTID
           ,gr.assign_name
           ,gr.finalgrade
           ,gr.category
           ,gr.pct      
           --,gr.student_number      
           --,s.lastfirst
           --,s.grade_level
           --,s.team
           --,s.gender
           --,cs.advisor
           --,cs.spedlep
           --,co.year_in_network
     FROM course_scaffold enr WITH(NOLOCK)
     JOIN GRADES$asmt_scores_category_long gr WITH(NOLOCK)
       ON enr.SECTIONID = gr.sectionid
      AND enr.week = gr.week
     --JOIN STUDENTS s WITH(NOLOCK)
     --  ON gr.student_number = s.student_number
     --JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
     --  ON s.id = cs.studentid
     --JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
     --  ON s.id = co.studentid
     -- AND co.year = dbo.fn_Global_Academic_Year()
     -- AND co.rn = 1
    ) sub
GROUP BY schoolid
        ,week
        ,week_of
        ,reporting_hash
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,SECTIONID
        ,SECTION
        ,teacher_name
        ,term
        ,finalgrade
        ,category

UNION ALL

SELECT enr.*            
      --,NULL AS ASSIGNMENTID
      --,'Term Grade' AS assign_name
      ,fg.term AS finalgrade
      ,NULL AS category
      ,fg.termgrade AS pct
      ,NULL AS n_assign
      --,fg.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN finalgrades_long fg WITH(NOLOCK)
  ON enr.sectionid = fg.sectionid
 AND enr.term = fg.term
--JOIN STUDENTS s WITH(NOLOCK)
--  ON fg.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1

UNION ALL

SELECT enr.*            
      --,NULL AS ASSIGNMENTID
      --,'Term Grade' AS assign_name
      ,fg.term AS finalgrade
      ,NULL AS category
      ,fg.termgrade AS pct
      ,NULL AS n_assign
      --,fg.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN finalgrades_long fg WITH(NOLOCK)
  ON enr.sectionid = fg.sectionid
 AND fg.term = 'Y1'
--JOIN STUDENTS s WITH(NOLOCK)
--  ON fg.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1

UNION ALL

SELECT enr.*            
      --,NULL AS ASSIGNMENTID
      --,'Attendance %' AS assign_name
      ,'Att %' AS finalgrade
      ,NULL AS category
      ,bis.butts_in_seats_pct AS pct
      ,NULL AS n_assign
      --,bis.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN butts_in_seats bis WITH(NOLOCK)
  ON enr.SECTIONID = bis.sectionid
 AND enr.week = bis.week
--JOIN STUDENTS s WITH(NOLOCK)
--  ON bis.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1