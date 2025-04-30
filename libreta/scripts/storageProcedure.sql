create PROCEDURE I_Persona
    @Apellido VARCHAR(64),
    @Nombre VARCHAR(64),
    @dni INTEGER,
    @id int out
as
Begin 
    Begin try 
        insert into Persona(Apellido, Nombre, dni)
        values (@Apellido, @Nombre, @dni)
        select @id = @@IDENTITY
    end try
    begin catch
        select ERROR_NUMBER() as ErrorNumber,
            ERROR_MESSAGE() as ErrorMessage,
            ERROR_SEVERITY() as ErrorSeverity,
            ERROR_STATE() as ErrorState,
            ERROR_PROCEDURE() as ErrorProcedure
    end catch
end
declare @id int
EXEC I_Persona "MARTINI", "JULIAN", 12345678, @id
select @id

