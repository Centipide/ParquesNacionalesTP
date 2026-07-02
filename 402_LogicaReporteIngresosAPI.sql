-- ============================================================
-- Fecha: 2025-07-02
-- Descripción: Reporte de ingresos en pesos y dolares
--              por semana, mes y año, por parque
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Reportes.sp_IngresosPorPeriodo
    @idParque INT = NULL,
    @anio     INT = NULL,
    @tipo     VARCHAR(10) = NULL -- 'Entrada', 'Tour', 'Canon'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CotizacionDolar DECIMAL(18,2) = 0

    SELECT TOP 1 @CotizacionDolar = valorVenta
    FROM APIs.CotizacionDolar
    ORDER BY fechaCotizacion DESC

    -- ========================================================================
    -- DESGLOSE CRONOLÓGICO POR MES
    -- ========================================================================
    PRINT 'Generando ResultSet 1: Desglose por Tipo y Mes...';
    
    WITH IngresosBase AS (
        SELECT e.idParque, dv.fechaAcceso AS fecha, dv.total AS monto, 'Entrada' AS tipo
        FROM Ventas.DetalleVenta dv
        JOIN Ventas.Entrada e ON dv.idEntrada = e.idEntrada
        WHERE (@idParque IS NULL OR e.idParque = @idParque)

        UNION ALL

        SELECT at.idParque, CAST(dc.fechaHora AS DATE) AS fecha, dc.costoTotal AS monto, 'Tour' AS tipo
        FROM Actividades.DetalleContratacion dc
        JOIN Actividades.Contratacion c ON c.idDetalleContratacion = dc.idDetalleContratacion
        JOIN Actividades.ActividadProgramada ap ON c.idActividadProgramada = ap.idActividadProgramada
        JOIN Actividades.ActividadTuristica at ON ap.idActividadTuristica = at.idActividadTuristica
        WHERE (@idParque IS NULL OR at.idParque = @idParque)

        UNION ALL

        SELECT con.idParque, pc.fechaPago, pc.monto, 'Canon' AS tipo
        FROM Concesiones.PagoCanon pc
        JOIN Concesiones.Concesion con ON pc.idConcesion = con.idConcesion
        WHERE (@idParque IS NULL OR con.idParque = @idParque)
    )
    SELECT 
        p.nombre AS parque,
        tipo,
        YEAR(fecha) AS anio,
        MONTH(fecha) AS mes,
        SUM(monto) AS totalIngresos_ARS,
        CAST(SUM(monto) / @CotizacionDolar AS DECIMAL(18,2)) AS totalIngresos_USD
    FROM IngresosBase ib
    JOIN Parques.Parque p ON ib.idParque = p.idParque
    WHERE (@anio IS NULL OR YEAR(fecha) = @anio)
      AND (@tipo IS NULL OR tipo = @tipo)
    GROUP BY p.nombre, tipo, YEAR(fecha), MONTH(fecha)
    ORDER BY parque, anio, mes, tipo;

    -- ========================================================================
    -- CONSOLIDADO GERENCIAL ANUAL
    -- ========================================================================
    PRINT CHAR(10) + 'Generando ResultSet 2: Consolidado Anual Estructural...';

    WITH IngresosBase AS (
        SELECT e.idParque, dv.fechaAcceso AS fecha, dv.total AS monto, 'Entrada' AS tipo
        FROM Ventas.DetalleVenta dv
        JOIN Ventas.Entrada e ON dv.idEntrada = e.idEntrada
        WHERE (@idParque IS NULL OR e.idParque = @idParque)

        UNION ALL

        SELECT at.idParque, CAST(dc.fechaHora AS DATE) AS fecha, dc.costoTotal AS monto, 'Tour' AS tipo
        FROM Actividades.DetalleContratacion dc
        JOIN Actividades.Contratacion c ON c.idDetalleContratacion = dc.idDetalleContratacion
        JOIN Actividades.ActividadProgramada ap ON c.idActividadProgramada = ap.idActividadProgramada
        JOIN Actividades.ActividadTuristica at ON ap.idActividadTuristica = at.idActividadTuristica
        WHERE (@idParque IS NULL OR at.idParque = @idParque)

        UNION ALL

        SELECT con.idParque, pc.fechaPago, pc.monto, 'Canon' AS tipo
        FROM Concesiones.PagoCanon pc
        JOIN Concesiones.Concesion con ON pc.idConcesion = con.idConcesion
        WHERE (@idParque IS NULL OR con.idParque = @idParque)
    )
    SELECT 
        p.nombre AS parque,
        YEAR(fecha) AS anio,
        SUM(CASE WHEN tipo = 'Entrada' THEN monto ELSE 0.00 END) AS totalEntradas_ARS,
        SUM(CASE WHEN tipo = 'Tour' THEN monto ELSE 0.00 END) AS totalTours_ARS,
        SUM(CASE WHEN tipo = 'Canon' THEN monto ELSE 0.00 END) AS totalCanones_ARS,
        SUM(monto) AS totalGeneral_ARS,

        CAST(SUM(CASE WHEN tipo = 'Entrada' THEN monto ELSE 0.00 END) / @CotizacionDolar AS DECIMAL(18,2)) AS totalEntradas_USD,
        CAST(SUM(CASE WHEN tipo = 'Tour' THEN monto ELSE 0.00 END) / @CotizacionDolar AS DECIMAL(18,2)) AS totalTours_USD,
        CAST(SUM(CASE WHEN tipo = 'Canon' THEN monto ELSE 0.00 END) / @CotizacionDolar AS DECIMAL(18,2)) AS totalCanones_USD,
        CAST(SUM(monto) AS DECIMAL(18,2)) AS totalGeneral_USD,
        @CotizacionDolar AS tipoCambioAplicado
    FROM IngresosBase ib
    JOIN Parques.Parque p ON ib.idParque = p.idParque
    WHERE (@anio IS NULL OR YEAR(fecha) = @anio)
      AND (@tipo IS NULL OR tipo = @tipo)
    GROUP BY p.nombre, YEAR(fecha)
    ORDER BY parque, anio;

END;
GO