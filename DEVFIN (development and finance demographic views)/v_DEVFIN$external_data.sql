USE KIPP_NJ
GO

ALTER VIEW DEVFIN$external_data AS

-- CTEs clean up school roster, make DB-friendly
-- Newark (disaggregated), NJ, Essex County, Montclair
-- all counties = 99
-- all districts = 9999
-- all schools = 999
-- all grades = 99

WITH newark AS (
-- disaggregated by school to all for neighborhood comparisons
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname                
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99 -- breaking convention here but it's consistent with county/district/school code
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3570
    AND [SCHOOL CODE] != 999 -- exclde district totals, we can roll up to this
    AND GRADE_LEVEL NOT IN ('PK','UG') -- exclude Pre-K and Graduated students
    
    
  UNION ALL
  
  -- no enrollment data for 2011, but we have it for NJASK, need to synthesize it for the roster
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3570
    AND GRADE_LEVEL NOT IN ('PK','UG')
 )
      
,nj_state AS (
-- state totals
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 99
    AND GRADE_LEVEL NOT IN ('PK','UG')
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 99
    AND GRADE_LEVEL NOT IN ('PK','UG')
 )
 
,montclair AS (
-- because f%@# them
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3310
    AND [SCHOOL CODE] = 999
    AND GRADE_LEVEL NOT IN ('PK','UG')
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3310
    AND [SCHOOL CODE] = 999
    AND GRADE_LEVEL NOT IN ('PK','UG')
 )
 
,essex_county AS (
-- county total
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 13
    AND [DISTRICT CODE] = 9999
    AND GRADE_LEVEL NOT IN ('PK','UG')
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 13
    AND [DISTRICT CODE] = 9999
    AND GRADE_LEVEL NOT IN ('PK','UG')
 )
 
,districts AS (
-- combine above CTEs to keep things clean
  SELECT *
  FROM newark

  UNION ALL

  SELECT *
  FROM nj_state

  UNION ALL

  SELECT *
  FROM essex_county

  UNION ALL

  SELECT *
  FROM montclair
 )
 
,enrollment_data AS (
-- and now for the actual data
  SELECT DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,CASE
          WHEN grade_level = 'KG' THEN 0        
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
        ,FLOOR(ROW_TOTAL) AS enrollment
        ,FLOOR([WH_M] + [WH_F]) AS W
        ,FLOOR([BL_M] + [BL_F]) AS B
        ,FLOOR([HI_M] + [HI_F]) AS H
        ,FLOOR([AS_M] 
          + [AS_F]
          + [AM_M] 
          + [AM_F]
          + [PI_M]
          + [PI_F]
          + [MU_M]
          + [MU_F])
          AS O
        ,FLOOR([WH_M]
          + [BL_M]
          + [HI_M]
          + [AS_M]        
          + [AM_M]        
          + [PI_M]        
          + [MU_M])     
          AS M
        ,FLOOR([WH_F]
          + [BL_F]
          + [HI_F]
          + [AS_F]        
          + [AM_F]        
          + [PI_F]        
          + [MU_F])
          AS F
        ,FLOOR([FREE_LUNCH]) AS Free
        ,FLOOR([REDUCED_PRICE_LUNCH]) AS Reduced
        ,FLOOR(FREE_LUNCH + REDUCED_PRICE_LUNCH) AS FARM
        ,FLOOR(ROW_TOTAL - [FREE_LUNCH] - [REDUCED_PRICE_LUNCH]) AS Paid
        ,FLOOR(LEP) AS LEP
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] IN (3310,3570,9999)
    AND GRADE_LEVEL NOT IN ('PK','UG')
 ) 

SELECT districts.*
      ,enrollment_data.enrollment
      ,enrollment_data.W
      ,enrollment_data.B
      ,enrollment_data.H
      ,enrollment_data.O
      ,enrollment_data.M
      ,enrollment_data.F
      ,enrollment_data.Free
      ,enrollment_data.Reduced
      ,enrollment_data.FARM
      ,enrollment_data.Paid
      ,enrollment_data.LEP
FROM districts 
LEFT OUTER JOIN enrollment_data
  ON districts.academic_year = enrollment_data.academic_year
 AND districts.county_code = enrollment_data.county_code
 AND districts.district_code = enrollment_data.district_code
 AND districts.school_code = enrollment_data.school_code
 AND districts.grade_level = enrollment_data.grade_level