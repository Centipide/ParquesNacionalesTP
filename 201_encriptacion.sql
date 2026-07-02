-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Creacion de sps para cifrar datos sensibles
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================


-- ============================================================
-- PASO 1: Agregar columnas cifradas (VARBINARY) sin tocar
--         las originales, para no romper el sistema existente.
--
--         Las columnas originales se conservarán durante la migración y 
--         podrán eliminarse una vez validado el proceso.
-- ============================================================

--++++++++++++++++++++++++ Visitante ++++++++++++++++++++++++

USE Com5600G05_ParquesNacionales;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Ventas.Visitante')
      AND name = 'emailCifrado'
)
    ALTER TABLE Ventas.Visitante ADD emailCifrado    VARBINARY(256) NULL;
GO


IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Ventas.Visitante')
      AND name = 'telefonoCifrado'
)
    ALTER TABLE Ventas.Visitante ADD telefonoCifrado VARBINARY(256) NULL;
GO

-- ++++++++++++++++++++++++ Guia ++++++++++++++++++++++++

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Guias.Guia')
      AND name = 'emailCifrado'
)
    ALTER TABLE Guias.Guia ADD emailCifrado       VARBINARY(512) NULL;
GO
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Guias.Guia')
      AND name = 'nroDocumentoCifrado'
)
    ALTER TABLE Guias.Guia ADD nroDocumentoCifrado VARBINARY(256) NULL;
GO

-- +++++++++++++++++++++++++ Guardaparque ++++++++++++++++++++

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Personal.Guardaparque')
      AND name = 'emailCifrado'
)
    ALTER TABLE Personal.Guardaparque ADD emailCifrado       VARBINARY(512) NULL;
GO
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Personal.Guardaparque')
      AND name = 'nroDocumentoCifrado'
)
    ALTER TABLE Personal.Guardaparque ADD nroDocumentoCifrado VARBINARY(256) NULL;
GO


-- ============================================================
-- PASO 2: SP de utilidad interna para cifrar una tabla.
--         La frase clave se recibe como parámetro (la capa
--         de aplicación la provee; no se persiste en la DB).
-- ============================================================

-- -------------------------------------------------------
-- SP_CifrarVisitantes
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Importacion.sp_CifrarVisitantes
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Ventas.Visitante
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, idVisitante)),
        telefonoCifrado = EncryptByPassPhrase(@FraseClave, telefono, 1, CONVERT(VARBINARY, idVisitante));

    PRINT CONCAT('Visitantes cifrados: ', @@ROWCOUNT);
END;
GO

-- -------------------------------------------------------
-- sp_CifrarGuias
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Importacion.sp_CifrarGuias
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Guias.Guia
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, idGuia)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, nroDocumento, 1, CONVERT(VARBINARY, idGuia));

    PRINT CONCAT('Guías cifrados: ', @@ROWCOUNT);
END;
GO

-- -------------------------------------------------------
-- SP_CifrarGuardaparques
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Importacion.sp_CifrarGuardaparques
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Personal.Guardaparque
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, idGuardaparque)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, nroDocumento, 1, CONVERT(VARBINARY, idGuardaparque));

    PRINT CONCAT('Guardaparques cifrados: ', @@ROWCOUNT);
END;
GO


-- ============================================================
-- PASO 3: SP de descifrado (solo para roles autorizados).
--         Retorna los datos sensibles de un registro puntual.
--         Sirve para testar el descifrado.
-- ============================================================

-- -------------------------------------------------------
-- SP_DescifrarVisitante
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Reportes.sp_DescifrarVisitante
    @idVisitante INT,
    @FraseClave  NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
    BEGIN
        RAISERROR('El visitante indicado no existe.', 16, 1);
        RETURN;
    END

    SELECT idVisitante, nombre, apellido,
        CONVERT(
            NVARCHAR(150),
            DecryptByPassPhrase(@FraseClave, emailCifrado, 1, CONVERT(VARBINARY, idVisitante))
        ) AS email,
        CONVERT(
            NVARCHAR(20),
            DecryptByPassPhrase(@FraseClave, telefonoCifrado, 1, CONVERT(VARBINARY, idVisitante))
        ) AS telefono
    FROM Ventas.Visitante
    WHERE idVisitante = @idVisitante;
END;
GO

-- -------------------------------------------------------
-- SP_DescifrarGuia
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Reportes.sp_DescifrarGuia
    @idGuia     INT,
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia WHERE idGuia = @idGuia)
    BEGIN
        RAISERROR('El guía indicado no existe.', 16, 1);
        RETURN;
    END

    SELECT idGuia, nombre, apellido, tipoDocumento,
        CONVERT(NVARCHAR(20),
            DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuia))
        ) AS nroDocumento,
        CONVERT(NVARCHAR(150),
            DecryptByPassPhrase(@FraseClave, emailCifrado, 1, CONVERT(VARBINARY, idGuia))
        ) AS email
    FROM Guias.Guia
    WHERE idGuia = @idGuia;
END;
GO

-- -------------------------------------------------------
-- SP_DescifrarGuardaparque
-- -------------------------------------------------------

CREATE OR ALTER PROCEDURE Reportes.sp_DescifrarGuardaparque
    @idGuardaparque INT,
    @FraseClave     NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Personal.Guardaparque WHERE idGuardaparque = @idGuardaparque)
    BEGIN
        RAISERROR('El guardaparque indicado no existe.', 16, 1);
        RETURN;
    END

    SELECT idGuardaparque, nombre, apellido, tipoDocumento,
        CONVERT(NVARCHAR(20),
            DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuardaparque))
        ) AS nroDocumento,
        CONVERT(NVARCHAR(150),
            DecryptByPassPhrase(@FraseClave, emailCifrado, 1, CONVERT(VARBINARY, idGuardaparque))
        ) AS email
    FROM Personal.Guardaparque
    WHERE idGuardaparque = @idGuardaparque;
END;
GO
