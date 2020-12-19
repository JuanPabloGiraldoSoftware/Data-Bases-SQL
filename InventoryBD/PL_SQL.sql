--INTEGRANTES DEL GRUPO 1:
-- JUAN DAVID GOMEZ
-- JUAN PABLO GIRALDO
-- MATEO OROZCO AREVALO

-- PUNTO 1
-- a) CUANDO EL CLIENTE VA A COMPRAR UN PRODUCTO AGOTADO EN EL ALMACEN
CREATE OR REPLACE TRIGGER TrRevisionCompra
AFTER INSERT ON COMPRA
FOR EACH ROW
DECLARE
CantidadAlma NUMBER(3);
BEGIN
    
    SELECT CANTIDADALMACEN INTO CantidadAlma FROM PRODUCTO WHERE :NEW.IDPRODUCTO = PRODUCTO.IDPRODUCTO;
    IF :NEW.CANTIDAD > 0 AND CantidadAlma = 0 THEN
    Raise_application_error(-20100,'El producto se encuentra agotado');
    END IF;
END;

INSERT INTO COMPRA (IDCOMPRA,PRECIO, CANTIDAD, IDFACTURA, IDPRODUCTO)
VALUES(1200,1034648392, 200, 100100, 547 );

-- CUANDO EL EMPLEADO VA A MOVER UN PRODUCTO AGOTADO

CREATE OR REPLACE TRIGGER TrRevisionMovimiento
AFTER INSERT ON SURTIR
FOR EACH ROW
DECLARE
CantidadBode NUMBER(3);
BEGIN
    
    SELECT CANTIDADBODEGA INTO CantidadBode FROM PRODUCTO WHERE :NEW.IDPRODUCTO = PRODUCTO.IDPRODUCTO;
    IF :NEW.CANTIDADATRANSLADADA > 0 AND CantidadBode = 0 THEN
    Raise_application_error(-20100,'El producto se encuentra agotado');
    END IF;
END;

INSERT INTO SURTIR (IDS,IDPRODUCTO,CANTIDADATRANSLADADA,CC,FECHA)
VALUES(01, 547, 10,22323046,'29/11/20');

-- b) NUEVO ATRIBUTO EN PROVEEDOR

ALTER TABLE PROVEEDOR
ADD HISTORICO NUMBER(6);

--FUNCION QUE RETORNA LA CANTIDAD DE TODOS LOS PRODUCTOS DE UN PROVEEDOR
CREATE OR REPLACE FUNCTION ACTU(IDP NUMBER) 
RETURN NUMBER
AS
TOTAL NUMBER(6);
BEGIN
    SELECT(SUM(CANTIDADBODEGA)+SUM(CANTIDADALMACEN)) INTO TOTAL
    FROM PRODUCTO 
    WHERE IDP = PRODUCTO.IDPROVEEDOR
    GROUP BY IDPROVEEDOR;
    
    RETURN TOTAL;
END;

--TRIGGER QUE MANTIENE ACTUALIZADO EL HISTORICO DE LOS PROVEEDORES CADA QUE CAMBIA ALGO EN LA TABLA PRODUCTOS
CREATE OR REPLACE TRIGGER trCambioHistorico
AFTER INSERT OR UPDATE ON PRODUCTO
BEGIN
UPDATE PROVEEDOR
SET HISTORICO = ACTU(PROVEEDOR.IDPROVEEDOR);
END;

--LINEA UTILIZADA PARA PROBAR LA VERACIDAD
INSERT INTO PRODUCTO (IDPRODUCTO, NOMBREPRODUCTO, IDPROVEEDOR,TIPO,CANTIDADBODEGA,CANTIDADALMACEN,IDMARCA)
VALUES (548,'Cucharadebebe',1000000,'Dom.',200,200,100);

DELETE FROM PRODUCTO WHERE IDPRODUCTO = 548;

-- PUNTO 2

-- ESCOGIMOS REALIZAR UN TRIGGER PARA LIMITAR EL MOVIMIENTO DE PRODUCTOS DONDE
-- UN EMPLEADO NO PODRA MOVER AL ALMACEN MAS PRODUCTOS DE LOS QUE HAYA EN BODEGA

CREATE OR REPLACE TRIGGER TrRevisionMovimientoMAX
AFTER INSERT OR UPDATE OR DELETE ON SURTIR
FOR EACH ROW
DECLARE
CantidadBode NUMBER(3);
BEGIN
    
    SELECT CANTIDADBODEGA INTO CantidadBode FROM PRODUCTO WHERE :NEW.IDPRODUCTO = PRODUCTO.IDPRODUCTO;
    IF :NEW.CANTIDADATRANSLADADA > CantidadBode THEN
    Raise_application_error(-20101,'No hay suficientes existencias del producto');
    END IF;
END;

INSERT INTO SURTIR (IDS,IDPRODUCTO,CANTIDADATRANSLADADA,CC,FECHA)
VALUES(02, 509, 900,22323046,'29/11/20');

--PUNTO 3
-- CONSULTA A MEJORAR EFICIENCIA
-- 1) Encuentre para cada a�o, el producto que se ha vendido en mayor cantidad (total del
--a�o) en ese a�o (si su modelo no incluye ventas, encuentre el producto que m�s se ha
--pedido).

CREATE INDEX COMPRAS ON COMPRA( IDPRODUCTO,IDFACTURA );

WITH cantpa AS (SELECT EXTRACT(YEAR FROM fecha) AS yr, IDproducto, SUM(cantidad) AS totcant FROM PRODUCTO NATURAL JOIN COMPRA NATURAL JOIN FACTURA 
GROUP BY idproducto, EXTRACT(YEAR FROM fecha))
SELECT yr, max(totcant) FROM cantpa GROUP BY yr ORDER BY yr;

-- SE DECIDE CREAR INDICES PARA OPTIMIZAR LOS JOIN CREANDO UN INDICE PARA LAS LLAVES FORANEAS EN LAS TABLA COMPRA QUE SERIAN IDPRODUCTO Y
-- IDFACTURA. NO SE CREAN INDICES EN LAS TABLAS PRODUCTO Y FACTURA DEBIDO A QUE SE UTILIZAN LAS LLAVES PRIMARIAS Y EL MOTOR YA CREA INDICES
-- AUTOMATICAMENTE PARA LAS LLAVES PRIMARIAS.

-- PUNTO 4 
CREATE OR REPLACE VIEW PUNTOCUATRO AS (SELECT DISTINCT  IDPROVEEDOR,NOMBREPROVEEDOR,NOMBREPRODUCTO ,CANTIDADBODEGA + CANTIDADALMACEN AS INVENTARIO, MARCA.NOMBRE AS MARCA , ROUND(PRECIO/CANTIDAD) AS PRECIO
                        FROM PROVEEDOR NATURAL JOIN MARCA NATURAL JOIN PRODUCTO NATURAL JOIN COMPRA);

SELECT * FROM PUNTOCUATRO
ORDER BY IDPROVEEDOR;

--PUNTO 5
-- CONSULTA DEL PROMEDIO DEL PRECIO DE CADA PROVEEDOR
SELECT IDPROVEEDOR,ROUND(AVG(PRECIO),2)AS PROMEDIO
FROM PUNTOCUATRO
GROUP BY IDPROVEEDOR
ORDER BY IDPROVEEDOR;

--PUNTO 6
-- a)
-- ESTRUCTURA PROPUESTA PARA LOS ARCHIVOS YAML
---
-- NOMBREPRODUCTO: ARANDANO
--   IDPRODUCTO: 510
--   IDPROVEEDOR: 1000003
--   TIPO: Com. (Comestible)
--   CANTIDAD BODEGA: 330
--   CANTIDAD ALMACEN: 439
--   IDMARCA: 100
--...

-- b) FUNCION QUE CREA LA TABLA PARA INGRESAR LOS ARCHIVOS YAML
CREATE OR REPLACE TYPE t_producto AS OBJECT (rw VARCHAR(1000));
CREATE OR REPLACE TYPE t_ans AS TABLE OF t_productos;
CREATE OR REPLACE FUNCTION getProductos RETURN t_ans
AS
    ret t_ans;
    CURSOR listaProductos IS 
    SELECT* FROM PRODUCTO;
BEGIN
    ret := t_ans();
    FOR i IN listaProductos LOOP
        ret.extend;
        ret(ret.count) := t_producto('---'||chr(10)||' NombreProducto: '||i.NombreProducto||chr(10)||'  IDProducto: '||i.IDProducto||chr(10)||' IDProveedor: '||i.IDProveedor||chr(10)||' Tipo: '||i.Tipo||chr(10)||'   CantidadBodega: '||i.CantidadBodega||chr(10)||' CantidadAlmacen: '||i.CantidadAlmacen||chr(10)||'   IDMarca: '||i.IDMarca||chr(10)||'...')
    END LOOP
    RETURN ret;
END;

--PUNTO 7
-- PROCEDIMIENTO QUE NOS MUESTRA TODOS LOS PRODUCTOS DE UN PROVEEDOR Y LA INFORMACION DE ESTOS
CREATE OR REPLACE PROCEDURE INFOPROVEE(IDP NUMBER,NOMBRP VARCHAR)
AS

BEGIN
DBMS_OUTPUT.PUT_LINE(IDP|| ' '|| NOMBRP); 

FOR INFO IN (   SELECT *
                FROM PRODUCTO NATURAL JOIN PROVEEDOR 
                WHERE IDP= IDPROVEEDOR)
            
LOOP
    DBMS_OUTPUT.PUT_LINE(INFO.IDPRODUCTO||' '||INFO.NOMBREPRODUCTO||' '|| INFO.TIPO);
END LOOP; 


END; 

BEGIN
INFOPROVEE(1000003,'gummy');
END;
