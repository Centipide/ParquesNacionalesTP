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

-- ============================================================
-- IMPORTACION Parques
-- https://ri.conicet.gov.ar/handle/11336/284755?show=full
-- FORMATO: .txt (Pero con formato .json)
-- RUTA: C:\Datasets\af_ha007__rea_protegida_argentina_geojson.txt
-- ============================================================
USE ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Importacion.sp_ImportarParques

AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #AreasProtegidas (
        idArea     INT,
        nombre     VARCHAR(100),
        superficie DECIMAL(10,3),
        pais       VARCHAR(100),
        subnaciona VARCHAR(100),
        tipo       VARCHAR(100),
        nivelGobi  VARCHAR(100),
        gestion    VARCHAR(100),
        creacion   VARCHAR(10),
        legal      VARCHAR(255),
        ecoregion  VARCHAR(100)
    )
    
    INSERT INTO #AreasProtegidas (idArea, nombre, superficie, pais, subnaciona,
                                tipo, nivelGobi, gestion, creacion, legal, ecoregion)
        SELECT idArea, nombre, superficie, pais,
                subnaciona, tipo, nivelGobi, gestion, creacion, legal, ecoregion
        FROM OPENROWSET(
            BULK 'C:\Datasets\af_ha007__rea_protegida_argentina_geojson.txt', SINGLE_CLOB, CODEPAGE = '65001') AS archJson
        CROSS APPLY OPENJSON(archJson.BulkColumn, '$.features')
        WITH (
            idArea     INT           '$.properties.ID',
            nombre     VARCHAR(100)  '$.properties.NOMBRE',
            superficie DECIMAL(10,3) '$.properties.SUPERFICIE',
            pais       VARCHAR(100)  '$.properties.PAIS',
            subnaciona VARCHAR(100)  '$.properties.SUBNACIONA',
            tipo       VARCHAR(100)  '$.properties.TIPO',
            nivelGobi  VARCHAR(100)  '$.properties.NIVEL_GOBI',
            gestion    VARCHAR(100)  '$.properties.GESTION',
            creacion   VARCHAR(10)   '$.properties.CREACION',
            legal      VARCHAR(255)  '$.properties.LEGAL',
            ecoregion  VARCHAR(100)  '$.properties.ECOREGION'
        )

    IF NOT EXISTS (
        SELECT 1 FROM #AreasProtegidas
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
            @creacion   VARCHAR(10),
            @legal      VARCHAR(255),
            @ecoregion  VARCHAR(100),
            @errFila    NVARCHAR(500),
            @okCont     INT = 0,
            @errCont    INT = 0,
            @addTParCont INT = 0,
            @modTParCont INT = 0,
            @addParCont  INT = 0,
            @modParCont  INT = 0,
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
        FROM #AreasProtegidas
    
    OPEN cur
    FETCH NEXT FROM cur INTO
        @idArea, @nombre, @superficie, @pais, @subnaciona, @tipo,
        @nivelGobi, @gestion, @creacion, @legal, @ecoregion

    WHILE @@FETCH_STATUS = 0
        BEGIN   SET @errFila = ''

        IF @idArea IS NULL
            SET @errFila += 'idArea no existe'

        IF @nombre IS NULL OR @nombre = ''
            SET @errFila += 'nombre vacio. '

        IF @superficie <= 0
            SET @errFila += 'superficie no valida. '

        IF @pais IS NULL OR @pais = ''
            SET @errFila += 'pais vacio. '

        IF @subnaciona IS NULL OR @subnaciona = ''
            SET @errFila += 'provincia vacia. '

        IF @tipo IS NULL OR @tipo = ''
            SET @errFila += 'tipo vacio. '

        IF @nivelGobi NOT IN ('PRIMER ORDEN', 'SEGUNDO ORDEN', 'TERCER ORDEN', 'INTERNACIONAL')
            SET @errFila += 'nivelGobi no valido. '

        IF @gestion IS NULL OR @gestion = ''
            SET @errFila += 'gestion vacia. '
        
        IF @creacion NOT LIKE '[0-9][0-9][0-9][0-9]'
            SET @errFila += 'creacion no valida. '

        IF @legal IS NULL OR @legal = ''
            SET @errFila += 'legal vacio. '

        IF @ecoregion IS NULL OR @ecoregion = ''
            SET @errFila += 'ecoregion vacia. '

        IF @errFila <> ''
            BEGIN
                SET @errTxt += CHAR(10) +
                CONCAT(' [', @idArea, ' | ', @nombre, ' | ', @superficie, ' | ', @pais,
                       ' | ',@subnaciona, ' | ', @tipo, ' | ', @nivelGobi, ' | ', @gestion,
                       ' | ', @creacion, ' | ', @legal, ' | ', @ecoregion,']: ', @errFila)
                SET @errCont += 1
            END
        ELSE
        BEGIN

    -- UPSERT TipoParque
        IF EXISTS (
            SELECT 1 FROM Parques.TipoParque
            WHERE nombre = @tipo
        )
            BEGIN
                SELECT @idTipoParque = idTipoParque
                FROM Parques.TipoParque
                WHERE nombre = @tipo

                SET @modTParCont += 1
            END

        ELSE
            BEGIN
                EXEC Parques.sp_AltaTipoParque
                    @tipo, ''

                SELECT @idTipoParque = idTipoParque
                FROM Parques.TipoParque
                WHERE nombre = @tipo

                SET @addTParCont += 1
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

                SET @modParCont += 1
            END

        ELSE
            BEGIN
                EXEC Parques.sp_AltaParque
                    @idTipoParque, @nombre, @ecoregion, @subnaciona, @superficie
                
                SET @addParCont += 1
            END
        
        SET @okCont += 1

        END

        SigFila:
        FETCH NEXT FROM cur INTO
            @idArea, @nombre, @superficie, @pais, @subnaciona, @tipo,
            @nivelGobi, @gestion, @creacion, @legal, @ecoregion
    END

    CLOSE cur
    DEALLOCATE cur
            
    SELECT
        --@rutaArchivo AS archivo,
        @okCont  AS filasImportadas,
        @errCont AS filasConError,
        @addTParCont AS tipoParqueAgregados,
        @modTParCont AS tipoParqueModificados,
        @addParCont AS parquesAgregados,
        @modParCont AS parquesModificados

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

CREATE OR ALTER PROCEDURE Importacion.sp_ImportarVisitas
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #Visitas (
        indiceTiempo     VARCHAR(100),
        origenVisitantes VARCHAR(100),
        visitas          VARCHAR(100),
        observaciones    VARCHAR(500)
    )

    BULK INSERT #Visitas
    FROM 'C:\Datasets\visitas-residentes-y-no-residentes.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        CODEPAGE = 'RAW'
    )

    IF NOT EXISTS (
        SELECT 1 FROM #Visitas
    )
    BEGIN
        RAISERROR('El archivo no contiene datos o la ruta es incorrecta', 16, 1)
        RETURN
    END


    DECLARE @indiceTiempo  NVARCHAR(20),
            @origen        NVARCHAR(20),
            @visitasStr    NVARCHAR(20),
            @observaciones NVARCHAR(500),
            @visitasInt    INT,
            @errFila       NVARCHAR(500),
            @okCont        INT = 0,
            @errCont       INT = 0,
            @addCont       INT = 0,
            @modCont       INT = 0,
            @errTxt        NVARCHAR(MAX) = ''

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            TRIM(indiceTiempo),
            TRIM(origenVisitantes),
            TRIM(visitas),
            TRIM(observaciones)
        FROM #Visitas
    
    OPEN cur
    FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones

    WHILE @@FETCH_STATUS = 0
        BEGIN   SET @errFila = ''

        IF ISDATE(@indiceTiempo) = 0
            SET @errFila += 'indiceTiempo invalido. '
        
        IF @origen NOT IN ('residentes', 'no residentes', 'total') or @origen IS NULL
            SET @errFila += 'origen invalido. '
        
        SET @visitasInt = TRY_CAST(@visitasStr AS INT)
        IF @visitasStr <> '' AND (@visitasInt IS NULL OR @visitasInt < 0)
            SET @errFila += 'visitas no validas. '

        IF @errFila <> ''
        BEGIN
            SET @errTxt += CHAR(10) +
                CONCAT(' [', @indiceTiempo, ' | ', @origen, ' | ', @visitasStr, ' | ', @observaciones, ']: ', @errFila)
            SET @errCont += 1
            GOTO SigFila
        END

        IF EXISTS (
            SELECT 1 FROM Importacion.VisitasParquesNacionales
            WHERE indiceTiempo = @indiceTiempo
            AND origenVisitantes = @origen
        )
            BEGIN
                UPDATE Importacion.VisitasParquesNacionales
                SET visitas = @visitasInt,
                    observaciones = @observaciones
                WHERE indiceTiempo = @indiceTiempo
                    AND origenVisitantes = @origen

                SET @modCont += 1
            END

        ELSE
            BEGIN
                INSERT INTO Importacion.VisitasParquesNacionales
                    (indiceTiempo, origenVisitantes, visitas, observaciones)
                VALUES
                    (@indiceTiempo, @origen, @visitasInt, @observaciones)

                SET @addCont += 1
            END
        
        SET @okCont += 1

        SigFila:
        FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones
    END

    CLOSE cur
    DEALLOCATE cur
            
    SELECT
        @okCont  AS filasImportadas,
        @errCont AS filasConError,
        @addCont AS filasAgregadas,
        @modCont AS filasModificadas

    IF @errCont > 0
        PRINT 'Errores encontrados: ' + @errTxt

END
GO


-- ============================================================
-- IMPORTACION Guias
-- https://data.buenosaires.gob.ar/dataset/registro-guias-turismo/resource/juqdkmgo-1791-resource
-- FORMATO: .csv
-- RUTA: C:\Datasets\registro-de-guias-de-turismo.csv
-- ============================================================
USE ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Importacion.sp_ImportarGuias
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #GuiasTurismo (
        periodo    VARCHAR(100),
        apellido   VARCHAR(100),
        nombre     VARCHAR(100),
        tipoDoc    VARCHAR(100),
        numero     VARCHAR(100),
        nRegistro  VARCHAR(100),
        categoria  VARCHAR(100)
    )

    BULK INSERT #GuiasTurismo
    FROM 'C:\Datasets\registro-de-guias-de-turismo.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ';',
        ROWTERMINATOR = '\n',
        CODEPAGE = 'ACP'
    )


    IF NOT EXISTS (
        SELECT 1 FROM #GuiasTurismo
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
            @addCont      INT = 0,
            @modCont      INT = 0,
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
        FROM #GuiasTurismo
    
    OPEN cur
    FETCH NEXT FROM cur INTO @periodoStr, @apellido, @nombre, @tipoDoc, @numeroDoc, @nRegistro, @categoria

    WHILE @@FETCH_STATUS = 0
        BEGIN
        SET @errFila = ''

        SET @numeroDoc = NULLIF(TRIM(@numeroDoc), '')

        IF @periodoStr NOT LIKE '[0-9][0-9][0-9][0-9]'
            SET @errFila += 'periodo invalido. '
        
        IF @apellido IS NULL
            SET @errFila += 'apellido vacio. '

        IF @nombre IS NULL
            SET @errFila += 'nombre vacio. '

        IF @tipoDoc IS NULL
            SET @errFila += 'tipoDocumento vacio. '

        IF @numeroDoc IS NULL OR ISNUMERIC(@numeroDoc) = 0
            SET @errFila += 'numeroDocumento invalido. '

        IF @nRegistro IS NULL
            SET @errFila += 'nRegistro vacio. '

        IF @categoria IS NULL
            SET @errFila += 'categoria vacia. '

        IF @errFila <> ''
        BEGIN
            SET @errTxt += CHAR(10) +
                CONCAT(' [', @periodoStr, ' | ', @apellido, ' | ', @nombre, ' | ', @tipoDoc,
                       ' | ',@numeroDoc, ' | ', @nRegistro, ' | ', @categoria, ']: ', @errFila)
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

                SET @modCont += 1
            END

        ELSE
            BEGIN
                SET @emailDin = CONCAT(TRIM(@nombre), TRIM(@numeroDoc), '@gmail.com')

                EXEC Guias.sp_AltaGuia
                    @nombre, @apellido, '2000-01-01', @tipoDoc, @numeroDoc, @emailDin, '2030-01-01'

                SET @addCont += 1
            END
        
        SET @okCont += 1

        SigFila:
        FETCH NEXT FROM cur INTO @periodoStr, @apellido, @nombre, @tipoDoc, @numeroDoc, @nRegistro, @categoria
    END

    CLOSE cur
    DEALLOCATE cur
            
    SELECT
        @okCont  AS filasImportadas,
        @errCont AS filasConError,
        @addCont AS filasAgregadas,
        @modCont AS filasModificadas

    IF @errCont > 0
        PRINT 'Errores encontrados: ' + @errTxt

END
GO
