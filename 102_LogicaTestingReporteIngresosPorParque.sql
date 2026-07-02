-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Reporte de ingresos por semana, mes y año, por parque
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE Com5600G05_ParquesNacionales;
GO

CREATE OR ALTER PROCEDURE Reportes.sp_IngresosPorPeriodo
    @idParque INT = NULL,
    @anio     INT = NULL,
    @tipo     VARCHAR(10) = NULL -- 'Entrada', 'Tour', 'Canon'
AS
BEGIN
    SET NOCOUNT ON;

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
        SUM(monto) AS totalIngresos
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
        SUM(CASE WHEN tipo = 'Entrada' THEN monto ELSE 0.00 END) AS totalEntradas,
        SUM(CASE WHEN tipo = 'Tour' THEN monto ELSE 0.00 END) AS totalTours,
        SUM(CASE WHEN tipo = 'Canon' THEN monto ELSE 0.00 END) AS totalCanones,
        SUM(monto) AS totalGeneral
    FROM IngresosBase ib
    JOIN Parques.Parque p ON ib.idParque = p.idParque
    WHERE (@anio IS NULL OR YEAR(fecha) = @anio)
      AND (@tipo IS NULL OR tipo = @tipo)
    GROUP BY p.nombre, YEAR(fecha)
    ORDER BY parque, anio;

END;
GO

-- ============================================================
-- TESTING
-- ============================================================


-- 1. Ver matriz completa del universo de datos
EXEC Reportes.sp_IngresosPorPeriodo;

-- 2. Aislar comportamiento del año actual (2026)
EXEC Reportes.sp_IngresosPorPeriodo @anio = 2026;

-- 3. Buscar un parque de forma segura sin IDs fijos
DECLARE @idParqueTest INT;
SELECT TOP 1 @idParqueTest = idParque FROM Parques.Parque ORDER BY NEWID();

EXEC Reportes.sp_IngresosPorPeriodo @idParque = @idParqueTest;

-- 4. Solo evaluar Cánones de Concesiones
EXEC Reportes.sp_IngresosPorPeriodo @tipo = 'Canon';

-- 5. Año histórico vacío (Debe dar grillas limpias sin explotar)
EXEC Reportes.sp_IngresosPorPeriodo @anio = 1945;

