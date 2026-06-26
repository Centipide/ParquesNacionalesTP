-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Script de prueba para el procedimiento de Reportes Ingresos Por Periodo
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

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

