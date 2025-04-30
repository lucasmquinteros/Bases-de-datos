from models.Alumno import Alumno
from models.Carrera import Carrera
from models.Database import Database


alumnno1 = Alumno("1", "Juan", "Pérez", "12345678", "2000-01-01", "juan@gmail.com", "123456789", "CalleFalsa 123", "2023-01-01", "Activo")
db = Database("C:/SQLite/proyectojuan/facultad.db")
db.insertar_alumno(alumnno1)
db.close()
    