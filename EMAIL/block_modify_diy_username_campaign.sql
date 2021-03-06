/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY ID

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('DIY Username Submision Status: Rise'
 ,'auto'
 ,'2013-11-01 07:25:30.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'DIY Username Submision Status: Rise'
   ,@send_again = @fake OUTPUT
END

*/

USE KIPP_NJ
GO

DECLARE @this_job_name      NCHAR(100) = 'DIY Username Submision Status: Rise'
       
BEGIN

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( --'amartin@teamschools.org'
       'amartin@teamschools.org;ldesimon@teamschools.org;jweber@teamschools.org;dmartin@teamschools.org;mjoseph@teamschools.org;tdempsey@teamschools.org'
       ,@this_job_name
       --figure out SEND AGAIN
       ,'DATEADD(DAY, 7, GETDATE())'
       ,4
        --stat query 1
       ,'SELECT CAST(ROUND(AVG(submitted_test + 0.0)*100,0) AS FLOAT) AS pct_submitted
         FROM
              (SELECT c.grade_level
                     ,c.lastfirst
                     ,cust.advisor
                     ,cust.diy_nickname
                     ,CASE
                        WHEN cust.diy_nickname IS NOT NULL THEN 1
                        WHEN cust.diy_nickname IS NULL THEN 0
                      END AS submitted_test
                 FROM KIPP_NJ..COHORT$comprehensive_long#static c
                 JOIN KIPP_NJ..CUSTOM_STUDENTS cust
                   ON c.studentid = cust.studentid
                  AND c.year = 2013 
                  AND c.schoolid = 73252
                  AND c.grade_level = 5
                  AND c.rn = 1
               ) sub
         GROUP BY grade_level
        '
        --stat query 2
       ,'SELECT CAST(ROUND(AVG(submitted_test + 0.0)*100,0) AS FLOAT) AS pct_submitted
         FROM
              (SELECT c.grade_level
                     ,c.lastfirst
                     ,cust.advisor
                     ,cust.diy_nickname
                     ,CASE
                        WHEN cust.diy_nickname IS NOT NULL THEN 1
                        WHEN cust.diy_nickname IS NULL THEN 0
                      END AS submitted_test
                 FROM KIPP_NJ..COHORT$comprehensive_long#static c
                 JOIN KIPP_NJ..CUSTOM_STUDENTS cust
                   ON c.studentid = cust.studentid
                  AND c.year = 2013 
                  AND c.schoolid = 73252
                  AND c.grade_level = 6
                  AND c.rn = 1
               ) sub
         GROUP BY grade_level
        '         
        --stat query 3
        ,'SELECT CAST(ROUND(AVG(submitted_test + 0.0)*100,0) AS FLOAT) AS pct_submitted
         FROM
              (SELECT c.grade_level
                     ,c.lastfirst
                     ,cust.advisor
                     ,cust.diy_nickname
                     ,CASE
                        WHEN cust.diy_nickname IS NOT NULL THEN 1
                        WHEN cust.diy_nickname IS NULL THEN 0
                      END AS submitted_test
                 FROM KIPP_NJ..COHORT$comprehensive_long#static c
                 JOIN KIPP_NJ..CUSTOM_STUDENTS cust
                   ON c.studentid = cust.studentid
                  AND c.year = 2013 
                  AND c.schoolid = 73252
                  AND c.grade_level = 7
                  AND c.rn = 1
               ) sub
         GROUP BY grade_level
        '
         --stat query 4
        ,'SELECT CAST(ROUND(AVG(submitted_test + 0.0)*100,0) AS FLOAT) AS pct_submitted
         FROM
              (SELECT c.grade_level
                     ,c.lastfirst
                     ,cust.advisor
                     ,cust.diy_nickname
                     ,CASE
                        WHEN cust.diy_nickname IS NOT NULL THEN 1
                        WHEN cust.diy_nickname IS NULL THEN 0
                      END AS submitted_test
                 FROM KIPP_NJ..COHORT$comprehensive_long#static c
                 JOIN KIPP_NJ..CUSTOM_STUDENTS cust
                   ON c.studentid = cust.studentid
                  AND c.year = 2013 
                  AND c.schoolid = 73252
                  AND c.grade_level = 8
                  AND c.rn = 1
               ) sub
         GROUP BY grade_level
        '
         --stat labels 1-4
        ,'% 5th Submitted'
        ,'% 6th Submitted'
        ,'% 7th Submitted'
        ,'% 8th Submitted'
        --image stuff
        ,0
        --dynamic filepath
        ,' '
        ,' '
        --regular text (use single space for nulls)
        ,'This table shows students who need to have their diy.org username submitted.  Advisors can submit diy.org usernames on PowerTeacher
          by clicking on the backpack (Info) icon, then on ''Submit DIY Username'' in the student screen dropdown (detailed directions, with pictures, below).<center>'
        ,'</center>'
        ,'<style type="text/css">
body, td {
   font-family: sans-serif;
   background-color: white;
   font-size: 12px;
   margin: 8px;
}

tt, code, pre {
   font-family: ''DejaVu Sans Mono'', ''Droid Sans Mono'', ''Lucida Console'', Consolas, Monaco, monospace;
}

h1 { 
   font-size:2.2em; 
}

h2 { 
   font-size:1.8em; 
}

h3 { 
   font-size:1.4em; 
}

h4 { 
   font-size:1.0em; 
}

h5 { 
   font-size:0.9em; 
}

h6 { 
   font-size:0.8em; 
}

a:visited {
   color: rgb(50%, 0%, 50%);
}

pre {	
   margin-top: 0;
   max-width: 95%;
   border: 1px solid #ccc;
   white-space: pre-wrap;
}

pre code {
   display: block; padding: 0.5em;
}

code.r, code.cpp {
   background-color: #F8F8F8;
}

table, td, th {
  border: none;
}

blockquote {
   color:#666666;
   margin:0;
   padding-left: 1em;
   border-left: 0.5em #EEE solid;
}

hr {
   height: 0px;
   border-bottom: none;
   border-top-width: thin;
   border-top-style: dotted;
   border-top-color: #999999;
}

@media print {
   * { 
      background: transparent !important; 
      color: black !important; 
      filter:none !important; 
      -ms-filter: none !important; 
   }

   body { 
      font-size:12pt; 
      max-width:100%; 
   }
       
   a, a:visited { 
      text-decoration: underline; 
   }

   hr { 
      visibility: hidden;
      page-break-before: always;
   }

   pre, blockquote { 
      padding-right: 1em; 
      page-break-inside: avoid; 
   }

   tr, img { 
      page-break-inside: avoid; 
   }

   img { 
      max-width: 100% !important; 
   }

   @page :left { 
      margin: 15mm 20mm 15mm 10mm; 
   }
     
   @page :right { 
      margin: 15mm 10mm 15mm 20mm; 
   }

   p, h2, h3 { 
      orphans: 3; widows: 3; 
   }

   h2, h3 { 
      page-break-after: avoid; 
   }
}

</style>





</head>

<body>
<h1>How do I: Record my advisee&#39;s nickname on diy.org?</h1>

<p>Rationale: diy.org is a powerful, free platform that lets students develop their talents and interests.  Rise is encouraging students to explore the different skills (<a href="https://diy.org/skills/sort/title">https://diy.org/skills/sort/title</a>) on the site and find something of interest to them.  We will report/showcase diy.org progress on the Rutgers Ready student report!</p>

<h3>1)  Log in to PowerTeacher.  Click on the Backpack (Info)</h3>

<p><img src="\\WINSQL01\r_images\step1.jpg"></p>

<h3>2)  Click a student&#39;s name.</h3>

<p><img src="\\WINSQL01\r_images\step2.jpg"></p>

<h3>3)  In the &#39;select screens&#39; dropdown, click &#39;Submit DIY Nickname&#39;</h3>

<p><img src="\\WINSQL01\r_images\step3.jpg"></p>

<h3>4)  4)	<b>Take the student&#39;snickname from their diy.org page.</b>  Use the nickname in the URL – it won’t have any spaces or capitalization.</h3>

<p><img src="\\WINSQL01\r_images\step4A.jpg"></p>

<h3>5)  Paste it into the page on PowerTeacher and submit.</h3>

<p><img src="\\WINSQL01\r_images\step5.jpg"></p>

<p><strong>Q: What if I do not teach this student (and thus do not have them in PowerTeacher) - how do I submit their name?</strong>
On PowerSchool admin side, navigate to Custom Screens/5_Classroom/Team/Travel and Advisor Info
diy.org Nickname appears there; enter it and submit.</p>'
        ,' '
        --csv stuff
        ,'On'
        ,'SELECT TOP 100000000 roster.grade_level
                ,roster.student_name
                ,cust.advisor
                ,cust.diy_nickname
          FROM 
            (SELECT CAST(c.grade_level AS VARCHAR) AS grade_level
                   ,c.lastfirst
                   ,s.first_name + '' '' + s.last_name AS student_name
                   ,c.studentid
             FROM KIPP_NJ..COHORT$comprehensive_long#static c
             JOIN KIPP_NJ..STUDENTS s
               ON c.studentid = s.id
             WHERE c.year = 2013 
               AND c.schoolid = 73252
               AND c.rn = 1
            ) roster
          JOIN KIPP_NJ..CUSTOM_STUDENTS cust
            ON roster.studentid = cust.studentid
          ORDER BY roster.grade_level
                  ,cust.advisor
                  ,roster.lastfirst'
        --table query 1
        ,'SELECT TOP 100000000 roster.grade_level
                ,roster.student_name
                ,cust.advisor
                ,cust.diy_nickname
          FROM 
            (SELECT CAST(c.grade_level AS VARCHAR) AS grade_level
                   ,c.lastfirst
                   ,s.first_name + '' '' + s.last_name AS student_name
                   ,c.studentid
             FROM KIPP_NJ..COHORT$comprehensive_long#static c
             JOIN KIPP_NJ..STUDENTS s
               ON c.studentid = s.id
             WHERE c.year = 2013 
               AND c.schoolid = 73252
               AND c.rn = 1
            ) roster
          JOIN KIPP_NJ..CUSTOM_STUDENTS cust
            ON roster.studentid = cust.studentid
           AND cust.diy_nickname IS NULL
          ORDER BY roster.grade_level
                  ,cust.advisor
                  ,roster.lastfirst'
          --table query 2
         ,' '
         --table query 3
         ,' '
          --table style parameters
         ,'CSS_medium'
         ,' '
         ,' '
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
    ,[image_count]
    ,[image_path1]
    ,[image_path2]
    ,[explanatory_text1]
    ,[explanatory_text2]
    ,[explanatory_text3]
    ,[explanatory_text4]
    ,[csv_toggle]
    ,[csv_query]
    ,[table_query1]
    ,[table_query2]
    ,[table_query3]
    ,[table_style1]
    ,[table_style2]
    ,[table_style3]
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
       ,target.image_count =  source.image_count
       ,target.image_path1 =  source.image_path1
       ,target.image_path2 =  source.image_path2
       ,target.explanatory_text1 =  source.explanatory_text1
       ,target.explanatory_text2 =  source.explanatory_text2
       ,target.explanatory_text3 =  source.explanatory_text3
       ,target.explanatory_text4 =  source.explanatory_text4
       ,target.csv_toggle =  source.csv_toggle
       ,target.csv_query =  source.csv_query
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_query3 =  source.table_query3
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2
       ,target.table_style3 =  source.table_style3
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
     ,[image_count]
     ,[image_path1]
     ,[image_path2]
     ,[explanatory_text1]
     ,[explanatory_text2]
     ,[explanatory_text3]
     ,[explanatory_text4]
     ,[csv_toggle]
     ,[csv_query]
     ,[table_query1]
     ,[table_query2]
     ,[table_query3]
     ,[table_style1]
     ,[table_style2]
     ,[table_style3]
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
     ,source.image_count
     ,source.image_path1
     ,source.image_path2
     ,source.explanatory_text1
     ,source.explanatory_text2
     ,source.explanatory_text3
     ,source.explanatory_text4
     ,source.csv_toggle
     ,source.csv_query
     ,source.table_query1
     ,source.table_query2
     ,source.table_query3
     ,source.table_style1
     ,source.table_style2
     ,source.table_style3
   );

END