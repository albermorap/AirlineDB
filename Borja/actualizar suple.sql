create or replace TRIGGER Actualizar_suplemento_billetes
FOR INSERT OR UPDATE OF EQUIPAJE ON BILLETES_TAB
COMPOUND TRIGGER

e_equipaje BILLETES_TAB.EQUIPAJE%TYPE;
clase_billete CLASE_BILLETE_OBJ;
peso_extra number :=0;
suplemento number :=0;

id_bille  BILLETES_TAB.ID%TYPE;

BEFORE EACH ROW IS
BEGIN
    IF (INSERTING OR UPDATING) THEN 
    id_bille:=:NEW.ID;
    
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
  IF (INSERTING OR UPDATING) THEN
        
        SELECT B.EQUIPAJE INTO e_equipaje
        FROM BILLETES_TAB B
        WHERE B.ID=id_bille;
                   
        SELECT DEREF(B.CLASE) INTO clase_billete
        FROM BILLETES_TAB B
        WHERE B.ID=id_bille;
 
		IF(e_equipaje.PESO_TOTAL>50)THEN
			RAISE_APPLICATION_ERROR(-20001, 'El equipaje se excede del peso permitodo para cualquier clase de billete');
		END IF;
		  
		/*IF e_equipaje IS NULL THEN		/* significa que no tenemos equipaje */
			/*RAISE_APPLICATION_ERROR(-20001, 'El equipaje no esta');*/
		/*END IF;*/
	/*para los billetes de clase business*/ 
	
			 IF(clase_billete.NOMBRE='BUSINESS' AND e_equipaje.PESO_TOTAL>40) THEN 
				peso_extra:= e_equipaje.PESO_TOTAL - 40;
				suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
        DBMS_OUTPUT.PUT_LINE('PRIMERO');
       END IF;
  /*para los billetes de clase tarifa reducida*/ 
			  IF(clase_billete.NOMBRE='TARIFA_REDUCIDA' AND e_equipaje.PESO_TOTAL>10) THEN 
				peso_extra:= e_equipaje.PESO_TOTAL - 10;
				suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
				END IF;		
  /*para los billetes de clase TURISTA*/ 
			  IF(clase_billete.NOMBRE='TURISTA' AND e_equipaje.PESO_TOTAL>25) THEN 
				peso_extra:= e_equipaje.PESO_TOTAL - 25;
				suplemento:=peso_extra*clase_billete.IMPORTE_SUP;
  		  END IF;
        
        UPDATE BILLETES_TAB B
				SET B.SUPLEMENTO =  suplemento
				WHERE id_bille = B.ID;
        
    END IF;
	END AFTER STATEMENT;
END Actualizar_suplemento_billetes;