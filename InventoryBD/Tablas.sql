--INTEGRANTES DEL GRUPO 1:
-- JUAN DAVID GOMEZ
-- JUAN PABLO GIRALDO
-- MATEO OROZCO AREVALO


--TABLA ENCARGADA DE MANTENER EL CONTROL DE LOS EMPLEADOS
--TODOS LOS DATOS DE LOS EMPLEADOS SON OBLIGATORIOS
CREATE TABLE EMPLEADO(
    CC NUMBER(8) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apellido VARCHAR2(50) NOT NULL,
    Correo VARCHAR2(100) NOT NULL UNIQUE,
    Direccion VARCHAR2(100) NOT NULL
);
--TABLA ENCARGADA DE MANTENER EL CONTROL DE LOS CLIENTES
--EL CLIENTE SOLO DEBERA INGRESAR SU APELLIDO Y CEDULA OBLIGATORIAMENTE
CREATE TABLE CLIENTE(
    CC NUMBER(8) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellido VARCHAR2(50) NOT NULL,
    Correo VARCHAR2(100) UNIQUE,
    Direccion VARCHAR2(100)
);

-- TABLA DEL PROVEEDOR ENCARGADA DE GUARDAR EL ID DEL PROVEEDOR
-- Y EL NOMBRE DE SU MARCA
CREATE TABLE PROVEEDOR(
    IDProveedor NUMBER(7) PRIMARY KEY,
    NombreProveedor VARCHAR2(50) NOT NULL UNIQUE
);

--TABLA ENCARGADA DE TENER LAS MARCAS DE LOS PRODUCTOS Y SUS IDS
CREATE TABLE MARCA(
    IDMarca NUMBER(3) PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL UNIQUE
);



-- TABLA DE PRODUCTOS ENCARGADA DE GUARDAR TODA LA INFORMACION DE LOS PRODUCTOS
CREATE TABLE PRODUCTO(
    IDProducto NUMBER(3) PRIMARY KEY,
    NombreProducto VARCHAR2(100) NOT NULL,
    IDProveedor NUMBER(7) REFERENCES PROVEEDOR,
    Tipo VARCHAR2(5),
    CantidadBodega NUMBER(3),
    CantidadAlmacen NUMBER(3),
    IDMarca NUMBER(3) REFERENCES MARCA

);

-- TABLA ENCARGADA DE REGISTRAR COMO SE REABASTECE EL INVENTARIO
CREATE TABLE REABASTECER(
    IDR NUMBER(4) PRIMARY KEY,
    IDProveedor NUMBER(7) REFERENCES PROVEEDOR,
    IDProducto NUMBER(3) REFERENCES PRODUCTO,
    CantidadIngresada NUMBER(3) CHECK(CantidadIngresada > 0),
    Fecha DATE NOT NULL
);


-- TABLA ENCARGARDA DE REGISTRAR CUANDO UN EMPLEADO MUEVE PRODUCTOS DESDE
-- LA BODEGA AL INVENTARI

CREATE TABLE SURTIR(
    IDS NUMBER(2) PRIMARY KEY,
    IDProducto  NUMBER(3) REFERENCES PRODUCTO,
    CantidadATransladada NUMBER(3) NOT NULL CHECK(CantidadATransladada > 0),
    CC NUMBER(8) REFERENCES EMPLEADO,
    Fecha DATE NOT NULL    

);

-- TABLA ENCARGADA DE TENER LA FACTURA Y UNIRLO CON EL CLIENTE

CREATE TABLE FACTURAS(
    IDFactura NUMBER(6) PRIMARY KEY,
    Fecha DATE NOT NULL,
    CC NUMBER(8) REFERENCES CLIENTE
);

--TABLA ENCARGADA DE TENER EL REGISTRO DE LAS COMPRAS DE UNA FACTURA
CREATE TABLE COMPRA(
    IDCompra NUMBER(4) PRIMARY KEY,
    Precio NUMBER(10) NOT NULL,
    Cantidad NUMBER(3) NOT NULL,
    IDFactura NUMBER(6) REFERENCES FACTURAS,
    IDProducto NUMBER(3) REFERENCES PRODUCTO
);

