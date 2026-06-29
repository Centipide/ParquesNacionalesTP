-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Creación de script de carga de datos.
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

DECLARE @idTipoP INT
DECLARE @idParque1 INT, @idParque2 INT, @idParque3 INT, @idParque4 INT,@idParque5 INT,
    @idParque6 INT, @idParque7 INT, @idParque8 INT, @idParque9 INT, @idParque10 INT

DECLARE @idG1 INT, @idG2 INT, @idG3 INT, @idG4 INT, @idG5 INT

DECLARE @idGuia1 INT, @idGuia2 INT, @idGuia3 INT, @idGuia4 INT, @idGuia5 INT

DECLARE @idTipoAct INT

DECLARE @idAct1 INT, @idAct2 INT, @idAct3 INT, @idAct4 INT, @idAct5 INT, @idAct6 INT

DECLARE @idTipoConc INT

DECLARE @idEmp1 INT, @idEmp2 INT, @idEmp3 INT, @idEmp4 INT, @idEmp5 INT

DECLARE @idTV1 INT, @idTV2 INT, @idTV3 INT, @idTV4 INT

DECLARE @idEnt1 INT, @idEnt2 INT, @idEnt3 INT, @idEnt4 INT, @idEnt5 INT, @idEnt6 INT,
    @idEnt7 INT, @idEnt8 INT, @idEnt9 INT, @idEnt10 INT, @idEnt11 INT

DECLARE @idVis1 INT, @idVis2 INT, @idVis3 INT, @idVis4 INT, @idVis5 INT

DECLARE @idVenta1 INT, @idVenta2 INT, @idVenta3 INT, @idVenta4 INT, @idVenta5 INT

DECLARE @idProg1 INT, @idProg2 INT, @idProg3 INT, @idProg4 INT

DECLARE @idDetCont1 INT, @idDetCont2 INT


-- ==========================================================
-- GENERACION Parques
-- ==========================================================

EXEC Parques.sp_AltaTipoParque @nombre = 'Parque Nacional', @descripcion = 'Area protegida de maxima restriccion.'
SELECT @idTipoP = idTipoParque FROM Parques.TipoParque WHERE nombre = 'Parque Nacional'


EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Los Glaciares',
    @region = 'Patagonia', @provincia = 'Santa Cruz', @superficie = 726927.00
SELECT @idParque1 = idParque FROM Parques.Parque WHERE nombre = 'Los Glaciares'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Iguazú',
    @region = 'NEA', @provincia = 'Misiones', @superficie = 67700.00
SELECT @idParque2 = idParque FROM Parques.Parque WHERE nombre = 'Iguazú'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Nahuel Huapi',
    @region = 'Patagonia', @provincia = 'Río Negro', @superficie = 710000.00;
SELECT @idParque3 = idParque FROM Parques.Parque WHERE nombre = 'Nahuel Huapi'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Tierra del Fuego',
    @region = 'Patagonia', @provincia = 'Tierra del Fuego', @superficie = 68909.00
SELECT @idParque4 = idParque FROM Parques.Parque WHERE nombre = 'Tierra del Fuego'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'El Palmar',
    @region = 'Centro', @provincia = 'Entre Ríos', @superficie = 8213.00
SELECT @idParque5 = idParque FROM Parques.Parque WHERE nombre = 'El Palmar'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Talampaya',
    @region = 'Cuyo', @provincia = 'La Rioja', @superficie = 215000.00
SELECT @idParque6 = idParque FROM Parques.Parque WHERE nombre = 'Talampaya'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Lanín',
    @region = 'Patagonia', @provincia = 'Neuquén', @superficie = 412003.00
SELECT @idParque7 = idParque FROM Parques.Parque WHERE nombre = 'Lanín'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Los Cardones',
    @region = 'NOA', @provincia = 'Salta', @superficie = 64117.00
SELECT @idParque8 = idParque FROM Parques.Parque WHERE nombre = 'Los Cardones'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Quebrada del Condorito',
    @region = 'Centro', @provincia = 'Córdoba', @superficie = 37344.00
SELECT @idParque9 = idParque FROM Parques.Parque WHERE nombre = 'Quebrada del Condorito'

EXEC Parques.sp_AltaParque @idTipoParque = @idTipoP, @nombre = 'Sierra de las Quijadas',
    @region = 'Cuyo', @provincia = 'San Luis', @superficie = 73534.00
SELECT @idParque10 = idParque FROM Parques.Parque WHERE nombre = 'Sierra de las Quijadas'


-- ==========================================================
-- GENERACION Guardaparques
-- ==========================================================

EXEC Personal.sp_AltaGuardaparque 'Carlos', 'González', '1975-04-12', 'DNI', '24555111',
    'carlos.gonzalez@parques.gob.ar', '2000-01-15'
SELECT @idG1 = idGuardaparque FROM Personal.Guardaparque WHERE email = 'carlos.gonzalez@parques.gob.ar'

EXEC Personal.sp_AltaGuardaparque 'María', 'Rodríguez', '1980-08-22', 'DNI', '28333222',
    'maria.rodriguez@parques.gob.ar', '2005-03-10'
SELECT @idG2 = idGuardaparque FROM Personal.Guardaparque WHERE email = 'maria.rodriguez@parques.gob.ar'

EXEC Personal.sp_AltaGuardaparque 'Juan', 'López', '1972-11-05', 'DNI', '22444333',
    'juan.lopez@parques.gob.ar', '1998-06-01'
SELECT @idG3 = idGuardaparque FROM Personal.Guardaparque WHERE email = 'juan.lopez@parques.gob.ar'

EXEC Personal.sp_AltaGuardaparque 'Ana', 'Martínez', '1985-01-30', 'DNI', '31555444',
    'ana.martinez@parques.gob.ar', '2010-02-15'
SELECT @idG4 = idGuardaparque FROM Personal.Guardaparque WHERE email = 'ana.martinez@parques.gob.ar'

EXEC Personal.sp_AltaGuardaparque 'Luis', 'Pérez', '1988-07-14', 'DNI', '33888555',
    'luis.perez@parques.gob.ar', '2012-08-01'
SELECT @idG5 = idGuardaparque FROM Personal.Guardaparque WHERE email = 'luis.perez@parques.gob.ar'

EXEC Personal.sp_AltaGuardaparque 'Laura', 'Gómez', '1990-03-25', 'DNI', '35222666',
    'laura.gomez@parques.gob.ar', '2015-05-20'

EXEC Personal.sp_AltaGuardaparque 'Jorge', 'Sánchez', '1968-09-18', 'DNI', '20111777',
    'jorge.sanchez@parques.gob.ar', '1992-11-01'

EXEC Personal.sp_AltaGuardaparque 'Elena', 'Díaz', '1983-12-02', 'DNI', '30444888',
    'elena.diaz@parques.gob.ar', '2008-04-10'

EXEC Personal.sp_AltaGuardaparque 'Ricardo', 'Álvarez', '1977-05-19', 'DNI', '25999999',
    'ricardo.alvarez@parques.gob.ar', '2002-09-01'

EXEC Personal.sp_AltaGuardaparque 'Sonia', 'Fernández', '1982-10-10', 'DNI', '29666111',
    'sonia.fernandez@parques.gob.ar', '2006-11-15'

EXEC Personal.sp_AltaGuardaparque 'Pedro', 'Romero', '1992-02-27', 'DNI', '36777222',
    'pedro.romero@parques.gob.ar', '2018-01-10'

EXEC Personal.sp_AltaGuardaparque 'Marta', 'Ruiz', '1986-06-15', 'DNI', '32444333',
    'marta.ruiz@parques.gob.ar', '2011-07-01'

EXEC Personal.sp_AltaGuardaparque 'Gabriel', 'Torres', '1979-11-23', 'DNI', '27333444',
    'gabriel.torres@parques.gob.ar', '2004-05-18'

EXEC Personal.sp_AltaGuardaparque 'Silvia', 'Alonso', '1984-04-05', 'DNI', '30999555',
    'silvia.alonso@parques.gob.ar', '2009-10-01'

EXEC Personal.sp_AltaGuardaparque 'Hugo', 'Gutiérrez', '1974-08-12', 'DNI', '23888666',
    'hugo.gutierrez@parques.gob.ar', '1999-03-01'

EXEC Personal.sp_AltaGuardaparque 'Beatriz', 'Castro', '1991-01-08', 'DNI', '35888777',
    'beatriz.castro@parques.gob.ar', '2016-09-15'

EXEC Personal.sp_AltaGuardaparque 'Daniel', 'Suárez', '1987-09-30', 'DNI', '33111888',
    'daniel.suarez@parques.gob.ar', '2013-02-01'

EXEC Personal.sp_AltaGuardaparque 'Alicia', 'Ortiz', '1981-05-14', 'DNI', '28777999',
    'alicia.ortiz@parques.gob.ar', '2007-06-20'

EXEC Personal.sp_AltaGuardaparque 'Roberto', 'Blanco', '1970-03-22', 'DNI', '21444111',
    'roberto.blanco@parques.gob.ar', '1995-04-01'

EXEC Personal.sp_AltaGuardaparque 'Clara', 'Medina', '1993-11-11', 'DNI', '37555222',
    'clara.medina@parques.gob.ar', '2019-11-01'


-- ==========================================================
-- GENERACION Guias
-- ==========================================================

EXEC Guias.sp_AltaGuia 'Ramón', 'Herrera', '1980-05-14', 'DNI', '28111001',
    'ramon.herrera@gmail.com', '2027-12-31'
SELECT @idGuia1 = idGuia FROM Guias.Guia WHERE email = 'ramon.herrera@gmail.com'

EXEC Guias.sp_AltaGuia 'Lucía', 'Benítez', '1988-09-23', 'DNI', '33222002',
    'lucia.benitez@gmail.com', '2027-12-31'
SELECT @idGuia2 = idGuia FROM Guias.Guia WHERE email = 'lucia.benitez@gmail.com'

EXEC Guias.sp_AltaGuia 'Esteban', 'Castro', '1985-02-11', 'DNI', '31333003',
    'esteban.castro@hotmail.com', '2027-06-30'
SELECT @idGuia3 = idGuia FROM Guias.Guia WHERE email = 'esteban.castro@hotmail.com'

EXEC Guias.sp_AltaGuia 'Verónica', 'Molina', '1992-07-19', 'DNI', '36444004',
    'veronica.molina@yahoo.com', '2028-01-01'
SELECT @idGuia4 = idGuia FROM Guias.Guia WHERE email = 'veronica.molina@yahoo.com'

EXEC Guias.sp_AltaGuia 'Facundo', 'Ríos', '1983-11-04', 'DNI', '30555005',
    'facundo.rios@gmail.com', '2027-05-15'

EXEC Guias.sp_AltaGuia 'Gabriela', 'Ortiz', '1989-04-30', 'DNI', '34666006',
    'gabriela.ortiz@outlook.com', '2027-09-20'

EXEC Guias.sp_AltaGuia 'Andrés', 'Silva', '1976-10-12', 'DNI', '25777007',
    'andres.silva@gmail.com', '2026-12-31'

EXEC Guias.sp_AltaGuia 'Natalia', 'Páez', '1994-01-25', 'DNI', '38888008',
    'natalia.paez@gmail.com', '2028-03-15'

EXEC Guias.sp_AltaGuia 'Mariano', 'Luna', '1981-06-08', 'DNI', '29999009',
    'mariano.luna@hotmail.com', '2027-11-30'

EXEC Guias.sp_AltaGuia 'Cecilia', 'Vera', '1987-12-15', 'DNI', '32111010',
    'cecilia.vera@gmail.com', '2027-08-12'

EXEC Guias.sp_AltaGuia 'Martín', 'Sosa', '1990-08-03', 'DNI', '35222011',
    'martin.sosa@gmail.com', '2028-02-10'

EXEC Guias.sp_AltaGuia 'Florencia', 'Acosta', '1993-03-14', 'DNI', '37333012',
    'flor.acosta@gmail.com', '2027-04-05'

EXEC Guias.sp_AltaGuia 'Javier', 'Garay', '1979-09-21', 'DNI', '27444013',
    'javier.garay@yahoo.com', '2026-10-31'

EXEC Guias.sp_AltaGuia 'Daniela', 'Medina', '1986-05-09', 'DNI', '32555014',
    'daniela.medina@gmail.com', '2027-07-25'

EXEC Guias.sp_AltaGuia 'Gonzalo', 'Miranda', '1991-02-18', 'DNI', '35666015',
    'gonzalo.miranda@hotmail.com', '2028-05-01'

EXEC Guias.sp_AltaGuia 'Carolina', 'Suárez', '1984-11-27', 'DNI', '30777016',
    'caro.suarez@gmail.com', '2027-12-15'

EXEC Guias.sp_AltaGuia 'Santiago', 'Cáceres', '1982-01-05', 'DNI', '29222017',
    'santiago.caceres@gmail.com', '2027-03-20'

EXEC Guias.sp_AltaGuia 'Camila', 'Domínguez', '1995-10-10', 'DNI', '39111018',
    'camila.d@outlook.com', '2028-06-01'

EXEC Guias.sp_AltaGuia 'Alejandro', 'Vega', '1978-07-04', 'DNI', '26444019',
    'alejandro.vega@gmail.com', '2026-11-15'

EXEC Guias.sp_AltaGuia 'Sofía', 'Flores', '1992-12-12', 'DNI', '36999020',
    'sofia.flores@gmail.com', '2028-01-10'


-- ==========================================================
-- GENERACION Actividades
-- ==========================================================

EXEC Actividades.sp_AltaTipoActividadTuristica @descripcion = 'Aventuras y Senderismo General'
SELECT @idTipoAct = idTipoActividadTuristica
FROM Actividades.TipoActividadTuristica
WHERE descripcion = 'Aventuras y Senderismo General'


EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque1, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Minitrekking Perito Moreno', @costo = 45000.00, @duracion = 240, @cupoMaximo = 20
SELECT @idAct1 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Minitrekking Perito Moreno'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque1, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Safari Náutico', @costo = 15000.00, @duracion = 60, @cupoMaximo = 60
SELECT @idAct2 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Safari Náutico'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque1, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Trekking Base Fitz Roy', @costo = 25000.00, @duracion = 480, @cupoMaximo = 15
SELECT @idAct3 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Trekking Base Fitz Roy'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque2, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Gran Aventura Cataratas', @costo = 35000.00, @duracion = 120, @cupoMaximo = 40
SELECT @idAct4 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Gran Aventura Cataratas'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque2, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Gran Aventura VIP Exclusiva', @costo = 45000.00, @duracion = 120, @cupoMaximo = 4
SELECT @idAct5 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Gran Aventura VIP Exclusiva'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque2, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Paseo de Luna Llena', @costo = 30000.00, @duracion = 150, @cupoMaximo = 30
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque2, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Sendero Macuco', @costo = 12000.00, @duracion = 180, @cupoMaximo = 25

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque3, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Isla Victoria y Arrayanes', @costo = 22000.00, @duracion = 300, @cupoMaximo = 100
SELECT @idAct6 = idActividadTuristica FROM Actividades.ActividadTuristica WHERE nombre = 'Isla Victoria y Arrayanes'

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque3, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Senderismo Cerro Tronador', @costo = 18000.00, @duracion = 360, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque3, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Cruce de los Andes', @costo = 55000.00, @duracion = 600, @cupoMaximo = 12

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque4, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Trekking Histórico Lapataia', @costo = 14000.00, @duracion = 180, @cupoMaximo = 25
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque4, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Canoas en Bahía Lapataia', @costo = 20000.00, @duracion = 120, @cupoMaximo = 16
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque4, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Avistaje de Castores', @costo = 16000.00, @duracion = 150, @cupoMaximo = 15

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque5, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Safari Fotográfico Yatay', @costo = 8000.00, @duracion = 120, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque5, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Sendero El Mollar Nocturno', @costo = 9500.00, @duracion = 90, @cupoMaximo = 25
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque5, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Ruinas Calera del Palmar', @costo = 7000.00, @duracion = 90, @cupoMaximo = 30

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque6, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Cañón de Talampaya Completo', @costo = 19000.00, @duracion = 150, @cupoMaximo = 40
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque6, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Sendero Geoformas', @costo = 11000.00, @duracion = 120, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque6, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Avistaje de Cóndores Talampaya', @costo = 14500.00, @duracion = 180, @cupoMaximo = 15

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque7, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Ascenso Volcán Lanín', @costo = 48000.00, @duracion = 480, @cupoMaximo = 10
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque7, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Navegación Huechulafquen', @costo = 16000.00, @duracion = 120, @cupoMaximo = 50
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque7, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Bosque de Pehuenes', @costo = 10000.00, @duracion = 150, @cupoMaximo = 25

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque8, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Caminata Recta Tin Tin', @costo = 9000.00, @duracion = 120, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque8, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Sendero Ojo del Cóndor', @costo = 8500.00, @duracion = 90, @cupoMaximo = 15
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque8, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Valle Encantado Fotografía', @costo = 13000.00, @duracion = 240, @cupoMaximo = 12

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque9, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Balcón Norte Condorito', @costo = 9500.00, @duracion = 240, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque9, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Quebrada Profunda', @costo = 14000.00, @duracion = 360, @cupoMaximo = 15
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque9, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Leyendas Comechingonas', @costo = 7500.00, @duracion = 120, @cupoMaximo = 25

EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque10, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Potrero de la Aguada', @costo = 12000.00, @duracion = 180, @cupoMaximo = 20
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque10, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Flora y Fauna Quijadas', @costo = 8000.00, @duracion = 90, @cupoMaximo = 25
EXEC Actividades.sp_AltaActividadTuristica @idParque = @idParque10, @idTipoActividadTuristica = @idTipoAct,
    @nombre = 'Expedición Farallones', @costo = 22000.00, @duracion = 300, @cupoMaximo = 12


EXEC Actividades.sp_AltaGuiaAutorizacion @idGuia = @idGuia1, @idActividadTuristica = @idAct1

EXEC Actividades.sp_AltaGuiaAutorizacion @idGuia = @idGuia2, @idActividadTuristica = @idAct2

EXEC Actividades.sp_AltaGuiaAutorizacion @idGuia = @idGuia3, @idActividadTuristica = @idAct3

EXEC Actividades.sp_AltaGuiaAutorizacion @idGuia = @idGuia4, @idActividadTuristica = @idAct6


EXEC Actividades.sp_AltaActividadProgramada @idGuia = @idGuia1, @idActividadTuristica = @idAct1,
    @fecha = '2026-11-20', @horaInicio = '10:00:00', @observaciones = 'Simultánea 1'
SELECT @idProg1 = MAX(idActividadProgramada) FROM Actividades.ActividadProgramada WHERE idGuia = @idGuia1 AND idActividadTuristica = @idAct1;

EXEC Actividades.sp_AltaActividadProgramada @idGuia = @idGuia2, @idActividadTuristica = @idAct2,
    @fecha = '2026-11-20', @horaInicio = '10:00:00', @observaciones = 'Simultánea 2';
SELECT @idProg2 = MAX(idActividadProgramada) FROM Actividades.ActividadProgramada WHERE idGuia = @idGuia2 AND idActividadTuristica = @idAct2;

EXEC Actividades.sp_AltaActividadProgramada @idGuia = @idGuia3, @idActividadTuristica = @idAct3,
    @fecha = '2026-11-20', @horaInicio = '10:00:00', @observaciones = 'Simultánea 3';
SELECT @idProg3 = MAX(idActividadProgramada) FROM Actividades.ActividadProgramada WHERE idGuia = @idGuia3 AND idActividadTuristica = @idAct3;

-- ==========================================================
-- GENERACION Concesiones
-- ==========================================================

EXEC Concesiones.sp_AltaTipoActividadConcesion @nombre = 'Hoteleria y Gastronomia',
    @descripcionActividad = 'Servicios integrales.'
SELECT @idTipoConc = idTipoActividadConcesion FROM Concesiones.TipoActividadConcesion
WHERE nombre = 'Hoteleria y Gastronomia'


EXEC Concesiones.sp_AltaEmpresaConcesionaria '30123456789', 'Patagonia Aventuras S.A.', 'contacto@patagoniaaventuras.com'
SELECT @idEmp1 = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria
WHERE cuit = '30123456789'

EXEC Concesiones.sp_AltaEmpresaConcesionaria '30987654321', 'Iguazú Falls Services SRL', 'info@iguazufallsservices.com'
SELECT @idEmp2 = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria
WHERE cuit = '30987654321'

EXEC Concesiones.sp_AltaEmpresaConcesionaria '33444555669', 'Lagos del Sur Concesiones', 'gerencia@lagosdelsur.com'
SELECT @idEmp3 = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria
WHERE cuit = '33444555669'

EXEC Concesiones.sp_AltaEmpresaConcesionaria '30555666774', 'EcoCatering Parques', 'proveedores@ecocatering.com'
SELECT @idEmp4 = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria
WHERE cuit = '30555666774'

EXEC Concesiones.sp_AltaEmpresaConcesionaria '30888999112', 'Transportes del Norte', 'ventas@expresonorte.com'
SELECT @idEmp5 = idEmpresaConcesionaria FROM Concesiones.EmpresaConcesionaria
WHERE cuit = '30888999112'


EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp1, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque1, @fechaInicio = '2019-01-01', @fechaFin = '2024-01-01',
    @montoAlquiler = 150000.00, @estado = 'Vencida'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp1, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque1, @fechaInicio = '2025-01-01', @fechaFin = '2030-01-01',
    @montoAlquiler = 600000.00, @estado = 'Activa'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp2, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque2, @fechaInicio = '2024-01-01', @fechaFin = '2029-01-01',
    @montoAlquiler = 450000.00, @estado = 'Activa'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp2, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque3, @fechaInicio = '2023-05-01', @fechaFin = '2028-05-01',
    @montoAlquiler = 800000.00, @estado = 'Activa'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp3, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque4, @fechaInicio = '2020-03-01', @fechaFin = '2025-03-01',
    @montoAlquiler = 220000.00, @estado = 'Vencida'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp3, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque5, @fechaInicio = '2025-01-01', @fechaFin = '2027-01-01',
    @montoAlquiler = 120000.00, @estado = 'Activa'
EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp4, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque6, @fechaInicio = '2022-06-01', @fechaFin = '2027-06-01',
    @montoAlquiler = 350000.00, @estado = 'Activa'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp4, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque7, @fechaInicio = '2018-01-01', @fechaFin = '2023-01-01',
    @montoAlquiler = 90000.00,  @estado = 'Vencida'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp5, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque8, @fechaInicio = '2024-09-01', @fechaFin = '2029-09-01',
    @montoAlquiler = 180000.00, @estado = 'Activa'

EXEC Concesiones.sp_AltaConcesion @idEmpresaConcesionaria = @idEmp5, @idTipoActividadConcesion = @idTipoConc,
    @idParque = @idParque9, @fechaInicio = '2025-02-01', @fechaFin = '2028-02-01',
    @montoAlquiler = 290000.00, @estado = 'Activa'


-- ==========================================================
-- GENERACION Ventas
-- ==========================================================

EXEC Ventas.sp_AltaTipoVisitante @nombre = 'General', @descripcion = 'Extranjero'
SELECT @idTV1 = idTipoVisitante FROM Ventas.TipoVisitante WHERE nombre = 'General'

EXEC Ventas.sp_AltaTipoVisitante @nombre = 'Nacional', @descripcion = 'Argentino'
SELECT @idTV2 = idTipoVisitante FROM Ventas.TipoVisitante WHERE nombre = 'Nacional'

EXEC Ventas.sp_AltaTipoVisitante @nombre = 'Provincial', @descripcion = 'Local'
SELECT @idTV3 = idTipoVisitante FROM Ventas.TipoVisitante WHERE nombre = 'Provincial'

EXEC Ventas.sp_AltaTipoVisitante @nombre = 'Estudiante', @descripcion = 'Diferencial'
SELECT @idTV4 = idTipoVisitante FROM Ventas.TipoVisitante WHERE nombre = 'Estudiante'


EXEC Ventas.sp_AltaEntrada @idParque = @idParque1, @idTipoVisitante = @idTV1, @precio = 20000.00
SELECT @idEnt1 = idEntrada FROM Ventas.Entrada
WHERE idParque = @idParque1 AND idTipoVisitante = @idTV1

EXEC Ventas.sp_AltaEntrada @idParque = @idParque1, @idTipoVisitante = @idTV2, @precio = 10000.00
SELECT @idEnt2 = idEntrada FROM Ventas.Entrada
WHERE idParque = @idParque1 AND idTipoVisitante = @idTV2

EXEC Ventas.sp_AltaEntrada @idParque = @idParque2, @idTipoVisitante = @idTV1, @precio = 25000.00
SELECT @idEnt3 = idEntrada FROM Ventas.Entrada
WHERE idParque = @idParque2 AND idTipoVisitante = @idTV1

EXEC Ventas.sp_AltaEntrada @idParque = @idParque2, @idTipoVisitante = @idTV4, @precio = 5000.00
SELECT @idEnt4 = idEntrada FROM Ventas.Entrada
WHERE idParque = @idParque2 AND idTipoVisitante = @idTV4

EXEC Ventas.sp_AltaEntrada @idParque = @idParque3, @idTipoVisitante = @idTV3, @precio = 8000.00
SELECT @idEnt5 = idEntrada FROM Ventas.Entrada
WHERE idParque = @idParque3 AND idTipoVisitante = @idTV3


EXEC Ventas.sp_AltaVisitante 'John', 'Smith', 'john.smith@travel.com', 'New York 124', '+14555888'
SELECT @idVis1 = idVisitante FROM Ventas.Visitante WHERE email = 'john.smith@travel.com'

EXEC Ventas.sp_AltaVisitante 'Juan', 'Pérez', 'juan.perez@hotmail.com', 'Av. Santa Fe 1200', '1144445555'
SELECT @idVis2 = idVisitante FROM Ventas.Visitante WHERE email = 'juan.perez@hotmail.com'

EXEC Ventas.sp_AltaVisitante 'Marie', 'Dupont', 'marie.dupont@france.fr', 'Paris 45', NULL
SELECT @idVis3 = idVisitante FROM Ventas.Visitante WHERE email = 'marie.dupont@france.fr'

EXEC Ventas.sp_AltaVisitante 'Ana', 'Gomez', 'ana.gomez@gmail.com', 'San Martín 450', '3764112233'
SELECT @idVis4 = idVisitante FROM Ventas.Visitante WHERE email = 'ana.gomez@gmail.com'

EXEC Ventas.sp_AltaVisitante 'Carlos', 'Sánchez', 'carlos.sanchez@yahoo.com.ar', 'Belgrano 78', '2944556677'
SELECT @idVis5 = idVisitante FROM Ventas.Visitante WHERE email = 'carlos.sanchez@yahoo.com.ar'


EXEC Ventas.sp_AltaVenta @idVisitante = @idVis1, @formaPago = 'Tarjeta',
    @puntoVenta = 'Boletería Online', @total = 70000.00
SELECT @idVenta1 = MAX(idVenta) FROM Ventas.Venta WHERE idVisitante = @idVis1

EXEC Ventas.sp_AltaVenta @idVisitante = @idVis2, @formaPago = 'Efectivo',
    @puntoVenta = 'Portal Glaciares', @total = 20000.00
SELECT @idVenta2 = MAX(idVenta) FROM Ventas.Venta WHERE idVisitante = @idVis2

EXEC Ventas.sp_AltaVenta @idVisitante = @idVis3, @formaPago = 'Digital',
    @puntoVenta = 'Boletería Online', @total = 35000.00
SELECT @idVenta3 = MAX(idVenta) FROM Ventas.Venta WHERE idVisitante = @idVis3

EXEC Ventas.sp_AltaVenta @idVisitante = @idVis4, @formaPago = 'Transferencia',
    @puntoVenta = 'Portal Iguazú', @total = 10000.00
SELECT @idVenta4 = MAX(idVenta) FROM Ventas.Venta WHERE idVisitante = @idVis4

EXEC Ventas.sp_AltaVenta @idVisitante = @idVis5, @formaPago = 'Tarjeta',
    @puntoVenta = 'Portal Nahuel Huapi', @total = 8000.00
SELECT @idVenta5 = MAX(idVenta) FROM Ventas.Venta WHERE idVisitante = @idVis5


EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta1, @idEntrada = @idEnt1,
    @cantidad = 2, @precioUnitario = 20000.00, @fechaAcceso = '2026-01-15'

EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta1, @idEntrada = @idEnt2,
    @cantidad = 1, @precioUnitario = 10000.00, @fechaAcceso = '2026-01-15'

EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta2, @idEntrada = @idEnt2,
    @cantidad = 2, @precioUnitario = 10000.00, @fechaAcceso = '2026-02-14'

EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta3, @idEntrada = @idEnt3,
    @cantidad = 1, @precioUnitario = 25000.00, @fechaAcceso = '2026-03-25'

EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta4, @idEntrada = @idEnt4,
    @cantidad = 2, @precioUnitario = 5000.00,  @fechaAcceso = '2026-04-05'

EXEC Ventas.sp_AltaDetalleVenta @idVenta = @idVenta5, @idEntrada = @idEnt5,
    @cantidad = 1, @precioUnitario = 8000.00,  @fechaAcceso = '2026-05-15'


-- ==========================================================
-- GENERACION Contrataciones
-- ==========================================================

EXEC Actividades.sp_AltaDetalleContratacion @idVenta = @idVenta1, @costoTotal = 90000.00
SELECT @idDetCont1 = MAX(idDetalleContratacion) FROM Actividades.DetalleContratacion WHERE idVenta = @idVenta1

EXEC Actividades.sp_AltaDetalleContratacion @idVenta = @idVenta3, @costoTotal = 35000.00
SELECT @idDetCont2 = MAX(idDetalleContratacion) FROM Actividades.DetalleContratacion WHERE idVenta = @idVenta3


EXEC Actividades.sp_AltaContratacion @idDetalleContratacion = @idDetCont1,
    @idActividadProgramada = @idProg1, @costo = 45000.00, @estado = 'Completada', @cantidadPersonas = 2

EXEC Actividades.sp_AltaContratacion @idDetalleContratacion = @idDetCont2,
    @idActividadProgramada = @idProg2, @costo = 35000.00, @estado = 'Completada', @cantidadPersonas = 1

DECLARE @idDetCont3 INT, @idDetCont4 INT, @idDetCont5 INT;

EXEC Actividades.sp_AltaDetalleContratacion 
    @idVenta = @idVenta4, @costoTotal = 48000.00;
SELECT @idDetCont3 = MAX(idDetalleContratacion) 
    FROM Actividades.DetalleContratacion WHERE idVenta = @idVenta4;

EXEC Actividades.sp_AltaContratacion 
    @idDetalleContratacion = @idDetCont3,
    @idActividadProgramada = @idProg3, 
    @costo = 48000.00, @estado = 'Completada', @cantidadPersonas = 3;

DECLARE @idProg4_Aux INT;
SELECT @idProg4_Aux = MAX(idActividadProgramada) FROM Actividades.ActividadProgramada;

EXEC Actividades.sp_AltaDetalleContratacion 
    @idVenta = @idVenta5, @costoTotal = 62000.00;
SELECT @idDetCont4 = MAX(idDetalleContratacion) 
    FROM Actividades.DetalleContratacion WHERE idVenta = @idVenta5;

EXEC Actividades.sp_AltaContratacion 
    @idDetalleContratacion = @idDetCont4,
    @idActividadProgramada = @idProg4_Aux, 
    @costo = 62000.00, @estado = 'Completada', @cantidadPersonas = 4;

EXEC Actividades.sp_AltaDetalleContratacion 
    @idVenta = @idVenta2, @costoTotal = 27000.00;
SELECT @idDetCont5 = MAX(idDetalleContratacion) 
    FROM Actividades.DetalleContratacion WHERE idVenta = @idVenta2;

EXEC Actividades.sp_AltaContratacion 
    @idDetalleContratacion = @idDetCont5,
    @idActividadProgramada = @idProg1, 
    @costo = 27000.00, @estado = 'Completada', @cantidadPersonas = 1;

-- ==========================================================
-- PAGOS DE CANON
-- ==========================================================

DECLARE @idConc1 INT, @idConc2 INT, @idConc3 INT, 
        @idConc4 INT, @idConc5 INT;

SELECT @idConc1 = MIN(idConcesion) FROM Concesiones.Concesion 
    WHERE estado = 'Activa' AND idParque = @idParque1;
SELECT @idConc2 = MIN(idConcesion) FROM Concesiones.Concesion 
    WHERE estado = 'Activa' AND idParque = @idParque2;
SELECT @idConc3 = MIN(idConcesion) FROM Concesiones.Concesion 
    WHERE estado = 'Activa' AND idParque = @idParque3;
SELECT @idConc4 = MIN(idConcesion) FROM Concesiones.Concesion 
    WHERE estado = 'Activa' AND idParque = @idParque5;
SELECT @idConc5 = MIN(idConcesion) FROM Concesiones.Concesion 
    WHERE estado = 'Activa' AND idParque = @idParque6;

-- Cánones de 2025 (historial anterior)
EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc1, @fechaPago = '2025-03-10',
    @monto = 600000.00, @fechaVencimiento = '2025-03-31', @fechaEmision = '2025-03-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc2, @fechaPago = '2025-05-08',
    @monto = 450000.00, @fechaVencimiento = '2025-05-31', @fechaEmision = '2025-05-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc3, @fechaPago = '2025-09-15',
    @monto = 800000.00, @fechaVencimiento = '2025-09-30', @fechaEmision = '2025-09-01';

-- Cánones de 2026
EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc1, @fechaPago = '2026-01-12',
    @monto = 600000.00, @fechaVencimiento = '2026-01-31', @fechaEmision = '2026-01-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc1, @fechaPago = '2026-02-10',
    @monto = 600000.00, @fechaVencimiento = '2026-02-28', @fechaEmision = '2026-02-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc2, @fechaPago = '2026-01-15',
    @monto = 450000.00, @fechaVencimiento = '2026-01-31', @fechaEmision = '2026-01-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc3, @fechaPago = '2026-03-08',
    @monto = 800000.00, @fechaVencimiento = '2026-03-31', @fechaEmision = '2026-03-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc4, @fechaPago = '2026-04-20',
    @monto = 120000.00, @fechaVencimiento = '2026-04-30', @fechaEmision = '2026-04-01';

EXEC Concesiones.sp_AltaPagoCanon 
    @idConcesion = @idConc5, @fechaPago = '2026-05-05',
    @monto = 350000.00, @fechaVencimiento = '2026-05-31', @fechaEmision = '2026-05-01';

-- ==========================================================
-- DEMOSTRACION
-- ==========================================================

SELECT * FROM Parques.Parque
SELECT * FROM Actividades.ActividadTuristica
SELECT * FROM Actividades.ActividadProgramada
SELECT * FROM Guias.Guia
SELECT * FROM Personal.Guardaparque
SELECT * FROM Concesiones.Concesion
SELECT * FROM Ventas.Venta
SELECT * FROM Ventas.DetalleVenta
SELECT * FROM Actividades.DetalleContratacion
SELECT * FROM Actividades.Contratacion
