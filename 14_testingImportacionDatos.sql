-- ============================================================
-- TESTING Parques y TiposParque
-- ============================================================

EXEC Importacion.sp_ImportarParques
    @rutaArchivo = 'C:\Datasets\af_ha007__rea_protegida_argentina_geojson.txt'

SELECT * FROM Importacion.AreasProtegidas
SELECT * FROM Parques.TipoParque
SELECT * FROM Parques.Parque


-- ============================================================
-- TESTING Visitas segun tipo visitante
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarVisitas
    @rutaArchivo = 'C:\Datasets\visitas-residentes-y-no-residentes.csv'

SELECT * FROM Importacion.VisitasParquesNacionales


-- ============================================================
-- TESTING Guias registrados
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarGuias
    @rutaArchivo = 'C:\Datasets\registro-de-guias-de-turismo.csv'

SELECT * FROM Guias.Guia