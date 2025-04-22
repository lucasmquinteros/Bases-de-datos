using Barrios;
using Escuelas_c_.Models;
using System;
using System.Data;
using System.Collections.Generic;
using System.Data.SQLite;

public class Program
{
    public static void Main()
    {
        // Configurar la ruta al archivo .db
        string dbPath = "C:/SQLite/tp3/escuelas.db";
        //string connectionString = $"Data Source={dbPath};Version=3;";
        string connectionString = "SERVER=localhost\\SQLEXPRESS;DATABASE=Aeropuerto;Trusted_Connection=yes;";

        var escuelaService = new EscuelaService(connectionString);
        /*

        //var escuelas = escuelaService.ObtenerEscuelasPorJurisdiccion("Córdoba");

        Console.WriteLine("Escuelas encontradas:");
        foreach (var escuela in escuelaService.ObtenerEscuelasPorJurisdiccion("Buenos Aires"))
        {
            Console.WriteLine($"- {escuela.Nombre} ({escuela.Localidad})");
        }
        
        List<Tabla> tablas = new List<Tabla>();
        using (var connection = new SQLiteConnection(connectionString))
        {
            connection.Open();
            var command = connection.CreateCommand();
            command.CommandText = "SELECT name, sql from sqlite_master where type = 'table'";

            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    var tabla = reader.GetString(0);
                    var sql = reader.GetString(1);
                    tablas.Add(new Tabla(connection, tabla, sql));
                }
            }
            foreach (Tabla t in tablas)
            {
                t.print();
        }
            }*/
        var analisis = escuelaService.AnalizarEsquemaBaseDatos();
        foreach (DataRow row in analisis.Rows)
        {
            Console.WriteLine($"{row["TipoObjeto"]} {row["NombreObjeto"]} - {row["TipoElemento"]}: {row["NombreElemento"]} | {row["Detalles"]}");
        }
    }
}