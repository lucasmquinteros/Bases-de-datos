class Carrera:
    def __init__(self, id, nombre):
        self.id = id
        self.nombre = nombre

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO Carrera (id, nombre)
            VALUES (?, ?)
        """, (self.id, self.nombre))
        conexion.commit()
