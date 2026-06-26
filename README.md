# Sistema de Gestión de Parques Nacionales

**Universidad Nacional de La Matanza**  
**Departamento de Ingeniería e Investigaciones Tecnológicas**  
**Asignatura:** Bases de Datos Aplicada  
**Año 2026 1° Cuatrimestre**   
**Comisión:** 02-5600
**Profesores:**
 - BOSSERO, JULIO CESAR  
 - HNATIUK, JAIR EZEQUIEL  

---

## **Grupo:** 05:

| Apellido y Nombre | GitHub |
|---|---|
| Ayala Bustos, Gustavo Gabriel | [TejonCosmico](https://github.com/TejonCosmico) |
| Bonfigli, Leonardo | [lb-leoo02](https://github.com/lb-leoo02) |
| Casale Benavente, Pedro Santino | [Centipide](https://github.com/Centipide) |
| Martinez Souto, Joaquin | [NeonCUCHAU](https://github.com/NeonCUCHAU) |

---

## Instrucciones de Ejecución

Conectarse a una instancia de SQL Server 2019 o superior desde SSMS y ejecutar los scripts en el siguiente orden:
01_setup.sql  
02_creacionTablas.sql  
03_ABM.sql  
05_logicaVentaEntradas.sql  
07_logicaRegistroActividades.sql  
09_logicaAsignacionGuias.sql  
11_logicaGestionConcesiones.sql  
13_logicaImportacionDatos.sql  
00_cargaDatos.sql  
> Los scripts de testing (archivos pares) son independientes y pueden ejecutarse después del script de lógica correspondiente.  
> El script `00_cargaDatos.sql` debe ejecutarse **después** de todos los scripts de creación y lógica.
