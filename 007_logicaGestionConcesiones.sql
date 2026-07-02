-- ========================================================================
--  UNIVERSIDAD NACIONAL DE LA MATANZA
--  Departamento de Ingeniería e Investigaciones Tecnológicas
--  Asignatura: 3641 - Bases de Datos Aplicada
--  Objetivo del Código: Lógica de Negocio Transaccional para Concesiones
-- ========================================================================
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE Com5600G05_ParquesNacionales;
GO
-- ========================================================================
-- 1. PROCESO: CANCELACIÓN ANTICIPADA / RESCISIÓN DE CONTRATO
-- ========================================================================
CREATE OR ALTER PROCEDURE Concesiones.sp_CancelarConcesion
    @idConcesion INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
    BEGIN
        RAISERROR('- Error de Negocio: El contrato de concesión especificado no existe.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Concesiones.Concesion
        SET estado = 'Cancelada'
        WHERE idConcesion = @idConcesion;

        COMMIT TRANSACTION;
        PRINT 'Contrato de concesión rescindido y cancelado lógicamente con éxito.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ========================================================================
-- 2. PROCESO: REGISTRO INTELIGENTE DE PAGO DE CÁNONES
-- ========================================================================
CREATE OR ALTER PROCEDURE Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion      INT,
    @monto            DECIMAL(12,2),
    @fechaPago        DATE = NULL,        
    @fechaEmision     DATE = NULL,
    @fechaVencimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @estadoContrato VARCHAR(20);
    SELECT @estadoContrato = estado FROM Concesiones.Concesion WHERE idConcesion = @idConcesion;

    
    IF @estadoContrato IN ('Cancelada', 'Vencida')
    BEGIN
        DECLARE @msgError VARCHAR(250) = '- Error de Negocio: Operación rechazada. No se pueden registrar pagos de cánones en un contrato comercial en estado: ' + @estadoContrato + '.';
        RAISERROR(@msgError, 16, 1);
        RETURN;
    END

    -- Asignación de temporales dinámicas si el usuario no las envía explicitamente
    SET @fechaPago = COALESCE(@fechaPago, CAST(GETDATE() AS DATE));
    SET @fechaEmision = COALESCE(@fechaEmision, CAST(GETDATE() AS DATE));
    SET @fechaVencimiento = COALESCE(@fechaVencimiento, DATEADD(DAY, 10, CAST(GETDATE() AS DATE)));

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Consumimos el ABM seguro
        EXEC Concesiones.sp_AltaPagoCanon
            @idConcesion = @idConcesion,
            @fechaPago = @fechaPago,
            @monto = @monto,
            @fechaVencimiento = @fechaVencimiento,
            @fechaEmision = @fechaEmision;

        COMMIT TRANSACTION;
        PRINT 'Pago de canon registrado y asociado al contrato correctamente.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ========================================================================
-- 3. PROCESO: CONSULTA DE CONCESIONES PRÓXIMAS A VENCER
-- ========================================================================
CREATE OR ALTER PROCEDURE Concesiones.sp_ConcesionesProximasAVencer
    @diasParaVencimiento INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.idConcesion,
        e.razonSocial AS empresa_concesionaria,
        p.nombre AS parque_nacional,
        tac.nombre AS tipo_actividad,
        c.fechaInicio AS fecha_inicio_contrato,
        c.fechaFin AS fecha_vencimiento_contrato,
        DATEDIFF(day, GETDATE(), c.fechaFin) AS dias_para_vencer,
        c.montoAlquiler AS canon_alquiler,
        c.estado
    FROM Concesiones.Concesion c
    JOIN Concesiones.EmpresaConcesionaria e ON c.idEmpresaConcesionaria = e.idEmpresaConcesionaria
    JOIN Concesiones.TipoActividadConcesion tac ON c.idTipoActividadConcesion = tac.idTipoActividadConcesion
    JOIN Parques.Parque p ON c.idParque = p.idParque
    WHERE c.estado = 'Activa'
      AND c.fechaFin >= GETDATE()
      AND c.fechaFin <= DATEADD(day, @diasParaVencimiento, GETDATE())
    ORDER BY c.fechaFin ASC;
END;
GO
