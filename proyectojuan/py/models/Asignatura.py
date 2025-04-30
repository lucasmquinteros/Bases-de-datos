class Asignatura:
    def __init__(self, id, nombre, creditos, id_carrera):
        self.id = id
        self.nombre = nombre
        self.creditos = creditos
        self.id_carrera = id_carrera

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO Asignatura (id, nombre, creditos, id_carrera)
            VALUES (?, ?, ?, ?)
        """, (self.id, self.nombre, self.creditos, self.id_carrera))
        conexion.commit()
