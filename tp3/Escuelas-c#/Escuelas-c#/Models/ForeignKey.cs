using System;
using System.Data;
using System.Collections.Generic;
using System.Data.SQLite;
using System.Diagnostics.Contracts;

namespace Barrios;

class ForeignKey
{
    public string texto { get; set; } 
    
    public ForeignKey(string texto) {
        this.texto = texto;
    }

    public ForeignKey() {}

    public void print() {
        if (String.IsNullOrEmpty(this.texto))
            Console.WriteLine("No tiene");
        else
            Console.WriteLine($"\t- {this.texto}");
    }
}

