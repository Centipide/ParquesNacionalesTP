-- ============================================================
-- TESTING Parques y TiposParque
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarParques

SELECT * FROM Parques.TipoParque
SELECT * FROM Parques.Parque


-- ============================================================
-- TESTING Visitas segun tipo visitante
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarVisitas

SELECT * FROM Importacion.VisitasParquesNacionales


-- ============================================================
-- TESTING Guias registrados
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarGuias

SELECT * FROM Guias.Guia