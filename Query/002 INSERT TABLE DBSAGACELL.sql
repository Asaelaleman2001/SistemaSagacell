USE DBSAGACELL

GO

insert into rol (Descripcion)
 values('ADMINISTRADOR')

 GO

  insert into rol (Descripcion)
 values('EMPLEADO')

 GO

insert into USUARIO (Documento,NombreCompleto,Correo,Clave,IdRol,Estado)
values 
('001-141085-0069M', 'Roberto Saravia', 'sagacell01@gmail.com', 'Robe141085', 1, 1)

GO

 select u.IdUsuario,u.Documento,u.NombreCompleto,u.Correo,u.Clave,u.Estado, r.IdRol, r.Descripcion from usuario u
inner join ROL r on r.IdRol = u.IdRol

GO

insert into PERMISO(IdRol,NombreMenu)
values
(1,'menuusuarios'),
(1,'menumantenedor'),
(1,'menuventas'),
(1,'menucompras'),
(1,'menuclientes'),
(1,'menuproveedores'),
(1,'menureportes'),
(1,'menuacercade')

GO

insert into PERMISO(IdRol,NombreMenu) 
values
(2,'menuventas'),
(2,'menucompras'),
(2,'menuclientes'),
(2,'menuproveedores'),
(2,'menuacercade')

GO

insert into NEGOCIO(IdNegocio, Nombre, RUC, Direccion) values
(1, 'Sagacell', '254621774516', 'Semáforos de PriceSmart ctra. Masaya 400 mts. arriba.')

GO