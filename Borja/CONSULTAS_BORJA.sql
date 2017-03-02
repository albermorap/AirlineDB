/* 1)	Obtén en una vista los diferentes vuelos que hay de un lugar 'X' a otro lugar 'Y' 
para una fecha concreta solicitada por un cliente. Debe de ser un vuelo que se vaya a efectuar
 (que no esté en curso, averiado, retrasado ni cancelado) para que tal cliente pueda comprarse uno o varios billetes. */

 CREATE OR REPLACE VIEW BORJA1
 AS  SELECT ID AS "ID VUELO", ORIGEN, DESTINO,
   TO_CHAR(FECHA_SALIDA, 'HH:MI:SS') AS "HORA SALIDA",                      
   TO_CHAR(FECHA_LLEGADA, 'HH:MI:SS') AS "HORA LLEGADA"
   FROM VUELOS_TAB
   WHERE ORIGEN='ESP' AND DESTINO='ITA'  AND     
   TO_CHAR(FECHA_SALIDA, 'DD/MM/YYYY')= '27/03/2014' AND   
   ESTADO='D';

   /* 2)Obtén con una consulta SELECT el equipaje relacionado con un vuelo específico (por ejemplo con el vuelo con ID 1) 
   y guarda el resultado en una vista.
   */
 
   CREATE OR REPLACE VIEW BORJA2
   AS SELECT B.EQUIPAJE
   FROM VUELOS_TAB V,BILLETES_TAB B
   WHERE REF(V)=B.VUELO AND V.ID='1';
   

 /*3)	 Número de billetes que ha comprado cada usuario registrado.*/

/*CREATE OR REPLACE VIEW BORJA3 AS*/
SELECT DEREF(CLIENTE).NOMBRE "CLIENTE", DEREF(CLIENTE).DNI "DNI", COUNT(*) "BILLETES COMPRADOS"
FROM BILLETES_TAB B
GROUP BY DEREF(CLIENTE).DNI,DEREF(CLIENTE).NOMBRE;


 /*4)	 Número de billetes que ha comprado un usuario registrado, por ejemplo el usuario con dni '10000002N'.*/

 /*CREATE OR REPLACE VIEW BORJA4 AS*/
SELECT DEREF(CLIENTE).NOMBRE "CLIENTE", DEREF(CLIENTE).DNI "DNI", COUNT(*) "BILLETES COMPRADOS"
FROM BILLETES_TAB B
WHERE  DEREF(CLIENTE).DNI = '10000002N'
GROUP BY DEREF(CLIENTE).DNI,DEREF(CLIENTE).NOMBRE;


/*5)	Porcentaje de llenado de los vuelos:*/

/*CREATE OR REPLACE VIEW BORJA5 AS*/
SELECT V.ID "ID VUELO",DEREF(AVION).CAPACIDAD "CAPACIDAD",COUNT(B.ID) "ASIENTOS OCUPADOS", 
(COUNT(B.ID)/(DEREF(AVION).CAPACIDAD)*100)||' %' "PORCENTAJE DE OCUPACIÓN"
FROM BILLETES_TAB B, VUELOS_TAB V
WHERE DEREF(AVION).MATRICULA=DEREF(AVION).MATRICULA AND V.ID=DEREF(VUELO).ID
GROUP BY V.ID,DEREF(AVION).CAPACIDAD;

   