-- ============================================================
-- Fecha: 2025-07-02
-- Descripción: Creación de los SP para la importacion
--              de las APIs.
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO

-- ============================================================
-- API para la cotizacion del dolar oficial
-- https://dolarapi.com/docs/argentina/operations/get-dolar-oficial.html
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Apis.sp_ImportarDolarOficial
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @url          VARCHAR(8000) = 'https://dolarapi.com/v1/dolares/oficial'
    DECLARE @object       INT
    DECLARE @respuestaTxt VARCHAR(8000)
    DECLARE @status       INT

    -- Creamos el objeto HTTP
    EXEC @status = sp_OACreate 'MSXML2.ServerXMLHTTP', @object OUT
    IF @status <> 0
    BEGIN
        PRINT 'Error creando objeto HTTP'
        RETURN
    END
    
    -- Configuramos y enviamos la peticion
    EXEC sp_OAMethod @object, 'OPEN', NULL, 'GET', @url, 'FALSE'
    EXEC sp_OAMethod @object, 'SEND'

    -- Capturamos la respuesta
    EXEC sp_OAGetProperty @object, 'responseText', @respuestaTxt OUT
    EXEC sp_OADestroy @object

    -- Procesamos el JSON y hacemos upsert
    IF @respuestaTxt IS NOT NULL AND ISJSON(@respuestaTxt) = 1
    BEGIN
        DECLARE @fechaCotizacion    DATE = CAST(JSON_VALUE(@respuestaTxt, '$.fechaActualizacion') AS DATE)
        DECLARE @valorCompra        DECIMAL(18,2) = CAST(JSON_VALUE(@respuestaTxt, '$.compra') AS DECIMAL(18,2))
        DECLARE @valorVenta         DECIMAL(18,2) = CAST(JSON_VALUE(@respuestaTxt, '$.venta') AS DECIMAL(18,2))
        DECLARE @fechaActualizacion DATETIME = CAST(JSON_VALUE(@respuestaTxt, '$.fechaActualizacion') AS DATETIME)

        IF EXISTS (
            SELECT 1 FROM Apis.CotizacionDolar
            WHERE fechaCotizacion = @fechaCotizacion
        )
        BEGIN
            UPDATE Apis.CotizacionDolar
            SET
                valorCompra = @valorCompra,
                valorVenta = @valorVenta,
                fechaActualizacion = @fechaActualizacion
            WHERE
                fechaCotizacion = @fechaCotizacion
            PRINT 'Cotizacion actualizada.'
        END
        ELSE
        BEGIN
            INSERT INTO Apis.CotizacionDolar (fechaCotizacion, valorCompra, valorVenta, fechaActualizacion)
            VALUES (@fechaCotizacion, @valorCompra, @valorVenta, @fechaActualizacion)

            PRINT 'Nueva cotizacion agregada.'
        END
    END
    ELSE
    BEGIN
        PRINT 'No se obtuvo respuesta de la API.'
    END
END
GO


-- ============================================================
-- API para traer los feriados en Argentina
-- https://argentinadatos.com/docs/operations/get-feriados
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Apis.sp_ImportarFeriados
    @anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    IF @anio IS NULL
    SET @anio = YEAR(GETDATE())

    DECLARE @url          VARCHAR(8000) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(@anio AS VARCHAR(4))
    DECLARE @object       INT
    DECLARE @respuestaTxt VARCHAR(8000)
    DECLARE @status       INT

    -- Creamos el objeto HTTP
    EXEC @status = sp_OACreate 'MSXML2.ServerXMLHTTP', @object OUT
    IF @status <> 0
    BEGIN
        PRINT 'Error creando objeto HTTP'
        RETURN
    END
    
    -- Configuramos y enviamos la peticion
    EXEC sp_OAMethod @object, 'OPEN', NULL, 'GET', @url, 'FALSE'
    EXEC sp_OAMethod @object, 'SEND'

    -- Capturamos la respuesta
    EXEC sp_OAGetProperty @object, 'responseText', @respuestaTxt OUT
    EXEC sp_OADestroy @object

    -- Procesamos el JSON y hacemos upsert
    IF @respuestaTxt IS NOT NULL AND ISJSON(@respuestaTxt) = 1
    BEGIN
        -- Actualiza si existe
        UPDATE tar
        SET
            tar.tipo = src.tipo,
            tar.nombre = src.nombre
        FROM Apis.Feriados tar
        INNER JOIN OPENJSON(@respuestaTxt)
        WITH (
            fecha  DATE         '$.fecha',
            tipo   VARCHAR(100) '$.tipo',
            nombre VARCHAR(250) '$.nombre'
        ) src ON tar.fecha = src.fecha

        -- Inserta si no existe
        INSERT INTO Apis.Feriados (fecha, tipo, nombre)
        SELECT src.fecha, src.tipo, src.nombre
        FROM OPENJSON(@respuestaTxt)
        WITH (
            fecha  DATE         '$.fecha',
            tipo   VARCHAR(100) '$.tipo',
            nombre VARCHAR(250) '$.nombre'
        ) src
        WHERE NOT EXISTS (
            SELECT 1 FROM Apis.Feriados tar
            WHERE tar.fecha = src.fecha
        )

        PRINT 'Feriados de ' + CAST(@anio AS VARCHAR(4)) + ' importados/actualizados correctamente.'
    END
    ELSE
    BEGIN
        PRINT 'No se obtuvo respuesta de la API.'
    END
END
GO