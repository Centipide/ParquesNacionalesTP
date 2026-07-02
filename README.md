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

Para garantizar el correcto funcionamiento del ecosistema relacional de la base de datos, toda la solución se encuentra unificada dentro del archivo `Com5600G05_ParquesNacionales.ssmssln`. Los scripts deben ejecutarse de forma secuencial desde **SQL Server Management Studio (SSMS)** respetando la estructura de nomenclatura **`XYY`** detallada a continuación.

### Explicación de la Nomenclatura (`XYY`)
Para facilitar el despliegue automático del motor evitando conflictos de dependencias, cada script utiliza un prefijo jerárquico:
* **`0YY` (X = 0):** Estructura base, esquemas, datos semilla y lógica de negocio core.
* **`1YY` (X = 1):** Módulo analítico y procedimientos de extracción de Reportes (retorno XML).
* **`2YY` (X = 2):** Capa transaccional de Seguridad, funciones de cifrado y asignación granular de Roles.
* **`3YY` (X = 3):** Suite independiente de pruebas unitarias de regresión y Testing lógico.

---

### Orden Estricto de Despliegue funcional

Abra la solución en SSMS y ejecute los archivos en el orden exacto de los siguientes bloques funcionales:

#### PASO 1: Construcción del Núcleo y Carga Inicial (`001` al `009`)
Este bloque inicializa la base de datos, levanta los esquemas relacionales, aplica los procedimientos ABM esenciales, inyecta los datos requeridos por los criterios de aceptación y procesa la migración masiva de los datasets externos.
1. `001_setup.sql` (Configura el entorno global, esquemas y fuerza la activación segura del usuario sa).
2. `002_creacionTablas.sql` (Construye las entidades físicas y restricciones de integridad).
3. `003_ABM.sql` (Encapsula estrictamente las operaciones de persistencia mediante stored procedures).
4. `004_logicaVentaEntradas.sql` (Despliega las reglas transaccionales de negocio para tickets y facturación).
5. `005_logicaRegistroActividades.sql` (Módulo transaccional de tours y visitas guiadas).
6. `006_logicaAsignacionGuias.sql` (Control de personal y vigencia de habilitaciones de guías).
7. `007_logicaGestionConcesiones.sql` (Validación de cánones mensuales, comercios y estados contractuales).
8. `008_cargaDatos.sql` (Población masiva de registros semilla y casos obligatorios de control para testing).
9. `009_logicalmportacionDatos.sql` (Proceso aislado de migración de datasets externos con lógica robusta de Upsert).

#### PASO 2: Módulo de Reportes Estructurados (`101` al `105`)
Una vez que el núcleo tiene datos consistentes, ejecute consecutivamente estos archivos para compilar las funciones analíticas y los reportes de exportación consumidos nativamente por la aplicación Java:
* `101_logicaTestingReporteVisitas.sql`
* `102_LogicaTestingReporteIngresosPorParque.sql`
* `103_logicaTestingReporteDeudores.sql`
* `104_logicaTestingReporteMatrizVisitas.sql`
* `105_logicaTestingReporteParquesYConcesiones.sql`

#### PASO 3: Despliegue de la Capa de Seguridad (`201` al `205`)
Ejecute este bloque final para aplicar las rutinas transaccionales de enmascaramiento sobre las columnas críticas identificadas y estructurar la permisología por roles.
* `201_encriptacion.sql` (Funciones de encriptación simétrica/asimétrica sobre columnas sensibles).
* `202_ABMconEncriptacion.sql` (Actualización de los SPs core para la lectura/escritura de datos cifrados).
* `203_migracionADatosEncriptados.sql` (Script de alteración masiva e inyección segura sobre los datos existentes).
* `204_testingABMEncriptacion.sql` (Verificación de consistencia del enmascaramiento).
* `205_Roles.sql` (Creación de perfiles funcionales con asignación granular de accesos al motor).

---

### Suite de Validación Lógica e Integridad (`301` al `306`)
De acuerdo con las pautas de diseño arquitectónico de la cátedra, los scripts de testing técnico se encuentran completamente aislados de la creación de objetos. Pueden ejecutarse de forma independiente posterior al **Paso 1** para comprobar la robustez de las validaciones del modelo:
* `301_testingABM.sql` (Pruebas de restricciones sobre tablas base).
* `302_testingVentaEntradas.sql` (Verificación de transacciones concurrentes y flujos de facturación).
* `303_testingRegistroActividades.sql` (Validación de alertas por cupos máximos sobrepasados).
* `304_testingAsignacionGuias.sql` (Control de alertas de vigencia de habilitación).
* `305_testingGestionConcesiones.sql` (Pruebas de consistencia de estados e impagos).
* `306_testingImportacionDatos.sql` (Validación de control de errores de formato y prevención de duplicados).
