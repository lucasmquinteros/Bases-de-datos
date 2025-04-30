import sqlite3
from . import Alumno
from . import Carrera


class Database:
    def __init__(self, db_path: str):
        self.connection = sqlite3.connect(db_path)
        self.cursor = self.connection.cursor()

    def create_table(self, table_name: str, columns: dict):
        columns_with_types = ", ".join([f"{col} {col_type}" for col, col_type in columns.items()])
        self.cursor.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({columns_with_types})")
        self.connection.commit()

    def insert(self, table_name: str, data: dict):
        columns = ", ".join(data.keys())
        placeholders = ", ".join("?" * len(data))
        values = tuple(data.values())
        self.cursor.execute(f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})", values)
        self.connection.commit()

    def fetch_all(self, table_name: str):
        self.cursor.execute(f"SELECT * FROM {table_name}")
        return self.cursor.fetchall()
    
    def insertar_alumno(self, alumno: Alumno):
        print(f"Insertando alumno: {alumno.nombre} {alumno.apellido}")
        self.cursor.execute("SELECT * FROM Alumno WHERE dni = ?", (alumno.dni,))
        if self.cursor.fetchone() is not None:
            print(f"El alumno con DNI {alumno.dni} ya existe. No se insertará.")
            return
        self.cursor.execute("""
            INSERT INTO Alumno (id, nombre, apellido, dni, fechaNacimiento, email, telefono, direccion, fechaIngreso, estado)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (alumno.id, alumno.nombre, alumno.apellido, alumno.dni, alumno.fecha_nacimiento,
              alumno.email, alumno.telefono, alumno.direccion, alumno.fecha_ingreso, alumno.estado))
        self.connection.commit()

    def insertar_carrera(self, carrera: Carrera):
        print(f"Insertando carrera: {carrera}")
        self.cursor.execute("""
            INSERT INTO Carrera (id, nombre)
            VALUES (?, ?)
        """, (carrera.id, carrera.nombre))
        self.connection.commit()

    def get_alumno(self, dni: str):
        self.cursor.execute("SELECT * FROM Alumno WHERE dni = ?", (dni,))
        result = self.cursor.fetchone()
        if result:
            print(f"Alumno encontrado: {result}")
            return result
        print(f"No se encontró un alumno con DNI {dni}.")
        return None

    def close(self):
        self.connection.close()
