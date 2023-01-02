DROP DATABASE IF EXISTS fymdental;
CREATE DATABASE IF NOT EXISTS fymdental;
USE fymdental;

CREATE TABLE IF NOT EXISTS tipo_de_empleado (
	id_tipo_empleado INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL UNIQUE,
    atiende	TINYINT	NOT NULL DEFAULT 1 ,
    porcentaje_tratamiento TINYINT NOT NULL DEFAULT 40,
    porcentaje_laboratorio TINYINT NOT NULL DEFAULT 50,
    lleva_monto_fijo TINYINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tratamientos (
	id_tratamiento INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    nomenclador VARCHAR(10) NOT NULL UNIQUE,
    precio DECIMAL(10,2) NOT NULL,
    monto_fijo DECIMAL(10,2) NOT NULL DEFAULT 0,
	trabajo_laboratorio	TINYINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS laboratorios (
	id_laboratorio INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255),
    email VARCHAR(50),
    cuit VARCHAR(11) UNIQUE,
    activo TINYINT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS modo_pago (
	id_modo_pago INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
    modo VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS generos (
	id_genero INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    genero VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS estado_turno (
	id_estado_turno INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS estado_trabajo_laboratorio (
	id_estado_trabajo_laboratorio INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS pacientes (
	id_paciente INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    documento DECIMAL(10,0) NOT NULL UNIQUE,
    id_genero INT NOT NULL,
    fecha_de_nacimiento DATE NOT NULL,
    email VARCHAR(50),
    celular VARCHAR(20),
    telefono VARCHAR(20),
    FOREIGN KEY (id_genero)
		REFERENCES generos (id_genero)
);

CREATE TABLE IF NOT EXISTS empleados (
	id_empleado INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
    documento DECIMAL(10,0)	NOT NULL UNIQUE,
    id_genero INT NOT NULL,
    fecha_de_nacimiento DATE NOT NULL,
    email VARCHAR(50) UNIQUE,
    celular VARCHAR(20),
    direccion VARCHAR(255),
    id_tipo_empleado INT NOT NULL,
    activo TINYINT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_genero)
		REFERENCES generos (id_genero),
    FOREIGN KEY (id_tipo_empleado)
		REFERENCES tipo_de_empleado (id_tipo_empleado)	
);

CREATE TABLE IF NOT EXISTS turnos (
	id_turno INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    id_estado_turno INT NOT NULL DEFAULT 2,
    id_paciente INT NOT NULL,
    id_empleado INT,
    id_tratamiento INT,
    FOREIGN KEY (id_estado_turno) 
		REFERENCES estado_turno (id_estado_turno),
    FOREIGN KEY (id_paciente) 
		REFERENCES pacientes (id_paciente),
	FOREIGN KEY (id_empleado)
		REFERENCES empleados (id_empleado),
	FOREIGN KEY (id_tratamiento)
		REFERENCES tratamientos (id_tratamiento)
);

CREATE TABLE IF NOT EXISTS trabajos_laboratorio (
	id_trabajo_laboratorio INT NOT NULL UNIQUE PRIMARY KEY AUTO_INCREMENT,
    id_laboratorio INT,
    precio DECIMAL(10,2),
    id_estado_trabajo_laboratorio INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_estado_trabajo_laboratorio)
		REFERENCES estado_trabajo_laboratorio (id_estado_trabajo_laboratorio),
    FOREIGN KEY (id_laboratorio)
		REFERENCES laboratorios (id_laboratorio)
);

CREATE TABLE IF NOT EXISTS evoluciones (
	id_evolucion INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
    id_tratamiento INT NOT NULL,
    descripcion VARCHAR(1000),
    id_turno INT NOT NULL,
    id_paciente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_trabajo_laboratorio INT,
    FOREIGN KEY (id_tratamiento)
		REFERENCES tratamientos (id_tratamiento),
	FOREIGN KEY (id_turno)
		REFERENCES turnos (id_turno),
    FOREIGN KEY (id_paciente)
		REFERENCES pacientes (id_paciente),
	FOREIGN KEY (id_empleado)
		REFERENCES empleados (id_empleado),
	FOREIGN KEY (id_trabajo_laboratorio)
		REFERENCES trabajos_laboratorio (id_trabajo_laboratorio)
);

CREATE TABLE IF NOT EXISTS pagos (
	id_pago	INT	NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
	fecha DATE NOT NULL DEFAULT (CURDATE()),
	id_evolucion INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    id_modo_pago INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_evolucion)
		REFERENCES evoluciones (id_evolucion),
	FOREIGN KEY (id_modo_pago) 
		REFERENCES modo_pago (id_modo_pago)
);

CREATE TABLE IF NOT EXISTS log_pagos (
	id_log_pagos INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
    fecha DATE NOT NULL DEFAULT (CURDATE()),
    hora TIME NOT NULL DEFAULT (CURTIME()),
    evento VARCHAR(20) NOT NULL,
    objetivo INT NOT NULL,
    usuario VARCHAR(50)	NOT NULL,
    FOREIGN KEY (objetivo)
		REFERENCES pagos (id_pago)
);

CREATE TABLE IF NOT EXISTS pagos_audit (
	id_changed_log INT NOT NULL,
    old_row	VARCHAR(3000) NOT NULL,
    new_row	VARCHAR(3000) NOT NULL,
    FOREIGN KEY (id_changed_log)
		REFERENCES log_pagos (id_log_pagos)
);

CREATE TABLE IF NOT EXISTS log_evoluciones (
	id_log_evoluciones INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
    fecha DATE NOT NULL DEFAULT (CURDATE()),
    hora TIME NOT NULL DEFAULT (CURTIME()),
    evento VARCHAR(20) NOT NULL,
    objetivo INT NOT NULL,
    usuario VARCHAR(50)	NOT NULL,
    FOREIGN KEY (objetivo)
		REFERENCES evoluciones (id_evolucion)
);

CREATE TABLE IF NOT EXISTS evoluciones_audit (
	id_changed_log INT NOT NULL,
    old_row VARCHAR(3000) NOT NULL,
    new_row VARCHAR(3000) NOT NULL,
    FOREIGN KEY (id_changed_log)
		REFERENCES log_evoluciones (id_log_evoluciones)
);

-- STORED PROCEDURES --

-- Obtener una lista de emails. Lista de pacientes ordenada por un parametro de entrada
-- order_column es el nombre de la columna por la qeu se quiere ordenar. Puede ser nombre, apellido, documento, genero (0 femenino, 1 masculino), fecha_de_nacimiento y email
-- El parámetro direction define si es ascendente o descendente. Poner ASC o DESC para elegir uno o el otro

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lista_emails` (IN order_column VARCHAR(50), IN direction VARCHAR(4))
BEGIN
	IF order_column <> '' THEN
		SET @order_clause = CONCAT('ORDER BY ', order_column, ' ', direction);
	ELSE
		SET @order_clause = '';
    END IF;
    
    SET @clause = CONCAT('SELECT p.nombre, p.apellido, p.documento, g.genero, p.fecha_de_nacimiento, p.email FROM pacientes p JOIN generos g ON p.id_genero = g.id_genero ', @order_clause);
    PREPARE runSQL FROM @clause;
    EXECUTE runSQL;
    DEALLOCATE PREPARE runSQL;
END$$

-- El siguiente Stored Procedure permite aumentar todos los precios de los tratamientos un porcentaje determinado
-- porcentaje_aumento es un INT. Si quiero aumentar un 10% los precios, ingreso 10
-- aplicar_a_monto_fijo puede valer 0 o 1, y representa si se debe aplicar el aumento a la columna monto_fijo

CREATE PROCEDURE `aumentar_precios` (IN porcentaje_aumento INT, aplicar_a_monto_fijo TINYINT)
BEGIN
	DECLARE i, m, n, row_id INT;
    DECLARE old_price, old_fixed DECIMAL(10,2);
    
    IF aplicar_a_monto_fijo NOT IN (0, 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Variable aplicar_a_monto_fijo puede ser sólo 0 o 1';
    END IF;
    
	SET i = 1;
    SELECT COUNT(*) INTO n FROM tratamientos;
    
    WHILE i <= n DO
		SET m = i - 1;
		SELECT id_tratamiento, precio, monto_fijo INTO row_id, old_price, old_fixed FROM tratamientos LIMIT m, 1;
        
        IF aplicar_a_monto_fijo = 0 THEN
			UPDATE tratamientos 
            SET precio = old_price * (1 + (porcentaje_aumento / 100))
            WHERE id_tratamiento = row_id;
        ELSEIF aplicar_a_monto_fijo = 1 THEN
			UPDATE tratamientos 
			SET precio = old_price * (1 + (porcentaje_aumento / 100)),
				monto_fijo = old_fixed *  (1 + (porcentaje_aumento / 100))
			WHERE id_tratamiento = row_id;
        END IF;
        
        SET i = i + 1;
	END WHILE;

END$$

DELIMITER ;

-- TRIGGERS --

-- Frente a una inserción en la tabla pagos, este trigger agrega un log en la tabla log_pagos

CREATE TRIGGER `generar_log_pago_insert`
AFTER INSERT ON `pagos`
FOR EACH ROW
INSERT INTO `log_pagos` (evento, objetivo, usuario) VALUES ('INSERT', NEW.id_pago, USER());

-- Frente a la modificación de una fila en la tabla pagos, este trigger agrega un log en la tabla log_pagos
-- También agrega una fila en pagos_audit que registra los cambios que se producen

DELIMITER $$
CREATE TRIGGER `generar_log_pago_update`
AFTER UPDATE ON `pagos`
FOR EACH ROW
BEGIN
	INSERT INTO log_pagos (evento, objetivo, usuario) VALUES ('UPDATE', NEW.id_pago, USER());
	INSERT INTO pagos_audit (id_changed_log, old_row, new_row)
		VALUES (
			(SELECT MAX(id_log_pagos) FROM log_pagos),
			CONCAT(NULL, ' ', OLD.fecha, ' ', OLD.id_evolucion, ' ', OLD.monto, ' ', OLD.id_modo_pago),
            CONCAT(NEW.fecha, ' ', NEW.id_evolucion, ' ', NEW.monto, ' ', NEW.id_modo_pago)
		);
END$$
DELIMITER ;

-- Frente a una inserción en la tabla pagos, este trigger agrega un log en la tabla log_pagos

CREATE TRIGGER `generar_log_evolucion_insert`
AFTER INSERT ON evoluciones
FOR EACH ROW
INSERT INTO log_evoluciones (evento, objetivo, usuario) VALUES ('INSERT', NEW.id_evolucion, USER());

-- Frente a la modificación de una fila en la tabla evoluciones, este trigger agrega un log en la tabla log_evoluciones
-- También agrega una fila en evoluciones_audit que registra los cambios que se producen

DELIMITER $$
CREATE TRIGGER `generar_log_evolucion_update`
AFTER UPDATE ON evoluciones
FOR EACH ROW
BEGIN
	INSERT INTO log_evoluciones (evento, objetivo, usuario) VALUES ('UPDATE', NEW.id_evolucion, USER());
    IF (NOT(OLD.id_trabajo_laboratorio IS NULL AND NEW.id_trabajo_laboratorio IS NOT NULL)) THEN
		INSERT INTO evoluciones_audit (id_changed_log, old_row, new_row)
		VALUES (
			(SELECT MAX(id_log_evoluciones) FROM log_evoluciones),
			CONCAT(OLD.id_evolucion, ' ', OLD.descripcion, ' ', OLD.id_tratamiento, ' ', OLD.id_turno, ' ', OLD.id_paciente, ' ', OLD.id_empleado, ' ', IF(OLD.id_trabajo_laboratorio IS NULL,'', OLD.id_trabajo_laboratorio)),
            CONCAT(NEW.id_evolucion, ' ', NEW.descripcion, ' ', NEW.id_tratamiento, ' ', NEW.id_turno, ' ', NEW.id_paciente, ' ', NEW.id_empleado, ' ', IF(NEW.id_trabajo_laboratorio IS NULL,'', NEW.id_trabajo_laboratorio))
		);
    END IF;
END$$
DELIMITER ;

-- Trigger que al agregar una evolucion con un tratamiento que tenga el parametro trabajo_laboratorio = 1, llama al stored procedure create_new_lab_work 
-- Este crea el nuevo trabajo de laboratorio y actualiza la evolucion con el id que acaba de crear

DELIMITER $$
CREATE TRIGGER `new_lab_work`
BEFORE INSERT ON `evoluciones`
FOR EACH ROW
BEGIN
    SET @laboratorio = (SELECT trabajo_laboratorio FROM tratamientos WHERE id_tratamiento = NEW.id_tratamiento);
    
    IF @laboratorio = 1 THEN       
         IF NEW.id_trabajo_laboratorio IS NULL THEN
			-- Este chequeo es por si se agrega una evolución con un trabajo de laboratorio ya asignado
			INSERT INTO trabajos_laboratorio (id_trabajo_laboratorio) VALUES (NULL);
            SET NEW.id_trabajo_laboratorio = (SELECT MAX(id_trabajo_laboratorio) FROM trabajos_laboratorio);
         END IF;
         
    END IF;
END$$

-- Triggers para validar los datos de la tabla pacientes

CREATE TRIGGER validar_datos_paciente_insert
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN 
	IF NEW.celular IS NULL AND NEW.telefono IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe proveer al menos un telefono de contacto';
    END IF;
    
	IF validar_email(NEW.email) = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	SET NEW.documento = limpiar_string(NEW.documento);
    SET NEW.telefono = limpiar_string(NEW.telefono);
    SET NEW.celular = limpiar_string(NEW.celular);
END$$

CREATE TRIGGER validar_datos_paciente_update
BEFORE UPDATE ON pacientes
FOR EACH ROW
BEGIN 
	IF NEW.celular IS NULL AND NEW.telefono IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe proveer al menos un telefono de contacto';
    END IF;
    
	IF validar_email(NEW.email) = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	SET NEW.documento = limpiar_string(NEW.documento);
    SET NEW.telefono = limpiar_string(NEW.telefono);
    SET NEW.celular = limpiar_string(NEW.celular);
END$$

-- Triggers para validar los datos de la tabla empleados

CREATE TRIGGER validar_datos_empleado_insert
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN 
	IF validar_email(NEW.email) = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	SET NEW.documento = limpiar_string(NEW.documento);
    SET NEW.celular = limpiar_string(NEW.celular);
END$$

CREATE TRIGGER validar_datos_empleado_update
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN 
	IF validar_email(NEW.email) = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	SET NEW.documento = limpiar_string(NEW.documento);
    SET NEW.celular = limpiar_string(NEW.celular);
END$$

-- Triggers de validación de datos para la tabla tipo_de_empleado

CREATE TRIGGER validar_datos_tipo_empleado_insert
BEFORE INSERT ON tipo_de_empleado
FOR EACH ROW
BEGIN 
	IF NEW.porcentaje_tratamiento < 0 OR NEW.porcentaje_tratamiento > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje de tratamiento va entre 0 y 100';
	END IF;
    
    IF NEW.porcentaje_laboratorio < 0 OR NEW.porcentaje_laboratorio > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje de laboratorio va entre 0 y 100';
	END IF;
END$$

CREATE TRIGGER validar_datos_tipo_empleado_update
BEFORE UPDATE ON tipo_de_empleado
FOR EACH ROW
BEGIN 
	IF NEW.porcentaje_tratamiento < 0 OR NEW.porcentaje_tratamiento > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje de tratamiento va entre 0 y 100';
	END IF;
    
    IF NEW.porcentaje_laboratorio < 0 OR NEW.porcentaje_laboratorio > 100 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje de laboratorio va entre 0 y 100';
	END IF;
END$$

-- Triggers de validación de datos para la tabla turnos

CREATE TRIGGER validar_datos_turnos_insert
BEFORE INSERT ON turnos
FOR EACH ROW
BEGIN 
	IF NEW.id_empleado IS NULL AND NEW.id_tratamiento IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El turno debe tener asignado o un odontólogo o un tratamiento radiológico';
	END IF;
END$$

CREATE TRIGGER validar_datos_turnos_update
BEFORE UPDATE ON turnos
FOR EACH ROW
BEGIN 
	IF NEW.id_empleado IS NULL AND NEW.id_tratamiento IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El turno debe tener asignado o un odontólogo o un tratamiento radiológico';
	END IF;
END$$

-- Triggers de validación de datos de la tabla laboratorios

CREATE TRIGGER validar_datos_laboratorios_insert
BEFORE INSERT ON laboratorios
FOR EACH ROW
BEGIN 
	IF NEW.email IS NOT NULL AND validar_email(NEW.email) = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;
    
	SET NEW.telefono = limpiar_string(NEW.telefono);
    SET NEW.cuit = limpiar_string(NEW.cuit);
END$$

CREATE TRIGGER validar_datos_laboratorios_update
BEFORE UPDATE ON laboratorios
FOR EACH ROW
BEGIN
	IF validar_email(NEW.email) = 0 OR NEW.email IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	SET NEW.telefono = limpiar_string(NEW.telefono);
    SET NEW.cuit = limpiar_string(NEW.cuit);
END$$

-- Este trigger modifica automáticamente el estado de un trabajo de laboratorio de 'Iniciado' a 'Asignado' cuando se se asigna un id_laboratorio

CREATE TRIGGER asignar_laboratorio
BEFORE UPDATE ON trabajos_laboratorio
FOR EACH ROW
BEGIN
	IF OLD.id_laboratorio IS NULL AND NEW.id_laboratorio IS NOT NULL THEN
		SET NEW.id_estado_trabajo_laboratorio = 2;
	END IF;
END$$
DELIMITER ;

-- FUNCIONES --

-- Esta función permite calcular los honorarios mensuales de un odontólogo en función de los tratamientos que realizó
-- El parámetro id es la columna id_empleado de la tabla empleados, correspondiente al odontólogo particular
-- El parámetro mes es el valor numérico del mes del año para el cual se desea calcular los honorarios
-- Un ejemplo seria llamar SELECT honorario_mensual(1, 2);

DELIMITER $$
DROP FUNCTION IF EXISTS `honorario_mensual`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `honorario_mensual`(id INT, mes INT) 
	RETURNS DECIMAL(10,2)
    READS SQL DATA
BEGIN
	DECLARE porcentaje_tratamiento INT;
    DECLARE porcentaje_laboratorio INT;
    DECLARE facturacion_mensual DECIMAL(10,2);
    DECLARE laboratorios_mensual DECIMAL(10,2);
    
	SELECT te.porcentaje_tratamiento, te.porcentaje_laboratorio INTO porcentaje_tratamiento, porcentaje_laboratorio
	FROM empleados e
	JOIN tipo_de_empleado te ON e.id_tipo_empleado = te.id_tipo_empleado
	WHERE e.id_empleado = id;
    
    IF porcentaje_tratamiento = 0 THEN
		RETURN 0.00;
	END IF;
    
	SELECT SUM(facturacion) INTO facturacion_mensual
    FROM facturacion_odontologo
	WHERE id_empleado = id
	AND MONTH(fecha) = mes;
    
    SELECT SUM(tl.precio) INTO laboratorios_mensual
    FROM evoluciones ev 
	JOIN turnos tu ON ev.id_turno = tu.id_turno
	JOIN trabajos_laboratorio tl ON ev.id_trabajo_laboratorio = tl.id_trabajo_laboratorio
	WHERE ev.id_empleado = id
	AND MONTH(tu.fecha) = mes;
    
    RETURN (facturacion_mensual * porcentaje_tratamiento - laboratorios_mensual * porcentaje_laboratorio) / 100;
END$$

-- Esta función permite calcular los el adicional que cobran algunos empleados por ciertos tratamientos en un determinado mes
-- El parámetro id es la columna id_empleado de la tabla empleados, correspondiente al odontólogo particular
-- El parámetro mes es el valor numérico del mes del año para el cual se desea calcular los honorarios
-- Un ejemplo seria llamar SELECT adicional_montos_fijos(13, 2);

DROP FUNCTION IF EXISTS `adicional_montos_fijos`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `adicional_montos_fijos`(id INT, mes INT) 
	RETURNS DECIMAL(10,2)
    READS SQL DATA
BEGIN
	DECLARE cobra_monto_fijo TINYINT;
    DECLARE adicional DECIMAL(10,2);
    
	SELECT te.lleva_monto_fijo INTO cobra_monto_fijo
    FROM empleados em
    JOIN tipo_de_empleado te ON em.id_tipo_empleado = te.id_tipo_empleado
    WHERE em.id_empleado = id;
    
    IF cobra_monto_fijo = 0 THEN
		RETURN 0.00;
	END IF;
    
    SELECT SUM(tr.monto_fijo) INTO adicional
	FROM pagos p
	JOIN evoluciones ev ON p.id_evolucion = ev.id_evolucion
	JOIN tratamientos tr ON ev.id_tratamiento = tr.id_tratamiento
	WHERE ev.id_empleado = id
    AND MONTH(p.fecha) = mes;
    
RETURN adicional;
END$$

-- DOCSTRING

CREATE FUNCTION `limpiar_string` (input VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE cleaned_string VARCHAR(50);
    DECLARE c VARCHAR(1);
    DECLARE i, n INT;
    
    SET cleaned_string = '';
    SET n = CHAR_LENGTH(input);
	SET i = 0;
    
    IF LOCATE('+', input) IN (1, 2) THEN
		SET cleaned_string = '+';
	END IF;
    
	WHILE i <= n DO
		SET c = RIGHT(LEFT(input, i),1);
        
        IF LOCATE(c, '0123456789') != 0 THEN
			SET cleaned_string = CONCAT(cleaned_string, c);
        END IF;
        
        SET i = i + 1;
    END WHILE;
    
    RETURN cleaned_string;
END$$

-- DOCSTRING

CREATE FUNCTION `validar_email` (input VARCHAR(50))
RETURNS TINYINT
NO SQL
BEGIN
	-- El REGEXP la saque de https://stackoverflow.com/questions/12759596/validate-email-addresses-in-mysql
	IF input REGEXP '^[a-zA-Z0-9][a-zA-Z0-9.!#$%&\'*+-/=?^_`{|}~]*?[a-zA-Z0-9._-]?@[a-zA-Z0-9][a-zA-Z0-9._-]*?[a-zA-Z0-9]?\\.[a-zA-Z]{2,63}$' THEN
		RETURN 1;
	END IF;
	RETURN 0;
END$$

DELIMITER ;

-- POBLACIÓN DE TABLAS --

INSERT INTO tipo_de_empleado (titulo, atiende, porcentaje_tratamiento, porcentaje_laboratorio, lleva_monto_fijo) 
VALUES ('Socio', 1, 70, 50, 0), ('Odontólogo', 1, 40, 50, 0), ('Recepcionista', 0, 0, 0, 1), ('Asistente', 0, 0, 0, 1);
    
INSERT INTO modo_pago (modo)
VALUES ('Efectivo'), ('Mercado Pago'), ('Transferencia'), ('Tarjeta de Débito'), ('Tarjeta de Crédito');

INSERT INTO laboratorios (nombre, telefono, direccion, email, cuit, activo)
VALUES
	('Dental Lab', '47233265', 'Av. Rivadavia 2154, Balvanera', NULL, '30215469857', 1),
    ('Super Lab','42569874', 'Av. Maipu 1656, Vicente Lopez, Pcia. de Buenos Aires', 'superlab@gmail.com', '30256547891', 0),
    ('Fym Dental Lab', '43254785', 'Av. Rivadavia 1936, Balvanera', 'fymdental@gmail.com', '30487963525', 1),
    ('Dientes Derechos', '41589632', 'Chiclana 952, Saavedra', 'dientesderechos@gmail.com' , '27356987841', 1),
    ('Esteban Alderete', '1549786523', 'Carlos Pellegrini 3652, San Nicolás', 'ealderete@gmail.com', '20296589851', 1),
    ('Timoteo Astro Mecanica Dental', '1532564578', 'Bernardo de Irigoyen 2563, Florida, Pcia. de Buenos Aires', 'tamecanicadental@gmail.com', '20312569402', 1);

INSERT INTO generos (genero) VALUES ('Femenino'), ('Masculino'), ('Otros');

INSERT INTO estado_turno (estado) VALUES ('No asistió'), ('Asistió'), ('Turno futuro');

INSERT INTO estado_trabajo_laboratorio (estado) VALUES ('Iniciado'), ('Asignado'), ('Despachado'), ('Recibido'), ('Entregado');

INSERT INTO pacientes (nombre, apellido, documento, id_genero, fecha_de_nacimiento, email, celular, telefono)
VALUES 
	('Juan', 'Straciatella', 34521478, 2, '1990-02-25', 'jstraciatella@gmail.com', '1549769856', '41527014'),
    ('Estela', 'Marquez', 16529689, 1, '1965-07-10', 'estela.marquez26@gmail.com', '1554789561', '50249014'),
    ('Juliana Ester', 'Porto', 23457898, 1, '1973-10-07', 'julianap163@gmail.com', '1543689501', '47926520'),
    ('Melisa', 'Sertain', 40158965, 1, '1995-04-02', 'melisertain@gmail.com', '1537894014', '46359014'),
    ('Esteban Julio', 'Nuñez Cartez', 45165896, 2, '2002-09-21', 'chuckynunez@gmail.com', '1544398855', '46359078'),
    ('Belen', 'Lussanne', 10458962, 1, '1954-03-17', 'blussanne@gmail.com', '1530256981', '47485201'),
    ('Mingo', 'Gomez', 29568965, 2, '1947-11-27', 'mingogomez23@gmail.com', '1554129021', '47802563'),
    ('Pedro Julian'	, 'Milan', 17845025, 2, '1963-05-25', 'pedrojulianmilan@gmail.com', '1543569014', '47102589'),
    ('Dixon', 'Johnson', 42658901, 2, '1999-01-12', 'dixiej1999@gmail.com', '1541222298', '46985632'),
    ('Usnavi', 'Gonzalez', 31642589, 2, '1986-06-01', 'usnavigonzalez147@gmail.com', '1549863025', '45654445'),
    ("Donovan", "Blackwell", 40735541, 2, "1954-07-25", "d.blackwell@aol.edu", "1527701146", "46331425"),
	("Kuame", "Decker", 15362206, 1, "1967-05-13", "d_kuame@google.com", "1566409614", "40798054"),
	("Pamela", "Campos", 23330615, 1, "1963-09-16", "campospamela@outlook.couk", "1551002884", "43851317"),
	("Jana", "Duran", 11158527, 1, "1951-05-04", "djana@google.org", "1555647381", "42870144"),
	("Rooney", "Mooney", 18894689, 2, "1955-08-27", "rooney-mooney8435@protonmail.ca", "1524640540", "48313313"),
    ("Cameron", "Mayo", 29190432, 2, "1983-07-20", "cameron-mayo2654@aol.edu", "1538523683", "47966741"),
	("Colt", "Young", 26981742, 2, "1964-11-23", "youngcolt@protonmail.edu", "1572127341", "47326858"),
	("Harper", "Walton", 24366598, 1, "1967-08-14", "h.walton846@hotmail.org", "1596279918", "41611574"),
	("Solomon", "Nguyen", 18895062, 2, "1979-04-18", "nguyen.solomon8053@hotmail.com" , "1553730945", "47322147"),
	("Brian", "Morrow", 30504045, 2, "2003-10-07", "mbrian9941@hotmail.edu", "1574458573", "47912343"),
    ("Imogene", "Kelley", 23794589, 1, "1958-10-18", "kelley.imoge6046@protomail.couk", "1534452023", "48276488"),
	("Yvonne", "Lyons", 34352612, 1, "1981-11-24", "y.lyons@hotmail.org", "1535280599", "40512666"),
	("Cruz", "Cash", 44218202, 2, "1958-01-03", "cruz-cash@hotmail.ca", "1516314639", "41557314"),
	("Nissim", "Sosa", 32224776, 1, "1961-01-06", "n_sosa8667@outlook.org", "1544363174", "43113127"),
	("Veda", "Kaufman", 12929457, 1, "1986-04-05", "kaufman-veda7250@hotmail.org", "1531582363", "41644859");

INSERT INTO tratamientos (nombre, nomenclador, precio, monto_fijo, trabajo_laboratorio)
VALUES 
	('Caries', 'CI.1012.01', 3500.00, 0.00, 0),
    ('Radiografía panorámica', 'CI.1034.01', 1650.25, 350.00, 0),
    ('Implante', 'CI.1102.01', 26750.00, 0.00, 0),
    ('Corona sobre implante', 'CI.1102.02', 47855.00, 0.00, 1),
    ('Tratamiento de conducto', 'CI.1005.01', 16500.00, 0.00, 0),
    ('Alineadores', 'CI.1501.01', 105000.00, 0.00, 1),
    ('Perno', 'CI.1005.02', 11500.00, 0.00, 0),
    ('Corona sobre perno', 'CI.1005.03', 37450.00, 0.00, 1),
    ('Placa miorrelajante', 'CI.1250.01', 6500.00, 500.00, 1),
    ('Limpieza', 'CI.1022.01', 8950.00, 0.00, 0);
    
INSERT INTO empleados (nombre, apellido, documento, id_genero, fecha_de_nacimiento, email, celular, direccion, id_tipo_empleado, activo)
VALUES 
	('Sebastián', 'Galarza', 34987014, 2, '1990-02-16', 'sgalarza@gmail.com', '1543580123', 'Cochabamba 498, CABA', 1, 1),
    ('Adriana', 'Lillian', 32421598, 1, '1989-12-14', 'adrilili@gmail.com', '1543659878', 'Cochabamba 498, CABA', 1, 1),
    ('Ximena', 'Ponce', 37259846, 1, '1993-09-26', 'ximelaloca@gmail.com', '1535980147', 'Av Santa Fe 3256 6A, CABA', 2, 1),
    ('Roberto Jesus', 'Rodón', 39426957, 2, '1957-01-07', 'bobbyroddy@gmail.com', '1541592015', 'Av. Rivadavia 1965 4C, CABA', 2, 1),
    ('Julieta', 'Wilson', 36195025, 1, '1991-05-11', 'jwilson91@gmail.com', '1525059852', 'Congreso 2018, CABA', 2, 1),
    ('Alberto', 'Benitez', 34258701, 2, '1990-03-31', 'bertiebenitez1990@gmail.com', '1540593014', 'Bernardo Ader 1651, Carapachay, Pcia de Buenos Aires', 2, 1),
    ('Lisandro Javier', 'Paso', 35489632, 2, '1990-07-20', 'lisapaso01@gmail.com', '1544596522', 'Av. Cabildo 651, CABA', 2, 0),
    ('Augusto', 'Nómade', 36652102, 2, '1991-11-02', 'gustomade@gmail.com', '1542021069', 'Frey Justo Sarmiento 620, CABA', 2, 0),
    ('Florencia', 'Del Carril', 42159870, 1, '1999-06-25', 'flordelcarril@gmail.com', '1541059877', 'Gaspar Campos, Vicente Lopez, Pcia. de Buenos Aires', 3, 1),
    ('Celeste', 'Umbaki', 41485201, 1, '1996-10-10', 'celesbaki10@gmail.com', '1556988746', 'Nuñez 2014, CABA', 3, 1),
    ('Beatriz', 'Portengo', 27452014, 1, '1980-08-18', 'beaportengo05@gmail.com', '1544159025', 'Juncal 410, CABA', 3, 0),
    ('Luciana', 'Latorre', 14731529, 1, '1961-01-16', 'llatorre105@gmail.com', '1546359852', 'Billinghurst 2856, CABA', 3, 1),
    ('Raquel', 'Brea', 35412985, 1, '1990-02-08', 'kellybrea90@gmail.com', '1533014978', 'Rio de Janerico 1547, CABA', 4, 1),
    ('Ramona', 'Montiel', 40415951, 1, '1995-06-16', 'rmontiel95@gmail.com', '1550789889', '7 de Septiembre 1597, CABA', 4, 1);

INSERT INTO turnos (fecha, hora, id_estado_turno, id_paciente, id_empleado, id_tratamiento)
VALUES 
	-- Ondontólogo id 1
    ('2022-02-12', '10:00', 2, 19, 1, NULL), ('2022-02-12', '12:00', 2,  6, 1, NULL), ('2022-02-12', '14:00', 1, 14, 1, NULL), ('2022-02-12', '16:00', 2,  2, 1, NULL),
    ('2022-04-25', '10:30', 2, 25, 1, NULL), ('2022-04-25', '11:30', 2, 19, 1, NULL), ('2022-04-25', '13:30', 2, 10, 1, NULL), ('2022-04-25', '15:00', 2,  2, 1, NULL),
    ('2022-06-17', '10:30', 1, 13, 1, NULL), ('2022-06-17', '12:00', 2, 16, 1, NULL), ('2022-06-17', '14:00', 2, 22, 1, NULL), ('2022-06-17', '15:30', 2, 25, 1, NULL),
    ('2022-09-05', '11:00', 2, 13, 1, NULL), ('2022-09-05', '12:30', 2,  8, 1, NULL), ('2022-09-05', '14:00', 2, 24, 1, NULL), ('2022-09-05', '16:00', 1,  3, 1, NULL),
    ('2022-11-29', '11:00', 3, 15, 1, NULL), ('2022-11-29', '12:30', 3,  1, 1, NULL), ('2022-11-29', '14:30', 3, 19, 1, NULL), ('2022-11-29', '16:30', 3,  8, 1, NULL),
    ('2022-12-13', '10:00', 3,  8, 1, NULL), ('2022-12-13', '12:00', 3, 14, 1, NULL), ('2022-12-13', '13:00', 3, 19, 1, NULL), ('2022-12-13', '17:30', 3, 10, 1, NULL),
    -- Ondontólogo id 2
    ('2022-02-12', '10:00', 2, 15, 2, NULL), ('2022-02-12', '12:00', 2, 14, 2, NULL), ('2022-02-12', '14:00', 2, 21, 2, NULL), ('2022-02-12', '16:00', 1, 23, 2, NULL),
    ('2022-04-25', '10:30', 1, 23, 2, NULL), ('2022-04-25', '11:30', 2,  4, 2, NULL), ('2022-04-25', '13:30', 2,  9, 2, NULL), ('2022-04-25', '15:00', 2, 15, 2, NULL),
    ('2022-06-17', '10:30', 2,  1, 2, NULL), ('2022-06-17', '12:00', 1, 21, 2, NULL), ('2022-06-17', '14:00', 2, 22, 2, NULL), ('2022-06-17', '15:30', 2, 17, 2, NULL),
    ('2022-09-05', '11:00', 1, 14, 2, NULL), ('2022-09-05', '12:30', 2,  1, 2, NULL), ('2022-09-05', '14:00', 2, 20, 2, NULL), ('2022-09-05', '16:00', 2,  4, 2, NULL),
    ('2022-11-29', '11:00', 3,  1, 2, NULL), ('2022-11-29', '12:30', 3, 19, 2, NULL), ('2022-11-29', '14:30', 3,  2, 2, NULL), ('2022-11-29', '16:30', 3, 11, 2, NULL),
    ('2022-12-13', '10:00', 3,  3, 2, NULL), ('2022-12-13', '12:00', 3,  4, 2, NULL), ('2022-12-13', '13:00', 3, 13, 2, NULL), ('2022-12-13', '17:30', 3,  1, 2, NULL),
    -- Ondontólogo id 3
    ('2022-02-12', '10:00', 2, 11, 3, NULL), ('2022-02-12', '12:00', 2,  3, 3, NULL), ('2022-02-12', '14:00', 2,  8, 3, NULL), ('2022-02-12', '16:00', 2, 21, 3, NULL),
    ('2022-04-25', '10:30', 2, 13, 3, NULL), ('2022-04-25', '11:30', 1, 14, 3, NULL), ('2022-04-25', '13:30', 1,  6, 3, NULL), ('2022-04-25', '15:00', 2,  4, 3, NULL),
    ('2022-06-17', '10:30', 2, 14, 3, NULL), ('2022-06-17', '12:00', 2, 25, 3, NULL), ('2022-06-17', '14:00', 2, 24, 3, NULL), ('2022-06-17', '15:30', 1, 16, 3, NULL),
    ('2022-09-05', '11:00', 1,  8, 3, NULL), ('2022-09-05', '12:30', 1, 23, 3, NULL), ('2022-09-05', '14:00', 2,  7, 3, NULL), ('2022-09-05', '16:00', 2, 15, 3, NULL),
    ('2022-11-29', '11:00', 3, 20, 3, NULL), ('2022-11-29', '12:30', 3, 12, 3, NULL), ('2022-11-29', '14:30', 3, 19, 3, NULL), ('2022-11-29', '16:30', 3, 25, 3, NULL),
    ('2022-12-13', '10:00', 3,  4, 3, NULL), ('2022-12-13', '12:00', 3,  5, 3, NULL), ('2022-12-13', '13:00', 3, 14, 3, NULL), ('2022-12-13', '17:30', 3, 16, 3, NULL),
    -- Ondontólogo id 4
    ('2022-02-12', '10:00', 2,  3, 4, NULL), ('2022-02-12', '12:00', 1,  9, 4, NULL), ('2022-02-12', '14:00', 2,  1, 4, NULL), ('2022-02-12', '16:00', 2, 22, 4, NULL),
    ('2022-04-25', '10:30', 2, 18, 4, NULL), ('2022-04-25', '11:30', 1, 20, 4, NULL), ('2022-04-25', '13:30', 2,  9, 4, NULL), ('2022-04-25', '15:00', 2, 11, 4, NULL),
    ('2022-06-17', '10:30', 2, 13, 4, NULL), ('2022-06-17', '12:00', 2, 19, 4, NULL), ('2022-06-17', '14:00', 2,  6, 4, NULL), ('2022-06-17', '15:30', 2,  1, 4, NULL),
    ('2022-09-05', '11:00', 1,  7, 4, NULL), ('2022-09-05', '12:30', 2, 20, 4, NULL), ('2022-09-05', '14:00', 1,  1, 4, NULL), ('2022-09-05', '16:00', 2,  8, 4, NULL),
    ('2022-11-29', '11:00', 3, 18, 4, NULL), ('2022-11-29', '12:30', 3, 12, 4, NULL), ('2022-11-29', '14:30', 3, 16, 4, NULL), ('2022-11-29', '16:30', 3, 20, 4, NULL),
    ('2022-12-13', '10:00', 3, 19, 4, NULL), ('2022-12-13', '12:00', 3, 15, 4, NULL), ('2022-12-13', '13:00', 3,  3, 4, NULL), ('2022-12-13', '17:30', 3, 16, 4, NULL),
    -- Ondontólogo id 5
    ('2022-02-12', '10:00', 1, 24, 5, NULL), ('2022-02-12', '12:00', 2,  2, 5, NULL), ('2022-02-12', '14:00', 2, 12, 5, NULL), ('2022-02-12', '16:00', 2,  4, 5, NULL),
    ('2022-04-25', '10:30', 2,  5, 5, NULL), ('2022-04-25', '11:30', 2,  1, 5, NULL), ('2022-04-25', '13:30', 2,  9, 5, NULL), ('2022-04-25', '15:00', 1, 24, 5, NULL),
    ('2022-06-17', '10:30', 2, 22, 5, NULL), ('2022-06-17', '12:00', 2, 13, 5, NULL), ('2022-06-17', '14:00', 2,  5, 5, NULL), ('2022-06-17', '15:30', 2,  2, 5, NULL),
    ('2022-09-05', '11:00', 2,  4, 5, NULL), ('2022-09-05', '12:30', 2,  7, 5, NULL), ('2022-09-05', '14:00', 2,  5, 5, NULL), ('2022-09-05', '16:00', 2,  6, 5, NULL),
    ('2022-11-29', '11:00', 3,  3, 5, NULL), ('2022-11-29', '12:30', 3,  4, 5, NULL), ('2022-11-29', '14:30', 3,  7, 5, NULL), ('2022-11-29', '16:30', 3,  8, 5, NULL),
    ('2022-12-13', '10:00', 3, 22, 5, NULL), ('2022-12-13', '12:00', 3, 24, 5, NULL), ('2022-12-13', '13:00', 3,  2, 5, NULL), ('2022-12-13', '17:30', 3, 16, 5, NULL),
    -- Ondontólogo id 6
    ('2022-02-12', '10:00', 2, 20, 6, NULL), ('2022-02-12', '12:00', 2, 21, 6, NULL), ('2022-02-12', '14:00', 2,  9, 6, NULL), ('2022-02-12', '16:00', 2,  8, 6, NULL),
    ('2022-04-25', '10:30', 2, 22, 6, NULL), ('2022-04-25', '11:30', 2, 20, 6, NULL), ('2022-04-25', '13:30', 1, 17, 6, NULL), ('2022-04-25', '15:00', 1, 10, 6, NULL),
    ('2022-06-17', '10:30', 2,  7, 6, NULL), ('2022-06-17', '12:00', 1,  8, 6, NULL), ('2022-06-17', '14:00', 2, 18, 6, NULL), ('2022-06-17', '15:30', 1,  3, 6, NULL),
    ('2022-09-05', '11:00', 2, 17, 6, NULL), ('2022-09-05', '12:30', 2,  5, 6, NULL), ('2022-09-05', '14:00', 2, 15, 6, NULL), ('2022-09-05', '16:00', 2, 16, 6, NULL),
    ('2022-11-29', '11:00', 3,  5, 6, NULL), ('2022-11-29', '12:30', 3, 25, 6, NULL), ('2022-11-29', '14:30', 3,  6, 6, NULL), ('2022-11-29', '16:30', 3, 24, 6, NULL),
    ('2022-12-13', '10:00', 3, 22, 6, NULL), ('2022-12-13', '12:00', 3, 19, 6, NULL), ('2022-12-13', '13:00', 3,  7, 6, NULL), ('2022-12-13', '17:30', 3, 25, 6, NULL),
    -- Tratamientos sin odontologo
    ('2022-02-12', '10:30', 2, 17, NULL, 2), ('2022-02-12', '15:00', 2, 10, NULL, 2), 
    ('2022-04-25', '11:00', 2, 10, NULL, 2), ('2022-04-25', '16:30', 2, 22, NULL, 2),
    ('2022-09-05', '12:00', 2,  6, NULL, 2), ('2022-09-05', '14:00', 2, 25, NULL, 2), 
    ('2022-12-13', '10:30', 3, 23, NULL, 2), ('2022-12-13', '16:00', 3, 17, NULL, 2);

INSERT INTO evoluciones (id_tratamiento, id_turno, id_paciente, id_empleado, descripcion)
VALUES 
	(7, 1, 19, 1, 'Se cementó un perno sobre la pieza 23'),
	(4, 2, 6, 1, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 17'),
	(5, 2, 6, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
	(3, 2, 6, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
	(7, 4, 2, 1, 'Se cementó un perno sobre la pieza 25'),
	(1, 4, 2, 1, 'Se removió una caries en la pieza 26'),
	(6, 5, 25, 1, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 5, 25, 1, 'Se removió una caries en la pieza 27'),
	(5, 5, 25, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
	(7, 6, 19, 1, 'Se cementó un perno sobre la pieza 26'),
	(3, 7, 10, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 28'),
	(7, 8, 2, 1, 'Se cementó un perno sobre la pieza 26'),
	(7, 10, 16, 1, 'Se cementó un perno sobre la pieza 21'),
	(9, 10, 16, 1, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(9, 11, 22, 1, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(3, 11, 22, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 10'),
	(1, 12, 25, 1, 'Se removió una caries en la pieza 6'),
	(5, 12, 25, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 31'),
	(6, 13, 13, 1, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(2, 14, 8, 1, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(5, 15, 24, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 7'),
	(4, 15, 24, 1, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 30'),
	(4, 25, 15, 2, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 16'),
	(4, 26, 14, 2, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 32'),
	(9, 27, 21, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(3, 30, 4, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 19'),
	(7, 31, 9, 2, 'Se cementó un perno sobre la pieza 21'),
	(8, 32, 15, 2, 'Se colocó un implante de porcelana sobre el perno de la pieza 19'),
	(9, 33, 1, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 33, 1, 2, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 35, 22, 2, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(3, 35, 22, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
	(1, 35, 22, 2, 'Se removió una caries en la pieza 24'),
	(9, 36, 17, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(9, 38, 1, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 39, 20, 2, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(9, 39, 20, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(5, 39, 20, 2, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
	(3, 40, 4, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 1'),
	(9, 40, 4, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(10, 40, 4, 2, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 49, 11, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 17'),
	(2, 49, 11, 3, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(8, 50, 3, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 20'),
	(6, 51, 8, 3, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 52, 21, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(9, 53, 13, 3, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(1, 53, 13, 3, 'Se removió una caries en la pieza 8'),
	(10, 53, 13, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(7, 56, 4, 3, 'Se cementó un perno sobre la pieza 22'),
	(3, 57, 14, 3, 'Se colocó un implante de titanio luego de una cirugía en la pieza 18'),
	(10, 57, 14, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 58, 25, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 27'),
	(2, 58, 25, 3, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 58, 25, 3, 'Se cementó un perno sobre la pieza 8'),
	(7, 59, 24, 3, 'Se cementó un perno sobre la pieza 12'),
	(4, 63, 7, 3, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
	(9, 64, 15, 3, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 73, 3, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(6, 75, 1, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 76, 22, 4, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 77, 18, 4, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 19'),
	(8, 79, 9, 4, 'Se colocó un implante de porcelana sobre el perno de la pieza 4'),
	(6, 80, 11, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(2, 81, 13, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(4, 82, 19, 4, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 3'),
	(9, 83, 6, 4, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(5, 83, 6, 4, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
	(2, 84, 1, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 86, 20, 4, 'Se cementó un perno sobre la pieza 28'),
	(2, 88, 8, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(8, 98, 2, 5, 'Se colocó un implante de porcelana sobre el perno de la pieza 11'),
	(6, 98, 2, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 98, 2, 5, 'Se removió una caries en la pieza 4'),
	(6, 99, 12, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 100, 4, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 101, 5, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 12'),
	(5, 102, 1, 5, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 32'),
	(3, 103, 9, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 31'),
	(4, 105, 22, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 26'),
	(2, 105, 22, 5, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(10, 106, 13, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(6, 107, 5, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 107, 5, 5, 'Se removió una caries en la pieza 32'),
	(7, 108, 2, 5, 'Se cementó un perno sobre la pieza 26'),
	(3, 109, 4, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 30'),
	(10, 110, 7, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 110, 7, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
	(5, 111, 5, 5, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 2'),
	(3, 111, 5, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 2'),
	(1, 111, 5, 5, 'Se removió una caries en la pieza 21'),
	(4, 112, 6, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 21'),
	(2, 121, 20, 6, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 121, 20, 6, 'Se cementó un perno sobre la pieza 31'),
	(5, 121, 20, 6, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 18'),
	(9, 122, 21, 6, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(10, 123, 9, 6, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(7, 124, 8, 6, 'Se cementó un perno sobre la pieza 17'),
	(3, 125, 22, 6, 'Se colocó un implante de titanio luego de una cirugía en la pieza 12'),
	(9, 126, 20, 6, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(4, 129, 7, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 11'),
	(2, 131, 18, 6, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(10, 133, 17, 6, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 133, 17, 6, 'Se colocó un implante de porcelana sobre el perno de la pieza 15'),
	(4, 134, 5, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 6'),
	(8, 134, 5, 6, 'Se colocó un implante de porcelana sobre el perno de la pieza 14'),
	(4, 135, 15, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 13'),
	(4, 136, 16, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 5'),
	(2, 145, 17, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 146, 10, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 147, 10, 12, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 148, 22, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 149, 6, 9, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 150, 25, 12, 'Se realizó una radiografía panorámica de la boca del paciente');
    
INSERT INTO pagos (fecha, id_evolucion, monto, id_modo_pago)
VALUES
	('2022-02-12', 1, 11500.0, 5), ('2022-02-12', 2, 47855.0, 3), ('2022-02-12', 3, 16500.0, 1), ('2022-02-12', 4, 26750.0, 2), ('2022-02-12', 5, 3910.0, 2), ('2022-02-15', 5, 7590.0, 2),
	('2022-02-12', 6, 3500.0, 1), ('2022-04-25', 7, 105000.0, 4), ('2022-04-25', 8, 3500.0, 1), ('2022-04-25', 9, 16500.0, 5), ('2022-04-25', 10, 11500.0, 5), ('2022-04-25', 11, 26750.0, 1),
	('2022-04-25', 12, 11500.0, 3), ('2022-06-17', 13, 11500.0, 2), ('2022-06-17', 14, 6500.0, 3), ('2022-06-17', 15, 6500.0, 4), ('2022-06-17', 16, 26750.0, 1), ('2022-06-17', 17, 3500.0, 3),
	('2022-06-17', 18, 16500.0, 3), ('2022-09-05', 19, 105000.0, 5), ('2022-09-05', 20, 1650.25, 3), ('2022-09-05', 21, 16500.0, 2), ('2022-09-05', 22, 47855.0, 1), ('2022-02-12', 23, 47855.0, 5),
	('2022-02-12', 24, 47855.0, 2), ('2022-02-12', 25, 6500.0, 2), ('2022-04-25', 26, 26750.0, 3), ('2022-04-25', 27, 11500.0, 2), ('2022-04-25', 28, 37450.0, 5), ('2022-06-17', 29, 6500.0, 3),
	('2022-06-17', 30, 105000.0, 4), ('2022-06-17', 31, 8950.0, 4), ('2022-06-17', 32, 26750.0, 1), ('2022-06-17', 33, 3500.0, 5), ('2022-06-17', 34, 6500.0, 4), ('2022-09-05', 35, 6500.0, 3),
	('2022-09-05', 36, 105000.0, 1), ('2022-09-05', 37, 6500.0, 1), ('2022-09-05', 38, 16500.0, 5), ('2022-09-05', 39, 13910.0, 5), ('2022-09-08', 39, 12840.0, 5), ('2022-09-05', 40, 6500.0, 3),
	('2022-09-05', 41, 8950.0, 2), ('2022-02-12', 42, 37450.0, 5), ('2022-02-12', 43, 1650.25, 3), ('2022-02-12', 44, 37450.0, 3), ('2022-02-12', 45, 105000.0, 1), ('2022-02-12', 46, 8950.0, 2),
	('2022-04-25', 47, 6500.0, 2), ('2022-04-25', 48, 3500.0, 2), ('2022-04-25', 49, 8950.0, 3), ('2022-04-25', 50, 3795.0, 1), ('2022-04-28', 50, 7705.0, 1), ('2022-06-17', 51, 26750.0, 5),
	('2022-06-17', 52, 8950.0, 2), ('2022-06-17', 53, 37450.0, 2), ('2022-06-17', 54, 1650.25, 4), ('2022-06-17', 55, 11500.0, 2), ('2022-06-17', 56, 11500.0, 2), ('2022-09-05', 57, 47855.0, 1),
	('2022-09-05', 58, 6500.0, 1), ('2022-02-12', 59, 105000.0, 1), ('2022-02-12', 60, 105000.0, 3), ('2022-02-12', 61, 8950.0, 4), ('2022-04-25', 62, 47855.0, 1), ('2022-04-25', 63, 37450.0, 3),
	('2022-04-25', 64, 105000.0, 3), ('2022-06-17', 65, 1650.25, 1), ('2022-06-17', 66, 47855.0, 1), ('2022-06-17', 67, 6500.0, 2), ('2022-06-17', 68, 16500.0, 4), ('2022-06-17', 69, 1650.25, 3),
	('2022-09-05', 70, 11500.0, 2), ('2022-09-05', 71, 1650.25, 4), ('2022-02-12', 72, 37450.0, 2), ('2022-02-12', 73, 105000.0, 5), ('2022-02-12', 74, 3500.0, 3), ('2022-02-12', 75, 105000.0, 3),
	('2022-02-12', 76, 3759.0, 1), ('2022-02-15', 76, 5191.0, 1), ('2022-04-25', 77, 47855.0, 3), ('2022-04-25', 78, 16500.0, 2), ('2022-04-25', 79, 17387.5, 1), ('2022-04-28', 79, 9362.5, 1),
	('2022-06-17', 80, 47855.0, 5), ('2022-06-17', 81, 1650.25, 3), ('2022-06-17', 82, 8950.0, 3), ('2022-06-17', 83, 105000.0, 3), ('2022-06-17', 84, 3500.0, 3), ('2022-06-17', 85, 11500.0, 5),
	('2022-09-05', 86, 26750.0, 5), ('2022-09-05', 87, 8950.0, 3), ('2022-09-05', 88, 47855.0, 5), ('2022-09-05', 89, 16500.0, 4), ('2022-09-05', 90, 12037.5, 3), ('2022-09-08', 90, 14712.5, 3),
	('2022-09-05', 91, 3500.0, 1), ('2022-09-05', 92, 47855.0, 4), ('2022-02-12', 93, 1650.25, 4), ('2022-02-12', 94, 11500.0, 3), ('2022-02-12', 95, 16500.0, 5), ('2022-02-12', 96, 6500.0, 5),
	('2022-02-12', 97, 8950.0, 2), ('2022-02-12', 98, 11500.0, 4), ('2022-04-25', 99, 26750.0, 3), ('2022-04-25', 100, 6500.0, 3), ('2022-06-17', 101, 47855.0, 5), ('2022-06-17', 102, 1650.25, 4),
	('2022-09-05', 103, 8950.0, 4), ('2022-09-05', 104, 37450.0, 1), ('2022-09-05', 105, 47855.0, 5), ('2022-09-05', 106, 37450.0, 3), ('2022-09-05', 107, 47855.0, 2), ('2022-09-05', 108, 47855.0, 1),
	('2022-02-12', 109, 1650.25, 3), ('2022-02-12', 110, 775.62, 3), ('2022-02-15', 110, 874.63, 3), ('2022-04-25', 111, 1650.25, 2), ('2022-04-25', 112, 1650.25, 3), ('2022-09-05', 113, 1650.25, 4),
	('2022-09-05', 114, 1650.25, 2);

-- A continuación modifico las filas vacías autogeneradas en trabajos_laboratorio

UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=63000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=1;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=50000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=2;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=5000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=3;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=17000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=4;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=46000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=5;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=22000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=6;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=42000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=7;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=65000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=8;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=25000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=9;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=32000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=10;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=48000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=11;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=61000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=12;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=49000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=13;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=54000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=14;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=62000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=15;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=22000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=16;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=65000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=17;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=29000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=18;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=7000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=19;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=11000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=20;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=58000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=21;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=17000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=22;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=11000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=23;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=32000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=24;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=54000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=25;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=50000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=26;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=6000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=27;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=45000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=28;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=19000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=29;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=29000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=30;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=51000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=31;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=50000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=32;
UPDATE trabajos_laboratorio SET id_laboratorio=5, precio=38000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=33;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=43000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=34;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=43000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=35;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=7000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=36;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=30000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=37;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=13000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=38;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=54000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=39;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=46000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=40;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=15000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=41;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=54000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=42;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=52000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=43;
UPDATE trabajos_laboratorio SET id_laboratorio=5, precio=51000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=44;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=47000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=45;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=45000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=46;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=7000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=47;

-- VISTAS --

-- VISTA 1
-- Nos permite ver la historia clínica de un paciente si se rstringe la vista por numero de documento (por ejemplo)

CREATE OR REPLACE VIEW historia_clinica AS (
	SELECT t.fecha, t.hora, p.documento, e.descripcion, em.apellido AS 'odontologo'
	FROM evoluciones e
	JOIN turnos t ON e.id_turno = t.id_turno
    JOIN empleados em ON em.id_empleado = e.id_empleado
	JOIN pacientes p ON e.id_paciente = p.id_paciente
	ORDER BY fecha, hora
);

-- Ejemplo de extraer la historia clínica de un paciente

-- SELECT fecha, hora, documento, odontologo, descripcion 
-- FROM historia_clinica
-- WHERE documento = '18895062';

-- VISTA 2
-- Me permite ver la agenda de turnos de la clínica o de un ogontologo en particular

CREATE OR REPLACE VIEW agenda AS (
	SELECT tu.fecha, tu.hora, e.apellido AS 'odontologo', CONCAT(p.nombre, ' ', p.apellido) AS 'paciente', p.documento, p.celular AS 'contacto'
    FROM turnos tu
    JOIN pacientes p ON tu.id_paciente = p.id_paciente
    JOIN empleados e ON tu.id_empleado = e.id_empleado
    WHERE id_estado_turno = 2 -- Los turnos que todavia no sucedieron
    AND id_tratamiento IS NULL -- Ignoro los turnos que corresponden a estudios radiológicos
    ORDER BY fecha, hora
);

-- Ejemplo de extraer la agenda de un odontólogo para un día en particular

-- SELECT fecha, hora, paciente, documento, contacto 
-- FROM agenda
-- WHERE odontologo = 'Lillian'
-- AND fecha = '2022-12-13';

-- Ejemplo de extraer la agenda de un odontólogo para una semana en particular

-- SELECT fecha, hora, paciente, documento, contacto FROM agenda
-- WHERE odontologo = 'Lillian'
-- AND WEEK(fecha) = 48;

-- VISTA 3
-- Me permite ver los turnos de la sección radiológica de la clínica

CREATE OR REPLACE VIEW agenda_radiologica AS (
	SELECT tu.fecha, tu.hora, CONCAT(p.nombre, ' ', p.apellido) AS 'paciente', p.documento, p.celular AS 'contacto', tr.nombre AS 'tratamiento'
    FROM turnos tu
    JOIN pacientes p ON tu.id_paciente = p.id_paciente
    JOIN tratamientos tr ON tu.id_tratamiento = tr.id_tratamiento
    WHERE id_estado_turno = 2 -- Los turnos que todavia no sucedieron
    AND tu.id_empleado IS NULL -- Sólo los turnos para radiológicos
    ORDER BY fecha, hora
);

-- Igual que mas arriba, se puede extraer la agenda radiológica para un día, semana o mes en particular.
-- Tambien se puede separar las agendas si hubera mas de un tipo de estudio radiológico

-- VISTA 4
-- Me permite ver los tratamientos que realiza un odontólogo, para evaluar la perfomance

CREATE OR REPLACE VIEW performance AS (
	SELECT em.apellido AS 'odontologo', tr.nombre AS 'tratamiento', COUNT(ev.id_tratamiento) AS 'cantidad', tu.fecha
    FROM evoluciones ev
    JOIN empleados em ON ev.id_empleado = em.id_empleado
    JOIN tratamientos tr ON ev.id_tratamiento = tr.id_tratamiento
    JOIN turnos tu ON ev.id_turno = tu.id_turno
    WHERE id_tipo_empleado IN (
		SELECT id_tipo_empleado
        FROM tipo_de_empleado
        WHERE atiende = 1 -- Sólo me fijo en la performance de odontólogos
    )
    GROUP BY em.apellido, tr.nombre, tu.fecha
);

-- Ejemplo de la performance de un odontólogo en un dia en particular (u otro período de tiempo adaptando la consulta)

-- SELECT tratamiento, SUM(cantidad) AS 'cantidad'
-- FROM performance
-- WHERE odontologo = 'Galarza'
-- AND fecha = '2022-02-12'
-- GROUP BY tratamiento;

-- Ejemplo de la performance del centro en un dia en particular

-- SELECT tratamiento, SUM(cantidad) as 'cantidad'
-- FROM performance
-- WHERE fecha = '2022-02-12'
-- GROUP BY tratamiento;

-- VISTA 5
-- Me permite ver la facturación total de la clínica, separada por modo de pago 

CREATE OR REPLACE VIEW facturacion_clinica AS (
	SELECT p.fecha, mp.modo, tr.nombre AS 'tratamiento', SUM(p.monto) as 'facturacion'
    FROM pagos p
    JOIN modo_pago mp ON p.id_modo_pago = mp.id_modo_pago
    JOIN evoluciones ev ON p.id_evolucion = ev.id_evolucion
    JOIN tratamientos tr ON ev.id_tratamiento = tr.id_tratamiento
    GROUP BY p.fecha, mp.modo, tr.nombre
    ORDER BY p.fecha
);

-- Ejemplo de obtener la facturacion de un día en particular

-- SELECT fecha, modo, SUM(facturacion) as 'facturacion'
-- FROM facturacion_clinica
-- WHERE fecha = '2022-02-12'
-- GROUP BY modo;

-- Ejemplo de obtener la facturacion de un mes en particular

-- SELECT modo, SUM(facturacion) AS 'facturacion'
-- FROM facturacion_clinica
-- WHERE MONTH(fecha) = 2
-- GROUP BY modo;

-- Ejemplo de obtener la facuracion de la clinica desglosada por tratamiento

-- SELECT tratamiento, SUM(facturacion) AS 'facturacion'
-- FROM facturacion_clinica
-- WHERE MONTH(fecha) = 2
-- GROUP BY tratamiento;

-- VISTA 6 
-- Me permite ver la facturación total de un odontólogo, separada por tipo de tratamiento

CREATE OR REPLACE VIEW facturacion_odontologo AS (
	SELECT p.fecha, em.apellido AS 'profesional', em.id_empleado, tr.nombre AS 'tratamiento', SUM(p.monto) as 'facturacion'
    FROM pagos p
    JOIN evoluciones ev ON p.id_evolucion = ev.id_evolucion
    JOIN tratamientos tr ON ev.id_tratamiento = tr.id_tratamiento
    JOIN empleados em ON ev.id_empleado = em.id_empleado
    GROUP BY p.fecha, em.apellido, tr.nombre
    ORDER BY p.fecha
);

-- Ejemplo de obtener la facturacion de cada odontólogo en un mes

-- SELECT profesional, SUM(facturacion) AS 'facturacion'
-- FROM facturacion_odontologo
-- WHERE MONTH(fecha) = 2
-- GROUP BY profesional;

-- Ejemplo de obtener la facturacion de un odontologo desglosado por tratamiento

-- SELECT tratamiento, SUM(facturacion) AS 'facturacion'
-- FROM facturacion_odontologo
-- WHERE profesional = 'Galarza'
-- GROUP BY tratamiento;

-- Este ultimo es facil de restringir para ver la facturacion desglosada en un período determinado