-- ========================================================================
-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Objetivo del Código: Lógica Avanzada de Asignacion de Guias
-- ========================================================================
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE Com5600G05_ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Guias.sp_AsignacionGuia
    @idGuia                 INT,
    @idActividadTuristica   INT,
    @fecha                  DATE,
    @horaInicio             TIME,
    @observaciones          VARCHAR(300)= NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores    VARCHAR(500) ='';
    DECLARE @vigencia   DATE;
    DECLARE @activo     BIT;

    -- Guia existe
    IF NOT EXISTS (
        SELECT 1 
        FROM Guias.Guia WHERE idGuia = @idGuia
        )
        SET @errores += 'El guia no existe.' + CHAR(10);
    
    -- Guia activo y vigencia (solo si existe)
    IF @errores = ''
    BEGIN
        SELECT @vigencia = vigenciaAutorizacion,
               @activo = estaActivo
        FROM Guias.Guia
        WHERE idGuia = @idGuia;

        IF ISNULL( @activo, 0) = 0
            SET @errores += 'El guia no esta activo' + CHAR(10);
        
        IF @vigencia < @fecha
            SET @errores += 'La vigencia de autorizacion del guia esta vencida para la fecha indicada.' + CHAR(10);
    END

    IF NOT EXISTS (
            SELECT 1 FROM Actividades.ActividadTuristica
            WHERE idActividadTuristica = @idActividadTuristica
        )
        SET @errores += 'La actividad turistica no existe.' + CHAR(10);

    
    IF @fecha IS NULL
        SET @errores += 'La fecha no puede estar vacia.' + CHAR(10);

    
    IF @horaInicio IS NULL
        SET @errores += 'La hora de inicio no puede estar vacia.' + CHAR(10);  

    IF  EXISTS (
        SELECT 1 FROM Actividades.ActividadProgramada
        WHERE idGuia = @idGuia AND fecha = @fecha AND   horaInicio = @horaInicio AND estado != 'Cancelada'
        )
        SET @errores += 'El guia tiene una actividad programada en esta fecha y horario.' + CHAR(10)

    IF @errores != ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    BEGIN TRANSACTION

    INSERT INTO Actividades.ActividadProgramada
        (idGuia, idActividadTuristica, fecha, horaInicio, observaciones)
    VALUES
        (@idGuia, @idActividadTuristica, @fecha, @horaInicio, @observaciones);

    COMMIT TRANSACTION;

END
GO

