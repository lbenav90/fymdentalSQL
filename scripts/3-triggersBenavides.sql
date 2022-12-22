USE `fymdental`;
DROP TRIGGER IF EXISTS `generar_log_pago_insert`;
DROP TRIGGER IF EXISTS `generar_log_pago_update`;
DROP TRIGGER IF EXISTS `generar_log_evolucion_insert`;
DROP TRIGGER IF EXISTS `generar_log_evolucion_update`;
DROP TRIGGER IF EXISTS `new_lab_work`;

-- Frente a una inserción en la tabla pagos, este trigger agrega un log en la tabla log_pagos

CREATE TRIGGER `generar_log_pago_insert`
AFTER INSERT ON `pagos`
FOR EACH ROW
INSERT INTO `log_pagos` (evento, objetivo, usuario) VALUES ('INSERT', NEW.id_pago, USER());

DELIMITER $$

-- Frente a la modificación de una fila en la tabla pagos, este trigger agrega un log en la tabla log_pagos
-- También agrega una fila en pagos_audit que registra los cambios que se producen

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
         -- Este chequeo es por si se agrega una evolución con un trabajo de laboratorio ya asignado
         IF NEW.id_trabajo_laboratorio IS NULL THEN
			INSERT INTO trabajos_laboratorio (id_trabajo_laboratorio) VALUES (NULL);
            SET NEW.id_trabajo_laboratorio = (SELECT MAX(id_trabajo_laboratorio) FROM trabajos_laboratorio);
         END IF;
         
    END IF;
END$$

DELIMITER ;

-- Validacion de telefonos y documentos

-- Validacion formato de direccion de email

-- Validacion de tinyint binario

-- Validacion porcentaje

-- Validacion de tinyint ternario

-- Validacion de tinyint quintenario

-- Validacion de formato de CUIT

-- Chequear que me hayan dado o un celular o un telefono de paciente