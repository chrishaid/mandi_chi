USE KIPP_NJ
GO

ALTER VIEW AR$goals_staging AS

WITH goals AS (
  SELECT [student_number]      
        ,73253 AS schoolid                  
        ,NULL AS words_goal      
        ,CONVERT(FLOAT,[points_goal]) AS points_goal
        ,2400 AS yearid
        ,CASE
          WHEN [term] = 'Q1' THEN 'Reporting Term 1'
          WHEN [term] = 'Q2' THEN 'Reporting Term 2'
          WHEN [term] = 'Q3' THEN 'Reporting Term 3'
          WHEN [term] = 'Q4' THEN 'Reporting Term 4'
          WHEN [term] = 'Y1' THEN 'Year'
         END AS time_period_name
        ,CASE
          WHEN [term] IN ('Q1','Q2','Q3','Q4') THEN 2
          WHEN [term] = 'Y1' THEN 1
         END AS time_period_hierarchy
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_NCA] WITH(NOLOCK)
  WHERE student_number IS NOT NULL

  UNION ALL

  SELECT [student_number]
        ,133570965 AS schoolid
        ,COALESCE([Adjusted Goal], [Default Goal]) AS words_goal
        ,NULL AS points_goal
        ,2400 AS yearid      
        ,CASE WHEN cycle IS NULL THEN 'Year' ELSE 'Hexameter ' + CONVERT(VARCHAR,[Cycle]) END AS time_period_name
        ,CASE WHEN Cycle IS NULL THEN 1 ELSE 2 END AS time_period_hierarchy
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_TEAM] WITH(NOLOCK)
  WHERE student_number IS NOT NULL  

  UNION ALL

  SELECT [student_number]
        ,73252 AS schoolid
        ,COALESCE([Adjusted Goal], [Words Goal]) AS words_goal
        ,NULL AS points_goal
        ,2400 AS yearid      
        ,CASE WHEN cycle IS NULL THEN 'Year' ELSE 'Hexameter ' + CONVERT(VARCHAR,[Cycle]) END AS time_period_name
        ,CASE WHEN Cycle IS NULL THEN 1 ELSE 2 END AS time_period_hierarchy
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_Rise] WITH(NOLOCK)
  WHERE student_number IS NOT NULL      
 )

SELECT goals.student_number
      ,goals.schoolid
      ,goals.words_goal
      ,goals.points_goal
      ,goals.yearid
      ,goals.time_period_name      
      ,dt.start_date AS time_period_start
      ,dt.end_date AS time_period_end
      ,goals.time_period_hierarchy
      ,ROW_NUMBER() OVER(
         PARTITION BY goals.student_number, goals.time_period_name
           ORDER BY goals.time_period_name) AS rn
FROM goals
JOIN REPORTING$dates dt WITH(NOLOCK)
  ON (goals.schoolid = dt.schoolid OR (dt.identifier = 'SY' AND dt.schoolid IS NULL))
 AND LEFT(goals.yearid, 2) = dt.yearid
 AND goals.time_period_name = CASE WHEN dt.time_per_name = 'Y1' THEN 'Year' ELSE dt.time_per_name END
 AND dt.identifier IN ('RT_IR', 'HEX', 'SY')