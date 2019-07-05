/****** Object:  UserDefinedFunction [dbo].[fn_extractupper]    Script Date: 6/10/2019 10:35:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fn_extractupper](@var varchar(500))
returns varchar(500)
as
begin

declare @lab varchar(500) = @var
declare @aux varchar(500) = ''
declare @size int = len(@var)
declare @position int = 0
while @position < @size
	begin
	   
		if ASCII(SUBSTRING(@var,@position,1)) = ASCII(UPPER(SUBSTRING(@var,@position,1)))
        if @position  > 1 
            ----- check for char before = upper -----
            AND ASCII(SUBSTRING(@var,@position - 1,1)) <> ASCII(UPPER(SUBSTRING(@var,@position - 1,1)))
            ----- check for char before = space -----
            AND SUBSTRING(@var,@position,1) <> ' '
	       begin
			begin
			    set @lab = replace(@lab,SUBSTRING(@var,@position,1), ' ' + SUBSTRING(@var,@position,1) )
				set @aux = @aux + SUBSTRING(@var,@position,1)
			end
	     END
		set @position = @position + 1
	   
	end

return @lab
END
