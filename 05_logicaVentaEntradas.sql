-- ========================================================================
-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- Asignatura: 3641 - Bases de Datos Aplicada
-- Objetivo del Código: Lógica Avanzada de Procesamiento de Ventas
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
-- 1. CREACIÓN DEL USER-DEFINED TABLE TYPE
-- ========================================================================
-- NOTA: Si el tipo ya existía por pruebas previas, lo borramos para recrearlo
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'TipoRenglonVenta' AND schema_id = SCHEMA_ID('Ventas'))
    DROP TYPE Ventas.TipoRenglonVenta;
GO

CREATE TYPE Ventas.TipoRenglonVenta AS TABLE (
    idEntrada       INT           NOT NULL,
    cantidad        INT           NOT NULL,
    precioUnitario  DECIMAL(10,2) NOT NULL,
    fechaAcceso     DATE          NOT NULL
);
GO

-- ========================================================================
-- 2. SP DE NEGOCIO: REGISTRO INTEGRAL DE VENTA CON MULTIPLICIDAD DE ITEMS
-- ========================================================================
CREATE OR ALTER PROCEDURE Ventas.sp_RegistrarVentaEntradas
    @idVisitante INT,
    @formaPago   VARCHAR(50),
    @puntoVenta  VARCHAR(50),
    @renglones   Ventas.TipoRenglonVenta READONLY -- Parámetro de tabla
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Si algo explota, deshace toda la transacción automáticamente

    DECLARE @errores VARCHAR(2000) = '';

    -- [VALIDACIONES DE CABECERA]
    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
        SET @errores += '- Error: El cliente/visitante especificado no existe.' + CHAR(10);

    IF @formaPago IS NULL OR LTRIM(RTRIM(@formaPago)) NOT IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Digital')
        SET @errores += '- Error: La forma de pago no es válida según directivas de negocio.' + CHAR(10);

    IF @puntoVenta IS NULL OR LTRIM(RTRIM(@puntoVenta)) = ''
        SET @errores += '- Error: Debe especificar el puesto/punto de venta emisor.' + CHAR(10);

    -- [VALIDACIONES DE RENGLONES]
    -- 1. Validar que vengan ítems para facturar
    IF NOT EXISTS (SELECT 1 FROM @renglones)
        SET @errores += '- Error de Negocio: No se pueden registrar ventas sin ítems en el carrito.' + CHAR(10);

    -- 2. Validar que todos los idEntrada existan en el catálogo
    IF EXISTS (SELECT 1 FROM @renglones r LEFT JOIN Ventas.Entrada e ON r.idEntrada = e.idEntrada WHERE e.idEntrada IS NULL)
        SET @errores += '- Error de Negocio: Uno o más IDs de tarifas ingresadas no existen en el catálogo.' + CHAR(10);

    -- 3. Validar consistencia de precios (Que no alteren el precio desde la interfaz)
    IF EXISTS (SELECT 1 FROM @renglones r JOIN Ventas.Entrada e ON r.idEntrada = e.idEntrada WHERE r.precioUnitario <> e.precio)
        SET @errores += '- Error de Fraude: El precio unitario enviado no coincide con la tarifa vigente del catálogo.' + CHAR(10);

    -- 4. Validar que la fecha de uso no sea del pasado
    IF EXISTS (SELECT 1 FROM @renglones WHERE fechaAcceso < CAST(GETDATE() AS DATE))
        SET @errores += '- Error Cronológico: No se pueden emitir pases de acceso para fechas pasadas.' + CHAR(10);

    -- Si algo falló, cortamos el flujo antes de abrir transacción
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    -- [PROCESO TRANSACCIONAL]
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @idVentaNueva INT;

        -- A. Creamos la cabecera limpia con total cero transitorio
        INSERT INTO Ventas.Venta (idVisitante, fechaHora, formaPago, puntoVenta, total, estado)
        VALUES (@idVisitante, GETDATE(), LTRIM(RTRIM(@formaPago)), LTRIM(RTRIM(@puntoVenta)), 0.00, 'Completada');
        
        SET @idVentaNueva = SCOPE_IDENTITY();

        -- B. Volcamos todos los renglones llamando a nuestro ABM blindado
        -- Usamos un cursor interno o una inserción masiva controlada
        INSERT INTO Ventas.DetalleVenta (idVenta, idEntrada, cantidad, precio, fechaAcceso)
        SELECT @idVentaNueva, idEntrada, cantidad, precioUnitario, fechaAcceso
        FROM @renglones;

        -- C. RECALCULO DE SEGURIDAD Y RECONSISTENCIA DE MONTOS TOTALES
        -- Sumamos el total persistido real generado por el motor y actualizamos la cabecera
        DECLARE @totalReal DECIMAL(12,2);
        SELECT @totalReal = SUM(total) FROM Ventas.DetalleVenta WHERE idVenta = @idVentaNueva;

        UPDATE Ventas.Venta
        SET total = @totalReal
        WHERE idVenta = @idVentaNueva;

        COMMIT TRANSACTION;
        
        -- Retornamos el ID de la transacción exitosa para control
        SELECT @idVentaNueva AS idVentaProcesada, @totalReal AS totalFacturado;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ========================================================================
-- 3. SP DE NEGOCIO: ACTUALIZACIÓN INDEPENDIENTE DE TARIFAS POR PARQUE
-- ========================================================================
CREATE OR ALTER PROCEDURE Ventas.sp_ActualizarPrecioEntrada
    @idParque        INT,
    @idTipoVisitante INT,
    @nuevoPrecio     DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    -- Validamos existencia de la combinación en el catálogo
    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante)
        SET @errores += '- Error de Negocio: No existe ninguna tarifa registrada para la combinación de Parque y Tipo de Visitante especificada.' + CHAR(10);

    -- Validamos magnitud del precio
    IF @nuevoPrecio IS NULL OR @nuevoPrecio < 0
        SET @errores += '- Error de Negocio: El nuevo precio de la tarifa no puede tomar un valor negativo.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    -- Ejecutamos la actualización comercial dirigida
    UPDATE Ventas.Entrada
    SET precio = @nuevoPrecio
    WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante;

    PRINT 'Tarifa de catálogo actualizada con éxito.';
END;
GO

-- ========================================================================
-- 4. SP DE NEGOCIO: ANULACIÓN LÓGICA Y CONTABLE DE TICKET DE VENTA
-- ========================================================================
CREATE OR ALTER PROCEDURE Ventas.sp_AnularVenta
    @idVenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validamos existencia del ticket
    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta)
    BEGIN
        RAISERROR('- Error de Negocio: El código de ticket de venta especificado no existe en los registros.', 16, 1);
        RETURN;
    END

    -- Validamos que no esté anulado previamente para evitar doble procesamiento
    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta AND estado = 'Anulada')
    BEGIN
        RAISERROR('- Error de Negocio: Operación abortada. La venta seleccionada ya se encuentra en estado Anulada.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Modificamos el estado de la cabecera a Anulada (Baja Lógica Contable)
        UPDATE Ventas.Venta
        SET estado = 'Anulada'
        WHERE idVenta = @idVenta;

        COMMIT TRANSACTION;
        PRINT 'Comprobante de venta anulado lógicamente de forma correcta.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO