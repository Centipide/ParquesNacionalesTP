-- ============================================================
-- Fecha: 2025-06-12
-- Descripción: Creación de la base de datos ParquesNacionales
--              y los esquemas de organización lógica.
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ParquesNacionales')
BEGIN
    PRINT 'La base de datos existe. Procediendo a eliminarla...';
    
    ALTER DATABASE ParquesNacionales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ParquesNacionales;
END
ELSE
BEGIN
    PRINT 'La base de datos no existía. Listo para crear desde cero.';
END
GO

CREATE DATABASE ParquesNacionales
    COLLATE Modern_Spanish_CI_AS;
GO

USE ParquesNacionales;
GO

-- Esquemas ---
CREATE SCHEMA Parques;          -- Entidades centrales del parque
GO
CREATE SCHEMA Guias;            -- Guías, habilitaciones y títulos
GO
CREATE SCHEMA Actividades;      -- Actividades turísticas
GO
CREATE SCHEMA Concesiones;      -- Empresas concesionarias y contratos
GO
CREATE SCHEMA Ventas;           -- Entradas, visitantes y ventas
GO
CREATE SCHEMA Personal;         -- Guardaparques
GO
CREATE SCHEMA Importacion       -- SP de migración + cifrado masivo
GO
CREATE SCHEMA Reportes          -- SP de consultas + descifrado
GO