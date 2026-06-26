-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Tabla cruzada mostrando visitas
-- por mes y parque.
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================
-- ========================================================================
-- 4. MATRIZ DE VISITAS
-- ========================================================================
USE ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Reportes.sp_MatrizVisitasXML
    @anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    IF @anio IS NULL SET @anio = YEAR(GETDATE())

    DECLARE @parques   NVARCHAR(MAX) = ''
    DECLARE @colSelect NVARCHAR(MAX) = ''

    SELECT
        @parques   += ',' + QUOTENAME(REPLACE(nombre, ' ', '_')),
        @colSelect += ',ISNULL(' + QUOTENAME(REPLACE(nombre, ' ', '_')) + ',0) AS ' + QUOTENAME(REPLACE(nombre, ' ', '_'))
    FROM (
        SELECT DISTINCT p.nombre
        FROM Ventas.DetalleVenta dv
        INNER JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
        INNER JOIN Parques.Parque p ON p.idParque  = e.idParque
        WHERE YEAR(dv.FechaAcceso) = @anio
    ) t

    IF @parques = ''
    BEGIN
        SELECT (
            SELECT 'Sin datos de visitas para ese año' AS mensaje
            FOR XML PATH('MatrizVisitas'), ROOT('Reporte'), TYPE
        )
        RETURN
    END

    SET @parques = STUFF(@parques, 1, 1, '')

    DECLARE @sql NVARCHAR(MAX) = N'
    SELECT (
        SELECT
            ' + CAST(@anio AS VARCHAR) + ' AS anio,
            (
                SELECT
                    mes,
                    nombre_mes ' + @colSelect + N'
                FROM (
                    SELECT
                        MONTH(dv.FechaAcceso)           AS mes,
                        DATENAME(MONTH, dv.FechaAcceso) AS nombre_mes,
                        REPLACE(p.nombre, '' '', ''_'') AS parque,
                        SUM(dv.Cantidad)                AS visitas
                    FROM Ventas.DetalleVenta dv
                    INNER JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada
                    INNER JOIN Parques.Parque p ON p.idParque  = e.idParque
                    WHERE YEAR(dv.FechaAcceso) = ' + CAST(@anio AS VARCHAR) + N'
                    GROUP BY MONTH(dv.FechaAcceso),
                             DATENAME(MONTH, dv.FechaAcceso),
                             p.nombre
                ) src
                PIVOT (SUM(visitas) FOR parque IN (' + @parques + N')) pvt
                ORDER BY mes
                FOR XML PATH(''Mes''), TYPE
            )
        FOR XML PATH(''MatrizVisitas''), TYPE
    )'

    EXEC sp_executesql @sql
END
GO

--EXEC Reportes.sp_MatrizVisitasXML