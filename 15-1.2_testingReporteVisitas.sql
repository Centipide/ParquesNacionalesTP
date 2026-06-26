-- ============================================================
-- Fecha: 2025-06-19
-- Descripción: Script de prueba para el procedimiento de Reportes Visitas Por Periodo
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
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
