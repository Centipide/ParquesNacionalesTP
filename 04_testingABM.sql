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
-- ========================================================================
-- TESTING DE EMPRESA CONCESIONARIA
-- ========================================================================
-- ************************************************************************
-- TEST CASO EXITOSO: ALTA -> MODIFICACIÓN -> ELIMINACIÓN
-- ************************************************************************

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


-- ************************************************************************
-- TEST CASO FALLIDO: SIMULACIÓN DE INFRACCIÓN A VALIDACIONES
-- ************************************************************************
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

-- ========================================================================
-- TESTING DE Tipo de actividad de concesión
-- ========================================================================
-- ************************************************************************
-- TEST TIPO ACTIVIDAD CONCESION: CASO EXITOSO (CON ROLLBACK)
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idActividadTest INT;

    -- 1. Probar Alta
    EXEC Concesiones.sp_AltaTipoActividadConcesion
        @nombre = 'TEST_Alquiler de Bicicletas',
        @descripcionActividad = 'Servicio de renta de rodados de montaña y cascos para senderos autorizados.';

    PRINT 'Evidencia post-alta:';
    SELECT * FROM Concesiones.TipoActividadConcesion WHERE nombre = 'TEST_Alquiler de Bicicletas';

    SELECT @idActividadTest = idTipoActividadConcesion FROM Concesiones.TipoActividadConcesion WHERE nombre = 'TEST_Alquiler de Bicicletas';

    -- 2. Probar Modificación
    EXEC Concesiones.sp_ModificacionTipoActividadConcesion
        @idTipoActividadConcesion = @idActividadTest,
        @nombre = 'TEST_Alquiler de Bicicletas y Mountain Bikes',
        @descripcionActividad = 'Servicio premium de renta de rodados para circuitos de alta complejidad.';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idActividadTest;

    -- 3. Probar Eliminación
    EXEC Concesiones.sp_EliminarTipoActividadConcesion @idTipoActividadConcesion = @idActividadTest;

    PRINT 'Evidencia post-eliminación (Debe retornar vacío):'; 
    SELECT * FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idActividadTest; 

END TRY
BEGIN CATCH
    PRINT 'Error inesperado durante la ejecución del test: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION; 
GO


-- ************************************************************************
--  CASO DE ERROR
-- ************************************************************************
-- ESCENARIO ESPERADO: Debe fallar concatenando el nombre vacío.

BEGIN TRANSACTION;
BEGIN TRY
    EXEC Concesiones.sp_AltaTipoActividadConcesion
        @nombre = '   ', -- Fuerza el error de cadena vacía
        @descripcionActividad = 'Prueba de falla acumulativa';
END TRY
BEGIN CATCH
    PRINT 'Mensaje consolidado capturado con éxito para el usuario final:';
    SELECT value AS [Errores Atrapados]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
-- ========================================================================
-- TESTING DE CONCESION
-- ========================================================================
-- ************************************************************************
-- CASO EXITOSO 
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesionTest INT;
    DECLARE @idTipoParque INT;

    -- Generar datos de soporte necesarios para cumplir las FKs
    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Reserva', 'Reserva de pruebas');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque Meteorito', 'region Test', 'Provincia Test', 5500.50);
    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial, contacto)
    VALUES ('30111111118', 'TEST_Gastronomía Patagónica S.A.', 'ventas@test.com');
    SET @idEmpresa = SCOPE_IDENTITY();

    INSERT INTO Concesiones.TipoActividadConcesion (nombre, descripcionActividad)
    VALUES ('TEST_Restaurante', 'Servicios de buffet y cafetería.');
    SET @idActividad = SCOPE_IDENTITY();

    -- 1. Probar Alta
    EXEC Concesiones.sp_AltaConcesion
        @idEmpresaConcesionaria = @idEmpresa,
        @idTipoActividadConcesion = @idActividad,
        @idParque = @idParque,
        @fechaInicio = '2026-01-01',
        @fechaFin = '2026-12-31',
        @montoAlquiler = 120000.00,
        @estado = 'Activa';

    PRINT 'Evidencia post-alta:';
    SELECT * FROM Concesiones.Concesion WHERE idEmpresaConcesionaria = @idEmpresa;

    SELECT @idConcesionTest = idConcesion FROM Concesiones.Concesion WHERE idEmpresaConcesionaria = @idEmpresa;

    -- 2. Probar Modificación
    EXEC Concesiones.sp_ModificacionConcesion
        @idConcesion = @idConcesionTest,
        @idEmpresaConcesionaria = @idEmpresa,
        @idTipoActividadConcesion = @idActividad,
        @idParque = @idParque,
        @fechaInicio = '2026-01-01',
        @fechaFin = '2027-06-30', -- Extensión del contrato
        @montoAlquiler = 150000.00, -- Aumento de canon
        @estado = 'Activa';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Concesiones.Concesion WHERE idConcesion = @idConcesionTest;

    -- 3. Probar Eliminación
    EXEC Concesiones.sp_EliminarConcesion @idConcesion = @idConcesionTest;

    PRINT 'Evidencia post-eliminación (Debe retornar vacío):';
    SELECT * FROM Concesiones.Concesion WHERE idConcesion = @idConcesionTest;

END TRY
BEGIN CATCH
    PRINT 'Error detectado en flujo de concesiones: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION; -- Limpieza de los datos de soporte
GO


-- ************************************************************************
-- CASO DE ERROR (VALIDACIONES ACUMULATIVAS)
-- ************************************************************************
-- ESCENARIO ESPERADO: Debe fallar concatenando tres infracciones claras:
-- (FKs inexistentes, fechas cruzadas al revés y monto negativo).

BEGIN TRANSACTION;
BEGIN TRY
    EXEC Concesiones.sp_AltaConcesion
        @idEmpresaConcesionaria = -1,  -- Inexistente
        @idTipoActividadConcesion = -1, -- Inexistente
        @idParque = -1,                 -- Inexistente
        @fechaInicio = '2026-12-31',
        @fechaFin = '2026-01-01',       -- Error: Fin menor que inicio
        @montoAlquiler = -5000.00,      -- Error: Monto negativo
        @estado = 'Invalido';           -- Error: Estado fuera del CHECK
END TRY
BEGIN CATCH
    PRINT 'Mensaje consolidado capturado con éxito para el usuario final:';
    SELECT value AS [Errores Atrapados]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

-- ========================================================================
-- TESTING DE PAGO CANON
-- ========================================================================
-- ************************************************************************
-- TEST PAGO CANON: CASO EXITOSO Y RESTRICCIÓN DE BAJA
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesion INT, @idPagoTest INT;
    DECLARE @idTipoParque INT;

    -- Datos semilla de soporte para la integridad de claves
    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_ReservaPago', 'Pruebas Pago');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque Financiero', 'region F', 'Provincia F', 2300.00);
    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial, contacto)
    VALUES ('30999999994', 'TEST_Concesiones de Alimentos S.A.', 'pagos@test.com');
    SET @idEmpresa = SCOPE_IDENTITY();

    INSERT INTO Concesiones.TipoActividadConcesion (nombre, descripcionActividad)
    VALUES ('TEST_Kiosco', 'Venta de golosinas y bebidas.');
    SET @idActividad = SCOPE_IDENTITY();

    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresa, @idActividad, @idParque, '2026-01-01', '2026-12-31', 50000.00, 'Activa');
    SET @idConcesion = SCOPE_IDENTITY();

    -- 1. Probar Alta Exitosa de un Pago de Canon
    EXEC Concesiones.sp_AltaPagoCanon
        @idConcesion = @idConcesion,
        @fechaPago = '2026-06-15',
        @monto = 50000.00,
        @fechaVencimiento = '2026-06-10', -- Pagado con retraso, pero válido
        @fechaEmision = '2026-06-01';

    PRINT 'Evidencia post-alta del Canon:';
    SELECT * FROM Concesiones.PagoCanon WHERE idConcesion = @idConcesion;

    SELECT @idPagoTest = idPagoCanon FROM Concesiones.PagoCanon WHERE idConcesion = @idConcesion;

    -- 2. Probar Modificación
    EXEC Concesiones.sp_ModificacionPagoCanon
        @idPagoCanon = @idPagoTest,
        @idConcesion = @idConcesion,
        @fechaPago = '2026-06-05', -- Ajuste de fecha real por conciliación bancaria
        @monto = 50000.00,
        @fechaVencimiento = '2026-06-10',
        @fechaEmision = '2026-06-01';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Concesiones.PagoCanon WHERE idPagoCanon = @idPagoTest;

    -- 3. Probar intento de eliminación (Debe disparar la regla restrictiva del SP)
    PRINT 'Intento de borrado físico del pago:';
    EXEC Concesiones.sp_EliminarPagoCanon @idPagoCanon = @idPagoTest;

END TRY
BEGIN CATCH
    PRINT 'Mensaje de Auditoría capturado de forma correcta en el bloque CATCH:';
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION; -- Dejamos la base limpia sin basura de testing
GO


-- ************************************************************************
-- TEST PAGO CANON: CASO DE ERROR (VALIDACIONES CRUZADAS)
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    EXEC Concesiones.sp_AltaPagoCanon
        @idConcesion = -1,          -- Concesión inexistente
        @fechaPago = '2026-06-18',
        @monto = -2500.00,          -- Monto negativo
        @fechaVencimiento = '2026-01-01',
        @fechaEmision = '2026-02-01'; -- Vencimiento anterior a la emisión
END TRY
BEGIN CATCH
    PRINT 'Mensaje consolidado de errores financieros:';
    SELECT value AS [Errores Atrapados]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

-- ========================================================================
-- ESCENARIOS DE ERROR COMPLEMENTARIOS (AUDITORÍA DE VALIDACIONES CRÍTICAS)
-- ========================================================================

--- ************************************************************************
--- TEST ERROR: MODIFICACIÓN CON ID INEXISTENTE
--- ************************************************************************
-- ESCENARIO ESPERADO: Debe fallar atrapando que el ID no existe en el sistema.

BEGIN TRANSACTION;
BEGIN TRY
    EXEC Concesiones.sp_ModificacionEmpresaConcesionaria
        @idEmpresaConcesionaria = -999, -- ID que jamás va a existir
        @cuit = '20444444441',
        @razonSocial = 'Empresa Fantasma S.A.',
        @contacto = NULL;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (ID Empresa Inexistente)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

BEGIN TRY
    EXEC Concesiones.sp_ModificacionConcesion
        @idConcesion = -999, -- ID que jamás va a existir
        @idEmpresaConcesionaria = 1,
        @idTipoActividadConcesion = 1,
        @idParque = 1,
        @fechaInicio = '2026-01-01',
        @fechaFin = '2026-12-31',
        @montoAlquiler = 50000.00,
        @estado = 'Activa';
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (ID Concesion Inexistente)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- TEST ERROR: VIOLACIÓN DE UNICIDAD (CUIT Y NOMBRE DUPLICADOS)
-- ************************************************************************
-- ESCENARIO ESPERADO: El sistema debe impedir la clonación de datos persistentes.

BEGIN TRANSACTION;
BEGIN TRY
    -- Insertamos una empresa base
    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial) 
    VALUES ('30888888881', 'Empresa Original S.A.');

    -- Intentamos forzar el alta de otra empresa con el MISMO CUIT usando el SP
    EXEC Concesiones.sp_AltaEmpresaConcesionaria
        @cuit = '30888888881', -- CUIT Duplicado intencional
        @razonSocial = 'Empresa Cloncito S.A.',
        @contacto = NULL;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (CUIT Duplicado)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

BEGIN TRY
    -- Insertamos un rubro base
    INSERT INTO Concesiones.TipoActividadConcesion (nombre) 
    VALUES ('Catamarán Nocturno');

    -- Intentamos forzar el alta del mismo rubro por SP
    EXEC Concesiones.sp_AltaTipoActividadConcesion
        @nombre = 'Catamarán Nocturno', -- Nombre Duplicado intencional
        @descripcionActividad = 'Clon de rubro';
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Rubro Duplicado)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- TEST ERROR: ELIMINACIÓN BLOQUEADA POR INTEGRIDAD REFERENCIAL (FK)
-- ************************************************************************
-- ESCENARIO ESPERADO: El SP debe impedir el DELETE físico porque la empresa tiene hijos.

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT;
    DECLARE @idTipoParque INT;

    -- Creamos la estructura referencial mínima en el scope transaccional
    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_Bloqueo');
    SET @idTipoParque = SCOPE_IDENTITY();
    
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) 
    VALUES (@idTipoParque, 'Parque de Test Bloqueo', 'L', 'P', 100);
    SET @idParque = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial) 
    VALUES ('30555555551', 'Empresa Con Contrato Activo S.A.');
    SET @idEmpresa = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.TipoActividadConcesion (nombre) 
    VALUES ('Rubro Con Contrato Activo');
    SET @idActividad = SCOPE_IDENTITY();
    
    -- Le metemos un contrato hijo directo a la tabla Concesion
    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresa, @idActividad, @idParque, '2026-01-01', '2026-12-31', 5000, 'Activa');

    -- Intentamos borrar la empresa madre usando tu SP (Debe saltar tu control IF EXISTS)
    EXEC Concesiones.sp_EliminarEmpresaConcesionaria @idEmpresaConcesionaria = @idEmpresa;

END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Fallo de Integridad Referencial)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TESTING DE TIPO DE VISITANTE
-- ========================================================================
-- ************************************************************************
-- TEST TIPO VISITANTE: CASO EXITOSO (CAMMINO FELIZ CON ROLLBACK)
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idTipoVisitanteTest INT;

    -- 1. Probar Alta Exitosa
    EXEC Ventas.sp_AltaTipoVisitante
        @nombre = 'TEST_Estudiante Universitario',
        @descripcion = 'Tarifa diferenciada aplicable a alumnos regulares de instituciones superiores.';

    PRINT 'Evidencia post-alta:';
    SELECT * FROM Ventas.TipoVisitante WHERE nombre = 'TEST_Estudiante Universitario';

    SELECT @idTipoVisitanteTest = idTipoVisitante FROM Ventas.TipoVisitante WHERE nombre = 'TEST_Estudiante Universitario';

    -- 2. Probar Modificación Exitosa
    EXEC Ventas.sp_ModificacionTipoVisitante
        @idTipoVisitante = @idTipoVisitanteTest,
        @nombre = 'TEST_Estudiante Universitario/Terciario',
        @descripcion = 'Tarifa diferenciada extendida a alumnos de educación superior pública o privada.';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitanteTest;

    -- 3. Probar Eliminación Física Exitosa
    EXEC Ventas.sp_EliminarTipoVisitante @idTipoVisitante = @idTipoVisitanteTest;

    PRINT 'Evidencia post-eliminación (Debe retornar vacío):';
    SELECT * FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitanteTest;

END TRY
BEGIN CATCH
    PRINT 'Error inesperado detectado en flujo de prueba feliz: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- TEST TIPO VISITANTE: CASOS DE ERROR (NULOS, DUPLICADOS E ID INEXISTENTE)
-- ************************************************************************

-- Prueba A: Nombre vacío al insertar
BEGIN TRANSACTION;
BEGIN TRY
    EXEC Ventas.sp_AltaTipoVisitante @nombre = '   ', @descripcion = 'Falla cadena vacía';
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Alta Vacía)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba B: Modificación con ID que no existe y parámetro NULL
BEGIN TRY
    EXEC Ventas.sp_ModificacionTipoVisitante 
        @idTipoVisitante = -99, -- Inexistente
        @nombre = NULL;        -- Error de nulo protegido
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Modificación Maliciosa)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba C: Control de nombres duplicados en el catálogo
BEGIN TRY
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('TEST_Duplicado');
    
    EXEC Ventas.sp_AltaTipoVisitante @nombre = 'TEST_Duplicado';
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Nombre Duplicado)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TESTING DE VISITANTE
-- ========================================================================
-- ************************************************************************
-- TEST VISITANTE: CASO EXITOSO
-- ************************************************************************

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idVisitanteTest INT;

    -- 1. Test Alta Exitosa (con datos opcionales completos)
    EXEC Ventas.sp_AltaVisitante
        @nombre = 'TEST_Carlos',
        @apellido = 'Pellegrini',
        @email = 'carlos@test.com',
        @direccion = 'Av. de Mayo 450',
        @telefono = '1144332211';

    PRINT 'Evidencia post-alta:';
    SELECT * FROM Ventas.Visitante WHERE email = 'carlos@test.com';

    SELECT @idVisitanteTest = idVisitante FROM Ventas.Visitante WHERE email = 'carlos@test.com';

    -- 2. Test Modificación Exitosa
    EXEC Ventas.sp_ModificacionVisitante
        @idVisitante = @idVisitanteTest,
        @nombre = 'TEST_Carlos Alberto',
        @apellido = 'Pellegrini',
        @email = 'carlos_alberto@test.com',
        @direccion = 'Av. de Mayo 500',
        @telefono = '1144332211';

    PRINT 'Evidencia post-modificación:';
    SELECT * FROM Ventas.Visitante WHERE idVisitante = @idVisitanteTest;

    -- 3. Test Eliminación Física Exitosa
    EXEC Ventas.sp_EliminarVisitante @idVisitante = @idVisitanteTest;

    PRINT 'Evidencia post-eliminación (Debe retornar vacío):';
    SELECT * FROM Ventas.Visitante WHERE idVisitante = @idVisitanteTest;

END TRY
BEGIN CATCH
    PRINT 'Error imprevisto en ejecución del camino feliz de visitantes: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- CASOS DE ERROR CONTROLADOS
-- ************************************************************************

-- Prueba A: Inserción maliciosa con campos mandatorios vacíos y email sin formato
BEGIN TRANSACTION;
BEGIN TRY
    EXEC Ventas.sp_AltaVisitante 
        @nombre = '  ', 
        @apellido = NULL, 
        @email = 'correo_invalido.com'; -- Rompe el patrón LIKE
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Alta Defectuosa)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba B: Modificación con ID inexistente y parámetro obligatorio en nulo
BEGIN TRY
    EXEC Ventas.sp_ModificacionVisitante
        @idVisitante = -999,
        @nombre = NULL,
        @apellido = 'Pérez',
        @email = NULL;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Modificación Defectuosa)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba C: Intento de borrado interceptado por integridad referencial (FK)
BEGIN TRY
    DECLARE @idFalsoVisitante INT, @idFalsaVenta INT;

    INSERT INTO Ventas.Visitante (nombre, apellido) VALUES ('TEST_Bloqueo', 'Ventas');
    SET @idFalsoVisitante = SCOPE_IDENTITY();

    -- Forzamos un ticket de cabecera ligado a este visitante
    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idFalsoVisitante, 'Efectivo', 'Portal Test', 1500.00);

    -- Intentamos remover al visitante mediante el SP
    EXEC Ventas.sp_EliminarVisitante @idVisitante = @idFalsoVisitante;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Bloqueo por FK de Ventas)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

ROLLBACK TRANSACTION;
GO

-- ========================================================================
-- TESTING DE ENTRADA
-- ========================================================================
-- ************************************************************************
-- TEST ENTRADA: CASO EXITOSO
-- ************************************************************************
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idParque INT, @idTipoVisitante INT, @idEntradaTest INT;
    DECLARE @idTipoParque INT;

    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_VentasEnt');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque Costero', 'region E', 'Provincia E', 1200.00);
    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Ventas.TipoVisitante (nombre, descripcion)
    VALUES ('TEST_Jubilado Nacional', 'Pase con descuento especial de la tercera edad.');
    SET @idTipoVisitante = SCOPE_IDENTITY();

    -- 1. Test Alta Exitosa
    EXEC Ventas.sp_AltaEntrada
        @idParque = @idParque,
        @idTipoVisitante = @idTipoVisitante,
        @precio = 2500.00;

    PRINT 'Evidencia post-alta Entrada:';
    SELECT * FROM Ventas.Entrada WHERE idParque = @idParque;

    SELECT @idEntradaTest = idEntrada FROM Ventas.Entrada WHERE idParque = @idParque;

    -- 2. Test Modificación Exitosa
    EXEC Ventas.sp_ModificacionEntrada
        @idEntrada = @idEntradaTest,
        @idParque = @idParque,
        @idTipoVisitante = @idTipoVisitante,
        @precio = 3200.00;

    PRINT 'Evidencia post-modificación Entrada:';
    SELECT * FROM Ventas.Entrada WHERE idEntrada = @idEntradaTest;

END TRY
BEGIN CATCH
    PRINT 'Error inesperado detectado en flujo de tarifas: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- TEST ENTRADA: CASOS DE ERROR CONTROLADOS
-- ************************************************************************

-- Prueba A: Claves inexistentes, precio nulo y negativo de forma acumulada
BEGIN TRANSACTION;
BEGIN TRY
    EXEC Ventas.sp_AltaEntrada
        @idParque = -1,
        @idTipoVisitante = -1,
        @precio = -450.00;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Datos Inválidos)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba B: Violación de índice de unicidad compuesta
BEGIN TRY
    DECLARE @idPK INT, @idTV INT;
    INSERT INTO Parques.TipoParque (nombre) VALUES ('T1');
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) VALUES (SCOPE_IDENTITY(), 'P1', 'L', 'P', 10);
    SET @idPK = SCOPE_IDENTITY();
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('V1');
    SET @idTV = SCOPE_IDENTITY();

    -- Insertamos el primer registro tarifario base
    EXEC Ventas.sp_AltaEntrada @idParque = @idPK, @idTipoVisitante = @idTV, @precio = 1000.00;

    -- Forzamos el alta del mismo par por SP (Debe fallar por tu IF EXISTS original)
    EXEC Ventas.sp_AltaEntrada @idParque = @idPK, @idTipoVisitante = @idTV, @precio = 1500.00;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Combinación Duplicada)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

ROLLBACK TRANSACTION;
GO

-- ========================================================================
-- TESTING DE VENTA
-- ========================================================================
-- ************************************************************************
-- CASO EXITOSO 
-- ************************************************************************
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idVisitante INT, @idVentaTest INT;

    INSERT INTO Ventas.Visitante (nombre, apellido, email) 
    VALUES ('TEST_Comprador', 'De Entradas', 'compras@test.com');
    SET @idVisitante = SCOPE_IDENTITY();

    -- 1. Test Alta Exitosa
    EXEC Ventas.sp_AltaVenta
        @idVisitante = @idVisitante,
        @formaPago = 'Tarjeta',
        @puntoVenta = 'Portal Web Iguazú',
        @total = 0.00;

    PRINT 'Evidencia post-alta Venta:';
    SELECT * FROM Ventas.Venta WHERE idVisitante = @idVisitante;

    SELECT @idVentaTest = idVenta FROM Ventas.Venta WHERE idVisitante = @idVisitante;

    -- 2. Test Modificación Exitosa
    EXEC Ventas.sp_ModificacionVenta
        @idVenta = @idVentaTest,
        @idVisitante = @idVisitante,
        @formaPago = 'Transferencia',
        @puntoVenta = 'Boletería Central',
        @total = 4500.50;

    PRINT 'Evidencia post-modificación Venta:';
    SELECT * FROM Ventas.Venta WHERE idVenta = @idVentaTest;

END TRY
BEGIN CATCH
    PRINT 'Error imprevisto en ejecución de pruebas de ventas: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ************************************************************************
-- TEST VENTA: CASOS DE ERROR CONTROLADOS
-- ************************************************************************

-- Prueba A: Cliente falso, datos nulos y total negativo juntos
BEGIN TRANSACTION;
BEGIN TRY
    EXEC Ventas.sp_AltaVenta
        @idVisitante = -1,
        @formaPago = '   ',
        @puntoVenta = NULL,
        @total = -1500.00;
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Venta Inválida)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba B: Validación de forma de pago inválida
BEGIN TRANSACTION;
BEGIN TRY
    EXEC Ventas.sp_AltaVenta
        @idVisitante = 1,
        @formaPago = 'Criptomonedas', -- No existe en el CHECK
        @puntoVenta = 'Portal Web',
        @total = 100.00;
END TRY
BEGIN CATCH
    PRINT 'Mensaje controlado capturado con éxito en el CATCH:';
    SELECT value AS [Errores Atrapados (CHECK FormaPago)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TESTING DE DETALLE VENTA
-- ========================================================================
-- ************************************************************************
-- TEST DETALLE VENTA: CASO EXITOSO
-- ************************************************************************
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idTypeP INT, @idPark INT, @idCat INT, @idTarifa INT, @idCli INT, @idTicket INT, @idDetalleTest INT;

    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_DetVenta');
    SET @idTypeP = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTypeP, 'TEST_Parque Detalle', 'region D', 'Provincia D', 900.00);
    SET @idPark = SCOPE_IDENTITY();

    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('TEST_Turista');
    SET @idCat = SCOPE_IDENTITY();

    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) 
    VALUES (@idPark, @idCat, 2000.00);
    SET @idTarifa = SCOPE_IDENTITY();

    INSERT INTO Ventas.Visitante (nombre, apellido) VALUES ('TEST_Comprador', 'Detalle');
    SET @idCli = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total) 
    VALUES (@idCli, 'Tarjeta', 'Puesto A', 4000.00);
    SET @idTicket = SCOPE_IDENTITY();

    -- 1. Test Alta Exitosa
    EXEC Ventas.sp_AltaDetalleVenta
        @idVenta = @idTicket,
        @idEntrada = @idTarifa,
        @cantidad = 2,
        @precioUnitario = 2000.00,
        @fechaAcceso = '2026-06-18'; -- Pasaporte para el día planificado

    PRINT 'Evidencia post-alta Detalle Venta:';
    SELECT * FROM Ventas.DetalleVenta WHERE idVenta = @idTicket;

    SELECT @idDetalleTest = idDetalleVenta FROM Ventas.DetalleVenta WHERE idVenta = @idTicket;

    -- 2. Test Modificación Exitosa
    EXEC Ventas.sp_ModificacionDetalleVenta
        @idDetalleVenta = @idDetalleTest,
        @idVenta = @idTicket,
        @idEntrada = @idTarifa,
        @cantidad = 3,
        @precioUnitario = 2000.00,
        @fechaAcceso = '2026-06-19'; -- Cambio de planes en la fecha de visita

    PRINT 'Evidencia post-modificación Detalle Venta:';
    SELECT * FROM Ventas.DetalleVenta WHERE idDetalleVenta = @idDetalleTest;

END TRY
BEGIN CATCH
    PRINT 'Error inesperado detectado en flujo de ítems facturados: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO

-- ************************************************************************
-- CASOS DE ERROR CONTROLADOS
-- ************************************************************************

-- Prueba A: IDs de cabecera y catálogo falsos, cantidad cero, subtotal negativo y fecha nula
BEGIN TRANSACTION;
BEGIN TRY
    -- Mandamos parámetros incorrectos para ver la grilla de errores consolidada (sumando la fecha nula)
    EXEC Ventas.sp_AltaDetalleVenta
        @idVenta = -1,
        @idEntrada = -1,
        @cantidad = 0,
        @precioUnitario = -100.00,
        @fechaAcceso = NULL; -- Violación de dato mandatorio
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Detalle Inválido)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;

-- Prueba B: Modificación con ID de renglón inexistente y parámetros en NULL
BEGIN TRY
    EXEC Ventas.sp_ModificacionDetalleVenta
        @idDetalleVenta = -999,
        @idVenta = 1,
        @idEntrada = 1,
        @cantidad = NULL,
        @precioUnitario = NULL,
        @fechaAcceso = NULL; -- Violación de dato mandatorio en UPDATE
END TRY
BEGIN CATCH
    SELECT value AS [Errores Atrapados (Modificación Inexistente)]
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
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

-- ===============================================================
-- CASOS EXITOSOS - HABILITACION (ALTA --> MODIFICACION -- > BAJA)
-- ===============================================================
 BEGIN TRANSACTION

    DECLARE @idHabilitacionTest INT;

    --1. test alta exitosa
    EXEC Guias.sp_AltaHabilitacion 
        @nombre = 'Guía Provincial de Pesca', 
        @fechaEmision = '2026-01-01', 
        @fechaVencimiento = '2028-01-01';

    SELECT @idHabilitacionTest = idHabilitacion 
    FROM Guias.Habilitacion WHERE nombre = 'Guía Provincial de Pesca';

    PRINT '     [EVIDENCIA] Registro insertado en la tabla:';
    SELECT * FROM Guias.Habilitacion WHERE idHabilitacion = @idHabilitacionTest;

    --2.test modificacion exitosa
    EXEC Guias.sp_ModificacionHabilitacion 
    @idHabilitacion = @idHabilitacionTest, 
    @nombre = 'Guía Provincial de Pesca - Modificado', 
    @fechaEmision = '2026-01-01', 
    @fechaVencimiento = '2029-01-01';

    PRINT '     [EVIDENCIA] Registro modificado en la tabla:';
    SELECT * FROM Guias.Habilitacion WHERE idHabilitacion = @idHabilitacionTest;

    --3.test Baja exitosa

    EXEC Guias.sp_BajaHabilitacion
    @idHabilitacion = @idHabilitacionTest;

    PRINT '     [EVIDENCIA] Registro eliminado (debe devolver 0 filas):';
    SELECT * FROM Guias.Habilitacion WHERE idHabilitacion = @idHabilitacionTest;

ROLLBACK TRANSACTION;
GO

-- ==========================================================================
-- CASOS ERRORES CONTROLADOS - HABILITACION (ALTA --> MODIFICACION -- > BAJA)
-- ==========================================================================
----------------------ALTA----------------------------
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
        EXEC Guias.sp_AltaHabilitacion 
        @nombre = '', 
        @fechaEmision = '2026-05-20', 
        @fechaVencimiento = '2025-05-20';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
-----------------------------Modificacion-------------
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
        EXEC Guias.sp_ModificacionHabilitacion 
        @idHabilitacion = -5, 
        @nombre = 'Invalido', 
        @fechaEmision = NULL, 
        @fechaVencimiento = NULL;
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
--------------------BAJA---------------
BEGIN TRANSACTION
BEGIN TRY

        EXEC Guias.sp_BajaHabilitacion 
        @idHabilitacion = 7777777;
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

----------------- BAJA - con guias asociados-------------------------------
BEGIN TRANSACTION
BEGIN TRY
        DECLARE @idHabBloqueada INT;
        DECLARE @idGuiaBloq     INT;

        INSERT INTO Guias.Habilitacion(nombre, fechaEmision, fechaVencimiento)
        VALUES ('TEST_Hab', '2024-01-01', '2030-01-01');
        SET @idHabBloqueada = SCOPE_IDENTITY();

        INSERT INTO Guias.Guia (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion)
        VALUES ('TEST', 'TEST', '1990-01-01', 'DNI', '11111111', 'bloq@test.com', '2030-01-01');
        SET @idGuiaBloq = SCOPE_IDENTITY();

        INSERT INTO Guias.GuiaHabilitacion(idGuia,idHabilitacion)
        VALUES (@idGuiaBloq, @idHabBloqueada)


        EXEC Guias.sp_BajaHabilitacion 
        @idHabilitacion = @idHabBloqueada;
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
-- ==========================================================================
-- CASOS EXISTOSOS: - GuiaHabilitacion (ALTA-- > BAJA)
-- ==========================================================================

USE ParquesNacionales
GO

BEGIN TRANSACTION

    DECLARE @idHabilitacionTEST INT;
    DECLARE @idGuiaTEST         INT;

    INSERT INTO Guias.Habilitacion(nombre, fechaEmision, fechaVencimiento)
    VALUES ('TEST_Habilitacion', '2024-01-01', '2030-01-01');
    SET @idHabilitacionTEST = SCOPE_IDENTITY();

    INSERT INTO Guias.Guia (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion)
    VALUES ('TEST_Nombre', 'TEST_Apellido', '1990-01-01', 'DNI', '11111111', 'test@test.com', '2030-01-01');
    SET @idGuiaTEST = SCOPE_IDENTITY();

    --1. test alta exitosa
    EXEC Guias.sp_AltaGuiaHabilitacion
        @idGuia = @idGuiaTEST,
        @idHabilitacion = @idHabilitacionTEST;

     PRINT '[EVIDENCIA] Relacion Insertada:';
    SELECT *
    FROM Guias.GuiaHabilitacion 
    WHERE idGuia = @idGuiaTEST AND idHabilitacion = @idHabilitacionTEST;

    --2.test Baja exitosa

    EXEC Guias.sp_BajaGuiaHabilitacion
        @idHabilitacion = @idHabilitacionTEST,
        @idGuia = @idGuiaTEST;

    PRINT '[EVIDENCIA] Relacion eliminada (debe devolver 0 filas):';
    SELECT * FROM Guias.GuiaHabilitacion 
    WHERE idHabilitacion = @idHabilitacionTEST AND idGuia = @idGuiaTEST;

ROLLBACK TRANSACTION;
GO

-- ==========================================================================
-- CASOS ERRORES CONTROLADOS: - GuiaHabilitacion (ALTA-- > BAJA)
-- ==========================================================================
----------------------ALTA----------------------------
USE ParquesNacionales;
GO
--ids inexistentes
BEGIN TRANSACTION
BEGIN TRY
        EXEC Guias.sp_AltaGuiaHabilitacion 
        @idGuia = -1, 
        @idHabilitacion = -1;
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
--- id duplicados
BEGIN TRANSACTION
BEGIN TRY
    DECLARE @idGuiaDup         INT;
    DECLARE @idHabilitacionDup INT;
    
    INSERT INTO Guias.Guia (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion)
    VALUES ('TEST_Nombre', 'TEST_Apellido', '1990-01-01', 'DNI', '40111222', 'dup@guia.com', '2030-01-01');
    SET @idGuiaDup = SCOPE_IDENTITY();

    INSERT INTO Guias.Habilitacion (nombre, fechaEmision, fechaVencimiento)
    VALUES ('TEST_Habilitacion', '2024-01-01', '2030-01-01');
    SET @idHabilitacionDup = SCOPE_IDENTITY();

    EXEC Guias.sp_AltaGuiaHabilitacion
        @idHabilitacion = @idHabilitacionDup,
        @idGuia = @idGuiaDup;
    
    --debe fallar porque esta duplicado
    EXEC Guias.sp_AltaGuiaHabilitacion
        @idHabilitacion = @idHabilitacionDup,
        @idGuia = @idGuiaDup;
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
--------------------BAJA---------------
BEGIN TRANSACTION
BEGIN TRY

        EXEC Guias.sp_BajaGuiaHabilitacion 
        @idHabilitacion = -1,
        @idGuia = -1;
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ==========================================================================
-- CASOS EXITOSOS: - Titulo (ALTA--> MODIFICAR --> BAJA)
-- ==========================================================================

 BEGIN TRANSACTION

    DECLARE @idTituloTest INT;

    --1. test alta exitosa
    EXEC Guias.sp_AltaTitulo
        @nombre = 'Tecnico Superior en Trekking', 
        @fechaEmision = '2018-06-15';

    SELECT @idTituloTest = idTitulo 
    FROM Guias.Titulo WHERE nombre = 'Tecnico Superior en Trekking';

    PRINT '     [EVIDENCIA] Registro insertado en la tabla:';
    SELECT * FROM Guias.Titulo WHERE idTitulo = @idTituloTest;

    --2.test modificacion exitosa
    EXEC Guias.sp_ModificacionTitulo 
        @idTitulo = @idTituloTest, 
        @nombre = 'Tecnico Superior en Trekking - Modificado', 
        @fechaEmision = '2018-06-15';

    PRINT '     [EVIDENCIA] Registro modificado en la tabla:';
    SELECT * FROM Guias.Titulo WHERE idTitulo = @idTituloTest;

    --3.test Baja exitosa

    EXEC Guias.sp_BajaTitulo
    @idTitulo = @idTituloTest;

    PRINT '     [EVIDENCIA] Registro eliminado (debe devolver 0 filas):';
    SELECT * FROM Guias.Titulo WHERE idTitulo = @idTituloTest;

ROLLBACK TRANSACTION;
GO


-- ==========================================================================
-- CASOS ERRORES CONTROLADOS: - Titulo (ALTA--> MODIFICAR --> BAJA)
-- ==========================================================================

----------------------ALTA----------------------------
USE ParquesNacionales;
GO

BEGIN TRANSACTION
BEGIN TRY
        EXEC Guias.sp_AltaTitulo 
        @nombre = '', 
        @fechaEmision = 'NULL';
END TRY
BEGIN CATCH
    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO

-----duplicado
BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO Guias.Titulo (nombre, fechaEmision)
    VALUES ('Tecnico Superior en Trekking','2018-06-15');

    EXEC Guias.sp_AltaGuia
        @nombre='Tecnico Superior en Trekking',
        @fechaEmision='2018-06-15';
END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10))
    WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO
-----------------------------Modificacion-------------
