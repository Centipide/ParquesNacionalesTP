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
USE ParquesNacionales
GO

DROP TABLE IF EXISTS Apis.CotizacionDolar
CREATE TABLE Apis.CotizacionDolar (
    fechaCotizacion    DATE PRIMARY KEY,
    valorCompra        DECIMAL(18,2),
    valorVenta         DECIMAL(18,2),
    fechaActualizacion DATETIME
)
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