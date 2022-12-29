--Them Nhan Vien (TruongPhongDH)
Create proc sp_ThemNV_DH
	@HoTen nvarchar(50),
	@GioiTinh bit,
	@NGAYSINH int,
	@IDPB int,
	@IDBP int,
	@IDCV int

as
begin
	if @IDPB=2002
	begin
		insert into tb_NHANVIEN(HOTEN,GIOITINH,NGAYSINH,IDPB,IDBP,IDCV)
		values(@HoTen,@GioiTinh,@NGAYSINH,@IDPB,@IDBP,@IDCV)
	end
	else
		print 'Nhan Vien Khong Thuoc Phong Dieu Hanh'
end

----Khen Thuong Nhan Vien Phong Dieu hanh
create proc sp_KT_NV_DH
	@MANV char(5),
	@SOKTKL int,
	@NOIDUNG nvarchar(50),
	@LOAI int

as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV and IDPB=2002)
	begin
		insert into tb_KHENTHUONG_KYLUAT(SOKTKL,NOIDUNG,NGAY,MANV,LOAI,THANG,NAM)
		values(@SOKTKL,@NOIDUNG,GETDATE(),@MANV,@LOAI,MONTH(GETDATE()),YEAR(GETDATE()))
	end
	else
		print 'Nhan Vien Khong Ton Tai Hoac Khong Thuoc Phong Ban Ban Quan Ly'
end

-- Phan cong tang ca trong Dieu Hanh

create proc sp_PC_TC_DH
	@SOGIO float,
	@MANV char(5),
	@IDLOAICA int

as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV and IDPB=2002)
	begin
		insert into tb_TANGCA(NAM,THANG,NGAY,SOGIO,MANV,IDLOAICA)
		values(YEAR(GETDATE()),MONTH(GETDATE()),DAY(GETDATE()),@SOGIO,@MANV,@IDLOAICA)
	end
	else
		print 'Nhan Vien Khong Ton Tai Hoac Khong Thuoc Phong Ban Ban Quan Ly'
end

-- Moi
--Them nhan vien chung

alter proc sp_THEM_NV
	@HOTEN nvarchar(50),
	@GIOTINH bit,
	@NGAYSINH datetime,
	@DIENTHOAI nvarchar(50),
	@CCCD nvarchar(50),
	@DIACHI nvarchar(500),
	@IDPB int,
	@IDBP int,
	@IDCV int,
	@IDTD int

as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_NHANVIEN with (updlock)
	begin try
		if exists ( select * from tb_NHANVIEN WHERE HOTEN = @HOTEN AND CCCD = @CCCD)
		begin
			raiserror ('Nhan vien da ton tai, ten va cccd khong duoc trung', 16,1)
		end
		else
		begin
			waitfor delay '00:00:05'
			insert into tb_NHANVIEN(HOTEN,GIOITINH,NGAYSINH,DIENTHOAI,CCCD,DIACHI,IDPB,IDBP,IDCV,IDTD)
			values(@HOTEN,@GIOTINH,@NGAYSINH,@DIENTHOAI,@CCCD,@DIACHI,@IDPB,@IDBP,@IDCV,@IDTD)
		end
		commit
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = 'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR (@errorMessage, 16,1)
	end catch
	
end

--Them Ung Luong

alter proc sp_THEM_UL
	@SOTIEN float,
	@MANV char(5)

as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_UNGLUONG with (updlock)
	begin try
		if not exists ( select MANV from tb_NHANVIEN WHERE MANV=@MANV)
		begin
			raiserror ('Nhan vien khong ton tai', 16,1)
		end
		else
		begin
			waitfor delay '00:00:05'
			insert into tb_UNGLUONG(NAM,THANG,NGAY,SOTIEN,TRANGTHAI,MANV)
			values(Year(getdate()),MONTH(getdate()),day(getdate()),@SOTIEN,1,@MANV)
		end
		commit
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = 'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR (@errorMessage, 16,1)
	end catch
	
end

execute sp_THEM_UL 5000000, 'NV004'

--Them vao bang nv_phucap

alter proc sp_THEM_NV_PC
	@MANV char(5),
	@IDPC int

as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_NHANVIEN_PHUCAP with (updlock)
	begin try
		if not exists ( select MANV from tb_NHANVIEN WHERE MANV=@MANV)
		begin
			raiserror ('Nhan vien khong ton tai', 16,1)
		end
		else
		begin
			waitfor delay '00:00:05'
			insert into tb_NHANVIEN_PHUCAP(MANV,IDPC)
			values(@MANV,@IDPC)
		end
		commit
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = 'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR (@errorMessage, 16,1)
	end catch
	
end

-- them vao bang khen thuong ky luat

alter proc sp_THEM_KT_KL
	@SOKTKL int,
	@NOIDUNG nvarchar(500),
	@MANV char(5),
	@LOAI int

as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_KHENTHUONG_KYLUAT with (updlock)
	begin try
		if not exists ( select MANV from tb_NHANVIEN WHERE MANV=@MANV)
		begin
			raiserror ('Nhan vien khong ton tai', 16,1)
		end
		else
		begin
			waitfor delay '00:00:05'
			insert into tb_KHENTHUONG_KYLUAT(SOKTKL,NOIDUNG,NGAY,MANV,LOAI,THANG,NAM)
			values(@SOKTKL,@NOIDUNG,GETDATE(),@MANV,@LOAI,MONTH(getdate()),year(getdate()))
		end
		commit
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = 'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR (@errorMessage, 16,1)
	end catch
	
end

-- Thanh Toan Luong
alter proc sp_TT_Luong
	@MATHANGCONG int,
	@ID int

as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_THANHTOANLUONG with (readcommitted)
	begin try
		if exists (select MATHANGCONG from tb_THANGCONGCHITIET where MATHANGCONG=@MATHANGCONG)
		begin
			if exists (select ID from tb_UNGLUONG where ID=@ID and TRANGTHAI=1) or @ID is Null
			begin
				waitfor delay '00:00:05'
				update tb_UNGLUONG
				set TRANGTHAI = 0
				where ID=@ID

				insert into tb_THANGCONG(MATHANGCONG)
				values(@MATHANGCONG)
				
				insert into tb_THANHTOANLUONG(ID,MATHANGCONG)
				values(@ID,@MATHANGCONG)
			end
			else
				print('Ma IDUL khong tin tai hoac da duoc thanh toan')
		end
		else
			print('Ma Thang Cong Khong Ton Tai')
		commit
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = 'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR (@errorMessage, 16,1)
	end catch
	
end

execute sp_TT_Luong 20221204, 6009
execute sp_TT_Luong 20221205, NULL
execute sp_TT_Luong 20221206, NULL
execute sp_TT_Luong 20221207, NULL
execute sp_TT_Luong 20221208, NULL
execute sp_TT_Luong 20221209, NULL
execute sp_TT_Luong 20221210, NULL
execute sp_TT_Luong 20221211, NULL
execute sp_TT_Luong 20221212, NULL
execute sp_TT_Luong 20221213, NULL
execute sp_TT_Luong 20221214, NULL
execute sp_TT_Luong 20221215, NULL
execute sp_TT_Luong 20221216, NULL
execute sp_TT_Luong 20221217, NULL
execute sp_TT_Luong 20221218, NULL
execute sp_TT_Luong 20221219, NULL
execute sp_TT_Luong 20221220, NULL
execute sp_TT_Luong 20221221, NULL
execute sp_TT_Luong 20221222, NULL
execute sp_TT_Luong 20221223, NULL
execute sp_TT_Luong 20221224, NULL
execute sp_TT_Luong 20221225, NULL
execute sp_TT_Luong 20221226, NULL
execute sp_TT_Luong 20221227, NULL
execute sp_TT_Luong 20221228, NULL
execute sp_TT_Luong 20221229, NULL
execute sp_TT_Luong 20221230, NULL
execute sp_TT_Luong 20221231, NULL
execute sp_TT_Luong 20221232, NULL
execute sp_TT_Luong 20221233, NULL