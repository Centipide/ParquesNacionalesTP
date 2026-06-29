-- ===============================================================================
-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Objetivo del Código: Script de Testing 1:1 para Lógica de Asignacion de Guias
-- ===============================================================================
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ==============================================================================


USE ParquesNacionales;
GO

-- ============================================================
-- CASO EXITOSO
-- ============================================================

BEGIN TRANSACTION

    DECLARE @idGuia               INT;
    DECLARE @idActividadTuristica INT;
    DECLARE @idTipoParque         INT;
    DECLARE @idParque             INT;
    DECLARE @idTipoActividad      INT;

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_Tipo', 'Tipo de prueba');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'Neuquen', 500.00);
    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');
    SET @idTipoActividad = SCOPE_IDENTITY();

    INSERT INTO Actividades.ActividadTuristica
        (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES
        (@idParque, @idTipoActividad, 'TEST_Trekking', 1500, 120, 15);
    SET @idActividadTuristica = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES
        ('TEST_Carlos', 'TEST_Gomez', '1990-05-10', 'DNI', '30500600', 'cgomez@test.com', '2030-01-01', 1);
    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

        EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00',
        @observaciones        = 'TEST_Asignacion exitosa';

    PRINT 'Actividad programada generada:';
    SELECT * FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND fecha = '2026-12-01';

ROLLBACK TRANSACTION;
GO

-- ============================================================
-- CASOS FALLIDOS
-- ============================================================

---guia inexistente y actividad inexistente
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY

    EXEC Guias.sp_AsignacionGuia
        @idGuia               = -1,
        @idActividadTuristica = -1,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';

END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

GO


--guia inactivo
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    DECLARE @idGuiaInactivo       INT;
    DECLARE @idActInactivo        INT;
    DECLARE @idTipoParqueInac     INT;
    DECLARE @idParqueInac         INT;
    DECLARE @idTipoActInac        INT;

    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Tipo','x');
    SET @idTipoParqueInac = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParqueInac, 'TEST_Parque', 'TEST_region', 'Neuquen', 100);
    SET @idParqueInac = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion) VALUES ('TEST_Tipo');
    SET @idTipoActInac = SCOPE_IDENTITY();

    INSERT INTO Actividades.ActividadTuristica
        (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParqueInac, @idTipoActInac, 'TEST_Act', 1000, 60, 10);
    SET @idActInactivo = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES ('TEST', 'TEST', '1990-01-01', 'DNI', '11111111', 'inactivo@test.com', '2030-01-01', 0); -- inactivo
    SET @idGuiaInactivo = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuiaInactivo, @idActInactivo);

    EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuiaInactivo,
        @idActividadTuristica = @idActInactivo,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO

-- vigencia vencida

USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    DECLARE @idGuiaVenc      INT;
    DECLARE @idActVenc       INT;
    DECLARE @idTipoParqVenc  INT;
    DECLARE @idParqVenc      INT;
    DECLARE @idTipoActVenc   INT;

    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Tipo','x');
    SET @idTipoParqVenc = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParqVenc, 'TEST_Parque', 'TEST_region', 'Neuquen', 100);
    SET @idParqVenc = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion) VALUES ('TEST_Tipo');
    SET @idTipoActVenc = SCOPE_IDENTITY();

    INSERT INTO Actividades.ActividadTuristica
        (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParqVenc, @idTipoActVenc, 'TEST_Actividad', 1000, 60, 10);
    SET @idActVenc = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES ('TEST_nombre', 'TEST_apellido', '1990-01-01', 'DNI', '22222222', 'venc@test.com', '2020-01-01', 1); -- vigencia vencida
    SET @idGuiaVenc = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuiaVenc, @idActVenc);

    EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuiaVenc,
        @idActividadTuristica = @idActVenc,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO


-----------guia no autorizado para la actividad
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    DECLARE @idGuiaSinAut    INT;
    DECLARE @idActSinAut     INT;
    DECLARE @idTipoParqSA    INT;
    DECLARE @idParqSA        INT;
    DECLARE @idTipoActSA     INT;

    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Tipo','x');
    SET @idTipoParqSA = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParqSA, 'TEST_Parque', 'TEST_region', 'Neuquen', 100);
    SET @idParqSA = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion) VALUES ('TEST_Tipo');
    SET @idTipoActSA = SCOPE_IDENTITY();

    INSERT INTO Actividades.ActividadTuristica
        (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParqSA, @idTipoActSA, 'TEST_Actividad', 1000, 60, 10);
    SET @idActSinAut = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES ('TEST_nombre', 'TEST_apellido', '1990-01-01', 'DNI', '33333333', 'sinaut@test.com', '2030-01-01', 1);
    SET @idGuiaSinAut = SCOPE_IDENTITY();

    -- No insertamos GuiaAutorizacion

    EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuiaSinAut,
        @idActividadTuristica = @idActSinAut,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-------- conflicto de horario
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    DECLARE @idGuiaConf      INT;
    DECLARE @idActConf       INT;
    DECLARE @idTipoParqConf  INT;
    DECLARE @idParqConf      INT;
    DECLARE @idTipoActConf   INT;

    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Tipo','x');
    SET @idTipoParqConf = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParqConf, 'TEST_Parque', 'TEST_region', 'Neuquen', 100);
    SET @idParqConf = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion) VALUES ('TEST_Tipo');
    SET @idTipoActConf = SCOPE_IDENTITY();

    INSERT INTO Actividades.ActividadTuristica
        (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParqConf, @idTipoActConf, 'TEST_Actividad', 1000, 60, 10);
    SET @idActConf = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES ('TEST_nombre', 'TEST_apellido', '1990-01-01', 'DNI', '44444444', 'conf@test.com', '2030-01-01', 1);
    SET @idGuiaConf = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuiaConf, @idActConf);

    -- Primera asignacion exitosa
    EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuiaConf,
        @idActividadTuristica = @idActConf,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';

    -- Segunda en el mismo horario: debe fallar
    EXEC Guias.sp_AsignacionGuia
        @idGuia               = @idGuiaConf,
        @idActividadTuristica = @idActConf,
        @fecha                = '2026-12-01',
        @horaInicio           = '09:00';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
GO
