package com.unlam.parques.service;

import com.unlam.parques.model.Visitante;
import com.unlam.parques.repository.VisitanteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.ArrayList;

@Service
public class VisitanteService {

    @Autowired
    private VisitanteRepository repo;

    @PersistenceContext
    private EntityManager entityManager;

    private static final String CLAVE_NUEVA = "FraseSecreta123";
    private static final String CLAVE_HISTORICA = "claveVisitantes";

    /**
     * 1. LISTAR VISITANTES
     */
    @SuppressWarnings("unchecked")
    public List<Visitante> listar() {
        String query = 
            "DECLARE @SqlNativo NVARCHAR(MAX); " +
            "IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Ventas.Visitante') AND name = 'emailCifrado') " +
            "BEGIN " +
            "    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Ventas.Visitante') AND name = 'email') " +
            "    BEGIN " +
            "        SET @SqlNativo = N'SELECT idVisitante, nombre, apellido, direccion, email, telefono, " +
            "        ISNULL(" +
            "            CONVERT(VARCHAR(100), DecryptByPassPhrase(''' + REPLACE(:fraseNueva, '''', '''''') + ''', emailCifrado, 1, CONVERT(VARBINARY, idVisitante))), " +
            "            CONVERT(VARCHAR(100), DecryptByPassPhrase(''' + REPLACE(:fraseVieja, '''', '''''') + ''', emailCifrado, 1, CONVERT(VARBINARY, idVisitante)))" +
            "        ) AS emailDescifrado, " +
            "        ISNULL(" +
            "            CONVERT(VARCHAR(20), DecryptByPassPhrase(''' + REPLACE(:fraseNueva, '''', '''''') + ''', telefonoCifrado, 1, CONVERT(VARBINARY, idVisitante))), " +
            "            CONVERT(VARCHAR(20), DecryptByPassPhrase(''' + REPLACE(:fraseVieja, '''', '''''') + ''', telefonoCifrado, 1, CONVERT(VARBINARY, idVisitante)))" +
            "        ) AS telefonoDescifrado " +
            "        FROM Ventas.Visitante'; " +
            "    END " +
            "    ELSE " +
            "    BEGIN " +
            "        SET @SqlNativo = N'SELECT idVisitante, nombre, apellido, direccion, NULL AS email, NULL AS telefono, " +
            "        ISNULL(" +
            "            CONVERT(VARCHAR(100), DecryptByPassPhrase(''' + REPLACE(:fraseNueva, '''', '''''') + ''', emailCifrado, 1, CONVERT(VARBINARY, idVisitante))), " +
            "            CONVERT(VARCHAR(100), DecryptByPassPhrase(''' + REPLACE(:fraseVieja, '''', '''''') + ''', emailCifrado, 1, CONVERT(VARBINARY, idVisitante)))" +
            "        ) AS emailDescifrado, " +
            "        ISNULL(" +
            "            CONVERT(VARCHAR(20), DecryptByPassPhrase(''' + REPLACE(:fraseNueva, '''', '''''') + ''', telefonoCifrado, 1, CONVERT(VARBINARY, idVisitante))), " +
            "            CONVERT(VARCHAR(20), DecryptByPassPhrase(''' + REPLACE(:fraseVieja, '''', '''''') + ''', telefonoCifrado, 1, CONVERT(VARBINARY, idVisitante)))" +
            "        ) AS telefonoDescifrado " +
            "        FROM Ventas.Visitante'; " +
            "    END " +
            "END " +
            "ELSE " +
            "BEGIN " +
            "    SET @SqlNativo = N'SELECT idVisitante, nombre, apellido, direccion, email, telefono, " +
            "    NULL AS emailDescifrado, NULL AS telefonoDescifrado " +
            "    FROM Ventas.Visitante'; " +
            "END; " +
            "EXEC sp_executesql @SqlNativo;";
                       
        List<Object[]> resultados = entityManager.createNativeQuery(query)
                                                 .setParameter("fraseNueva", CLAVE_NUEVA)
                                                 .setParameter("fraseVieja", CLAVE_HISTORICA)
                                                 .getResultList();
        List<Visitante> visitantes = new ArrayList<>();
        
        String checkColumns = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Ventas.Visitante') AND name = 'emailCifrado'";
        boolean modoSeguridadActivo = !entityManager.createNativeQuery(checkColumns).getResultList().isEmpty();
        
        for (Object[] fila : resultados) {
            Visitante v = new Visitante();
            v.setIdVisitante((Integer) fila[0]);
            v.setNombre((String) fila[1]);
            v.setApellido((String) fila[2]);
            v.setDireccion((String) fila[3]);
            
            String emailPlano = (String) fila[4];
            String telefonoPlano = (String) fila[5];
            String emailDescifrado = (String) fila[6];
            String telefonoDescifrado = (String) fila[7];
            
            if (emailPlano != null && !emailPlano.trim().isEmpty()) {
                v.setEmail(emailPlano);
            } else if (emailDescifrado != null && !emailDescifrado.trim().isEmpty()) {
                v.setEmail(emailDescifrado);
            } else {
                v.setEmail(modoSeguridadActivo ? "[ENCRIPTADO]" : "N/A");
            }
            
            if (telefonoPlano != null && !telefonoPlano.trim().isEmpty()) {
                v.setTelefono(telefonoPlano);
            } else if (telefonoDescifrado != null && !telefonoDescifrado.trim().isEmpty()) {
                v.setTelefono(telefonoDescifrado);
            } else {
                v.setTelefono(modoSeguridadActivo ? "N/A" : "N/A"); 
            }
            
            visitantes.add(v);
        }
        return visitantes;
    }

    /**
     * 2. BUSCAR UN VISITANTE POR ID
     * Recupera un único registro descifrando sus datos personales de forma segura.
     */
    public Visitante buscar(Integer id) {
        // Buscamos el objeto base usando el listado híbrido para garantizar el descifrado correcto
        return this.listar().stream()
                   .filter(v -> v.getIdVisitante().equals(id))
                   .findFirst()
                   .orElse(null);
    }

    /**
     * 3. GUARDAR VISITANTE
     */
    @Transactional
    public void guardar(Visitante v) {
        String checkParam = "SELECT 1 FROM sys.parameters WHERE object_id = OBJECT_ID('Ventas.sp_AltaVisitante') AND name = '@FraseClave'";
        boolean spPideFrase = !entityManager.createNativeQuery(checkParam).getResultList().isEmpty();
        
        if (spPideFrase) {
            entityManager.createNativeQuery(
                "EXEC Ventas.sp_AltaVisitante @nombre = :nom, @apellido = :ape, @email = :em, @direccion = :dir, @telefono = :tel, @FraseClave = :frase")
                .setParameter("nom", v.getNombre())
                .setParameter("ape", v.getApellido())
                .setParameter("em", v.getEmail())
                .setParameter("dir", v.getDireccion())
                .setParameter("tel", v.getTelefono())
                .setParameter("frase", CLAVE_NUEVA)
                .executeUpdate();
        } else {
            entityManager.createNativeQuery(
                "EXEC Ventas.sp_AltaVisitante @nombre = :nom, @apellido = :ape, @email = :em, @direccion = :dir, @telefono = :tel")
                .setParameter("nom", v.getNombre())
                .setParameter("ape", v.getApellido())
                .setParameter("em", v.getEmail())
                .setParameter("dir", v.getDireccion())
                .setParameter("tel", v.getTelefono())
                .getResultList(); 
        }
    }

    /**
     * 4. ELIMINAR VISITANTE
     */
    @Transactional
    public void eliminar(Integer id) {
        repo.deleteById(id);
    }

    /**
     * 5. OBTENER MATRIZ DE VISITAS EN XML
     */
    public String obtenerMatrizVisitasXml() {
        try {
            return (String) entityManager.createNativeQuery(
                "EXEC Reportes.sp_TestingReporteMatrizVisitas") 
                .getSingleResult();
        } catch (Exception e) {
            return "<error>No se pudo generar la matriz XML</error>";
        }
    }
}