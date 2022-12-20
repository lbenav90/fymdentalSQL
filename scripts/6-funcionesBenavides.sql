USE fymdental;

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
	AND month(tu.fecha) = mes;
    
    RETURN (facturacion_mensual * porcentaje_tratamiento - laboratorios_mensual * porcentaje_laboratorio) / 100;
END$$

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
DELIMITER ;

-- Crear funcion que limpie un string de un telefono o un documento para dejarlo alfanumerico
