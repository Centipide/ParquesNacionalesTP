-- ============================================================
-- Fecha: 2025-06-15
-- Descripción: Creación de todos los ABM
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

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarTipoActividadTuristica
    @descripcion VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';
    
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripcion no puede estar vacia.';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.TipoActividadTuristica(descripcion)
    VALUES (@descripcion);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificarTipoActividadTuristica
    @idTipoActividadTuristica INT,
	@descripcion              VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON 

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de tipo de actividad turistica no existe. ';

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


CREATE OR ALTER PROCEDURE Actividades.sp_EliminarTipoActividadTuristica
    @idTipoActividadTuristica INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de tipo de actividad turistica no existe. ';

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

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarActividadTuristica
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
        SET @errores = @errores + 'El id de Parque no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de Tipo Actividad turistica no existe. ';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre no puede estar vacio. ';

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo. ';

    IF @duracion <= 0
        SET @errores = @errores + 'La duracion debe ser mayor a 0. ';

    IF @cupoMaximo <= 0
        SET @errores = @errores + 'El cupo maximo debe ser mayor a 0. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.ActividadTuristica (idParque, idTipoActividadTuristica, nombre, costo, duracion, cupoMaximo)
    VALUES (@idParque, @idTipoActividadTuristica, @nombre, @costo, @duracion, @cupoMaximo);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificarActividadTuristica
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
        SET @errores = @errores + 'El id de Actividad Turistica no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Parques.Parque
                   WHERE idParque = @idParque)
        SET @errores = @errores + 'El id de Parque no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.TipoActividadTuristica
                   WHERE idTipoActividadTuristica = @idTipoActividadTuristica)
        SET @errores = @errores + 'El id de Tipo Actividad Turistica no existe. ';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre no puede estar vacio. ';

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo. ';

    IF @duracion <= 0
        SET @errores = @errores + 'La duracion debe ser mayor a 0. ';

    IF @cupoMaximo <= 0
        SET @errores = @errores + 'El cupo maximo debe ser mayor a 0. ';

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


CREATE OR ALTER PROCEDURE Actividades.sp_EliminarActividadTuristica
    @idActividadTuristica INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe. ';

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

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarGuiaAutorizacion 
    @idGuia                 INT,
    @idActividadTuristica   INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia
                   WHERE idGuia = @idGuia)
        SET @errores = @errores + 'El id de Guia no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe. ';

    IF EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
               WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia ya esta autorizado para esta actividad. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.GuiaAutorizacion (idGuia, idActividadTuristica)
    VALUES (@idGuia, @idActividadTuristica);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_EliminarGuiaAutorizacion
    @idGuia                 INT,
    @idActividadTuristica   INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'No existe una autorizacion para ese guia y actividad. ';

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

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarActividadProgramada
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
        SET @errores = @errores + 'El id de Guia no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia
                     AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia no esta autorizado para realizar esta actividad. ';

    IF @fecha IS NULL
        SET @errores = @errores + 'La fecha no puede estar vacia. ';

    IF @horaInicio IS NULL
        SET @errores = @errores + 'La hora de inicio no puede estar vacia. ';

    IF EXISTS (SELECT 1
               FROM Actividades.ActividadProgramada
               WHERE idGuia = @idGuia
                 AND idActividadTuristica = @idActividadTuristica
                 AND fecha = @fecha
                 AND horaInicio = @horaInicio)
        SET @errores = @errores + 'Ya existe una actividad programada con esos datos. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.ActividadProgramada (idGuia, idActividadTuristica, fecha, horaInicio, observaciones)
    VALUES (@idGuia, @idActividadTuristica, @fecha, @horaInicio, @observaciones);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificarActividadProgramada
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
        SET @errores = @errores + 'El id de Actividad Programada no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Guias.Guia
                   WHERE idGuia = @idGuia)
        SET @errores = @errores + 'El id de Guia no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadTuristica
                   WHERE idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El id de Actividad Turistica no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.GuiaAutorizacion
                   WHERE idGuia = @idGuia
                     AND idActividadTuristica = @idActividadTuristica)
        SET @errores = @errores + 'El guia no esta autorizado para realizar esta actividad. ';

    IF @fecha IS NULL
        SET @errores = @errores + 'La fecha no puede estar vacia. ';

    IF @horaInicio IS NULL
        SET @errores = @errores + 'La hora de inicio no puede estar vacia. ';

    IF @estado NOT IN ('Programada', 'Realizada', 'Cancelada')
        SET @errores = @errores + 'El estado debe ser Programada, Realizada o Cancelada. ';

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

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarDetalleContratacion
    @idVenta    INT,
    @costoTotal DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta
                   WHERE idVenta = @idVenta)
        SET @errores = @errores + 'El id de Venta no existe. ';

    IF @costoTotal < 0
        SET @errores = @errores + 'El costo total no puede ser negativo. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    INSERT INTO Actividades.DetalleContratacion (idVenta, costoTotal)
    VALUES (@idVenta, @costoTotal);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificarDetalleContratacion
    @idDetalleContratacion INT,
    @idVenta               INT,
    @costoTotal            DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Ventas.Venta
                   WHERE idVenta = @idVenta)
        SET @errores = @errores + 'El id de Venta no existe. ';

    IF @costoTotal < 0
        SET @errores = @errores + 'El costo total no puede ser negativo. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END

    UPDATE Actividades.DetalleContratacion
    SET    idVenta    = @idVenta,
           costoTotal = @costoTotal
    WHERE  idDetalleContratacion = @idDetalleContratacion;
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_EliminarDetalleContratacion
    @idDetalleContratacion INT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errores VARCHAR(500) = '';

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe. ';

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
        estado IN ('Pendiente','Confirmada','Cancelada','Completada')
    )
);
GO

*/

CREATE OR ALTER PROCEDURE Actividades.sp_RegistrarContratacion
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
        SET @errores = @errores + 'El id de Detalle Contratacion no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadProgramada
                   WHERE idActividadProgramada = @idActividadProgramada)
        SET @errores = @errores + 'El id de Actividad Programada no existe. ';

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo. ';

    IF @cantidadPersonas <= 0
        SET @errores = @errores + 'La cantidad de personas debe ser mayor a 0. ';

    IF @estado IS NULL
       OR @estado NOT IN ('Confirmada', 'Cancelada', 'Completada')
        SET @errores = @errores + 'El estado debe ser Confirmada, Cancelada o Completada. ';

    IF @errores != ''
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END

    INSERT INTO Actividades.Contratacion (idDetalleContratacion, idActividadProgramada, costo, estado, cantidadPersonas)
    VALUES (@idDetalleContratacion, @idActividadProgramada, @costo, @estado, @cantidadPersonas);
END
GO


CREATE OR ALTER PROCEDURE Actividades.sp_ModificarContratacion
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
        SET @errores = @errores + 'El id de Contratacion no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.DetalleContratacion
                   WHERE idDetalleContratacion = @idDetalleContratacion)
        SET @errores = @errores + 'El id de Detalle Contratacion no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Actividades.ActividadProgramada
                   WHERE idActividadProgramada = @idActividadProgramada)
        SET @errores = @errores + 'El id de Actividad Programada no existe. ';

    IF @costo < 0
        SET @errores = @errores + 'El costo no puede ser negativo. ';

    IF @cantidadPersonas <= 0
        SET @errores = @errores + 'La cantidad de personas debe ser mayor a 0. ';

    IF @estado IS NULL
       OR @estado NOT IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada')
        SET @errores = @errores + 'El estado debe ser Pendiente, Confirmada, Cancelada o Completada. ';

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