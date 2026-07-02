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
USE ParquesNacionales
GO

EXEC Apis.sp_ImportarDolarOficial

SELECT * FROM Apis.CotizacionDolar


-- ============================================================
-- API para importar feriados
-- ============================================================
USE ParquesNacionales
GO

EXEC Apis.sp_ImportarFeriados

SELECT * FROM Apis.Feriados