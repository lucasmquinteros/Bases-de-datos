using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Data.SQLite;

//Install-Package System.Data.SQLite

namespace Escuelas_c_.Models
{
    public class EscuelaService
    {
        private readonly string _connectionString;

        public EscuelaService(string connectionString)
        {
            _connectionString = connectionString;
        }

        public List<Escuela> ObtenerEscuelasPorJurisdiccion(string jurisdiccion)
        {
            var resultados = new List<Escuela>();

            using (var conn = new SQLiteConnection(_connectionString))
            {
                //comando de sql que quiero ejecutar
                var cmd = new SQLiteCommand(
                    @"SELECT e.nombre, e.cue_anexo, e.domicilio, 
                         l.nombre as localidad, d.nombre as departamento
                  FROM escuela e
                  JOIN localidad l ON e.localidad_id = l.id
                  JOIN departamento d ON l.depto_id = d.id
                  JOIN jurisdiccion j ON d.jurisdiccion_id = j.id
                  WHERE j.nombre = @jurisdiccion and l.nombre = 'SAN NICOLAS DE LOS ARROYOS'", conn);
                //cambiar el valor del comando usando el string que pase yo explicitamente
                cmd.Parameters.AddWithValue("@jurisdiccion", jurisdiccion);
                //abrir mi conexion al archivo en sqlite
                conn.Open();
                //crear una variable tipo lector de sqlite
                var reader = cmd.ExecuteReader();
                //ejecutar el comando de sqlite en mi base de datos
                while (reader.Read())
                {
                    resultados.Add(new Escuela
                    {
                        Nombre = reader["nombre"].ToString(),
                        CueAnexo = reader["cue_anexo"].ToString(),
                        Domicilio = reader["domicilio"].ToString(),
                        Localidad = reader["localidad"].ToString(),
                        Departamento = reader["departamento"].ToString()
                    });
                }
            }

            return resultados;
        }
        public bool ActualizarEscuela(Escuela escuela)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                using (var transaction = conn.BeginTransaction())
                {
                    try
                    {
                        var cmd = new SqlCommand("sp_ActualizarEscuela", conn, transaction)
                        {
                            CommandType = CommandType.StoredProcedure
                        };

                        cmd.Parameters.AddWithValue("@id", escuela.Id);
                        cmd.Parameters.AddWithValue("@nombre", escuela.Nombre);
                        // ... otros parámetros

                        int affectedRows = cmd.ExecuteNonQuery();

                        transaction.Commit();
                        return affectedRows > 0;
                    }
                    catch
                    {
                        transaction.Rollback();
                        return false;
                    }
                }
            }
        }
    }
}
