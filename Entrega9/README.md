# Entrega 9: Aplicación Web de Gestión e Integración - Grupo 5

Para cumplir con los requerimientos de la **Novena Entrega**, desarrollamos una aplicación web ágil utilizando **Spring Boot 4.x**, **JPA/Hibernate** y **Thymeleaf**. El sistema implementa una arquitectura limpia por capas y se conecta de forma nativa a la base de datos relacional `Com5600G05_ParquesNacionales` en SQL Server.

### Objetivos Implementados
1. **Módulo ABM Completo:** Gestión de operaciones sobre la tabla `Ventas.visitante`, forzando a que las inserciones, modificaciones y bajas se ejecuten estrictamente a través de los Procedimientos Almacenados de la *Entrega 3*.
2. **Integración con Reportes (Entrega 7):** Un módulo de descarga interactiva que invoca nuestro procedimiento nativo `Reportes.sp_MatrizVisitasXML`, obteniendo la matriz cruzada de visitas anuales pivotada por el motor y exportándola como un archivo `.xml` descargable.

---

## Instrucciones de Configuración y Despliegue

### 0. Configuración de Red Local (SQL Server)

Si al intentar levantar la aplicación Java el backend se queda congelado o arroja un error de tipo `SocketTimeoutException` o `Connection refused`, significa que el motor de SQL Server local tiene el protocolo de red TCP/IP desactivado por defecto. 

Para habilitarlo y dejar el entorno listo en 2 minutos, siga este paso a paso estricto en su máquina:

1. **Abrir la consola de administración:** Presione las teclas `Windows + R`, escriba `compmgmt.msc` *(Administración de equipos)* y presione **Enter**.
2. **Localizar los protocolos:** En la columna izquierda, navegue hasta el fondo en **Servicios y Aplicaciones** ➔ Despliegue **Configuración de red de SQL Server** (SQL Server Configuration Manager) ➔ Haga clic en **Protocolos de SQLEXPRESS** *(SQL Server Network Configuration)*.
3. **Habilitar TCP/IP:** En el panel central derecho, haga doble clic sobre el protocolo **TCP/IP**:
   * En la pestaña **Protocolo**: Cambie la opción **Habilitado** a **Sí** (En caso de estar en ingles **Enabled** y cambiar a **yes**).
   * En la pestaña **Direcciones IP**: Baje con el scroll hasta el fondo de todo (sección **IPAll**). Borre cualquier número que figure en *Puertos dinámicos TCP (TCP Dynamic Ports)* (debe quedar completamente vacío) y en el campo **Puerto TCP** escriba rigurosamente `1433`.
   * Haga clic en **Aplicar** y **Aceptar**.
4. **Reiniciar el Motor:** En la misma columna izquierda de la ventana, suba hasta el nodo **Servicios**, busque el servicio principal llamado **SQL Server (SQLEXPRESS)** *(o su instancia correspondiente)*, haga clic derecho sobre él y seleccione **Reiniciar**.


### 1. Requisito Previo (Base de Datos)
Antes de iniciar la aplicación, asegúrese de haber ejecutado la totalidad de los scripts de creación, lógica y carga de datos en el orden estricto especificado en el **README principal** de la raíz del repositorio. 

> **Credenciales del Servidor (Configuración Unificada):**
> Al ejecutar nuestro script `01_setup.sql`, el motor de base de datos configurará automáticamente la contraseña grupal y activará el login del administrador (`sa`). Por lo tanto, el entorno queda unificado por defecto con los siguientes datos:
> * **`username`**: sa
> * **`password`**: Grupo05_tp2026

### 2. Configuración del Entorno Java
1. Importe el contenido de esta carpeta (`Entrega9`) en su IDE (Eclipse, IntelliJ, etc.) como un **Existing Maven Project**.
2. Abra el archivo de configuración en `src/main/resources/application.yaml` y verifique que las credenciales coincidan con las mencionadas arriba.

>Nota de conectividad: La aplicación está configurada para escuchar de forma segura en el puerto **`8090`** (`server.port: 8090`) para evitar conflictos con servicios locales colgados en el puerto estándar.*

### 3. Ejecución del Sistema
1. Localice la clase principal en: `src/main/java/com/unlam/parques/ParquesApplication.java`.
2. Haga clic derecho sobre el archivo y seleccione **Run As -> Java Application**.
3. Una vez que la consola indique que el servidor Tomcat inició correctamente, abra su navegador e ingrese a:
   **http://localhost:8090/visitantes**
