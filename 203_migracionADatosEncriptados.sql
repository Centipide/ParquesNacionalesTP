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

USE Com5600G05_ParquesNacionales
GO

SELECT * FROM Guias.Guia

EXEC Importacion.sp_CifrarVisitantes @FraseClave = 'claveVisitantes';
EXEC Importacion.sp_CifrarGuias @FraseClave = 'ClavesGuias';
EXEC Importacion.sp_CifrarGuardaparques @FraseClave = 'ClaveGuardaparques';
GO

-- ============================================================
-- PASO 4.1 IMPORTANTE 
--     Adaptar las tablas para eliminar los datos sensibles
--     almacenados en texto plano.
--     Ejecutar antes del Paso 4.2.
-- ============================================================

ALTER TABLE Personal.Guardaparque
DROP CONSTRAINT UQ_Guardaparque_Documento;

ALTER TABLE Personal.Guardaparque
DROP CONSTRAINT UQ_Guardaparque_Email;

ALTER TABLE Personal.Guardaparque
ALTER COLUMN nroDocumento VARCHAR(20) NULL;

ALTER TABLE Personal.Guardaparque
ALTER COLUMN email VARCHAR(150) NULL;

ALTER TABLE Guias.Guia
DROP CONSTRAINT UQ_Guia_Documento;

ALTER TABLE Guias.Guia
DROP CONSTRAINT UQ_Guia_Email;

ALTER TABLE Guias.Guia
ALTER COLUMN nroDocumento VARCHAR(20) NULL;

ALTER TABLE Guias.Guia
ALTER COLUMN email VARCHAR(150) NULL;

-- ============================================================
-- PASO 4.2 (IMPORTANTE - ejecutar solo cuando se confirme el cifrado):
--         Limpiar las columnas en texto plano.
-- 
-- !!ADVERTENCIA!!
-- Antes de ejecutar este paso verificar que:
--   1. El cifrado y descifrado funcionan correctamente.
--   2. Se dispone de un respaldo de la base de datos.
--   3. La frase clave fue almacenada de forma segura.

-- ============================================================

/*

UPDATE Ventas.Visitante      SET email = NULL, telefono = NULL;
UPDATE Guias.Guia            SET email = NULL, nroDocumento = NULL;
UPDATE Personal.Guardaparque SET email = NULL, nroDocumento = NULL;

SELECT * FROM Guias.Guia

*/

-- ============================================================
-- PASO 4.3 Borrar las columnas en texto plano
--
-- !!ADVERTENCIA!!
-- Antes de ejecutar este paso:
--  1. ejecutar el 4.2
--  2. Verificar que la aplicación ya utiliza exclusivamente las columnas cifradas.
-- ============================================================

/*
ALTER TABLE Ventas.Visitante
DROP COLUMN email, telefono;

ALTER TABLE Guias.Guia
DROP COLUMN email, nroDocumento;

ALTER TABLE Personal.Guardaparque
DROP COLUMN email, nroDocumento;
*/


SELECT * FROM Guias.Guia
