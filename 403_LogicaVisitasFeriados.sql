-- ============================================================
-- Fecha: 2025-07-02
-- Descripción: Reporte de visitas los dias feriados
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Reportes.sp_VisitasEnFeriados
    @anio     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @anio IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Apis.Feriados
        WHERE YEAR(fecha) = @anio
    )
    BEGIN
        PRINT 'Feriados no encontrados.'
        RETURN
    END

    -- El resultado final se empaqueta en una raíz llamada <ReporteVisitasFeriados>
    SELECT 
        p.idParque AS [@IdParque],
        p.nombre   AS [@NombreParque],
        
        -- Subconsulta 1: Obtener el total consolidado del parque en feriados
        (
            SELECT SUM(dv_tot.cantidad)
            FROM Ventas.DetalleVenta dv_tot
            JOIN Ventas.Entrada e_tot ON e_tot.idEntrada = dv_tot.idEntrada
            JOIN Apis.Feriados f_tot ON CAST(dv_tot.fechaAcceso AS DATE) = f_tot.fecha
            WHERE e_tot.idParque = p.idParque
              AND (@anio IS NULL OR YEAR(dv_tot.fechaAcceso) = @anio)
        ) AS [TotalVisitasFeriados],

        -- Subconsulta 2: Detalle interno nodo por nodo de cada feriado
        (
            SELECT 
                f.fecha   AS [@Fecha],
                f.nombre  AS [@NombreFeriado],
                f.tipo    AS [@TipoFeriado],
                SUM(dv_det.cantidad) AS [CantidadVisitas]
            FROM Ventas.DetalleVenta dv_det
            JOIN Ventas.Entrada e_det ON e_det.idEntrada = dv_det.idEntrada
            JOIN Apis.Feriados f ON CAST(dv_det.fechaAcceso AS DATE) = f.fecha
            WHERE e_det.idParque = p.idParque
              AND (@anio IS NULL OR YEAR(dv_det.fechaAcceso) = @anio)
            GROUP BY f.fecha, f.nombre, f.tipo
            ORDER BY f.fecha ASC
            FOR XML PATH('Feriado'), TYPE
        ) AS [DesgloseFeriados]

    FROM Parques.Parque p
    WHERE EXISTS (
        -- Filtramos para mostrar únicamente los parques que registran visitas en feriados
        SELECT 1 
        FROM Ventas.DetalleVenta dv_chk
        JOIN Ventas.Entrada e_chk ON e_chk.idEntrada = dv_chk.idEntrada
        JOIN Apis.Feriados f_chk ON CAST(dv_chk.fechaAcceso AS DATE) = f_chk.fecha
        WHERE e_chk.idParque = p.idParque
          AND (@anio IS NULL OR YEAR(dv_chk.fechaAcceso) = @anio)
    )
    ORDER BY p.nombre
    FOR XML PATH('Parque'), ROOT('ReporteVisitasFeriados');
END
GO