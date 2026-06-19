-- ========================================================================
--  UNIVERSIDAD NACIONAL DE LA MATANZA
--  Asignatura: 3641 - Bases de Datos Aplicada
--  Objetivo del Código: Script de Testing 1:1 para Lógica de Concesiones
-- ======================================================================== */
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

-- ========================================================================
-- TESTS DE NEGOCIO EN CASO EXITOSO
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesion INT;
    DECLARE @idTipoParque INT;

    -- Estructura semilla de pruebas
    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_NegFlujo');
    SET @idTipoParque = SCOPE_IDENTITY();
    
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) 
    VALUES (@idTipoParque, 'Parque Negocio Ok', 'L', 'P', 500);
    SET @idParque = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial) 
    VALUES ('30111111152', 'Parador Activo S.A.');
    SET @idEmpresa = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.TipoActividadConcesion (nombre) 
    VALUES ('Servicios Comerciales OK');
    SET @idActividad = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresa, @idActividad, @idParque, '2026-01-01', '2026-12-31', 80000.00, 'Activa');
    SET @idConcesion = SCOPE_IDENTITY();

    -- Probar Pago Exitoso en Concesión Activa
    EXEC Concesiones.sp_RegistrarPagoCanonNegocio 
        @idConcesion = @idConcesion, 
        @monto = 80000.00;

    PRINT 'Evidencia post-pago exitoso (Debe listar 1 pago registrado):';
    SELECT * FROM Concesiones.PagoCanon WHERE idConcesion = @idConcesion;

END TRY
BEGIN CATCH
    PRINT 'Fallo inesperado en camino feliz: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TESTS DE NEGOCIO: CASOS DE ERROR
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesion INT;
    DECLARE @idTipoParque INT;

    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_NegErr');
    set @idTipoParque = SCOPE_IDENTITY();
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) VALUES (@idTipoParque, 'P', 'L', 'P', 100);
    set @idParque = SCOPE_IDENTITY();
    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial) VALUES ('30999999952', 'Parador Inactivo S.A.');
    set @idEmpresa = SCOPE_IDENTITY();
    INSERT INTO Concesiones.TipoActividadConcesion (nombre) VALUES ('Servicios Err');
    set @idActividad = SCOPE_IDENTITY();
    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresa, @idActividad, @idParque, '2026-01-01', '2026-12-31', 50000.00, 'Activa');
    SET @idConcesion = SCOPE_IDENTITY();

    -- Escenario A: Probar cancelación de ID inexistente
    PRINT 'Escenario A - Intento de cancelación de ID falso:';
    EXEC Concesiones.sp_CancelarConcesion @idConcesion = -999;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- Escenario B: Probar rechazo de cobro a contrato Cancelado
    PRINT CHAR(10) + 'Escenario B - Intento de pago en contrato Cancelado:';
    EXEC Concesiones.sp_CancelarConcesion @idConcesion = @idConcesion;
    EXEC Concesiones.sp_RegistrarPagoCanonNegocio @idConcesion = @idConcesion, @monto = 50000.00;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO