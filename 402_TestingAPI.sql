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
EXEC Apis.sp_ImportarDolarOficial

SELECT * FROM Apis.CotizacionDolar