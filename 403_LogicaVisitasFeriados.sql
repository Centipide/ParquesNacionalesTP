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
    @idParque INT = NULL,
    @anio     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @anioFiltro INT = COALESCE(@anio, YEAR(GETDATE()));

    BEGIN TRY
        EXEC Apis.sp_ImportarFeriados @anio = @anioFiltro;
    END TRY
    BEGIN CATCH
        PRINT 'No se pudo actualizar la API de feriados. Se usará la información disponible.';
    END CATCH;

    SELECT 
        p.idParque,
        p.nombre AS parque,
        f.fecha AS fechaFeriado,
        f.nombre AS nombreFeriado,
        f.tipo AS tipoFeriado,
        ISNULL(SUM(dv.cantidad), 0) AS totalVisitas
    FROM Apis.Feriados f
    LEFT JOIN Ventas.DetalleVenta dv ON CAST(dv.fechaAcceso AS DATE) = f.fecha
    LEFT JOIN Ventas.Entrada e ON e.idEntrada = dv.idEntrada AND (@idParque IS NULL OR e.idParque = @idParque)
    LEFT JOIN Parques.Parque p ON p.idParque = e.idParque
    WHERE 
        YEAR(f.fecha) = @anioFiltro
        AND (@idParque IS NULL OR p.idParque = @idParque)
    GROUP BY 
        p.idParque, 
        p.nombre, 
        f.fecha, 
        f.nombre, 
        f.tipo
    ORDER BY 
        f.fecha ASC, 
        totalVisitas DESC;
END
GO