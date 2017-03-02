/*ACTUALIZAR_SUPLEMENTO,comprueba cuando se mete un equipaje, si el peso es mayor de lo permito por la clase billete que lleva asociado
ese billete, se recalcula el precio del suplemento que tendra ese billete.
*/

create or replace TRIGGER Actualizar_suplemento_billetes
BEFORE INSERT OR UPDATE OF EQUIPAJE ON BILLETES_TAB
FOR EACH ROW
DECLARE
e_equipaje BILLETES_TAB.EQUIPAJE%TYPE;

clase_billete CLASE_BILLETE_OBJ;
peso_extra number;
suplemento number;
BEGIN
        SELECT B.EQUIPAJE INTO e_equipaje
        FROM BILLETES_TAB B
        WHERE B.ID=:NEW.ID;
            
        SELECT DEREF(B.CLASE) INTO clase_billete
        FROM BILLETES_TAB B
        WHERE B.ID=:NEW.ID;
 
  IF(e_equipaje.PESO_TOTAL>50)THEN
   RAISE_APPLICATION_ERROR(-20001, 'El equipaje se excede del peso permitodo para cualquier clase de billete');
  END IF;
   /*para los billetes de clase business*/ 
  IF(clase_billete.NOMBRE='BUSINESS' AND e_equipaje.PESO_TOTAL>40) THEN 
    peso_extra:= 50-e_equipaje.PESO_TOTAL;
    suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
    
	UPDATE BILLETES_TAB B
		SET B.SUPLEMENTO =  suplemento
		WHERE :NEW.ID = B.ID;
  END IF;
   
    /*para los billetes de clase tarifa reducida*/ 
  IF(clase_billete.NOMBRE='TARIFA_REDUCIDA' AND e_equipaje.PESO_TOTAL>10) THEN 
    peso_extra:= 50-e_equipaje.PESO_TOTAL;
    suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
    
  UPDATE BILLETES_TAB B
		SET B.SUPLEMENTO =  suplemento
		WHERE :NEW.ID = B.ID;
  END IF;
    
    /*para los billetes de clase TURISTA*/ 
  IF(clase_billete.NOMBRE='TURISTA' AND e_equipaje.PESO_TOTAL>25) THEN 
    peso_extra:= 50-e_equipaje.PESO_TOTAL;
    suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
  UPDATE BILLETES_TAB B
		SET B.SUPLEMENTO =  suplemento
		WHERE :NEW.ID = B.ID;
  END IF;

		IF e_equipaje IS NULL THEN		/* significa que no tenemos equipaje */
			RAISE_APPLICATION_ERROR(-20001, 'El equipaje no esta');
		END IF;
    
END Actualizar_suplemento_billetes;


/
/*COMPROBAR RECLAMACIONES
reclamacion hay de tipo perdida y daños.
si hay reclamacion de daños no puedes meter una de perdidas. al reves si.
que el empleado que asigna sea de taquilla*/


create or replace TRIGGER Comprobar_reclamaciones
AFTER INSERT OR UPDATE OF EQUIPAJE ON BILLETES_TAB
FOR EACH ROW
DECLARE
	a_reclamacion 		RECLAMACION_ARRAY;
	v_reclamacion		RECLAMACION_OBJ;
	v_cargo         	EMPLEADO_OBJ;
	NO_ADMITE_PERDIDA 	EXCEPTION;
BEGIN

    SELECT B.EQUIPAJE.RECLAMACIONES INTO a_reclamacion
    FROM BILLETES_TAB B
	WHERE B.ID = :NEW.ID;

	IF (a_reclamacion.COUNT = 2) THEN
	
        IF (a_reclamacion(1).TIPO = 'DAÑO') THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: No puede meter otra reclamacion puesto que ya tiene una de daños');
            RAISE NO_ADMITE_PERDIDA;
        ELSIF (a_reclamacion(2).TIPO = 'PERDIDA') THEN
            DBMS_OUTPUT.PUT_LINE('segundo');
            RAISE NO_ADMITE_PERDIDA;
        END IF;
  		v_reclamacion:= a_reclamacion(2);  
    ELSIF (a_reclamacion.COUNT = 1) THEN
		v_reclamacion := a_reclamacion(1);

	END IF;
	
	SELECT DEREF(v_reclamacion.EMPLEADO) INTO v_cargo FROM DUAL;
	
	IF (v_cargo.CARGO <>'TAQUILLA') THEN
		RAISE_APPLICATION_ERROR(-20001, 'El emplado no tiene el cargo apropiado.');
	END IF;

	EXCEPTION
		WHEN NO_ADMITE_PERDIDA THEN
		RAISE_APPLICATION_ERROR(-20002, 'No se permite agregar esa reaclamacion');
END;