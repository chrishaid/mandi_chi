/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('AR Progress Monitoring Rise Gr 5'
 ,'auto'
 ,'2013-10-04 06:45:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Gr 8'
   ,@send_again = @fake OUTPUT
END

*/

USE KIPP_NJ
GO

DECLARE @helper_grade_level INT = 5
       ,@helper_schoolid    INT = 73252
       ,@helper_school      NVARCHAR(5) = 'Rise'
       ,@this_job_name      NCHAR(100) = 'AR Progress Monitoring Rise Gr 5'
       
BEGIN

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( --'amartin@teamschools.org'
       --'amartin@teamschools.org;ldesimon@teamschools.org;kdjones@teamschools.org;srutherford@teamschools.org'
       --'amartin@teamschools.org;ldesimon@teamschools.org;kdjones@teamschools.org;cbraman@teamschools.org;melguero@teamschools.org'
       --'amartin@teamschools.org;ldesimon@teamschools.org;kdjones@teamschools.org;scopeland@teamschools.org;ljoseph@teamschools.org'
       'amartin@teamschools.org;ldesimon@teamschools.org;kdjones@teamschools.org;kpasheluk@teamschools.org;kgalarza@teamschools.org;mjoseph@teamschools.org'
       ,'AR Progress Monitoring, ' + CAST(@helper_school AS NVARCHAR) + ' Gr. ' + CAST(@helper_grade_level AS NVARCHAR)
       --figure out SEND AGAIN
       ,'CASE
           --if today is friday
           WHEN DATEPART(WEEKDAY, GETDATE()) = 6
             --add 3 days
             THEN DATEADD(DAY, 3, GETDATE())
             --otherwise ju st add 1
           ELSE DATEADD(DAY, 1, GETDATE())
         END'
       ,4
        --stat query 1
       ,'SELECT CAST(CAST(ROUND(AVG(ar.stu_status_words_numeric + 0.0) * 100,0) AS FLOAT) AS NVARCHAR) + ''%'' AS pct_on_track
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
            AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
            AND yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''RT1''
        '
        --stat query 2
       ,'SELECT replace(convert(varchar,convert(Money, CAST(ROUND(AVG(ar.words),1) AS FLOAT)),1),''.00'','''') AS avg_words
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
            AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
            AND yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''RT1''
         '
         --stat query 3
        ,'SELECT CAST(ROUND(AVG(ar.mastery),1) AS FLOAT) AS avg_mastery
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
            JOIN KIPP_NJ..STUDENTS s
              ON ar.studentid = s.id
            AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND yearid = 2300
             AND time_hierarchy = 2
             AND time_period_name = ''RT1''
         '
         --stat query 4
        ,'SELECT CAST(ROUND(AVG(ar.pct_fiction),1) AS FLOAT) AS avg_mastery
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
            JOIN KIPP_NJ..STUDENTS s
              ON ar.studentid = s.id
            AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND yearid = 2300
             AND time_hierarchy = 2
             AND time_period_name = ''RT1''
         '
         --stat labels 1-4
        ,'% On Track'
        ,'Avg Words'
        ,'Avg Mastery'
        ,'Avg % Fiction'
        --image stuff
        ,'On'
        --dynamic filepath
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_words_Rise_gr_' + CAST(@helper_grade_level AS NVARCHAR) + '.png'
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_mastery_Rise_gr_' + CAST(@helper_grade_level AS NVARCHAR) + '.png'
        --regular text (use single space for nulls)
        ,'This table shows the percent of students on track by week.'
        ,'Student roster data below:'
        ,' '
        --csv stuff
        ,'On'
        ,2
        --table query 1
        ,'SELECT TOP 1000000000
                 [grade_level]
                ,[eng_enr]
                ,[time_period_name]
                ,SUBSTRING(students, 1, 15) AS students
                ,N
                ,[8/5]
                ,[8/12]
                ,[8/19]
                ,[8/26]
                ,[9/2]
                ,[9/9]
                ,[9/16]
                ,[9/23]
                ,[9/30]
                ,[10/7]
                ,[10/14]
                ,[10/21]
                ,[10/28]
                ,[11/4]
                ,[11/11]
                ,[11/18]
                ,[11/25]
                ,[12/2]
                ,[12/9]
                ,[12/16]
                ,[12/23]
                ,[12/29]
              FROM KIPP_NJ..[AR$on_track#wide]
              WHERE grade_level = ''' + CAST(@helper_grade_level AS NVARCHAR) + '''
                AND school = ''' + CAST(@helper_school AS NVARCHAR) + '''
                AND time_period_name IN (''Year'', ''Hexameter 1'')
              ORDER BY time_period_name
                      ,eng_enr
          '
          --table query 2
         ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,s.grade_level 
                 ,ar.time_period_name
                 ,CAST(CAST(ROUND(ar.words_goal, 1) AS FLOAT) AS NVARCHAR) AS words_goal
                 ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words          
                 ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_words, 0) AS FLOAT)),1),''.00'','''') AS ''Target''
                 ,ar.stu_status_words AS status
                 ,ar.mastery
                 ,ar.avg_lexile AS ''Avg Lexile''
                 ,ar.pct_fiction AS ''Pct Fiction''
                 ,ar.n_passed
                 ,ar.n_total
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
            AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
           WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND yearid = 2300
             AND time_hierarchy = 2
             AND time_period_name = ''RT1''
           ORDER BY ar.words DESC
          '
          --table style parameters
         ,'CSS_small'
         ,'CSS_small'
     )
  ) AS SOURCE
  (  [email_recipients]
    ,[email_subject]
    ,[send_again]
    ,[stat_count]
    ,[stat_query1]
    ,[stat_query2]
    ,[stat_query3]
    ,[stat_query4]
    ,[stat_label1]
    ,[stat_label2]
    ,[stat_label3]
    ,[stat_label4]
    ,[image_toggle]
    ,[image_path1]
    ,[image_path2]
    ,[explanatory_text1]
    ,[explanatory_text2]
    ,[explanatory_text3]
    ,[csv_toggle]
    ,[which_csv]
    ,[table_query1]
    ,[table_query2]
    ,[table_style1]
    ,[table_style2]
  )
  ON target.job_name = @this_job_name

WHEN MATCHED THEN
  UPDATE
    SET target.email_recipients = source.email_recipients
       ,target.email_subject    = source.email_subject
       ,target.send_again =  source.send_again
       ,target.stat_count =  source.stat_count
       ,target.stat_query1 =  source.stat_query1
       ,target.stat_query2 =  source.stat_query2
       ,target.stat_query3 =  source.stat_query3
       ,target.stat_query4 =  source.stat_query4
       ,target.stat_label1 =  source.stat_label1
       ,target.stat_label2 =  source.stat_label2
       ,target.stat_label3 =  source.stat_label3
       ,target.stat_label4 =  source.stat_label4
       ,target.image_toggle =  source.image_toggle
       ,target.image_path1 =  source.image_path1
       ,target.image_path2 =  source.image_path2
       ,target.explanatory_text1 =  source.explanatory_text1
       ,target.explanatory_text2 =  source.explanatory_text2
       ,target.explanatory_text3 =  source.explanatory_text3
       ,target.csv_toggle =  source.csv_toggle
       ,target.which_csv =  source.which_csv
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2

WHEN NOT MATCHED THEN
   INSERT
   (  [job_name]
     ,[email_recipients]
     ,[email_subject]
     ,[send_again]
     ,[stat_count]
     ,[stat_query1]
     ,[stat_query2]
     ,[stat_query3]
     ,[stat_query4]
     ,[stat_label1]
     ,[stat_label2]
     ,[stat_label3]
     ,[stat_label4]
     ,[image_toggle]
     ,[image_path1]
     ,[image_path2]
     ,[explanatory_text1]
     ,[explanatory_text2]
     ,[explanatory_text3]
     ,[csv_toggle]
     ,[which_csv]
     ,[table_query1]
     ,[table_query2]
     ,[table_style1]
     ,[table_style2]

   )
   VALUES
   (  @this_job_name
     ,source.email_recipients
     ,source.email_subject
     ,source.send_again
     ,source.stat_count
     ,source.stat_query1
     ,source.stat_query2
     ,source.stat_query3
     ,source.stat_query4
     ,source.stat_label1
     ,source.stat_label2
     ,source.stat_label3
     ,source.stat_label4
     ,source.image_toggle
     ,source.image_path1
     ,source.image_path2
     ,source.explanatory_text1
     ,source.explanatory_text2
     ,source.explanatory_text3
     ,source.csv_toggle
     ,source.which_csv
     ,source.table_query1
     ,source.table_query2
     ,source.table_style1
     ,source.table_style2
   );

END