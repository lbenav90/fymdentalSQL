USE fymdental;

INSERT INTO tipo_de_empleado 
	(titulo, porcentaje_tratamiento, porcentaje_laboratorio, lleva_monto_fijo) 
VALUES 
	('Socio'	    , 70, 50, 0),
    ('Odontólogo'	, 40, 50, 0),
    ('Recepcionista',  0,  0, 1),
    ('Asistente'	,  0,  0, 1);

INSERT INTO laboratorios
	(nombre, telefono, direccion, email, cuit, activo)
VALUES
	('Dental Lab'					,   '47233265', 'Av. Rivadavia 2154, Balvanera'							   , 'dentallab@gmail.com'		 , '30215469857', 1),
    ('Super Lab'					,   '42569874', 'Av. Maipu 1656, Vicente Lopez, Pcia. de Buenos Aires'     , 'superlab@gmail.com'		 , '30256547891', 0),
    ('Fym Dental Lab'				,   '43254785', 'Av. Rivadavia 1936, Balvanera'							   , 'fymdental@gmail.com'		 , '30487963525', 1),
    ('Dientes Derechos'				,   '41589632', 'Chiclana 952, Saavedra'								   , 'dientesderechos@gmail.com' , '27356987841', 1),
    ('Esteban Alderete'				, '1549786523', 'Carlos Pellegrini 3652, San Nicolás'					   , 'ealderete@gmail.com'		 , '20296589851', 1),
    ('Timoteo Astro Mecanica Dental', '1532564578', 'Bernardo de Irigoyen 2563, Florida, Pcia. de Buenos Aires', 'tamecanicadental@gmail.com', '20312569402', 1);

INSERT INTO pacientes 
	(nombre, apellido, documento, genero, fecha_de_nacimiento, email, celular, telefono)
VALUES 
	('Juan'			, 'Straciatella', 34521478, 1, '1990-02-25', 'jstraciatella@gmail.com'	 	  , '1549769856', '41527014'),
    ('Estela'		, 'Marquez'		, 16529689, 0, '1965-07-10', 'estela.marquez26@gmail.com'	  , '1554789561', '50249014'),
    ('Juliana Ester', 'Porto'		, 23457898, 0, '1973-10-07', 'julianap163@gmail.com'		  , '1543689501', '47926520'),
    ('Melisa'		, 'Sertain'		, 40158965, 0, '1995-04-02', 'melisertain@gmail.com'		  , '1537894014', '46359014'),
    ('Esteban Julio', 'Nuñez Cartez', 45165896, 1, '2002-09-21', 'chuckynuñez@gmail.com'		  , '1544398855', '46359078'),
    ('Belen'		, 'Lussanne'	, 10458962, 0, '1954-03-17', 'blussanne@gmail.com'			  , '1530256981', '47485201'),
    ('Mingo'		, 'Gomez'		, 29568965, 1, '1947-11-27', 'mingogomez23@gmail.com'	 	  , '1554129021', '47802563'),
    ('Pedro Julian'	, 'Milan'		, 17845025, 1, '1963-05-25', 'pedrojulianmilan@gmail.com'	  , '1543569014', '47102589'),
    ('Dixon' 		, 'Johnson'		, 42658901, 1, '1999-01-12', 'dixiej1999@gmail.com'	 	  	  , '1541222298', '46985632'),
    ('Usnavi'		, 'Gonzalez'	, 31642589, 1, '1986-06-01', 'usnavigonzalez147@gmail.com'	  , '1549863025', '45654445'),
    ("Donovan"		, "Blackwell"	, 40735541, 1, "1954-07-25", "d.blackwell@aol.edu"		  	  , "1527701146", "46331425"),
	("Kuame"  		, "Decker"		, 15362206, 0, "1967-05-13", "d_kuame@google.com"		 	  , "1566409614", "40798054"),
	("Pamela"		, "Campos"		, 23330615, 0, "1963-09-16", "campospamela@outlook.couk"  	  , "1551002884", "43851317"),
	("Jana"  		, "Duran"		, 11158527, 0, "1951-05-04", "djana@google.org"			   	  , "1555647381", "42870144"),
	("Rooney" 		, "Mooney"		, 18894689, 1, "1955-08-27", "rooney-mooney8435@protonmail.ca", "1524640540", "48313313"),
    ("Cameron"		, "Mayo"		, 29190432, 1, "1983-07-20", "cameron-mayo2654@aol.edu"		  , "1538523683", "47966741"),
	("Colt"   		, "Young"		, 26981742, 1, "1964-11-23", "youngcolt@protonmail.edu"		  , "1572127341", "47326858"),
	("Harper" 		, "Walton"		, 24366598, 0, "1967-08-14", "h.walton846@hotmail.org"	      , "1596279918", "41611574"),
	("Solomon"		, "Nguyen"		, 18895062, 1, "1979-04-18", "nguyen.solomon8053@hotmail.com" , "1553730945", "47322147"),
	("Brian"  		, "Morrow"		, 30504045, 1, "2003-10-07", "mbrian9941@hotmail.edu"		  , "1574458573", "47912343"),
    ("Imogene"		, "Kelley"		, 23794589, 0, "1958-10-18", "kelley.imoge6046@protomail.couk", "1534452023", "48276488"),
	("Yvonne" 		, "Lyons"		, 34352612, 0, "1981-11-24", "y.lyons@hotmail.org"			  , "1535280599", "40512666"),
	("Cruz"   		, "Cash"		, 44218202, 1, "1958-01-03", "cruz-cash@hotmail.ca"			  , "1516314639", "41557314"),
	("Nissim" 		, "Sosa"		, 32224776, 0, "1961-01-06", "n_sosa8667@outlook.org"		  , "1544363174", "43113127"),
	("Veda"   		, "Kaufman"		, 12929457, 0, "1986-04-05", "kaufman-veda7250@hotmail.org"   , "1531582363", "41644859");

INSERT INTO tratamientos 
	(nombre, nomenclador, precio, monto_fijo)
VALUES 
	('Caries', 'CI.1012.01', 3500.00, 0.00),
    ('Radiografía panorámica', 'CI.1034.01', 1650.25, 350.00),
    ('Implante', 'CI.1102.01', 26750.00, 0.00),
    ('Corona sobre implante', 'CI.1102.02', 47855.00, 0.00),
    ('Tratamiento de conducto', 'CI.1005.01', 16500.00, 0.00),
    ('Alineadores', 'CI.1501.01', 105000.00, 0.00),
    ('Perno', 'CI.1005.02', 11500.00, 0.00),
    ('Corona sobre perno', 'CI.1005.03', 37450.00, 0.00),
    ('Placa miorrelajante', 'CI.1250.01', 6500.00, 500.00),
    ('Limpieza', 'CI.1022.01', 8950.00, 0.00);
    
INSERT INTO empleados 
	(nombre, apellido, documento, genero, fecha_de_nacimiento, email, celular, direccion, id_tipo_empleado, activo)
VALUES 
	('Sebastián', 'Galarza', 34987014, 1, '1990-02-16', 'sgalarza@gmail.com', '1543580123', 'Cochabamba 498, CABA', 1, 1),
    ('Adriana', 'Lillian', 32421598, 0, '1989-12-14', 'adrilili@gmail.com', '1543659878', 'Cochabamba 498, CABA', 1, 1),
    ('Ximena', 'Ponce', 37259846, 0, '1993-09-26', 'ximelaloca@gmail.com', '1535980147', 'Av Santa Fe 3256 6A, CABA', 2, 1),
    ('Roberto Jesus', 'Rodón', 39426957, 1, '195-01-07', 'bobbyroddy@gmail.com', '1541592015', 'Av. Rivadavia 1965 4C, CABA', 2, 1),
    ('Julieta', 'Wilson', 36195025, 0, '1991-05-11', 'jwilson91@gmail.com', '1525059852', 'Congreso 2018, CABA', 2, 1),
    ('Alberto', 'Benitez', 34258701, 1, '1990-03-31', 'bertiebenitez1990@gmail.com', '1540593014', 'Bernardo Ader 1651, Carapachay, Pcia de Buenos Aires', 2, 1),
    ('Lisandro Javier', 'Paso', 35489632, 1, '1990-07-20', 'lisapaso01@gmail.com', '1544596522', 'Av. Cabildo 651, CABA', 2, 0),
    ('Augusto', 'Nómade', 36652102, 1, '1991-11-02', 'gustomade@gmail.com', '1542021069', 'Frey Justo Sarmiento 620, CABA', 2, 0),
    ('Florencia', 'Del Carril', 42159870, 0, '1999-06-25', 'flordelcarril@gmail.com', '1541059877', 'Gaspar Campos, Vicente Lopez, Pcia. de Buenos Aires', 3, 1),
    ('Celeste', 'Umbaki', 41485201, 0, '1996-10-10', 'celesbaki10@gmail.com', '1556988746', 'Nuñez 2014, CABA', 3, 1),
    ('Beatriz', 'Portengo', 27452014, 0, '1980-08-18', 'beaportengo05@gmail.com', '1544159025', 'Juncal 410, CABA', 3, 0),
    ('Luciana', 'Latorre', 14731529, 0, '1961-01-16', 'llatorre105@gmail.com', '1546359852', 'Billinghurst 2856, CABA', 3, 1),
    ('Raquel', 'Brea', 35412985, 0, '1990-02-08', 'kellybrea90@gmail.com', '1533014978', 'Rio de Janerico 1547, CABA', 4, 1),
    ('Ramona', 'Montiel', 40415951, 0, '1995-06-16', 'rmontiel95@gmail.com', '1550789889', '7 de Septiembre 1597, CABA', 4, 1);

INSERT INTO turnos 
	(fecha, hora, asistio, id_paciente, id_empleado, id_tratamiento)
VALUES 
	-- Ondontólogo id 1
	('2022-02-12', '10:00', 1, 19, 1, NULL), ('2022-02-12', '12:00', 1, 6, 1, NULL), ('2022-02-12', '14:00', 0, 14, 1, NULL), ('2022-02-12', '16:00', 1, 2, 1, NULL),
    ('2022-04-25', '10:30', 1, 25, 1, NULL), ('2022-04-25', '11:30', 1, 19, 1, NULL), ('2022-04-25', '13:30', 1, 10, 1, NULL), ('2022-04-25', '15:00', 1, 2, 1, NULL),
    ('2022-06-17', '10:30', 0, 13, 1, NULL), ('2022-06-17', '12:00', 1, 16, 1, NULL), ('2022-06-17', '14:00', 1, 22, 1, NULL), ('2022-06-17', '15:30', 1, 25, 1, NULL),
    ('2022-09-05', '11:00', 1, 13, 1, NULL), ('2022-09-05', '12:30', 1, 8, 1, NULL), ('2022-09-05', '14:00', 1, 24, 1, NULL), ('2022-09-05', '16:00', 0, 3, 1, NULL),
    ('2022-11-29', '11:00', 2, 15, 1, NULL), ('2022-11-29', '12:30', 2, 1, 1, NULL), ('2022-11-29', '14:30', 2, 19, 1, NULL), ('2022-11-29', '16:30', 2, 8, 1, NULL),
    ('2022-12-13', '10:00', 2, 8, 1, NULL), ('2022-12-13', '12:00', 2, 14, 1, NULL), ('2022-12-13', '13:00', 2, 19, 1, NULL), ('2022-12-13', '17:30', 2, 10, 1, NULL),
    -- Ondontólogo id 2
    ('2022-02-12', '10:00', 1, 15, 2, NULL), ('2022-02-12', '12:00', 1, 14, 2, NULL), ('2022-02-12', '14:00', 1, 21, 2, NULL), ('2022-02-12', '16:00', 0, 23, 2, NULL),
    ('2022-04-25', '10:30', 0, 23, 2, NULL), ('2022-04-25', '11:30', 1, 4, 2, NULL), ('2022-04-25', '13:30', 1, 9, 2, NULL), ('2022-04-25', '15:00', 1, 15, 2, NULL),
    ('2022-06-17', '10:30', 1, 1, 2, NULL), ('2022-06-17', '12:00', 0, 21, 2, NULL), ('2022-06-17', '14:00', 1, 22, 2, NULL), ('2022-06-17', '15:30', 1, 17, 2, NULL),
    ('2022-09-05', '11:00', 0, 14, 2, NULL), ('2022-09-05', '12:30', 1, 1, 2, NULL), ('2022-09-05', '14:00', 1, 20, 2, NULL), ('2022-09-05', '16:00', 1, 4, 2, NULL),
    ('2022-11-29', '11:00', 2, 1, 2, NULL), ('2022-11-29', '12:30', 2, 19, 2, NULL), ('2022-11-29', '14:30', 2, 2, 2, NULL), ('2022-11-29', '16:30', 2, 11, 2, NULL),
    ('2022-12-13', '10:00', 2, 3, 2, NULL), ('2022-12-13', '12:00', 2, 4, 2, NULL), ('2022-12-13', '13:00', 2, 13, 2, NULL), ('2022-12-13', '17:30', 2, 1, 2, NULL),
    -- Ondontólogo id 3
    ('2022-02-12', '10:00', 1, 11, 3, NULL), ('2022-02-12', '12:00', 1, 3, 3, NULL), ('2022-02-12', '14:00', 1, 8, 3, NULL), ('2022-02-12', '16:00', 1, 21, 3, NULL),
    ('2022-04-25', '10:30', 1, 13, 3, NULL), ('2022-04-25', '11:30', 0, 14, 3, NULL), ('2022-04-25', '13:30', 0, 6, 3, NULL), ('2022-04-25', '15:00', 1, 4, 3, NULL),
    ('2022-06-17', '10:30', 1, 14, 3, NULL), ('2022-06-17', '12:00', 1, 25, 3, NULL), ('2022-06-17', '14:00', 1, 24, 3, NULL), ('2022-06-17', '15:30', 0, 16, 3, NULL),
    ('2022-09-05', '11:00', 0, 8, 3, NULL), ('2022-09-05', '12:30', 0, 23, 3, NULL), ('2022-09-05', '14:00', 1, 7, 3, NULL), ('2022-09-05', '16:00', 1, 15, 3, NULL),
    ('2022-11-29', '11:00', 2, 20, 3, NULL), ('2022-11-29', '12:30', 2, 12, 3, NULL), ('2022-11-29', '14:30', 2, 19, 3, NULL), ('2022-11-29', '16:30', 2, 25, 3, NULL),
    ('2022-12-13', '10:00', 2, 4, 3, NULL), ('2022-12-13', '12:00', 2, 5, 3, NULL), ('2022-12-13', '13:00', 2, 14, 3, NULL), ('2022-12-13', '17:30', 2, 16, 3, NULL),
    -- Ondontólogo id 4
    ('2022-02-12', '10:00', 1, 3, 4, NULL), ('2022-02-12', '12:00', 0, 9, 4, NULL), ('2022-02-12', '14:00', 1, 1, 4, NULL), ('2022-02-12', '16:00', 1, 22, 4, NULL),
    ('2022-04-25', '10:30', 1, 18, 4, NULL), ('2022-04-25', '11:30', 0, 20, 4, NULL), ('2022-04-25', '13:30', 1, 9, 4, NULL), ('2022-04-25', '15:00', 1, 11, 4, NULL),
    ('2022-06-17', '10:30', 1, 13, 4, NULL), ('2022-06-17', '12:00', 1, 19, 4, NULL), ('2022-06-17', '14:00', 1, 6, 4, NULL), ('2022-06-17', '15:30', 1, 1, 4, NULL),
    ('2022-09-05', '11:00', 0, 7, 4, NULL), ('2022-09-05', '12:30', 1, 20, 4, NULL), ('2022-09-05', '14:00', 0, 1, 4, NULL), ('2022-09-05', '16:00', 1, 8, 4, NULL),
    ('2022-11-29', '11:00', 2, 18, 4, NULL), ('2022-11-29', '12:30', 2, 12, 4, NULL), ('2022-11-29', '14:30', 2, 16, 4, NULL), ('2022-11-29', '16:30', 2, 20, 4, NULL),
    ('2022-12-13', '10:00', 2, 19, 4, NULL), ('2022-12-13', '12:00', 2, 15, 4, NULL), ('2022-12-13', '13:00', 2, 3, 4, NULL), ('2022-12-13', '17:30', 2, 16, 4, NULL),
    -- Ondontólogo id 5
    ('2022-02-12', '10:00', 0, 24, 5, NULL), ('2022-02-12', '12:00', 1, 2, 5, NULL), ('2022-02-12', '14:00', 1, 12, 5, NULL), ('2022-02-12', '16:00', 1, 4, 5, NULL),
    ('2022-04-25', '10:30', 1, 5, 5, NULL), ('2022-04-25', '11:30', 1, 1, 5, NULL), ('2022-04-25', '13:30', 1, 9, 5, NULL), ('2022-04-25', '15:00', 0, 24, 5, NULL),
    ('2022-06-17', '10:30', 1, 22, 5, NULL), ('2022-06-17', '12:00', 1, 13, 5, NULL), ('2022-06-17', '14:00', 1, 5, 5, NULL), ('2022-06-17', '15:30', 1, 2, 5, NULL),
    ('2022-09-05', '11:00', 1, 4, 5, NULL), ('2022-09-05', '12:30', 1, 7, 5, NULL), ('2022-09-05', '14:00', 1, 5, 5, NULL), ('2022-09-05', '16:00', 1, 6, 5, NULL),
    ('2022-11-29', '11:00', 2, 3, 5, NULL), ('2022-11-29', '12:30', 2, 4, 5, NULL), ('2022-11-29', '14:30', 2, 7, 5, NULL), ('2022-11-29', '16:30', 2, 8, 5, NULL),
    ('2022-12-13', '10:00', 2, 22, 5, NULL), ('2022-12-13', '12:00', 2, 24, 5, NULL), ('2022-12-13', '13:00', 2, 2, 5, NULL), ('2022-12-13', '17:30', 2, 16, 5, NULL),
    -- Ondontólogo id 6
    ('2022-02-12', '10:00', 1, 20, 6, NULL), ('2022-02-12', '12:00', 1, 21, 6, NULL), ('2022-02-12', '14:00', 1, 9, 6, NULL), ('2022-02-12', '16:00', 1, 8, 6, NULL),
    ('2022-04-25', '10:30', 1, 22, 6, NULL), ('2022-04-25', '11:30', 1, 20, 6, NULL), ('2022-04-25', '13:30', 0, 17, 6, NULL), ('2022-04-25', '15:00', 0, 10, 6, NULL),
    ('2022-06-17', '10:30', 1, 7, 6, NULL), ('2022-06-17', '12:00', 0, 8, 6, NULL), ('2022-06-17', '14:00', 1, 18, 6, NULL), ('2022-06-17', '15:30', 0, 3, 6, NULL),
    ('2022-09-05', '11:00', 1, 17, 6, NULL), ('2022-09-05', '12:30', 1, 5, 6, NULL), ('2022-09-05', '14:00', 1, 15, 6, NULL), ('2022-09-05', '16:00', 1, 16, 6, NULL),
    ('2022-11-29', '11:00', 2, 5, 6, NULL), ('2022-11-29', '12:30', 2, 25, 6, NULL), ('2022-11-29', '14:30', 2, 6, 6, NULL), ('2022-11-29', '16:30', 2, 24, 6, NULL),
    ('2022-12-13', '10:00', 2, 22, 6, NULL), ('2022-12-13', '12:00', 2, 19, 6, NULL), ('2022-12-13', '13:00', 2, 7, 6, NULL), ('2022-12-13', '17:30', 2, 25, 6, NULL),
    -- Tratamientos sin odontologo
    ('2022-02-12', '10:30', 1, 17, NULL, 2), ('2022-02-12', '15:00', 1, 10, NULL, 2), 
    ('2022-04-25', '11:00', 1, 10, NULL, 2), ('2022-04-25', '16:30', 1, 22, NULL, 2),
    ('2022-09-05', '12:00', 1, 6, NULL, 2), ('2022-09-05', '14:00', 1, 25, NULL, 2), 
    ('2022-12-13', '10:30', 2, 23, NULL, 2), ('2022-12-13', '16:00', 2, 17, NULL, 2);
    
-- INSERT INTO facturacion 
-- 	()
-- VALUES 
-- 	(),;

INSERT INTO trabajos_laboratorio 
	(id_laboratorio, precio, estado)
VALUES 
	(4, 63000, 1), (2, 50000, 2), (6, 5000, 1), (5, 17000, 1), (6, 46000, 4), (3, 22000, 4),
	(5, 42000, 1), (1, 65000, 1), (1, 25000, 3), (4, 32000, 3), (2, 48000, 3),(4, 61000, 1),
	(6, 49000, 3), (5, 54000, 1), (2, 62000, 2), (4, 22000, 4), (3, 65000, 2),(1, 29000, 4),
	(3, 7000, 4), (4, 11000, 3), (3, 58000, 1), (3, 17000, 2), (1, 11000, 4), (5, 32000, 1),
	(4, 54000, 2), (3, 50000, 4), (4, 6000, 4), (3, 45000, 4), (4, 19000, 3), (3, 29000, 3),
	(2, 51000, 4), (1, 50000, 1), (5, 38000, 3), (4, 43000, 1), (3, 43000, 4), (4, 7000, 1), 
    (6, 30000, 3), (1, 13000, 2), (3, 54000, 2), (2, 46000, 2), (2, 15000, 3), (3, 54000, 4),
    (2, 52000, 2), (5, 51000, 2), (5, 47000, 1), (3, 45000, 2), (6, 7000, 1);

-- INSERT INTO evoluciones 
-- 	(id_tratamiento, id_turno, id_paciente, id_empleado, id_trabajo_laboratorio, id_factura, descripcion)
-- VALUES 
-- 	(7, 1, 19, 1, NULL, NULL, 'Se cementó un perno sobre la pieza 23'),
-- 	(4, 2, 6, 1, 1, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 17'),
-- 	(5, 2, 6, 1, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
-- 	(3, 2, 6, 1, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
-- 	(7, 4, 2, 1, NULL, NULL, 'Se cementó un perno sobre la pieza 25'),
-- 	(1, 4, 2, 1, NULL, NULL, 'Se removió una caries en la pieza 26'),
-- 	(6, 5, 25, 1, 2, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(1, 5, 25, 1, NULL, NULL, 'Se removió una caries en la pieza 27'),
-- 	(5, 5, 25, 1, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
-- 	(7, 6, 19, 1, NULL, NULL, 'Se cementó un perno sobre la pieza 26'),
-- 	(3, 7, 10, 1, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 28'),
-- 	(7, 8, 2, 1, NULL, NULL, 'Se cementó un perno sobre la pieza 26'),
-- 	(7, 10, 16, 1, NULL, NULL, 'Se cementó un perno sobre la pieza 21'),
-- 	(9, 10, 16, 1, 3, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(9, 11, 22, 1, 4, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(3, 11, 22, 1, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 10'),
-- 	(1, 12, 25, 1, NULL, NULL, 'Se removió una caries en la pieza 6'),
-- 	(5, 12, 25, 1, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 31'),
-- 	(6, 13, 13, 1, 5, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(2, 14, 8, 1, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(5, 15, 24, 1, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 7'),
-- 	(4, 15, 24, 1, 6, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 30'),
-- 	(4, 25, 15, 2, 7, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 16'),
-- 	(4, 26, 14, 2, 8, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 32'),
-- 	(9, 27, 21, 2, 9, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(3, 30, 4, 2, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 19'),
-- 	(7, 31, 9, 2, NULL, NULL, 'Se cementó un perno sobre la pieza 21'),
-- 	(8, 32, 15, 2, 10, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 19'),
-- 	(9, 33, 1, 2, 11, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(6, 33, 1, 2, 12, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(10, 35, 22, 2, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(3, 35, 22, 2, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 3'),
-- 	(1, 35, 22, 2, NULL, NULL, 'Se removió una caries en la pieza 24'),
-- 	(9, 36, 17, 2, 13, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(9, 38, 1, 2, 14, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(6, 39, 20, 2, 15, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(9, 39, 20, 2, 16, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(5, 39, 20, 2, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 20'),
-- 	(3, 40, 4, 2, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 1'),
-- 	(9, 40, 4, 2, 17, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(10, 40, 4, 2, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(8, 49, 11, 3, 18, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 17'),
-- 	(2, 49, 11, 3, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(8, 50, 3, 3, 19, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 20'),
-- 	(6, 51, 8, 3, 20, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(10, 52, 21, 3, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(9, 53, 13, 3, 21, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(1, 53, 13, 3, NULL, NULL, 'Se removió una caries en la pieza 8'),
-- 	(10, 53, 13, 3, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(7, 56, 4, 3, NULL, NULL, 'Se cementó un perno sobre la pieza 22'),
-- 	(3, 57, 14, 3, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 18'),
-- 	(10, 57, 14, 3, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(8, 58, 25, 3, 22, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 27'),
-- 	(2, 58, 25, 3, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(7, 58, 25, 3, NULL, NULL, 'Se cementó un perno sobre la pieza 8'),
-- 	(7, 59, 24, 3, NULL, NULL, 'Se cementó un perno sobre la pieza 12'),
-- 	(4, 63, 7, 3, 23, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
-- 	(9, 64, 15, 3, 24, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(6, 73, 3, 4, 25, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(6, 75, 1, 4, 26, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(10, 76, 22, 4, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(4, 77, 18, 4, 27, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 19'),
-- 	(8, 79, 9, 4, 28, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 4'),
-- 	(6, 80, 11, 4, 29, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(2, 81, 13, 4, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(4, 82, 19, 4, 30, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 3'),
-- 	(9, 83, 6, 4, 31, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(5, 83, 6, 4, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 6'),
-- 	(2, 84, 1, 4, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(7, 86, 20, 4, NULL, NULL, 'Se cementó un perno sobre la pieza 28'),
-- 	(2, 88, 8, 4, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(8, 98, 2, 5, 32, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 11'),
-- 	(6, 98, 2, 5, 33, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(1, 98, 2, 5, NULL, NULL, 'Se removió una caries en la pieza 4'),
-- 	(6, 99, 12, 5, 34, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(10, 100, 4, 5, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(4, 101, 5, 5, 35, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 12'),
-- 	(5, 102, 1, 5, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 32'),
-- 	(3, 103, 9, 5, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 31'),
-- 	(4, 105, 22, 5, 36, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 26'),
-- 	(2, 105, 22, 5, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(10, 106, 13, 5, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(6, 107, 5, 5, 37, NULL, 'Se inició le evaluación del estado de la boca para iniciar un tratamiento de corrección de dentadura por alineadores'),
-- 	(1, 107, 5, 5, NULL, NULL, 'Se removió una caries en la pieza 32'),
-- 	(7, 108, 2, 5, NULL, NULL, 'Se cementó un perno sobre la pieza 26'),
-- 	(3, 109, 4, 5, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 30'),
-- 	(10, 110, 7, 5, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(4, 110, 7, 5, 38, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 15'),
-- 	(5, 111, 5, 5, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 2'),
-- 	(3, 111, 5, 5, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 2'),
-- 	(1, 111, 5, 5, NULL, NULL, 'Se removió una caries en la pieza 21'),
-- 	(4, 112, 6, 5, 39, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 21'),
-- 	(2, 121, 20, 6, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(7, 121, 20, 6, NULL, NULL, 'Se cementó un perno sobre la pieza 31'),
-- 	(5, 121, 20, 6, NULL, NULL, 'Se realizó un tratamiento de conducto debido a un nervio comprometido por infección en la pieza 18'),
-- 	(9, 122, 21, 6, 40, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(10, 123, 9, 6, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(7, 124, 8, 6, NULL, NULL, 'Se cementó un perno sobre la pieza 17'),
-- 	(3, 125, 22, 6, NULL, NULL, 'Se colocó un implante de titanio luego de una cirugía en la pieza 12'),
-- 	(9, 126, 20, 6, 41, NULL, 'Se le preparó una placa miorrelajante a la paciente debido a bruxismo'),
-- 	(4, 129, 7, 6, 42, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 11'),
-- 	(2, 131, 18, 6, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(10, 133, 17, 6, NULL, NULL, 'Se realizó una limpieza completa con ultrasonido, removiendo sarro acumulado'),
-- 	(8, 133, 17, 6, 43, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 15'),
-- 	(4, 134, 5, 6, 44, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 6'),
-- 	(8, 134, 5, 6, 45, NULL, 'Se colocó un implante de porcelana sobre el perno de la pieza 14'),
-- 	(4, 135, 15, 6, 46, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 13'),
-- 	(4, 136, 16, 6, 47, NULL, 'Se colocó y atornilló un implante de porcelana sobre el implante colocado en la pieza 5'),
-- 	(2, 145, 17, 13, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(2, 146, 10, 13, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(2, 147, 10, 12, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(2, 148, 22, 13, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(2, 149, 6, 9, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente'),
-- 	(2, 150, 25, 12, NULL, NULL, 'Se realizó una radiografía panorámica de la boca del paciente');