/*set serveroutput on;*/
begin
	IMPRIME_FACTURA();

end;


/*1)	El proceso “IMPRIME_FACTURA”, realiza una tarea básica, imprimir la factura de un cliente, 
adjuntando los datos de la compra que ha realizado de billetes, datos de la factura y sus propios datos como el dni o el nombre.
 No realiza ningún cambio en las tablas ni devuelve nada al ser un procedimiento.*/
CREATE OR REPLACE PROCEDURE IMPRIME_FACTURA 
( FAC IN FACTURAS_TAB.ID%TYPE)
AS 
  
  CURSOR c_billetes IS 
    SELECT *
    FROM BILLETES_TAB
    WHERE DEREF(FACTURA).ID=FAC;
 
 TYPE v_factura IS RECORD(
    ID FACTURAS_TAB.ID%TYPE,
    IMPORTE_TOTAL FACTURAS_TAB.IMPORTE_TOTAL%TYPE,
    FECHA_COMPRA FACTURAS_TAB.FECHA_COMPRA%TYPE,
    CLIENTE FACTURAS_TAB.CLIENTE%TYPE,
    TARJETA FACTURAS_TAB.TARJETA%TYPE
  );
   TYPE v_cliente IS RECORD(
    DNI CLIENTES_TAB.DNI%TYPE,
    PASAPORTE CLIENTES_TAB.PASAPORTE%TYPE,
    NOMBRE CLIENTES_TAB.NOMBRE%TYPE,
    APELLIDOS CLIENTES_TAB.APELLIDOS%TYPE,
    TLF CLIENTES_TAB.TLF%TYPE,
    EMAIL CLIENTES_TAB.EMAIL%TYPE,
    DIRECCION CLIENTES_TAB.DIRECCION%TYPE,
    CIUDAD CLIENTES_TAB.CIUDAD%TYPE,
    CP CLIENTES_TAB.CP%TYPE,
    PAIS CLIENTES_TAB.PAIS%TYPE,
    PASSWORD CLIENTES_TAB.PASSWORD%TYPE,
    TARJETAS CLIENTES_TAB.TARJETAS%TYPE,
    BILLETES CLIENTES_TAB.BILLETES%TYPE
  );
  
 v_fac v_factura;
 v_clie v_cliente;
BEGIN


  SELECT * INTO v_fac
  FROM FACTURAS_TAB
  WHERE ID=FAC;

  SELECT * INTO v_clie
  FROM CLIENTES_TAB C
  WHERE REF(C)=v_fac.CLIENTE;

  DBMS_OUTPUT.put_line('***********************************************************************************************');
  DBMS_OUTPUT.put_line('***********************************************************************************************');
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('  Factura:'||v_fac.ID||'    Fecha de compra: '||v_fac.FECHA_COMPRA);
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('      Cliente: '||v_clie.NOMBRE||' '||v_clie.APELLIDOS||'    DNI:'||v_clie.DNI);
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('                     **************************************************                        ');
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('  COMPRA REALIZADA :');

  FOR v_bi IN c_billetes LOOP
    DBMS_OUTPUT.put_line(' ');
    DBMS_OUTPUT.put_line('  >>>>>>>  ID BILLETE: '||v_bi.ID||' PRECIO: '||v_bi.PRECIO||'€ IVA: '||v_bi.IVA);
    DBMS_OUTPUT.put_line('  >>>>>>>  TOTAL PRECIO BILLETE : '||v_bi.PRECIO*(1+v_bi.IVA/100)||'€');
    DBMS_OUTPUT.put_line(' ');
  END LOOP;
  DBMS_OUTPUT.put_line('                     **************************************************                        ');
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('IMPORTE TOTAL : '||v_fac.IMPORTE_TOTAL);
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('***********************************************************************************************');
  DBMS_OUTPUT.put_line('***********************************************************************************************');
  DBMS_OUTPUT.put_line(' ');
  DBMS_OUTPUT.put_line('GRACIAS POR SU COMPRA ');
  DBMS_OUTPUT.put_line(' ');
  
EXCEPTION

  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line(' LA FACTURA SOLICITADA NO EXISTE ');

END IMPRIME_FACTURA;
/*2)	Este es el 2º procedimiento que he realizado, su aplicación es la de actualizar las facturas,
 algo que era necesario para comprobar el funcionamiento del disparador que más tarde describiremos. Por tanto su función es la de actualizar
 el campo “IMPORTE_TOTAL” de todas las columnas de la tabla factura calculando los precios a partir de la tabla “BILLETES”.*/

CREATE OR REPLACE PROCEDURE ACTUALIZAR_FACTURAS AS 

 TYPE v_factura IS RECORD(
    ID FACTURAS_TAB.ID%TYPE,
    IMPORTE_TOTAL FACTURAS_TAB.IMPORTE_TOTAL%TYPE,
    FECHA_COMPRA FACTURAS_TAB.FECHA_COMPRA%TYPE,
    CLIENTE FACTURAS_TAB.CLIENTE%TYPE,
    TARJETA FACTURAS_TAB.TARJETA%TYPE
  );
  
  CURSOR c_facturas IS 
    SELECT * FROM FACTURAS_TAB;
  
  importeT FACTURAS_TAB.IMPORTE_TOTAL%TYPE;

  CURSOR c_billetes (fac v_factura) IS 
    SELECT * FROM BILLETES_TAB WHERE DEREF(FACTURA).ID=fac.ID;
    
    
BEGIN

  FOR factura IN c_facturas LOOP
      
      importeT:=0;
      
      FOR billete IN c_billetes(factura) LOOP
      
          importeT:=importeT+billete.PRECIO*(1+billete.IVA/100);
      
      END LOOP;
      
      UPDATE FACTURAS_TAB SET IMPORTE_TOTAL=importeT WHERE ID=factura.ID;
    
  END LOOP;


END ACTUALIZAR_FACTURAS;


/*Este procedimiento muestra los empleados que han trabajado en cada uno de los vuelos registrados hasta el momento,
calcula el dinero medio que ha cobrado cada empleado en funcion de los vuelos en los que ha trabajado y el salario mensual que cobra y 
calcula el coste del vuelo en salarios de empleados*/
CREATE OR REPLACE PROCEDURE SALARIOS_MEDIOS_EMPLEADOS
AS
   TYPE v_empleado IS RECORD(
    DNI EMPLEADOS_TAB.DNI%TYPE,
    NOMBRE EMPLEADOS_TAB.NOMBRE%TYPE,
    APELLIDOS EMPLEADOS_TAB.APELLIDOS%TYPE,
    TLF EMPLEADOS_TAB.TLF%TYPE,
    EMAIL EMPLEADOS_TAB.EMAIL%TYPE,
    DIRECCION EMPLEADOS_TAB.DIRECCION%TYPE,
    CIUDAD EMPLEADOS_TAB.CIUDAD%TYPE,
    CP EMPLEADOS_TAB.CP%TYPE,
    PAIS EMPLEADOS_TAB.PAIS%TYPE,
    CARGO EMPLEADOS_TAB.CARGO%TYPE,
    SALARIO EMPLEADOS_TAB.SALARIO%TYPE);
  
  CURSOR c_vuelos IS 
    SELECT V.ID FROM VUELOS_TAB V;
  
  CURSOR c_personal (v VUELOS_TAB.ID%TYPE) IS 
   SELECT E.* FROM EMPLEADOS_TAB E,VUELOS_TAB V,TABLE(V.PERSONAL)EMP WHERE V.ID=v AND COLUMN_VALUE= REF(E);

  empleado v_empleado;
  coste_vuelo_en_salarios NUMBER;
  dinero_medio_cobro_por_vuelo NUMBER;
  n NUMBER;
BEGIN
 for vuelo in c_vuelos LOOP
    coste_vuelo_en_salarios:=0;
    DBMS_OUTPUT.PUT_LINE('');
     DBMS_OUTPUT.PUT_LINE('**********************************');
    DBMS_OUTPUT.PUT_LINE('******** VUELO '||vuelo.ID||'*********');
    DBMS_OUTPUT.PUT_LINE('**********************************');  
       
       FOR empleado IN c_personal(vuelo.ID) LOOP
       n:=0;
        dinero_medio_cobro_por_vuelo:=0;
    SELECT COUNT(V.ID) INTO n FROM EMPLEADOS_TAB E,VUELOS_TAB V,TABLE(V.PERSONAL)EMP WHERE COLUMN_VALUE= REF(E) AND E.DNI=empleado.DNI;

                DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Cargo: ' || empleado.CARGO);
                DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------');
                DBMS_OUTPUT.PUT_LINE('--DNI: ' || empleado.DNI);
                DBMS_OUTPUT.PUT_LINE('--Nombre: ' || empleado.NOMBRE);
                DBMS_OUTPUT.PUT_LINE('--Apellidos: ' || empleado.APELLIDOS);
                DBMS_OUTPUT.PUT_LINE('--Salario Mensual: ' || empleado.SALARIO);
                DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
                dinero_medio_cobro_por_vuelo:=empleado.SALARIO/N;
                DBMS_OUTPUT.PUT_LINE('--> Salario Medio cobrado por este vuelo: ' || dinero_medio_cobro_por_vuelo);
                DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
                DBMS_OUTPUT.PUT_LINE('**************************************************************************');  

              coste_vuelo_en_salarios:=coste_vuelo_en_salarios + dinero_medio_cobro_por_vuelo;      
    
       END LOOP;
        DBMS_OUTPUT.PUT_LINE('-->COSTE DEL VUELO EN SALARIOS DE EMPLEADOS : ' || coste_vuelo_en_salarios);
        DBMS_OUTPUT.PUT_LINE('**************************************************************');
        DBMS_OUTPUT.PUT_LINE('');
end loop;
  
END SALARIOS_MEDIOS_EMPLEADOS;