using System;
using System.Data;
using System.Collections.Generic;
using System.Data.SQLite;

namespace Barrios;

class Columna
{
    public string id { get; set; } 
    public string name { get; set; } 
    public string type { get; set; } 
    public string not_null { get; set; } 
    public string default_value { get; set; } 
    public string ispk { get; set; } 

    public Columna(string id, string name, string type, string not_null, string default_value, string ispk) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.not_null = not_null;
        this.default_value = default_value;
        this.ispk = ispk;
    }

    public Columna() {}

    public void print() {
        Console.WriteLine($"\t- Id: {this.id}");
        Console.WriteLine($"\t- Name: {this.name}");
        Console.WriteLine($"\t- Type: {this.type}");
        Console.WriteLine($"\t- Not Null: {this.not_null}");
        Console.WriteLine($"\t- Default Value: {this.default_value}");
        Console.WriteLine($"\t- Is PK: {this.ispk}");
        Console.WriteLine();
    }
}