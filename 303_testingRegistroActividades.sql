-- ============================================================
-- Fecha: 2025-06-18
-- Descripción: Scripts de Testing para logicaRegistroActividad
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================


-- ============================================================
-- CASOS EXITOSOS - RegistrarActividadRealizada
-- ============================================================

USE Com5600G05_ParquesNacionales;
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

    -- Datos para DetalleContratacion

    INSERT INTO Ventas.Visitante (nombre, apellido)
    VALUES ('TEST_Nombre', 'TEST_Apellido');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PV', 0);

    SET @idVenta = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 10000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta;

    -- Datos para ActividadProgramada

    INSERT INTO Parques.TipoParque(nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Contratación confirmada

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Confirmada',
        @cantidadPersonas = 4;

    -- Ejecución

    EXEC Actividades.sp_AltaActividadRealizada
        @idActividadProgramada = @idActividadProgramada,
        @observaciones = 'Actividad realizada correctamente';

    ----------------------------------------------------
    -- Verificaciones
    ----------------------------------------------------

    -- Debería mostrar estado = Realizada

    SELECT *
    FROM Actividades.ActividadProgramada
    WHERE idActividadProgramada = @idActividadProgramada;

    -- Debería mostrar estado = Completada

    SELECT *
    FROM Actividades.Contratacion
    WHERE idActividadProgramada = @idActividadProgramada;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - RegistrarActividadRealizada
-- ************************************************************

-- *********** Actividad Programada inexistente ***************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_RegistrarActividadRealizada
        @idActividadProgramada = -1;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;
ROLLBACK TRANSACTION;
GO

-- ******* Actividad en estado no Programada ****************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;
    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;
    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    INSERT INTO Parques.TipoParque(nombre)
    VALUES ('TEST_TipoParque');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST', 'TEST', 100);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
    VALUES ('TEST_TipoActividad');

    SET @idTipoActividad = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaActividadTuristica
        @idParque = @idParque,
        @idTipoActividadTuristica = @idTipoActividad,
        @nombre = 'TEST_Actividad',
        @costo = 100,
        @duracion = 60,
        @cupoMaximo = 10;

    SELECT @idActividadTuristica = idActividadTuristica
    FROM Actividades.ActividadTuristica
    WHERE nombre = 'TEST_Actividad';

    INSERT INTO Guias.Guia
        (nombre, apellido, fechaNacimiento,
         tipoDocumento, nroDocumento,
         email, vigenciaAutorizacion)
    VALUES
        ('TEST','TEST','1990-01-01',
         'DNI','12345678',
         'test@test.com','2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia;

    UPDATE Actividades.ActividadProgramada
    SET estado = 'Cancelada'
    WHERE idActividadProgramada = @idActividadProgramada;

BEGIN TRY

    EXEC Actividades.sp_RegistrarActividadRealizada
        @idActividadProgramada = @idActividadProgramada;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO


-- ************* Sin contrataciones *********************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    INSERT INTO Parques.TipoParque(nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    EXEC Actividades.sp_RegistrarActividadRealizada
        @idActividadProgramada = @idActividadProgramada;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ********************** Sin contrataciones confirmadas *******************************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idVisitante INT;
    DECLARE @idVenta INT;
    DECLARE @idDetalleContratacion INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    -- Datos para DetalleContratacion

    INSERT INTO Ventas.Visitante (nombre, apellido)
    VALUES ('TEST_Nombre', 'TEST_Apellido');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PV', 0);

    SET @idVenta = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 10000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta;

    -- Datos para ActividadProgramada

    INSERT INTO Parques.TipoParque(nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Contratación cancelada

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Cancelada',
        @cantidadPersonas = 4;


    EXEC Actividades.sp_RegistrarActividadRealizada
        @idActividadProgramada = @idActividadProgramada;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO



-- ============================================================
-- CASOS EXITOSOS - CancelarActividadProgramada
-- ============================================================

-- Verifica que al cancelar una actividad programada:
-- 1. La actividad cambie su estado a Cancelada.
-- 2. Se registren las observaciones.
-- 3. Las contrataciones Confirmadas pasen a Cancelada.
-- 4. Las contrataciones en otros estados no se modifiquen.

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idVisitante INT;
    DECLARE @idVenta INT;
    DECLARE @idDetalleContratacion1 INT;
    DECLARE @idDetalleContratacion2 INT;

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    -- Visitante y Venta

    INSERT INTO Ventas.Visitante(nombre, apellido)
    VALUES ('TEST_Nombre', 'TEST_Apellido');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PV', 0);

    SET @idVenta = SCOPE_IDENTITY();

    -- Dos detalles de contratación

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 10000;

    SELECT @idDetalleContratacion1 = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta
      AND costoTotal = 10000;

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 15000;

    SELECT @idDetalleContratacion2 = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta
      AND costoTotal = 15000;

    -- Actividad Programada

    INSERT INTO Parques.TipoParque(nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Localidad', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Contrataciones

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion1,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Confirmada',
        @cantidadPersonas = 2;

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion2,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 7000,
        @estado = 'Completada',
        @cantidadPersonas = 4;

    -- Cancelación

    EXEC Actividades.sp_CancelarActividadProgramada
        @idActividadProgramada = @idActividadProgramada,
        @observaciones = 'Cancelada por condiciones climaticas';

    ----------------------------------------------------
    -- Verificaciones
    ----------------------------------------------------

    -- Debería mostrar estado = Cancelada

    SELECT estado, observaciones
    FROM Actividades.ActividadProgramada
    WHERE idActividadProgramada = @idActividadProgramada;

    -- La primera Contratacion Deberia pasar a cancelada
    -- La segunda Contratacion Deberia seguir en Completada

    SELECT idContratacion,
           estado,
           cantidadPersonas
    FROM Actividades.Contratacion
    WHERE idActividadProgramada = @idActividadProgramada;

ROLLBACK TRANSACTION;
GO


-- ************************************************************
-- CASOS DE ERROR - CancelarActividadProgramada
-- ************************************************************

-- ********************** id Actividad Programada inexistente *******************************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_CancelarActividadProgramada
        @idActividadProgramada = -1,
        @observaciones = 'TEST';

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO



-- ********** Actividad no esta en estado Programada *********

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idTipoParque INT;
    DECLARE @idParque INT;

    DECLARE @idTipoActividad INT;
    DECLARE @idActividadTuristica INT;

    DECLARE @idGuia INT;
    DECLARE @idActividadProgramada INT;

    INSERT INTO Parques.TipoParque(nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'TEST_Parque', 'TEST_Region', 'TEST_Provincia', 1000);

    SET @idParque = SCOPE_IDENTITY();

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;

    -- Fuerzo otro estado
    UPDATE Actividades.ActividadProgramada
    SET estado = 'Realizada'
    WHERE idActividadProgramada = @idActividadProgramada;

    EXEC Actividades.sp_CancelarActividadProgramada
        @idActividadProgramada = @idActividadProgramada;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO


-- ============================================================
-- CASO EXITOSO - CancelarContratacion
-- ============================================================

-- Verifica que al cancelar una contratación Confirmada
-- su estado pase a Cancelada.

USE Com5600G05_ParquesNacionales;
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

    -- Datos para DetalleContratacion

    INSERT INTO Ventas.Visitante (nombre, apellido)
    VALUES ('TEST_Nombre', 'TEST_Apellido');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PV', 0);

    SET @idVenta = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 10000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta
      AND costoTotal = 10000;

    -- Datos para ActividadProgramada

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque
        (idTipoParque, nombre, region, provincia, superficie)
    VALUES
        (@idTipoParque, 'TEST_Parque', 'TEST_Region',
         'TEST_Provincia', 1000);

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
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion
        (idGuia, idActividadTuristica)
    VALUES
        (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia
      AND idActividadTuristica = @idActividadTuristica;

    -- Contratacion

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Confirmada',
        @cantidadPersonas = 4;

    SELECT @idContratacion = idContratacion
    FROM Actividades.Contratacion
    WHERE idDetalleContratacion = @idDetalleContratacion
      AND idActividadProgramada = @idActividadProgramada;

    -- Cancelacion

    EXEC Actividades.sp_CancelarContratacion
        @idContratacion = @idContratacion;

    ----------------------------------------------------
    -- Verificacion
    ----------------------------------------------------

    -- Debería mostrar estado = Cancelada

    SELECT idContratacion,
           estado
    FROM Actividades.Contratacion
    WHERE idContratacion = @idContratacion;

ROLLBACK TRANSACTION;
GO

-- ************************************************************
-- CASOS DE ERROR - CancelarActividadProgramada
-- ************************************************************


-- ********************** id de Contratacion no existe *******************************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_CancelarContratacion
        @idContratacion = -1;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO

-- ********************** Contratacion no esta en estado Confirmada *******************************

USE Com5600G05_ParquesNacionales;
GO

BEGIN TRANSACTION;

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

    -- Datos para DetalleContratacion

    INSERT INTO Ventas.Visitante (nombre, apellido)
    VALUES ('TEST_Nombre', 'TEST_Apellido');

    SET @idVisitante = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total)
    VALUES (@idVisitante, 'Efectivo', 'TEST_PV', 0);

    SET @idVenta = SCOPE_IDENTITY();

    EXEC Actividades.sp_AltaDetalleContratacion
        @idVenta = @idVenta,
        @costoTotal = 10000;

    SELECT @idDetalleContratacion = idDetalleContratacion
    FROM Actividades.DetalleContratacion
    WHERE idVenta = @idVenta
      AND costoTotal = 10000;

    -- Datos para ActividadProgramada

    INSERT INTO Parques.TipoParque (nombre, descripcion)
    VALUES ('TEST_TipoParque', 'TEST');

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
        ('TEST_Guia', 'TEST_Apellido', '1990-01-01',
         'DNI', '12345678',
         'test@test.com', '2030-01-01');

    SET @idGuia = SCOPE_IDENTITY();

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);

    EXEC Actividades.sp_AltaActividadProgramada
        @idGuia = @idGuia,
        @idActividadTuristica = @idActividadTuristica,
        @fecha = '2026-12-01',
        @horaInicio = '09:00';

    SELECT @idActividadProgramada = idActividadProgramada
    FROM Actividades.ActividadProgramada
    WHERE idGuia = @idGuia
      AND idActividadTuristica = @idActividadTuristica;

    -- Contratacion en estado Cancelada

    EXEC Actividades.sp_AltaContratacion
        @idDetalleContratacion = @idDetalleContratacion,
        @idActividadProgramada = @idActividadProgramada,
        @costo = 5000,
        @estado = 'Cancelada',
        @cantidadPersonas = 4;

    SELECT @idContratacion = idContratacion
    FROM Actividades.Contratacion
    WHERE idDetalleContratacion = @idDetalleContratacion
      AND idActividadProgramada = @idActividadProgramada;

BEGIN TRY

    EXEC Actividades.sp_CancelarContratacion
        @idContratacion = @idContratacion;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS Error;

END CATCH;

ROLLBACK TRANSACTION;
GO
