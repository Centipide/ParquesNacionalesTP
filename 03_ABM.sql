-- ============================================================
-- Fecha: 2025-06-15
-- Descripción: Creación de todos los ABM
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

/*
CREATE TABLE Actividades.TipoActividadTuristica (
    idTipoActividadTuristica INT          IDENTITY(1,1),
    descripcion              VARCHAR(300) NOT NULL,

    CONSTRAINT PK_TipoActTur PRIMARY KEY (idTipoActividadTuristica)
);
GO
*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaTipoActividadTuristica
    @descripcion VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';
    
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripcion no puede estar vacia.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
    VALUES (@descripcion);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificacionTipoActividadTuristica
    @idTipoActividadTuristica INT,
	@descripcion              VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON 

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de tipo de actividad turistica no existe.' + CHAR(10);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripcion no puede estar vacia.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Actividades.TipoActividadTuristica
    SET    descripcion = @descripcion
    WHERE  idTipoActividadTuristica = @idTipoActividadTuristica
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_BajaTipoActividadTuristica
    @idTipoActividadTuristica INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de tipo de actividad turistica no existe.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END
    
    DELETE FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActividadTuristica
END
GO

/*
CREATE TABLE Actividades.ActividadTuristica (
    idActividadTuristica     INT           IDENTITY(1,1),
    idParque                 INT           NOT NULL,
    idTipoActividadTuristica INT           NOT NULL,
    nombre                   VARCHAR(50)   NOT NULL,
    costo                    DECIMAL(10,2) NOT NULL,
    duracion                 INT           NOT NULL,   -- en minutos
    cupoMaximo               INT           NOT NULL,

    CONSTRAINT PK_ActTur PRIMARY KEY (idActividadTuristica),
    CONSTRAINT FK_ActTur_Parque FOREIGN KEY (idParque)
        REFERENCES Parques.Parque (idParque),
    CONSTRAINT FK_ActTur_TipoAct FOREIGN KEY (idTipoActividadTuristica)
        REFERENCES Actividades.TipoActividadTuristica (idTipoActividadTuristica),
    CONSTRAINT CK_ActTur_Costo CHECK (costo >= 0),
    CONSTRAINT CK_ActTur_Duracion CHECK (duracion > 0),
    CONSTRAINT CK_ActTur_Cupo CHECK (cupoMaximo > 0)
);
GO
*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaActividadTuristica
    @idParque                    INT,
    @idTipoActividadTuristica    INT,
    @nombre                      VARCHAR(50),
    @costo                       DECIMAL(10,2),
    @duracion                    INT,
    @cupoMaximo                  INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque
                   WHERE idParque = @idParque)
        SET @errores = @errores + 'El id de Parque no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de Tipo Actividad turistica no existe.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre no puede estar vacio.' + CHAR(10);

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo.' + CHAR(10);

    IF @duracion <= 0
        SET @errores = @errores + 'La duracion debe ser mayor a 0.' + CHAR(10);

    IF @cupoMaximo <= 0
        SET @errores = @errores + 'El cupo maximo debe ser mayor a 0.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.ActividadTuristica (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParque, @idTipoActividadTuristica, @nombre, @costo, @duracion, @cupoMaximo);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificacionActividadTuristica
    @idActividadTuristica       INT,
    @idParque                   INT,
    @idTipoActividadTuristica   INT,
    @nombre                     VARCHAR(50),
    @costo                      DECIMAL(10,2),
    @duracion                   INT,
    @cupoMaximo                 INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque
                   WHERE idParque = @idParque)
        SET @errores = @errores + 'El id de Parque no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de Tipo Actividad Turistica no existe.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre no puede estar vacio.' + CHAR(10);

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo.' + CHAR(10);

    IF @duracion <= 0
        SET @errores = @errores + 'La duracion debe ser mayor a 0.' + CHAR(10);

    IF @cupoMaximo <= 0
        SET @errores = @errores + 'El cupo maximo debe ser mayor a 0.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Actividades.ActividadTuristica
    SET    idParque                 = @idParque,
           idTipoActividadTuristica = @idTipoActividadTuristica,
           nombre                   = @nombre,
           costo                    = @costo,
           duracion                 = @duracion,
           cupoMaximo               = @cupoMaximo
    WHERE  idActividadTuristica = @idActividadTuristica;
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_BajaActividadTuristica
    @idActividadTuristica INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Actividades.ActividadTuristica
    WHERE idActividadTuristica = @idActividadTuristica;
END
GO

/*
CREATE TABLE Actividades.GuiaAutorizacion (
    idGuia               INT NOT NULL,
    idActividadTuristica INT NOT NULL,

    CONSTRAINT PK_GuiaAutorizacion PRIMARY KEY (idGuia, idActividadTuristica),
    CONSTRAINT FK_GA_Guia FOREIGN KEY (idGuia)
        REFERENCES Guias.Guia (idGuia),
    CONSTRAINT FK_GA_Actividad FOREIGN KEY (idActividadTuristica)
        REFERENCES Actividades.ActividadTuristica (idActividadTuristica)
);
GO
*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaGuiaAutorizacion 
    @idGuia                 INT,
    @idActividadTuristica   INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia
                   WHERE idGuia = @idGuia)
        SET @errores = @errores + 'El id de Guia no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
               WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia ya esta autorizado para esta actividad.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_BajaGuiaAutorizacion
    @idGuia                 INT,
    @idActividadTuristica   INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'No existe una autorizacion para ese guia y actividad.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Actividades.GuiaAutorizacion
    WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica;
END
GO

/*
CREATE TABLE Actividades.ActividadProgramada (
    idActividadProgramada   INT          IDENTITY(1,1),
    idGuia                  INT          NOT NULL,
    idActividadTuristica    INT          NOT NULL,
    fecha                   DATE         NOT NULL,
    horaInicio              TIME         NOT NULL,
    estado                  VARCHAR(20)  NOT NULL DEFAULT 'Programada',
    observaciones           VARCHAR(300) NULL,

    CONSTRAINT PK_ActProg PRIMARY KEY (idActividadProgramada),
    CONSTRAINT FK_ActProg_Guia FOREIGN KEY (idGuia)
        REFERENCES Guias.Guia (idGuia),
    CONSTRAINT FK_ActProg_Actividad FOREIGN KEY (idActividadTuristica)
        REFERENCES Actividades.ActividadTuristica (idActividadTuristica),
    CONSTRAINT CK_ActProg_Estado CHECK (estado IN ('Programada','Realizada','Cancelada'))
);
GO
*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaActividadProgramada
    @idGuia                 INT,
    @idActividadTuristica   INT,
    @fecha                  DATE,
    @horaInicio             TIME,
    @observaciones          VARCHAR(300) = NULL -- si no pasamos observaciones, toma NULL por defecto
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia
                   WHERE idGuia = @idGuia)
        SET @errores = @errores + 'El id de Guia no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia
                     AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia no esta autorizado para realizar esta actividad.' + CHAR(10);

    IF @fecha IS NULL
        SET @errores = @errores + 'La fecha no puede estar vacia.' + CHAR(10);

    IF @horaInicio IS NULL
        SET @errores = @errores + 'La hora de inicio no puede estar vacia.' + CHAR(10);

    IF EXISTS (SELECT 1
               FROM Actividades.ActividadProgramada
               WHERE idGuia = @idGuia
                 AND idActividadTuristica = @idActividadTuristica
                 AND fecha = @fecha
                 AND horaInicio = @horaInicio)
        SET @errores = @errores + 'Ya existe una actividad programada con esos datos.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.ActividadProgramada (idGuia, idActividadTuristica, fecha, horaInicio, observaciones)
    VALUES (@idGuia, @idActividadTuristica, @fecha, @horaInicio, @observaciones);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificacionActividadProgramada
    @idActividadProgramada   INT,
    @idGuia                  INT,
    @idActividadTuristica    INT,
    @fecha                   DATE,
    @horaInicio              TIME,
    @estado                  VARCHAR(20),
    @observaciones           VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadProgramada
                   WHERE idActividadProgramada = @idActividadProgramada)
        SET @errores = @errores + 'El id de Actividad Programada no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia
                   WHERE idGuia = @idGuia)
        SET @errores = @errores + 'El id de Guia no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia
                     AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia no esta autorizado para realizar esta actividad.' + CHAR(10);

    IF @fecha IS NULL
        SET @errores = @errores + 'La fecha no puede estar vacia.' + CHAR(10);

    IF @horaInicio IS NULL
        SET @errores = @errores + 'La hora de inicio no puede estar vacia.' + CHAR(10);

    IF @estado NOT IN ('Programada', 'Realizada', 'Cancelada')
        SET @errores = @errores + 'El estado debe ser Programada, Realizada o Cancelada.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Actividades.ActividadProgramada
    SET    idGuia               = @idGuia,
           idActividadTuristica = @idActividadTuristica,
           fecha                = @fecha,
           horaInicio           = @horaInicio,
           estado               = @estado,
           observaciones        = @observaciones
    WHERE  idActividadProgramada = @idActividadProgramada;
END
GO


/* 
    Las actividades programadas no se eliminan físicamente
    para mantener trazabilidad histórica. En vez de eliminarlas,
    en 07_LogicaRegistroActividades, hicimos un sp para cancelarlas.
    Al cancelarlas, las contrataciones asociadas pasan automaticamente
    al estado 'Cancelada'.

*/

/*

CREATE TABLE Actividades.DetalleContratacion (
    idDetalleContratacion INT           IDENTITY(1,1),
    idVenta               INT           NOT NULL,
    costoTotal            DECIMAL(12,2) NOT NULL,
    fechaHora             DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_DetalleContratacion PRIMARY KEY (idDetalleContratacion),
    CONSTRAINT FK_DC_Venta FOREIGN KEY (idVenta)
        REFERENCES Ventas.Venta (idVenta),
    CONSTRAINT CK_DC_Costo CHECK (costoTotal >= 0)
);
GO
*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaDetalleContratacion
    @idVenta    INT,
    @costoTotal DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta
                   WHERE idVenta = @idVenta)
        SET @errores = @errores + 'El id de Venta no existe.' + CHAR(10);

    IF @costoTotal < 0
        SET @errores = @errores + 'El costo total no puede ser negativo.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.DetalleContratacion (idVenta, costoTotal)
    VALUES (@idVenta, @costoTotal);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_BajaDetalleContratacion
    @idDetalleContratacion INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Actividades.DetalleContratacion
    WHERE idDetalleContratacion = @idDetalleContratacion;
END
GO

/*

CREATE TABLE Actividades.Contratacion (
    idContratacion         INT           IDENTITY(1,1),
    idDetalleContratacion  INT           NOT NULL,
    idActividadProgramada  INT           NOT NULL,
    costo                  DECIMAL(10,2) NOT NULL,
    estado                 VARCHAR(20)   NOT NULL DEFAULT 'Confirmada',
    cantidadPersonas       INT           NOT NULL,

    CONSTRAINT PK_Contratacion PRIMARY KEY (idContratacion),

    CONSTRAINT FK_Con_DetalleCon FOREIGN KEY (idDetalleContratacion)
        REFERENCES Actividades.DetalleContratacion (idDetalleContratacion),

    CONSTRAINT FK_Con_ActividadProgramada FOREIGN KEY (idActividadProgramada)
        REFERENCES Actividades.ActividadProgramada (idActividadProgramada),

    CONSTRAINT CK_Cont_Costo CHECK (costo >= 0),
    CONSTRAINT CK_Cont_Personas CHECK (cantidadPersonas > 0),
    CONSTRAINT CK_Cont_Estado CHECK (
        estado IN ('Confirmada','Cancelada','Completada')
    )
);
GO

*/

CREATE OR ALTER PROCEDURE Actividades.sp_AltaContratacion
    @idDetalleContratacion INT,
    @idActividadProgramada INT,
    @costo                 DECIMAL(10,2),
    @estado                VARCHAR(20) = 'Confirmada',
    @cantidadPersonas      INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadProgramada
                   WHERE idActividadProgramada = @idActividadProgramada)
        SET @errores = @errores + 'El id de Actividad Programada no existe.' + CHAR(10);

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo.' + CHAR(10);

    IF @cantidadPersonas <= 0
        SET @errores = @errores + 'La cantidad de personas debe ser mayor a 0.' + CHAR(10);

    IF @estado IS NULL
       OR @estado NOT IN ('Confirmada', 'Cancelada', 'Completada')
        SET @errores = @errores + 'El estado debe ser Confirmada, Cancelada o Completada.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    INSERT INTO Actividades.Contratacion (idDetalleContratacion, idActividadProgramada, costo, estado, cantidadPersonas)
    VALUES (@idDetalleContratacion, @idActividadProgramada, @costo, @estado, @cantidadPersonas);

END
GO

CREATE OR ALTER PROCEDURE Actividades.sp_ModificacionContratacion
    @idContratacion         INT,
    @idDetalleContratacion  INT,
    @idActividadProgramada  INT,
    @costo                  DECIMAL(10,2),
    @estado                 VARCHAR(20),
    @cantidadPersonas       INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.Contratacion
                   WHERE idContratacion = @idContratacion)
        SET @errores = @errores + 'El id de Contratacion no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadProgramada
                   WHERE idActividadProgramada = @idActividadProgramada)
        SET @errores = @errores + 'El id de Actividad Programada no existe.' + CHAR(10);

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo.' + CHAR(10);

    IF @cantidadPersonas <= 0
        SET @errores = @errores + 'La cantidad de personas debe ser mayor a 0.' + CHAR(10);

    IF @estado IS NULL
       OR @estado NOT IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada')
        SET @errores = @errores + 'El estado debe ser Pendiente, Confirmada, Cancelada o Completada.' + CHAR(10);

    IF @errores != ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    UPDATE Actividades.Contratacion
    SET    idDetalleContratacion = @idDetalleContratacion,
           idActividadProgramada = @idActividadProgramada,
           costo                 = @costo,
           estado                = @estado,
           cantidadPersonas      = @cantidadPersonas
    WHERE  idContratacion        = @idContratacion;
END
GO

/*
    Al igual que con las actividades Programadas, hicimos
    cancelación lógica, en 07_logicaRegistroActividades
*/

-- ==========================================================
-- TABLA Parque
-- ==========================================================
CREATE OR ALTER PROCEDURE Parques.sp_AltaParque
    @idTipoParque INT,
    @nombre       VARCHAR(100),
    @region       VARCHAR(50),
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

    IF ISNULL(@region,'') = ''
    SET @errores += '- Falta ingresar region.' + CHAR(10)

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
        (idTipoParque, nombre, region, provincia, superficie)
    VALUES
        (@idTipoParque, @nombre, @region, @provincia, @superficie)
    
    SELECT SCOPE_IDENTITY() AS idParqueNuevo
END
GO

CREATE OR ALTER PROCEDURE Parques.sp_ModificacionParque
    @idParque     INT,
    @idTipoParque INT,
    @nombre       VARCHAR(100),
    @region       VARCHAR(50),
    @provincia    VARCHAR(30),
    @superficie   DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

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
    SET idTipoParque = @idTipoParque, nombre = @nombre, region = @region,
        provincia = @provincia, superficie = @superficie
    WHERE idParque = @idParque
END
GO


CREATE OR ALTER PROCEDURE Parques.sp_BajaParque
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

    IF EXISTS (
        SELECT 1 FROM Actividades.ActividadTuristica
        WHERE idParque = @idParque
    )
        SET @errores += 'No se puede eliminar porque existen Actividades Turisticas en el parque.' + CHAR(10)

    IF EXISTS (
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idParque = @idParque
    )
        SET @errores += 'No se puede eliminar porque existen Historial de Guardaparque en el parque.' + CHAR(10)

    IF EXISTS (
        SELECT 1 FROM Concesiones.Concesion
        WHERE idParque = @idParque
    )
        SET @errores += 'No se puede eliminar porque existen Concesiones en el parque.' + CHAR(10)

    IF EXISTS (
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
-- TABLA TipoParque
-- ==========================================================
CREATE OR ALTER PROCEDURE Parques.sp_AltaTipoParque
    @nombre      VARCHAR(100),
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF ISNULL (@nombre, '') = ''
        SET @errores += '- Nombre de Tipo Parque no ingresado' + CHAR(10)
    ELSE IF EXISTS (
        SELECT 1 FROM Parques.TipoParque
        WHERE nombre = @nombre
    )
        SET @errores += '- Tipo Parque ya existe' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    INSERT INTO Parques.TipoParque
        (nombre, descripcion)
    VALUES
        (@nombre, @descripcion)
    
    SELECT SCOPE_IDENTITY() AS idTipoParqueNuevo
END
GO


CREATE OR ALTER PROCEDURE Parques.sp_ModificacionTipoParque
    @idTipoParque INT,
    @nombre       VARCHAR(100),
    @descripcion  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Parques.TipoParque
        WHERE idTipoParque = @idTipoParque
    )
        SET @errores += '- No existe el Tipo Parque ingresado.' + CHAR(10)
    
    IF ISNULL (@nombre, '') = ''
        SET @errores += '- Nombre de Tipo Parque no ingresado' + CHAR(10)
    ELSE IF EXISTS (
        SELECT 1 FROM Parques.TipoParque
        WHERE nombre = @nombre
    )
        SET @errores += '- Tipo Parque ya existe' + CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    UPDATE Parques.TipoParque
    SET nombre = @nombre, descripcion = @descripcion
    WHERE idTipoParque = @idTipoParque
END
GO


CREATE OR ALTER PROCEDURE Parques.sp_BajaTipoParque
    @idTipoParque INT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(1000) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Parques.TipoParque
        WHERE idTipoParque = @idTipoParque
    )
        SET @errores += '- Tipo Parque ingresado no existe.' + CHAR(10)

    IF EXISTS (
        SELECT 1 FROM Parques.Parque
        WHERE idTipoParque = @idTipoParque
    )
        SET @errores += '- No se puede eliminar porque existen Parques registrados.'

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    DELETE FROM Parques.TipoParque
    WHERE idTipoParque = @idTipoParque
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

    -- Validacion TIPO Y NRO DOCUMENTOD
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
    IF (@fechaIngresoCargo > CAST(GETDATE() AS DATE))
        SET @errores += '- Fecha invalida.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    INSERT INTO Personal.Guardaparque
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

    IF (@fechaEgresoCargo IS NOT NULL AND @fechaEgresoCargo < @fechaIngresoCargo)
        SET @errores += '- Fecha de egreso no puede ser menor a ingreso.' + CHAR(10)

    IF EXISTS (
        SELECT 1 FROM Personal.Guardaparque
        WHERE tipoDocumento = @tipoDocumento AND nroDocumento = @nroDocumento AND idGuardaparque != @idGuardaparque
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


CREATE OR ALTER PROCEDURE Personal.sp_EliminarGuardaparque
    @idGuardaparque     INT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(100) = ''

    IF EXISTS (
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idGuardaparque = @idGuardaparque
    )
        SET @errores += '- No se puede eliminar porque Guardapaque posee Historial.'

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    DELETE FROM Personal.Guardaparque
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

    INSERT INTO Personal.HistorialGuardaparque
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
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idHistorial = @idHistorial
    )
        SET @errores += '- El historial no existe.' + CHAR(10)

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
    @idHistorial INT
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


CREATE OR ALTER PROCEDURE Personal.sp_EliminarHistorialGuardaparque
    @idHistorial     INT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errores VARCHAR(100) = ''

    IF NOT EXISTS (
        SELECT 1 FROM Personal.HistorialGuardaparque
        WHERE idHistorial = @idHistorial
    )
        SET @errores += '- No se puede eliminar Historial inexistente.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR (@errores, 16, 1)
        RETURN
    END

    DELETE FROM Personal.HistorialGuardaparque
    WHERE idHistorial = @idHistorial
END
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
    @vigenciaAutorizacion DATE


AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    -- Validacion NOMBRE
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre no puede estar vacio.' + CHAR(10)
    
    -- Validacion APELLIDO
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores += 'El apellido no puede estar vacio.' + CHAR(10)
    
    -- Validacion FECHA NACIMIENTO
    IF @fechaNacimiento IS NULL
        SET @errores += 'Fecha de nacimiento no ingresada.' + CHAR(10)

    --Validacion TIPO DOCUMENTO Y NRO DOCUMENTO
    IF EXISTS (
        SELECT 1 FROM Guias.Guia
        WHERE tipoDocumento = @tipoDocumento AND nroDocumento = @nroDocumento
    )
        SET @errores += 'Tipo y Nro de documento ya existen.' + CHAR(10)

    --Validacion EMAIL
    IF EXISTS(
        SELECT 1 FROM Guias.Guia
        WHERE email = @email
    )
        SET @errores += 'Email ya registrado.' + CHAR(10)
    
    -- Validacion vigencia autorizacion vacia
    IF @vigenciaAutorizacion IS NULL
         SET @errores += 'La vigencia de autorizacion es obligatoria.' + CHAR(10)

    -- Validacion vigencia vencida
    IF @vigenciaAutorizacion IS NOT NULL AND @vigenciaAutorizacion < GETDATE()
    SET @errores += 'La vigencia de autorizacion no puede estar vencida.'+ CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    INSERT INTO Guias.Guia (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, email, vigenciaAutorizacion, estaActivo)
    VALUES (@nombre, @apellido, @fechaNacimiento, @tipoDocumento, @nroDocumento, @email, @vigenciaAutorizacion, 1)

    SELECT SCOPE_IDENTITY() AS idGuiaNuevo
END
GO
--======================================================================================================================

CREATE OR ALTER PROCEDURE Guias.sp_ModificacionGuia
    @idGuia               INT,
    @nombre               VARCHAR(50),
    @apellido             VARCHAR(50),
    @fechaNacimiento      DATE,
    @tipoDocumento        VARCHAR(20),
    @nroDocumento         VARCHAR(20),
    @email                VARCHAR(150),
    @vigenciaAutorizacion DATE

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El id de guia ingresado no existe.' + CHAR(10)

    --Validacion TIPO DOCUMENTO Y NRO DOCUMENTO
    IF EXISTS (
        SELECT 1 FROM Guias.Guia
        WHERE tipoDocumento = @tipoDocumento AND nroDocumento = @nroDocumento AND idGuia != @idGuia
    )
        SET @errores += 'Ya existe otro guia con este tipo y nro de documento.' + CHAR(10)

    --Validacion EMAIL
    IF EXISTS(
        SELECT 1 FROM Guias.Guia
        WHERE email = @email AND idGuia != @idGuia
    )
        SET @errores += 'ya existe otro guia con ese email.' + CHAR(10)
    
    -- Validacion vigencia autorizacion vacia
    IF @vigenciaAutorizacion IS NULL
         SET @errores += 'La vigencia de autorizacion es obligatoria.' + CHAR(10)

    -- Validacion vigencia vencida
    IF @vigenciaAutorizacion IS NOT NULL AND @vigenciaAutorizacion < GETDATE()
    SET @errores += 'La vigencia de autorizacion no puede estar vencida.'+ CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

     UPDATE Guias.Guia
    SET
        nombre=@nombre,
        apellido=@apellido,
        fechaNacimiento=@fechaNacimiento,
        tipoDocumento=@tipoDocumento,
        nroDocumento=@nroDocumento,
        email=@email,
        vigenciaAutorizacion=@vigenciaAutorizacion

    WHERE idGuia=@idGuia;
END
GO

--===================================================================================

CREATE OR ALTER PROCEDURE Guias.sp_BajaGuia
    @idGuia INT

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(100) = ''

    IF NOT EXISTS(
        SELECT 1 FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El guia no existe.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

     UPDATE Guias.Guia
    SET estaActivo = 0
    WHERE idGuia=@idGuia
END
GO
-- ==========================================================
-- TABLA Habilitacion
-- ==========================================================

CREATE OR ALTER PROCEDURE Guias.sp_AltaHabilitacion
    @nombre           VARCHAR(50),
    @fechaEmision     DATE,
    @fechaVencimiento DATE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''
    
    --Validacion nombre
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre no puede estar vacio.' + CHAR(10)

    --Validacion FechaEmision
    IF @fechaEmision IS NULL
        SET @errores += 'La fecha de emision es obligatoria.' + CHAR(10)
    
    IF @fechaVencimiento IS NULL
        SET @errores += 'La fecha de vencimiento es obligatoria.' + CHAR(10)

    IF @fechaEmision IS NOT NULL AND @fechaVencimiento IS NOT NULL
    AND @fechaVencimiento <= @fechaEmision
        SET @errores += 'La fecha de vencimiento debe ser posterior a la fecha de emision.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    INSERT INTO Guias.Habilitacion (nombre,fechaEmision,fechaVencimiento)
    VALUES(@nombre, @fechaEmision, @fechaVencimiento)

    SELECT SCOPE_IDENTITY() AS idHabilitacionNueva
END
GO

--==================================================================
CREATE OR ALTER PROCEDURE Guias.sp_ModificacionHabilitacion
    @idHabilitacion   INT,
    @nombre           VARCHAR(50),
    @fechaEmision     DATE,
    @fechaVencimiento DATE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''
    
    IF NOT EXISTS(
        SELECT 1 FROM Guias.Habilitacion
        WHERE idHabilitacion = @idHabilitacion
    )
    SET @errores += 'La habilitacion ingresada no existe' + CHAR(10)

        --Validacion nombre
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre no puede estar vacio.' + CHAR(10)

    --Validacion FechaEmision
    IF @fechaEmision IS NULL
        SET @errores += 'La fecha de emision es obligatoria.' + CHAR(10)
    
    --Validacion FechaVencimiento
    IF @fechaVencimiento IS NULL
        SET @errores += 'La fecha de vencimiento es obligatoria.' + CHAR(10)

    IF @fechaEmision IS NOT NULL AND @fechaVencimiento IS NOT NULL
    AND @fechaVencimiento <= @fechaEmision
        SET @errores += 'La fecha de vencimiento debe ser posterior a la fecha de emision.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END

    UPDATE Guias.Habilitacion 
    SET 
        nombre = @nombre, 
        fechaEmision = @fechaEmision, 
        fechaVencimiento = @fechaVencimiento
    WHERE idHabilitacion = @idHabilitacion
END
GO
--=====================================================================================================
CREATE OR ALTER PROCEDURE Guias.sp_BajaHabilitacion
    @idHabilitacion   INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''
    
    IF NOT EXISTS(
        SELECT 1 FROM Guias.Habilitacion
        WHERE idHabilitacion = @idHabilitacion
    )
    SET @errores += 'La habilitacion ingresada no existe.' + CHAR(10)

    IF EXISTS(
        SELECT 1
        FROM Guias.GuiaHabilitacion
        WHERE idHabilitacion = @idHabilitacion
    )
        SET @errores += 'No se puede eliminar porque existen guias asociadas.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1)
        RETURN
    END
    
    DELETE FROM Guias.Habilitacion
    WHERE idHabilitacion = @idHabilitacion

END
GO

--===========================================================
-- TABLA GuiaHabilitacion
-- ==========================================================
CREATE OR ALTER PROCEDURE Guias.sp_AltaGuiaHabilitacion
    @idGuia         INT,
    @idHabilitacion INT
AS
BEGIN 
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El guia ingresado no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.Habilitacion
        WHERE idHabilitacion = @idHabilitacion
    )
        SET @errores += 'La habilitacion ingresada no existe.' + CHAR(10)
    
    IF EXISTS(
        SELECT 1
        FROM Guias.GuiaHabilitacion
        WHERE idHabilitacion = @idHabilitacion
        AND idGuia = @idGuia
    )
        SET @errores += 'El guia ya tiene esa habilitacion' + CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    INSERT INTO Guias.GuiaHabilitacion (idGuia, idHabilitacion)
    VALUES (@idGuia, @idHabilitacion)
END
GO

--=================================================================

CREATE OR ALTER PROCEDURE Guias.sp_BajaGuiaHabilitacion
    @idGuia         INT,
    @idHabilitacion INT
AS
BEGIN 
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El guia ingresado no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.Habilitacion
        WHERE idHabilitacion = @idHabilitacion
    )
        SET @errores += 'La habilitacion ingresada no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.GuiaHabilitacion
        WHERE idHabilitacion = @idHabilitacion
        AND idGuia = @idGuia
    )
        SET @errores += 'La relacion Guia - Habilitacion no existe' + CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    DELETE FROM Guias.GuiaHabilitacion
    WHERE idGuia = @idGuia AND idHabilitacion = @idHabilitacion
END
GO

--===========================================================
-- TABLA Titulo
-- ==========================================================

CREATE OR ALTER PROCEDURE Guias.sp_AltaTitulo
    @nombre           VARCHAR(50),
    @fechaEmision     DATE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''
    
    --Validacion nombre
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre del titulo no puede estar vacio.' + CHAR(10)

    --Validacion FechaEmision
    IF @fechaEmision IS NULL
        SET @errores += 'La fecha de emision es obligatoria.' + CHAR(10)

    IF EXISTS(
        SELECT 1
        FROM GUias.Titulo
        WHERE nombre = @nombre AND fechaEmision = @fechaEmision
    )
        SET @errores += 'Este titulo ya existe.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    INSERT INTO Guias.Titulo (nombre,fechaEmision)
    VALUES(@nombre, @fechaEmision)

    SELECT SCOPE_IDENTITY() AS idTituloNuevo
END
GO

 --====================================================================
CREATE OR ALTER PROCEDURE Guias.sp_ModificacionTitulo
    @idTitulo         INT,
    @nombre           VARCHAR(50),
    @fechaEmision     DATE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Titulo
        WHERE idTitulo = @idTitulo
    )
        SET @errores += 'El titulo ingresado no existe.' + CHAR(10)
    
    --Validacion nombre
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += 'El nombre del titulo no puede estar vacio.' + CHAR(10)

    --Validacion FechaEmision
    IF @fechaEmision IS NULL
        SET @errores += 'La fecha de emision es obligatoria.' + CHAR(10)

    IF EXISTS(
        SELECT 1
        FROM Guias.Titulo
        WHERE nombre = @nombre AND fechaEmision = @fechaEmision AND idTitulo != @idTitulo
    )
        SET @errores += 'Ya existe este titulo con estos datos.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    UPDATE Guias.Titulo 
    SET 
        nombre = @nombre,
        fechaEmision = @fechaEmision
    WHERE idTitulo = @idTitulo
END
GO

--=========================================================================

CREATE OR ALTER PROCEDURE Guias.sp_BajaTitulo
    @idTitulo         INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Titulo
        WHERE idTitulo = @idTitulo
    )
        SET @errores += 'El titulo ingresado no existe.' + CHAR(10)
    
    IF EXISTS(
        SELECT 1
        FROM Guias.GuiaTitulo
        WHERE idTitulo = @idTitulo
    )
        SET @errores += 'No se puede eliminar porque existe guias asociados.' + CHAR(10)

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    DELETE FROM Guias.Titulo 
    WHERE idTitulo = @idTitulo
END
GO

--===========================================================
-- TABLA GuiaTitulo
-- ==========================================================
CREATE OR ALTER PROCEDURE Guias.sp_AltaGuiaTitulo
    @idGuia         INT,
    @idTitulo       INT
AS
BEGIN 
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El guia ingresado no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.Titulo
        WHERE idTitulo = @idTitulo
    )
        SET @errores += 'El titulo ingresado no existe.' + CHAR(10)
    
    IF EXISTS(
        SELECT 1
        FROM Guias.GuiaTitulo
        WHERE idTitulo = @idTitulo
        AND idGuia = @idGuia
    )
        SET @errores += 'El guia ya tiene ese titulo' + CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    INSERT INTO Guias.GuiaTitulo (idGuia, idTitulo)
    VALUES (@idGuia, @idTitulo)
END
GO

--=================================================================

CREATE OR ALTER PROCEDURE Guias.sp_BajaGuiaTitulo
    @idGuia         INT,
    @idTitulo       INT
AS
BEGIN 
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = ''

    IF NOT EXISTS(
        SELECT 1 
        FROM Guias.Guia
        WHERE idGuia = @idGuia
    )
        SET @errores += 'El guia ingresado no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.Titulo
        WHERE idTitulo = @idTitulo
    )
        SET @errores += 'El titulo ingresado no existe.' + CHAR(10)
    
    IF NOT EXISTS(
        SELECT 1
        FROM Guias.GuiaTitulo
        WHERE idTitulo = @idTitulo
        AND idGuia = @idGuia
    )
        SET @errores += 'La relacion Guia - Titulo no existe' + CHAR(10)
    
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores,16,1)
        RETURN
    END

    DELETE FROM Guias.GuiaTitulo
    WHERE idGuia = @idGuia AND idTitulo = @idTitulo
END
GO

--===========================================================
-- TABLA EmpresaConcesionaria
-- ==========================================================

CREATE OR ALTER PROCEDURE Concesiones.sp_AltaEmpresaConcesionaria
    @cuit        CHAR(11),
    @razonSocial VARCHAR(100),
    @contacto    VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF @cuit IS NULL OR LEN(LTRIM(RTRIM(@cuit))) <> 11 OR @cuit LIKE '%[^0-9]%'
        SET @errores += '- El CUIT es obligatorio, debe contener exactamente 11 caracteres y ser numérico puro.' + CHAR(10);
    
    IF EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE cuit = @cuit)
        SET @errores += '- El CUIT ingresado ya se encuentra asignado a otra empresa concesionaria.' + CHAR(10);

    IF @razonSocial IS NULL OR LTRIM(RTRIM(@razonSocial)) = ''
        SET @errores += '- La razón social es un campo obligatorio y no puede quedar vacío.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial, contacto)
    VALUES (LTRIM(RTRIM(@cuit)), LTRIM(RTRIM(@razonSocial)), LTRIM(RTRIM(@contacto)));
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_ModificacionEmpresaConcesionaria
    @idEmpresaConcesionaria INT,
    @cuit                   CHAR(11),
    @razonSocial            VARCHAR(100),
    @contacto               VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria)
        SET @errores += '- El ID de la empresa concesionaria especificado no existe.' + CHAR(10);

    IF @cuit IS NULL OR LEN(LTRIM(RTRIM(@cuit))) <> 11 OR @cuit LIKE '%[^0-9]%'
        SET @errores += '- El CUIT es obligatorio, debe contener exactamente 11 caracteres y ser numérico puro.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE cuit = @cuit AND idEmpresaConcesionaria <> @idEmpresaConcesionaria)
        SET @errores += '- El nuevo CUIT ingresado ya pertenece a otra empresa concesionaria.' + CHAR(10);

    IF @razonSocial IS NULL OR LTRIM(RTRIM(@razonSocial)) = ''
        SET @errores += '- La razón social es obligatoria.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.EmpresaConcesionaria
    SET cuit = LTRIM(RTRIM(@cuit)),
        razonSocial = LTRIM(RTRIM(@razonSocial)),
        contacto = LTRIM(RTRIM(@contacto))
    WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_EliminarEmpresaConcesionaria
    @idEmpresaConcesionaria INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria)
        SET @errores += '- El ID de la empresa a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria)
        SET @errores += '- Restricción de Integridad: No se puede eliminar la empresa porque posee contratos de concesión activos o históricos asignados.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.EmpresaConcesionaria 
    WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria;
    
    PRINT 'Empresa concesionaria eliminada correctamente.';
END;
GO

-- ==========================================================
-- TABLA TipoActividadConcesion
-- ==========================================================

CREATE OR ALTER PROCEDURE Concesiones.sp_AltaTipoActividadConcesion
    @nombre               VARCHAR(100),
    @descripcionActividad VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre de la actividad de concesión es obligatorio y no puede estar vacío.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE nombre = @nombre)
        SET @errores += '- El tipo de actividad comercial ingresado ya existe en el sistema.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.TipoActividadConcesion (nombre, descripcionActividad)
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@descripcionActividad)));

    SELECT SCOPE_IDENTITY() AS idTipoActividadConcesionNueva;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_ModificacionTipoActividadConcesion
    @idTipoActividadConcesion INT,
    @nombre                   VARCHAR(100),
    @descripcionActividad     VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idTipoActividadConcesion)
        SET @errores += '- El ID del tipo de actividad de concesión especificado no existe.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre de la actividad es un campo obligatorio.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE nombre = @nombre AND idTipoActividadConcesion <> @idTipoActividadConcesion)
        SET @errores += '- Ya existe otra actividad registrada con ese mismo nombre.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.TipoActividadConcesion
    SET nombre = LTRIM(RTRIM(@nombre)),
        descripcionActividad = LTRIM(RTRIM(@descripcionActividad))
    WHERE idTipoActividadConcesion = @idTipoActividadConcesion;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_EliminarTipoActividadConcesion
    @idTipoActividadConcesion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idTipoActividadConcesion)
        SET @errores += '- El ID de la actividad a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idTipoActividadConcesion = @idTipoActividadConcesion)
        SET @errores += '- Restricción de Integridad: No se puede eliminar el rubro comercial debido a que posee contratos de concesión asociados.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.TipoActividadConcesion 
    WHERE idTipoActividadConcesion = @idTipoActividadConcesion;
    
    PRINT 'Tipo de actividad de concesión eliminado correctamente.';
END;
GO

-- ==========================================================
-- TABLA Concesion
-- ==========================================================

CREATE OR ALTER PROCEDURE Concesiones.sp_AltaConcesion
    @idEmpresaConcesionaria   INT,
    @idTipoActividadConcesion INT,
    @idParque                 INT,
    @fechaInicio              DATE,
    @fechaFin                 DATE,
    @montoAlquiler            DECIMAL(12,2),
    @estado                   VARCHAR(20) = 'Activa'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';


    IF NOT EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria)
        SET @errores += '- El ID de la empresa concesionaria especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idTipoActividadConcesion)
        SET @errores += '- El ID del tipo de actividad de concesión especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE idParque = @idParque)
        SET @errores += '- El ID del parque especificado no existe.' + CHAR(10);


    IF @fechaInicio IS NULL OR @fechaFin IS NULL
        SET @errores += '- Las fechas de inicio y fin de contrato son obligatorias.' + CHAR(10);
    ELSE IF @fechaFin <= @fechaInicio
        SET @errores += '- La fecha de finalización del contrato debe ser estrictamente posterior a la fecha de inicio.' + CHAR(10);

    IF @montoAlquiler IS NULL OR @montoAlquiler <= 0
        SET @errores += '- El monto del alquiler/canon mensual debe ser una magnitud mayor a cero.' + CHAR(10);

    IF @estado NOT IN ('Activa', 'Vencida', 'Cancelada')
        SET @errores += '- El estado del contrato ingresado no es válido (Debe ser Activa, Vencida o Cancelada).' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresaConcesionaria, @idTipoActividadConcesion, @idParque, @fechaInicio, @fechaFin, @montoAlquiler, @estado);

    SELECT SCOPE_IDENTITY() AS idConcesionNueva;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_ModificacionConcesion
    @idConcesion              INT,
    @idEmpresaConcesionaria   INT,
    @idTipoActividadConcesion INT,
    @idParque                 INT,
    @fechaInicio              DATE,
    @fechaFin                 DATE,
    @montoAlquiler            DECIMAL(12,2),
    @estado                   VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
        SET @errores += '- El ID del contrato de concesión especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.EmpresaConcesionaria WHERE idEmpresaConcesionaria = @idEmpresaConcesionaria)
        SET @errores += '- El ID de la empresa concesionaria especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.TipoActividadConcesion WHERE idTipoActividadConcesion = @idTipoActividadConcesion)
        SET @errores += '- El ID del tipo de actividad de concesión especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE idParque = @idParque)
        SET @errores += '- El ID del parque especificado no existe.' + CHAR(10);

    IF @fechaInicio IS NULL OR @fechaFin IS NULL
        SET @errores += '- Las fechas de inicio y fin de contrato son obligatorias.' + CHAR(10);
    ELSE IF @fechaFin <= @fechaInicio
        SET @errores += '- La fecha de finalización debe ser estrictamente posterior a la fecha de inicio.' + CHAR(10);

    IF @montoAlquiler IS NULL OR @montoAlquiler <= 0
        SET @errores += '- El monto del alquiler debe ser una magnitud mayor a cero y no nula.' + CHAR(10);

    IF @estado IS NULL OR @estado NOT IN ('Activa', 'Vencida', 'Cancelada')
        SET @errores += '- El estado es obligatorio y debe ser Activa, Vencida o Cancelada.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.Concesion
    SET idEmpresaConcesionaria = @idEmpresaConcesionaria,
        idTipoActividadConcesion = @idTipoActividadConcesion,
        idParque = @idParque,
        fechaInicio = @fechaInicio,
        fechaFin = @fechaFin,
        montoAlquiler = @montoAlquiler,
        estado = @estado
    WHERE idConcesion = @idConcesion;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_EliminarConcesion
    @idConcesion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
        SET @errores += '- El ID del contrato de concesión a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Concesiones.PagoCanon WHERE idConcesion = @idConcesion)
        SET @errores += '- Restricción de Integridad: No es posible eliminar el contrato de concesión porque posee registros de pagos históricos (PagoCanon) asociados.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Concesiones.Concesion 
    WHERE idConcesion = @idConcesion;
    
    PRINT 'Contrato de concesión eliminado de forma exitosa.';
END;
GO

-- ==========================================================
-- TABLA PagoCanon
-- ==========================================================

CREATE OR ALTER PROCEDURE Concesiones.sp_AltaPagoCanon
    @idConcesion      INT,
    @fechaPago        DATE,
    @monto            DECIMAL(12,2),
    @fechaVencimiento DATE,
    @fechaEmision     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
        SET @errores += '- El ID del contrato de concesión especificado no existe en los registros.' + CHAR(10);

    IF @monto IS NULL OR @monto <= 0
        SET @errores += '- El monto del canon debe ser una magnitud financiera estrictamente mayor a cero.' + CHAR(10);

    IF @fechaVencimiento IS NULL OR @fechaEmision IS NULL
        SET @errores += '- Las fechas de emisión y vencimiento del canon son campos de carácter obligatorio.' + CHAR(10);
    ELSE IF @fechaVencimiento < @fechaEmision
        SET @errores += '- Consistencia temporal: La fecha de vencimiento no puede ser anterior a la fecha de emisión del comprobante.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Concesiones.PagoCanon (idConcesion, fechaPago, monto, fechaVencimiento, fechaEmision)
    VALUES (@idConcesion, @fechaPago, @monto, @fechaVencimiento, @fechaEmision);

    SELECT SCOPE_IDENTITY() AS idPagoCanonNuevo;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_ModificacionPagoCanon
    @idPagoCanon      INT,
    @idConcesion      INT,
    @fechaPago        DATE,
    @monto            DECIMAL(12,2),
    @fechaVencimiento DATE,
    @fechaEmision     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Concesiones.PagoCanon WHERE idPagoCanon = @idPagoCanon)
        SET @errores += '- El ID del registro de pago de canon a modificar no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
        SET @errores += '- El ID del contrato de concesión especificado no existe.' + CHAR(10);

    IF @monto IS NULL OR @monto <= 0
        SET @errores += '- El monto a modificar es obligatorio y debe ser mayor a cero.' + CHAR(10);

    IF @fechaVencimiento IS NULL OR @fechaEmision IS NULL OR @fechaPago IS NULL
        SET @errores += '- Las fechas de pago, emisión y vencimiento son mandatorias en la modificación.' + CHAR(10);
    ELSE IF @fechaVencimiento < @fechaEmision
        SET @errores += '- La fecha de vencimiento no puede ser anterior a la fecha de emisión.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Concesiones.PagoCanon
    SET idConcesion = @idConcesion,
        fechaPago = @fechaPago,
        monto = @monto,
        fechaVencimiento = @fechaVencimiento,
        fechaEmision = @fechaEmision
    WHERE idPagoCanon = @idPagoCanon;
END;
GO

CREATE OR ALTER PROCEDURE Concesiones.sp_EliminarPagoCanon
    @idPagoCanon INT
AS
BEGIN
    SET NOCOUNT ON;
    
    RAISERROR('- Error de Auditoría: Los registros históricos de PagoCanon no pueden ser eliminados físicamente del sistema por normativas de control fiscal.', 16, 1);
    RETURN;
END;
GO

-- ==========================================================
-- TABLA TipoVisitante
-- ==========================================================

CREATE OR ALTER PROCEDURE Ventas.sp_AltaTipoVisitante
    @nombre      VARCHAR(100),
    @descripcion VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre del tipo de visitante es obligatorio y no puede enviarse vacío.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE nombre = @nombre)
        SET @errores += '- El tipo de visitante ingresado ya se encuentra registrado en el catálogo.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Ventas.TipoVisitante (nombre, descripcion)
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@descripcion)));

    SELECT SCOPE_IDENTITY() AS idTipoVisitanteNuevo;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionTipoVisitante
    @idTipoVisitante INT,
    @nombre          VARCHAR(100),
    @descripcion     VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errores += '- El ID del tipo de visitante especificado no existe.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores += '- El nombre de la categoría es un campo obligatorio y no nulo.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE nombre = @nombre AND idTipoVisitante <> @idTipoVisitante)
        SET @errores += '- Ya existe otra categoría de visitante registrada con ese mismo nombre.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Ventas.TipoVisitante
    SET nombre = LTRIM(RTRIM(@nombre)),
        descripcion = LTRIM(RTRIM(@descripcion))
    WHERE idTipoVisitante = @idTipoVisitante;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_EliminarTipoVisitante
    @idTipoVisitante INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errores += '- El ID de la categoría a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idTipoVisitante = @idTipoVisitante)
        SET @errores += '- Restricción de Integridad: No se puede eliminar la categoría porque existen tarifas de entrada vigentes vinculadas a este tipo de visitante.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.TipoVisitante 
    WHERE idTipoVisitante = @idTipoVisitante;
    
    PRINT 'Tipo de visitante eliminado correctamente.';
END;
GO

-- ==========================================================
-- TABLA Visitante
-- ==========================================================
CREATE OR ALTER PROCEDURE Ventas.sp_AltaVisitante
    @nombre    VARCHAR(50),
    @apellido  VARCHAR(50),
    @email     VARCHAR(100) = NULL,
    @direccion VARCHAR(100) = NULL,
    @telefono  VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

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

    INSERT INTO Ventas.Visitante (nombre, apellido, email, direccion, telefono)
    VALUES (
        LTRIM(RTRIM(@nombre)), 
        LTRIM(RTRIM(@apellido)), 
        NULLIF(LTRIM(RTRIM(@email)), ''), 
        NULLIF(LTRIM(RTRIM(@direccion)), ''), 
        NULLIF(LTRIM(RTRIM(@telefono)), '')
    );

    SELECT SCOPE_IDENTITY() AS idVisitanteNuevo;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionVisitante
    @idVisitante INT,
    @nombre      VARCHAR(50),
    @apellido    VARCHAR(50),
    @email       VARCHAR(100) = NULL,
    @direccion   VARCHAR(100) = NULL,
    @telefono    VARCHAR(20) = NULL
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
        email = NULLIF(LTRIM(RTRIM(@email)), ''),
        direccion = NULLIF(LTRIM(RTRIM(@direccion)), ''),
        telefono = NULLIF(LTRIM(RTRIM(@telefono)), '')
    WHERE idVisitante = @idVisitante;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_EliminarVisitante
    @idVisitante INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
        SET @errores += '- El ID de visitante a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVisitante = @idVisitante)
        SET @errores += '- Restricción de Integridad: No es posible remover al visitante debido a que registra tickets comerciales asociados en el módulo de ventas.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.Visitante 
    WHERE idVisitante = @idVisitante;
    
    PRINT 'Visitante removido del padrón de forma exitosa.';
END;
GO


-- ==========================================================
-- TABLA Entrada
-- ==========================================================
CREATE OR ALTER PROCEDURE Ventas.sp_AltaEntrada
    @idParque        INT,
    @idTipoVisitante INT,
    @precio          DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE idParque = @idParque)
        SET @errores += '- El ID de parque especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errores += '- El ID del tipo de visitante especificado no existe.' + CHAR(10);

    IF @precio IS NULL OR @precio < 0
        SET @errores += '- El precio de la tarifa no puede ser nulo ni tomar valores negativos.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante)
        SET @errores += '- Error de catálogo: Ya existe una tarifa definida para ese Tipo de Visitante en el parque seleccionado.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Ventas.Entrada (idParque, idTipoVisitante, precio)
    VALUES (@idParque, @idTipoVisitante, @precio);

    SELECT SCOPE_IDENTITY() AS idEntradaNueva;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionEntrada
    @idEntrada       INT,
    @idParque        INT,
    @idTipoVisitante INT,
    @precio          DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idEntrada = @idEntrada)
        SET @errores += '- El ID del registro tarifario de entrada especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque WHERE idParque = @idParque)
        SET @errores += '- El ID de parque especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.TipoVisitante WHERE idTipoVisitante = @idTipoVisitante)
        SET @errores += '- El ID del tipo de visitante especificado no existe.' + CHAR(10);

    IF @precio IS NULL OR @precio < 0
        SET @errores += '- El precio de la tarifa es un campo obligatorio y no puede ser negativo.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idParque = @idParque AND idTipoVisitante = @idTipoVisitante AND idEntrada <> @idEntrada)
        SET @errores += '- Ya se encuentra registrado otro tarifario para esa combinación de parque y categoría.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Ventas.Entrada
    SET idParque = @idParque,
        idTipoVisitante = @idTipoVisitante,
        precio = @precio
    WHERE idEntrada = @idEntrada;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_EliminarEntrada
    @idEntrada INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idEntrada = @idEntrada)
        SET @errores += '- El ID de la tarifa a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.DetalleVenta WHERE idEntrada = @idEntrada)
        SET @errores += '- Restricción de Integridad: No es posible eliminar el ítem de tarifa debido a que existen comprobantes de venta emitidos asociados a este código.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.Entrada 
    WHERE idEntrada = @idEntrada;
    
    PRINT 'Tarifa de acceso removida correctamente del sistema.';
END;
GO

-- ==========================================================
-- TABLA Venta
-- ==========================================================

CREATE OR ALTER PROCEDURE Ventas.sp_AltaVenta
    @idVisitante INT,
    @formaPago   VARCHAR(50),
    @puntoVenta  VARCHAR(50),
    @total       DECIMAL(12,2) = 0.00
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
        SET @errores += '- El ID de visitante especificado no existe en el sistema.' + CHAR(10);

    IF @formaPago IS NULL OR LTRIM(RTRIM(@formaPago)) NOT IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Digital')
        SET @errores += '- La forma de pago ingresada no es válida. (Valores aceptados: Efectivo, Tarjeta, Transferencia, Digital).' + CHAR(10);

    IF @puntoVenta IS NULL OR LTRIM(RTRIM(@puntoVenta)) = ''
        SET @errores += '- El punto de venta/emisión del ticket es obligatorio.' + CHAR(10);

    IF @total IS NULL OR @total < 0
        SET @errores += '- El total de la venta no puede ser una magnitud negativa.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Ventas.Venta (idVisitante, fechaHora, formaPago, puntoVenta, total)
    VALUES (@idVisitante, GETDATE(), LTRIM(RTRIM(@formaPago)), LTRIM(RTRIM(@puntoVenta)), @total);

    SELECT SCOPE_IDENTITY() AS idVentaNueva;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionVenta
    @idVenta     INT,
    @idVisitante INT,
    @formaPago   VARCHAR(50),
    @puntoVenta  VARCHAR(50),
    @total       DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta)
        SET @errores += '- El ID del ticket de venta especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Visitante WHERE idVisitante = @idVisitante)
        SET @errores += '- El ID de visitante especificado no existe.' + CHAR(10);

    IF @formaPago IS NULL OR LTRIM(RTRIM(@formaPago)) NOT IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Digital')
        SET @errores += '- La forma de pago modificada no es válida. (Valores aceptados: Efectivo, Tarjeta, Transferencia, Digital).' + CHAR(10);

    IF @puntoVenta IS NULL OR LTRIM(RTRIM(@puntoVenta)) = ''
        SET @errores += '- El punto de venta es requerido.' + CHAR(10);

    IF @total IS NULL OR @total < 0
        SET @errores += '- El monto total no puede ser nulo ni negativo.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta AND estado = 'Anulada')
        SET @errores += '- No se puede modificar un ticket que ya fue anulado.' + CHAR(10);
        
    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Ventas.Venta
    SET idVisitante = @idVisitante,
        formaPago = LTRIM(RTRIM(@formaPago)),
        puntoVenta = LTRIM(RTRIM(@puntoVenta)),
        total = @total
    WHERE idVenta = @idVenta;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_EliminarVenta
    @idVenta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta)
        SET @errores += '- El ID de la venta a eliminar no existe.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM Ventas.DetalleVenta WHERE idVenta = @idVenta)
        SET @errores += '- Restricción de Integridad: No es posible eliminar la cabecera de la venta porque registra ítems facturados (DetalleVenta) asociados.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.Venta 
    WHERE idVenta = @idVenta;
    
    PRINT 'Ticket de venta removido de forma física correctamente.';
END;
GO


-- ==========================================================
-- TABLA DetalleVenta
-- ==========================================================
CREATE OR ALTER PROCEDURE Ventas.sp_AltaDetalleVenta
    @idVenta         INT,
    @idEntrada       INT,
    @cantidad        INT,
    @precioUnitario  DECIMAL(12,2),
    @fechaAcceso     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta)
        SET @errores += '- El ID del ticket de venta especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idEntrada = @idEntrada)
        SET @errores += '- El ID del registro tarifario de entrada especificado no existe.' + CHAR(10);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @errores += '- La cantidad de entradas por ítem debe ser estrictamente mayor a cero.' + CHAR(10);

    IF @precioUnitario IS NULL OR @precioUnitario < 0
        SET @errores += '- El precio unitario del renglón no puede tomar valores negativos.' + CHAR(10);

    IF @fechaAcceso IS NULL
        SET @errores += '- La fecha planificada de acceso al parque es un dato obligatorio.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Ventas.DetalleVenta (idVenta, idEntrada, cantidad, precio, fechaAcceso)
    VALUES (@idVenta, @idEntrada, @cantidad, @precioUnitario, @fechaAcceso);

    SELECT SCOPE_IDENTITY() AS idDetalleVentaNuevo;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_ModificacionDetalleVenta
    @idDetalleVenta INT,
    @idVenta        INT,
    @idEntrada      INT,
    @cantidad       INT,
    @precioUnitario  DECIMAL(12,2),
    @fechaAcceso     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.DetalleVenta WHERE idDetalleVenta = @idDetalleVenta)
        SET @errores += '- El ID del renglón de detalle especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta WHERE idVenta = @idVenta)
        SET @errores += '- El ID del ticket de venta Bird especificado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM Ventas.Entrada WHERE idEntrada = @idEntrada)
        SET @errores += '- El ID de la tarifa especificada no existe.' + CHAR(10);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @errores += '- La cantidad modificada debe ser mayor a cero.' + CHAR(10);

    IF @precioUnitario IS NULL OR @precioUnitario < 0
        SET @errores += '- El precio unitario modificado no puede ser nulo ni negativo.' + CHAR(10);

    IF @fechaAcceso IS NULL
        SET @errores += '- La fecha modificada de acceso al parque no puede ser nula.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Ventas.DetalleVenta
    SET idVenta = @idVenta,
        idEntrada = @idEntrada,
        cantidad = @cantidad,
        precio = @precioUnitario,
        fechaAcceso = @fechaAcceso
    WHERE idDetalleVenta = @idDetalleVenta;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.sp_EliminarDetalleVenta
    @idDetalleVenta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.DetalleVenta WHERE idDetalleVenta = @idDetalleVenta)
        SET @errores += '- El ID del detalle de venta a eliminar no existe.' + CHAR(10);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    DELETE FROM Ventas.DetalleVenta 
    WHERE idDetalleVenta = @idDetalleVenta;
    
    PRINT 'Renglón de la venta eliminado correctamente.';
END;
GO