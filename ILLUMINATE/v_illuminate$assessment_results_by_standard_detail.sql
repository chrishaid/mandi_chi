USE Illuminate_mirror
GO

CREATE VIEW assessment_result_by_standard_detail AS

SELECT	a.subject_area_id,
		a.subject_area, 
		r.*
FROM		dbo.assessment_results_by_standard r
LEFT JOIN	dbo.assessments a
ON a.assessment_id = r.assessment_id
;
