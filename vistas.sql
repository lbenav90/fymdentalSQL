USE fymdental;

-- Historia clínica de un paciente

CREATE OR REPLACE VIEW historia_clinica AS (
	SELECT t.fecha, t.hora, p.documento, e.descripcion, em.apellido AS 'Odontólogo'
	FROM evoluciones e
	JOIN turnos t ON e.id_turno = t.id_turno
    JOIN empleados em ON em.id_empleado = e.id_empleado
	JOIN pacientes p ON e.id_paciente = p.id_paciente
	ORDER BY fecha, hora);
