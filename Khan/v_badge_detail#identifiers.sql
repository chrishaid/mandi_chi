USE Khan
GO

ALTER VIEW badge_detail#identifiers AS
SELECT s.id AS studentid
      ,sub.*
FROM
      (SELECT b.*
             ,REPLACE(stu_detail.identity_email, '@teamstudents.org', '') + '.student' AS id_key
       FROM Khan..badge_detail b WITH(NOLOCK)
       JOIN Khan..stu_detail WITH(NOLOCK)
         ON b.student = stu_detail.student
       ) sub
JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
  ON sub.id_key = s.student_web_id