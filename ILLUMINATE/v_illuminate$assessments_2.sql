USE Illuminate_mirror
GO

ALTER VIEW assessments AS

SELECT *      
FROM OPENQUERY(ILL_CHI,'
  SELECT	sa.code_id AS subject_area_id,
			sa.code_translation as subject_area, 
			a.*
  FROM dna_assessments.assessments a 
  LEFT JOIN codes.dna_subject_areas sa
  ON a.code_subject_area_id = sa.code_id
')