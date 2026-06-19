-- ============================================================
-- Fecha: 2025-06-16
-- Descripción: Scripts de Testing
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales
GO

-- ************************************************************
-- CASOS DE ERROR - Parque
-- ************************************************************
USE ParquesNacionales
GO
-- idTipoParque no existente, nombre vacio, region vacia, provincia vacia, superficie invalida
BEGIN TRY
	EXEC Parques.sp_AltaParque @idTipoParque = 54, @nombre = '',
		@region = '', @provincia = '', @superficie = '0'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idParque no existe, idTipoParque no existe, superficie invalida
BEGIN TRY
	EXEC Parques.sp_ModificacionParque  @idParque = 1, @idTipoParque = 54, @nombre = '',
		@region = '', @provincia = '', @superficie = '0'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idParque no existe
BEGIN TRY
	EXEC Parques.sp_BajaParque  @idParque = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- ===========================================================
-- CASOS EXITOSOS - Parque
-- ============================================================
USE ParquesNacionales
GO

BEGIN TRANSACTION

    DECLARE @idTipoParque_TEST INT,
            @idParque_TEST     INT

    -- Alta exitosa
    EXEC Parques.sp_AltaTipoParque
        @nombre = 'Parque Nacional', @descripcion = 'Jurisdiccion nacional'

    SELECT @idTipoParque_TEST = idTipoParque
    FROM Parques.TipoParque
    WHERE nombre = 'Parque Nacional'

    EXEC Parques.sp_AltaParque
        @idTipoParque = @idTipoParque_TEST, @nombre = 'Parque Nacional Nahuel Huapi',
        @region = '-', @provincia = 'Rio Negro', @superficie = 717.26

    SELECT @idParque_TEST = idParque
    FROM Parques.Parque
    WHERE nombre = 'Parque Nacional Nahuel Huapi'

    SELECT *
    FROM Parques.Parque


    -- Modificación exitosa
    EXEC Parques.sp_ModificacionParque
        @idParque = @idParque_TEST, @idTipoParque = @idTipoParque_TEST, @nombre = 'Parque Nacional Laguna Blanca',
        @region = '', @provincia = 'Neuquen', @superficie = 11.25

    SELECT *
    FROM Parques.Parque


    -- Baja exitosa
    EXEC Parques.sp_BajaParque
        @idParque = @idParque_TEST

    SELECT *
    FROM Parques.Parque

    EXEC Parques.sp_BajaTipoParque
        @idTipoParque = @idTipoParque_TEST

ROLLBACK TRANSACTION


-- ************************************************************
-- CASOS DE ERROR - TipoParque
-- ************************************************************
-- idTipoParque no ingresado
BEGIN TRY
	EXEC Parques.sp_AltaTipoParque @nombre = '', @descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idTipoParque no ingresado, nombre no ingresado
BEGIN TRY
	EXEC Parques.sp_ModificacionTipoParque @idTipoParque = 1, @nombre = '', @descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idTipoParque no existe
BEGIN TRY
	EXEC Parques.sp_BajaTipoParque  @idTipoParque = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- ===========================================================
-- CASOS EXITOSOS - TipoParque
-- ============================================================
USE ParquesNacionales
GO

BEGIN TRANSACTION

    DECLARE @idTipoParque_TEST INT

    -- Alta exitosa
    EXEC Parques.sp_AltaTipoParque
        @nombre = 'Parque Nacional', @descripcion = 'Jurisdiccion nacional'

    SELECT @idTipoParque_TEST = idTipoParque
    FROM Parques.TipoParque
    WHERE nombre = 'Parque Nacional'

    SELECT *
    FROM Parques.TipoParque

    -- Modificación exitosa
    EXEC Parques.sp_ModificacionTipoParque
        @idTipoParque = @idTipoParque_TEST, @nombre = 'Reserva Natural', @descripcion = ''

    SELECT *
    FROM Parques.TipoParque


    -- Baja exitosa
    EXEC Parques.sp_BajaTipoParque
        @idTipoParque = @idTipoParque_TEST

    SELECT *
    FROM Parques.TipoParque

ROLLBACK TRANSACTION


-- ************************************************************
-- CASOS DE ERROR - Guardaparque
-- ************************************************************
USE ParquesNacionales
GO

-- nombre no ingresado, apellido no ingresado, fechaNacimiento no ingresada, fechaIngresoCargo no valida
BEGIN TRY
	EXEC Personal.sp_AltaGuardaparque @nombre = '', @apellido = '',
        @fechaNacimiento = '', @tipoDocumento = '', @nroDocumento = 0,
        @email = '', @fechaIngresoCargo = '2077-06-18'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idGuardaparque no existe, fechaEgresoCargo no valida
BEGIN TRY
	EXEC Personal.sp_ModificacionGuardaparque @idGuardaparque = 1, @nombre = '', @apellido = '',
        @fechaNacimiento = '', @tipoDocumento = '', @nroDocumento = 0, @email = '',
        @fechaIngresoCargo = '2017-06-18', @fechaEgresoCargo = '2016-05-15', @motivoEgreso = '', @estaActivo = 0
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idGuardaparque no existe
BEGIN TRY
	EXEC Personal.sp_BajaGuardaparque @idGuardaparque = 1, @motivoEgreso = 'Despido'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- ===========================================================
-- CASOS EXITOSOS - Guardaparque
-- ============================================================
USE ParquesNacionales
GO

BEGIN TRANSACTION

    DECLARE @idGuardaparque_TEST INT

    -- Alta exitosa
    EXEC Personal.sp_AltaGuardaparque
        @nombre = 'Pedro', @apellido = 'Pedro', @fechaNacimiento = '2000-01-21', @tipoDocumento = 'DNI',
        @nroDocumento = '46000000', @email = 'johnsmith@mail.com', @fechaIngresoCargo = '2026-06-12'

    SELECT @idGuardaparque_TEST = idGuardaparque
    FROM Personal.Guardaparque
    WHERE tipoDocumento = 'DNI' AND nroDocumento = '46000000'

    SELECT *
    FROM Personal.Guardaparque

    -- Modificación exitosa
    EXEC Personal.sp_ModificacionGuardaparque
        @idGuardaparque = @idGuardaparque_TEST, @nombre = 'John', @apellido = 'Doe', @fechaNacimiento = '1999-04-26',
        @tipoDocumento = 'DNI', @nroDocumento = '46000000', @email = 'johnsmith@gmail.com', @fechaIngresoCargo = '2025-07-17',
        @fechaEgresoCargo = NULL , @motivoEgreso = '', @estaActivo = 1

    SELECT *
    FROM Personal.Guardaparque


    -- Baja exitosa
    EXEC Personal.sp_BajaGuardaparque
        @idGuardaparque = @idGuardaparque_TEST, @motivoEgreso = 'Despido'

    SELECT *
    FROM Personal.Guardaparque


    -- Eliminacion exitosa
    EXEC Personal.sp_EliminarGuardaparque
        @idGuardaparque = @idGuardaparque_TEST

    SELECT *
    FROM Personal.Guardaparque

ROLLBACK TRANSACTION


-- ************************************************************
-- CASOS DE ERROR - HistorialGuardaparque
-- ************************************************************
USE ParquesNacionales
GO

-- idParque no existe, idGuardaparque no existe
BEGIN TRY
	EXEC Personal.sp_AltaHistorialGuardaparque @idParque = 1, @idGuardaparque = 1,
        @fechaIngreso = NULL, @fechaEgreso = NULL
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idHistorial no existe, idParque no existe, idGuardaparque no existe, fechaEgreso no valida
BEGIN TRY
	EXEC Personal.sp_ModificacionHistorialGuardaparque @idHistorial = 1, @idParque = 1,
    @idGuardaparque = 1, @fechaIngreso = '2026-06-20', @fechaEgreso = '2025-06-20'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idHistorial no existe
BEGIN TRY
	EXEC Personal.sp_BajaHistorialGuardaparque @idHistorial = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idHistorial no existe
BEGIN TRY
	EXEC Personal.sp_EliminarHistorialGuardaparque @idHistorial = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- ===========================================================
-- CASOS EXITOSOS - HistorialGuardaparque
-- ============================================================
USE ParquesNacionales
GO

BEGIN TRANSACTION

    DECLARE @idHistorial_TEST    INT,
            @idTipoParque_TEST   INT,
            @idParque_TEST       INT,
            @idGuardaparque_TEST INT

    -- Alta exitosa
    EXEC Personal.sp_AltaGuardaparque
        @nombre = 'Pedro', @apellido = 'Pedro', @fechaNacimiento = '2000-01-21', @tipoDocumento = 'DNI',
        @nroDocumento = '46000000', @email = 'johnsmith@mail.com', @fechaIngresoCargo = '2026-06-12'

    SELECT @idGuardaparque_TEST = idGuardaparque
    FROM Personal.Guardaparque
    WHERE tipoDocumento = 'DNI' AND nroDocumento = '46000000'

    EXEC Parques.sp_AltaTipoParque
        @nombre = 'Parque Nacional', @descripcion = 'Jurisdiccion nacional'

    SELECT @idTipoParque_TEST = idTipoParque
    FROM Parques.TipoParque
    WHERE nombre = 'Parque Nacional'

    EXEC Parques.sp_AltaParque
        @idTipoParque = @idTipoParque_TEST, @nombre = 'Parque Nacional Nahuel Huapi',
        @region = '-', @provincia = 'Rio Negro', @superficie = 717.26

    SELECT @idParque_TEST = idParque
    FROM Parques.Parque
    WHERE nombre = 'Parque Nacional Nahuel Huapi'


    EXEC Personal.sp_AltaHistorialGuardaparque
        @idParque = @idParque_TEST, @idGuardaparque = @idGuardaparque_TEST, @fechaIngreso = '2025-08-23', @fechaEgreso = NULL

    SELECT @idHistorial_TEST = idHistorial
    FROM Personal.HistorialGuardaparque
    WHERE idGuardaparque = @idGuardaparque_TEST AND idParque = @idParque_TEST

    SELECT *
    FROM Personal.HistorialGuardaparque

    -- Modificación exitosa
    EXEC Personal.sp_ModificacionHistorialGuardaparque @idHistorial = @idHistorial_TEST, @idParque = @idParque_TEST,
        @idGuardaparque = @idGuardaparque_TEST, @fechaIngreso = '2026-06-10', @fechaEgreso = NULL

    SELECT *
    FROM Personal.HistorialGuardaparque


    -- Baja exitosa
    EXEC Personal.sp_BajaHistorialGuardaparque
        @idHistorial = @idHistorial_TEST

    SELECT *
    FROM Personal.HistorialGuardaparque


    -- Eliminacion exitosa
    EXEC Personal.sp_EliminarHistorialGuardaparque
        @idHistorial = @idHistorial_TEST

    SELECT *
    FROM Personal.HistorialGuardaparque

ROLLBACK TRANSACTION


-- ===========================================================
-- CASOS EXITOSOS - TipoActividadTuristica
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idTipoActTest INT;

    -- Alta exitosa
    EXEC Actividades.sp_AltaTipoActividadTuristica
        @descripcion = 'TEST_Actividades acuáticas';

    SELECT @idTipoActTest = idTipoActividadTuristica
    FROM Actividades.TipoActividadTuristica
    WHERE descripcion = 'TEST_Actividades acuáticas';

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;

    -- Modificación exitosa
    EXEC Actividades.sp_ModificacionTipoActividadTuristica
        @idTipoActividadTuristica = @idTipoActTest,
        @descripcion = 'TEST_Actividades acuáticas y de río';

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;


    -- Baja exitosa
    EXEC Actividades.sp_BajaTipoActividadTuristica
        @idTipoActividadTuristica = @idTipoActTest;

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;
    -- Debería devolver 0 filas

ROLLBACK TRANSACTION;

-- ************************************************************
-- CASOS DE ERROR - TipoActividadTuristica
-- ************************************************************

-- ********************** Alta *******************************

-- descripcion vacia
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaTipoActividadTuristica
        @descripcion = '     ';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;

-- ***************** Modificacion ***************************

-- id no encontrado
-- descripcion vacia
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_ModificacionTipoActividadTuristica
        @idTipoActividadTuristica = -1,
        @descripcion = '';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;

-- ********************** Baja *******************************

-- id no encontrado
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_BajaTipoActividadTuristica
        @idTipoActividadTuristica = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';


END CATCH;
ROLLBACK TRANSACTION;



-- ============================================================
-- CASOS EXITOSOS - ActividadTuristica
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idActividadTuristicaTest INT;
    DECLARE @idParque INT;
    DECLARE @idTipoActividad INT;
    DECLARE @idTipoParque INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000.00);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    -- Alta exitosa

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Caminata Guiada',
        @costo = 1500,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristicaTest = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Caminata Guiada';

    -- Debería devolver una fila
    SELECT *
    FROM Actividades.ActividadTuristica
    WHERE idActividadTuristica = @idActividadTuristicaTest;

    -- Modificación exitosa

    EXEC Actividades.sp_ModificacionActividadTuristica
        @idActividadTuristica = @idActividadTuristicaTest,
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Caminata Guiada Extendida',
        @costo = 2000,
        @duracion = 180,
        @cupoMaximo = 30;

    -- Debería devolver una fila modificada
    SELECT *
    FROM Actividades.ActividadTuristica
    WHERE idActividadTuristica = @idActividadTuristicaTest;

    -- Baja exitosa

    EXEC Actividades.sp_BajaActividadTuristica
        @idActividadTuristica = @idActividadTuristicaTest;

    -- Debería devolver 0 filas
    SELECT *
    FROM Actividades.ActividadTuristica
    WHERE idActividadTuristica = @idActividadTuristicaTest;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - ActividadTuristica
-- ************************************************************

-- ********************** Alta *******************************

USE ParquesNacionales;
GO

-- id de Parque no existe,
-- id de Tipo Actividad Turistica no existe,
-- nombre no puede estar vacio
-- costo no puede ser negativo
-- duracion debe ser > 0
-- cupo maximo > 0
BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = -1,
        @idTipoActividadTuristica = -1,
        @nombre = '     ',
        @costo = -1,
        @duracion = 0,
        @cupoMaximo = 0;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO

-- ********************** Modificación *******************************

-- id de Actividad Turistica no existe
-- id de Parque no existe,
-- id de Tipo Actividad Turistica no existe,
-- nombre no puede estar vacio
-- costo no puede ser negativo
-- duracion debe ser > 0
-- cupo maximo > 0

USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_ModificacionActividadTuristica
        @idActividadTuristica = -1,
        @idParque = -1,
        @idTipoActividadTuristica = -1,
        @nombre = '     ',
        @costo = -1,
        @duracion = 0,
        @cupoMaximo = 0;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO

-- ********************** Baja *******************************

-- id Actividad Turistica no existe
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_BajaActividadTuristica
        @idActividadTuristica = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO


-- ============================================================
-- CASOS EXITOSOS - GuiaAutorizacion
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idGuia INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;
    DECLARE @idTipoActividad INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia 
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Nombre', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@guia.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    -- Alta exitosa

    EXEC Actividades.sp_AltaGuiaAutorizacion
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica;

    -- Debería devolver una fila

    SELECT *
    FROM Actividades.GuiaAutorizacion
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Baja exitosa

    EXEC Actividades.sp_BajaGuiaAutorizacion
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica;

    -- Debería devolver 0 filas

    SELECT *
    FROM Actividades.GuiaAutorizacion
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - GuiaAutorizacion
-- ************************************************************


-- ********************** Alta *******************************

USE ParquesNacionales;
GO

-- id de Guia no existe
-- id de Actividad Turistica no existe

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaGuiaAutorizacion
        @idGuia = -1,
        @idActividadTuristica = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO


USE ParquesNacionales;
GO

-- El guia ya esta autorizado para esta actividad

BEGIN TRANSACTION;

-- creamos los mismos datos auxiliares del caso exitoso

    DECLARE @idGuia INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;
    DECLARE @idTipoActividad INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia 
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Nombre', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@guia.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

BEGIN TRY

    EXEC Actividades.sp_AltaGuiaAutorizacion
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica;

    EXEC Actividades.sp_AltaGuiaAutorizacion
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ********************** Baja *******************************

USE ParquesNacionales;
GO

-- No existe una autorizacion para ese guia y actividad

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_BajaGuiaAutorizacion
        @idGuia = -1,
        @idActividadTuristica = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO



-- ============================================================
-- CASOS EXITOSOS - ActividadProgramada
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idActividadProgramada INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Nombre', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@guia.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    -- Alta exitosa

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00',
        @observaciones = 'TEST_Observaciones';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia
      AND idActividadTuristica = @idActividadTuristica
      AND fecha = '2026-12-01'
      AND horaInicio = '09:00';

    -- Debería devolver una fila

    SELECT *
    FROM Actividades.ActividadProgramada
    WHERE idActividadProgramada = @idActividadProgramada;

    -- Modificación exitosa

    EXEC Actividades.sp_ModificacionActividadProgramada
        @idActividadProgramada = @idActividadProgramada,
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-02',
        @horaInicio = '10:00',
        @estado = 'Realizada',
        @observaciones = 'TEST_Modificada';

    -- Debería devolver una fila modificada

    SELECT *
    FROM Actividades.ActividadProgramada
    WHERE idActividadProgramada = @idActividadProgramada;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - ActividadProgramada
-- ************************************************************


-- ********************** Alta *******************************

USE ParquesNacionales;
GO

-- id de Guia no existe
-- id de Actividad Turistica no existe
-- guia no autorizado
-- fecha vacia
-- hora de inicio vacia

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = -1,
        @idActividadTuristica = -1,
        @fecha = NULL,
        @horaInicio = NULL,
        @observaciones = NULL;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO


USE ParquesNacionales;
GO

-- Ya existe una actividad programada con esos datos

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idActividadProgramada INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Nombre', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@guia.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00',
        @observaciones = 'TEST';

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00',
        @observaciones = 'TEST';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;

ROLLBACK TRANSACTION;
GO


USE ParquesNacionales;
GO

-- El guia no esta autorizado para realizar esta actividad

BEGIN TRANSACTION;
BEGIN TRY

        DECLARE @idActividadProgramada INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;

    -- Datos necesarios para el test

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Nombre', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@guia.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    -- no creamos guiaAutorizacion

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ********************** Modificación *******************************

USE ParquesNacionales;
GO

-- id de Actividad Programada no existe
-- id de Guia no existe
-- id de Actividad Turistica no existe
-- guia no autorizado
-- fecha vacia
-- hora de inicio vacia
-- estado invalido

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_ModificacionActividadProgramada
        @idActividadProgramada = -1,
        @idGuia = -1,
        @idActividadTuristica = -1,
        @fecha = NULL,
        @horaInicio = NULL,
        @estado = 'CualquierCosa',
        @observaciones = NULL;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO




-- ============================================================
-- CASOS EXITOSOS - DetalleContratacion
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idVisitante INT;
    DECLARE @idVenta INT;
    DECLARE @idDetalleContratacion INT;

    -- Datos necesarios para el test

    INSERT INTO Ventas.Visitante (nombre, apellido, email, direccion, telefono)
    VALUES ('TEST_Nombre', 'TEST_Apellido', 'test@correo.com', 'TEST_Direccion', '123456789');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PuntoVenta', 0);

    SET @idVenta = SCOPE_IDENTITY();

    -- Alta exitosa

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 15000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta AND costoTotal = 15000;

    -- Debería devolver una fila

    SELECT *
    FROM Actividades.DetalleContratacion
    WHERE idDetalleContratacion = @idDetalleContratacion;

    -- Modificación exitosa

    EXEC Actividades.sp_ModificacionDetalleContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idVenta = @idVenta,
        @costoTotal = 20000;

    -- Debería devolver una fila modificada

    SELECT *
    FROM Actividades.DetalleContratacion
    WHERE idDetalleContratacion = @idDetalleContratacion;

    -- Baja exitosa

    EXEC Actividades.sp_BajaDetalleContratacion
        @idDetalleContratacion = @idDetalleContratacion;

    -- Debería devolver 0 filas

    SELECT *
    FROM Actividades.DetalleContratacion
    WHERE idDetalleContratacion = @idDetalleContratacion;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - DetalleContratacion
-- ************************************************************

-- ********************** Alta *******************************

USE ParquesNacionales;
GO

-- id de Venta no existe
-- costo total no puede ser negativo

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = -1,
        @costoTotal = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO

-- ********************** Baja *******************************

USE ParquesNacionales;
GO

-- id de Detalle Contratacion no existe

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_BajaDetalleContratacion
        @idDetalleContratacion = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO


-- ============================================================
-- CASOS EXITOSOS - Contratacion
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idVisitante INT;
    DECLARE @idVenta INT;
    DECLARE @idDetalleContratacion INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    DECLARE @idContratacion INT;

    -- Datos necesarios para el test

    INSERT INTO Ventas.Visitante (nombre, apellido, email, direccion, telefono)
    VALUES ('TEST_Nombre', 'TEST_Apellido', 'test@test.com', 'TEST_Direccion', '123456789');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PuntoVenta', 0);

    SET @idVenta = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 15000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta;

    -- Datos para ActividadProgramada

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'Tipo de parque para testing');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque,'TEST_Parque','TEST_Region','TEST_Provincia',1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica (descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 1000,
        @duracion = 120,
        @cupoMaximo = 20;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST_Guia', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'testguia@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00',
        @observaciones = 'TEST';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Alta exitos

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Confirmada',
        @cantidadPersonas = 4;

    SELECT @idContratacion = idContratacion
    FROM Actividades.Contratacion
    WHERE idDetalleContratacion = @idDetalleContratacion AND idActividadProgramada = @idActividadProgramada;

    -- Debería devolver una fila

    SELECT *
    FROM Actividades.Contratacion
    WHERE idContratacion = @idContratacion;

    -- Modificación exitosa

    EXEC Actividades.sp_ModificacionContratacion
        @idContratacion = @idContratacion,
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 7000,
        @estado = 'Completada',
        @cantidadPersonas = 6;

    -- Debería devolver una fila modificada

    SELECT *
    FROM Actividades.Contratacion
    WHERE idContratacion = @idContratacion;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - Contratacion
-- ************************************************************

-- ********************** Alta *******************************

USE ParquesNacionales;
GO

-- id de Detalle Contratacion no existe
-- id de Actividad Programada no existe
-- costo no puede ser negativo
-- cantidad de personas debe ser mayor a 0
-- estado inválido

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = -1,
        @idActividadProgramada = -1,
        @costo = -1,
        @estado = 'EstadoInvalido',
        @cantidadPersonas = 0;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO

-- ********************** Modificación *******************************

USE ParquesNacionales;
GO

-- id de Contratacion no existe
-- id de Detalle Contratacion no existe
-- id de Actividad Programada no existe
-- costo no puede ser negativo
-- cantidad de personas debe ser mayor a 0
-- estado inválido

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_ModificacionContratacion
        @idContratacion = -1,
        @idDetalleContratacion = -1,
        @idActividadProgramada = -1,
        @costo = -1,
        @estado = 'EstadoInvalido',
        @cantidadPersonas = 0;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';

END CATCH;
ROLLBACK TRANSACTION;
GO



USE ParquesNacionales;
GO

-- '========================================================================';
-- 'TEST CASO EXITOSO: ALTA -> MODIFICACIÓN -> ELIMINACIÓN';
-- '========================================================================';

BEGIN TRANSACTION; -- Inicio de zona segura de pruebas sin datos basura
BEGIN TRY
    DECLARE @idGenerado INT;

    -- 1. Probar Alta Exitosa
    EXEC Concesiones.sp_AltaEmpresaConcesionaria
        @cuit = '20123456789',
        @razonSocial = 'TEST_Paradores de la Selva S.A.',
        @contacto = 'info@paradoresselva.com';

    -- Evidencia del alta mediante consulta directa
    PRINT 'Evidencia post-alta:';
    SELECT * FROM Concesiones.EmpresaConcesionaria WHERE cuit = '20123456789';

    SELECT @idGenerado = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria WHERE cuit = '20123456789';

    -- 2. Probar Modificación Exitosa
    EXEC Concesiones.sp_ModificacionEmpresaConcesionaria
        @idEmpresaConcesionaria = @idGenerado,
        @cuit = '20123456789',
        @razonSocial = 'TEST_Paradores y Refugios de la Selva S.A.',
        @contacto = 'nuevo_contacto@paradoresselva.com';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idGenerado;

    -- 3. Probar Eliminación Exitosa
    EXEC Concesiones.sp_EliminarEmpresaConcesionaria @idEmpresaConcesionaria = @idGenerado;

    PRINT 'Evidencia post-eliminación (Debe retornar 0 filas):';
    SELECT * FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idGenerado;

END TRY
BEGIN CATCH
    PRINT 'Error inesperado durante la ejecución del test: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION; -- La base vuelve a su estado original e intacto
GO


-- '========================================================================';
-- 'TEST CASO FALLIDO: SIMULACIÓN DE INFRACCIÓN A VALIDACIONES';
-- '========================================================================';
-- ESCENARIO ESPERADO: El SP debe interceptar los fallos y concatenar ambos
-- en un mismo string (CUIT inválido menor a 11 caracteres y Razón Social vacía).

BEGIN TRANSACTION;
BEGIN TRY
    EXEC Concesiones.sp_AltaEmpresaConcesionaria
        @cuit = '12345',    -- Fuerza error de longitud
        @razonSocial = ' ', -- Fuerza error de campo vacío
        @contacto = NULL;
END TRY
BEGIN CATCH
    PRINT 'Mensaje consolidado capturado con éxito para el usuario final:';
    SELECT value AS [Errores Atrapados]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


--===============================================================================
-- CASOS EXITOSOS: GUIA (ALTA --> MODIFICACION --> BAJA)
--===============================================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idGuiaTest INT;

    -- Alta exitosa

    EXEC Guias.sp_AltaGuia
        @nombre='TEST_Joaquin',
        @apellido='TEST_Martinez',
        @fechaNacimiento='1998-05-10',
        @tipoDocumento='DNI',
        @nroDocumento='40111222',
        @email='test@guia.com',
        @vigenciaAutorizacion='2030-01-01';

    SELECT @idGuiaTest=idGuia
    FROM Guias.Guia
    WHERE email='test@guia.com';

     -- Deberia devolver una fila creada y activa
    PRINT ' [EVIDENCIA] Registro insertado en la tabla:';
    SELECT * 
    FROM Guias.Guia
    WHERE idGuia=@idGuiaTest AND estaActivo = 1;


    -- Modificacion exitosa

    EXEC Guias.sp_ModificacionGuia
        @idGuia=@idGuiaTest,
        @nombre='TEST_Modificado',
        @apellido='Martinez',
        @fechaNacimiento='1998-05-10',
        @tipoDocumento='DNI',
        @nroDocumento='40111222',
        @email='nuevo@guia.com',
        @vigenciaAutorizacion='2031-01-01';

    -- Deberia devolver datos modificados

    PRINT '     [EVIDENCIA] Registro modificado en la tabla:';
    SELECT *
    FROM Guias.Guia
    WHERE idGuia=@idGuiaTest;


    -- Baja logica

    EXEC Guias.sp_BajaGuia
        @idGuia=@idGuiaTest;

    -- Deberia devolver 0 filas
    PRINT '     [EVIDENCIA] Registro tras la baja lógica (estaActivo debe ser 0):';
    SELECT *
    FROM Guias.Guia
    WHERE idGuia=@idGuiaTest AND estaActivo = 0;

ROLLBACK TRANSACTION;
GO

-- ============================================================
-- CASOS FALLIDOS - Guia (ALTA --> MODIFICACION -- > BAJA)
-- ============================================================

----------------------------------ALTA-------------------------------------
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    EXEC Guias.sp_AltaGuia
        @nombre='',
        @apellido='',
        @fechaNacimiento=NULL,
        @tipoDocumento='DNI',
        @nroDocumento='12345678',
        @email='',
        @vigenciaAutorizacion='2020-01-01';
END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

    --TEST DUPLICADOS
BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO Guias.Guia (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion)
    VALUES ('Base', 'Base', '1990-01-01', 'DNI', '40111222', 'base@guia.com', '2030-01-01');

    EXEC Guias.sp_AltaGuia
        @nombre='Esteban',
        @apellido='Quito',
        @fechaNacimiento='1992-04-10',
        @tipoDocumento='DNI',
        @nroDocumento='40111222',
        @email='esteban.quito@turismo.com',
        @vigenciaAutorizacion='2030-01-01';
END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
--------------------MODIFICACION---------------------------------

USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    EXEC Guias.sp_ModificacionGuia
        @idGuia = -99,                                       -- Error: No existe
        @nombre = 'Esteban', 
        @apellido = 'Quito', 
        @fechaNacimiento = '1992-04-10', 
        @tipoDocumento = 'DNI', 
        @nroDocumento = '40111222', 
        @email = 'esteban.quito@turismo.com', 
        @vigenciaAutorizacion = '2015-01-01';              -- Error: Fecha vencida
END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

----------------------BAJA---------------------------------------

USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
    EXEC Guias.sp_BajaGuia
        @idGuia = 999999;
END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
