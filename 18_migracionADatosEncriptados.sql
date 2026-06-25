-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Migración - Ejecucion de sps para cifrar 
--              datos sensibles
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_CifrarVisitantes @FraseClave = 'claveVisitantes';
EXEC Importacion.sp_CifrarGuias @FraseClave = 'ClavesGuias';
EXEC Importacion.sp_CifrarGuardaparques @FraseClave = 'ClaveGuardaparques';
GO