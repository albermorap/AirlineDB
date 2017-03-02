CREATE OR REPLACE VIEW VISTA_PERSONAL AS
SELECT * FROM VUELOS_TAB;

CREATE OR REPLACE TRIGGER Comprueba_personal_vuelo
INSTEAD OF INSERT ON NESTED TABLE PERSONAL OF VISTA_PERSONAL
FOR EACH ROW
DECLARE
	num 	NUMBER;
	cargo 	EMPLEADOS_TAB.CARGO%TYPE;
BEGIN
	SELECT COUNT(*) INTO num
	FROM TABLE (SELECT PERSONAL FROM VUELOS_TAB WHERE ID = :PARENT.ID)
	WHERE COLUMN_VALUE = :NEW.COLUMN_VALUE;
	
	IF (num <> 0) THEN
		RAISE_APPLICATION_ERROR(-20001, 'El empleado ya esta asignado a este vuelo');
	END IF;
	
    SELECT CARGO INTO cargo
    FROM EMPLEADOS_TAB
    WHERE DNI = DEREF(:NEW.COLUMN_VALUE).DNI;
    
    IF (cargo <> 'PILOTO' AND cargo <> 'AZAFATA') THEN
      RAISE_APPLICATION_ERROR(-20002, 'El empleado no tiene un cargo adecuado para la asignacion');
    END IF;
	
	INSERT INTO TABLE(SELECT PERSONAL FROM VUELOS_TAB WHERE ID = :PARENT.ID) VALUES (:NEW.COLUMN_VALUE);
	
	EXCEPTION
    WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20003, 'El empleado no existe');
END;

/

CREATE OR REPLACE TRIGGER Comprueba_administrador
BEFORE INSERT OR UPDATE OF ADMINISTRADOR ON VUELOS_TAB
FOR EACH ROW
DECLARE
	cargo EMPLEADOS_TAB.CARGO%TYPE;
BEGIN
    SELECT CARGO INTO cargo
    FROM EMPLEADOS_TAB
    WHERE DNI = DEREF(:NEW.ADMINISTRADOR).DNI;
    
    IF (cargo <> 'ADMINISTRADOR') THEN
      RAISE_APPLICATION_ERROR(-20001, 'El empleado no es Administrador de vuelos');
    END IF;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20002, 'El empleado no existe');
END;

/

/* Evita que se modifique el precio de un billete una vez que se ha añadido */
CREATE OR REPLACE TRIGGER Precio_billete_invariable
BEFORE UPDATE OF PRECIO ON BILLETES_TAB
FOR EACH ROW
BEGIN    
	RAISE_APPLICATION_ERROR(-20001, 'No se puede modificar el precio de un billete existente.');
END;

/

/* Comprueba que el asiento no esté ocupado, que haya plazas, actualiza el importe de la factura */
/*ALTER TRIGGER Comprueba_billete_y_equipaje DISABLE;*/

CREATE OR REPLACE TRIGGER Comprueba_billete
	FOR INSERT ON BILLETES_TAB
COMPOUND TRIGGER
	TYPE r_billete IS RECORD(
		PRECIO	BILLETES_TAB.PRECIO%TYPE,
		IVA		BILLETES_TAB.IVA%TYPE,
		FACTURA	BILLETES_TAB.FACTURA%TYPE,
		CLIENTE	BILLETES_TAB.CLIENTE%TYPE
	);
	
	TYPE IDV IS TABLE OF BILLETES_TAB.ID%TYPE;
	
	num			NUMBER;
	id_vuelo 	VUELOS_TAB.ID%TYPE;
	v_capacidad AVIONES_TAB.CAPACIDAD%TYPE;
	v_billete 	r_billete;
	cont		NUMBER := 0;
	v_idv		IDV := IDV();
BEFORE EACH ROW IS
BEGIN 
	/* Asiento ocupado */
	SELECT COUNT(*) INTO num
	FROM BILLETES_TAB
	WHERE :NEW.VUELO = VUELO AND :NEW.ASIENTO = ASIENTO;
	
	IF (num <> 0) THEN
		RAISE_APPLICATION_ERROR(-20001, 'El asiento '||:NEW.ASIENTO||' ya está ocupado.');
	END IF;
	
	/* Plazas */		
	SELECT COUNT(*) INTO num
	FROM BILLETES_TAB
	WHERE :NEW.VUELO = VUELO;
	
	SELECT DEREF(DEREF(:NEW.VUELO).AVION).CAPACIDAD INTO v_capacidad FROM DUAL;
	
	IF (num + 1 > v_capacidad) THEN
		SELECT DEREF(:NEW.VUELO).ID INTO id_vuelo FROM DUAL;
		RAISE_APPLICATION_ERROR(-20002, 'No hay plazas en el vuelo '||id_vuelo);
	END IF;
	
	/* Almacenar datos para la seccion after */
	cont := cont + 1;
	v_idv.EXTEND();
	v_idv(cont) := :NEW.ID;
    
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
	FOR cont IN 1..v_idv.COUNT LOOP
		SELECT PRECIO, IVA, FACTURA, CLIENTE INTO v_billete
		FROM BILLETES_TAB
		WHERE ID = v_idv(cont); 
	
		/* Actualizamos factura */
		UPDATE FACTURAS_TAB F
		SET F.IMPORTE_TOTAL = F.IMPORTE_TOTAL + (v_billete.PRECIO * (1 + v_billete.IVA/100))
		WHERE v_billete.FACTURA = REF(F);
		
		/* Mantenemos la restriccion */
		INSERT INTO TABLE(SELECT C.BILLETES FROM CLIENTES_TAB C WHERE REF(C) = v_billete.CLIENTE)
			SELECT REF(B) FROM BILLETES_TAB B WHERE B.ID = v_idv(cont);				
	END LOOP;
END AFTER STATEMENT;
END Comprueba_billete;

/

CREATE OR REPLACE TRIGGER Actualizar_suplemento
BEFORE INSERT OR UPDATE OF EQUIPAJE ON BILLETES_TAB
FOR EACH ROW
DECLARE
	v_clase		CLASE_BILLETE_OBJ;
BEGIN
	IF (:NEW.EQUIPAJE IS NOT NULL) THEN
		IF (:NEW.EQUIPAJE.PESO_TOTAL > 50) THEN
			RAISE_APPLICATION_ERROR(-20003, 'El equipaje supera el peso máximo permitido');
		END IF;
		
		SELECT VALUE(C) INTO v_clase
		FROM CLASES_BILLETE_TAB C
		WHERE REF(C) = :NEW.CLASE;
		
		IF (:NEW.EQUIPAJE.PESO_TOTAL > v_clase.PESO_MAX) THEN
			:NEW.SUPLEMENTO := (:NEW.EQUIPAJE.PESO_TOTAL - v_clase.PESO_MAX) * v_clase.IMPORTE_SUP;
		ELSE
			:NEW.SUPLEMENTO := null;
		END IF;
	END IF;
END;

/

/* Comprueba que la tarjeta es del cliente, que la factura no tiene fecha posterior a la actual y evita cambios en la factura excepto en el importe total */
CREATE OR REPLACE TRIGGER Comprueba_tarjeta_de_factura
BEFORE INSERT OR UPDATE ON FACTURAS_TAB
FOR EACH ROW
DECLARE
	a_tarjetas 	TARJETA_ARRAY;
	ind			NUMBER;
	v_tarjeta 	TARJETA_OBJ;
BEGIN
	IF (INSERTING AND :NEW.TARJETA IS NOT NULL) THEN
		SELECT TARJETAS INTO a_tarjetas
		FROM CLIENTES_TAB C
		WHERE :NEW.CLIENTE = REF(C);
		
		IF (a_tarjetas IS NULL) THEN
			RAISE_APPLICATION_ERROR(-20001, 'La tarjeta no esta asignada al cliente.');
		END IF;
		
		ind := a_tarjetas.FIRST;
	  
		WHILE (ind IS NOT NULL AND a_tarjetas(ind).NUMERO <> :NEW.TARJETA)
		LOOP
			ind := a_tarjetas.NEXT (ind);
		END LOOP;
		
		IF ind IS NULL THEN		/* significa que no tenemos la tarjeta */
			RAISE_APPLICATION_ERROR(-20001, 'La tarjeta no esta asignada al cliente.');
		END IF;
		
		IF (a_tarjetas(ind).FECHA_CADUCIDAD < :NEW.FECHA_COMPRA) THEN
			RAISE_APPLICATION_ERROR(-20002, 'La tarjeta está caducada.');
		END IF;
	END IF;
	
	IF (UPDATING AND NOT UPDATING('IMPORTE_TOTAL')) THEN
		RAISE_APPLICATION_ERROR(-20003, 'No se puede modificar las facturas almacenadas.');
	END IF;
END;

/

/*COMPROBAR RECLAMACIONES
reclamacion hay de tipo perdida y daños.
si hay reclamacion de daños no puedes meter una de perdidas. al reves si.
que el empleado que asigna sea de taquilla*/
CREATE OR REPLACE TRIGGER Comprueba_reclamaciones
	FOR UPDATE OF EQUIPAJE ON BILLETES_TAB
COMPOUND TRIGGER
	TYPE IDV IS TABLE OF BILLETES_TAB.ID%TYPE;
	
	cont		NUMBER := 0;
	v_idv		IDV := IDV();
	
	a_reclamacion 			RECLAMACION_ARRAY;
	v_reclamacion			RECLAMACION_OBJ;
	v_cargo         		EMPLEADOS_TAB.CARGO%TYPE;
	NO_ADMITE_RECLAMACION	EXCEPTION;
BEFORE EACH ROW IS
BEGIN

	/* Almacenar datos para la seccion after */
	cont := cont + 1;
	v_idv.EXTEND();
	v_idv(cont) := :NEW.ID;
    
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
	FOR cont IN 1..v_idv.COUNT LOOP
		BEGIN
			SELECT B.EQUIPAJE.RECLAMACIONES INTO a_reclamacion
			FROM BILLETES_TAB B
			WHERE B.ID = v_idv(cont);
			
			IF (a_reclamacion.COUNT = 2) THEN
				IF (a_reclamacion(1).TIPO = 'DAÑO') THEN
					RAISE NO_ADMITE_RECLAMACION;
				ELSIF (a_reclamacion(2).TIPO = 'PERDIDA') THEN
					RAISE NO_ADMITE_RECLAMACION;
				END IF;
				
				v_reclamacion:= a_reclamacion(2); 
				
			ELSIF (a_reclamacion.COUNT = 1) THEN
				v_reclamacion := a_reclamacion(1);
			END IF;
			
			SELECT DEREF(v_reclamacion.EMPLEADO).CARGO INTO v_cargo FROM DUAL;
			
			IF (v_cargo <>'TAQUILLA') THEN
				RAISE_APPLICATION_ERROR(-20004, 'El emplado no tiene el cargo apropiado.');
			END IF;

			EXCEPTION
				WHEN NO_ADMITE_RECLAMACION THEN
				RAISE_APPLICATION_ERROR(-20005, 'No se permite agregar esa reaclamacion');
		END;		
	END LOOP;
END AFTER STATEMENT;
END Comprueba_reclamaciones;