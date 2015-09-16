USE Illuminate_mirror
GO

ALTER VIEW dbo.assessment_results_by_question_group_detail

AS 

WITH
ag AS
(
SELECT	ass.*, 
		rg.label AS reporting_group
FROM dbo.assessment_results_by_question_group ass
LEFT JOIN OPENQUERY(ILL_CHI, 'SELECT * FROM dna_assessments.reporting_groups') rg
ON ass.reporting_group_id = rg.reporting_group_id
),
assess AS
(
SELECT * 
FROM assessments
),
students as 
(
SELECT * FROM OPENQUERY(ILL_CHI, 'SELECT student_id, local_student_id FROM public.students')
)

SELECT r.*,
	   students.local_student_id
FROM
(SELECT	assess.local_assessment_id,
		assess.subject_area_id,
		assess.subject_area, 
		assess.administered_at,
		assess.title,
		assess.description,
		assess.academic_year,
		ag.*
FROM		ag 
LEFT JOIN	assess 
ON ag.assessment_id = assess.assessment_id 
) r
LEFT JOIN students
ON r.student_id = students.student_id
;