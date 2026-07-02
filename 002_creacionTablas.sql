-- ============================================================
-- Fecha: 2025-06-12
-- Descripción: Creación de todas las tablas con sus PKs, FKs,
--              checks y restricciones de integridad.
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

-- ==========================================================
-- ESQUEMA Parques
-- ==========================================================

CREATE TABLE Parques.TipoParque (
    idTipoParque INT          IDENTITY(1,1),
    nombre       VARCHAR(100)  NOT NULL,
    descripcion  VARCHAR(100) NULL,

    CONSTRAINT PK_TipoParque PRIMARY KEY (idTipoParque),
    CONSTRAINT UQ_TipoParque_Nombre UNIQUE (nombre)
);
GO

CREATE TABLE Parques.Parque (
    idParque     INT           IDENTITY(1,1),
    idTipoParque INT           NOT NULL,
    nombre       VARCHAR(100)   NOT NULL,
    region    VARCHAR(50)   NOT NULL,
    provincia    VARCHAR(30)   NOT NULL,
    superficie   DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Parque PRIMARY KEY (idParque),
    CONSTRAINT FK_Parque_TipoParque FOREIGN KEY (idTipoParque)
        REFERENCES Parques.TipoParque (idTipoParque),
    CONSTRAINT CK_Parque_Superficie CHECK (superficie > 0)
);
GO

-- ==========================================================
-- ESQUEMA Personal
-- ==========================================================

CREATE TABLE Personal.Guardaparque (
    idGuardaparque   INT          IDENTITY(1,1),
    nombre           VARCHAR(50)  NOT NULL,
    apellido         VARCHAR(50)  NOT NULL,
    fechaNacimiento  DATE         NOT NULL,
    tipoDocumento    VARCHAR(20)  NOT NULL,
    nroDocumento     VARCHAR(20)  NOT NULL,
    email            VARCHAR(150) NOT NULL,
    fechaIngresoCargo DATE        NOT NULL,
    fechaEgresoCargo  DATE        NULL,
    motivoEgreso     VARCHAR(300) NULL,
    estaActivo       BIT          NOT NULL DEFAULT 1,

    CONSTRAINT PK_Guardaparque PRIMARY KEY (idGuardaparque),
    CONSTRAINT UQ_Guardaparque_Documento UNIQUE (tipoDocumento, nroDocumento),
    CONSTRAINT UQ_Guardaparque_Email UNIQUE (email),
    CONSTRAINT CK_Guardaparque_Fechas CHECK (
        fechaEgresoCargo IS NULL OR fechaEgresoCargo >= fechaIngresoCargo
    ),
);
GO

CREATE TABLE Personal.HistorialGuardaparque (
    idHistorial     INT  IDENTITY(1,1),
    idParque        INT  NOT NULL,
    idGuardaparque  INT  NOT NULL,
    fechaIngreso    DATE NOT NULL,
    fechaEgreso     DATE NULL,

    CONSTRAINT PK_HistorialGuardaparque PRIMARY KEY (idHistorial),
    CONSTRAINT FK_HistGP_Parque FOREIGN KEY (idParque)
        REFERENCES Parques.Parque (idParque),
    CONSTRAINT FK_HistGP_Guardaparque FOREIGN KEY (idGuardaparque)
        REFERENCES Personal.Guardaparque (idGuardaparque),
    CONSTRAINT CK_HistGP_Fechas CHECK (
        fechaEgreso IS NULL OR fechaEgreso >= fechaIngreso
    )
);
GO

-- ==========================================================
-- ESQUEMA Guias
-- ==========================================================

CREATE TABLE Guias.Habilitacion (
    idHabilitacion   INT          IDENTITY(1,1),
    nombre           VARCHAR(50)  NOT NULL,
    fechaEmision     DATE         NOT NULL,
    fechaVencimiento DATE         NOT NULL,

    CONSTRAINT PK_Habilitacion PRIMARY KEY (idHabilitacion),
    CONSTRAINT CK_Habilitacion_Fechas CHECK (fechaVencimiento > fechaEmision)
);
GO

CREATE TABLE Guias.Titulo (
    idTitulo     INT          IDENTITY(1,1),
    nombre       VARCHAR(50)  NOT NULL,
    fechaEmision DATE         NOT NULL,

    CONSTRAINT PK_Titulo PRIMARY KEY (idTitulo)
);
GO

CREATE TABLE Guias.Guia (
    idGuia               INT          IDENTITY(1,1),
    nombre               VARCHAR(50)  NOT NULL,
    apellido             VARCHAR(50)  NOT NULL,
    fechaNacimiento      DATE         NOT NULL,
    tipoDocumento        VARCHAR(20)  NOT NULL,
    nroDocumento         VARCHAR(20)  NOT NULL,
    email                VARCHAR(150) NOT NULL,
    vigenciaAutorizacion DATE         NOT NULL,
    estaActivo           BIT

    CONSTRAINT PK_Guia PRIMARY KEY (idGuia),
    CONSTRAINT UQ_Guia_Documento UNIQUE (tipoDocumento, nroDocumento),
    CONSTRAINT UQ_Guia_Email UNIQUE (email),
);
GO

CREATE TABLE Guias.GuiaHabilitacion (
    idGuia         INT NOT NULL,
    idHabilitacion INT NOT NULL,

    CONSTRAINT PK_GuiaHabilitacion PRIMARY KEY (idGuia, idHabilitacion),
    CONSTRAINT FK_GH_Guia FOREIGN KEY (idGuia)
        REFERENCES Guias.Guia (idGuia),
    CONSTRAINT FK_GH_Habilitacion FOREIGN KEY (idHabilitacion)
        REFERENCES Guias.Habilitacion (idHabilitacion)
);
GO

CREATE TABLE Guias.GuiaTitulo (
    idGuia   INT NOT NULL,
    idTitulo INT NOT NULL,

    CONSTRAINT PK_GuiaTitulo PRIMARY KEY (idGuia, idTitulo),
    CONSTRAINT FK_GT_Guia FOREIGN KEY (idGuia)
        REFERENCES Guias.Guia (idGuia),
    CONSTRAINT FK_GT_Titulo FOREIGN KEY (idTitulo)
        REFERENCES Guias.Titulo (idTitulo)
);
GO

-- ==========================================================
-- ESQUEMA Actividades
-- ==========================================================

CREATE TABLE Actividades.TipoActividadTuristica (
    idTipoActividadTuristica INT          IDENTITY(1,1),
    descripcion              VARCHAR(300) NOT NULL,

    CONSTRAINT PK_TipoActTur PRIMARY KEY (idTipoActividadTuristica)
);
GO

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

-- ==========================================================
-- ESQUEMA Concesiones
--==========================================================

CREATE TABLE Concesiones.TipoActividadConcesion (
    idTipoActividadConcesion INT          IDENTITY(1,1),
    nombre                   VARCHAR(100) NOT NULL,
    descripcionActividad     VARCHAR(200) NULL,

    CONSTRAINT PK_TipoActConcesion PRIMARY KEY (idTipoActividadConcesion)
);
GO

CREATE TABLE Concesiones.EmpresaConcesionaria (
    idEmpresaConcesionaria INT          IDENTITY(1,1),
    cuit                   CHAR(11)     NOT NULL,
    razonSocial            VARCHAR(100) NOT NULL,
    contacto               VARCHAR(200) NULL,

    CONSTRAINT PK_EmpresaConcesionaria PRIMARY KEY (idEmpresaConcesionaria),
    CONSTRAINT UQ_Empresa_Cuit UNIQUE (cuit)
);
GO

CREATE TABLE Concesiones.Concesion (
    idConcesion              INT           IDENTITY(1,1),
    idEmpresaConcesionaria   INT           NOT NULL,
    idTipoActividadConcesion INT           NOT NULL,
    idParque                 INT           NOT NULL,
    fechaInicio              DATE          NOT NULL,
    fechaFin                 DATE          NOT NULL,
    montoAlquiler            DECIMAL(12,2) NOT NULL,
    estado                   VARCHAR(20)   NOT NULL DEFAULT 'Activa',

    CONSTRAINT PK_Concesion PRIMARY KEY (idConcesion),
    CONSTRAINT FK_Con_Empresa FOREIGN KEY (idEmpresaConcesionaria)
        REFERENCES Concesiones.EmpresaConcesionaria (idEmpresaConcesionaria),
    CONSTRAINT FK_Con_TipoAct FOREIGN KEY (idTipoActividadConcesion)
        REFERENCES Concesiones.TipoActividadConcesion (idTipoActividadConcesion),
    CONSTRAINT FK_Con_Parque FOREIGN KEY (idParque)
        REFERENCES Parques.Parque (idParque),
    CONSTRAINT CK_Con_Fechas CHECK (fechaFin > fechaInicio),
    CONSTRAINT CK_Con_Monto CHECK (montoAlquiler > 0),
    CONSTRAINT CK_Con_Estado CHECK (estado IN ('Activa','Vencida','Cancelada'))
);
GO

CREATE TABLE Concesiones.PagoCanon (
    idPagoCanon      INT           IDENTITY(1,1),
    idConcesion      INT           NOT NULL,
    fechaPago        DATE          NOT NULL,
    monto            DECIMAL(12,2) NOT NULL,
    fechaVencimiento DATE          NOT NULL,
    fechaEmision     DATE          NOT NULL,

    CONSTRAINT PK_PagoCanon PRIMARY KEY (idPagoCanon),
    CONSTRAINT FK_PC_Concesion FOREIGN KEY (idConcesion)
        REFERENCES Concesiones.Concesion (idConcesion),
    CONSTRAINT CK_PC_Monto CHECK (monto > 0)
);
GO

-- ==========================================================
-- ESQUEMA Ventas
-- ==========================================================

CREATE TABLE Ventas.TipoVisitante (
    idTipoVisitante INT          IDENTITY(1,1),
    nombre          VARCHAR(100) NOT NULL,
    descripcion     VARCHAR(300) NULL,

    CONSTRAINT PK_TipoVisitante PRIMARY KEY (idTipoVisitante)
);
GO

CREATE TABLE Ventas.Visitante (
    idVisitante INT          IDENTITY(1,1),
    nombre      VARCHAR(50)  NOT NULL,
    apellido    VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NULL,
    direccion   VARCHAR(100) NULL,
    telefono    VARCHAR(20)  NULL,

    CONSTRAINT PK_Visitante PRIMARY KEY (idVisitante)
);
GO

CREATE TABLE Ventas.Venta (
    idVenta     INT          IDENTITY(1,1),
    idVisitante INT          NOT NULL,
    fechaHora   DATETIME     NOT NULL DEFAULT GETDATE(),
    formaPago   VARCHAR(50)  NOT NULL,
    puntoVenta  VARCHAR(50)  NOT NULL,
    total       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    estado      VARCHAR(20)  NOT NULL DEFAULT 'Completada',

    CONSTRAINT PK_Venta PRIMARY KEY (idVenta),
    CONSTRAINT FK_Venta_Visitante FOREIGN KEY (idVisitante)
        REFERENCES Ventas.Visitante (idVisitante),
    CONSTRAINT CK_Venta_Total CHECK (total >= 0),
    CONSTRAINT CK_Venta_FormaPago CHECK (formaPago IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Digital')),
    CONSTRAINT CK_Venta_Estado CHECK (estado IN ('Completada', 'Anulada'))
);
GO

CREATE TABLE Ventas.Entrada (
    idEntrada       INT           IDENTITY(1,1),
    idParque        INT           NOT NULL,
    idTipoVisitante INT           NOT NULL,
    precio          DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Entrada PRIMARY KEY (idEntrada),
    CONSTRAINT FK_Entrada_Parque FOREIGN KEY (idParque)
        REFERENCES Parques.Parque (idParque),
    CONSTRAINT FK_Entrada_TipoVisitante FOREIGN KEY (idTipoVisitante)
        REFERENCES Ventas.TipoVisitante (idTipoVisitante),
    CONSTRAINT CK_Entrada_Precio CHECK (precio >= 0),
    
    CONSTRAINT UQ_Entrada_Parque_TipoVisitante UNIQUE (idParque, idTipoVisitante)
);
GO

CREATE TABLE Ventas.DetalleVenta (
    idDetalleVenta INT           IDENTITY(1,1),
    idVenta        INT           NOT NULL,
    idEntrada      INT           NOT NULL,
    cantidad       INT           NOT NULL,
    precio         DECIMAL(10,2) NOT NULL,
    fechaAcceso    DATE          NOT NULL,
    total          AS (cantidad * precio) PERSISTED,

    CONSTRAINT PK_DetalleVenta PRIMARY KEY (idDetalleVenta),
    CONSTRAINT FK_DV_Venta FOREIGN KEY (idVenta)
        REFERENCES Ventas.Venta (idVenta),
    CONSTRAINT FK_DV_Entrada FOREIGN KEY (idEntrada)
        REFERENCES Ventas.Entrada (idEntrada),
    CONSTRAINT CK_DV_Cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_DV_Precio CHECK (precio >= 0)
);
GO

-- ==========================================================
-- ESQUEMA Actividades
-- ==========================================================

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

-- ==========================================================
-- ESQUEMA Importacion
-- ==========================================================

CREATE TABLE Importacion.VisitasParquesNacionales (
    indiceTiempo     VARCHAR(30),
    origenVisitantes VARCHAR(30),
    visitas          INT,
    observaciones    VARCHAR(500)
    CONSTRAINT PK_Visitas PRIMARY KEY (indiceTiempo, origenVisitantes)
)
GO

-- ==========================================================
-- ESQUEMA Apis
-- ==========================================================

CREATE TABLE Apis.CotizacionDolar (
    fechaCotizacion    DATE PRIMARY KEY,
    valorCompra        DECIMAL(18,2),
    valorVenta         DECIMAL(18,2),
    fechaActualizacion DATETIME
)
GO

CREATE TABLE Apis.Feriados (
    fecha  DATE PRIMARY KEY,
    tipo   VARCHAR(100),
    nombre VARCHAR(250)
)
GO