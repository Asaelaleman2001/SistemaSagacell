USE DBSAGACELL

GO

create PROC SP_REGISTRARUSUARIO(
@Documento varchar(16),
@NombreCompleto varchar(100),
@Correo varchar(100),
@Clave varchar(100),
@IdRol int,
@Estado bit,
@IdUsuarioResultado int output,
@Mensaje varchar(500) output
)
as
begin
	set @IdUsuarioResultado = 0
	set @Mensaje = ''


	if not exists(select * from USUARIO where Correo = @Correo)
	begin
		insert into usuario(Documento,NombreCompleto,Correo,Clave,IdRol,Estado) values
		(@Documento,@NombreCompleto,@Correo,@Clave,@IdRol,@Estado)

		set @IdUsuarioResultado = SCOPE_IDENTITY()
		
	end
	else
		set @Mensaje = 'No se puede repetir el documento para más de un usuario'


end

go

create PROC SP_EDITARUSUARIO(
@IdUsuario int,
@Documento varchar(16),
@NombreCompleto varchar(100),
@Correo varchar(100),
@Clave varchar(100),
@IdRol int,
@Estado bit,
@Respuesta bit output,
@Mensaje varchar(500) output
)
as
begin
	set @Respuesta = 0
	set @Mensaje = ''


	if not exists(select * from USUARIO where Correo = @Correo and idusuario != @IdUsuario)
	begin
		update  usuario set
		Documento = @Documento,
		NombreCompleto = @NombreCompleto,
		Correo = @Correo,
		Clave = @Clave,
		IdRol = @IdRol,
		Estado = @Estado
		where IdUsuario = @IdUsuario

		set @Respuesta = 1
		
	end
	else
		set @Mensaje = 'No se puede repetir el documento para más de un usuario'


end
go

create PROC SP_ELIMINARUSUARIO(
@IdUsuario int,
@Respuesta bit output,
@Mensaje varchar(500) output
)
as
begin
	set @Respuesta = 0
	set @Mensaje = ''
	declare @pasoreglas bit = 1

	IF EXISTS (SELECT * FROM COMPRA C 
	INNER JOIN USUARIO U ON U.IdUsuario = C.IdUsuario
	WHERE U.IDUSUARIO = @IdUsuario
	)
	BEGIN
		set @pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje + 'No se puede eliminar porque el usuario se encuentra relacionado a una COMPRA\n' 
	END

	IF EXISTS (SELECT * FROM VENTA V
	INNER JOIN USUARIO U ON U.IdUsuario = V.IdUsuario
	WHERE U.IDUSUARIO = @IdUsuario
	)
	BEGIN
		set @pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje + 'No se puede eliminar porque el usuario se encuentra relacionado a una VENTA\n' 
	END

	if(@pasoreglas = 1)
	begin
		delete from USUARIO where IdUsuario = @IdUsuario
		set @Respuesta = 1 
	end

end

go

/* ---------- PROCEDIMIENTOS PARA CATEGORIA -----------------*/
create procedure SP_MostrarCategoria
as
select * from CATEGORIA


GO

create PROC SP_RegistrarCategoria(
@Descripcion varchar(50),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion)
	begin
		insert into CATEGORIA(Descripcion,Estado) values (@Descripcion,@Estado)
		set @Resultado = SCOPE_IDENTITY()
	end
	ELSE
		set @Mensaje = 'No se puede repetir la descripcion de una categoria'
	
end


go

Create procedure sp_EditarCategoria(
@IdCategoria int,
@Descripcion varchar(50),
@Estado bit,
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion =@Descripcion and IdCategoria != @IdCategoria)
		update CATEGORIA set
		Descripcion = @Descripcion,
		Estado = @Estado
		where IdCategoria = @IdCategoria
	ELSE
	begin
		SET @Resultado = 0
		set @Mensaje = 'No se puede repetir la descripcion de una categoria'
	end

end

go

create procedure sp_EliminarCategoria(
@IdCategoria int,
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (
	 select *  from CATEGORIA c
	 inner join PRODUCTO p on p.IdCategoria = c.IdCategoria
	 where c.IdCategoria = @IdCategoria
	)
	begin
	 delete top(1) from CATEGORIA where IdCategoria = @IdCategoria
	end
	ELSE
	begin
		SET @Resultado = 0
		set @Mensaje = 'La categoria se encuentara relacionada a un producto'
	end

end

GO

execute SP_RegistrarCategoria 'Telefonos', 1, null, null
execute SP_RegistrarCategoria 'Tablets', 1, null, null
execute SP_RegistrarCategoria 'Accesorios', 1, null, null

execute SP_MostrarCategoria 


GO

/* ---------- PROCEDIMIENTOS PARA PRODUCTO -----------------*/
create procedure SP_MostrarProducto
as
	select * from PRODUCTO

GO

create PROC sp_RegistrarProducto(
@Codigo varchar(20),
@Nombre varchar(30),
@Descripcion varchar(30),
@IdCategoria int,
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM producto WHERE Codigo = @Codigo)
	begin
		insert into producto(Codigo,Nombre,Descripcion,IdCategoria,Estado) values (@Codigo,@Nombre,@Descripcion,@IdCategoria,@Estado)
		set @Resultado = SCOPE_IDENTITY()
	end
	ELSE
	 SET @Mensaje = 'Ya existe un producto con el mismo codigo' 
	
end

GO

create procedure sp_ModificarProducto(
@IdProducto int,
@Codigo varchar(20),
@Nombre varchar(30),
@Descripcion varchar(30),
@IdCategoria int,
@Estado bit,
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM PRODUCTO WHERE codigo = @Codigo and IdProducto != @IdProducto)
		
		update PRODUCTO set
		codigo = @Codigo,
		Nombre = @Nombre,
		Descripcion = @Descripcion,
		IdCategoria = @IdCategoria,
		Estado = @Estado
		where IdProducto = @IdProducto
	ELSE
	begin
		SET @Resultado = 0
		SET @Mensaje = 'Ya existe un producto con el mismo codigo' 
	end
end

go


create PROC SP_EliminarProducto(
@IdProducto int,
@Respuesta bit output,
@Mensaje varchar(500) output
)
as
begin
	set @Respuesta = 0
	set @Mensaje = ''
	declare @pasoreglas bit = 1

	IF EXISTS (SELECT * FROM DETALLE_COMPRA dc 
	INNER JOIN PRODUCTO p ON p.IdProducto = dc.IdProducto
	WHERE p.IdProducto = @IdProducto
	)
	BEGIN
		set @pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje + 'No se puede eliminar porque se encuentra relacionado a una COMPRA\n' 
	END

	IF EXISTS (SELECT * FROM DETALLE_VENTA dv
	INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
	WHERE p.IdProducto = @IdProducto
	)
	BEGIN
		set @pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje + 'No se puede eliminar porque se encuentra relacionado a una VENTA\n' 
	END

	if(@pasoreglas = 1)
	begin
		delete from PRODUCTO where IdProducto = @IdProducto
		set @Respuesta = 1 
	end

end
go

execute sp_RegistrarProducto '001', 'Galaxy Tab A7 64GB/4GB', 'Usado', 2, 1, null, null
execute sp_RegistrarProducto '002', 'Realme Pad Mini 64GB/4GB', 'Nuevo', 2, 1, null, null
execute sp_RegistrarProducto '003', 'Samsung Galaxy Tab S8 128GB/6GB', 'Usado', 2, 1, null, null
execute sp_RegistrarProducto '004', 'Huawei MatePad T10s 64GB/4GB', 'Seminuevo', 2, 0, null, null
execute sp_RegistrarProducto '005', 'Huawei Media Pad M3 128GB/8GB', 'Nuevo', 2, 1, null, null
execute sp_RegistrarProducto '006', 'Apple iPad mini 64GB/4GB', 'Usado', 2, 0, null, null
execute sp_RegistrarProducto '007', 'Samsung Galaxy Tab A 128GB/8GB', 'Seminuevo', 2, 1, null, null
execute sp_RegistrarProducto '008', 'Samsung Galaxy Book 128GB/4GB', 'Nuevo', 2, 1, null, null
execute sp_RegistrarProducto '009', 'Lenovo Miix 256GB/6GB', 'Nuevo', 2, 0, null, null
execute sp_RegistrarProducto '010', 'Google Nexus 9 128GB/6GB', 'Usado', 2, 1, null, null
execute sp_RegistrarProducto '011', 'iPhone 13 Pro 128GB/6GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '012', 'Samsung Galaxy S22 Ultra 256GB/8GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '013', 'Google Pixel 6 Pro 128GB/8GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '014', 'Motorola Moto G Power 64GB/4GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '015', 'Google Pixel 6 256GB/8GB', 'Seminuevo', 1, 0, null, null
execute sp_RegistrarProducto '016', 'Apple iPhone SE 128GB/6GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '017', 'Samsung Galaxy A71 64GB/4GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '018', 'Samsung Galaxy A31 64GB/4GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '019', 'Samsung Galaxy Note10 Lite 256GB/6GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '020', 'Realme Narzo 50 5G 128GB/6GB', 'Nuevo', 1, 0, null, null
execute sp_RegistrarProducto '021', 'Realme GT Neo 3 256GB/6GB', 'Usado', 1, 0, null, null
execute sp_RegistrarProducto '022', 'Realme C21 64GB/4GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '023', 'Realme 7 256GB/8GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '024', 'Xiaomi 12 Lite 256GB/8GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '025', 'Xiaomi Redmi Note 11 Pro 5G 128GB/6GB', 'Nuevo', 1, 0, null, null
execute sp_RegistrarProducto '026', 'Xiaomi POCO X4 Pro 5G 256GB/8GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '027', 'Xiaomi Redmi Note 11 Pro 64GB/8GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '028', 'Xiaomi Redmi Note 10 Pro 128GB/6GB', 'Nuevo', 1, 0, null, null
execute sp_RegistrarProducto '029', 'Xiaomi Redmi Note 11S 256GB/8GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '030', 'Redmi 9 64GB/4GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '031', 'Samsung Galaxy S22+ 256GB/8Gb', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '032', 'Samsung Galaxy S21 FE 5G 128GB/6GB', 'Usado', 1, 0, null, null
execute sp_RegistrarProducto '033', 'Samsung Galaxy A52 5G 256GB/8GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '034', 'Samsung Galaxy A51 5G 128GB/6GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '035', 'Samsung Galaxy A32 5G 128GB/8GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '036', 'Samsung Galaxy A21S 64GB/4GB', 'Usado', 1, 0, null, null
execute sp_RegistrarProducto '037', 'LG W41 Pro 128GB/6GB', 'Seminuevo', 1, 1, null, null
execute sp_RegistrarProducto '038', 'LG Q92 5G 64GB/4GB', 'Nuevo', 1, 0, null, null
execute sp_RegistrarProducto '039', 'LG K40S 128GB/6GB', 'Nuevo', 1, 1, null, null
execute sp_RegistrarProducto '040', 'LG X4+ 64GB/4GB', 'Usado', 1, 1, null, null
execute sp_RegistrarProducto '041', 'Cable cargador USB para iPhone', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '042', 'Altavoces Sonos', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '043', 'Protector pantalla iPhone 6', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '044', 'Altavoz Bose inalámbrico portátil', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '045', 'Funda Iphone 6', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '046', 'Bateria externa portátil (RAVPower)', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '047', 'Auriculares Soby bluetooth', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '048', 'Bateria externa Aukey', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '049', 'Cargador USB doble para el carro (válido para Apple y Android)', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '050', 'Case Redmi note 10', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '051', 'Case Redmi note 10 4G', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '052', 'Case Redmi note 10 5G', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '053', 'AirPods ', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '054', 'AirPods 2', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '055', 'AirPods 3', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '056', 'AirPods Pro', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '057', 'AirPods Pro Max', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '058', 'Xiaomi Redmi AirDots', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '059', 'Xiaomi Mi AirDots', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '060', 'AirDots 2', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '061', 'AirDots', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '062', 'Redmi Buds 3', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '063', 'AirDots 3', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '064', 'AirDots S', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '065', 'Xiaomi Mi True Wireless Earbuds', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '066', 'Xiaomi Mi Band 3', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '067', 'Xiaomi Mi Band 4', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '068', 'Xiaomi Mi Band 5', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '069', 'Xiaomi Mi Band 6', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '070', 'Xiaomi Mi Band 7', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '071', 'Apple Watch Series 3.', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '072', 'Apple Watch Series 4', 'Nuevo', 3, 0, null, null
execute sp_RegistrarProducto '073', 'Apple Watch Series 5', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '074', 'Apple Watch Series SE', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '075', 'Apple Watch Series 6', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '076', 'Apple Watch Series 7', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '077', 'Samsung Galaxy Watch 4', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '078', 'Samsung Galaxy Fit', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '079', 'Samsung Gear Fit 2 Pro', 'Nuevo', 3, 1, null, null
execute sp_RegistrarProducto '080', 'Samsung Galaxy Watch Active2', 'Nuevo', 3, 1, null, null
execute SP_MostrarProducto 

GO

/* ---------- PROCEDIMIENTOS PARA CLIENTE -----------------*/
create procedure SP_MostrarCliente
as
select * from CLIENTE


GO

create PROC sp_RegistrarCliente(
@Documento varchar(16),
@NombreCompleto varchar(50),
@Correo varchar(50),
@Telefono varchar(12),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 0
	DECLARE @IDPERSONA INT 
	IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Documento = @Documento)
	begin
		insert into CLIENTE(Documento,NombreCompleto,Correo,Telefono,Estado) values (
		@Documento,@NombreCompleto,@Correo,@Telefono,@Estado)

		set @Resultado = SCOPE_IDENTITY()
	end
	else
		set @Mensaje = 'El numero de documento ya existe'
end

go

create PROC sp_ModificarCliente(
@IdCliente int,
@Documento varchar(16),
@NombreCompleto varchar(50),
@Correo varchar(50),
@Telefono varchar(12),
@Estado bit,
@Resultado bit output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 1
	DECLARE @IDPERSONA INT 
	IF NOT EXISTS (SELECT * FROM CLIENTE WHERE Documento = @Documento and IdCliente != @IdCliente)
	begin
		update CLIENTE set
		Documento = @Documento,
		NombreCompleto = @NombreCompleto,
		Correo = @Correo,
		Telefono = @Telefono,
		Estado = @Estado
		where IdCliente = @IdCliente
	end
	else
	begin
		SET @Resultado = 0
		set @Mensaje = 'El numero de documento ya existe'
	end
end

GO

Exec sp_RegistrarCliente '036-230911-2180D','Maria Elena Cordoba Espinoza','clearMelissa@msn.com',22458956,1,null, null
Exec sp_RegistrarCliente '001-240589-4789Y','Carlos Emilio Ugarte Sanchez','ugartecar@gmail.com',87459878,0,null, null
Exec sp_RegistrarCliente '289-385423-4470A','Juan Jose Oporta Brenes','Evandoubtful@gmx.de',54689523,0,null, null
Exec sp_RegistrarCliente '401-250498-0235J','Miriam de los Angeles Alvarez','miralrez@gmail.com',78956486,0,null, null
Exec sp_RegistrarCliente '043-279296-9810Y','Maria Luisa Cano Pineda','Lukefrightened@centurytel.net',22456535,0,null, null
Exec sp_RegistrarCliente '001-030488-0052D','Samir Alonso Matamoros Pineda','ugartecar@gmail.com',87965236,0,null, null
Exec sp_RegistrarCliente '089-190321-0670R','Roberto Carlos Osorio Peña','wildTommy42@telenet.be',22360230,0,null, null
Exec sp_RegistrarCliente '045-345684-5660L','William Esteban Espinoza Rodriguez','espinoguez@yahoo.es',22689563,0,null, null
Exec sp_RegistrarCliente '290-339007-4060Y','Maria Isabel Velez Solis','determinedLance@outlook.com',56895325,1,null, null
Exec sp_RegistrarCliente '001-060490-1025T','Rommel Antonio Martinez Cuadra','martinez045@gmail.com',88834914,1,null, null
Exec sp_RegistrarCliente '048-245268-1108K','Stella Maris Manzanarez Tapia','Hilarycruel@yahoo.com.sg',22540202,1,null, null
Exec sp_RegistrarCliente '001-030285-2156N','Camila Sofia Gonzalez Perez','Goncal04@gmail.com',75486235,1,null, null
Exec sp_RegistrarCliente '081-342194-6730J','Juan Ernesto Solorzano Valle','Steveprecious@laposte.net',54265301,0,null, null
Exec sp_RegistrarCliente '001-081065-5230M','Archivaldo Jose Mendoza Berviz','ugartecar@gmail.com',22896532,0,null, null
Exec sp_RegistrarCliente '291-300507-3395M','Maria Teresa Molina Perez','filthyTyler64@cox.net',78401010,1,null, null
Exec sp_RegistrarCliente '001-300587-2504L','Jairo Antonio Lopez Obregon','obregonyur@gmail.com',76544558,1,null, null
Exec sp_RegistrarCliente '203-368036-7780T','Luis Alberto Alvarez Gonzalez','crowdedAshlee@juno.com',22410506,0,null, null
Exec sp_RegistrarCliente '247-190580-0001L','Ever ALfredo Gomez Garcia','avergoge@gmail.com',85235498,1,null, null
Exec sp_RegistrarCliente '243-221727-8302X','Marta Susana Mendoza','Shannonpleasant@laposte.net',22789865, 1,null, null
Exec sp_RegistrarCliente '001-050869-2780R','Indira Maria Flores Jarquin','jarindiiraa@gmail.com',88599271,1,null, null
Exec sp_RegistrarCliente '001-140896-0234F','Melba Luz Alaniz Oporta','colorfulRyan@uol.com.br',22667895,1,null, null
Exec sp_RegistrarCliente '089-198783-1083C','Pedro Missael Lezama Cordoba','breakableSavannah93@blueyonder.co.uk',78451201,0,null, null
Exec sp_RegistrarCliente '123-281175-0001Q','Esteban Tellez Pinell','pinelltel@gmail.com',742301461,1,null, null
Exec sp_RegistrarCliente '283-309584-1110L','Miguel Angel Busto Prado','unsightlyLindsey@sky.com',22701425,1,null, null
Exec sp_RegistrarCliente '401-020299-1008T','Angela Maria Espinales Soza','angelsoz@gmail.com',72014563,1,null, null
Exec sp_RegistrarCliente '165-262074-226OJ','Jose Luis Ugarte Sanchez','smoggyGrace83@uol.com.br',789456518,0,null, null
Exec sp_RegistrarCliente '562-251282-0001M','Maria Daniela Barberena Perales','damperal@gmail.com',85623201,0,null, null
Exec sp_RegistrarCliente '166-385718-0470Y','Jorge Alberto Fernandez Sequeira','fineDustin39@mail.ru',23451020,0,null, null
Exec sp_RegistrarCliente '361-324531-0420P','Alberto Ernesto Salmeron Quiroz','famousTasha@mac.com',21030546,1,null, null
Exec sp_RegistrarCliente '401-120598-8020D','Jose Alberto Sanchez Baca','baccajos@gmail.com',87562301,1,null, null
Exec sp_RegistrarCliente '162-205703-4204Q','Maria Ester Baltodano Nuñez','Allenbeautiful@yandex.ru',22336040,1,null, null
Exec sp_RegistrarCliente '610-081093-0555M','Aldo Danilo Baez Solis','baezAldo@gmail.com',87562102,0,null, null
Exec sp_RegistrarCliente '247-300174-1323S','Bismarck Renne Quezada Borge','quezborge@gmail.com',80203025,0,null, null
Exec sp_RegistrarCliente '090-321295-8530Y','Maria Rosa Berviz Reyes','Darrenlong@rambler.ru',228450215,1,null, null
Exec sp_RegistrarCliente '092-274378-4800Q','Miguel Angel Alaniz Ortiz','putridDevin68@sbcglobal.net',22667895,1,null, null
Exec sp_RegistrarCliente '243-338544-6960P','Eduardo Virgili Morales Arauz','cleanDeanna@tiscali.it',58702511,1,null, null
Exec sp_RegistrarCliente '001-220295-0068H','Paula Emilia Brenes Saenz','ugartecar@gmail.com',74203569,0,null, null
Exec sp_RegistrarCliente '281-246222-4590S','Juan Carlo Gutierrez Rocha','grieving@hotmail.com',22547895,1,null, null
Exec sp_RegistrarCliente '163-204240-4334D','Ana Maria Castillo Mendoza','Staceybusy@live.ca',23184599,1,null, null
Exec sp_RegistrarCliente '291-271600-4620E','Carlos Alberto Fuentes Cuadra','impossibleJacob@libero.it',54336520,1,null, null
Exec sp_RegistrarCliente '082-349556-2520N','Maria Cristina Roman Perez','toughKristopher45@qq.com',88880005,1,null, null
Exec sp_RegistrarCliente '001-030457-0000X','Joaquin Alexander Guzman Maltez','ugartecar@gmail.com',22502112,0,null, null
Exec sp_RegistrarCliente '245-228035-7889F','Maria Del Carmen Martinez Picado','livelyJorge@bol.com.br',78930010,1,null, null
Exec sp_RegistrarCliente '087-279059-8400P','Maria Angelica Sandoval Lopez','mistyRegina86@bol.com.br',74089530,1,null, null
Exec sp_RegistrarCliente '001-050592-0004Y','Tania Carolina Portocarrero Andino','menwon@gmail.com',22678956,0,null, null
Exec sp_RegistrarCliente '120-734656-4449Y','Francisco Antonio Aburto Mendoza','Stacyfunny@aol.com',22410659,1,null, null
Exec sp_RegistrarCliente '128-277820-2209N','Norma Beatriz Sandino Valle','Ginaoutrageous@tiscali.it',88754687,1,null, null
Exec sp_RegistrarCliente '082-024094-9721D','Domingo Valerio Venegas López','Lancethoughtless@optusnet.com.au',78495208,0,null, null
Exec sp_RegistrarCliente '090-321295-8530E','Jorge Omar Guerrero Díaz','kindCatherine@hotmail.de',76262471,1,null, null
Exec sp_RegistrarCliente '009-227437-8480Q','Mirta Beatriz Mendoza Ferreira','Adrianainquisitive@laposte.net',81202419,1,null, null
Exec sp_RegistrarCliente '001-240598-0012C','Ernesto Jose Farías Ramírez','vastDerrick@outlook.com',76677734,1,null, null
Exec sp_RegistrarCliente '245-020470-2545Z','Maria Mercedes San Martín  Castillo','gleamingMelody@web.de',83969269,1,null, null
Exec sp_RegistrarCliente '005-141165-0215M','Maria Angelica Sobalvarro Cuadra','mistyRegina86@bol.com.br',54203018,1,null, null
Exec sp_RegistrarCliente '248-050875-2221X','Carlos Roberto Marchena Lopez','jitteryDevin@bluewin.ch',22564796,1,null, null
Exec sp_RegistrarCliente '785-050372-5489P','Jose Antonio Marin Reyes','enviousDesiree51@terra.com.br',87569523,1,null, null
Exec sp_RegistrarCliente '001-120569-2001M','Pedro Pablo Castillo Molina','sibejo3325@kahase.com',89785645,1,null, null
Exec sp_RegistrarCliente '125-081196-1456F','Carlos Jose Carvajal Quiroz','c124fc5534@catdogmail.live',54698652,1,null, null
Exec sp_RegistrarCliente '205-130569-4100D','Yaoska Carolina Lara Hurtado','nurdoropsa@vusra.com',23569896,1,null, null
Exec sp_RegistrarCliente '001-050595-7896A','Valeria Guadalupe Cajina Ruiz','pkozeyp_i824r@oysa.life',78965400,1,null, null
Exec sp_RegistrarCliente '145-987569-0232T','Fernando De Jesus Guzman Castro','jesus32_det@yahoo.es',78985868,1,null, null
Exec sp_RegistrarCliente '745-906542-6158Ñ','Virginia Medal Perez Salmeron','medal_059@hotmail.com',89025602,1,null, null
Exec sp_RegistrarCliente '004-897856-2031P','Elena del Socorro Bustillo Vanegas','socorro_bust@outlook.com',54698631,1,null, null
Exec sp_RegistrarCliente '326-030289-6548R','Rodolfo Leonel Chavarria Mendez','rodofcha@gmail.com',70702530,1,null, null
Exec sp_RegistrarCliente '879-542689-0121C','Donald Roberto Huembes Jimenez','hueji121@gmail.com',25648956,1,null, null
Exec sp_RegistrarCliente '001-854566-2023G','Reyna Elizabeth Pineda Arauz','ellotrdn_2023@gmail.com',20201415,1,null, null
Exec sp_RegistrarCliente '001-141298-5623H','Gerson Sotelo Sanchez','pgersan_76@yahoo.es',89785601,1,null, null
Exec sp_RegistrarCliente '446-270875-0001E','Javier Antonio Melendez Garcia','melen001@outlook.com',59692125,1,null, null
Exec sp_RegistrarCliente '161-061102-1004Q','Cristhian Sofia Moreno Sandoval','morenofin_hys@use.fisl',24589656,1,null, null
Exec sp_RegistrarCliente '021-210494-0000Y','Jorge Alberto Jarquin Suazo','suazojorge76@yahoo.es',22365698,1,null, null
Exec sp_RegistrarCliente '701-459803-2120P','Jose Luis Pastran Zapata','pastranklo@esx.life',1,78982640,null, null
Exec sp_RegistrarCliente '874-621032-5677X','Gustavo Adolfo Martinez Salinas','salinmar_gust@yahoo.es',23659872,1,null, null
Exec sp_RegistrarCliente '320-146894-1257Y','Maria Victoria Picado Cajina','cajina_victoria@gmail.com',58975632,1,null, null
Exec sp_RegistrarCliente '015-468224-8613Q','Lorena Prudencia Blanco Urrutia','blancoprudencia84@gmail.com',22659863,1,null, null
Exec sp_RegistrarCliente '023-156489-2011K','Ruth Maria Barberena Luna','barberenaruth76@hotmail.com',76985423,1,null, null
Exec sp_RegistrarCliente '741-589641-0548R','Azarias Jose Chavez Arana','chazaran89@outlook.com',23564892,1,null, null
Exec sp_RegistrarCliente '032-558264-0436U','Kimberly Alexa Soza Morales','kimsomo@gmail.com',54698868,1,null, null
Exec sp_RegistrarCliente '156-235698-4565J','Jeremy Evertz FLores Brenes','evertzssss45@yahoo.com',78769258,1,null, null
Exec sp_RegistrarCliente '401-310487-6523F','Moises Israel Polanco Maltez','moisesisrap@yahoo.es',78426950,1,null, null
Exec sp_RegistrarCliente '789-280988-0000D','Alvaro Josue Moreira Davila','alvaro968@hotmail.com',55186158,1,null, null
Exec sp_RegistrarCliente '456-231065-5465S','Valeria Sofia Munguia Prado','pradovlaeria@gmail.com',87456255,1,null, null
execute SP_MostrarCliente

GO

/* ---------- PROCEDIMIENTOS PARA PROVEEDOR -----------------*/
create procedure SP_MostrarProveedor 
as
select * from PROVEEDOR


GO


create PROC sp_RegistrarProveedor(
@Documento varchar(16),
@RazonSocial varchar(50),
@Correo varchar(50),
@Telefono varchar(12),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 0
	DECLARE @IDPERSONA INT 
	IF NOT EXISTS (SELECT * FROM PROVEEDOR WHERE Documento = @Documento)
	begin
		insert into PROVEEDOR(Documento,RazonSocial,Correo,Telefono,Estado) values (
		@Documento,@RazonSocial,@Correo,@Telefono,@Estado)

		set @Resultado = SCOPE_IDENTITY()
	end
	else
		set @Mensaje = 'El numero de documento ya existe'
end

GO

create PROC sp_ModificarProveedor(
@IdProveedor int,
@Documento varchar(16),
@RazonSocial varchar(50),
@Correo varchar(50),
@Telefono varchar(12),
@Estado bit,
@Resultado bit output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 1
	DECLARE @IDPERSONA INT 
	IF NOT EXISTS (SELECT * FROM PROVEEDOR WHERE Documento = @Documento and IdProveedor != @IdProveedor)
	begin
		update PROVEEDOR set
		Documento = @Documento,
		RazonSocial = @RazonSocial,
		Correo = @Correo,
		Telefono = @Telefono,
		Estado = @Estado
		where IdProveedor = @IdProveedor
	end
	else
	begin
		SET @Resultado = 0
		set @Mensaje = 'El numero de documento ya existe'
	end
end


go

create procedure sp_EliminarProveedor(
@IdProveedor int,
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (
	 select *  from PROVEEDOR p
	 inner join COMPRA c on p.IdProveedor = c.IdProveedor
	 where p.IdProveedor = @IdProveedor
	)
	begin
	 delete top(1) from PROVEEDOR where IdProveedor = @IdProveedor
	end
	ELSE
	begin
		SET @Resultado = 0
		set @Mensaje = 'El proveedor se encuentara relacionado a una compra'
	end

end

go

execute sp_RegistrarProveedor '081-240398-0010T', 'Vendedor de dispositivos LG', 'diontone@outlook.com', 85681463, 1, null, null
execute sp_RegistrarProveedor '081-230197-1012H', 'Vendedor de dispositivos Motorola', 'moto76@outlook.com', 82681464, 1, null, null
execute sp_RegistrarProveedor '031-270994-9823U', 'Vendedor de dispositivos Samsung', 'rio876@gmail.com', 82681498, 1, null, null
execute sp_RegistrarProveedor '001-150990-3498Y', 'Vendedor de dispositivos Google', 'pablolose@outlook.com', 89681464, 1, null, null
execute sp_RegistrarProveedor '020-240496-0657Y', 'Vendedor de dispositivos Realme', 'teomalez@outlook.com', 82681464, 1, null, null
execute sp_RegistrarProveedor '001-140195-0984T', 'Vendedor de dispositivos Xiaomi', 'pierogomez@outlook.com', 86681464, 1, null, null
execute sp_RegistrarProveedor '011-250197-0028T', 'Vendedor de dispositivos Huawei', 'romeo9898@gmail.com', 87681464, 1, null, null
execute sp_RegistrarProveedor '001-301092-0010N', 'Vendedor de dispositivos Lenovo', 'camiloperez@gmail.com', 85651464, 1, null, null
execute sp_RegistrarProveedor '081-241293-0010H', 'Vendedor de dispositivos Apple', 'pedropablo@outlook.com', 85349834, 1, null, null
execute sp_RegistrarProveedor '021-142323-0230S', 'Cheap Devices', 'usaave87.devices@outlook.com', 85349834, 1, null, null
execute SP_MostrarProveedor

GO


/* PROCESOS PARA REGISTRAR UNA COMPRA */

CREATE TYPE [dbo].[EDetalle_Compra] AS TABLE(
	[IdProducto] int NULL,
	[PrecioCompra] decimal(18,2) NULL,
	[PrecioVenta] decimal(18,2) NULL,
	[Cantidad] int NULL,
	[MontoTotal] decimal(18,2) NULL
)


GO


CREATE PROCEDURE sp_RegistrarCompra(
@IdUsuario int,
@IdProveedor int,
@TipoDocumento varchar(500),
@NumeroDocumento varchar(500),
@MontoTotal decimal(18,2),
@DetalleCompra [EDetalle_Compra] READONLY,
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	
	begin try

		declare @idcompra int = 0
		set @Resultado = 1
		set @Mensaje = ''

		begin transaction registro

		insert into COMPRA(IdUsuario,IdProveedor,TipoDocumento,NumeroDocumento,MontoTotal)
		values(@IdUsuario,@IdProveedor,@TipoDocumento,@NumeroDocumento,@MontoTotal)

		set @idcompra = SCOPE_IDENTITY()

		insert into DETALLE_COMPRA(IdCompra,IdProducto,PrecioCompra,PrecioVenta,Cantidad,MontoTotal)
		select @idcompra,IdProducto,PrecioCompra,PrecioVenta,Cantidad,MontoTotal from @DetalleCompra


		update p set p.Stock = p.Stock + dc.Cantidad, 
		p.PrecioCompra = dc.PrecioCompra,
		p.PrecioVenta = dc.PrecioVenta
		from PRODUCTO p
		inner join @DetalleCompra dc on dc.IdProducto= p.IdProducto

		commit transaction registro


	end try
	begin catch
		set @Resultado = 0
		set @Mensaje = ERROR_MESSAGE()
		rollback transaction registro
	end catch

end


GO

/* PROCESOS PARA REGISTRAR UNA VENTA */

CREATE TYPE [dbo].[EDetalle_Venta] AS TABLE(
	[IdProducto] int NULL,
	[PrecioVenta] decimal(18,2) NULL,
	[Cantidad] int NULL,
	[SubTotal] decimal(18,2) NULL
)


GO


create procedure usp_RegistrarVenta(
@IdUsuario int,
@TipoDocumento varchar(500),
@NumeroDocumento varchar(500),
@DocumentoCliente varchar(500),
@NombreCliente varchar(500),
@MontoPago decimal(18,2),
@MontoCambio decimal(18,2),
@MontoTotal decimal(18,2),
@DetalleVenta [EDetalle_Venta] READONLY,                                      
@Resultado bit output,
@Mensaje varchar(500) output
)
as
begin
	
	begin try

		declare @idventa int = 0
		set @Resultado = 1
		set @Mensaje = ''

		begin  transaction registro

		insert into VENTA(IdUsuario,TipoDocumento,NumeroDocumento,DocumentoCliente,NombreCliente,MontoPago,MontoCambio,MontoTotal)
		values(@IdUsuario,@TipoDocumento,@NumeroDocumento,@DocumentoCliente,@NombreCliente,@MontoPago,@MontoCambio,@MontoTotal)

		set @idventa = SCOPE_IDENTITY()

		insert into DETALLE_VENTA(IdVenta,IdProducto,PrecioVenta,Cantidad,SubTotal)
		select @idventa,IdProducto,PrecioVenta,Cantidad,SubTotal from @DetalleVenta

		commit transaction registro

	end try
	begin catch
		set @Resultado = 0
		set @Mensaje = ERROR_MESSAGE()
		rollback transaction registro
	end catch

end

go


create PROC sp_ReporteCompras(
 @fechainicio varchar(10),
 @fechafin varchar(10),
 @idproveedor int
 )
  as
 begin

  SET DATEFORMAT dmy;
   select 
 convert(char(10),c.FechaRegistro,103)[FechaRegistro],c.TipoDocumento,c.NumeroDocumento,c.MontoTotal,
 u.NombreCompleto[UsuarioRegistro],
 pr.Documento[DocumentoProveedor],pr.RazonSocial,
 p.Codigo[CodigoProducto],p.Nombre[NombreProducto],ca.Descripcion[Categoria],dc.PrecioCompra,dc.PrecioVenta,dc.Cantidad,dc.MontoTotal[SubTotal]
 from COMPRA c
 inner join USUARIO u on u.IdUsuario = c.IdUsuario
 inner join PROVEEDOR pr on pr.IdProveedor = c.IdProveedor
 inner join DETALLE_COMPRA dc on dc.IdCompra = c.IdCompra
 inner join PRODUCTO p on p.IdProducto = dc.IdProducto
 inner join CATEGORIA ca on ca.IdCategoria = p.IdCategoria
 where CONVERT(date,c.FechaRegistro) between @fechainicio and @fechafin
 and pr.IdProveedor = iif(@idproveedor=0,pr.IdProveedor,@idproveedor)
 end

 go

 CREATE PROC sp_ReporteVentas(
 @fechainicio varchar(10),
 @fechafin varchar(10)
 )
 as
 begin
 SET DATEFORMAT dmy;  
 select 
 convert(char(10),v.FechaRegistro,103)[FechaRegistro],v.TipoDocumento,v.NumeroDocumento,v.MontoTotal,
 u.NombreCompleto[UsuarioRegistro],
 v.DocumentoCliente,v.NombreCliente,
 p.Codigo[CodigoProducto],p.Nombre[NombreProducto],ca.Descripcion[Categoria],dv.PrecioVenta,dv.Cantidad,dv.SubTotal
 from VENTA v
 inner join USUARIO u on u.IdUsuario = v.IdUsuario
 inner join DETALLE_VENTA dv on dv.IdVenta = v.IdVenta
 inner join PRODUCTO p on p.IdProducto = dv.IdProducto
 inner join CATEGORIA ca on ca.IdCategoria = p.IdCategoria
 where CONVERT(date,v.FechaRegistro) between @fechainicio and @fechafin
end

go