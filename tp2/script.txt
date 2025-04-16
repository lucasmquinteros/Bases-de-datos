CREATE TABLE IF NOT EXISTS "base"(
"id" TEXT, "ident" TEXT, "type" TEXT, "name" TEXT,
 "latitude_deg" TEXT, "longitude_deg" TEXT, "elevation_ft" TEXT, "continent" TEXT,
 "country_name" TEXT, "iso_country" TEXT, "region_name" TEXT, "iso_region" TEXT,
 "local_region" TEXT, "municipality" TEXT, "scheduled_service" TEXT, "gps_code" TEXT,
 "icao_code" TEXT, "iata_code" TEXT, "local_code" TEXT, "home_link" TEXT,
 "wikipedia_link" TEXT, "keywords" TEXT, "score" TEXT, "last_updated" TEXT);


sqlite> create table continent(id integer primary key autoincrement not null, nombre varchar(64) not null);
sqlite> insert into continent(nombre) select distinct continent from base;

sqlite> create table country(id integer primary key autoincrement not null, nombre varchar(64) not null, iso_code varchar(128) not null, id_continente integer not null, foreign key (id_continente) references continent(id));

sqlite> insert into country(nombre, iso_code, id_continente) select distinct b.country_name, b.iso_country, c.id from Base b inner join continent c on c.nombre = b.continent;

	create table region(id integer primary key autoincrement not null, nombre varchar(128) not null, iso varchar(64) not null,local_region varchar(128) not null, id_country integer not null, foreign key (id_country) references country(id));

 	insert into region(nombre, iso, local_region, id_country) select distinct b.region_name, b.iso_region, b.local_region, co.id from base b inner join country co on co.nombre = b.country_name;

sqlite> create table municipality(id integer primary key autoincrement not null, nombre varchar(128) not null,id_region integer not null, foreign key (id_region) references region(id));

insert into municipality(nombre, id_region) select b.name, r.id from base b inner join region r on r.nombre = b.region_name;

CREATE TABLE type(id integer primary key autoincrement not null, nombre varchar(128) not null);

sqlite> insert into type(nombre) select distinct type from base;

sqlite> select count(distinct local_code) from base;
--[{"count(distinct local_code)":770}]

CREATE TABLE Aeropuerto(id integer primary key autoincrement not null, ident varchar(128) not null, type_id integer not null,nombre varchar(128) not null, lat_deg real not null, long_deg REAL not null, elevacion integer not null, municipalidad_id integer not null, servicios integer not null, gps  varchar(128) not null, icao_code  varchar(128) not null, iata_code varchar(128) not null,local_code varchar(64) not null,home_link varchar(128), wikipedia varchar(128), keywords varchar(128), score integer not null default 0, last_update text,foreign key(type_id) references type(id) ,foreign key(municipalidad_id) references municipality(id));

insert into aeropuerto(ident, type_id, nombre, lat_deg, long_deg, elevacion, municipalidad_id, servicios, gps, icao_code, iata_code, local_code,home_link, wikipedia, keywords, score, last_update) select b.ident, t.id, b.name, b.latitude_deg, b.longitude_deg, b.elevation_ft, m.id, b.scheduled_service, b.gps_code, b.icao_code, b.iata_code, b.local_code, b.home_link, b.wikipedia_link, b.keywords, b.score, b.last_updated from base b inner join type t on t.nombre = b.type inner join municipality m on m.nombre = b.municipality;

--aquí probe mandarte todo para que usted nomas copie y pegue el código pero no encuentro mi error en el insert ya que copie y pegue todo lo que hice 2 veces y en mi base de datos si funciona, pero en el segundo intento solamente se me insertan 5 aeropuertos, luego probar tirar abajo la tabla aeropuerto en mi db original y ahora se insertan  1104 aeropuertos, cuando llegue a clase consulto sobre esto.