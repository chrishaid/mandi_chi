USE [PS_mirror]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_DateToSY] (@date DATE)
  RETURNS INT
  AS

BEGIN
  RETURN CASE WHEN DATEPART(MONTH,@date) < 7 THEN DATEPART(YEAR,@date) - 1 ELSE DATEPART(YEAR,@date) END;
END

GO