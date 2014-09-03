USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_wide AS

WITH fsa_rn AS (
  SELECT *
        ,ROW_NUMBER() OVER(
           PARTITION BY schoolid, grade_level, scope, fsa_week
             ORDER BY subject, standards_tested) AS fsa_std_rn      
  FROM
      (
       SELECT DISTINCT
              schoolid      
             ,grade_level
             ,academic_year
             ,assessment_id
             ,fsa_week
             ,administered_at           
             ,scope
             ,subject      
             ,standards_tested
       FROM ILLUMINATE$assessments#static WITH(NOLOCK)
       WHERE schoolid IN (73254, 73255, 73256, 73257, 179901)
         AND scope = 'FSA'
         AND subject IS NOT NULL
         AND fsa_week IS NOT NULL
         AND academic_year = dbo.fn_Global_Academic_Year()
      ) sub  
 )    

,fsa_scaffold AS (
  SELECT co.studentid
        ,co.STUDENT_NUMBER
        ,a.assessment_id
        ,a.fsa_week
        ,a.schoolid
        ,a.grade_level
        ,a.standards_tested
        ,CONVERT(VARCHAR,a.subject) AS FSA_subject
        ,CONVERT(VARCHAR,a.standards_tested) AS FSA_standard
        ,CONVERT(VARCHAR,nxt.next_steps_mastered) AS FSA_nxtstp_y
        ,CONVERT(VARCHAR,nxt.next_steps_notmastered) AS FSA_nxtstp_n
        ,CONVERT(VARCHAR,nxt.objective) AS FSA_obj
        ,a.FSA_std_rn
  FROM fsa_rn a
  JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
    ON a.schoolid = co.SCHOOLID
   AND a.grade_level = co.GRADE_LEVEL   
   AND a.academic_year = co.year   
   AND co.rn = 1
  LEFT OUTER JOIN GDOCS$FSA_longterm_clean nxt
    ON a.SCHOOLID = nxt.schoolid
   AND a.GRADE_LEVEL = nxt.grade_level
   AND a.fsa_week = nxt.week_num
   AND a.standards_tested = nxt.ccss_standard  
 )

SELECT *
FROM
    (
     SELECT studentid
           ,STUDENT_NUMBER
           ,fsa_week
           ,identifier + '_' + CONVERT(VARCHAR,fsa_std_rn) AS identifier
           ,value
     FROM
         (
          SELECT a.studentid
                ,a.student_number           
                ,a.FSA_week
                ,a.FSA_subject
                ,a.FSA_standard
                ,a.FSA_obj
                ,a.FSA_nxtstp_y
                ,a.FSA_nxtstp_n
                ,a.FSA_std_rn
                ,CONVERT(VARCHAR,res.performance_band_level) AS FSA_score
                ,CONVERT(VARCHAR,res.perf_band_label) AS FSA_prof
          FROM fsa_scaffold a            
          LEFT OUTER JOIN ILLUMINATE$assessment_results_by_standard#static res WITH(NOLOCK)  
            ON a.student_number = res.local_student_id           
           AND a.assessment_id = res.assessment_id
           AND res.custom_code = a.standards_tested
         ) sub
         
     UNPIVOT (
       value
       FOR identifier IN ([FSA_subject]
                         ,[FSA_score]
                         ,[FSA_prof]
                         ,[FSA_standard]
                         ,[FSA_nxtstp_y]
                         ,[FSA_nxtstp_n]
                         ,[FSA_obj])
      ) unpiv
    ) sub2  

--/*
PIVOT (
  MAX(value)
  FOR identifier IN ([FSA_subject_1]
                    ,[FSA_subject_2]
                    ,[FSA_subject_3]
                    ,[FSA_subject_4]
                    ,[FSA_subject_5]
                    ,[FSA_subject_6]
                    ,[FSA_subject_7]
                    ,[FSA_subject_8]
                    ,[FSA_subject_9]
                    ,[FSA_subject_10]
                    ,[FSA_subject_11]
                    ,[FSA_subject_12]
                    ,[FSA_subject_13]
                    ,[FSA_subject_14]
                    ,[FSA_subject_15]
                    ,[FSA_standard_1]
                    ,[FSA_standard_2]
                    ,[FSA_standard_3]
                    ,[FSA_standard_4]
                    ,[FSA_standard_5]
                    ,[FSA_standard_6]
                    ,[FSA_standard_7]
                    ,[FSA_standard_8]
                    ,[FSA_standard_9]
                    ,[FSA_standard_10]
                    ,[FSA_standard_11]
                    ,[FSA_standard_12]
                    ,[FSA_standard_13]
                    ,[FSA_standard_14]
                    ,[FSA_standard_15]
                    ,[FSA_obj_1]
                    ,[FSA_obj_2]
                    ,[FSA_obj_3]
                    ,[FSA_obj_4]
                    ,[FSA_obj_5]
                    ,[FSA_obj_6]
                    ,[FSA_obj_7]
                    ,[FSA_obj_8]
                    ,[FSA_obj_9]
                    ,[FSA_obj_10]
                    ,[FSA_obj_11]
                    ,[FSA_obj_12]
                    ,[FSA_obj_13]
                    ,[FSA_obj_14]
                    ,[FSA_obj_15]
                    ,[FSA_score_1]
                    ,[FSA_score_2]
                    ,[FSA_score_3]
                    ,[FSA_score_4]
                    ,[FSA_score_5]
                    ,[FSA_score_6]
                    ,[FSA_score_7]
                    ,[FSA_score_8]
                    ,[FSA_score_9]
                    ,[FSA_score_10]
                    ,[FSA_score_11]
                    ,[FSA_score_12]
                    ,[FSA_score_13]
                    ,[FSA_score_14]
                    ,[FSA_score_15]
                    ,[FSA_prof_1]
                    ,[FSA_prof_2]
                    ,[FSA_prof_3]
                    ,[FSA_prof_4]
                    ,[FSA_prof_5]
                    ,[FSA_prof_6]
                    ,[FSA_prof_7]
                    ,[FSA_prof_8]
                    ,[FSA_prof_9]
                    ,[FSA_prof_10]
                    ,[FSA_prof_11]
                    ,[FSA_prof_12]
                    ,[FSA_prof_13]
                    ,[FSA_prof_14]
                    ,[FSA_prof_15]
                    ,[FSA_nxtstp_y_1]
                    ,[FSA_nxtstp_y_2]
                    ,[FSA_nxtstp_y_3]
                    ,[FSA_nxtstp_y_4]
                    ,[FSA_nxtstp_y_5]
                    ,[FSA_nxtstp_y_6]
                    ,[FSA_nxtstp_y_7]
                    ,[FSA_nxtstp_y_8]
                    ,[FSA_nxtstp_y_9]
                    ,[FSA_nxtstp_y_10]
                    ,[FSA_nxtstp_y_11]
                    ,[FSA_nxtstp_y_12]
                    ,[FSA_nxtstp_y_13]
                    ,[FSA_nxtstp_y_14]
                    ,[FSA_nxtstp_y_15]
                    ,[FSA_nxtstp_n_1]
                    ,[FSA_nxtstp_n_2]
                    ,[FSA_nxtstp_n_3]
                    ,[FSA_nxtstp_n_4]
                    ,[FSA_nxtstp_n_5]
                    ,[FSA_nxtstp_n_6]
                    ,[FSA_nxtstp_n_7]
                    ,[FSA_nxtstp_n_8]
                    ,[FSA_nxtstp_n_9]
                    ,[FSA_nxtstp_n_10]
                    ,[FSA_nxtstp_n_11]
                    ,[FSA_nxtstp_n_12]
                    ,[FSA_nxtstp_n_13]
                    ,[FSA_nxtstp_n_14]
                    ,[FSA_nxtstp_n_15])
 ) piv
 --*/