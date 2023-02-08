DROP DATABASE IF EXISTS fymdental;
CREATE DATABASE IF NOT EXISTS fymdental;
USE fymdental;

CREATE TABLE IF NOT EXISTS tipo_de_empleado (
    id_tipo_empleado INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL UNIQUE,
    atiende TINYINT NOT NULL DEFAULT 1,
    porcentaje_tratamiento TINYINT UNSIGNED NOT NULL DEFAULT 40, 	-- Porcentaje del precio que se lleva el odontólogo
    porcentaje_laboratorio TINYINT UNSIGNED NOT NULL DEFAULT 50, 	-- Porcentaje del costo de laboratorio que asume en odontólogo
    lleva_monto_fijo TINYINT NOT NULL DEFAULT 0 			-- Si este tipo de empleado cobra montos fijos para los tratamientos que los tienen
);

CREATE TABLE IF NOT EXISTS tratamientos (
    id_tratamiento INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    nomenclador VARCHAR(10) NOT NULL UNIQUE,		-- Código único para tratamientos reconocidos, Se puede modificar en funcion del código utilizado
    precio DECIMAL(10,2) NOT NULL,
    monto_fijo DECIMAL(10,2) NOT NULL DEFAULT 0,
    trabajo_laboratorio	TINYINT NOT NULL DEFAULT 0,
    solo_odontologos TINYINT NOT NULL DEFAULT 1 	-- Indica si el tratamiento lo pueden realizar sólo odontólogos o cualquier empleado
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
    genero VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS estado_turno (
    id_estado_turno INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS estado_trabajo_laboratorio (
    id_estado_trabajo_laboratorio INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL UNIQUE
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
    documento DECIMAL(10,0) NOT NULL UNIQUE,
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

CREATE TABLE IF NOT EXISTS honorarios_definitivos(
    fecha_definicion DATE NOT NULL DEFAULT (CURDATE()),
    usuario VARCHAR(50) NOT NULL, 			-- Se ingresa solo en un trigger
    id_empleado INT NOT NULL,
    honorario DECIMAL(10, 2) NOT NULL,
    mes INT NOT NULL,
    anio INT NOT NULL,
    FOREIGN KEY (id_empleado)
	REFERENCES empleados (id_empleado),
    PRIMARY KEY (id_empleado, mes, anio) 		-- No puede haber dos honorarios del mismo mes para un mismo odontólogo
);

CREATE TABLE IF NOT EXISTS turnos (
    id_turno INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    id_estado_turno INT NOT NULL DEFAULT 2,
    id_paciente INT NOT NULL,
    id_empleado INT, 		-- Esta columna tiene valor si es un turno con un odontólogo.
    id_tratamiento INT,		-- Esta columna tiene valor si es un turno radiológico.
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
    id_empleado INT NOT NULL, 		-- Parece redundante con el id_empleado en el turno, pero puede no ateneder el mismo al que se al asigna el turno
    id_trabajo_laboratorio INT,
    FOREIGN KEY (id_tratamiento)
	REFERENCES tratamientos (id_tratamiento),
    FOREIGN KEY (id_turno)
	REFERENCES turnos (id_turno),
    FOREIGN KEY (id_empleado)
	REFERENCES empleados (id_empleado),
    FOREIGN KEY (id_trabajo_laboratorio)
	REFERENCES trabajos_laboratorio (id_trabajo_laboratorio)
);

CREATE TABLE IF NOT EXISTS pagos (
    id_pago INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY ,
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
    objetivo INT NOT NULL, 		-- id del pago sobre el que se realiza el log
    usuario VARCHAR(50)	NOT NULL,
    FOREIGN KEY (objetivo)
	REFERENCES pagos (id_pago)
);

CREATE TABLE IF NOT EXISTS pagos_audit (
    id_changed_log INT NOT NULL,
    old_row VARCHAR(3000) NOT NULL, 		-- String con los datos viejos
    new_row VARCHAR(3000) NOT NULL, 		-- String con los datos nuevos
    FOREIGN KEY (id_changed_log)
	REFERENCES log_pagos (id_log_pagos)
);

CREATE TABLE IF NOT EXISTS log_evoluciones (
    id_log_evoluciones INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT (CURDATE()),
    hora TIME NOT NULL DEFAULT (CURTIME()),
    evento VARCHAR(20) NOT NULL,
    objetivo INT NOT NULL, 		-- id de la evolucion sobra la que que se realiza el log
    usuario VARCHAR(50)	NOT NULL,
    FOREIGN KEY (objetivo)
	REFERENCES evoluciones (id_evolucion)
);

CREATE TABLE IF NOT EXISTS evoluciones_audit (
    id_changed_log INT NOT NULL,
    old_row VARCHAR(3000) NOT NULL,		-- String con los datos viejos
    new_row VARCHAR(3000) NOT NULL, 		-- String con los datos nuevos
    FOREIGN KEY (id_changed_log)
	REFERENCES log_evoluciones (id_log_evoluciones)
);

CREATE TABLE IF NOT EXISTS stock (
    id_producto INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cantidad INT UNSIGNED NOT NULL, 			-- Cantidad actual
    cantidad_minima INT UNSIGNED NOT NULL DEFAULT 1, 	-- Mínima cantidad para ser considerado de bajo stock
    cantidad_recomendada INT UNSIGNED, 			-- Cantidad recomendada para realizar pedidos
    presentacion VARCHAR(50) NOT NULL,
    variedad VARCHAR(50),
    ubicacion VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255),
    email VARCHAR(50),
    url VARCHAR(100),
    cuit VARCHAR(11) UNIQUE,
    activo TINYINT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS consumos_stock (
    id_consumo INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT (CURDATE()),
    hora TIME NOT NULL DEFAULT (CURTIME()),
    id_producto INT NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    id_empleado_retira INT NOT NULL,		-- Quien lo retira del stock
    id_empleado_utiliza INT NOT NULL, 		-- Quien lo utiliza. Se destinan a consultorios, asique este deberían ser odontólogos
    FOREIGN KEY (id_producto)
	REFERENCES stock (id_producto),
    FOREIGN KEY (id_empleado_retira)
	REFERENCES empleados (id_empleado),
    FOREIGN KEY (id_empleado_utiliza)
	REFERENCES empleados (id_empleado)
);

CREATE TABLE IF NOT EXISTS estado_pedido (
    id_estado_pedido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS pedidos_stock (
    id_pedido INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    fecha_ingreso DATE NOT NULL DEFAULT (CURDATE()),
    precio_total DECIMAL(10,2),
    id_estado_pedido INT,
    id_empleado_recibe INT,				-- Quien recibe el pedido
    id_empleado_controla INT,				-- Quien controla sus contenidos
    FOREIGN KEY (id_proveedor)
	REFERENCES proveedores (id_proveedor),
    FOREIGN KEY (id_estado_pedido)
	REFERENCES estado_pedido (id_estado_pedido),
    FOREIGN KEY (id_empleado_recibe)
	REFERENCES empleados (id_empleado),
    FOREIGN KEY (id_empleado_controla)
	REFERENCES empleados (id_empleado)
);

CREATE TABLE IF NOT EXISTS ingresos_stock (
    id_ingreso INT NOT NULL UNIQUE AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_ingresada INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_pedido)
	REFERENCES pedidos_stock (id_pedido),
    FOREIGN KEY (id_producto)
	REFERENCES stock (id_producto)
);

-- STORED PROCEDURES --
DELIMITER $$

-- El siguiente procedimiento permite obtener los porcentajes que aplican a un determinado odontólogo
-- Toma como INPUT el id del odontólogo de interés y posee dos parámetros de OUTPUT, el porcentaje del tratamiento que se lleva el odontólogo
-- y el porcentaje del valor del trabajo de laboratorio que le corresponde deducir de la facturación.
-- Es llamado por la función 'honorario_mensual'

CREATE PROCEDURE obtener_porcentajes (IN id_odontologo INT, OUT porcentaje_tratamiento INT, OUT porcentaje_laboratorio INT)
BEGIN
	SELECT te.porcentaje_tratamiento, te.porcentaje_laboratorio INTO porcentaje_tratamiento, porcentaje_laboratorio
	FROM empleados e
	JOIN tipo_de_empleado te ON e.id_tipo_empleado = te.id_tipo_empleado
	WHERE e.id_empleado = id_odontologo;
END$$

-- El siguiente procedimiento permite obtener la facturación mensual de un odontólogo en un mes
-- Toma como INPUT el id del odontólogo y dos INT que corresponden al 'mes' y 'anio' de interes.
-- Genera un OUTPUT con la facturación del mes del odontólogo
-- Es llamado por la función 'honorario_mensual'

CREATE PROCEDURE obtener_facturacion_mensual (IN id_odontologo INT, IN mes INT, IN anio INT, OUT facturacion_mensual DECIMAL(10,2))
BEGIN
	-- Utilizo una vista generada más abajo
	SELECT SUM(facturacion) INTO facturacion_mensual
    	FROM facturacion_odontologo
	WHERE id_empleado = id_odontologo
	AND MONTH(fecha) = mes
    	AND YEAR(fecha) = anio;
END$$

-- El siguiente procedimiento permite obtener el costo de los trabajos de laboratorio de un odontólogo en un mes
-- Toma como INPUT el id del odontólogo y dos INT que corresponden al 'mes' y 'anio' de interes.
-- Genera un OUTPUT con el costo de laboratorio del mes del odontólogo
-- Es llamado por la función 'honorario_mensual'

CREATE PROCEDURE obtener_costo_laboratorio (IN id_odontologo INT, IN mes INT, IN anio INT, OUT laboratorios_mensual DECIMAL(10,2))
BEGIN
	DECLARE check_null INT;

	-- Esta primera query me permite chequear si alguno de los precios que voy a sumar es NULL
	SELECT SUM(ISNULL(tl.precio)) INTO check_null
	FROM evoluciones ev 
	JOIN turnos tu ON ev.id_turno = tu.id_turno
	JOIN trabajos_laboratorio tl ON ev.id_trabajo_laboratorio = tl.id_trabajo_laboratorio
	WHERE ev.id_empleado = id_odontologo
	AND MONTH(tu.fecha) = mes
	AND YEAR(tu.fecha) = anio;

	-- Si algun precio es NULL, tira un error para que lo ingresen. Así evita olvidos de ingresar valores de trabajos de laboratorio
	IF check_null <> 0 THEN
		SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Al menos uno de los precios de los trabajos del mes no tiene un valor asignado';
	END IF;

	SELECT SUM(tl.precio) INTO laboratorios_mensual
	FROM evoluciones ev 
	JOIN turnos tu ON ev.id_turno = tu.id_turno
	JOIN trabajos_laboratorio tl ON ev.id_trabajo_laboratorio = tl.id_trabajo_laboratorio
	WHERE ev.id_empleado = id_odontologo
	AND MONTH(tu.fecha) = mes
	AND YEAR(tu.fecha) = anio;
END$$

-- El siguiente procedimiento permite obtener la condicion de un empleado frente a los montos fijos de un tratamiento
-- Toma como INPUT el id del profesional de interés y como OUTPUT un booleano indicando si el profesional cobra o no los montos fijos
-- Es llamado por la función 'adicional_monto_fijo

CREATE PROCEDURE obtener_estado_monto_fijo (IN id_asistente INT, OUT cobra_monto_fijo TINYINT)
BEGIN
	SELECT te.lleva_monto_fijo INTO cobra_monto_fijo
	FROM empleados em
	JOIN tipo_de_empleado te ON em.id_tipo_empleado = te.id_tipo_empleado
	WHERE em.id_empleado = id_asistente;
END$$

-- El siguiente procedimiento calcula el adicional mensual al sueldo que cobra un empleado.
-- Lo calcula a partir de los pagos realizados en un mes, no las evoluciones. Como se puede hacer más de un pago por cada evolución, 
-- se toma el cuidado de agrupar por evolución, por lo que se debe usar esta sintaxis y no sumar directamente en la consulta interna
-- Toma como INPUT el id del profesional y dos INT que corresponden al 'mes' y al 'anio'.
-- Genera un OUTPUT con el adicional del mes del profesional
-- Es llamado por la función 'adicional_montos_fijos"

CREATE PROCEDURE obtener_adicional (IN id_asistente INT, IN mes INT, IN anio INT, OUT adicional DECIMAL (10,2))
BEGIN
	SELECT SUM(montos.monto_fijo) INTO adicional
	FROM (
		SELECT tr.monto_fijo
		FROM pagos p
		JOIN evoluciones ev ON p.id_evolucion = ev.id_evolucion
		JOIN tratamientos tr ON ev.id_tratamiento = tr.id_tratamiento
		WHERE ev.id_empleado = id_asistente
		AND MONTH(p.fecha) = mes
		AND YEAR(p.fecha) = anio
		GROUP BY ev.id_evolucion 	-- Por si hay más de un pago por evolución, que no cuente doble
	) AS montos;
END$$

-- Este procedimiento permite obtener una lista de empleados con sus honorarios por el mes. Para empelados que no atienden, corresponde a los adicionales sobre el sueldo.
-- Los parámetros 'mes' y 'anio' es la representación numérica de la fecha para la que se desea realizar el cálculo. 
-- El parámetro 'atiende' es 0 o 1 si el empleado es odontólogo o no.
-- El último parámetro 'definitivo' es un booleano que indica si la facturacion que se calcula es definitiva. Si lo es, se agrega a la tabla honorarios_definitivos 
-- y no permite llamar más al procedimiento para la combinacion año-mes

-- La tabla honorarios_definitivos tiene ingresados ya los honorarios para los meses febrero, abril y junio.
-- Dejé el mes de septiembre sin generarr honorarios definitivos para testear esto en la correccion. Los meses de noviembre y diciembre tienen solo turnos futuros
-- Para testear este procedimiento, llamar CALL honorarios(9, 2022, 1, 1); CALL honorarios(9, 2022, 0, 1);

CREATE PROCEDURE honorarios (IN mes INT, IN anio INT, IN atiende TINYINT, IN definitivo TINYINT)
BEGIN
	-- Dependiendo de si quiero honorarios de odontólogos o de otros empleados, debo cambiar la función que llama más adelante
	IF atiende = 1 THEN
		SET @function_call = 'honorario_mensual';
        	SET @nombre = 'honorarios';
	ELSEIF atiende = 0 THEN
		SET @function_call = 'adicional_montos_fijos';
        	SET @nombre = 'montos_fijos';
	ELSE
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Valor inválido para "atiende". Debe ser 1 o 0 para odontólogos u otos, respectivamente.';
    	END IF;

	-- Esta query es la que el usuario ve
	SET @clause = CONCAT('SELECT e.nombre, e.apellido, ', @function_call, '(e.id_empleado, ', mes, ', ', anio, ') as "', @nombre, '" ');
	SET @clause = CONCAT(@clause ,'FROM empleados e JOIN tipo_de_empleado te ON e.id_tipo_empleado=te.id_tipo_empleado WHERE e.activo = 1 AND te.atiende = ', atiende, ';');
	PREPARE runSQL FROM @clause;
	EXECUTE runSQL;
	DEALLOCATE PREPARE runSQL;

	-- Si determinó que los honorarios son definitivos, inserta en la table honorarios_definitivos 
	-- Utiliza una query similar a la anterior como subconsulta
	IF definitivo = 1 THEN
		SET @insert_clause = CONCAT('INSERT INTO honorarios_definitivos (id_empleado, mes, anio, honorario) ');
		SET @insert_clause = CONCAT(@insert_clause, 'SELECT e.id_empleado, ', mes, ', ', anio, ', ', @function_call, '(e.id_empleado, ', mes, ', ', anio, ') as "', @nombre, '" ');
		SET @insert_clause = CONCAT(@insert_clause ,'FROM empleados e JOIN tipo_de_empleado te ON e.id_tipo_empleado=te.id_tipo_empleado WHERE e.activo=1 AND te.atiende=', atiende, ';');
		PREPARE runSQLInsert FROM @insert_clause;
		EXECUTE runSQLInsert;
		DEALLOCATE PREPARE runSQLInsert;
	END IF;
END$$

-- Obtener una lista de emails. Lista de pacientes ordenada por un parametro de entrada
-- order_column es el nombre de la columna por la qeu se quiere ordenar. Puede ser nombre, apellido, documento, genero (0 femenino, 1 masculino), fecha_de_nacimiento y email
-- El parámetro direction define si es ascendente o descendente. Poner ASC o DESC para elegir uno o el otro

CREATE PROCEDURE lista_emails (IN order_column VARCHAR(50), IN direction VARCHAR(4))
BEGIN
	IF order_column <> '' THEN
		SET @order_clause = CONCAT('ORDER BY ', order_column, ' ', direction);
	ELSE
		SET @order_clause = '';
	END IF;

	SET @clause = CONCAT('SELECT p.nombre, p.apellido, p.documento, g.genero, p.fecha_de_nacimiento, p.email');
	SET @clause = CONCAT(@clause, 'FROM pacientes p JOIN generos g ON p.id_genero = g.id_genero', @order_clause);
	PREPARE runSQL FROM @clause;
	EXECUTE runSQL;
	DEALLOCATE PREPARE runSQL;
END$$

-- El siguiente Stored Procedure permite aumentar todos los precios de los tratamientos un porcentaje determinado
-- porcentaje_aumento es un INT. Si quiero aumentar un 10% los precios, ingreso 10
-- aplicar_a_monto_fijo puede valer 0 o 1, y representa si se debe aplicar el aumento a la columna monto_fijo

CREATE PROCEDURE aumentar_precios (IN porcentaje_aumento INT, aplicar_a_monto_fijo TINYINT)
BEGIN
	DECLARE i, m, n, row_id INT;
	DECLARE old_price, old_fixed DECIMAL(10,2);

	IF aplicar_a_monto_fijo NOT IN (0, 1) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Variable aplicar_a_monto_fijo puede ser sólo 0 o 1';
	END IF;

	SET i = 1;
	SELECT COUNT(*) INTO n FROM tratamientos;

	-- Hago un loop sobre todos los tratamientos aumentando el precio
	-- No es necesario que los id_tratamientos sean consecutivos
	WHILE i <= n DO
		SET m = i - 1;
		
		SELECT id_tratamiento, precio, monto_fijo INTO row_id, old_price, old_fixed 
		FROM tratamientos LIMIT m, 1;

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

CREATE TRIGGER generar_log_pago_insert
AFTER INSERT ON pagos
FOR EACH ROW
INSERT INTO log_pagos (evento, objetivo, usuario) VALUES ('INSERT', NEW.id_pago, USER());

-- Frente a la modificación de una fila en la tabla pagos, este trigger agrega un log en la tabla log_pagos
-- También agrega una fila en pagos_audit que registra los cambios que se producen

DELIMITER $$
CREATE TRIGGER generar_log_pago_update
AFTER UPDATE ON pagos
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

CREATE TRIGGER generar_log_evolucion_insert
AFTER INSERT ON evoluciones
FOR EACH ROW
INSERT INTO log_evoluciones (evento, objetivo, usuario) VALUES ('INSERT', NEW.id_evolucion, USER());

-- Frente a la modificación de una fila en la tabla evoluciones, este trigger agrega un log en la tabla log_evoluciones
-- También agrega una fila en evoluciones_audit que registra los cambios que se producen

DELIMITER $$

CREATE TRIGGER generar_log_evolucion_update
AFTER UPDATE ON evoluciones
FOR EACH ROW
BEGIN
	INSERT INTO log_evoluciones (evento, objetivo, usuario) VALUES ('UPDATE', NEW.id_evolucion, USER());

	INSERT INTO evoluciones_audit (id_changed_log, old_row, new_row)
	VALUES (
		(SELECT MAX(id_log_evoluciones) FROM log_evoluciones),
		CONCAT(OLD.id_evolucion, ' ', OLD.descripcion, ' ', OLD.id_tratamiento, ' ', OLD.id_turno, ' ', OLD.id_empleado, ' ', IF(OLD.id_trabajo_laboratorio IS NULL,'', OLD.id_trabajo_laboratorio)),
		CONCAT(NEW.id_evolucion, ' ', NEW.descripcion, ' ', NEW.id_tratamiento, ' ', NEW.id_turno, ' ', NEW.id_empleado, ' ', IF(NEW.id_trabajo_laboratorio IS NULL,'', NEW.id_trabajo_laboratorio))
	);
END$$

-- Trigger que al agregar una evolucion con un tratamiento que tenga el parametro trabajo_laboratorio = 1, llama al stored procedure create_new_lab_work 
-- Este crea el nuevo trabajo de laboratorio y actualiza la evolucion con el id que acaba de crear

CREATE TRIGGER new_lab_work
BEFORE INSERT ON evoluciones
FOR EACH ROW
BEGIN
	DECLARE laboratorio TINYINT;
    
	-- Busco si al tratamiento de la evolución le corresponde un trabajo de laboratorio
	SELECT trabajo_laboratorio INTO laboratorio 
	FROM tratamientos 
	WHERE id_tratamiento = NEW.id_tratamiento;

	IF laboratorio AND NEW.id_trabajo_laboratorio IS NULL THEN
		-- El segundo chequeo es por si se agrega una evolución con un trabajo de laboratorio ya asignado
		INSERT INTO trabajos_laboratorio (id_trabajo_laboratorio) VALUES (NULL);
		SET NEW.id_trabajo_laboratorio = (SELECT MAX(id_trabajo_laboratorio) FROM trabajos_laboratorio);
	END IF;
END$$

-- Triggers para validar los datos de la tabla pacientes

CREATE TRIGGER validar_datos_paciente_insert
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);

	-- Chequeo que me den al menos un teléfono de contacto
	IF NEW.celular IS NULL AND NEW.telefono IS NULL THEN
		SET mensaje = CONCAT('Error en el paciente ', NEW.nombre, ' ', NEW.apellido, '. Debe proveer al menos un telefono de contacto');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;

	-- Valido la estructura del email con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el paciente ', NEW.nombre, ' ', NEW.apellido, '. Email inválido');
		SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = mensaje;
	END IF;

	-- Limpio los strings numéricos para remover caracteres innecesarios
	SET NEW.documento = limpiar_string(NEW.documento);
	SET NEW.telefono = limpiar_string(NEW.telefono);
	SET NEW.celular = limpiar_string(NEW.celular);
END$$

CREATE TRIGGER validar_datos_paciente_update
BEFORE UPDATE ON pacientes
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR (800);
    
	-- Chequeo que me den al menos un teléfono de contacto
	IF NEW.celular IS NULL AND NEW.telefono IS NULL THEN
		SET mensaje = CONCAT('Error en el paciente ', NEW.nombre, ' ', NEW.apellido, '. Debe proveer al menos un telefono de contacto');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
    	END IF;
    
	-- Valido la estructura del email con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el paciente ', NEW.nombre, ' ', NEW.apellido, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	-- Limpio los strings numéricos para remover caracteres innecesarios
	SET NEW.documento = limpiar_string(NEW.documento);
    	SET NEW.telefono = limpiar_string(NEW.telefono);
    	SET NEW.celular = limpiar_string(NEW.celular);
END$$

-- Triggers para validar los datos de la tabla empleados

CREATE TRIGGER validar_datos_empleado_insert
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido la estructura del email con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el empleado ', NEW.nombre, ' ', NEW.apellido, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	-- Limpio los strings numéricos para remover caracteres innecesarios
	SET NEW.documento = limpiar_string(NEW.documento);
    	SET NEW.celular = limpiar_string(NEW.celular);
END$$

CREATE TRIGGER validar_datos_empleado_update
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido la estructura del email con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el empleado ', NEW.nombre, ' ', NEW.apellido, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Formato de email inválido';
	END IF;

	-- Limpio los strings numéricos para remover caracteres innecesarios
	SET NEW.documento = limpiar_string(NEW.documento);
    	SET NEW.celular = limpiar_string(NEW.celular);
END$$

-- Trigger para insertar el usuario en la tabla honorarios_definitivos ya que no se puede insertar como DEFAULT en esa columna

CREATE TRIGGER insertar_usuario_honorarios
BEFORE INSERT ON honorarios_definitivos
FOR EACH ROW
SET NEW.usuario = USER();

-- Triggers de validación de datos para la tabla tipo_de_empleado

CREATE TRIGGER validar_datos_tipo_empleado_insert
BEFORE INSERT ON tipo_de_empleado
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido que los porcentajes se encuentren entre 0 y 100
	IF NEW.porcentaje_tratamiento NOT BETWEEN 0 AND 100 OR NEW.porcentaje_laboratorio NOT BETWEEN 0 AND 100 THEN
		SET mensaje = CONCAT('Error en el tipo de empleado ', NEW.titulo, '. Los porcentajes van entre 0 y 100.');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

CREATE TRIGGER validar_datos_tipo_empleado_update
BEFORE UPDATE ON tipo_de_empleado
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido que los porcentajes se encuentren entre 0 y 100
	IF NEW.porcentaje_tratamiento NOT BETWEEN 0 AND 100 OR NEW.porcentaje_laboratorio NOT BETWEEN 0 AND 100 THEN
		SET mensaje = CONCAT('Error en el tipo de empleado ', NEW.titulo, '. Los porcentajes van entre 0 y 100.');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

-- Triggers de validación de datos para la tabla turnos

CREATE TRIGGER validar_datos_turnos_insert
BEFORE INSERT ON turnos
FOR EACH ROW
BEGIN 
	DECLARE empleado_atiende, empleado_activo, tratamiento_solo_odontologos TINYINT;
    	DECLARE mensaje VARCHAR(800);
    
    	-- Valido que me dé sólo el o un id_empleado o un id_tratamiento, pero no ambos
	IF NOT (NEW.id_empleado IS NULL XOR NEW.id_tratamiento IS NULL) THEN
		SET mensaje = CONCAT('Error en el turno del ', NEW.fecha,  ' ', NEW.hora, ' con id_paciente = ', NEW.id_paciente, ' .El turno debe tener asignado debe contener o un empleado o un tratamiento radiológico.');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Busco el estado del empleado mencionado. Cuando es NULL, no encuentra nada
	SELECT te.atiende, e.activo INTO empleado_atiende, empleado_activo
	FROM empleados e
	JOIN tipo_de_empleado te ON e.id_tipo_empleado = te.id_tipo_empleado
	WHERE e.id_empleado = NEW.id_empleado;

	-- Sólo permito que se inserten odontólogos para el turno
	IF NOT empleado_atiende THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. En la columna id_empleado sólo puede figurar un odontólogo');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Sólo permito odontólogos acutalmente activos
   	IF NOT empleado_activo THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. El empleado referido en el turno se encuentra inactivo');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Busco si el tratamiento que figura lo pueden realizar sólo odontólogos. Si es NULL, no encuentra nada
	SELECT tr.solo_odontologos INTO tratamiento_solo_odontologos
	FROM tratamientos tr
	WHERE tr.id_tratamiento = NEW.id_tratamiento;
    
    	-- Sólo permito incluir tratamientos que puede realizar todos los empleados, como los radiológicos
	IF tratamiento_solo_odontologos THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. El tratamiento referido puede ser realizado sólo por odontólogos');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

CREATE TRIGGER validar_datos_turnos_update
BEFORE UPDATE ON turnos
FOR EACH ROW
BEGIN 
	DECLARE empleado_atiende, empleado_activo, tratamiento_solo_odontologos TINYINT;
    	DECLARE mensaje VARCHAR(800);
    
    	-- Valido que me dé sólo el o un id_empleado o un id_tratamiento, pero no ambos
	IF NOT (NEW.id_empleado IS NULL XOR NEW.id_tratamiento IS NULL) THEN
		SET mensaje = CONCAT('Error en el turno del ', NEW.fecha,  ' ', NEW.hora, ' con id_paciente = ', NEW.id_paciente, ' .El turno debe tener asignado debe contener o un empleado o un tratamiento radiológico.');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Busco el estado del empleado mencionado. Cuando es NULL, no encuentra nada
	SELECT te.atiende, e.activo INTO empleado_atiende, empleado_activo
	FROM empleados e
	JOIN tipo_de_empleado te ON e.id_tipo_empleado = te.id_tipo_empleado
	WHERE e.id_empleado = NEW.id_empleado;

	-- Sólo permito que se inserten odontólogos para el turno
	IF NOT empleado_atiende THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. En la columna id_empleado sólo puede figurar un odontólogo');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
    
    	-- Sólo permito odontólogos acutalmente activos
    	IF NOT empleado_activo THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. El empleado referido en el turno se encuentra inactivo');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Busco si el tratamiento que figura lo pueden realizar sólo odontólogos. Si es NULL, no encuentra nada
	SELECT tr.solo_odontologos INTO tratamiento_solo_odontologos
	FROM tratamientos tr
	WHERE tr.id_tratamiento = NEW.id_tratamiento;

   	-- Sólo permito incluir tratamientos que puede realizar todos los empleados, como los radiológicos
	IF tratamiento_solo_odontologos THEN
		SET mensaje = CONCAT('Error en el turno con datos ', NEW.fecha, ' ', NEW.hora, ' id_paciente = ', NEW.id_paciente, '. El tratamiento referido puede ser realizado sólo por odontólogos');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

-- Triggers de validación de datos de la tabla laboratorios

CREATE TRIGGER validar_datos_laboratorios_insert
BEFORE INSERT ON laboratorios
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido que el email se válido con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el laboratorio ', NEW.nombre, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Limpio los strings de entrada
	SET NEW.telefono = limpiar_string(NEW.telefono);
    	SET NEW.cuit = limpiar_string(NEW.cuit);
END$$

CREATE TRIGGER validar_datos_laboratorios_update
BEFORE UPDATE ON laboratorios
FOR EACH ROW
BEGIN
	DECLARE mensaje VARCHAR(800);
    
    	-- Valido que el email se válido con una función definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el laboratorio ', NEW.nombre, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;

	-- Limpio los strings de entrada
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

-- Triggers de la tabla stock. Controlan que no se inserten valores de cantidades sin sentido

CREATE TRIGGER cantidades_stock_insert
BEFORE INSERT ON stock
FOR EACH ROW
BEGIN
	DECLARE mensaje VARCHAR(800);
    
   	-- La positividad de las cantidades esta dada por el constrain de UNSIGNED en la definicion de la tabla
    
    	-- Chequeo que la cantidad recomendada para pedir sea mayor que la cantidad mínima, sino no tiene sentido
    	IF NEW.cantidad_minima > NEW.cantidad_recomendada THEN
		SET mensaje = CONCAT('La cantidad mínima ingresada para el producto ', NEW.nombre, ' debe ser menor que la cantidad recomendada');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
   	END IF;
END$$

CREATE TRIGGER cantidades_stock_update
BEFORE UPDATE ON stock
FOR EACH ROW
BEGIN
	DECLARE mensaje VARCHAR(800);
    
	-- La positividad de las cantidades esta dada por el constrain de UNSIGNED en la definicion de la tabla

	-- Chequeo que la cantidad recomendada para pedir sea mayor que la cantidad mínima, sino no tiene sentido
	IF NEW.cantidad_minima > NEW.cantidad_recomendada THEN
		SET mensaje = CONCAT('La cantidad mínima ingresada para el producto ', NEW.nombre, ' debe ser menor que la cantidad recomendada');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
    	END IF;
END$$

-- Triggers para chequear que se inserten los datos adecuados a medida que avanza un pedido

CREATE TRIGGER avance_de_pedido_insert
BEFORE INSERT ON pedidos_stock
FOR EACH ROW
BEGIN
	DECLARE estado VARCHAR(20);
	DECLARE mensaje VARCHAR(800);

	-- Busco el nombre del estado en el que se encuentra el pedido
	SELECT ep.estado INTO estado
	FROM estado_pedido ep
	WHERE ep.id_estado_pedido = NEW.id_estado_pedido;

	-- Si el estado del pedido es 'Recibido', me asegro que ingresen el empleado que lo recibió
	IF estado = 'Recibido' AND NEW.id_empleado_recibe IS NULL THEN
		SET mensaje = CONCAT('Error en el id_pedido = ', NEW.id_pedido, '. Al pasar un pedido a "Recibido", se debe insertar el empleado que lo recibió.');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Si el estado del pedido es 'Chequeado', me asegro que ingresen el empleado que lo recibió y el que lo revisó. Chequeo ambos por si se saltea el paso de 'Recibido'
	IF estado = 'Chequeado' AND (NEW.id_empleado_recibe IS NULL OR NEW.id_empleado_controla IS NULL) THEN
		SET mensaje = CONCAT('Error en el id_pedido = ', NEW.id_pedido, '. Al pasar un pedido a "Chequeado", se debe insertar el empleado que lo recibió y el que lo controló.');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

CREATE TRIGGER avance_de_pedido_update
BEFORE UPDATE ON pedidos_stock
FOR EACH ROW
BEGIN
	DECLARE estado VARCHAR(20);
	DECLARE mensaje VARCHAR(800);

	-- Busco el nombre del estado en el que se encuentra el pedido
	SELECT ep.estado INTO estado
	FROM estado_pedido ep
	WHERE ep.id_estado_pedido = NEW.id_estado_pedido;

	-- Si el estado del pedido es 'Recibido', me asegro que ingresen el empleado que lo recibió
	IF estado = 'Recibido' AND NEW.id_empleado_recibe IS NULL THEN
		SET mensaje = CONCAT('Error en el id_pedido = ', NEW.id_pedido, '. Al pasar un pedido a "Recibido", se debe insertar el empleado que lo recibió.');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Si el estado del pedido es 'Chequeado', me asegro que ingresen el empleado que lo recibió y el que lo revisó. Chequeo ambos por si se saltea el paso de 'Recibido'
	IF estado = 'Chequeado' AND (NEW.id_empleado_recibe IS NULL OR NEW.id_empleado_controla IS NULL) THEN
		SET mensaje = CONCAT('Error en el id_pedido = ', NEW.id_pedido, '. Al pasar un pedido a "Chequeado", se debe insertar el empleado que lo recibió y el que lo controló.');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
END$$

-- Triggers para validación de datos de la tabla proveedores

CREATE TRIGGER validar_datos_proveedores_insert
BEFORE INSERT ON proveedores
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido el email con una funcion definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el proveedor ', NEW.nombre, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
    	-- Limpio los strings de entrada
	SET NEW.telefono = limpiar_string(NEW.telefono);
    	SET NEW.cuit = limpiar_string(NEW.cuit);
END$$

CREATE TRIGGER validar_datos_proveedores_update
BEFORE UPDATE ON proveedores
FOR EACH ROW
BEGIN 
	DECLARE mensaje VARCHAR(800);
    
	-- Valido el email con una funcion definida más abajo
	IF NEW.email IS NOT NULL AND NOT validar_email(NEW.email) THEN
		SET mensaje = CONCAT('Error en el proveedor ', NEW.nombre, '. Email inválido');
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = mensaje;
	END IF;
    
    	-- Limpio los strings de entrada
	SET NEW.telefono = limpiar_string(NEW.telefono);
    	SET NEW.cuit = limpiar_string(NEW.cuit);
END$$

-- Triggers para actualizar automaticamente el stock frente a un INSERT de consumo_stock o ingreso_stock

CREATE TRIGGER consumo_stock_insert
BEFORE INSERT ON consumos_stock
FOR EACH ROW
BEGIN
	DECLARE cantidad_actual INT;
	DECLARE mensaje VARCHAR(800);

	-- La positividad de la cantidad esta garantizada por el constrain de UNSIGNED

	-- Busco la cantidad actual del producto consumido
	SELECT st.cantidad INTO cantidad_actual
	FROM stock st
	WHERE st.id_producto = NEW.id_producto;
    
    	-- Chequeo que haya suficiente en stock para el consumo que esta ingresando
	IF cantidad_actual < NEW.cantidad THEN
		SET mensaje = CONCAT('Error en id_producto = ', NEW.id_producto, '. La cantidad ingresada excede la cantidad disponible del producto');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Cambio el stock del producto, restándole la cantidad consumida
	UPDATE stock st SET st.cantidad = (cantidad_actual - NEW.cantidad) WHERE st.id_producto = NEW.id_producto;
END$$

CREATE TRIGGER consumo_stock_update
BEFORE UPDATE ON consumos_stock
FOR EACH ROW
BEGIN
	DECLARE cantidad_actual INT;
	DECLARE mensaje VARCHAR(800);

	-- La positividad de la cantidad esta garantizada por el constrain de UNSIGNED

	-- Busco la cantidad actual del producto consumido
	SELECT st.cantidad INTO cantidad_actual
	FROM stock st
	WHERE st.id_producto = NEW.id_producto;

	-- Chequeo que haya suficiente stock para realizar la modificación sin irme por debajo de 0
	IF cantidad_actual < (NEW.cantidad - OLD.cantidad) THEN
		SET mensaje = CONCAT('Error en id_producto = ', NEW.id_producto, '. La cantidad ingresada excede la cantidad disponible del producto');
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = mensaje;
	END IF;
    
	-- Modifico el stock, deshaciendo la resta anterior y rehaciendola con el nuevo valor
	UPDATE stock st SET st.cantidad = (cantidad_actual + OLD.cantidad - NEW.cantidad) WHERE st.id_producto = NEW.id_producto;
END$$

CREATE TRIGGER ingreso_stock_insert
AFTER INSERT ON ingresos_stock
FOR EACH ROW
BEGIN  
	DECLARE cantidad_actual INT;

	-- La positividad de la cantidad esta garantizada por el constrain de UNSIGNED

	-- Busco la cantidad actual del producto consumido
	SELECT st.cantidad INTO cantidad_actual
	FROM stock st 
	WHERE st.id_producto=NEW.id_producto;

	-- Modifico el stock sumando la cantidad ingresada
	UPDATE stock st
	SET st.cantidad = cantidad_actual + NEW.cantidad_ingresada
	WHERE st.id_producto = NEW.id_producto;
END$$

CREATE TRIGGER ingreso_stock_update
AFTER UPDATE ON ingresos_stock
FOR EACH ROW
BEGIN  
	DECLARE cantidad_actual INT;

	-- La positividad de la cantidad esta garantizada por el constrain de UNSIGNED

	-- Busco la cantidad actual del producto consumido
	SELECT st.cantidad INTO cantidad_actual
	FROM stock st 
	WHERE st.id_producto=NEW.id_producto;

	-- Modifico el stock, dehaciendo la suma anterior y sumando la nueva
	UPDATE stock st
	SET st.cantidad = cantidad_actual - OLD.cantidad_ingresada + NEW.cantidad_ingresada
	WHERE st.id_producto = NEW.id_producto;
END$$

DELIMITER ;

-- FUNCIONES --

-- Esta función permite calcular los honorarios mensuales de un odontólogo en función de los tratamientos que realizó
-- El parámetro id es la columna id_empleado de la tabla empleados, correspondiente al odontólogo particular
-- El parámetro mes es el valor numérico del mes del año para el cual se desea calcular los honorarios
-- Un ejemplo seria llamar SELECT honorario_mensual(1, 2);

DELIMITER $$
CREATE FUNCTION honorario_mensual(id_odontologo INT, mes INT, anio INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
	DECLARE porcentaje_tratamiento, porcentaje_laboratorio INT;
	DECLARE facturacion_mensual, laboratorios_mensual, honorarios DECIMAL(10,2);

	-- Obtengo los porcentajes correspondientes al odontólogo
	CALL obtener_porcentajes(id_odontologo, porcentaje_tratamiento, porcentaje_laboratorio);

	-- Si el empleado no recibe porcentaje de tratamientos, ya devuelvo 0.00
	-- Esto evita ingresar empleado que no atienden sin chequear más
	IF porcentaje_tratamiento = 0 THEN
		RETURN 0.00;
	END IF;

	-- Obtengo la facturación del mes de el odontólogo
	CALL obtener_facturacion_mensual(id_odontologo, mes, anio, facturacion_mensual);

	-- Obtengo los costos de laboratorio de los tratamientos del odontólogo
	CALL obtener_costo_laboratorio(id_odontologo, mes, anio, laboratorios_mensual);

	-- Realizo la cuenta de honorarios. Le sumo el porcentaje que le corresponde de los pagos realizados en el mes
	-- Le resto el porcentaje que le corresponde del costo de laboratorio
	SET honorarios = (facturacion_mensual * porcentaje_tratamiento - laboratorios_mensual * porcentaje_laboratorio) / 100;

	-- Por si todos los valores son NULL, quiero devolver siempre números
	IF honorarios IS NULL THEN
		RETURN 0.00;
	ELSE
		RETURN honorarios;
	END IF;
END$$

-- Esta función permite calcular los el adicional que cobran algunos empleados por ciertos tratamientos en un determinado mes
-- El parámetro id es la columna id_empleado de la tabla empleados, correspondiente al odontólogo particular
-- El parámetro mes es el valor numérico del mes del año para el cual se desea calcular los honorarios
-- Un ejemplo seria llamar SELECT adicional_montos_fijos(13, 2);

CREATE FUNCTION adicional_montos_fijos(id_asistente INT, mes INT, anio INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
	DECLARE cobra_monto_fijo TINYINT;
	DECLARE adicional DECIMAL(10,2);

	-- Obtengo el estado del empleado, si cobra monto fijo
	CALL obtener_estado_monto_fijo(id_asistente, cobra_monto_fijo);

	-- Si ingresé un odontólogo ya devuelvo 0.00, sin necesidad de chequear el estado
	IF cobra_monto_fijo = 0 THEN
		RETURN 0.00;
	END IF;

	-- Calculo los adicionales que le corresponden el período indicado
	CALL obtener_adicional(id_asistente, mes, anio, adicional);

	-- Por si todos los adicionales son NULL, quiero retornar siempre números
	IF adicional IS NULL THEN
		RETURN 0.00;
	ELSE    
		RETURN adicional;
	END IF;
END$$

-- Esta función toma como INPUT una sequencia de caracteres y lo limpia de caracteres indeseados. 
-- Se utiliza para limpiar los datos ingresados de teléfonos, documentos y números de CUIT
-- Remueve todos los caracteres que no son numéricos EXCEPTO si comienza con un +, para teléfonos internacionales

CREATE FUNCTION limpiar_string(input VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE cleaned_string VARCHAR(50);
	DECLARE c VARCHAR(1);
	DECLARE i, n INT;

	SET cleaned_string = '';
	SET n = CHAR_LENGTH(input);
	SET i = 0;

	-- Permito que empiece con un + ya que puede ser un teléfono internacional
	-- Se usa para otras cosas que no son teléfonos, pero las chances que se dé algo así son bajas
	IF LOCATE('+', input) IN (1, 2) THEN
		SET cleaned_string = '+';
	END IF;

	-- Hago un loop sobre los caracteres, chequeando si son números. Si lo son, los agrego al string limpio
	WHILE i <= n DO
		SET c = RIGHT(LEFT(input, i),1);

		IF LOCATE(c, '0123456789') != 0 THEN
				SET cleaned_string = CONCAT(cleaned_string, c);
		END IF;

		SET i = i + 1;
	END WHILE;

	RETURN cleaned_string;
END$$

-- Función que frente a una secuencia de caracteres, devuelve un BOOLEANO indicando si la secuencia es una dirección de email válida.
-- Utiliza una expresión regular para el formato actual de emails válidos.

CREATE FUNCTION validar_email (input VARCHAR(50))
RETURNS TINYINT
NO SQL
BEGIN
	-- El REGEXP la saque de https://stackoverflow.com/questions/12759596/validate-email-addresses-in-mysql
    	-- No se bien como funciona, pero chequeandolo parece andar bien con los formatos válidos de email del presente
	IF input REGEXP '^[a-zA-Z0-9][a-zA-Z0-9.!#$%&\'*+-/=?^_`{|}~]*?[a-zA-Z0-9._-]?@[a-zA-Z0-9][a-zA-Z0-9._-]*?[a-zA-Z0-9]?\\.[a-zA-Z]{2,63}$' THEN
		RETURN 1;
	END IF;
	RETURN 0;
END$$

DELIMITER ;

-- POBLACIÓN DE TABLAS --

INSERT INTO tipo_de_empleado (titulo, atiende, porcentaje_tratamiento, porcentaje_laboratorio, lleva_monto_fijo) VALUES 
	('Socio', 1, 70, 50, 0), ('Odontólogo', 1, 40, 50, 0), ('Recepcionista', 0, 0, 0, 1), ('Asistente', 0, 0, 0, 1);
    
INSERT INTO modo_pago (modo) VALUES ('Efectivo'), ('Mercado Pago'), ('Transferencia'), ('Tarjeta de Débito'), ('Tarjeta de Crédito');

INSERT INTO laboratorios (nombre, telefono, direccion, email, cuit, activo) VALUES
	('Dental Lab', '47233265', 'Av. Rivadavia 2154, Balvanera', NULL, '30215469857', 1),
	('Super Lab','42569874', 'Av. Maipu 1656, Vicente Lopez, Pcia. de Buenos Aires', 'superlab@gmail.com', '30256547891', 0),
	('Fym Dental Lab', '43254785', 'Av. Rivadavia 1936, Balvanera', 'fymdental@gmail.com', '30487963525', 1),
	('Dientes Derechos', '41589632', 'Chiclana 952, Saavedra', 'dientesderechos@gmail.com' , '27356987841', 1),
	('Esteban Alderete', '1549786523', 'Carlos Pellegrini 3652, San Nicolás', 'ealderete@gmail.com', '20296589851', 1),
	('Timoteo Astro Mecanica Dental', '1532564578', 'Bernardo de Irigoyen 2563, Florida, Pcia. de Buenos Aires', 'tamecanicadental@gmail.com', '20312569402', 1);

INSERT INTO generos (genero) VALUES ('Femenino'), ('Masculino'), ('Otros');

INSERT INTO estado_turno (estado) VALUES ('No asistió'), ('Asistió'), ('Turno futuro');

INSERT INTO estado_trabajo_laboratorio (estado) VALUES ('Iniciado'), ('Asignado'), ('Despachado'), ('Recibido'), ('Entregado');

INSERT INTO pacientes (nombre, apellido, documento, id_genero, fecha_de_nacimiento, email, celular, telefono) VALUES 
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

INSERT INTO tratamientos (nombre, nomenclador, precio, monto_fijo, trabajo_laboratorio, solo_odontologos) VALUES 
	('Caries', 'CI.1012.01', 3500.00, 0.00, 0, 1),
	('Radiografía panorámica', 'CI.1034.01', 1650.25, 350.00, 0, 0),
	('Implante', 'CI.1102.01', 26750.00, 0.00, 0, 1),
	('Corona sobre implante', 'CI.1102.02', 47855.00, 0.00, 1, 1),
	('Tratamiento de conducto', 'CI.1005.01', 16500.00, 0.00, 0, 1),
	('Alineadores', 'CI.1501.01', 105000.00, 0.00, 1, 1),
	('Perno', 'CI.1005.02', 11500.00, 0.00, 0, 1),
	('Corona sobre perno', 'CI.1005.03', 37450.00, 0.00, 1, 1),
	('Placa miorrelajante', 'CI.1250.01', 6500.00, 500.00, 1, 1),
	('Limpieza', 'CI.1022.01', 8950.00, 0.00, 0, 1);
    
INSERT INTO empleados (nombre, apellido, documento, id_genero, fecha_de_nacimiento, email, celular, direccion, id_tipo_empleado, activo) VALUES 
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

INSERT INTO turnos (fecha, hora, id_estado_turno, id_paciente, id_empleado, id_tratamiento) VALUES 
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

INSERT INTO evoluciones (id_tratamiento, id_turno, id_empleado, descripcion) VALUES 
	(7, 1, 1, 'Se cementó un perno sobre la pieza 23'),
	(4, 2, 1, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 17'),
	(5, 2, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
	(3, 2, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
	(7, 4, 1, 'Se cementó un perno sobre la pieza 25'),
	(1, 4, 1, 'Se removió una caries en la pieza 26'),
	(6, 5, 1, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 5, 1, 'Se removió una caries en la pieza 27'),
	(5, 5, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
	(7, 6, 1, 'Se cementó un perno sobre la pieza 26'),
	(3, 7, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 28'),
	(7, 8, 1, 'Se cementó un perno sobre la pieza 26'),
	(7, 10, 1, 'Se cementó un perno sobre la pieza 21'),
	(9, 10, 1, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(9, 11, 1, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(3, 11, 1, 'Se colocó un implante de titanio luego de una cirugía en la pieza 10'),
	(1, 12, 1, 'Se removió una caries en la pieza 6'),
	(5, 12, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 31'),
	(6, 13, 1, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(2, 14, 1, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(5, 15, 1, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 7'),
	(4, 15, 1, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 30'),
	(4, 25, 2, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 16'),
	(4, 26, 2, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 32'),
	(9, 27, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(3, 30, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 19'),
	(7, 31, 2, 'Se cementó un perno sobre la pieza 21'),
	(8, 32, 2, 'Se colocó un implante de porcelana sobre el perno de la pieza 19'),
	(9, 33, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 33, 2, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 35, 2, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(3, 35, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
	(1, 35, 2, 'Se removió una caries en la pieza 24'),
	(9, 36, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(9, 38, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 39, 2, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(9, 39, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(5, 39, 2, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
	(3, 40, 2, 'Se colocó un implante de titanio luego de una cirugía en la pieza 1'),
	(9, 40, 2, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(10, 40, 2, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 49, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 17'),
	(2, 49, 3, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(8, 50, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 20'),
	(6, 51, 3, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 52, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(9, 53, 3, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(1, 53, 3, 'Se removió una caries en la pieza 8'),
	(10, 53, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(7, 56, 3, 'Se cementó un perno sobre la pieza 22'),
	(3, 57, 3, 'Se colocó un implante de titanio luego de una cirugía en la pieza 18'),
	(10, 57, 3, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 58, 3, 'Se colocó un implante de porcelana sobre el perno de la pieza 27'),
	(2, 58, 3, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 58, 3, 'Se cementó un perno sobre la pieza 8'),
	(7, 59, 3, 'Se cementó un perno sobre la pieza 12'),
	(4, 63, 3, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
	(9, 64, 3, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(6, 73, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(6, 75, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 76, 4, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 77, 4, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 19'),
	(8, 79, 4, 'Se colocó un implante de porcelana sobre el perno de la pieza 4'),
	(6, 80, 4, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(2, 81, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(4, 82, 4, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 3'),
	(9, 83, 4, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(5, 83, 4, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
	(2, 84, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 86, 4, 'Se cementó un perno sobre la pieza 28'),
	(2, 88, 4, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(8, 98, 5, 'Se colocó un implante de porcelana sobre el perno de la pieza 11'),
	(6, 98, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 98, 5, 'Se removió una caries en la pieza 4'),
	(6, 99, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(10, 100, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 101, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 12'),
	(5, 102, 5, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 32'),
	(3, 103, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 31'),
	(4, 105, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 26'),
	(2, 105, 5, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(10, 106, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(6, 107, 5, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
	(1, 107,5, 'Se removió una caries en la pieza 32'),
	(7, 108, 5, 'Se cementó un perno sobre la pieza 26'),
	(3, 109, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 30'),
	(10, 110, 5, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(4, 110, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
	(5, 111, 5, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 2'),
	(3, 111, 5, 'Se colocó un implante de titanio luego de una cirugía en la pieza 2'),
	(1, 111, 5, 'Se removió una caries en la pieza 21'),
	(4, 112, 5, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 21'),
	(2, 121, 6, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(7, 121, 6, 'Se cementó un perno sobre la pieza 31'),
	(5, 121, 6, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 18'),
	(9, 122, 6, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(10, 123, 6, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(7, 124, 6, 'Se cementó un perno sobre la pieza 17'),
	(3, 125, 6, 'Se colocó un implante de titanio luego de una cirugía en la pieza 12'),
	(9, 126, 6, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
	(4, 129, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 11'),
	(2, 131, 6, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(10, 133, 6, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
	(8, 133, 6, 'Se colocó un implante de porcelana sobre el perno de la pieza 15'),
	(4, 134, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 6'),
	(8, 134, 6, 'Se colocó un implante de porcelana sobre el perno de la pieza 14'),
	(4, 135, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 13'),
	(4, 136, 6, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 5'),
	(2, 145, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 146, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 147, 12, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 148, 13, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 149, 9, 'Se realizó una radiografía panorámica de la boca del paciente'),
	(2, 150, 12, 'Se realizó una radiografía panorámica de la boca del paciente');
    
INSERT INTO pagos (fecha, id_evolucion, monto, id_modo_pago) VALUES
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

INSERT INTO stock (nombre, cantidad, cantidad_minima, cantidad_recomendada, presentacion, variedad, ubicacion) VALUES
	('Guantes de latex', 6, 3, 19, 'Caja/s', 'Talle XS', 'Estantería e4'), ('Guantes de latex', 18, 5, 19, 'Caja/s', 'Talle S', 'Estantería c2'),
	('Guantes de latex', 4, 4, 20, 'Caja/s', 'Talle M', 'Estantería e1'), ('Guantes de latex', 11, 5, 16, 'Caja/s', 'Talle L', 'Estantería g1'),
	('Guantes de latex', 12, 8, 8, 'Caja/s', 'Talle XL', 'Estantería d1'), ('Barbijos quirúrgicos', 13, 6, 10, 'Caja/s', NULL, 'Estantería f3'),
	('Lima p/ conducto', 16, 5, 14, 'Unidad/es', 'Tamaño 1', 'Estantería f2'), ('Lima p/ conducto', 16, 6, 10, 'Unidad/es', 'Tamaño 2', 'Estantería f1'),
	('Lima p/ conducto', 3, 3, 10, 'Unidad/es', 'Tamaño 3', 'Estantería e1'), ('Lima p/ conducto', 9, 6, 18, 'Unidad/es', 'Tamaño 4', 'Estantería f1'),
	('Lima p/ conducto', 8, 7, 10, 'Unidad/es', 'Tamaño 5', 'Estantería g2'), ('Lima p/ conducto', 17, 4, 17, 'Unidad/es', 'Tamaño 6', 'Estantería g2'),
	('Papel absorbente p/ conducto', 16, 8, 8, 'Unidad/es', NULL, 'Estantería b3'), ('Fresa p/ torno', 16, 4, 15, 'Unidad/es', 'Cónica tamaño 1', 'Estantería c2'),
	('Fresa p/ torno', 13, 8, 19, 'Unidad/es', 'Cónica tamaño 2', 'Estantería d3'), ('Fresa p/ torno', 11, 6, 8, 'Unidad/es', 'Cónica tamaño 3', 'Estantería c1'),
	('Fresa p/ torno', 4, 4, 16, 'Unidad/es', 'Cilíndrica tamaño 1', 'Estantería d2'), ('Fresa p/ torno', 4, 6, 13, 'Unidad/es', 'Cilíndrica tamaño 2', 'Estantería g2'),
	('Fresa p/ torno', 10, 4, 20, 'Unidad/es', 'Cilíndrica tamaño 3', 'Estantería b5'), ('Tubo flexible p/ absorbedor', 17, 8, 8, 'Paquete/s', NULL, 'Estantería g3'),
	('Ionómetro vítreo', 20, 8, 12, 'Kilo/s', NULL, 'Estantería f1'), ('Pasta c/ flúor', 3, 7, 20, 'Tubo/s', NULL, 'Estantería d1');
    
INSERT INTO proveedores (nombre, telefono, direccion, email, url, cuit, activo) VALUES
	('Greenberg', '47653548', 'Av. Santa Fe 3256, CABA', 'ventas@greenberg.com.ar', 'www.greenbarg.com.ar', 30524125630, 1),
	('Insumos Dental Total', '41258964', 'Riobamba 1415, 2B, CABA', 'ventas@dentaltotal.com.ar', NULL, 30356589591, 1),
	('Viscay Implementos', '50265896', 'Fray Justo Sarmiento 252, Vicente Lopez', 'info@viscay.com.ar', NULL, 30154858965, 0),
	('Miguel del Monte', '1148759855', 'Soldado de Malvinas 1145, CABA', 'mmonte@gmail.com', NULL, 20365214588, 1),
	("Lilli's", '43689856', 'Viamonte 1190, CABA', 'consultas@lillis.com.ar', 'www.lillis.com.ar', 30785415952, 1),
	('Instrumental Pasteur', '49857854', 'Viamonte 1145, CABA', 'ventas@instrumentalpasteur.com.ar', 'www.instrumentalpasteur.com.ar', 30652147023, 1),
	('Gabriel Montero', '1142157845', 'Av. Presidente Peron 7450, Avellaneda', 'gabymontero@hotmail.com', NULL, 20270147853, 0),
	('Pipes Insumos Dentales', '32659887', 'Juana Azurduy 2569, CABA', 'pipesventas@yahoo.com.ar', NULL, 30269856489, 1);
    
INSERT INTO estado_pedido (estado) VALUES ('Realizado'), ('Recibido'), ('Chequeado');

INSERT INTO pedidos_stock (id_proveedor, fecha_ingreso, precio_total, id_estado_pedido, id_empleado_recibe, id_empleado_controla) VALUES
	(1, '2022-04-01', 105000.00, 3, 9, 9),
	(4, '2022-04-01', 45000.00, 3, 13, 10),
	(2, '2022-07-02', 85000.00, 3, 12, 12),
	(4, '2022-07-01', 38000.00, 3, 14, 14),
	(1, '2022-10-01', 78000.00, 3, 9, 14),
	(2, '2022-10-03', 36000.00, 2, 13, NULL),
	(4, '2022-10-03', 24000.00, 2, 10, NULL);

-- A partir de aca hay una serie de consumos e ingresos de stock, simulando pedidos cada un par de meses

INSERT INTO consumos_stock (fecha, hora, id_producto, cantidad, id_empleado_retira, id_empleado_utiliza) VALUES
	('2022-02-08', '10:30', 4, 2, 4, 4), ('2022-02-26', '16:03', 3, 1, 10, 4), ('2022-02-27', '19:02', 6, 1, 13, 2),
	('2022-02-09', '14:50', 13, 1, 10, 1), ('2022-02-25', '14:21', 3, 1, 7, 2), ('2022-02-13', '19:28', 8, 1, 13, 6),
	('2022-02-10', '11:47', 19, 1, 12, 1), ('2022-02-14', '11:55', 11, 1, 3, 6), ('2022-02-16', '18:44', 9, 2, 8, 3),
	('2022-03-14', '12:13', 10, 1, 6, 2), ('2022-03-23', '17:34', 3, 1, 3, 1), ('2022-03-17', '13:38', 14, 2, 9, 5),
	('2022-03-06', '15:40', 5, 1, 3, 6), ('2022-03-17', '12:08', 15, 1, 6, 2), ('2022-03-22', '10:47', 12, 1, 1, 1),
	('2022-03-06', '20:14', 17, 1, 2, 6), ('2022-03-23', '19:56', 3, 1, 10, 2), ('2022-03-28', '19:51', 20, 1, 9, 2),
	('2022-03-04', '18:12', 8, 1, 12, 2), ('2022-03-08', '19:26', 4, 1, 5, 5), ('2022-03-10', '17:02', 11, 2, 1, 6),
	('2022-03-01', '16:07', 22, 1, 1, 2), ('2022-03-18', '20:14', 4, 3, 2, 2), ('2022-03-15', '13:07', 5, 1, 9, 1),
	('2022-03-27', '12:56', 8, 3, 6, 5), ('2022-03-28', '13:36', 6, 1, 9, 3), ('2022-03-18', '14:28', 11, 1, 8, 2),
	('2022-03-28', '10:07', 18, 2, 6, 6), ('2022-03-12', '20:51', 18, 1, 5, 4), ('2022-03-26', '10:02', 5, 1, 14, 5),
	('2022-03-10', '20:17', 10, 1, 3, 2), ('2022-03-27', '10:49', 13, 1, 3, 3), ('2022-03-11', '10:32', 21, 1, 4, 3),
	('2022-03-10', '15:27', 15, 1, 12, 3), ('2022-03-05', '10:26', 14, 5, 4, 1), ('2022-03-19', '15:47', 16, 1, 4, 3), 
	('2022-03-07', '14:17', 16, 1, 9, 3), ('2022-03-21', '13:27', 4, 1, 14, 2), ('2022-03-28', '10:35', 22, 1, 8, 6),
	('2022-03-02', '18:11', 5, 1, 5, 3), ('2022-03-04', '11:08', 22, 1, 8, 6), ('2022-03-03', '19:08', 5, 1, 5, 1),
	('2022-03-05', '14:30', 21, 1, 4, 2), ('2022-03-27', '12:22', 5, 2, 12, 3), ('2022-03-27', '16:52', 15, 1, 6, 1),
	('2022-03-05', '10:35', 10, 1, 14, 4), ('2022-03-20', '20:52', 6, 2, 5, 2);

INSERT INTO ingresos_stock (id_pedido, id_producto, cantidad_ingresada) VALUES
	(1, 17, 16), (1, 18, 13), (1, 9, 10), (1, 10, 18), (1, 11, 10),
	(1, 22, 20), (2, 3, 20), (2, 4, 16), (2, 5, 8);
    
INSERT INTO consumos_stock (fecha, hora, id_producto, cantidad, id_empleado_retira, id_empleado_utiliza) VALUES
	('2022-04-05', '19:44', 2, 1, 13, 4), ('2022-04-09', '16:42', 7, 1, 11, 4), ('2022-04-26', '14:51', 19, 1, 8, 3),
	('2022-04-09', '11:02', 11, 1, 4, 2), ('2022-04-09', '15:39', 2, 1, 14, 6), ('2022-04-01', '14:30', 4, 1, 5, 6),
	('2022-04-13', '13:40', 7, 1, 9, 2), ('2022-04-28', '14:28', 13, 1, 7, 6), ('2022-04-28', '15:54', 12, 1, 2, 4),
	('2022-04-09', '11:27', 22, 1, 6, 5), ('2022-04-03', '15:39', 20, 2, 4, 1), ('2022-04-02', '14:34', 8, 1, 7, 2),
	('2022-04-05', '13:09', 17, 2, 1, 2), ('2022-04-04', '17:42', 4, 1, 2, 1), ('2022-04-15', '11:36', 15, 2, 10, 5),
	('2022-04-05', '10:58', 18, 1, 1, 5), ('2022-04-24', '14:28', 22, 3, 9, 6), ('2022-04-23', '19:54', 10, 1, 12, 5),
	('2022-04-19', '12:12', 4, 1, 12, 3), ('2022-04-17', '10:09', 14, 2, 8, 1), ('2022-04-01', '10:15', 15, 1, 3, 6),
	('2022-04-16', '10:24', 5, 1, 1, 5), ('2022-04-14', '11:40', 21, 1, 6, 2), ('2022-04-28', '18:41', 15, 1, 8, 1),
	('2022-04-02', '15:13', 1, 1, 2, 4), ('2022-04-16', '14:08', 9, 2, 2, 5), ('2022-04-22', '16:12', 14, 1, 10, 1),
	('2022-04-16', '14:33', 11, 1, 14, 1), ('2022-04-28', '10:35', 3, 1, 4, 2), ('2022-04-16', '15:14', 14, 2, 9, 3),
	('2022-04-02', '12:28', 3, 1, 7, 2), ('2022-04-25', '10:04', 21, 1, 14, 1), ('2022-04-04', '15:31', 22, 1, 11, 2),
	('2022-04-20', '13:10', 1, 2, 14, 4), ('2022-04-08', '10:35', 3, 1, 14, 3), ('2022-04-22', '15:08', 8, 2, 6, 2),
	('2022-04-11', '12:05', 17, 2, 7, 3), ('2022-04-06', '14:28', 8, 1, 14, 1), ('2022-04-21', '12:17', 5, 1, 7, 3),
	('2022-04-24', '18:40', 16, 1, 10, 3), ('2022-04-27', '15:27', 10, 1, 1, 6), ('2022-04-08', '17:13', 15, 1, 9, 3),
	('2022-04-20', '13:43', 6, 1, 4, 1), ('2022-04-04', '11:13', 2, 1, 6, 1), ('2022-04-08', '20:37', 15, 3, 12, 1),
	('2022-05-21', '19:59', 10, 1, 6, 5), ('2022-05-17', '12:28', 11, 2, 14, 1), ('2022-06-27', '15:25', 9, 1, 1, 5),
	('2022-06-12', '14:53', 18, 1, 2, 5), ('2022-06-19', '17:27', 21, 1, 10, 4);

INSERT INTO ingresos_stock (id_pedido, id_producto, cantidad_ingresada) VALUES
	(1, 14, 15), (1, 15, 19), (2, 1, 19);
    
INSERT INTO consumos_stock (fecha, hora, id_producto, cantidad, id_empleado_retira, id_empleado_utiliza) VALUES
	('2022-07-14', '18:52', 20, 2, 1, 6), ('2022-07-28', '11:18', 1, 1, 1, 4), ('2022-07-01', '16:21', 7, 1, 1, 4),
	('2022-07-13', '10:10', 5, 1, 10, 2), ('2022-07-19', '14:01', 17, 3, 12, 2), ('2022-07-21', '12:39', 6, 2, 7, 2),
	('2022-07-11', '12:08', 22, 1, 1, 3), ('2022-07-12', '13:12', 19, 2, 14, 4), ('2022-08-10', '19:11', 1, 1, 14, 6),
	('2022-08-05', '16:59', 11, 1, 2, 5), ('2022-08-11', '11:45', 7, 1, 8, 4), ('2022-08-26', '14:36', 1, 1, 9, 5),
	('2022-08-18', '13:01', 2, 1, 14, 3), ('2022-08-22', '19:56', 8, 3, 12, 6), ('2022-08-05', '17:29', 4, 1, 7, 3),
	('2022-08-08', '12:17', 11, 2, 9, 2), ('2022-08-28', '18:23', 18, 1, 1, 4), ('2022-08-18', '19:54', 16, 1, 12, 2),
	('2022-08-01', '15:18', 22, 1, 12, 5), ('2022-08-01', '17:48', 2, 1, 1, 6), ('2022-08-04', '15:12', 4, 1, 8, 5),
	('2022-08-23', '11:52', 3, 1, 12, 2), ('2022-08-07', '16:45', 12, 1, 6, 2), ('2022-08-25', '20:03', 18, 1, 7, 4),
	('2022-08-26', '19:43', 1, 1, 13, 4), ('2022-08-03', '13:02', 2, 1, 1, 4), ('2022-08-16', '15:44', 8, 1, 3, 1),
	('2022-08-19', '12:56', 2, 1, 6, 4), ('2022-08-28', '13:47', 10, 1, 3, 1), ('2022-08-22', '12:17', 15, 1, 2, 3),
	('2022-08-01', '11:25', 1, 1, 2, 6), ('2022-08-04', '17:47', 15, 1, 1, 3), ('2022-08-02', '13:46', 4, 1, 9, 6),
	('2022-08-22', '15:29', 5, 1, 10, 6), ('2022-08-13', '11:13', 18, 2, 2, 6), ('2022-08-04', '10:13', 17, 1, 14, 3),
	('2022-08-17', '15:48', 16, 1, 14, 5), ('2022-08-27', '18:07', 12, 1, 1, 5), ('2022-08-08', '20:42', 13, 2, 3, 2),
	('2022-08-09', '18:37', 14, 1, 4, 3), ('2022-08-27', '14:50', 2, 1, 2, 1), ('2022-08-12', '11:40', 2, 1, 3, 3),
	('2022-08-08', '14:01', 9, 1, 11, 1), ('2022-08-02', '13:29', 19, 1, 9, 5), ('2022-08-06', '12:19', 9, 1, 8, 1),
	('2022-08-12', '19:23', 6, 1, 3, 6), ('2022-08-05', '11:48', 21, 4, 3, 2), ('2022-08-06', '20:08', 4, 1, 14, 4),
	('2022-08-20', '13:11', 5, 1, 9, 4), ('2022-08-06', '18:19', 8, 1, 9, 6), ('2022-08-25', '13:50', 9, 1, 7, 3),
	('2022-08-23', '11:44', 1, 1, 6, 6), ('2022-08-07', '11:33', 13, 1, 8, 5), ('2022-08-22', '13:22', 16, 1, 5, 5),
	('2022-08-25', '14:33', 2, 1, 10, 1), ('2022-08-03', '15:41', 8, 1, 6, 2), ('2022-08-03', '11:49', 2, 1, 11, 5),
	('2022-08-28', '10:52', 4, 1, 7, 3), ('2022-08-21', '16:06', 16, 1, 12, 1), ('2022-08-10', '11:29', 1, 1, 7, 2),
	('2022-08-13', '15:31', 16, 1, 9, 1), ('2022-08-19', '17:26', 19, 2, 13, 2), ('2022-08-06', '11:21', 9, 1, 1, 2),
	('2022-08-19', '18:04', 20, 1, 14, 4), ('2022-08-24', '18:00', 7, 1, 2, 6), ('2022-08-11', '10:08', 9, 1, 10, 6),
	('2022-08-20', '18:23', 20, 1, 1, 3), ('2022-09-24', '13:44', 3, 3, 2, 3), ('2022-09-09', '19:00', 9, 1, 4, 6),
	('2022-09-21', '16:33', 19, 2, 11, 6), ('2022-09-16', '12:12', 19, 1, 1, 1), ('2022-09-24', '12:18', 1, 1, 8, 6), 
	('2022-09-28', '13:47', 12, 3, 1, 5), ('2022-09-15', '17:02', 16, 2, 9, 5), ('2022-09-05', '15:20', 14, 1, 7, 5), 
	('2022-09-17', '10:34', 13, 1, 11, 3), ('2022-09-19', '10:39', 5, 1, 7, 1), ('2022-09-15', '20:37', 8, 1, 8, 4), 
	('2022-09-12', '10:39', 14, 1, 10, 1), ('2022-09-09', '18:01', 6, 1, 12, 1), ('2022-09-05', '16:12', 11, 2, 4, 6), 
	('2022-09-03', '14:20', 12, 3, 11, 5), ('2022-09-18', '11:25', 14, 2, 6, 4), ('2022-09-05', '12:27', 1, 1, 7, 6),
	('2022-09-04', '11:34', 16, 1, 6, 1), ('2022-09-21', '10:12', 10, 1, 6, 1), ('2022-09-26', '19:03', 9, 1, 3, 6),
	('2022-09-04', '17:19', 2, 1, 10, 1), ('2022-09-28', '16:47', 11, 1, 8, 4), ('2022-09-10', '20:44', 11, 1, 12, 6),
	('2022-09-10', '11:04', 18, 1, 1, 2), ('2022-09-05', '19:41', 12, 2, 1, 5), ('2022-09-22', '14:22', 10, 1, 14, 4),
	('2022-09-10', '17:09', 1, 1, 3, 5), ('2022-09-25', '11:46', 6, 1, 12, 6), ('2022-09-16', '17:05', 13, 2, 4, 1);

INSERT INTO ingresos_stock (id_pedido, id_producto, cantidad_ingresada) VALUES
	(1, 16, 8), (1, 19, 20), (2, 8, 10), (2, 9, 10),
	(2, 11, 10), (2, 13, 8),(3, 6, 10), (3, 5, 8);

-- Esta tabla se llena sola en la utilización comun. Esto simula el proceso de llamar el SP honorarios a fin de cada mes trabajado (excepto septiembre, dejado para testear)
INSERT INTO honorarios_definitivos (fecha_definicion, usuario, id_empleado, honorario, mes, anio) VALUES 
	('2022-03-01','root@localhost',1,65823.50,2,2022), ('2022-05-01','root@localhost',1,109825.00,4,2022),  ('2022-07-01','root@localhost',1,43375.00,6,2022),
	('2022-03-01','root@localhost',2,28547.00,2,2022), ('2022-05-01','root@localhost',2,43990.00,4,2022), ('2022-07-01','root@localhost',2,84540.00,6,2022),
	('2022-03-01','root@localhost',3,61700.10,2,2022), ('2022-05-01','root@localhost',3,180.00,4,2022), ('2022-07-01','root@localhost',3,33620.10,6,2022),
	('2022-03-01','root@localhost',4,64580.00,2,2022), ('2022-05-01','root@localhost',4,64622.00,4,2022), ('2022-07-01','root@localhost',4,6162.20,6,2022), 
	('2022-03-01','root@localhost',5,72460.00,2,2022), ('2022-05-01','root@localhost',5,26442.00,4,2022), ('2022-07-01','root@localhost',5,61382.10,6,2022),
	('2022-03-01','root@localhost',6,12640.10,2,2022), ('2022-05-01','root@localhost',6,8800.00,4,2022), ('2022-07-01','root@localhost',6,7802.10,6,2022), 
	('2022-03-01','root@localhost',9,0.00,2,2022), ('2022-05-01','root@localhost',9,0.00,4,2022), ('2022-07-01','root@localhost',9,0.00,6,2022), 
	('2022-03-01','root@localhost',10,0.00,2,2022),('2022-05-01','root@localhost',10,0.00,4,2022), ('2022-07-01','root@localhost',10,0.00,6,2022), 
	('2022-03-01','root@localhost',12,0.00,2,2022), ('2022-05-01','root@localhost',12,350.00,4,2022), ('2022-07-01','root@localhost',12,0.00,6,2022), 
	('2022-03-01','root@localhost',13,700.00,2,2022), ('2022-05-01','root@localhost',13,350.00,4,2022), ('2022-07-01','root@localhost',13,0.00,6,2022), 
	('2022-03-01','root@localhost',14,0.00,2,2022), ('2022-05-01','root@localhost',14,0.00,4,2022), ('2022-07-01','root@localhost',14,0.00,6,2022);

-- A continuación modifico las filas vacías autogeneradas en trabajos_laboratorio

UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=33000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=1;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=25000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=2;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=3000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=3;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=10000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=4;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=23000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=5;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=18000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=6;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=32000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=7;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=42000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=8;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=12000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=9;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=18000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=10;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=26000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=11;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=14000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=12;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=11000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=13;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=21000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=14;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=24000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=15;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=13000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=16;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=27000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=17;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=16000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=18;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=4000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=19;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=9000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=20;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=24000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=21;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=11000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=22;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=8000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=23;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=12000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=24;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=25000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=25;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=21000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=26;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=2000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=27;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=12000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=28;
UPDATE trabajos_laboratorio SET id_laboratorio=4, precio=9000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=29;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=15000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=30;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=32000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=31;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=24000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=32;
UPDATE trabajos_laboratorio SET id_laboratorio=5, precio=18000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=33;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=21000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=34;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=20000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=35;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=5000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=36;
UPDATE trabajos_laboratorio SET id_laboratorio=6, precio=15000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=37;
UPDATE trabajos_laboratorio SET id_laboratorio=1, precio=7000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=38;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=23000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=39;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=20000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=40;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=9000, id_estado_trabajo_laboratorio=3 WHERE id_trabajo_laboratorio=41;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=24000, id_estado_trabajo_laboratorio=4 WHERE id_trabajo_laboratorio=42;
UPDATE trabajos_laboratorio SET id_laboratorio=2, precio=21000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=43;
UPDATE trabajos_laboratorio SET id_laboratorio=5, precio=20000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=44;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=19000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=45;
UPDATE trabajos_laboratorio SET id_laboratorio=3, precio=18000, id_estado_trabajo_laboratorio=2 WHERE id_trabajo_laboratorio=46;
UPDATE trabajos_laboratorio SET id_laboratorio=NULL, precio=6000, id_estado_trabajo_laboratorio=1 WHERE id_trabajo_laboratorio=47;

-- VISTAS --

-- VISTA 1
-- Nos permite ver la historia clínica de un paciente si se retringe la vista por numero de documento (por ejemplo)

CREATE OR REPLACE VIEW historia_clinica AS (
	SELECT t.fecha, t.hora, p.documento, e.descripcion, em.apellido AS 'odontologo', tl.precio AS 'costo_laboratorio', lb.nombre AS 'laboratorio'
	FROM evoluciones e
	JOIN turnos t ON e.id_turno = t.id_turno
	JOIN empleados em ON em.id_empleado = e.id_empleado
	JOIN pacientes p ON t.id_paciente = p.id_paciente
	LEFT JOIN trabajos_laboratorio tl ON e.id_trabajo_laboratorio = tl.id_trabajo_laboratorio
	LEFT JOIN laboratorios lb ON tl.id_laboratorio = lb.id_laboratorio
	ORDER BY fecha, hora
);

-- Ejemplo de extraer la historia clínica de un paciente

-- SELECT *
-- FROM historia_clinica
-- WHERE documento = '18895062';

-- VISTA 2
-- Me permite ver la agenda de turnos de la clínica o de un ogontologo en particular

CREATE OR REPLACE VIEW agenda AS (
	SELECT tu.fecha, tu.hora, e.apellido AS 'odontologo', CONCAT(p.nombre, ' ', p.apellido) AS 'paciente', p.documento, p.celular AS 'contacto'
	FROM turnos tu
	JOIN pacientes p ON tu.id_paciente = p.id_paciente
	JOIN empleados e ON tu.id_empleado = e.id_empleado
	WHERE tu.id_estado_turno = 3 -- Los turnos que todavia no sucedieron
	AND tu.id_tratamiento IS NULL -- Ignoro los turnos que corresponden a estudios radiológicos
	ORDER BY fecha, hora
);

-- Ejemplo de extraer la agenda de un odontólogo para un día en particular

-- SELECT fecha, hora, paciente, documento, contacto 
-- FROM agenda
-- WHERE odontologo = 'Lillian'
-- AND fecha = '2022-02-12';

-- Ejemplo de extraer la agenda de un odontólogo para una semana en particular

-- SELECT fecha, hora, paciente, documento, contacto 
-- FROM agenda
-- WHERE odontologo = 'Lillian'
-- AND WEEK(fecha) = 48;

-- VISTA 3
-- Me permite ver los turnos de la sección radiológica de la clínica

CREATE OR REPLACE VIEW agenda_radiologica AS (
	SELECT tu.fecha, tu.hora, CONCAT(p.nombre, ' ', p.apellido) AS 'paciente', p.documento, p.celular AS 'contacto', tr.nombre AS 'tratamiento'
	FROM turnos tu
	JOIN pacientes p ON tu.id_paciente = p.id_paciente
	JOIN tratamientos tr ON tu.id_tratamiento = tr.id_tratamiento
	WHERE id_estado_turno = 3 -- Los turnos que todavia no sucedieron
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

-- VISTA 7
-- Me permite ver los productos con bajo stock, recomenando una cantidad a pedir.

CREATE OR REPLACE VIEW bajo_stock AS (
	SELECT st.nombre, st.variedad, CONCAT(st.cantidad, ' ', st.presentacion) AS 'stock_actual', CONCAT(st.cantidad_recomendada, ' ', st.presentacion) AS 'pedido_recomendado' 
	FROM stock st
	WHERE cantidad <= cantidad_minima
	ORDER BY st.nombre
);

-- Se puede modificar facilmente para generar otro formato de tablapara exportar pedidos directamente
