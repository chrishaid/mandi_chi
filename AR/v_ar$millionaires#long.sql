USE KIPP_NJ
GO

ALTER VIEW AR$millionaires#long AS

WITH scaffold AS (
  SELECT c.student_number
        ,c.grade_level
        ,sch.abbreviation AS school
        ,c.year
        ,CONVERT(datetime, '07/01/' + CONVERT(VARCHAR,c.year), 101) AS start_date_ar        
        ,CAST(rd.date AS DATE) AS date        
  FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH (NOLOCK)
  JOIN KIPP_NJ..UTIL$reporting_days#static rd WITH (NOLOCK)
    ON c.entrydate <= rd.date
   AND c.exitdate > rd.date
  JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
    ON c.schoolid = sch.school_number
  WHERE c.schoolid IN (73252, 133570965, 73253)
    AND c.year >= 2010
    AND c.schoolid != 999999
    AND c.rn = 1
    --testing
    --AND s.last_name = 'Williams'
    --AND c.year = 2012
 )

SELECT CASE GROUPING(sub.grade_level) WHEN 1 THEN 'School' ELSE CONVERT(NVARCHAR,sub.grade_level) END AS grade_level
      ,sub.school
      ,sub.year
      ,sub.date
      ,CONVERT(VARCHAR,DATEPART(MONTH,sub.date)) + '/' + CONVERT(VARCHAR,DATEPART(DAY,sub.date)) AS date_no_year
      ,SUM(millionaire_test) AS millionaires
      ,ROUND(AVG(CONVERT(FLOAT,millionaire_test)) * 100,0) AS pct_millionaire
FROM
    (
     SELECT sub.*
           ,CASE WHEN sub.words >= 1000000 THEN 1 ELSE 0 END AS millionaire_test
     FROM
         (
          SELECT scaffold.grade_level
                ,scaffold.school
                ,scaffold.year
                ,scaffold.date                
                ,SUM(CASE WHEN det.tipassed = 1 THEN det.iwordcount ELSE 0 END) AS words
          FROM scaffold WITH(NOLOCK)
          JOIN KIPP_NJ..AR$test_event_detail#static det WITH (NOLOCK)
            ON scaffold.student_number = det.student_number
           AND det.dtTaken >= scaffold.start_date_ar
           AND det.dtTaken <  scaffold.date
          GROUP BY scaffold.grade_level
                  ,scaffold.school
                  ,scaffold.year
                  ,scaffold.date                  
         ) sub
    ) sub
GROUP BY CUBE(sub.grade_level)
        ,sub.school
        ,sub.year
        ,sub.date        