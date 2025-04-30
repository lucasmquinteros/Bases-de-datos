from models.Alumno import Alumno
from models.Carrera import Carrera
from models.Database import Database
import sqlite3


#db = Database("C:/SQLite/proyectojuan/facultad.db")
connection = sqlite3.connect("C:/SQLite/proyectojuan/facultad.db")
cursor =connection.cursor()

cursor.execute("SELECT * from Alumno")

#alumno =  db.get_alumno("12345678")
#carrera1 = Carrera("1", "Ingeniería en Sistemas")
#db.insertar_carrera(carrera1)
#db.close()
    