-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Listado de parques y vector anidado con
-- concesiones
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================
-- ============================================================
-- 5. PARQUES CON CONCESIONES ANIDADAS
-- ============================================================
USE ParquesNacionales
GO

CREATE OR ALTER PROCEDURE Reportes.sp_ParquesConConcesionesXML
    @solo_activas BIT = 1   -- 1 = sólo concesiones Activas, 0 = todas
AS
BEGIN
    SET NOCOUNT ON

    SELECT (
        SELECT
            p.idParque       AS [@id],
            p.nombre          AS nombre,
            p.provincia       AS provincia,
            p.superficie      AS superficie_ha,
            tp.nombre         AS tipo,
            -- Concesiones anidadas como elemento hijo
            (
                SELECT
                    con.idConcesion          AS [@id],
                    e.razonSocial            AS titular,
                    e.cuit                    AS cuit_titular,
                    e.contacto                AS contacto,
                    tac.nombre                AS servicio,
                    con.fechaInicio          AS fecha_inicio,
                    con.fechaFin             AS fecha_fin,
                    con.montoAlquiler        AS canon_mensual,
                    con.Estado                AS estado,
                    -- Total pagado
                    ISNULL((
                        SELECT SUM(monto)
                        FROM Concesiones.PagoCanon
                        WHERE idConcesion = con.idConcesion
                    ), 0)                     AS total_pagado,
                    -- Cantidad de pagos
                    ISNULL((
                        SELECT COUNT(*)
                        FROM Concesiones.PagoCanon
                        WHERE idConcesion = con.idConcesion
                    ), 0)                     AS cantidad_pagos
                FROM Concesiones.Concesion con
                INNER JOIN Concesiones.EmpresaConcesionaria e
                    ON e.idEmpresaConcesionaria = con.idEmpresaConcesionaria
                INNER JOIN Concesiones.TipoActividadConcesion tac
                    ON tac.idTipoActividadConcesion = con.idTipoActividadConcesion
                WHERE con.idParque = p.idParque
                  AND (@solo_activas = 0 OR con.Estado = 'Activa')
                ORDER BY con.FechaInicio
                FOR XML PATH('Concesion'), ROOT('Concesiones'), TYPE
            )
        FROM Parques.Parque p
        INNER JOIN Parques.TipoParque tp ON tp.idTipoParque = p.idTipoParque
        -- Solo parques que tienen al menos una concesión
        WHERE EXISTS (
            SELECT 1 FROM Concesiones.Concesion con
            WHERE con.idParque = p.idParque
              AND (@solo_activas = 0 OR con.Estado = 'Activa')
        )
        ORDER BY p.nombre
        FOR XML PATH('Parque'), ROOT('Parques'), TYPE
    )
END
GO

--Listado completo de parques con sus concesiones
--EXEC Reportes.sp_ParquesConConcesionesXML @solo_activas = 0

--Listado de parques solamente con concesiones ACTIVAS
--EXEC Reportes.sp_ParquesConConcesionesXML @solo_activas = 1