-- Crear tabla Institucion
CREATE TABLE Institucion (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Direccion VARCHAR(128) NOT NULL
);

-- Crear tabla Carrera
CREATE TABLE Carrera (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL
);

-- Crear tabla InstitucionxCarrera (tabla de relación)
CREATE TABLE InstitucionxCarrera (
    Id_Institucion INTEGER NOT NULL,
    Id_Carrera INTEGER NOT NULL,
    PRIMARY KEY (Id_Institucion, Id_Carrera),
    FOREIGN KEY (Id_Institucion) REFERENCES Institucion(Id),
    FOREIGN KEY (Id_Carrera) REFERENCES Carrera(Id)
);

-- Crear tabla Departamento
CREATE TABLE Departamento (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Integrantes VARCHAR(128) NOT NULL,
    Id_carrera INTEGER NOT NULL,
    FOREIGN KEY (Id_carrera) REFERENCES Carrera(Id)
);

-- Crear tabla Regimen
CREATE TABLE Regimen (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL
);

-- Crear tabla Area
CREATE TABLE Area (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL
);

-- Crear tabla PlanEstudio
CREATE TABLE PlanEstudio (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Año DATETIME NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    AñoFin DATETIME,  -- Puede ser NULL
    Id_carrera INTEGER NOT NULL,
    FOREIGN KEY (Id_carrera) REFERENCES Carrera(Id)
);

-- Crear tabla Cuatrimestre
CREATE TABLE Cuatrimestre (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Id_plan INTEGER NOT NULL,
    Nro INTEGER NOT NULL,
    FOREIGN KEY (Id_plan) REFERENCES PlanEstudio(Id)
);

-- Crear tabla Asignatura
CREATE TABLE Asignatura (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Hsemanal INTEGER NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Htotales INTEGER NOT NULL,
    Creditos INTEGER NOT NULL,
    Id_area INTEGER NOT NULL,
    Id_Regimen INTEGER NOT NULL,
    Id_depto INTEGER NOT NULL,
    FOREIGN KEY (Id_area) REFERENCES Area(Id),
    FOREIGN KEY (Id_Regimen) REFERENCES Regimen(Id),
    FOREIGN KEY (Id_depto) REFERENCES Departamento(Id)
);

-- Crear tabla AsignaturaxPlan (tabla de relación)
CREATE TABLE AsignaturaxPlan (
    Id_Plan INTEGER NOT NULL,
    Id_Asignatura INTEGER NOT NULL,
    PRIMARY KEY (Id_Plan, Id_Asignatura),
    FOREIGN KEY (Id_Plan) REFERENCES PlanEstudio(Id),
    FOREIGN KEY (Id_Asignatura) REFERENCES Asignatura(Id)
);

-- Crear tabla MateriasxCuatrimestre (tabla de relación)
CREATE TABLE MateriasxCuatrimestre (
    Id_Asignatura INTEGER NOT NULL,
    Id_cuatrimestre INTEGER NOT NULL,
    PRIMARY KEY (Id_Asignatura, Id_cuatrimestre),
    FOREIGN KEY (Id_Asignatura) REFERENCES Asignatura(Id),
    FOREIGN KEY (Id_cuatrimestre) REFERENCES Cuatrimestre(Id)
);

-- Crear tabla Correlativa (prerrequisitos)
CREATE TABLE Correlativa (
    Id_asignatura INTEGER NOT NULL,
    Id_Correlativa INTEGER NOT NULL,
    PRIMARY KEY (Id_asignatura, Id_Correlativa),
    FOREIGN KEY (Id_asignatura) REFERENCES Asignatura(Id),
    FOREIGN KEY (Id_Correlativa) REFERENCES Asignatura(Id)
);

-- Crear tabla Alumno
CREATE TABLE Alumno (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Apellido VARCHAR(128) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    FechaNacimiento DATE NOT NULL,
    Email VARCHAR(128) NOT NULL,
    Telefono VARCHAR(20),
    Direccion VARCHAR(255),
    FechaIngreso DATE NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo' -- Activo, Graduado, Baja, etc.
);

-- Crear tabla AlumnoxCarrera (relación entre alumnos y carreras)
CREATE TABLE AlumnoxCarrera (
    Id_Alumno INTEGER NOT NULL,
    Id_Carrera INTEGER NOT NULL,
    FechaInscripcion DATE NOT NULL,
    PRIMARY KEY (Id_Alumno, Id_Carrera),
    FOREIGN KEY (Id_Alumno) REFERENCES Alumno(Id),
    FOREIGN KEY (Id_Carrera) REFERENCES Carrera(Id)
);

-- Crear tabla Profesor
CREATE TABLE Profesor (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Apellido VARCHAR(128) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(128) NOT NULL,
    Telefono VARCHAR(20),
    Titulo VARCHAR(128) NOT NULL,
    Especialidad VARCHAR(128),
    TipoContrato VARCHAR(50) NOT NULL, -- Tiempo completo, parcial, etc.
    FechaIngreso DATE NOT NULL,
    Id_Departamento INTEGER NOT NULL,
    FOREIGN KEY (Id_Departamento) REFERENCES Departamento(Id)
);

-- Crear tabla ProfesorxAsignatura (relación entre profesores y asignaturas)
CREATE TABLE ProfesorxAsignatura (
    Id_Profesor INTEGER NOT NULL,
    Id_Asignatura INTEGER NOT NULL,
    Rol VARCHAR(50) NOT NULL, -- Titular, Adjunto, JTP, Ayudante, etc.
    AñoAcademico INTEGER NOT NULL,
    Cuatrimestre INTEGER NOT NULL,
    PRIMARY KEY (Id_Profesor, Id_Asignatura, AñoAcademico, Cuatrimestre),
    FOREIGN KEY (Id_Profesor) REFERENCES Profesor(Id),
    FOREIGN KEY (Id_Asignatura) REFERENCES Asignatura(Id)
);

-- Crear tabla Cursada (inscripción de alumnos a asignaturas)
CREATE TABLE Cursada (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Id_Alumno INTEGER NOT NULL,
    Id_Asignatura INTEGER NOT NULL,
    Id_Plan INTEGER NOT NULL,
    AñoAcademico INTEGER NOT NULL,
    Cuatrimestre INTEGER NOT NULL,
    Estado VARCHAR(20) NOT NULL, -- Cursando, Regular, Libre, Promocionado
    NotaFinal DECIMAL(4,2),
    FOREIGN KEY (Id_Alumno) REFERENCES Alumno(Id),
    FOREIGN KEY (Id_Asignatura) REFERENCES Asignatura(Id),
    FOREIGN KEY (Id_Plan) REFERENCES PlanEstudio(Id),
    UNIQUE (Id_Alumno, Id_Asignatura, AñoAcademico, Cuatrimestre)
);

-- Crear tabla ExamenFinal
CREATE TABLE ExamenFinal (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Fecha DATE NOT NULL,
    Id_Asignatura INTEGER NOT NULL,
    Id_Profesor INTEGER NOT NULL, -- Profesor que preside la mesa
    Llamado INTEGER NOT NULL, -- 1er llamado, 2do llamado, etc.
    FOREIGN KEY (Id_Asignatura) REFERENCES Asignatura(Id),
    FOREIGN KEY (Id_Profesor) REFERENCES Profesor(Id)
);

-- Crear tabla InscripcionExamen (relación entre alumnos y exámenes finales)
CREATE TABLE InscripcionExamen (
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Id_Alumno INTEGER NOT NULL,
    Id_ExamenFinal INTEGER NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Inscripto', -- Inscripto, Presente, Ausente
    Calificacion DECIMAL(4,2),
    Observaciones TEXT,
    FOREIGN KEY (Id_Alumno) REFERENCES Alumno(Id),
    FOREIGN KEY (Id_ExamenFinal) REFERENCES ExamenFinal(Id),
    UNIQUE (Id_Alumno, Id_ExamenFinal)
);



CREATE PROCEDURE InsertarAlumno(
    IN pNombre VARCHAR(255),
    IN pApellido VARCHAR(255),
    IN pDNI VARCHAR(255),
    IN pFechaNacimiento DATE,
    IN pEmail VARCHAR(255),
    IN pTelefono VARCHAR(255),
    IN pDireccion VARCHAR(255),
    IN pFechaIngreso DATE,
    IN pEstado VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Alumno WHERE DNI = pDNI) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe un alumno con ese DNI.';
    ELSE
        INSERT INTO Alumno (
            Nombre,
            Apellido,
            DNI,
            FechaNacimiento,
            Email,
            Telefono,
            Direccion,
            FechaIngreso,
            Estado
        )
        VALUES (
            pNombre,
            pApellido,
            pDNI,
            pFechaNacimiento,
            pEmail,
            pTelefono,
            pDireccion,
            pFechaIngreso,
            pEstado
        );
    END IF;
END //

DELIMITER //

CREATE PROCEDURE InsertarInscripcionExamen(
    IN pIdAlumno INTEGER,
    IN pIdExamenFinal INTEGER,
    IN pEstado VARCHAR(255),
    IN pCalificacion DECIMAL(10,2),
    IN pObservaciones TEXT
)
BEGIN
    -- Validar que el alumno exista
    IF NOT EXISTS (SELECT 1 FROM Alumno WHERE Id = pIdAlumno) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El alumno no existe.';
    
    -- Validar que el examen final exista
    ELSEIF NOT EXISTS (SELECT 1 FROM ExamenFinal WHERE Id = pIdExamenFinal) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El examen final no existe.';
    
    ELSE
        INSERT INTO InscripcionExamen (
            Id_Alumno,
            Id_ExamenFinal,
            Estado,
            Calificacion,
            Observaciones
        )
        VALUES (
            pIdAlumno,
            pIdExamenFinal,
            pEstado,
            pCalificacion,
            pObservaciones
        );
    END IF;
END 

DELIMITER ;

