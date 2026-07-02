-- ============================================================
-- Fecha: 2025-06-20
-- Descripción: Testing para la Importacion de Archivos.
--		Los lotes de prueba se encuentran en los archivos.
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

-- ============================================================
-- TESTING Parques y TiposParque
-- RUTA: C:\Datasets\af_ha007__rea_protegida_argentina_geojson_TEST.txt
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

EXEC Importacion.sp_ImportarParques

SELECT * FROM Parques.TipoParque
SELECT * FROM Parques.Parque


-- ============================================================
-- TESTING Visitas segun tipo visitante
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

EXEC Importacion.sp_ImportarVisitas

SELECT * FROM Importacion.VisitasCom5600G05_ParquesNacionales


-- ============================================================
-- TESTING Guias registrados
-- RUTA: C:\Datasets\registro-de-guias-de-turismo_TEST.csv
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

EXEC Importacion.sp_ImportarGuias

SELECT * FROM Guias.Guia
