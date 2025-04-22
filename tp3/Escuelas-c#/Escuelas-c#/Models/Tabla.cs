using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Data.SQLite;
namespace Barrios;

class Tabla
{
    public string name { get; set; } 
    public string sql { get; set; }


    SQLiteConnection conn;
    public Tabla(SQLiteConnection conn,string name, string sql) {
        this.conn = conn;
        this.name = name;
        this.sql = sql;
    }

    public Tabla() {}

    public void print() {
        Console.WriteLine("#------------------------------------------#");
        Console.WriteLine($"#----- Tabla: {this.name}");
        Console.WriteLine("#------------------------------------------#");
        Console.WriteLine($"SQL: {this.sql}");

        foreach(Columna c in getCols(conn, this.name)) {
            c.print();
        }        
        foreach(ForeignKey fk in getFKs(conn, this.name)) {
            fk.print();
        }
    }

    List<Columna> getCols(SQLiteConnection conn, string tabla) {
        List<Columna> columnas = new List<Columna>();
        string sql = @"select cid,name,type,""notnull"" as not_null,
            ifnull(dflt_value,'No asignado'),pk 
            from pragma_table_info('{tabla}')";
        Console.WriteLine($"#---- Columnas de la tabla {tabla}:");
        var command = conn.CreateCommand();
        command.CommandText = sql;
        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                var id = reader.GetString(0);
                var name = reader.GetString(1);
                var type = reader.GetString(2);
                var notnull = reader.GetString(3);
                var default_value = reader.GetString(4);
                var ispk = reader.GetString(5);
                columnas.Add(new Columna(id,name,type,notnull,default_value,ispk));
            }
        }
        return columnas;
    }

    List<ForeignKey> getFKs(SQLiteConnection conn, string tabla) {
        List<ForeignKey> fks = new List<ForeignKey>();
        string sql = @"select 'Columna '||""from""||'->'||""table""||'('||""to""||')' 
        as texto 
        from pragma_foreign_key_list('{tabla}')";
        Console.WriteLine($"#---- Foreign Keys de la tabla {tabla}:");
        var command = conn.CreateCommand();
        command.CommandText = sql;
        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                var texto = reader.GetString(0);
                fks.Add(new ForeignKey(texto));
            }
        }
        return fks;
    }
}