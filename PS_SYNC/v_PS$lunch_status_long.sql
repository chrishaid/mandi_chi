USE KIPP_NJ
GO

ALTER VIEW PS$lunch_status_long AS

-- archived in custom fields
SELECT sub2.studentid
      ,sub2.year
      ,sub2.lunch_status
FROM
    (
     SELECT sub.*
           ,ROW_NUMBER() OVER(
               PARTITION BY studentid, year, lunch_status
                   ORDER BY lunch_status) AS rn
     FROM
         (
          SELECT studentid
                ,CASE
                  WHEN field_name LIKE ('%0708%') THEN 2007
                  WHEN field_name LIKE ('%0809%') THEN 2008
                  WHEN field_name LIKE ('%0910%') THEN 2009
                  WHEN field_name LIKE ('%1011%') THEN 2010
                  WHEN field_name LIKE ('%1112%') THEN 2011
                  WHEN field_name LIKE ('%1213%') THEN 2012                          
                 END AS year        
                ,CASE                  
                  WHEN string_value = 'Free' THEN 'F'
                  WHEN string_value = 'TANF' THEN 'F'
                  WHEN LOWER(string_value) LIKE '%food%stamp%' THEN 'F'
                  WHEN string_value = 'Reduced' THEN 'R'
                  WHEN string_value = 'Paid' THEN 'P'        
                  WHEN string_value = 'Income too high' THEN 'P'
                  WHEN LOWER(string_value) LIKE '%direct%cert%' THEN 'Direct Certified'                                    
                  WHEN UPPER(LTRIM(RTRIM(string_value))) IN ('F','R','P') THEN UPPER(LTRIM(RTRIM(string_value)))
                  WHEN string_value = 'Incomplete' THEN 'NoD'
                  ELSE 'NoD'
                 END AS lunch_status
          FROM OPENQUERY(PS_TEAM,'
            SELECT field_name
                  ,string_value
                  ,studentid
            FROM PVSIS_CUSTOM_STUDENTS
            WHERE LOWER(field_name) LIKE (''%lunch_status%'')
              AND LOWER(field_name) NOT LIKE (''%category%'')
          ')
         ) sub
    ) sub2
WHERE rn = 1

UNION ALL

-- archived in EXT table
SELECT studentid
      ,CONVERT(INT,'20' + SUBSTRING(REVERSE(year), 2, 2)) AS year
      ,lunch_status
FROM OPENQUERY(PS_TEAM,'
  SELECT s.id AS studentid
        ,ext.lunchstatus_1314
  FROM U_DEF_EXT_STUDENTS ext
  JOIN students s
    ON ext.studentsdcid = s.dcid
  WHERE ext.lunchstatus_1314 IS NOT NULL
')

UNPIVOT (
  lunch_status
  FOR year IN (lunchstatus_1314)
 ) u

UNION ALL

-- current year
SELECT studentid
      ,year
      ,s.LUNCHSTATUS AS lunch_status
FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
JOIN STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.id
WHERE co.year = 2014
  AND co.grade_level < 99
  AND co.rn = 1