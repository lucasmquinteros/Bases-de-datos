using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Escuelas_c_.Models
{
    public class Escuela
    {
        public string Nombre { get; set; }
        public string Id{ get; private set; }
        public string CueAnexo { get; set; }
        public string Domicilio { get; set; }
        public string Localidad { get; set; }
        public string Departamento { get; set; }
    }
}
