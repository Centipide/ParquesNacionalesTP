-- ============================================================
-- Fecha: 2025-06-19
-- Descripción: Reporte de visitas por semana, mes y año,
-- por parque
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE Com5600G05_ParquesNacionales
GO

-- ========================================================================
-- 1. REPORTE DE VISITAS POR SEMANA, MES Y AÑO, POR PARQUE
-- ========================================================================
-- Se calcula sobre Ventas.DetalleVenta (cantidad de entradas vendidas),
-- agrupando por las distintas granularidades de fechaAcceso.

CREATE OR ALTER PROCEDURE Reportes.sp_VisitasPorPeriodo
    @idParque INT = NULL,
    @anio     INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	-- Visitas por semana

	SELECT 
		p.idParque,
		p.nombre						AS parque,
		YEAR(dv.fechaAcceso)			AS anio,
		DATEPART(WEEK, dv.fechaAcceso)	AS semana,
		SUM(dv.cantidad)				AS totalVisitas
	FROM Ventas.DetalleVenta dv
	JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
	JOIN Parques.Parque p ON p.idParque = e.idParque
	WHERE (@idParque IS NULL OR e.idParque = @idParque)
  		AND (@anio IS NULL OR YEAR(dv.fechaAcceso) = @anio)
	GROUP BY p.idParque, p.nombre, YEAR(dv.fechaAcceso), DATEPART(WEEK, dv.fechaAcceso)
	ORDER BY p.nombre, anio, semana;


	-- Visitas por mes
	
	SELECT 
		p.idParque,
		p.nombre				AS parque,
		YEAR(dv.fechaAcceso)	AS anio,
		MONTH(dv.fechaAcceso)	AS mes,
		SUM(dv.cantidad)		AS totalVisitas
	FROM Ventas.DetalleVenta dv
	JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
	JOIN Parques.Parque p ON p.idParque = e.idParque
	WHERE (@idParque IS NULL OR e.idParque = @idParque)
  		AND (@anio     IS NULL OR YEAR(dv.fechaAcceso) = @anio)
	GROUP BY p.idParque, p.nombre, YEAR(dv.fechaAcceso), MONTH(dv.fechaAcceso)
	ORDER BY p.nombre, anio, mes;

	-- Visitas por año

	SELECT 
		p.idParque,
		p.nombre				AS parque,
		YEAR(dv.fechaAcceso)	AS anio,
		SUM(dv.cantidad)		AS totalVisitas
	FROM Ventas.DetalleVenta dv
	JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
	JOIN Parques.Parque p ON p.idParque = e.idParque
	WHERE (@idParque IS NULL OR e.idParque = @idParque)
  		AND (@anio     IS NULL OR YEAR(dv.fechaAcceso) = @anio)
	GROUP BY p.idParque, p.nombre, YEAR(dv.fechaAcceso)
	ORDER BY p.nombre, anio;

	-- Visitas históricas por parque

	SELECT 
        p.idParque,
        p.nombre                AS parque,
        SUM(dv.cantidad)        AS totalVisitasHistoricas
    FROM Ventas.DetalleVenta dv
    JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
    JOIN Parques.Parque p ON p.idParque = e.idParque
    WHERE (@idParque IS NULL OR e.idParque = @idParque)
        AND (@anio IS NULL OR YEAR(dv.fechaAcceso) = @anio)
    GROUP BY p.idParque, p.nombre
    ORDER BY totalVisitasHistoricas DESC, p.nombre;
END
GO

-- ============================================================
-- TESTING
-- ============================================================

-- ESCENARIO A: Traer todo el historial completo de todos los parques
-- (Ideal para ver el comportamiento global del sistema)
EXEC Reportes.sp_VisitasPorPeriodo;


-- ESCENARIO B: Filtrar la estadística únicamente para el año en curso
-- (Muestra semanas, meses y totales del 2026)
EXEC Reportes.sp_VisitasPorPeriodo 
    @idParque = NULL, 
    @anio = 2026;


-- ESCENARIO C: Filtrar de forma cruzada por Parque específico y Año
-- (Muestra semanas, meses y totales de un parque existente)
DECLARE @idParquePrueba INT;
SELECT TOP 1 @idParquePrueba = idParque 
FROM Parques.Parque 
ORDER BY idParque;

EXEC Reportes.sp_VisitasPorPeriodo @idParque = @idParquePrueba, @anio = NULL;


-- ESCENARIO D: Caso sin datos (Filtros que no machean con nada)
-- (Debe retornar las 4 estructuras de tablas completamente vacías, sin fallar)
EXEC Reportes.sp_VisitasPorPeriodo 
    @idParque = -1, 
    @anio = 1900;
