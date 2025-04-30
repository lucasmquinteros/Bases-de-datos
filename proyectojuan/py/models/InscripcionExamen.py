class InscripcionExamen:
    def __init__(self, id, id_alumno, id_examenfinal, estado, calificacion):
        self.id = id
        self.id_alumno = id_alumno
        self.id_examenfinal = id_examenfinal
        self.estado = estado
        self.calificacion = calificacion

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO InscripcionExamen (id, id_alumno, id_examenfinal, estado, calificacion)
            VALUES (?, ?, ?, ?, ?)
        """, (self.id, self.id_alumno, self.id_examenfinal, self.estado, self.calificacion))
        conexion.commit()
