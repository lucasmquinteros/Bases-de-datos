import sqlite3
import pyodbc

# Conectar a SQLite
sqlite_conn = sqlite3.connect('C:/SQLite/libreta/facultad.db')
sqlite_cur = sqlite_conn.cursor()

# Conectar a SQL Server
sqlserver_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost\\SQLEXPRESS;DATABASE=Facultad;Trusted_Connection=yes;')
sqlserver_cur = sqlserver_conn.cursor()

# Mapeo de tipos
tipo_sqlite_a_sqlserver = {
    "INTEGER": "INT",
    "TEXT": "NVARCHAR(MAX)",
    "REAL": "FLOAT",
    "BLOB": "VARBINARY(MAX)",
    "NUMERIC": "DECIMAL(18,2)"
}

# Obtener las tablas (excluyendo las internas de SQLite)
sqlite_cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
tablas = [fila[0] for fila in sqlite_cur.fetchall() if not fila[0].startswith('sqlite_')]
print(f"Tablas encontradas: {tablas}")
for tabla in tablas:
    print(f"Migrando estructura de tabla: {tabla}")

    # Obtener columnas y claves primarias
    sqlite_cur.execute(f"PRAGMA table_info({tabla});")
    columnas_info = sqlite_cur.fetchall()

    columnas_sql = []
    primary_keys = []
    for col in columnas_info:
        nombre = col[1]
        tipo = col[2].upper()
        notnull = col[3]
        pk = col[5]

        tipo_sqlserver = tipo_sqlite_a_sqlserver.get(tipo, "NVARCHAR(MAX)")
        campo = f"[{nombre}] {tipo_sqlserver}"
        if notnull:
            campo += " NOT NULL"
        columnas_sql.append(campo)

        if pk:
            primary_keys.append(nombre)

    # Agregar la clave primaria
    if primary_keys:
        pk_str = ", ".join([f"[{col}]" for col in primary_keys])
        columnas_sql.append(f"PRIMARY KEY ({pk_str})")

    # Agregar claves foráneas
    sqlite_cur.execute(f"PRAGMA foreign_key_list({tabla});")
    foreign_keys = sqlite_cur.fetchall()
    for fk in foreign_keys:
        col_local = fk[3]
        tabla_ref = fk[2]
        col_ref = fk[4]
        columnas_sql.append(f"FOREIGN KEY ([{col_local}]) REFERENCES [{tabla_ref}]([{col_ref}])")

    columnas_str = ",\n    ".join(columnas_sql)

    # Eliminar la tabla si ya existe y crearla
    try:
        sqlserver_cur.execute(f"DROP TABLE IF EXISTS [{tabla}]")
    except:
        pass
    sqlserver_cur.execute(f"CREATE TABLE [{tabla}] (\n    {columnas_str}\n)")
    print(f" Tabla {tabla} creada.")

# Insertar datos ahora que las estructuras están listas
for tabla in tablas:
    print(f"Insertando datos en: {tabla}")

    sqlite_cur.execute(f"SELECT * FROM {tabla}")
    datos = sqlite_cur.fetchall()

    sqlite_cur.execute(f"PRAGMA table_info({tabla})")
    columnas = [col[1] for col in sqlite_cur.fetchall()]
    placeholders = ', '.join(['?'] * len(columnas))

    if datos:
        sqlserver_cur.executemany(f"INSERT INTO [{tabla}] VALUES ({placeholders})", datos)
        print(f" Insertadas {len(datos)} filas en {tabla}")
    else:
        print(f"Sin datos en {tabla}")

# Guardar cambios
sqlserver_conn.commit()
sqlite_conn.close()
sqlserver_conn.close()

print("Migración completa: estructura y datos transferidos.")
