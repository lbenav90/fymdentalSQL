USE fymdental;

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
    WHERE asistio = 2 -- Los turnos que todavia no sucedieron
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
    WHERE asistio = 2 -- Los turnos que todavia no sucedieron
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