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


