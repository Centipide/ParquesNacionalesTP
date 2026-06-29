-- ============================================================
-- Fecha: 2025-06-15
-- Descripción: Creación de la logica de negocia para Registro
--              de Actividades
-- ============================================================



/*
	Cuando se registra una Actividad realizada, deberíamos
	verificar:
	- Que exista la actividad Programada
	- Que la actividad Programada no esté en estado Cancelada o
	  Realizada (osea que este en Programada)
	- Que exista al menos una contratacion vinculada
	- Que exista al menos una contratacion en estado confirmada
	y Realizar:
	- Cambiar el estado de la ActividadProgramada a Realizada
	- Cambiar el estado de la contratacion vinculada a Realizada.
*/




USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Actividades.sp_AltaActividadRealizada
	@idActividadProgramada	INT,
	@observaciones			VARCHAR(300) = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @errores VARCHAR(500) = '';

	DECLARE @estadoActividad VARCHAR(20);
	SELECT @estadoActividad = estado
	FROM Actividades.ActividadProgramada
	WHERE idActividadProgramada = @idActividadProgramada;
	
	IF @estadoActividad IS NULL
		SET @errores = @errores + 'El id de Actividad Programada no existe' + CHAR(10);

	ELSE IF @estadoActividad <> 'Programada'
		SET @errores = @errores + 'La Actividad Programada ya estaba en estado ' + @estadoActividad + CHAR(10);
	
	ELSE
	BEGIN
		IF NOT EXISTS (
			SELECT 1
			FROM Actividades.Contratacion
			WHERE idActividadProgramada = @idActividadProgramada
		)
			SET @errores = @errores + 'No existen contrataciones vinculadas a la actividad.' + CHAR(10);

    ELSE IF NOT EXISTS (
        SELECT 1
        FROM Actividades.Contratacion
        WHERE idActividadProgramada = @idActividadProgramada
          AND estado = 'Confirmada'
    )
        SET @errores = @errores + 'No existen contrataciones confirmadas para la actividad.' + CHAR(10);
	END

	IF @errores != ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

	BEGIN TRY
		BEGIN TRANSACTION

			UPDATE Actividades.ActividadProgramada
			SET estado = 'Realizada',
				observaciones = @observaciones
			WHERE idActividadProgramada = @idActividadProgramada;

			UPDATE Actividades.Contratacion
			SET estado = 'Completada'
			WHERE idActividadProgramada = @idActividadProgramada
			  AND estado = 'Confirmada';

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;

	END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.sp_CancelarActividadProgramada
    @idActividadProgramada INT,
    @observaciones         VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    DECLARE @estadoActividad VARCHAR(20);
    SELECT @estadoActividad = estado
    FROM Actividades.ActividadProgramada
    WHERE idActividadProgramada = @idActividadProgramada;

    IF @estadoActividad IS NULL
        SET @errores = @errores + 'El id de Actividad Programada no existe. ';

    ELSE IF @estadoActividad <> 'Programada'
        SET @errores = @errores + 'La Actividad Programada ya estaba en estado ' + @estadoActividad + '. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    BEGIN TRY

        BEGIN TRANSACTION

            UPDATE Actividades.ActividadProgramada
            SET estado = 'Cancelada',
                observaciones = @observaciones
            WHERE idActividadProgramada = @idActividadProgramada;

            UPDATE Actividades.Contratacion
            SET estado = 'Cancelada'
            WHERE idActividadProgramada = @idActividadProgramada
              AND estado = 'Confirmada';

        COMMIT TRANSACTION

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.sp_CancelarContratacion
    @idContratacion INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    DECLARE @estadoContratacion VARCHAR(20);
    SELECT @estadoContratacion = estado
    FROM Actividades.Contratacion
    WHERE idContratacion = @idContratacion;

    IF @estadoContratacion IS NULL
        SET @errores = @errores + 'El id de Contratacion no existe. ';

    ELSE IF @estadoContratacion <> 'Confirmada'
        SET @errores = @errores + 'La Contratacion ya estaba en estado ' + @estadoContratacion + '. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Actividades.Contratacion
    SET estado = 'Cancelada'
    WHERE idContratacion = @idContratacion;
END
GO


