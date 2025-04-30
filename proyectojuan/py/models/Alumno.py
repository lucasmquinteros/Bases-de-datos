class Alumno:
    def __init__(self, id, nombre, apellido, dni, fecha_nacimiento, email, telefono, direccion, fecha_ingreso, estado):
        self.id = id
        self.nombre = nombre
        self.apellido = apellido
        self.dni = dni
        self.fecha_nacimiento = fecha_nacimiento
        self.email = email
        self.telefono = telefono
        self.direccion = direccion
        self.fecha_ingreso = fecha_ingreso
        self.estado = estado

    def guardar(self, conexion):
        cursor = conexion.cursor()
        cursor.execute("""
            INSERT INTO Alumno (id, nombre, apellido, dni, fechaNacimiento, email, telefono, direccion, fechaIngreso, estado)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (self.id, self.nombre, self.apellido, self.dni, self.fecha_nacimiento,
              self.email, self.telefono, self.direccion, self.fecha_ingreso, self.estado))
        conexion.commit()
