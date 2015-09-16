USE ST_Math
GO

CREATE VIEW progress_completion#identifiers AS
SELECT p.*
      ,s.id AS studentid
FROM ST_Math..progress_completion p
JOIN PS_mirror..students s
  ON p.school_student_id = s.student_number