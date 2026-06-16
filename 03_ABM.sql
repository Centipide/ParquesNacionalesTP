-- ============================================================
-- Fecha: 2025-06-12
-- Descripción: Creación de todos los SP para ABM de las tablas
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales
GO

-- ==========================================================
-- TABLA Parque
-- ==========================================================
CREATE OR ALTER PROCEDURE Parques.sp_AltaParque
    @idTipoParque INT,
    @nombre       VARCHAR(50),
    @localidad    VARCHAR(50),
    @provincia    VARCHAR(30),
    @superficie   DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS(
        SELECT 1 FROM Parques.TipoParque
        WHERE idTipoParque = @idTipoParque
    )
    SET @errores += '- El tipo de parque no existe.' + CHAR(10)

    IF ISNULL(@nombre,'') = ''
    SET @errores += '- Falta ingresar nombre.' + CHAR(10)

    IF ISNULL(@localidad,'') = ''
    SET @errores += '- Falta ingresar localidad.' + CHAR(10)

    IF ISNULL(@provincia,'') = ''
    SET @errores += '- Falta ingresar provincia.' + CHAR(10)

    IF @superficie <= 0
    SET @errores += '- Superficie ingresada no valida.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    INSERT INTO Parques.Parque
        (idTipoParque, nombre, localidad, provincia, superficie)
    VALUES
        (@idTipoParque, @nombre, @localidad, @provincia, @superficie)
    
    SELECT SCOPE_IDENTITY() AS idParqueNuevo
END
GO


CREATE OR ALTER sp_ModificacionParque
    @idParque     INT,
    @idTipoParque INT,
    @nombre       VARCHAR(50),
    @localidad    VARCHAR(50),
    @provincia    VARCHAR(30),
    @superficie   DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARHCAR(1000) = ''

    IF NOT EXISTS(
        SELECT 1 FROM Parques.Parque
        WHERE idParque = @idParque
    )
    SET @errores += '- El parque ingresado no existe.' + CHAR(10)

    IF NOT EXISTS(
        SELECT 1 FROM Parques.TipoParque
        WHERE idTipoParque = @idTipoParque
    )
    SET @errores += '- El tipo de parque ingresado no existe.' + CHAR(10)

    IF @superficie <= 0
    SET @errores += '- Superficie ingresada no valida.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    UPDATE Parques.Parque
    SET TipoParque = @TipoParque, nombre = @nombre, localidad = @localidad,
        provincia = @provincia, superficie = @superficie
    WHERE idParque = @idParque
END
GO


CREATE OR ALTER PROCEDURE sp_BajaParque
    @idParque INT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Parques.Parque
        WHERE idParque = @idParque
    )
    SET @errores += 'No existe el parque ingresado.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Actividades.ActividadTuristica
        WHERE idParque = @idParque
    )
    SET @errores += 'No se puede eliminar porque existen Actividades Turisticas en el parque.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idParque = @idParque
    )
    SET @errores += 'No se puede eliminar porque existen Historial de Guardaparque en el parque.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Concesiones.Concesion
        WHERE idParque = @idParque
    )
    SET @errores += 'No se puede eliminar porque existen Concesiones en el parque.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Ventas.Entrada
        WHERE idParque = @idParque
    )
    SET @errores += 'No se puede eliminar porque existen Entradas en el parque.' + CHAR(10)

    IF @errores <> ''
    BEGIN 
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    DELETE FROM Parques.Parque
    WHERE idParque = @idParque
END
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
    @fechaIngresoCargo  DATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    -- Validacion NOMBRE
    IF ISNULL (@nombre,'') = ''
    SET @errores += '- Nombre no ingresado.' + CHAR(10)

    -- Validacion APELLIDO
    IF ISNULL (@apellido,'') = ''
    SET @errores += '- Apellido no ingresado.' + CHAR(10)

    -- Validacion FECHA NACIMIENTO
    IF ISNULL (@fechaNacimiento,'') = ''
    SET @errores += '- Fecha de nacimiento no ingresada.' + CHAR(10)

    -- Validacion TIPO Y NRO DOCUMENTO
    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE tipoDocumento = @tipoDocumento AND nroDocumento = @nroDocumento
    )
    SET @errores += '- Tipo y Nro de documento ya existen.' + CHAR(10)

    -- Validacion EMAIL
    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE email = @email
    )
    SET @errores += '- Email ya registrado.' + CHAR(10)

    -- Validacion FECHA INGRESO
    IF EXISTS (@fechaIngresoCargo > CAST(GETDATE() AS DATE))
    SET @errores += '- Fecha invalida.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    INSERTO INTO Personal.Guardaparque
        (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, fechaIngresoCargo, estaActivo)
    VALUES
        (@nombre, @apellido, @fechaNacimiento, @tipoDocumento, @nroDocumento, @email, @fechaIngresoCargo, 1)

    SELECT SCOPE_IDENTITY() AS idGuardaparquesNuevo
END
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
    @estaActivo         BIT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
    SET @errores += '- Id de guardaparques no existe.' + CHAR(10)

    IF (@fechaEgresoCargo IS NOT NULL AND @fechaIngresoCargo < @fechaIngresoCargo)
    SET @errores += '- Fecha de egreso no puede ser menor a ingreso.' + CHAR(10)

    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE tipoDocumento = @tipoDocumento AND nroDocumento = @nroDocumento
    )
    SET @errores += '- Documento ya existente' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    UPDATE Personal.Guardaparque
    SET nombre = @nombre, apellido = @apellido, fechaNacimiento = @fechaNacimiento,
        tipoDocumento = @tipoDocumento, nroDocumento = @nroDocumento, email = @email,
        fechaIngresoCargo = @fechaIngresoCargo, fechaEgresoCargo = @fechaEgresoCargo,
        motivoEgreso = @motivoEgreso, estaActivo = @estaActivo
    WHERE idGuardaparque = @idGuardaparque
END
GO


CREATE OR ALTER PROCEDURE Personal.sp_BajaGuardaparque
    @idGuardaparque     INT,
    @motivoEgreso       VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(100) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
    SET @errores += '- Guardaparque no existe.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    UPDATE Personal.Guardaparque
    SET estaActivo = 0, fechaEgresoCargo = CAST(GETDATE() AS DATE), motivoEgreso = @motivoEgreso
    WHERE idGuardaparque = @idGuardaparque
END
GO

-- ==========================================================
-- TABLA HistorialGuardaparque
-- ==========================================================
CREATE OR ALTER PROCEDURE Personal.sp_AltaHistorialGuardaparque
    @idParque       INT,
    @idGuardaparque INT,
    @fechaIngreso   DATE,
    @fechaEgreso    DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Parques.Parque
        WHERE idParque = @idParque
    )
    SET @errores += '- El parque no existe.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
    SET @errores += '- El guardaparque no existe.' + CHAR(10)

    IF @fechaEgreso IS NOT NULL AND @fechaEgreso < @fechaIngreso
    SET @errores += '- Fecha de agreso no puede ser menor a ingreso' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    INSERTO INTO Personal.HistorialGuardaparque
        (idParque, idGuardaparque, fechaIngreso, fechaEgreso)
    VALUES
        (@idParque, @idGuardaparque, @fechaIngreso, @fechaEgreso)

    SELECT SCOPE_IDENTITY() AS idHistorialGuardaparqueNuevo
END
GO


CREATE OR ALTER PROCEDURE Personal.sp_ModificacionHistorialGuardaparque
    @idHistorial    INT,
    @idParque       INT,
    @idGuardaparque INT,
    @fechaIngreso   DATE,
    @fechaEgreso    DATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Parques.Parque
        WHERE idParque = @idParque
    )
    SET @errores += '- El parque no existe.' + CHAR(10)

    IF NOT EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
    SET @errores += '- El guardaparque no existe.' + CHAR(10)

    IF @fechaEgreso IS NOT NULL AND @fechaEgreso < @fechaIngreso
    SET @errores += '- Fecha de agreso no puede ser menor a ingreso' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    UPDATE Personal.HistorialGuardaparque
    SET idParque = @idParque, idGuardaparque = @idGuardaparque,
        fechaIngreso = @fechaIngreso, fechaEgreso = @fechaEgreso
    WHERE idHistorial = @idHistorial
END
GO


CREATE OR ALTER PROCEDURE Personal.sp_BajaHistorialGuardaparque
    @idHistorial        INT,
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(100) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idHistorial = @idHistorial
    )
    SET @errores += '- Historial de Guardaparque no existe.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    UPDATE Personal.HistorialGuardaparque
    SET fechaEgreso = CAST(GETDATE() AS DATE)
    WHERE idHistorial = @idHistorial
END
GO