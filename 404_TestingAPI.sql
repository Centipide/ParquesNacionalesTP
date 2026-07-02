-- ============================================================
-- Fecha: 2025-07-02
-- Descripción: Testing de las SP para las APIs
-- 
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
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

EXEC Apis.sp_ImportarDolarOficial
SELECT * FROM Apis.CotizacionDolar

EXEC Reportes.sp_IngresosPorPeriodo

-- ============================================================
-- API para importar feriados
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

EXEC Apis.sp_ImportarFeriados
SELECT * FROM Apis.Feriados

EXEC Reportes.sp_VisitasEnFeriados