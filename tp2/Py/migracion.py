import sqlite3
import pyodbc

# Conectar a SQLite
sqlite_conn = sqlite3.connect('C:/SQLite/tp2/aeropuertos.db')
sqlite_cur = sqlite_conn.cursor()

# Conectar a SQL Server
sqlserver_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost\\SQLEXPRESS;DATABASE=Aeropuertos;Trusted_Connection=yes;')
sqlserver_cur = sqlserver_conn.cursor()

# Traductor de tipos de SQLite a SQL Server
tipo_sqlite_a_sqlserver = {
    "INTEGER": "INT",
    "TEXT": "NVARCHAR(MAX)",
    "REAL": "FLOAT",
    "BLOB": "VARBINARY(MAX)",
    "NUMERIC": "DECIMAL(18, 2)"
}

# Obtener todas las tablas de SQLite
sqlite_cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
tablas = [fila[0] for fila in sqlite_cur.fetchall()]

for tabla in tablas:
    print(f"Migrando tabla: {tabla}")

    # Obtener estructura de la tabla en SQLite
    sqlite_cur.execute(f"PRAGMA table_info({tabla});")
    columnas_info = sqlite_cur.fetchall()
    
    columnas_sql = []
    columnas_nombres = []
    for col in columnas_info:
        nombre_col = col[1]
        tipo_col = col[2].upper()
        tipo_sqlserver = tipo_sqlite_a_sqlserver.get(tipo_col, "NVARCHAR(MAX)")
        columnas_sql.append(f"[{nombre_col}] {tipo_sqlserver}")
        columnas_nombres.append(nombre_col)

    columnas_str = ", ".join(columnas_sql)

    # Eliminar tabla si ya existe (opcional)
    try:
        sqlserver_cur.execute(f"DROP TABLE IF EXISTS [{tabla}]")
    except:
        pass

    # Crear tabla en SQL Server
    sqlserver_cur.execute(f"CREATE TABLE [{tabla}] ({columnas_str})")
    print(f"Tabla {tabla} creada.")

    # Obtener datos desde SQLite
    sqlite_cur.execute(f"SELECT * FROM {tabla}")
    datos = sqlite_cur.fetchall()

    if datos:
        placeholders = ', '.join(['?'] * len(columnas_nombres))
        sqlserver_cur.executemany(f"INSERT INTO [{tabla}] VALUES ({placeholders})", datos)
        print(f"Datos insertados en {tabla} ({len(datos)} filas)")

sqlserver_conn.commit()
sqlite_conn.close()
sqlserver_conn.close()

print("Migración completada.")
