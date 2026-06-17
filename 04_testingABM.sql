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

-- ==========================================================
-- TESTING Parque
-- ==========================================================
-- idTipoParque no existente, nombre vacio, localidad vacia, provincia vacia, superficie invalida
BEGIN TRY
	EXEC Parques.sp_AltaParque @idTipoParque = 54, @nombre = '',
		@localidad = '', @provincia = '', @superficie = '0'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idParque no existe, idTipoParque no existe, superficie invalida
BEGIN TRY
	EXEC Parques.sp_ModificacionParque  @idParque = 1, @idTipoParque = 54, @nombre = '',
		@localidad = '', @provincia = '', @superficie = '0'
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


-- ==========================================================
-- TESTING TipoParque
-- ==========================================================
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





/*
TipoActividadTuristica X
ActividadTuristica X
GuiaAutorizacion
ActividadProgramada
Contratacion
DetalleContratacion
*/



-- ===========================================================
-- CASOS EXITOSOS - TipoActividadTuristica'
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

-- ============================================================
-- CASOS DE ERROR - TipoActividadTuristica
-- ============================================================

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000.00);

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

-- ============================================================
-- CASOS DE ERROR - ActividadTuristica
-- ============================================================

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