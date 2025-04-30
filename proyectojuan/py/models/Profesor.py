class Profesor:
    def __init__(self, id, nombre, apellido, titulo, id_departamento):
        self.id = id
        self.nombre = nombre
        self.apellido = apellido
        self.titulo = titulo
        self.id_departamento = id_departamento

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO Profesor (id, nombre, apellido, titulo, id_departamento)
            VALUES (?, ?, ?, ?, ?)
        """, (self.id, self.nombre, self.apellido, self.titulo, self.id_departamento))
        conexion.commit()
