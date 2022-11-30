CREATE DATABASE IF NOT EXISTS fymdental;

USE fymdental;

CREATE TABLE IF NOT EXISTS pacientes (
	id_paciente 			INT 			NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre 					VARCHAR(50) 	NOT NULL,
    apellido 				VARCHAR(50) 	NOT NULL,
    documento 				DECIMAL(10,0) 	NOT NULL UNIQUE,
    genero 					TINYINT 		NOT NULL,
    fecha_de_nacimiento 	DATE 			NOT NULL,
    email 					VARCHAR(50) 			 UNIQUE,
    celular 				VARCHAR(20),
    telefono 				VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS tipo_de_empleado (
	id_tipo_empleado 		INT 					NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    titulo 					VARCHAR(50) 			NOT NULL UNIQUE,
    porcentaje_tratamiento 	TINYINT 	DEFAULT 40,
    porcentaje_laboratorio 	TINYINT		DEFAULT 50,
    lleva_monto_fijo 		TINYINT 	DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tratamientos (
	id_tratamiento 	INT 					NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre			VARCHAR(50) 			NOT NULL,
    nomenclador 	VARCHAR(10) 			NOT NULL UNIQUE,
    precio 			DECIMAL(10,2) 			NOT NULL,
    monto_fijo 		DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS laboratorios (
	id_laboratorio 	INT					NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre 			VARCHAR(50) 		NOT NULL,
    telefono 		VARCHAR(20) 		NOT NULL,
    direccion 		VARCHAR(255),
    email 			VARCHAR(50),
    cuit 			VARCHAR(11) 				 UNIQUE,
    activo 			TINYINT 	DEFAULT 1
);

CREATE TABLE IF NOT EXISTS empleados (
	id_empleado 			INT 					NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre 					VARCHAR(50) 			NOT NULL,
	apellido 				VARCHAR(50) 			NOT NULL,
    documento 				DECIMAL(10,0) 			NOT NULL UNIQUE,
    genero 					TINYINT 				NOT NULL,
    fecha_de_nacimiento 	DATE 					NOT NULL,
    email 					VARCHAR(50) 			         UNIQUE,
    celular 				VARCHAR(20),
    direccion 				VARCHAR(255),
    id_tipo_empleado 		INT 					NOT NULL,
    activo 					TINYINT 	DEFAULT 1,
    FOREIGN KEY (id_tipo_empleado)
		REFERENCES tipo_de_empleado (id_tipo_empleado)
);

CREATE TABLE IF NOT EXISTS turnos (
	id_turno 		INT 					NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    fecha 			DATE 					NOT NULL,
    hora 			TIME 					NOT NULL,
    asistio 		TINYINT 	DEFAULT 2,
    id_paciente 	INT 					NOT NULL,
    id_empleado 	INT,
    id_tratamiento 	INT,
    FOREIGN KEY (id_paciente) 
		REFERENCES pacientes (id_paciente)
        ON DELETE CASCADE,
	FOREIGN KEY (id_empleado)
		REFERENCES empleados (id_empleado)
        ON DELETE SET NULL,
	FOREIGN KEY (id_tratamiento)
		REFERENCES tratamientos (id_tratamiento)
);

CREATE TABLE IF NOT EXISTS facturacion (
	id_factura 		INT 					  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_paciente 	INT 					  NOT NULL,
    tipo 			TINYINT 				  NOT NULL,
    valor_ideal 	DECIMAL(10,2) 			  NOT NULL,
    valor_real 		DECIMAL(10,2),
    numero_factura 	VARCHAR(14),
    condicion_venta	TINYINT 		DEFAULT 0,
    FOREIGN KEY (id_paciente)
		REFERENCES pacientes (id_paciente)
);

CREATE TABLE IF NOT EXISTS trabajos_laboratorio (
	id_trabajo_laboratorio 	INT 						NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
    id_laboratorio 			INT 						NOT NULL,
    precio 					DECIMAL(10,2),
    estado 					TINYINT 		DEFAULT 0,
    FOREIGN KEY (id_laboratorio)
		REFERENCES laboratorios (id_laboratorio)
);

CREATE TABLE IF NOT EXISTS evoluciones (
	descripcion 			VARCHAR(1000),
    id_tratamiento 			INT 			NOT NULL,
    id_turno 				INT				NOT NULL,
    id_paciente 			INT 			NOT NULL,
    id_empleado 			INT 			NOT NULL,
    id_trabajo_laboratorio 	INT,
    id_factura 				INT,
    FOREIGN KEY (id_tratamiento)
		REFERENCES tratamientos (id_tratamiento),
	FOREIGN KEY (id_turno)
		REFERENCES turnos (id_turno),
    FOREIGN KEY (id_paciente)
		REFERENCES pacientes (id_paciente),
	FOREIGN KEY (id_empleado)
		REFERENCES empleados (id_empleado),
	FOREIGN KEY (id_trabajo_laboratorio)
		REFERENCES trabajos_laboratorio (id_trabajo_laboratorio),
	FOREIGN KEY (id_factura)
		REFERENCES facturacion (id_factura)
);