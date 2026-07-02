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

    DECLARE @url          VARCHAR(MAX) = 'https://dolarapi.com/v1/dolares/oficial'
    DECLARE @object       INT
    DECLARE @respuestaTxt VARCHAR(MAX)
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
    DECLARE @respuestaTabla TABLE (respuestaTxt VARCHAR(MAX))
    INSERT INTO @respuestaTabla (respuestaTxt)
    EXEC sp_OAMethod @object, 'respuestaTxt'

    SELECT @respuestaTxt = respuestaTxt FROM @respuestaTabla
    EXEC sp_OADestroy @object

    -- Procesamos el JSON y hacemos upsert
    IF @respuestaTxt IS NOT NULL
    BEGIN
        MERGE Apis.CotizacionDolar AS tar
        USING (
            SELECT
                CAST(JSON_VALUE(@respuestaTxt, '$.fechaActualizacion') AS DATE) as fechaCotizacion,
                CAST(JSON_VALUE(@respuestaTxt, '$.compra') AS DECIMAL(18,2)) as valorCompra,
                CAST(JSON_VALUE(@respuestaTxt, '$.venta') AS DECIMAL(18,2)) as valorVenta,
                CAST(JSON_VALUE(@respuestaTxt, '$.fechaActualizacion') AS DECIMAL(18,2)) as fechaActualizacion
        ) AS src
        ON tar.fechaCotizacion = src.fechaCotizacion
        WHEN MATCHED THEN
            UPDATE SET
                valorCompra = src.valorCompra,
                valorVenta = src.valorVenta,
                fechaActualizacion = src.fechaActualizacion
        WHEN NOT MATCHED THEN
            INSERT (fechaCotizacion, valorCompra, valorVenta, fechaActualizacion)
            VALUES (src.fechaCotizacion, src.valorCompra, src.valorVenta, src.fechaActualizacion)

        PRINT 'Cotizacion de dolar actualizada.'
    END

    ELSE
    BEGIN
        PRINT 'No se obtuvo despues de la API'
    END
END
GO