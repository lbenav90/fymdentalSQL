USE `fymdental`;
DROP PROCEDURE IF EXISTS `lista_emails`;
DROP PROCEDURE IF EXISTS `create_new_lab_work`;

DELIMITER $$

-- Obtener una lista de emails. Lista de pacientes ordenada por un parametro de entrada
-- Las columnas de orden pueden ser nombre, apellido, documento, genero (0 femenino, 1 masculino), fecha_de_nacimiento y email
-- El segundo parámetro define si es ascendente o descendente. Poner ASC o DESC para elegir uno o el otro

CREATE DEFINER=`root`@`localhost` PROCEDURE `lista_emails`(IN order_column VARCHAR(50), IN direction VARCHAR(4))
BEGIN
	IF order_column <> '' THEN
		SET @order_clause = CONCAT('ORDER BY ', order_column, ' ', direction);
	ELSE
		SET @order_clause = '';
    END IF;
    
    SET @clause = CONCAT('SELECT nombre, apellido, documento, genero, fecha_de_nacimiento, email FROM pacientes ', @order_clause);
    PREPARE runSQL FROM @clause;
    EXECUTE runSQL;
    DEALLOCATE PREPARE runSQL;
END$$

-- El siguiente Stored Procedure es llamado desde un trigger de la tabla evoluciones (aún no implementado)
-- Frente a la inserción de una evolución que refiera a un tratamiento que tenga un valor de trabajo_laboratorio=1 (en la tabla tratamientos), se llama a este Procedure
-- Este procedure hace un INSERT vacío en la tabla trabajos_laboratorio
-- Luego hace un UPDATE de la fila de la tabla evoluciones que se insertó con el id_trabajo_laboratorio insertado antes.

-- Para testearlo hay que agregar una nueva evolución, por ejemplo:
-- INSERT INTO evoluciones (descripcion, id_tratamiento, id_turno, id_paciente, id_empleado) VALUES ('generico', 4, 1, 1, 1);
-- Luego, llamar a Stored Procedure con el id_evolucion de la fila recien generada (si se usan solo los datos insertdos por script, el nuevo id es 115)
-- CALL fymdental.create_new_lab_work(115);

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_new_lab_work`(IN evolucion_id INT)
BEGIN

	DECLARE trabajo_id INT;
    
    SET trabajo_id = (SELECT id_trabajo_laboratorio FROM evoluciones WHERE id_evolucion=evolucion_id);
    
    IF NOT ISNULL(trabajo_id) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya se creó un trabajo de laboratorio para esta evolución';
    END IF;
    
    SET @clausula_create = CONCAT('INSERT INTO trabajos_laboratorio (id_trabajo_laboratorio) VALUES (NULL)');
	PREPARE insertSQL FROM @clausula_create;
	EXECUTE insertSQL;
	DEALLOCATE PREPARE insertSQL;
	
	SET @clausula_update = CONCAT('UPDATE evoluciones SET id_trabajo_laboratorio=(SELECT MAX(id_trabajo_laboratorio)  FROM trabajos_laboratorio) WHERE id_evolucion=', evolucion_id);
	PREPARE updateSQL FROM @clausula_update;
	EXECUTE updateSQL;
	DEALLOCATE PREPARE updateSQL;
END$$
DELIMITER ;
