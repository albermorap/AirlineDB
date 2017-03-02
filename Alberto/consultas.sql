-- 1. Número de averías que han sufrido los aviones junto a la fecha de la última
-- revisión de los mismos por si es necesaria una nueva revisión.
DECLARE
  CURSOR aviones IS
    SELECT * FROM AVIONES_TAB;
  CURSOR incidencias (matricula CHAR) IS
    SELECT V.INCIDENCIAS 
    FROM VUELOS_TAB V, AVIONES_TAB A
    WHERE A.MATRICULA = matricula AND V.AVION = REF(A);
  num           NUMBER;
  cont          NUMBER;
  v_incidencia 	VUELOS_TAB.INCIDENCIAS%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('MATRICULA  ULTIMA REVICION       NUMERO DE AVERIAS');
  
  FOR avion IN aviones LOOP
    cont:=0;
    OPEN incidencias(avion.matricula);
    
    FETCH incidencias INTO v_incidencia;
    WHILE incidencias%FOUND LOOP
      num:=0;
      
      SELECT COUNT(*) INTO num
      FROM TABLE(v_incidencia)
      WHERE TIPO = 'AV';
      
      cont := cont + num;
      
      FETCH incidencias INTO v_incidencia;
    END LOOP;
    
    CLOSE incidencias;
    
    DBMS_OUTPUT.PUT_LINE(avion.MATRICULA||avion.ULTIMA_REV||'   '||cont);
  END LOOP;
END;

-- 2. Peso medio del equipaje que llevan los clientes en todos sus vuelos. Si no lleva equipaje el peso es 0, para ello usamos NVL().
CREATE OR REPLACE VIEW ALBERTO1 AS
SELECT C.DNI,C.NOMBRE,C.APELLIDOS,SUM(NVL(B.EQUIPAJE.PESO_TOTAL,0))/COUNT(*) "PESO MEDIO"
FROM CLIENTES_TAB C, BILLETES_TAB B
WHERE REF(C) = B.CLIENTE
GROUP BY C.DNI,C.NOMBRE,C.APELLIDOS;

-- 3. Horas de vuelo realizadas por los pilotos teniendo sólo en cuenta los vuelos efectuados. Las horas se mostrarán en formato decimal.
DECLARE
  CURSOR pilotos IS
    SELECT * FROM EMPLEADOS_TAB WHERE CARGO = 'PILOTO';
  CURSOR vuelos IS
    SELECT * FROM VUELOS_TAB V WHERE V.ESTADO = 'E';
  num           NUMBER;
  horas          NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('DNI        NOMBRE   NUMERO DE HORAS PILOTADAS');
  
  FOR piloto IN pilotos LOOP
    horas:=0;
    
    FOR vuelo IN vuelos LOOP
      num:=0;
      
      SELECT COUNT(*) INTO num
      FROM TABLE(vuelo.PERSONAL)
      WHERE DEREF(COLUMN_VALUE).DNI = piloto.DNI;
      
      IF (num <> 0) THEN
        horas:=horas + ((vuelo.FECHA_LLEGADA - vuelo.FECHA_SALIDA) * 24);
      END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(piloto.DNI||'  '||piloto.NOMBRE||'     '||horas);
  END LOOP;
END;

--	4. Obtén los empleados asignados al vuelo con ID = X, en este caso 1
CREATE OR REPLACE VIEW ALBERTO3 (DNI, NOMBRE, APELLIDOS, CARGO) AS
SELECT DEREF(COLUMN_VALUE).DNI, DEREF(COLUMN_VALUE).NOMBRE,
		DEREF(COLUMN_VALUE).APELLIDOS, DEREF(COLUMN_VALUE).CARGO
FROM TABLE (SELECT PERSONAL FROM VUELOS_TAB WHERE ID = 1)
UNION
SELECT DEREF(ADMINISTRADOR).DNI, DEREF(ADMINISTRADOR).NOMBRE,
		DEREF(ADMINISTRADOR).APELLIDOS, DEREF(ADMINISTRADOR).CARGO
FROM VUELOS_TAB
WHERE ID = 1;

-- 5. Obtén los vuelos que aún no se han realizado, estan en estado disponible y disponen de asientos libres
CREATE OR REPLACE VIEW ALBERTO2 AS
SELECT V.ID "ID VUELO", COUNT(B.ID) "ASIENTOS OCUPADOS", A.CAPACIDAD , (A.CAPACIDAD - COUNT(B.ID)) AS "ASIENTOS LIBRES"
FROM AVIONES_TAB A, VUELOS_TAB V, BILLETES_TAB B
WHERE B.VUELO = REF(V) AND V.AVION = REF(A) AND V.FECHA_SALIDA > SYSDATE AND V.ESTADO = 'D'
GROUP BY V.ID, A.CAPACIDAD
HAVING COUNT(B.ID) < A.CAPACIDAD;

-- 6. Número de reclamaciones por vuelo gestionado por empleado	----------------------NO FUNCIONA -------------------
CREATE VIEW ALBERTO3 AS
SELECT E.DNI,E.NOMBRE,E.APELLIDOS,E.CARGO,V.ID VUELO,COUNT(*) "NÚMERO DE RECLAMACIONES"
FROM RECLAMACIONES R,EMPLEADOS E,EQUIPAJE EQ,BILLETES B,VUELOS V
WHERE E.DNI=R.EMPLEADO AND R.EQUIPAJE=EQ.ID AND EQ.BILLETE=B.ID AND B.VUELO=V.ID
GROUP BY E.DNI,E.NOMBRE,E.APELLIDOS,E.CARGO,V.ID;