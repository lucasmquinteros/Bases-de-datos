class ExamenFinal:
    def __init__(self, id, fecha, id_asignatura, id_profesor, llamado):
        self.id = id
        self.fecha = fecha
        self.id_asignatura = id_asignatura
        self.id_profesor = id_profesor
        self.llamado = llamado

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO ExamenFinal (id, fecha, id_asignatura, id_profesor, llamado)
            VALUES (?, ?, ?, ?, ?)
        """, (self.id, self.fecha, self.id_asignatura, self.id_profesor, self.llamado))
        conexion.commit()
