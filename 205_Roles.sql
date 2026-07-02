-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Creacion de roles de seguridad con permisos
--              
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

-- ============================================================
-- SECCION 1: LIMPIEZA DE ROLES
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Administrador')
    DROP ROLE rol_Administrador;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Boleteria')
    DROP ROLE rol_Boleteria;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_GestionGuias')
    DROP ROLE rol_GestionGuias;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Personal')
    DROP ROLE rol_Personal;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Importador')
    DROP ROLE rol_Importador;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Reportes')
    DROP ROLE rol_Reportes;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Auditor')
    DROP ROLE rol_Auditor;
GO


-- ============================================================
-- SECCIÓN 2: CREACIÓN DE ROLES
-- ============================================================

CREATE ROLE rol_Administrador;
CREATE ROLE rol_Boleteria;
CREATE ROLE rol_GestionGuias;
CREATE ROLE rol_Personal;
CREATE ROLE rol_Importador;
CREATE ROLE rol_Reportes;
CREATE ROLE rol_Auditor;
GO


-- ============================================================
-- SECCIÓN 3: ASIGNACIÓN DE PERMISOS POR ROL
-- ============================================================

-- ============================================================
-- 3.1  rol_Administrador
-- Acceso total: todos los SPs de todos los esquemas.
-- Acceso completo a todos los procedimientos y consultas de la aplicación
-- ============================================================

GRANT EXECUTE TO rol_Administrador;
GRANT SELECT TO rol_Administrador;

-- ============================================================
-- 3.2  rol_Boleteria
-- Venta de entradas y contratación de actividades.
-- Puede dar de alta visitantes y consultar precios. 
-- NO puede modificar precios ni anular ventas.
-- ============================================================

GRANT EXECUTE ON Ventas.sp_AltaVisitante              TO rol_Boleteria;
GRANT EXECUTE ON Ventas.sp_RegistrarVentaEntradas     TO rol_Boleteria;
GRANT SELECT ON Ventas.Entrada                        TO rol_Boleteria;
GRANT SELECT ON Ventas.TipoVisitante                  TO rol_Boleteria;
GRANT SELECT ON Parques.Parque                        TO rol_Boleteria;
GO


-- ============================================================
-- 3.3  rol_GestionGuias
-- ABM de guías y habilitaciones. Asignación a actividades.
-- Registro de actividades realizadas y cancelaciones.
-- NO tiene acceso a ventas ni concesiones.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Guias                              TO rol_GestionGuias;
GRANT EXECUTE ON Actividades.sp_AltaActividadRealizada      TO rol_GestionGuias;
GRANT EXECUTE ON Actividades.sp_CancelarActividadProgramada TO rol_GestionGuias;
GRANT EXECUTE ON Actividades.sp_CancelarContratacion        TO rol_GestionGuias;
GO

-- ============================================================
-- 3.4  rol_Personal
-- ABM de guardaparques e historial de cargos.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Personal TO rol_Personal;

-- ============================================================
-- 3.5  rol_Importador
-- Exclusivamente: ejecutar los SPs de importación masiva.
-- No puede leer ni escribir datos de otra forma.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Importacion TO rol_Importador;
GO


-- ============================================================
-- 3.6  rol_Reportes
-- Solo ejecutar SPs de reportes.
-- No puede modificar ningún dato.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Reportes TO rol_Reportes;
GO

-- ============================================================
-- 3.7  rol_Auditor
-- SELECT directo sobre tablas para auditoría.
-- Ve los datos tal como están almacenados:
-- columnas cifradas aparecen como VARBINARY (ilegibles).
-- No puede ejecutar ningún SP de escritura.
-- No puede descifrar datos personales.
-- ============================================================

GRANT SELECT ON SCHEMA::Parques       TO rol_Auditor;
GRANT SELECT ON SCHEMA::Personal      TO rol_Auditor;
GRANT SELECT ON SCHEMA::Guias         TO rol_Auditor;
GRANT SELECT ON SCHEMA::Actividades   TO rol_Auditor;
GRANT SELECT ON SCHEMA::Concesiones   TO rol_Auditor;
GRANT SELECT ON SCHEMA::Ventas        TO rol_Auditor;
GRANT SELECT ON SCHEMA::Importacion   TO rol_Auditor;

-- ============================================================
-- SECCIÓN 4: VERIFICACION DE ROLES
-- ============================================================

-- Consulta para verificar los roles creados

SELECT name AS Nombre_Rol 
FROM sys.database_principals 
WHERE type = 'R' 
ORDER BY name;
