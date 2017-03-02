/*INSERCCIONES*/

INSERT INTO CLIENTES_TAB VALUES
('10000001M','ESP000000A','Pepe','Nuñez Rodriguez','0034677782889','pepe@gmail.com','c/calle1 23,2ºA','Albacete','11111','España','1234',null,BILLETE_LIST());
INSERT INTO CLIENTES_TAB VALUES
('10000002N','ARG111111B','Juan','Martinez Perez','0031677782888','juan@hotmail.com','c/calle2 23,2ºB','Buenos Aries','22222','Argentina','1234',null,BILLETE_LIST());
INSERT INTO CLIENTES_TAB VALUES
('10000003F','BRA222222C','Carlos','Placente Mora','0031677782883','charly@yahoo.es','c/calle3 23,2ºC','Brasilia','33333','Brasil','1234',null,BILLETE_LIST());

UPDATE CLIENTES_TAB
SET TARJETAS = TARJETA_ARRAY(TARJETA_OBJ('123456789','Alberto','02/05/2016','123'))
WHERE DNI='10000001M';


INSERT INTO FACTURAS_TAB VALUES
(FACTURA_OBJ('23/06/2013','10000001M','123456789'));
INSERT INTO FACTURAS_TAB VALUES
(FACTURA_OBJ('23/06/2012','10000002N',null));
INSERT INTO FACTURAS_TAB VALUES
(FACTURA_OBJ('03/02/2013','10000003F',null));


INSERT INTO EMPLEADOS_TAB VALUES
('20000001N','Eustaquio','Gomez Sanchez','0034677782999','eusta@hotmail.com','c/calle2 23,2ºB','Getafe','02003','España','ADMINISTRADOR',7000.33);
INSERT INTO EMPLEADOS_TAB VALUES
('20000002A','Pepelu','Yosako Mimoto','0034612329909','yosako@hotmail.com','c/calle55 23,2ºB','Pekin','00002','China','ADMINISTRADOR',6700.33);
INSERT INTO EMPLEADOS_TAB VALUES
('20000003F','Martin','Romero Diaz','0034677782993','mrd@gmail.es','c/calle3 23,2ºC','Madrid','03003','España','PILOTO',3000.33);
INSERT INTO EMPLEADOS_TAB VALUES
('20000004W','Jose','Tolosa Garcia','0034677712343','tolosa@yahoo.es','c/calle7 29,bajo','Albacete','02200','España','PILOTO',3500);
INSERT INTO EMPLEADOS_TAB VALUES
('20000005F','Julian','Martinez Fonseca','0123690823043','fonse@yahoo.es','c/calle13 23,bajo','Guadalajara','09999','México','PILOTO',2000.95);
INSERT INTO EMPLEADOS_TAB VALUES
('20000006T','Junior','Mora Tete','0034676128900','moratete@gmail.com','c/calle11 3,5ºC','Rio de Janeiro','12347','Brasil','AZAFATA',3230.99);
INSERT INTO EMPLEADOS_TAB VALUES
('20000007G','Pablo','Martinez Mondejar','0034767671234','pablo@yahoo.es','c/calle7 2,4ºC','Mostoles','03005','España','AZAFATA',1120.99);
INSERT INTO EMPLEADOS_TAB VALUES
('20000008S','Carla','Nuñez Gomez','0034676456234','carla@hotmail.es','c/calle9 2,2ºC','Malaga','45435','España','AZAFATA',1890.99);
INSERT INTO EMPLEADOS_TAB VALUES
('20000009T','Maria Santiago','Mora Soler','0034676781234','mariasantiago@yahoo.es','c/calle1 2,9ºC','Lisboa','00123','Portugal','AZAFATA',1999.99);
INSERT INTO EMPLEADOS_TAB VALUES
('20000010S','Alberta','Mora Plata','0034676781236','moraplata@yahoo.es','c/calle2 2,4ºC','Almeria','66666','España','AZAFATA',2000.99);
INSERT INTO EMPLEADOS_TAB VALUES
('20000040S','Juan','López Lucas','0034676781236','juanlopez@yahoo.es','c/calle4 2,4ºC','Madrid','12345','España','TAQUILLA',2000.99);


INSERT INTO AVIONES_TAB VALUES
('ECabc',300,TO_DATE('23/02/2015 10:35:36', 'DD/MM/YY HH24:MI:SS'),'SI');
INSERT INTO AVIONES_TAB VALUES
('ECefg',200,TO_DATE('17/02/1994 19:56:14', 'DD/MM/YY HH24:MI:SS'),'NO');
INSERT INTO AVIONES_TAB VALUES
('ECsdf',100,TO_DATE('14/02/2015 12:32:06', 'DD/MM/YY HH24:MI:SS'),'SI');
INSERT INTO AVIONES_TAB VALUES
('CCasd',400,TO_DATE('13/02/2010 09:08:07', 'DD/MM/YY HH24:MI:SS'),'NO');


INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('EC','ESP','ITA','20/05/2015 10:30:00','20/05/2015 12:30:00',100,'ECabc','20000001N'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('E','ESP','NOR','12/05/2015 15:30:00','12/05/2015 19:58:00',100,'ECabc','20000001N'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('E','ESP','ENG','03/05/2015 07:05:00','03/05/2015 10:00:00',150,'ECefg','20000001N'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('D','ESP','ITA','27/03/2017 11:11:00','27/03/2017 14:36:00',150,'ECsdf','20000002A'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('R','ESP','NOR','25/03/2015 03:45:00','25/05/2015 09:23:00',140,'ECsdf','20000002A'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('D','ESP','FRA','20/05/2011 22:56:00','20/05/2011 23:58:00',200,'ECabc','20000001N'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('C','ESP','ITA','10/03/2013 14:22:00','10/03/2013 17:01:00',130,'ECabc','20000001N'));
INSERT INTO VUELOS_TAB VALUES
(VUELO_OBJ('D','ESP','FRA','27/06/2015 14:22:00','27/06/2015 16:01:00',150,'ECabc','20000001N'));



/* PERSONAL DE VUELO */

/*INSERT INTO TABLE (SELECT PERSONAL FROM VUELOS_TAB WHERE ID = '1')
	SELECT REF(E) FROM EMPLEADOS_TAB E WHERE E.DNI = '20000003F';*/
DECLARE
	num NUMBER; /* Es necesario al ser una función */
BEGIN
	num:=VUELO_OBJ.Asignar_empleado('20000003F','1');
	num:=VUELO_OBJ.Asignar_empleado('20000005F','1');
	num:=VUELO_OBJ.Asignar_empleado('20000006T','1');
	num:=VUELO_OBJ.Asignar_empleado('20000007G','1');
	num:=VUELO_OBJ.Asignar_empleado('20000008S','1');

	num:=VUELO_OBJ.Asignar_empleado('20000003F','12');
	num:=VUELO_OBJ.Asignar_empleado('20000004W','12');
	num:=VUELO_OBJ.Asignar_empleado('20000006T','12');
	num:=VUELO_OBJ.Asignar_empleado('20000009T','12');
	num:=VUELO_OBJ.Asignar_empleado('20000010S','12');

	num:=VUELO_OBJ.Asignar_empleado('20000005F','23');
	num:=VUELO_OBJ.Asignar_empleado('20000004W','23');
	num:=VUELO_OBJ.Asignar_empleado('20000008S','23');
	num:=VUELO_OBJ.Asignar_empleado('20000009T','23');
	num:=VUELO_OBJ.Asignar_empleado('20000010S','23');

	num:=VUELO_OBJ.Asignar_empleado('20000003F','34');
	num:=VUELO_OBJ.Asignar_empleado('20000004W','34');
	num:=VUELO_OBJ.Asignar_empleado('20000008S','34');
	num:=VUELO_OBJ.Asignar_empleado('20000007G','34');
	num:=VUELO_OBJ.Asignar_empleado('20000010S','34');

	num:=VUELO_OBJ.Asignar_empleado('20000005F','45');
	num:=VUELO_OBJ.Asignar_empleado('20000004W','45');
	num:=VUELO_OBJ.Asignar_empleado('20000006T','45');
	num:=VUELO_OBJ.Asignar_empleado('20000010S','45');
	num:=VUELO_OBJ.Asignar_empleado('20000009T','45');

	num:=VUELO_OBJ.Asignar_empleado('20000005F','56');
	num:=VUELO_OBJ.Asignar_empleado('20000003F','56');
	num:=VUELO_OBJ.Asignar_empleado('20000006T','56');
	num:=VUELO_OBJ.Asignar_empleado('20000010S','56');
	num:=VUELO_OBJ.Asignar_empleado('20000009T','56');
END;

/

/* CLASES BILLETE */
INSERT INTO CLASES_BILLETE_TAB VALUES('BUSINESS',1.5,40,1.5);
INSERT INTO CLASES_BILLETE_TAB VALUES('TARIFA_REDUCIDA',0.75,10,2);
INSERT INTO CLASES_BILLETE_TAB VALUES('TURISTA',1,25,0.75);


/* BILLETES */
INSERT INTO BILLETES_TAB VALUES
(BILLETE_OBJ('22A','NO',10,'1','TURISTA','10000001M','1'));
INSERT INTO BILLETES_TAB VALUES
(BILLETE_OBJ('22B','NO',16,'1','TURISTA','10000002N','1'));
INSERT INTO BILLETES_TAB VALUES
(BILLETE_OBJ('30C','NO',16,'12','BUSINESS','10000002N','6'));
INSERT INTO BILLETES_TAB VALUES
(BILLETE_OBJ('05D','NO',16,'23','TARIFA_REDUCIDA','10000003F','11'));
INSERT INTO BILLETES_TAB VALUES
(BILLETE_OBJ('10C','NO',16,'56','TURISTA','10000002N','6'));

/* EQUIPAJES */
DECLARE
	num NUMBER; /* Es necesario al ser una función */
BEGIN
	num:=BILLETE_OBJ.Asignar_equipaje('1',2,'NO',24);
	num:=BILLETE_OBJ.Asignar_equipaje('31',3,'SI',20);
	num:=BILLETE_OBJ.Asignar_equipaje('46',2,'NO',20);
	num:=BILLETE_OBJ.Asignar_equipaje('16',4,'NO',15);
END;

/

/* INCIDENDICIAS */
INSERT INTO TABLE (SELECT INCIDENCIAS FROM VUELOS_TAB WHERE ID = 45) VALUES
(TO_CHAR(SINCIDENCIAS.NEXTVAL),'R','Retraso en vuelo a causa de las grandes precipitaciones.',TO_DATE('23/02/2014 02:30:15', 'DD/MM/YY HH24:MI:SS'));
INSERT INTO TABLE (SELECT INCIDENCIAS FROM VUELOS_TAB WHERE ID = 12) VALUES
(TO_CHAR(SINCIDENCIAS.NEXTVAL),'AV','AverIa en el motor derecho.',TO_DATE('14/05/2013 23:36:58', 'DD/MM/YY HH24:MI:SS'));
INSERT INTO TABLE (SELECT INCIDENCIAS FROM VUELOS_TAB WHERE ID = 12) VALUES
(TO_CHAR(SINCIDENCIAS.NEXTVAL),'AV','Pinchazo en rueda de aterrizaje.',TO_DATE('15/05/2013 12:36:58', 'DD/MM/YY HH24:MI:SS'));
INSERT INTO TABLE (SELECT INCIDENCIAS FROM VUELOS_TAB WHERE ID = 45) VALUES
(TO_CHAR(SINCIDENCIAS.NEXTVAL),'AV','Averia en el ala.',TO_DATE('22/02/2014 23:36:58', 'DD/MM/YY HH24:MI:SS'));

/* RECLAMACIONES */
DECLARE
	num NUMBER; /* Es necesario al ser una función */
BEGIN
	num:=BILLETE_OBJ.Crear_Reclamacion('31',RECLAMACION_OBJ('PERDIDA','Maleta verde perdida.','01/12/2013 14:05:25','20000040S'));
	num:=BILLETE_OBJ.Crear_Reclamacion('31',RECLAMACION_OBJ('DAÑO','Se ha encontrado la maleta pero tenIa daños irreversibles','23/12/2013 12:25:14','20000040S'));
	num:=BILLETE_OBJ.Crear_Reclamacion('16',RECLAMACION_OBJ('PERDIDA','Maleta de Nike en paradero desconocido','20/03/2014 10:25:25','20000040S'));
END;