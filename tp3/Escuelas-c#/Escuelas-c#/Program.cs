using Escuelas_c_.Models;
using System;
using System.Collections.Generic;
using System.Data.SQLite;

public class Program
{
    public static void Main()
    {
        // Configurar la ruta al archivo .db
        string dbPath = "C:/SQLite/tp3/escuelas.db";
        string connectionString = $"Data Source={dbPath};Version=3;";

        var escuelaService = new EscuelaService(connectionString);

        //var escuelas = escuelaService.ObtenerEscuelasPorJurisdiccion("Córdoba");

        Console.WriteLine("Escuelas encontradas:");
        foreach (var escuela in escuelaService.ObtenerEscuelasPorJurisdiccion("Buenos Aires"))
        {
            Console.WriteLine($"- {escuela.Nombre} ({escuela.Localidad})");
        }
    }
}