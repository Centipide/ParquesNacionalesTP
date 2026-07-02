-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Actualizar ABMs con datos encriptados
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

-- TABLA Visitante
USE Com5600G05_ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Ventas.sp_AltaVisitante
    @nombre    VARCHAR(50),
    @apellido  VARCHAR(50),
    @email     VARCHAR(100) = NULL,
    @direccion VARCHAR(100) = NULL,
    @telefono  VARCHAR(20) = NULL,
    @FraseClave NVARCHAR(128) = 'claveVisitantes'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(1000) = '';
    DECLARE @idVisitante INT;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre del visitante es obligatorio y no puede quedar vacío.' + CHAR(10);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores += '- El apellido del visitante es obligatorio y no puede quedar vacío.' + CHAR(10);

    IF @email IS NOT NULL AND LTRIM(RTRIM(@email)) <> '' AND @email NOT LIKE '%_@__%.__%'
        SET @errores += '- El formato del correo electrónico ingresado no es válido.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    -- 1. INSERT sin datos sensibles en claro
    INSERT INTO Ventas.Visitante (nombre, apellido, direccion)
    VALUES (
        LTRIM(RTRIM(@nombre)),
        LTRIM(RTRIM(@apellido)),
        NULLIF(LTRIM(RTRIM(@direccion)), '')
    );

    SET @idVisitante = SCOPE_IDENTITY();

    -- 2. Guardar SOLO cifrado
    UPDATE Ventas.Visitante
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idVisitante)),
        telefonoCifrado = EncryptByPassPhrase(@FraseClave, @telefono, 1, CONVERT(VARBINARY, @idVisitante))
    WHERE idVisitante = @idVisitante;

END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionVisitante
    @idVisitante INT,
    @nombre      VARCHAR(50),
    @apellido    VARCHAR(50),
    @email       VARCHAR(100) = NULL,
    @direccion   VARCHAR(100) = NULL,
    @telefono    VARCHAR(20) = NULL,
    @FraseClave  NVARCHAR(128) = 'claveVisitantes'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
        SET @errores += '- El ID de visitante especificado no existe en el padrón central.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre del visitante es requerido y no puede ser nulo.' + CHAR(10);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores += '- El apellido del visitante es requerido y no puede ser nulo.' + CHAR(10);

    IF @email IS NOT NULL AND LTRIM(RTRIM(@email)) <> '' AND @email NOT LIKE '%_@__%.__%'
        SET @errores += '- El formato del correo electrónico ingresado no es válido.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Ventas.Visitante
    SET nombre = LTRIM(RTRIM(@nombre)),
        apellido = LTRIM(RTRIM(@apellido)),
        direccion = NULLIF(LTRIM(RTRIM(@direccion)), ''),
        emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idVisitante)),
        telefonoCifrado = EncryptByPassPhrase(@FraseClave, @telefono, 1, CONVERT(VARBINARY, @idVisitante))
    WHERE idVisitante = @idVisitante;
END;
GO


-- ==========================================================
-- TABLA Guardaparque
-- ==========================================================

CREATE OR ALTER PROCEDURE Personal.sp_AltaGuardaparque
    @nombre             VARCHAR(50),
    @apellido           VARCHAR(50),
    @fechaNacimiento    DATE,
    @tipoDocumento      VARCHAR(20),
    @nroDocumento       VARCHAR(20),
    @email              VARCHAR(150),
    @fechaIngresoCargo  DATE,
    @FraseClave         NVARCHAR(125) = 'ClaveGuardaparques'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(1000) = '';
    DECLARE @idGuardaparque INT;

    IF ISNULL(@nombre, '') = ''
        SET @errores += '- Nombre no ingresado.' + CHAR(10);

    IF ISNULL(@apellido, '') = ''
        SET @errores += '- Apellido no ingresado.' + CHAR(10);

    IF @fechaNacimiento IS NULL
        SET @errores += '- Fecha de nacimiento no ingresada.' + CHAR(10);

    IF @fechaIngresoCargo > CAST(GETDATE() AS DATE)
        SET @errores += '- Fecha invalida.' + CHAR(10);

    IF @email IS NOT NULL
       AND LTRIM(RTRIM(@email)) <> ''
       AND @email NOT LIKE '%_@__%.__%'
        SET @errores += '- El formato del correo electrónico ingresado no es válido.' + CHAR(10);


    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE tipoDocumento = @tipoDocumento
            AND CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuardaparque))) = @nroDocumento
    )
        SET @errores += '- Tipo y Nro de documento ya existen.' + CHAR(10)


    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Personal.Guardaparque
    (nombre, apellido, fechaNacimiento, tipoDocumento, fechaIngresoCargo, estaActivo)
    VALUES
    (@nombre, @apellido, @fechaNacimiento, @tipoDocumento, @fechaIngresoCargo, 1);

    SET @idGuardaparque = SCOPE_IDENTITY();

    UPDATE Personal.Guardaparque
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idGuardaparque)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, @nroDocumento, 1, CONVERT(VARBINARY, @idGuardaparque))
    WHERE idGuardaparque = @idGuardaparque;
    
END;
GO

CREATE OR ALTER PROCEDURE Personal.sp_ModificacionGuardaparque
    @idGuardaparque     INT,
    @nombre             VARCHAR(50),
    @apellido           VARCHAR(50),
    @fechaNacimiento    DATE,
    @tipoDocumento      VARCHAR(20),
    @nroDocumento       VARCHAR(20),
    @email              VARCHAR(150),
    @fechaIngresoCargo  DATE,
    @fechaEgresoCargo   DATE,
    @motivoEgreso       VARCHAR(300),
    @estaActivo         BIT,
    @FraseClave         NVARCHAR(125) = 'ClaveGuardaparques'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Personal.Guardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
        SET @errores += '- Id de guardaparques no existe.' + CHAR(10);

    IF @fechaEgresoCargo IS NOT NULL
       AND @fechaEgresoCargo < @fechaIngresoCargo
        SET @errores += '- Fecha de egreso no puede ser menor a ingreso.' + CHAR(10);

    IF @email IS NOT NULL
       AND LTRIM(RTRIM(@email)) <> ''
       AND @email NOT LIKE '%_@__%.__%'
        SET @errores += '- El formato del correo electrónico ingresado no es válido.' + CHAR(10);

    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE tipoDocumento = @tipoDocumento
        AND CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuardaparque))) = @nroDocumento
        AND idGuardaparque != @idGuardaparque
    )
        SET @errores += '- Documento ya existente' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Personal.Guardaparque
    SET nombre = @nombre,
        apellido = @apellido,
        fechaNacimiento = @fechaNacimiento,
        tipoDocumento = @tipoDocumento,
        fechaIngresoCargo = @fechaIngresoCargo,
        fechaEgresoCargo = @fechaEgresoCargo,
        motivoEgreso = @motivoEgreso,
        estaActivo = @estaActivo,
        emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idGuardaparque)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, @nroDocumento, 1, CONVERT(VARBINARY, @idGuardaparque))
    WHERE idGuardaparque = @idGuardaparque;
END;
GO

-- ==========================================================
-- TABLA Guia
-- ==========================================================

CREATE OR ALTER PROCEDURE Guias.sp_AltaGuia
    @nombre               VARCHAR(50),
    @apellido             VARCHAR(50),
    @fechaNacimiento      DATE,
    @tipoDocumento        VARCHAR(20),
    @nroDocumento         VARCHAR(20),
    @email                VARCHAR(150),
    @vigenciaAutorizacion DATE,
    @FraseClave           NVARCHAR(125) = 'ClavesGuias'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(500) = '';
    DECLARE @idGuia INT;

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre no puede estar vacio.' + CHAR(10);

    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores += 'El apellido no puede estar vacio.' + CHAR(10);

    IF @fechaNacimiento IS NULL
        SET @errores += 'Fecha de nacimiento no ingresada.' + CHAR(10);

    IF EXISTS (
        SELECT 1 FROM Guias.Guia
        WHERE tipoDocumento = @tipoDocumento
            AND CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuia))) = @nroDocumento
    )
        SET @errores += '- Tipo y Nro de documento ya existen.' + CHAR(10)


    IF @email IS NOT NULL
       AND LTRIM(RTRIM(@email)) <> ''
       AND @email NOT LIKE '%_@__%.__%'
        SET @errores += 'El formato del correo electrónico ingresado no es válido.' + CHAR(10);

    IF @vigenciaAutorizacion IS NULL
        SET @errores += 'La vigencia de autorizacion es obligatoria.' + CHAR(10);

    IF @vigenciaAutorizacion IS NOT NULL
       AND @vigenciaAutorizacion < CAST(GETDATE() AS DATE)
        SET @errores += 'La vigencia de autorizacion no puede estar vencida.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    INSERT INTO Guias.Guia
    (nombre, apellido, fechaNacimiento, tipoDocumento, vigenciaAutorizacion, estaActivo)
    VALUES
    (@nombre, @apellido, @fechaNacimiento, @tipoDocumento, @vigenciaAutorizacion, 1);

    SET @idGuia = SCOPE_IDENTITY();

    UPDATE Guias.Guia
    SET emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idGuia)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, @nroDocumento, 1, CONVERT(VARBINARY, @idGuia))
    WHERE idGuia = @idGuia;
END;
GO

CREATE OR ALTER PROCEDURE Guias.sp_ModificacionGuia
    @idGuia               INT,
    @nombre               VARCHAR(50),
    @apellido             VARCHAR(50),
    @fechaNacimiento      DATE,
    @tipoDocumento        VARCHAR(20),
    @nroDocumento         VARCHAR(20),
    @email                VARCHAR(150),
    @vigenciaAutorizacion DATE,
    @FraseClave           NVARCHAR(125) = 'ClavesGuias'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (
        SELECT 1
        FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El id de guia ingresado no existe.' + CHAR(10);

     IF EXISTS (
        SELECT 1 FROM Guias.Guia
        WHERE tipoDocumento = @tipoDocumento
        AND CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY, idGuia))) = @nroDocumento
        AND idGuia != @idGuia
    )
        SET @errores += '- Documento ya existente' + CHAR(10)


    IF @email IS NOT NULL
       AND LTRIM(RTRIM(@email)) <> ''
       AND @email NOT LIKE '%_@__%.__%'
        SET @errores += 'El formato del correo electrónico ingresado no es válido.' + CHAR(10);

    IF @vigenciaAutorizacion IS NULL
        SET @errores += 'La vigencia de autorizacion es obligatoria.' + CHAR(10);

    IF @vigenciaAutorizacion IS NOT NULL
       AND @vigenciaAutorizacion < CAST(GETDATE() AS DATE)
        SET @errores += 'La vigencia de autorizacion no puede estar vencida.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    UPDATE Guias.Guia
    SET nombre = @nombre,
        apellido = @apellido,
        fechaNacimiento = @fechaNacimiento,
        tipoDocumento = @tipoDocumento,
        vigenciaAutorizacion = @vigenciaAutorizacion,
        emailCifrado = EncryptByPassPhrase(@FraseClave, @email, 1, CONVERT(VARBINARY, @idGuia)),
        nroDocumentoCifrado = EncryptByPassPhrase(@FraseClave, @nroDocumento, 1, CONVERT(VARBINARY, @idGuia))
    WHERE idGuia = @idGuia;
END;
GO
