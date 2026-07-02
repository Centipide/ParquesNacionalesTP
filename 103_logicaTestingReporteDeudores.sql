-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Concesiones atrasadas en los pagos,
-- detallando meses y montos.
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================
-- ============================================================
-- 3. REPORTE DE DEUDORES
-- ============================================================
USE Com5600G05_ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Reportes.sp_ConcesionesDeudoras

AS
BEGIN
    SELECT
        -- Identificación
        c.idConcesion,
        e.razonSocial AS empresa,
        e.cuit,
        p.nombre AS parque,
 
        -- Vigencia del contrato
        pc.fechaEmision,
        pc.fechaPago,
        pc.fechaVencimiento,
        pc.monto,

        CASE
            WHEN pc.fechaPago > pc.fechaVencimiento
                THEN 'Vencida'
            WHEN pc.fechaPago IS NULL
                THEN 'Sin Pagar'
            ELSE '---'
        END AS estado
 
    FROM Concesiones.Concesion c
    INNER JOIN Concesiones.EmpresaConcesionaria e
        ON e.idEmpresaConcesionaria = c.idEmpresaConcesionaria
    INNER JOIN Parques.Parque p
        ON p.idParque = c.idParque
    INNER JOIN Concesiones.TipoActividadConcesion tac
        ON tac.idTipoActividadConcesion = c.idTipoActividadConcesion
    INNER JOIN Concesiones.PagoCanon pc
        ON pc.idConcesion = c.idConcesion
    WHERE pc.fechaPago > pc.fechaVencimiento OR pc.fechaPago IS NULL
    ORDER BY
        e.razonSocial ASC;
END
GO


-- ============================================================
-- TESTING
-- ============================================================
DECLARE @idConc2 INT = 2
DECLARE @idConc3 INT = 3
DECLARE @idConc4 INT = 4
DECLARE @idConc6 INT = 6
 
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc2, @monto = 600000.00,
    @fechaPago = '2025-02-03', @fechaEmision = '2025-01-25', @fechaVencimiento = '2025-02-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc2, @monto = 600000.00,
    @fechaPago = '2025-03-04', @fechaEmision = '2025-02-25', @fechaVencimiento = '2025-03-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc2, @monto = 600000.00,
    @fechaPago = '2025-04-02', @fechaEmision = '2025-03-25', @fechaVencimiento = '2025-04-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc2, @monto = 600000.00,
    @fechaPago = '2025-05-05', @fechaEmision = '2025-04-25', @fechaVencimiento = '2025-05-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc2, @monto = 600000.00,
    @fechaPago = '2025-06-03', @fechaEmision = '2025-05-25', @fechaVencimiento = '2025-06-05'
 
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc3, @monto = 450000.00,
    @fechaPago = '2024-02-01', @fechaEmision = '2024-01-25', @fechaVencimiento = '2024-02-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc3, @monto = 450000.00,
    @fechaPago = '2024-03-04', @fechaEmision = '2024-02-25', @fechaVencimiento = '2024-03-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc3, @monto = 450000.00,
    @fechaPago = '2024-04-03', @fechaEmision = '2024-03-25', @fechaVencimiento = '2024-04-05'

EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc4, @monto = 800000.00,
    @fechaPago = '2023-06-20', @fechaEmision = '2023-05-25', @fechaVencimiento = '2023-06-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc4, @monto = 800000.00,
    @fechaPago = '2023-07-18', @fechaEmision = '2023-06-25', @fechaVencimiento = '2023-07-05'
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc4, @monto = 800000.00,
    @fechaPago = '2023-08-22', @fechaEmision = '2023-07-25', @fechaVencimiento = '2023-08-05'
 
EXEC Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion = @idConc6, @monto = 120000.00,
    @fechaPago = '2025-02-03', @fechaEmision = '2025-01-25', @fechaVencimiento = '2025-02-05'
 
 
-- ============================================================
-- TEST
-- ============================================================
PRINT '--- TEST 1: Solo concesiones deudoras (hoy) ---';
EXEC Reportes.sp_ConcesionesDeudoras

-- ============================================================
-- EVIDENCIA
-- ============================================================
SELECT
    c.idConcesion,
    e.razonSocial,
    p.nombre AS parque,
    c.montoAlquiler AS canonMensual,
    c.fechaInicio,
    c.estado,
    pc.fechaPago,
    pc.fechaVencimiento,
    pc.monto,
    CASE
        WHEN pc.fechaPago > pc.fechaVencimiento THEN 'TARDE'
        ELSE 'A tiempo'
    END AS condicionPago
FROM Concesiones.PagoCanon pc
INNER JOIN Concesiones.Concesion c
    ON  c.idConcesion = pc.idConcesion
INNER JOIN Concesiones.EmpresaConcesionaria e
    ON  e.idEmpresaConcesionaria = c.idEmpresaConcesionaria
INNER JOIN Parques.Parque p
    ON  p.idParque = c.idParque
ORDER BY
    c.idConcesion,
    pc.fechaPago
