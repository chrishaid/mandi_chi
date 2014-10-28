USE PS_mirror
GO

CREATE VIEW PS$terms AS 

SELECT *
FROM OPENQUERY(PS_CHI,'
  SELECT *
  FROM terms
')

SELECT * from [dbo].PS$terms;