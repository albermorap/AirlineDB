/* BORRADO */
DROP TABLE BILLETES_XML;
EXEC DBMS_XMLSCHEMA.deleteSchema(schemaURL => 'billetes.xsd');

/* CREACION */
BEGIN
  DBMS_XMLSCHEMA.registerSchema(schemaURL => 'billetes.xsd', schemaDOC=>
    '<?xml version="1.0" encoding="UTF-8"?> 
	<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns="http://www.billetes.es" targetNamespace="http://www.billetes.es">
		<xs:element name="billetes"/>
		<xs:element name="billete">
			<xs:complexType>
				<xs:sequence>
					<xs:element name="clase" type="claseBillete"/>
					<xs:element name="asiento" type="xs:string"/>
					<xs:element name="precio" type="xs:decimal"/>
					<xs:element name="iva" type="xs:decimal"/>
					<xs:element name="viajero" type="xs:string"/>
				</xs:sequence>
			</xs:complexType>
		</xs:element>
		<xs:element name="cliente">
			<xs:complexType>
				<xs:sequence>
					<xs:element name="nombre" type="xs:string"/>
					<xs:element name="telefono" type="xs:string"/>
					<xs:element name="email" type="xs:string"/>
					<xs:element name="direccion" type="xs:string"/>
					<xs:element name="ciudad" type="xs:string"/>
				</xs:sequence>
				<xs:attribute name="dni" use="required" type="xs:string"/>
			</xs:complexType>
		</xs:element>
		
		<xs:simpleType name="claseBillete">
			<xs:restriction base="xs:token">
				<xs:enumeration value="Turista"/>
				<xs:enumeration value="Bussiness"/>
			</xs:restriction>
		</xs:simpleType>
	</xs:schema>', OPTIONS => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
END;

/

CREATE TABLE BILLETES_XML (
	ID		NUMBER(3,0),
	BILLETE	XMLTYPE
)
XMLTYPE COLUMN BILLETE
STORE AS BINARY XML
XMLSCHEMA "billetes.xsd"
ELEMENT "billetes";

INSERT INTO BILLETES_XML VALUES(1,
	'<?xml version="1.0" encoding="UTF-8"?>
	<bi:billetes xmlns:bi="http://www.billetes.es"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.billetes.es billetes.xsd">
		
		<bi:billete>
			<clase>Turista</clase>
			<asiento>22A</asiento>
			<precio>120</precio>
			<iva>10</iva>
			<viajero>12345678A</viajero>
		</bi:billete>

		<bi:cliente dni="12345678A">
			<nombre>Pedro López</nombre>
			<telefono>963852741</telefono>
			<email>pedro@gmail.com</email>
			<direccion>c/ economia, 25</direccion>
			<ciudad>Madrid</ciudad>
		</bi:cliente>
		<bi:cliente dni="12345678B">
			<nombre>Gonzalo García</nombre>
			<telefono>987456321</telefono>
			<email>gonzalo@gmail.com</email>
			<direccion>c/ rupestre,4</direccion>
			<ciudad>Albacete</ciudad>
		</bi:cliente>
		
	</bi:billetes>'
);


/* Billetes de un cliente */
SELECT EXTRACT(BILLETE, '//billete[viajero=//cliente[nombre="Pedro López"]/@dni/text()]') "BILLETES DE PEDRO"
FROM BILLETES_XML
WHERE ID = 1;

SELECT XMLQUERY(
	'for $i in ora:view("EMPLEADOS_TAB")/ROW
	where $i/CARGO = "PILOTO"
	return
		if ($i/SALARIO > 3000)
		then <piloto rango="1" dni="{$i/DNI}"/>
		else <piloto rango="2" dni="{$i/DNI}"/>'
	RETURNING CONTENT) AS EMPLEADO
FROM DUAL;

SELECT ID, XMLQUERY(
	'for $i in //billetes
	return $i'
	PASSING BILLETE RETURNING CONTENT) AS BILLETES
FROM BILLETES_XML;