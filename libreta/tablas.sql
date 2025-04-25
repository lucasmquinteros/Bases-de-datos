create table Institucion (
	id integer not null primary key autoincrement, 
	nombre  varchar(256) not null unique,
	domicilio varchar(256));

create table Carrera (
	id integer not null primary key autoincrement, 
	institucion_id integer not null,
	nombre  varchar(256) not null unique,
	duracion integer not null,
	foreign key (institucion_id) references  Institucion(id));

create table Regimen (
	id integer not null primary key autoincrement, 
	nombre  varchar(256) not null unique);

create table Area (
	id integer not null primary key autoincrement, 
	nombre  varchar(256) not null unique);

create table Plan (
	id integer not null primary key autoincrement, 
	nombre  varchar(256) not null unique,
	carrera_id integer not null,
	fecha_inicio datetime not null,
	fecha_fin datetime,
	foreign key (carrera_id) references Carrera(id));

create table Cuatrimestre (
	id integer not null primary key autoincrement, 
	numero integer not null check (numero >= 0),
	descripcion varchar(128) not null);

create table Nivel (
	id integer not null primary key autoincrement, 
	numero integer not null check (numero >= 0),
	descripcion varchar(128) not null);

create table Asignatura(
	id integer not null primary key autoincrement, 
	area_id integer not null,
	regimen_id integer not null,
	nombre varchar(256) not null,
	horassemana integer not null,
	horascuatrimestre integer not null,
	creditos integer not null,
	foreign key (area_id) references Area(id),
	foreign key (regimen_id) references Regimen(id));

create table MateriasPlan(
	id integer not null primary key autoincrement,
	plan_id integer not null,
	asignatura_id integer,
	nivel_id integer not null,
	cuatrimestre_id integer not null,
	Foreign Key(plan_id) references Plan(id),
	Foreign Key(asignatura_id) references Asignatura(id),
	Foreign Key(nivel_id) references Nivel(id),
	Foreign Key(cuatrimestre_id) references Cuatrimestre(id));

create table Correlativas(
	id integer not null primary key autoincrement,
	materia_id integer not null,
	correlativa_id integer not null check (correlativa_id != materia_id),
	foreign key (materia_id) references Materia(id),
	foreign key (correlativa_id) references Materia(id));

select p.nombre, a.nombre, n.numero, c.numero from MateriasPlan mp
 inner join plan p on p.id = mp.plan_id
 inner join asignatura a on  a.id  = mp.asignatura_id
 inner join nivel n on n.id = mp.nivel_id
 inner join Cuatrimestre c on c.id = mp.cuatrimestre_id; 