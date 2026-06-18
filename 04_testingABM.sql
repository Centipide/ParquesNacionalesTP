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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

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

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque,'TEST_Parque','TEST_Localidad','TEST_Provincia',1000);

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
-- TEST CASO EXITOSO: ALTA -> MODIFICACIÓN -> ELIMINACIÓN
-- ========================================================================

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


-- ========================================================================
-- TEST CASO FALLIDO: SIMULACIÓN DE INFRACCIÓN A VALIDACIONES
-- ========================================================================
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
-- TEST TIPO ACTIVIDAD CONCESION: CASO EXITOSO (CON ROLLBACK)
-- ========================================================================

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


-- ========================================================================
-- TEST TIPO ACTIVIDAD CONCESION: CASO DE ERROR
-- ========================================================================
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
-- TEST CONCESION: CASO EXITOSO (CON ROLLBACK)
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesionTest INT;
    DECLARE @idTipoParque INT;

    -- Generar datos de soporte necesarios para cumplir las FKs
    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_Reserva', 'Reserva de pruebas');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque Meteorito', 'Localidad Test', 'Provincia Test', 5500.50);
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


-- ========================================================================
-- TEST CONCESION: CASO DE ERROR (VALIDACIONES ACUMULATIVAS)
-- ========================================================================
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
-- TEST PAGO CANON: CASO EXITOSO Y RESTRICCIÓN DE BAJA
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesion INT, @idPagoTest INT;
    DECLARE @idTipoParque INT;

    -- Datos semilla de soporte para la integridad de claves
    INSERT INTO Parques.TipoParque (nombre, descripcion) VALUES ('TEST_ReservaPago', 'Pruebas Pago');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque Financiero', 'Localidad F', 'Provincia F', 2300.00);
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


-- ========================================================================
-- TEST PAGO CANON: CASO DE ERROR (VALIDACIONES CRUZADAS)
-- ========================================================================

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