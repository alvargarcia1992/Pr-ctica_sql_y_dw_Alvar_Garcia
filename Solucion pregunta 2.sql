--- 2. CREACIÓN DE BASE DE DATOS
  -- Desarrollar un script para crear las tablas y las restricciones necesarias según el diagrama entregado en   el punto anterior. eLscript debe poder ejecutarse en PostgreSQL.


CREATE TABLE Bootcamp (
    Bootcamp_id INT NOT NULL,
    nombre VARCHAR (225),
    edicion VARCHAR (225),
    fecha_inicio DATE,
    fecha_final DATE,
    PRIMARY KEY (Bootcamp_id)
);

CREATE TABLE Modulos (
    Modulo_id INT NOT NULL,
    Bootcamp_id INT NOT NULL,
    Profesor_id INT NOT NULL,
    nombre VARCHAR (225),
    PRIMARY KEY (Modulo_id)
);

CREATE TABLE Bootcamp_Modulos (
    Bootcamp_id INT NOT NULL,
	Modulo_id INT NOT NULL,
	Fecha_inicio DATE,
	Fecha_final DATE,
    PRIMARY KEY (Bootcamp_id, Modulo_id),
    FOREIGN KEY (Bootcamp_id) REFERENCES Bootcamp(Bootcamp_id),
	FOREIGN KEY (Modulo_id) REFERENCES Modulos(Modulo_id)
);

CREATE TABLE Profesores_Modulo (
    Profesor_id INT NOT NULL,
	Modulo_id INT NOT NULL,
    PRIMARY KEY (Profesor_id, Modulo_id),
    FOREIGN KEY (Profesor_id) REFERENCES Profesores(Profesor_id),
	FOREIGN KEY (Modulo_id) REFERENCES Modulos(Modulo_id)
);

CREATE TABLE Alumnos (
    Alumnos_id INT NOT NULL,
    Bootcamp_id INT NOT NULL,
	apellido_1 VARCHAR (225),
    apellido_2 VARCHAR (225),
    tiene_beca boolean,
    ha_pagado boolean,
    telefono VARCHAR (20),
    direccion VARCHAR (225),
    DNI VARCHAR (225),
    PRIMARY KEY (Alumnos_id),
    FOREIGN KEY (Bootcamp_id) REFERENCES Bootcamp(Bootcamp_id)
);

CREATE TABLE Profesores (
	Profesor_id INT NOT NULL,
	nombre VARCHAR (225),
	apellido_1 VARCHAR (225),
	apellido_2 VARCHAR (225),
	DNI VARCHAR (225),
	fecha_nacimiento DATE,
	telefono VARCHAR (20),
	direccion VARCHAR (225),
	sueldo DECIMAL (10,2),
	numero_cuenta VARCHAR (225),
	PRIMARY KEY (Profesor_id)
);

CREATE TABLE Notas(
	Notas_id INT NOT NULL,
	Alumno_id INT NOT NULL,
	Modulo_id INT NOT NULL,
	Nota_1er_INTento INT,
	Nota_2o_INTento INT,
	es_apto boolean,
	PRIMARY KEY (Notas_id),
	FOREIGN KEY (Alumno_id) REFERENCES Alumnos(Alumnos_id),
	FOREIGN KEY (Modulo_id) REFERENCES Modulos(Modulo_id)
);