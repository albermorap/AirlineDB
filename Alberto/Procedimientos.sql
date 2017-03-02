/*PROCEDIMIENTO 1*/
CREATE OR REPLACE PROCEDURE Cancelar_vuelo
  ( p_vuelo IN VUELOS_TAB.ID%TYPE,
    p_admin IN EMPLEADOS_TAB.DNI%TYPE,
    p_causa IN VARCHAR2)
AS
  PERMISO_DENEGADO EXCEPTION;
  VUELO_NO_CANCELAR EXCEPTION;
  DESCRIPCION_LARGA EXCEPTION;
  PRAGMA EXCEPTION_INIT (DESCRIPCION_LARGA, -12899);
  
  CURSOR billetes_anulados IS
    SELECT ID,ASIENTO,PRECIO,IVA,CLIENTE
    FROM BILLETES_TAB
    WHERE DEREF(VUELO).ID = p_vuelo AND ANULADO = 'NO'
    FOR UPDATE OF ANULADO;
    
  TYPE vuelo IS RECORD(
    ESTADO VUELOS_TAB.ESTADO%TYPE,
    ADMINISTRADOR VUELOS_TAB.ADMINISTRADOR%TYPE
  );
  
  reg vuelo;
  total NUMBER := 0;
  v_dni CLIENTES_TAB.DNI%TYPE;
BEGIN
  SELECT ESTADO,ADMINISTRADOR INTO reg
  FROM VUELOS_TAB
  WHERE ID = p_vuelo;

  SELECT DEREF(reg.ADMINISTRADOR).DNI INTO v_dni FROM DUAL;
  IF(p_admin <> v_dni) THEN
    RAISE PERMISO_DENEGADO;
  END IF;
  
  IF(reg.ESTADO = 'C' OR reg.ESTADO = 'EC' OR reg.ESTADO = 'E') THEN
    RAISE VUELO_NO_CANCELAR;
  END IF;

  UPDATE VUELOS_TAB
  SET ESTADO = 'C'
  WHERE ID = p_vuelo;
  
  INSERT INTO TABLE(SELECT INCIDENCIAS FROM VUELOS_TAB WHERE ID = p_vuelo) VALUES
  (TO_CHAR(SINCIDENCIAS.NEXTVAL),'C',p_causa,SYSDATE);
  
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('                    BILLETES ANULADOS');
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('BILLETE'||'      '||'ASIENTO'||'      '||'PASAJERO'||'      '||'PRECIO'||'          '||'IVA');
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
  FOR b_anulado IN billetes_anulados LOOP
	SELECT DEREF(b_anulado.CLIENTE).DNI INTO v_dni FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(b_anulado.ID||'    '||b_anulado.ASIENTO||'         '||v_dni||'     '||b_anulado.PRECIO||' €        '||b_anulado.IVA||' %');
	
    total := total + b_anulado.PRECIO*(1+(b_anulado.IVA/100));
	
    UPDATE BILLETES_TAB
	SET ANULADO = 'SI' 
	WHERE CURRENT OF billetes_anulados;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('IMPORTE TOTAL MÁS IVA: '||total||' €');
  
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('¡¡CANCELACIÓN DEL VUELO CON ÉXITO!!');
  
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El vuelo '||p_vuelo||' no existe en el sistema.');
      WHEN PERMISO_DENEGADO THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El empleado '||p_admin||' no tiene persmiso para modificar el vuelo '||p_vuelo||'.');
      WHEN VUELO_NO_CANCELAR THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El vuelo '||p_vuelo||' no puede ser cancelado.');
      WHEN DESCRIPCION_LARGA THEN
        RAISE_APPLICATION_ERROR(-20000, 'La descripción de la causa de la cancelación del vuelo es demasiado larga.');
END;

/

/*FUNCIÓN 2*/
CREATE OR REPLACE FUNCTION Comprar_billete
  ( p_asiento IN  BILLETES_TAB.ASIENTO%TYPE,
    p_iva     IN  BILLETES_TAB.IVA%TYPE,
    p_factura IN OUT FACTURAS_TAB.ID%TYPE,
    p_vuelo   IN  VUELOS_TAB.ID%TYPE,
    p_clase   IN  CLASES_BILLETE_TAB.NOMBRE%TYPE,
	p_dni     IN  CLIENTES_TAB.DNI%TYPE,
    p_nombre  IN  CLIENTES_TAB.NOMBRE%TYPE DEFAULT 'desconocido',
    p_apelli  IN  CLIENTES_TAB.APELLIDOS%TYPE DEFAULT 'desconocido',
    p_email   IN  CLIENTES_TAB.EMAIL%TYPE DEFAULT 'desconocido@dominio.com',
	p_tarjeta IN  CHAR)
RETURN BILLETE_OBJ
AS
	pasajero 			CLIENTE_OBJ;
	num 				NUMBER;
	v_billeteRef 		REF BILLETE_OBJ;
	v_facturaRef 		REF FACTURA_OBJ;
	v_estado 			VUELOS_TAB.ESTADO%TYPE;
	v_billete 			BILLETE_OBJ;
	VUELO_NO_DISPONIBLE EXCEPTION;
BEGIN

	SELECT ESTADO
	INTO v_estado
	FROM VUELOS_TAB
	WHERE ID = p_vuelo;
  
	IF(v_estado <> 'D' AND v_estado <> 'R') THEN
		RAISE VUELO_NO_DISPONIBLE;
	END IF;
  
	/* Creamos el cliente */
	BEGIN
		SELECT VALUE(C) INTO pasajero
		FROM CLIENTES_TAB C
		WHERE C.DNI = p_dni;
    
		DBMS_OUTPUT.PUT_LINE('CLIENTE: '||pasajero.NOMBRE||' '||pasajero.APELLIDOS);
    
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			INSERT INTO CLIENTES_TAB(DNI,NOMBRE,APELLIDOS,EMAIL,BILLETES) VALUES(p_dni,p_nombre,p_apelli,p_email,BILLETE_LIST());
			DBMS_OUTPUT.PUT_LINE('NUEVO CLIENTE: '||p_nombre||' '||p_apelli);
	END;
	
	/* FACTURA */
	IF (p_factura IS NOT NULL) THEN
		SELECT COUNT(*) INTO num
		FROM FACTURAS_TAB
		WHERE ID = p_factura;
    
		IF(num = 0) THEN
			INSERT INTO FACTURAS_TAB F VALUES (FACTURA_OBJ(TO_CHAR(SYSDATE),p_dni,p_tarjeta))
			RETURNING REF(F) INTO v_facturaRef;
			
			SELECT DEREF(v_facturaRef).ID INTO p_factura FROM DUAL;
		END IF;
	ELSE
		INSERT INTO FACTURAS_TAB F VALUES (FACTURA_OBJ(TO_CHAR(SYSDATE),p_dni,p_tarjeta))
		RETURNING REF(F) INTO v_facturaRef;
		
		SELECT DEREF(v_facturaRef).ID INTO p_factura FROM DUAL;
	END IF;
	
	INSERT INTO BILLETES_TAB B VALUES(BILLETE_OBJ(p_asiento,'NO',p_iva,p_vuelo,p_clase,p_dni,p_factura))
	RETURNING REF(B) INTO v_billeteRef;
	
	INSERT INTO TABLE (SELECT BILLETES FROM CLIENTES_TAB WHERE DNI = p_dni) VALUES(v_billeteRef);
  
	SELECT DEREF(v_billeteRef) INTO v_billete FROM DUAL;
  
	RETURN v_billete;
  
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('No existe el vuelo '||p_vuelo||'. Imposible comprar billete.');
			RETURN null;
		WHEN VUELO_NO_DISPONIBLE THEN
			DBMS_OUTPUT.PUT_LINE('No se permite la compra de billetes para el vuelo '||p_vuelo||'.');
			RETURN null;
END;

/

/*PROCEDIMIENTO 2*/
CREATE OR REPLACE PROCEDURE Calcular_salario_extra
	(limiteHorasMensuales NUMBER)
AS
	CURSOR personal_vuelo IS
		SELECT * FROM EMPLEADOS_TAB WHERE CARGO IN ('PILOTO','AZAFATA');
	CURSOR vuelos IS
		SELECT * FROM VUELOS_TAB V WHERE V.ESTADO = 'E' AND
		EXTRACT(MONTH FROM FECHA_SALIDA) = TO_CHAR(SYSDATE, 'MM') AND 
		EXTRACT(YEAR FROM FECHA_SALIDA) = TO_CHAR(SYSDATE, 'YYYY');
	num				NUMBER;
	horas          	NUMBER(5,2);
	salarioextra 	NUMBER(6,2);
    
BEGIN
	DBMS_OUTPUT.PUT_LINE('DNI        CARGO      SALARIO    HORAS EXTRA  SALARIO TOTAL');
	DBMS_OUTPUT.PUT_LINE('---------  ---------  ---------  -----------  -------------');
	
	FOR empleado IN personal_vuelo LOOP
		horas:=0;
		salarioextra:=0;
		
		FOR vuelo IN vuelos LOOP
			num:=0;
			  
			SELECT COUNT(*) INTO num
			FROM TABLE(vuelo.PERSONAL)
			WHERE DEREF(COLUMN_VALUE).DNI = empleado.DNI;
			  
			IF (num <> 0) THEN
				horas:=horas + ((vuelo.FECHA_LLEGADA - vuelo.FECHA_SALIDA) * 24);
			END IF;
		END LOOP;
		
		IF (horas > limiteHorasMensuales) THEN
			salarioextra := (horas - limiteHorasMensuales) * (empleado.SALARIO * 0.015);
			
			DBMS_OUTPUT.PUT_LINE(empleado.DNI ||'  '|| empleado.CARGO ||'     '||
				empleado.SALARIO ||'       '|| (horas - limiteHorasMensuales) ||'      '|| (empleado.SALARIO + salarioextra));
		ELSE
			DBMS_OUTPUT.PUT_LINE(empleado.DNI ||'  '|| empleado.CARGO ||'     '||
				empleado.SALARIO ||'   000,00      '|| (empleado.SALARIO + salarioextra));
		END IF;
		
	END LOOP;
END Calcular_salario_extra;