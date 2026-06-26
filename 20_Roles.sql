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
-- SECCIÓN 1: LIMPIEZA PREVENTIVA
-- ============================================================


-- Limpiar logins/usuarios de prueba si ya existían

-- ============================================================
-- LIMPIEZA DE USUARIOS
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    DROP USER usr_admin;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_boleteria')
    DROP USER usr_boleteria;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_guias')
    DROP USER usr_guias;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_importador')
    DROP USER usr_importador;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_reportes')
    DROP USER usr_reportes;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_auditor')
    DROP USER usr_auditor;
GO

-- ============================================================
-- LIMPIEZA DE ROLES
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Administrador')
    DROP ROLE rol_Administrador;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Boleteria')
    DROP ROLE rol_Boleteria;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_GestionGuias')
    DROP ROLE rol_GestionGuias;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Importador')
    DROP ROLE rol_Importador;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Reportes')
    DROP ROLE rol_Reportes;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_Auditor')
    DROP ROLE rol_Auditor;
GO

-- ============================================================
-- LIMPIEZA DE LOGINS
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin')
    DROP LOGIN login_admin;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_boleteria')
    DROP LOGIN login_boleteria;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_guias')
    DROP LOGIN login_guias;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_importador')
    DROP LOGIN login_importador;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_reportes')
    DROP LOGIN login_reportes;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_auditor')
    DROP LOGIN login_auditor;
GO


-- ============================================================
-- SECCIÓN 2: CREACIÓN DE ROLES
-- ============================================================

CREATE ROLE rol_Administrador;
CREATE ROLE rol_Boleteria;
CREATE ROLE rol_GestionGuias;
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
-- Puede dar de alta visitantes y consultar precios.                    !!!!!!!!!!(FALTA ESTO)
-- NO puede modificar precios ni anular ventas.
-- ============================================================

GRANT EXECUTE ON Ventas.sp_AltaVisitante              TO rol_Boleteria;
GRANT EXECUTE ON Ventas.sp_RegistrarVentaEntradas     TO rol_Boleteria;
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
-- 3.4  rol_Importador
-- Exclusivamente: ejecutar los SPs de importación masiva.
-- No puede leer ni escribir datos de otra forma.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Importacion TO rol_Importador;
GO


-- ============================================================
-- 3.5  rol_Reportes
-- Solo ejecutar SPs de reportes.
-- No puede modificar ningún dato.
-- ============================================================

GRANT EXECUTE ON SCHEMA::Reportes TO rol_Reportes;
GO

-- ============================================================
-- 3.6  rol_Auditor
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
-- SECCIÓN 4: CREACIÓN DE LOGINS Y USUARIOS DE EJEMPLO
-- Un login por rol para demostración. En producción cada
-- persona tendría su propio login asignado al rol que le
-- corresponda según su función.
-- ============================================================

-- Logins a nivel servidor
CREATE LOGIN login_admin      WITH PASSWORD = 'Admin#2026!';
CREATE LOGIN login_boleteria  WITH PASSWORD = 'Bolet3r!a26';
CREATE LOGIN login_guias      WITH PASSWORD = 'Gu14s#2026!';
CREATE LOGIN login_importador WITH PASSWORD = 'Imp0rt#2026';
CREATE LOGIN login_reportes   WITH PASSWORD = 'Rep0rt3s#26';
CREATE LOGIN login_auditor    WITH PASSWORD = 'Aud1t0r#26!';
GO

-- Usuarios en la base ParquesNacionales
CREATE USER usr_admin      FOR LOGIN login_admin;
CREATE USER usr_boleteria  FOR LOGIN login_boleteria;
CREATE USER usr_guias      FOR LOGIN login_guias;
CREATE USER usr_importador FOR LOGIN login_importador;
CREATE USER usr_reportes   FOR LOGIN login_reportes;
CREATE USER usr_auditor    FOR LOGIN login_auditor;
GO

-- Asignación de roles
ALTER ROLE rol_Administrador  ADD MEMBER usr_admin;
ALTER ROLE rol_Boleteria      ADD MEMBER usr_boleteria;
ALTER ROLE rol_GestionGuias   ADD MEMBER usr_guias;
ALTER ROLE rol_Importador     ADD MEMBER usr_importador;
ALTER ROLE rol_Reportes       ADD MEMBER usr_reportes;
ALTER ROLE rol_Auditor        ADD MEMBER usr_auditor;
GO


-- ============================================================
-- SECCIÓN 5: VERIFICACIÓN
-- Consultas para confirmar que los permisos quedaron bien.
-- ============================================================

-- Ver todos los roles creados
SELECT name AS rol, type_desc
FROM sys.database_principals
WHERE type = 'R'
  AND name LIKE 'rol_%'
ORDER BY name;

-- Ver qué usuarios pertenecen a cada rol
SELECT
    dr.name  AS rol,
    dp.name  AS usuario
FROM sys.database_role_members drm
JOIN sys.database_principals dr ON drm.role_principal_id   = dr.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE dr.name LIKE 'rol_%'
ORDER BY dr.name, dp.name;

-- Ver permisos EXECUTE asignados a cada rol
SELECT
    dp.name AS Rol,
    p.permission_name,
    p.class_desc,
    CASE
        WHEN p.class_desc = 'SCHEMA'
            THEN SCHEMA_NAME(p.major_id)
        WHEN p.class_desc = 'OBJECT_OR_COLUMN'
            THEN OBJECT_NAME(p.major_id)
        ELSE NULL
    END AS Objeto
FROM sys.database_permissions p
JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
WHERE dp.name LIKE 'rol_%'
ORDER BY dp.name;