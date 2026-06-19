-- ============================================================
-- Fecha: 2025-06-12
-- Descripción: Creación de la logica para la importacion
--              masiva de datos.
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
-- ============================================================
-- IMPORTACION Parques
-- https://ri.conicet.gov.ar/handle/11336/284755?show=full
-- FORMATO: .txt
-- ============================================================
USE ParquesNacionales
GO

DROP TABLE IF EXISTS Importacion.AreasProtegidas;
CREATE TABLE Importacion.AreasProtegidas (
    idArea     INT,
    nombre     VARCHAR(100),
    superficie DECIMAL(10,3),
    pais       VARCHAR(100),
    subnaciona VARCHAR(100),
    tipo       VARCHAR(100),
    nivelGobi  VARCHAR(100),
    gestion    VARCHAR(100),
    creacion   INT,
    legal      VARCHAR(255),
    ecoregion  VARCHAR(100)
)

CREATE OR ALTER PROCEDURE Importacion.sp_ImportarParques
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON

    TRUNCATE TABLE Importacion.AreasProtegidas

    DECLARE @sql NVARCHAR(2000) =
        N'INSERT INTO Importacion.AreasProtegidas (idArea, nombre, superficie, pais, subnaciona, tipo, nivelGobi, gestion, creacion, legal, ecoregion)
        SELECT idArea, nombre, superficie, pais, subnaciona, tipo, nivelGobi, gestion, creacion, legal, ecoregion
        FROM OPENROWSET(
            BULK ''' + @rutaArchivo + N''', SINGLE_CLOB) AS archJson
        CROSS APPLY OPENJSON(archJson.BulkColumn, ''$.features'')
        WITH (
            idArea     INT           ''$.properties.ID'',
            nombre     VARCHAR(100)  ''$.properties.NOMBRE'',
            superficie DECIMAL(10,3) ''$.properties.SUPERFICIE'',
            pais       VARCHAR(100)  ''$.properties.PAIS'',
            subnaciona VARCHAR(100)  ''$.properties.SUBNACIONA'',
            tipo       VARCHAR(100)  ''$.properties.TIPO'',
            nivelGobi  VARCHAR(100)  ''$.properties.NIVEL_GOBI'',
            gestion    VARCHAR(100)  ''$.properties.GESTION'',
            creacion   INT           ''$.properties.CREACION'',
            legal      VARCHAR(255)  ''$.properties.LEGAL'',
            ecoregion  VARCHAR(100)  ''$.properties.ECOREGION''
        )'
    
    BEGIN TRY
        EXEC sp_executesql @sql
    END TRY

    BEGIN CATCH
        DECLARE @errorMessage NVARCHAR(1000) = ERROR_MESSAGE()
        RAISERROR('Error al cargar el archivo de visitas %s : %s', 16, 1, @rutaArchivo, @errorMessage)
        RETURN
    END CATCH

    IF NOT EXISTS (
        SELECT 1 FROM Importacion.Visitas
    )
    BEGIN
        RAISERROR('El archivo no contiene datos o la ruta es incorrecta', 16, 1)
        RETURN
    END


    DECLARE @idArea     INT,
            @nombre     VARCHAR(100),
            @superficie DECIMAL(10,3),
            @pais       VARCHAR(100),
            @subnaciona VARCHAR(100),
            @tipo       VARCHAR(100),
            @nivelGobi  VARCHAR(100),
            @gestion    VARCHAR(100),
            @creacion   INT,
            @legal      VARCHAR(255),
            @ecoregion  VARCHAR(100),
            @errFila    NVARCHAR(500),
            @okCont     INT = 0,
            @errCont    INT = 0,
            @errTxt     NVARCHAR(MAX) = '',
            @idTipoParque INT

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            idArea,
            TRIM(nombre),
            superficie,
            TRIM(pais),
            TRIM(subnaciona),
            TRIM(tipo),
            TRIM(nivelGobi),
            TRIM(gestion),
            creacion,
            TRIM(legal),
            TRIM(ecoregion)
        FROM Importacion.AreasProtegidas
    
    OPEN cur
    FETCH NEXT FROM cur INTO
        @idArea, @nombre, @superficie, @pais, @subnaciona, @tipo, @nivelGobi, @gestion, @creacion, @legal, @ecoregion

    WHILE @@FETCH_STATUS = 0
    BEGIN   SET @errFila = ''

    IF @nombre IS NULL
        SET @errFila += 'nombre vacio ("' + @idArea + '"). '

    IF @superficie <= 0
        SET @errFila += 'superficie no valida ("' + @superficie + '"). '

    IF @pais IS NULL
        SET @errFila += 'pais vacio ("' + @idArea + '"). '

    IF @tipo IS NULL
        SET @errFila += 'tipo vacio ("' + @idArea + '"). '

    IF @nivelGobi NOT IN ('PRIMER ORDEN', 'SEGUNDO ORDEN', 'TERCER ORDEN', 'INTERNACIONAL')
        SET @errFila += 'nivelGobi no valido ("' + @nivelGobi + '"). '

    IF @gestion IS NULL
        SET @errFila += 'gestion vacia ("' + @idArea + '"). '
    
    IF @creacion <= 0
        SET @errFila += 'creacion no valida ("' + @creacion + '"). '

    IF @legal IS NULL
        SET @errFila += 'legal vacio ("' + @idArea + '"). '

    IF @ecoregion IS NULL
        SET @errFila += 'ecoregion vacia ("' + @idArea + '"). '

    IF @errFila <> ''
    BEGIN
        SET @errTxt = @errTxt + CHAR(10) + N' [' + CAST(@idArea AS NVARCHAR(10)) + N']: ' + @errFila;
        SET @errCont += 1;
    END
    ELSE
    BEGIN
-- UPSERT TipoParque
    IF EXISTS (
        SELECT 1 FROM Parques.TipoParque
        WHERE nombre = @tipo
    )
        SELECT @idTipoParque = idTipoParque
        FROM Parques.TipoParque
        WHERE nombre = @tipo

    ELSE
        BEGIN
            EXEC Parques.sp_AltaTipoParque
                @tipo, ''

            SELECT @idTipoParque = idTipoParque
            FROM Parques.TipoParque
            WHERE nombre = @tipo
        END
    
-- UPSERT Parque
    IF EXISTS (
        SELECT 1 FROM Parques.Parque
        WHERE nombre = @nombre
    )
        BEGIN
            SELECT @idArea = idParque
            FROM Parques.Parque
            WHERE nombre = @nombre

            EXEC Parques.sp_ModificacionParque
                @idArea, @idTipoParque, @nombre, @ecoregion, @subnaciona, @superficie
        END

    ELSE
        BEGIN
            EXEC Parques.sp_AltaParque
                @idTipoParque, @nombre, @ecoregion, @subnaciona, @superficie
        END
    
    SET @okCont += 1

    END

    SigFila:
    FETCH NEXT FROM cur INTO
        @idArea, @nombre, @superficie, @pais, @subnaciona, @tipo, @nivelGobi, @gestion, @creacion, @legal, @ecoregion
END

CLOSE cur
DEALLOCATE cur
        
SELECT
    @rutaArchivo AS archivo,
    @okCont AS filasImportadas,
    @errCont AS filasConError

IF @errCont > 0
    PRINT 'Errores encontrados: ' + @errTxt

END
GO


-- ============================================================
-- IMPORTACION Visitas segun tipo visitante
-- https://datos.yvera.gob.ar/dataset/parques-nacionales/archivo/a570af75-ed33-427c-9797-980fc0cd8fd1
-- FORMATO: .csv
-- ============================================================
USE ParquesNacionales
GO

DROP TABLE IF EXISTS Importacion.VisitasParquesNacionales
CREATE TABLE Importacion.VisitasParquesNacionales (
    indiceTiempo     VARCHAR(30),
    origenVisitantes VARCHAR(30),
    visitas          INT,
    observaciones    VARCHAR(300)
    CONSTRAINT PK_Visitas PRIMARY KEY (indiceTiempo, origenVisitantes)
)
GO

DROP TABLE IF EXISTS Importacion.Visitas
CREATE TABLE Importacion.Visitas (
    indiceTiempo     VARCHAR(100),
    origenVisitantes VARCHAR(100),
    visitas          VARCHAR(100),
    observaciones    VARCHAR(300)
)
GO


CREATE OR ALTER PROCEDURE Importacion.sp_ImportarVisitas
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON

    TRUNCATE TABLE Importacion.Visitas

    DECLARE @sql NVARCHAR(2000) =
        N'BULK INSERT Importacion.Visitas FROM ''' + @rutaArchivo + N'''
            WITH (FIRSTROW = 2,
                  FIELDTERMINATOR = '','',
                  ROWTERMINATOR = ''0x0a'',
                  CODEPAGE = ''RAW'',
                  TABLOCK)'
    BEGIN TRY
        EXEC sp_executesql @sql
    END TRY

    BEGIN CATCH
        DECLARE @errorMessage NVARCHAR(1000) = ERROR_MESSAGE()
        RAISERROR('Error al cargar el archivo de visitas %s : %s', 16, 1, @rutaArchivo, @errorMessage)
        RETURN
    END CATCH

    IF NOT EXISTS (
        SELECT 1 FROM Importacion.Visitas
    )
    BEGIN
        RAISERROR('El archivo no contiene datos o la ruta es incorrecta', 16, 1)
        RETURN
    END


    DECLARE @indiceTiempo  NVARCHAR(20),
            @origen        NVARCHAR(20),
            @visitasStr    NVARCHAR(20),
            @observaciones NVARCHAR(100),
            @visitasInt    INT,
            @errFila       NVARCHAR(500),
            @okCont        INT = 0,
            @errCont       INT = 0,
            @errTxt        NVARCHAR(MAX) = ''

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            TRIM(indiceTiempo),
            TRIM(origenVisitantes),
            TRIM(visitas),
            TRIM(observaciones)
        FROM Importacion.Visitas
    
    OPEN cur
    FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones

    WHILE @@FETCH_STATUS = 0
    BEGIN   SET @errFila = ''

    IF ISDATE(@indiceTiempo) = 0
        SET @errFila += 'indiceTiempo invalido ("' + @indiceTiempo + '"). '
    
    IF @origen NOT IN ('residentes', 'no residentes', 'total')
        SET @errFila += 'origen invalido ("' + @origen + '"). '
    
    SET @visitasInt = TRY_CAST(@visitasStr AS INT)
    IF @visitasStr <> '' AND @visitasInt IS NULL
        SET @errFila += 'visitas no contiene valor ("' + @visitasStr + '"). '

    IF @errFila <> ''
    BEGIN
        SET @errTxt += CHAR(10) +
            ' [' + @indiceTiempo + ' | ' + @origen + ']: ' + @errFila
        SET @errCont += 1
        GOTO SigFila
    END

    IF EXISTS (
        SELECT 1 FROM Importacion.VisitasParquesNacionales
        WHERE indiceTiempo = @indiceTiempo
        AND origenVisitantes = @origen
    )
        UPDATE Importacion.VisitasParquesNacionales
        SET visitas = @visitasInt,
            observaciones = @observaciones
        WHERE indiceTiempo = @indiceTiempo
            AND origenVisitantes = @origen

    ELSE
        INSERT INTO Importacion.VisitasParquesNacionales
            (indiceTiempo, origenVisitantes, visitas, observaciones)
        VALUES
            (@indiceTiempo, @origen, @visitasInt, @observaciones)
    
    SET @okCont += 1

    SigFila:
    FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones
END

CLOSE cur
DEALLOCATE cur
        
SELECT
    @rutaArchivo AS archivo,
    @okCont AS filasImportadas,
    @errCont AS filasConError

IF @errCont > 0
    PRINT 'Errores encontrados: ' + @errTxt

END
GO


-- ============================================================
-- IMPORTACION Guias
-- https://data.buenosaires.gob.ar/dataset/registro-guias-turismo/resource/juqdkmgo-1791-resource
-- FORMATO: .csv
-- ============================================================
USE ParquesNacionales
GO

DROP TABLE IF EXISTS Importacion.GuiasTurismo
CREATE TABLE Importacion.GuiasTurismo (
    periodo    VARCHAR(100),
    apellido   VARCHAR(100),
    nombre     VARCHAR(100),
    tipoDoc    VARCHAR(100),
    numero     VARCHAR(100),
    nRegistro  VARCHAR(100),
    categoria  VARCHAR(100)
)
GO

CREATE OR ALTER PROCEDURE Importacion.sp_ImportarGuias
    @rutaArchivo VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON

    TRUNCATE TABLE Importacion.GuiasTurismo

    DECLARE @sql NVARCHAR(2000) =
        N'BULK INSERT Importacion.GuiasTurismo FROM ''' + @rutaArchivo + N'''
            WITH (FIRSTROW = 2,
                  FIELDTERMINATOR = '';'',
                  ROWTERMINATOR = ''\n'',
                  CODEPAGE = ''ACP''
                  )'
    BEGIN TRY
        EXEC sp_executesql @sql
    END TRY

    BEGIN CATCH
        DECLARE @errorMessage VARCHAR(1000) = ERROR_MESSAGE()
        RAISERROR('Error al cargar el archivo de visitas %s : %s', 16, 1, @rutaArchivo, @errorMessage)
        RETURN
    END CATCH

    IF NOT EXISTS (
        SELECT 1 FROM Importacion.GuiasTurismo
    )
    BEGIN
        RAISERROR('El archivo no contiene datos o la ruta es incorrecta', 16, 1)
        RETURN
    END


    DECLARE @periodoStr   VARCHAR(50),
            @apellido     VARCHAR(50),
            @nombre       VARCHAR(50),
            @tipoDoc      VARCHAR(50),
            @numeroDoc    VARCHAR(50),
            @nRegistro    VARCHAR(50),
            @categoria    VARCHAR(50),
            @periodoInt   INT,
            @errFila      VARCHAR(500),
            @okCont       INT = 0,
            @errCont      INT = 0,
            @errTxt       VARCHAR(MAX) = '',
            @idGuia       INT,
            @fechaNac     DATE,
            @email        VARCHAR(150),
            @vigAut       DATE,
            @emailDin     VARCHAR(150)

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            TRIM(periodo),
            TRIM(apellido),
            TRIM(nombre),
            TRIM(tipoDoc),
            TRIM(numero),
            TRIM(nRegistro),
            TRIM(categoria)
        FROM Importacion.GuiasTurismo
    
    OPEN cur
    FETCH NEXT FROM cur INTO @periodoStr, @apellido, @nombre, @tipoDoc, @numeroDoc, @nRegistro, @categoria

    WHILE @@FETCH_STATUS = 0
    BEGIN   SET @errFila = ''

    IF @periodoStr NOT LIKE '[0-9][0-9][0-9][0-9]'
        SET @errFila += 'periodo invalido ("' + @periodoStr + '"). '
    
    IF @apellido IS NULL
        SET @errFila += 'apellido vacio ("' + @apellido + '"). '

    IF @nombre IS NULL
        SET @errFila += 'nombre vacio ("' + @nombre + '"). '

    IF @tipoDoc IS NULL
        SET @errFila += 'tipoDocumento vacio ("' + @tipoDoc + '"). '

    IF ISNUMERIC(@numeroDoc) = 0 OR @numeroDoc IS NULL OR TRIM(@numeroDoc) = ''
        SET @errFila += 'numeroDocumento invalido ("' + @numeroDoc + '"). '

    IF @nRegistro IS NULL
        SET @errFila += 'nRegistro vacio ("' + @nRegistro + '"). '

    IF @categoria IS NULL
        SET @errFila += 'categoria vacia ("' + @categoria + '"). '

    IF @errFila <> ''
    BEGIN
        SET @errTxt += CHAR(10) +
            ' [' + @tipoDoc + ' | ' + @numeroDoc + ']: ' + @errFila
        SET @errCont += 1
        GOTO SigFila
    END

    SET @periodoInt = CAST(@periodoStr AS INT)

    IF EXISTS (
        SELECT 1 FROM Guias.Guia
        WHERE tipoDocumento = @tipoDoc
        AND nroDocumento = @numeroDoc
    )
        BEGIN
            SELECT @idGuia = idGuia, @fechaNac = fechaNacimiento, @email = email, @vigAut = vigenciaAutorizacion
            FROM Guias.Guia
            WHERE tipoDocumento = @tipoDoc
            AND nroDocumento = @numeroDoc

            EXEC Guias.sp_ModificacionGuia
                @idGuia, @nombre, @apellido, @fechaNac, @tipoDoc, @numeroDoc, @email, @vigAut
        END

    ELSE
        BEGIN
            SET @emailDin = CONCAT(TRIM(@nombre), TRIM(@numeroDoc), '@gmail.com')

            EXEC Guias.sp_AltaGuia
                @nombre, @apellido, '2000-01-01', @tipoDoc, @numeroDoc, @emailDin, '2030-01-01'
        END
    
    SET @okCont += 1

    SigFila:
    FETCH NEXT FROM cur INTO @periodoStr, @apellido, @nombre, @tipoDoc, @numeroDoc, @nRegistro, @categoria
END

CLOSE cur
DEALLOCATE cur
        
SELECT
    @rutaArchivo AS archivo,
    @okCont AS filasImportadas,
    @errCont AS filasConError

IF @errCont > 0
    PRINT 'Errores encontrados: ' + @errTxt

END
GO