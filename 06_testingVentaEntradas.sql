-- ========================================================================
-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Componente del Grupo: Bonfigli, Leonardo
-- Objetivo del Código: Suite de Testing Avanzada - Procesamiento de Ventas
-- ========================================================================
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

-- ========================================================================
-- TEST 1: VENTA COMPLETA EXITOSA
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idTipoParque INT, @idParque INT, @idTV1 INT, @idTV2 INT;
    DECLARE @idTarifa1 INT, @idTarifa2 INT, @idCliente INT;

    -- 1. Semillas de infraestructura base
    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_Fact_Tipo');
    SET @idTipoParque = SCOPE_IDENTITY();

    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie)
    VALUES (@idTipoParque, 'Parque Nacional de Pruebas', 'region X', 'Provincia X', 1500.00);
    SET @idParque = SCOPE_IDENTITY();

    -- 2. Semillas de categorías de visitantes
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('TEST_General_Nac');
    SET @idTV1 = SCOPE_IDENTITY();
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('TEST_Menor_Nac');
    SET @idTV2 = SCOPE_IDENTITY();

    -- 3. Registro de tarifas vigentes en el catálogo
    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) VALUES (@idParque, @idTV1, 4000.00);
    SET @idTarifa1 = SCOPE_IDENTITY();
    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) VALUES (@idParque, @idTV2, 2000.00);
    SET @idTarifa2 = SCOPE_IDENTITY();

    -- 4. Semilla del cliente comprador
    INSERT INTO Ventas.Visitante (nombre, apellido, email) VALUES ('Leo', 'Bonfigli', 'leo@unlam.edu.ar');
    SET @idCliente = SCOPE_IDENTITY();

    -- 5. Declaramos y poblamos nuestro carrito virtual
    DECLARE @carrito Ventas.TipoRenglonVenta;
    
    INSERT INTO @carrito (idEntrada, cantidad, precioUnitario, fechaAcceso)
    VALUES 
        (@idTarifa1, 2, 4000.00, '2026-06-20'), -- 2 entradas generales = $8000
        (@idTarifa2, 1, 2000.00, '2026-06-20'); -- 1 entrada menor = $2000
        -- Total esperado en la factura: $10000

    -- 6. Ejecutamos el procesador inteligente de negocio
    EXEC Ventas.sp_RegistrarVentaEntradas
        @idVisitante = @idCliente,
        @formaPago = 'Efectivo',
        @puntoVenta = 'Boletería Principal Terminal',
        @renglones = @carrito;

    -- 7. Auditoría de control de consistencia contable
    PRINT CHAR(10) + 'Evidencia de la Cabecera de la Venta (Total recalculado nativamente):';
    SELECT * FROM Ventas.Venta WHERE idVisitante = @idCliente;

    PRINT CHAR(10) + 'Evidencia de los Renglones del Detalle asociados con su fecha de acceso:';
    SELECT dv.* FROM Ventas.DetalleVenta dv 
    JOIN Ventas.Venta v ON dv.idVenta = v.idVenta WHERE v.idVisitante = @idCliente;

END TRY
BEGIN CATCH
    PRINT 'Error crítico e imprevisto en el camino feliz: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TESTS DE VALIDACIONES CRÍTICAS DE NEGOCIO
-- ========================================================================


-- ========================================================================
-- TEST 2: Intentar mandar un carrito vacío (Sin ítems)
-- ========================================================================
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @carritoVacio Ventas.TipoRenglonVenta; -- Tabla vacía sin inserts
    
    EXEC Ventas.sp_RegistrarVentaEntradas
        @idVisitante = 1, @formaPago = 'Tarjeta', @puntoVenta = 'Web', @renglones = @carritoVacio;
END TRY
BEGIN CATCH
    SELECT value AS [Test 2 - Atrapado (Carrito Vacío)] FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;


-- ========================================================================
-- TEST 3: Intentar ingresar un ID de tarifa inexistente en el catálogo
-- ========================================================================
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @carritoInvalido Ventas.TipoRenglonVenta;
    INSERT INTO @carritoInvalido (idEntrada, cantidad, precioUnitario, fechaAcceso)
    VALUES (-999, 1, 500.00, '2026-06-25');

    EXEC Ventas.sp_RegistrarVentaEntradas
        @idVisitante = 1, @formaPago = 'Tarjeta', @puntoVenta = 'Web', @renglones = @carritoInvalido;
END TRY
BEGIN CATCH
    SELECT value AS [Test 3 - Atrapado (Tarifa Inexistente)] FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;


-- ========================================================================
-- TEST 4: Intentar alterar/alterar el precio de venta (Prevención de Fraudes de Interfaz)
-- ========================================================================
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idP INT, @idTV INT, @idTarifaReal INT;
    INSERT INTO Parques.TipoParque (nombre) VALUES ('T_Fraude');
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) VALUES (SCOPE_IDENTITY(), 'P', 'L', 'P', 10);
    SET @idP = SCOPE_IDENTITY();
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('V_Fraude');
    SET @idTV = SCOPE_IDENTITY();
    
    -- La tarifa real del catálogo es de $5000.00
    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) VALUES (@idP, @idTV, 5000.00);
    SET @idTarifaReal = SCOPE_IDENTITY();

    DECLARE @carritoHackeado Ventas.TipoRenglonVenta;
    -- Forzamos maliciosamente un precio de $10.00 desde afuera
    INSERT INTO @carritoHackeado (idEntrada, cantidad, precioUnitario, fechaAcceso)
    VALUES (@idTarifaReal, 2, 10.00, '2026-06-25');

    EXEC Ventas.sp_RegistrarVentaEntradas
        @idVisitante = 1, @formaPago = 'Tarjeta', @puntoVenta = 'Web UI', @renglones = @carritoHackeado;
END TRY
BEGIN CATCH
    SELECT value AS [Test 4 - Atrapado (Intento de Fraude)] FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;

-- ========================================================================
-- TEST 5: Intentar reservar un pase para una fecha del pasado
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idParq INT, @idVis INT, @idTar INT;
    INSERT INTO Parques.TipoParque (nombre) VALUES ('T_Pasado');
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) VALUES (SCOPE_IDENTITY(), 'P', 'L', 'P', 10);
    SET @idParq = SCOPE_IDENTITY();
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('V_Pasado');
    SET @idVis = SCOPE_IDENTITY();
    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) VALUES (@idParq, @idVis, 1500.00);
    SET @idTar = SCOPE_IDENTITY();

    DECLARE @carritoPasado Ventas.TipoRenglonVenta;
    INSERT INTO @carritoPasado (idEntrada, cantidad, precioUnitario, fechaAcceso)
    VALUES (@idTar, 1, 1500.00, '2023-01-01'); -- Fecha vieja del pasado

    EXEC Ventas.sp_RegistrarVentaEntradas
        @idVisitante = 1, @formaPago = 'Tarjeta', @puntoVenta = 'Web UI', @renglones = @carritoPasado;
END TRY
BEGIN CATCH
    SELECT value AS [Test 5 - Atrapado (Fecha del Pasado)] FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10)) WHERE value <> '';
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TEST 6: ACTUALIZACIÓN INDEPENDIENTE DE PRECIOS
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idPK INT, @idTV INT;
    INSERT INTO Parques.TipoParque (nombre) VALUES ('T_Pre');
    INSERT INTO Parques.Parque (idTipoParque, nombre, region, provincia, superficie) VALUES (SCOPE_IDENTITY(), 'P', 'L', 'P', 10);
    SET @idPK = SCOPE_IDENTITY();
    INSERT INTO Ventas.TipoVisitante (nombre) VALUES ('V_Pre');
    SET @idTV = SCOPE_IDENTITY();
    
    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio) VALUES (@idPK, @idTV, 1200.00);

    PRINT 'Precio inicial en el catálogo:';
    SELECT * FROM Ventas.Entrada WHERE idParque = @idPK AND idTipoVisitante = @idTV;

    -- Ejecutamos la actualización comercial dirigida
    EXEC Ventas.sp_ActualizarPrecioEntrada @idParque = @idPK, @idTipoVisitante = @idTV, @nuevoPrecio = 1850.50;

    PRINT 'Precio final post-ejecución del proceso de precios:';
    SELECT * FROM Ventas.Entrada WHERE idParque = @idPK AND idTipoVisitante = @idTV;

END TRY
BEGIN CATCH
    PRINT 'Error inesperado actualizando tarifa: ' + ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO


-- ========================================================================
-- TEST 7: PROCESO DE ANULACIÓN CONTABLE DE TICKETS
-- ========================================================================

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @idCli INT, @idVenta INT;
    INSERT INTO Ventas.Visitante (nombre, apellido) VALUES ('Test', 'Anula');
    SET @idCli = SCOPE_IDENTITY();

    INSERT INTO Ventas.Venta (idVisitante, formaPago, puntoVenta, total, estado)
    VALUES (@idCli, 'Digital', 'App Móvil', 3500.00, 'Completada');
    SET @idVenta = SCOPE_IDENTITY();

    PRINT 'Estado original del ticket de venta:';
    SELECT idVenta, total, estado FROM Ventas.Venta WHERE idVenta = @idVenta;

    -- Anulamos la operación
    EXEC Ventas.sp_AnularVenta @idVenta = @idVenta;

    PRINT 'Estado definitivo del ticket post-anulación (Baja Lógica):';
    SELECT idVenta, total, estado FROM Ventas.Venta WHERE idVenta = @idVenta;

    -- Forzamos doble anulación errónea para verificar el bloqueo
    PRINT CHAR(10) + 'Intento de re-anulación (Debe disparar error de control):';
    EXEC Ventas.sp_AnularVenta @idVenta = @idVenta;

END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
ROLLBACK TRANSACTION;
GO