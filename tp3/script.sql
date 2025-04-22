CREATE TABLE jurisdiccion(id integer primary key autoincrement not null, nombre varchar(128) not null);

insert into jurisdiccion(nombre) select distinct Jurisdicción from base;

create table departamento(id integer primary key autoincrement not null, nombre varchar(128) not null, jurisdiccion_id integer not null, foreign key(jurisdiccion_id) references jurisdiccion(id));

insert into departamento(nombre, jurisdiccion_id) select distinct b.Departamento, j.id from base b inner join jurisdiccion j on j.nombre = b.Jurisdicción;

create table localidad(id integer primary key autoincrement not null, nombre varchar(128) not null, cp integer not null,cod_area integer not null, cod_localidad integer not null, depto_id integer not null, foreign key(depto_id) references departamento(id));

insert into localidad(nombre, cp , cod_area, cod_localidad, depto_id)
select distinct b.Localidad, b.CP, b."Código de área", b."Código localidad", d.id
from base b
inner join jurisdiccion j on j.nombre = b.Jurisdicción
inner join departamento d on d.nombre = b.Departamento and d.jurisdiccion_id = j.id
where b.Localidad is not null and b.CP is not null and b."Código de área" is not null and b."Código localidad" is not null
group by b.Localidad, b.CP, b."Código de área", b."Código localidad", d.id;


create table sector(id integer primary key autoincrement not null, tipo varchar(128) not null);

insert into sector(tipo) select distinct Sector from base;

create table ambito(id integer primary key autoincrement not null, tipo varchar(128) not null);

insert into ambito(tipo) select distinct Ámbito from base;

create table escuela(id integer primary key autoincrement not null, nombre varchar(128) not null, cue_anexo varchar(128) not null, domicilio varchar(128) not null, telefono integer not null default 0, mail varchar(128) not null default 'No tiene', localidad_id integer not null, sector_id integer not null, ambito_id integer not null, foreign key(localidad_id) references localidad(id), foreign key(sector_id) references sector(id), foreign key(ambito_id) references ambito(id));

insert into escuela(nombre, cue_anexo, domicilio, telefono, mail, localidad_id, sector_id, ambito_id)
select b.Nombre, b."CUE Anexo", b.Domicilio, b.Teléfono, b.Mail, l.id, s.id, a.id
from base b
inner join jurisdiccion j on j.nombre = b.Jurisdicción
inner join departamento d on d.nombre = b.Departamento and d.jurisdiccion_id = j.id
inner join localidad l on l.nombre = b.Localidad and l.depto_id = d.id and l.cp = b.CP and l.cod_area = b."Código de área" and l.cod_localidad = b."Código localidad"
inner join sector s on s.tipo = b.Sector
inner join ambito a on a.tipo = b.Ámbito;


--storage procedure, a partir de aca es sql server

USE [TU_BASE_DE_DATOS]
GO

CREATE PROCEDURE [dbo].[sp_ObtenerEscuelasPorJurisdiccion]
    @nombreJurisdiccion VARCHAR(128),
    @cantidadEscuelas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Consulta principal
    SELECT 
        e.nombre, 
        e.cue_anexo, 
        e.domicilio,
        l.nombre as localidad, 
        d.nombre as departamento
    FROM escuela e
    JOIN localidad l ON e.localidad_id = l.id
    JOIN departamento d ON l.depto_id = d.id
    JOIN jurisdiccion j ON d.jurisdiccion_id = j.id
    WHERE j.nombre = @nombreJurisdiccion;
    
    -- Contar escuelas (valor de retorno)
    SELECT @cantidadEscuelas = COUNT(*)
    FROM escuela e
    JOIN localidad l ON e.localidad_id = l.id
    JOIN departamento d ON l.depto_id = d.id
    JOIN jurisdiccion j ON d.jurisdiccion_id = j.id
    WHERE j.nombre = @nombreJurisdiccion;
END
GO



CREATE PROCEDURE sp_AnalizarEsquema
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tabla para resultados
    CREATE TABLE #ResultadoEsquema (
        TipoObjeto VARCHAR(50),
        NombreObjeto VARCHAR(255),
        TipoElemento VARCHAR(50),
        NombreElemento VARCHAR(255),
        Detalles VARCHAR(MAX)
    );
    
    -- 1. Analizar tablas
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        t.name AS NombreObjeto,
        'DEFINICION' AS TipoElemento,
        '' AS NombreElemento,
        'Columnas: ' + CAST(COUNT(c.name) AS VARCHAR) + 
        ', Filas estimadas: ' + CAST(p.rows AS VARCHAR) AS Detalles
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
    GROUP BY t.name, p.rows;
    
    -- 2. Analizar columnas (PK, FK, tipos)
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        t.name AS NombreObjeto,
        'COLUMNA' AS TipoElemento,
        c.name AS NombreElemento,
        'Tipo: ' + tp.name + 
        CASE WHEN ic.column_id IS NOT NULL THEN ', PK' ELSE '' END +
        CASE WHEN fk.parent_object_id IS NOT NULL THEN ', FK' ELSE '' END +
        CASE WHEN c.is_nullable = 1 THEN ', NULL' ELSE ', NOT NULL' END AS Detalles
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.is_primary_key = 1
    LEFT JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND c.column_id = ic.column_id
    LEFT JOIN sys.foreign_key_columns fkc ON t.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
    LEFT JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id;
    
    -- 3. Analizar constraints
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        OBJECT_NAME(parent_object_id) AS NombreObjeto,
        'CONSTRAINT' AS TipoElemento,
        name AS NombreElemento,
        CASE type
            WHEN 'PK' THEN 'PRIMARY KEY'
            WHEN 'FK' THEN 'FOREIGN KEY'
            WHEN 'UQ' THEN 'UNIQUE CONSTRAINT'
            WHEN 'C' THEN 'CHECK CONSTRAINT'
            WHEN 'D' THEN 'DEFAULT CONSTRAINT'
            ELSE type_desc
        END AS Detalles
    FROM sys.objects
    WHERE type IN ('PK','FK','UQ','C','D');
    
    -- 4. Analizar vistas
    INSERT INTO #ResultadoEsquema
    SELECT 
        'VISTA' AS TipoObjeto,
        name AS NombreObjeto,
        'DEFINICION' AS TipoElemento,
        '' AS NombreElemento,
        'Definición: ' + SUBSTRING(OBJECT_DEFINITION(object_id), 1, 100) + '...' AS Detalles
    FROM sys.views;
    
    -- Devolver resultados
    SELECT * FROM #ResultadoEsquema
    ORDER BY TipoObjeto, NombreObjeto, TipoElemento, NombreElemento;
    
    DROP TABLE #ResultadoEsquema;
END


CREATE PROCEDURE sp_AnalizarEsquema
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tabla para resultados
    CREATE TABLE #ResultadoEsquema (
        TipoObjeto VARCHAR(50),
        NombreObjeto VARCHAR(255),
        TipoElemento VARCHAR(50),
        NombreElemento VARCHAR(255),
        Detalles VARCHAR(MAX)
    );
    
    -- 1. Analizar tablas
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        t.name AS NombreObjeto,
        'DEFINICION' AS TipoElemento,
        '' AS NombreElemento,
        'Columnas: ' + CAST(COUNT(c.name) AS VARCHAR) + 
        ', Filas estimadas: ' + CAST(p.rows AS VARCHAR) AS Detalles
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
    GROUP BY t.name, p.rows;
    
    -- 2. Analizar columnas (PK, FK, tipos)
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        t.name AS NombreObjeto,
        'COLUMNA' AS TipoElemento,
        c.name AS NombreElemento,
        'Tipo: ' + tp.name + 
        CASE WHEN ic.column_id IS NOT NULL THEN ', PK' ELSE '' END +
        CASE WHEN fk.parent_object_id IS NOT NULL THEN ', FK' ELSE '' END +
        CASE WHEN c.is_nullable = 1 THEN ', NULL' ELSE ', NOT NULL' END AS Detalles
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types tp ON c.user_type_id = tp.user_type_id
    LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.is_primary_key = 1
    LEFT JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND c.column_id = ic.column_id
    LEFT JOIN sys.foreign_key_columns fkc ON t.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
    LEFT JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id;
    
    -- 3. Analizar constraints
    INSERT INTO #ResultadoEsquema
    SELECT 
        'TABLA' AS TipoObjeto,
        OBJECT_NAME(parent_object_id) AS NombreObjeto,
        'CONSTRAINT' AS TipoElemento,
        name AS NombreElemento,
        CASE type
            WHEN 'PK' THEN 'PRIMARY KEY'
            WHEN 'FK' THEN 'FOREIGN KEY'
            WHEN 'UQ' THEN 'UNIQUE CONSTRAINT'
            WHEN 'C' THEN 'CHECK CONSTRAINT'
            WHEN 'D' THEN 'DEFAULT CONSTRAINT'
            ELSE type_desc
        END AS Detalles
    FROM sys.objects
    WHERE type IN ('PK','FK','UQ','C','D');
    
    -- 4. Analizar vistas
    INSERT INTO #ResultadoEsquema
    SELECT 
        'VISTA' AS TipoObjeto,
        name AS NombreObjeto,
        'DEFINICION' AS TipoElemento,
        '' AS NombreElemento,
        'Definición: ' + SUBSTRING(OBJECT_DEFINITION(object_id), 1, 100) + '...' AS Detalles
    FROM sys.views;
    
    -- Devolver resultados
    SELECT * FROM #ResultadoEsquema
    ORDER BY TipoObjeto, NombreObjeto, TipoElemento, NombreElemento;
    
    DROP TABLE #ResultadoEsquema;
END