--1 trigger kiem tra tuoi nhan vien
alter trigger trg_KiemTra_Tuoi_NhanVien
on tb_NhanVien
after insert
as
begin
	declare @HOTEN nvarchar(50), @GIOITINH Bit, @NGAYSINH datetime, @DIENTHOAI nvarchar(50), @CCCD nvarchar(50), @DIACHI NVARCHAR(500), @HINHANH varbinary(max),
	@IDPB int, @IDBP int, @IDCV int, @IDTD int, @MA_NQL char(5)
	select @HOTEN=HOTEN,@GIOITINH=GIOITINH,@NGAYSINH=NGAYSINH, @DIENTHOAI=DIENTHOAI, @CCCD=CCCD, @DIACHI=DIACHI, @HINHANH=HINHANH, @IDPB=IDPB, @IDBP=IDBP, 
	@IDCV=IDCV, @IDTD=IDTD, @MA_NQL=MA_NQL
	from inserted
	if (year(getdate()) - year(@NGAYSINH))<18
	begin
		raiserror ('Nhan Vien Phai Tren 18 Tuoi', 16,1)
		rollback tran
		return
	end
end
drop trigger trg_KiemTra_Tuoi_NhanVien
insert into tb_NHANVIEN (HOTEN, GIOITINH, NGAYSINH, DIENTHOAI, CCCD, DIACHI, HINHANH, IDPB, IDBP, IDCV, IDTD, MA_NQL)
values (N'Nguyễn Văn Nam', 0, '20001010', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)


--2 Trigger tu dong them hop dong khi tao nhan vien

create trigger trg_ThemHD_NV
on tb_NHANVIEN
after insert
as
begin
	declare @MANV char(5), @NGAYKI datetime, @NGAYBATDAU datetime, @NGAYKETTHUC datetime, @HANHD int
	select @MANV=MANV, @NGAYKI=GETDATE(), @NGAYBATDAU=@NGAYKI+5, @HANHD=5, @NGAYKETTHUC=DATEADD(YEAR, @HANHD, @NGAYKI) from inserted
	insert into tb_HOPDONG(NGAYBAYDAU, NGAYKETTHUC, NGAYKY, MANV, HANHD)
	values(@NGAYBATDAU,@NGAYKETTHUC, @NGAYKI,@MANV,@HANHD)

end

--3 Trigger kiem tra update nhanvien

create trigger trg_KiemTra_ThongTinSua
on tb_NHANVIEN
after update
as
begin
	declare @old_Hoten nvarchar(50), @old_ngaysinh datetime, @old_dienthoai nvarchar(50), @old_DiaChi nvarchar(500)
	declare @new_manv char(5),
	@new_Hoten nvarchar(50), @new_ngaysinh datetime, @new_dienthoai nvarchar(50), @new_DiaChi nvarchar(500)
	select @old_Hoten=HOTEN, @old_ngaysinh=NGAYSINH, @old_dienthoai=DIENTHOAI, @old_DiaChi=DIACHI
	from deleted
	
	select @new_Hoten=HOTEN, @new_ngaysinh=NGAYSINH, @new_dienthoai=DIENTHOAI,@new_DiaChi=DIACHI 
	from inserted

	if(UPDATE(MANV))
	begin
		rollback tran
		raiserror('Khong duoc sua ma nhan vien',16,1)
		return
	end
	if(UPDATE(HOTEN) and @old_Hoten=@new_Hoten)
	begin
		rollback tran
		raiserror('Ho ten moi phai khac ho ten cu',16,1)
	end
	if(UPDATE(NGAYSINH) and @old_ngaysinh=@new_ngaysinh)
	begin
		rollback tran
		raiserror('Ngay sinh moi phai khac ngay sinh cu',16,1)
	end
	if(UPDATE(NGAYSINH) and year(getdate())-year(@new_ngaysinh)<18)
	begin
		rollback tran
		raiserror('Nhan vien phai tren 18 tuoi',16,1)
	end
	if(UPDATE(DIENTHOAI) and @old_dienthoai=@new_dienthoai)
	begin
		rollback tran
		raiserror('So dien thoai moi phai khac so dien thoai cu',16,1)
	end
	if(UPDATE(DIACHI) and @old_DiaChi=@new_DiaChi)
	begin
		rollback tran
		raiserror('Dia chi moi phai khac so dia chi cu',16,1)
	end
end

drop trigger trg_KiemTra_ThongTinSua

--4 Trigger kiem tra tien ung

alter trigger trg_KiemTra_TienUng
on tb_UNGLUONG
instead of insert
as
begin
	declare @MANV char(5), @Nam int, @Thang int, @Sotien float, @Ngay int, @Trangthai bit
	select @MANV=MANV, @Nam=NAM, @Thang=THANG, @Sotien=SOTIEN, @Ngay=NGAY, @Trangthai=1 from inserted

	if exists (select NAM, THANG from tb_UNGLUONG where MANV=@MANV and NAM=@Nam and Thang=@Thang)
	begin
		raiserror ('Moi Nhan Vien Khong Duoc Ung Qua 1 Lan 1 Thang', 16,1)
		rollback tran
		return
	end
	if @Sotien>5000000
	begin
		raiserror ('Tien Ung Khong Duoc Qua 5000000', 16,1)
		rollback tran
		return
	end
	insert into tb_UNGLUONG(NAM, THANG, NGAY, SOTIEN, TRANGTHAI, MANV)
	values(@Nam, @Thang, @Ngay, @Sotien, @Trangthai, @MANV)
end

drop trigger trg_KiemTra_TienUng

insert into tb_UNGLUONG(NAM, THANG, SOTIEN,MANV)
values(2022, 12, 5000000, 'NV003')

--5 Kiem tra bao hiem

alter trigger trg_KiemTra_BaoHiem
on tb_BAOHIEM
instead of insert
as
begin
	declare @MANV char(5), @NoiCap nvarchar(50), @NoiDK nvarchar(50)
	select @MANV=MANV, @NoiCap=NOICAP, @NoiDK=NOIDK from inserted

	if exists (select MANV from tb_BAOHIEM where MANV=@MANV)
	begin
		raiserror ('Moi Nhan Vien Chi Co 1 Bao Hiem', 16,1)
		rollback tran
		return
	end
	insert into tb_BAOHIEM(NGAYCAP, NOICAP, NOIDK, MANV)
	values(GETDATE(), @NoiCap, @NoiDK, @MANV)
end

insert into tb_BAOHIEM(NOICAP, NOIDK, MANV)
values(N'Hồ Chí Minh', N'Bệnh Viện Tp.HCM', 'NV034')

--6 HeSoLuong Va BienDongHSL

alter trigger trg_HSL_BIENDONGHSL
on tb_HESOLUONG
after update, insert, delete
as
begin
	declare @MAHSL char(4), @BAC int, @NhomNgach char(20), @HeSoLuong Float, @action as char(1)
	select @MAHSL=MAHSL, @BAC=BAC, @NhomNgach=NHOMNGACH, @HeSoLuong=HESOLUONG from inserted


    SET @action = 'I'; -- Set Action to Insert by default.
    IF EXISTS(SELECT * FROM DELETED)
    BEGIN
        SET @action = 
            CASE
                WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' -- Set Action to Updated.
                ELSE 'D' -- Set Action to Deleted.       
            END
    END
	ELSE 
        IF NOT EXISTS(SELECT * FROM INSERTED) RETURN;
	if @action='I'
	begin
		insert into tb_BIENDONGHSL(MAHSL ,NAMAPDUNG, BAC, NHOMNGACH, HESOLUONG)
		values (@MAHSL,GETDATE(),@BAC, @NhomNgach, @HeSoLuong)
	end
	if @action='U'
	begin
		update tb_BIENDONGHSL
		set NAMAPDUNG=Getdate(),BAC=@BAC, NHOMNGACH=@NhomNgach,HESOLUONG=@HeSoLuong
		where MAHSL=@MAHSL
	end
	if @action='D'
	begin
		select @MAHSL=MAHSL from deleted
		delete from tb_BIENDONGHSL
		where MAHSL=@MAHSL
	end
end

--7 Trigger Phu cap

alter trigger trg_NV_PC
on tb_NHANVIEN_PHUCAP
after insert, update
as
begin
	declare @ID int, @IDPC int, @SOTIEN float, @TENPC nvarchar(50)
	select @ID=ID, @IDPC=IDPC
	from inserted
	if not exists (select IDPC from tb_PHUCAP where IDPC=@IDPC)
	BEGIN
		RAISERROR('Xin Kiem Tra Lai Thong Tin Nhap', 16, 1)
        ROLLBACK TRAN
	end
	Else
	begin
		select @SOTIEN=SOTIEN, @TENPC=TENPC
		from tb_PHUCAP
		where IDPC=@IDPC

		update tb_NHANVIEN_PHUCAP
		set SOTIEN=@SOTIEN, NGAY=GETDATE(), NOIDUNG=@TENPC
		where ID=@ID
	end
end

--8 Trigger bang cong
alter trigger trg_BangCongCT
on tb_THANGCONGCHITIET 
AFTER insert,update
as
begin
	declare @MATC int, @MANV char(5),  @N1 nvarchar(10),@N2 nvarchar(10),@N3 nvarchar(10),@N4 nvarchar(10),@N5 nvarchar(10),@N6 nvarchar(10),@N7 nvarchar(10),@N8 nvarchar(10),@N9 nvarchar(10),@N10 nvarchar(10),
	@N11 nvarchar(10),@N12 nvarchar(10),@N13 nvarchar(10),@N14 nvarchar(10),@N15 nvarchar(10),@N16 nvarchar(10),@N17 nvarchar(10),@N18 nvarchar(10),@N19 nvarchar(10),@N20 nvarchar(10),
	@N21 nvarchar(10),@N22 nvarchar(10),@N23 nvarchar(10),@N24 nvarchar(10),@N25 nvarchar(10),@N26 nvarchar(10),@N27 nvarchar(10),@N28 nvarchar(10),@N29 nvarchar(10),@N30 nvarchar(10), @N31 nvarchar(10)
	declare @NGHICP int, @NGHIKP int

	select @MATC=MATHANGCONG, @MANV=MANV, @N1=N1,@N2=N2,@N3=N3,@N4=N4,@N5=N5,@N6=N6,@N7=N7,@N8=N8,@N9=N9,@N10=N10, @N11=N11, @N12=N12,@N13=N13,
	@N14=N14,@N15=N15,@N16=N16,@N17=N17,@N18=N18,@N19=N19,@N20=N20,
	@N21=N21,@N22=N22,@N23=N23,@N24=N24,@N25=N25,@N26=N26,@N27=N27,@N28=N28, @N29=N29, @N30=N30,@N31=N31, @NGHICP=0,@NGHIKP=0 from inserted


	if @N1='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N1='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N2='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N2='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N3='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N3='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N4='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N4='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N5='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N5='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N6='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N6='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N7='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N7='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N8='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N8='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N9='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N9='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N10='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N10='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N11='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N11='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N12='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N12='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N13='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N13='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N14='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N14='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N15='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N15='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N16='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N16='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N17='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N17='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N18='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N18='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N19='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N19='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N20='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N20='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N21='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N21='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N22='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N22='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N23='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N23='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N24='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N24='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N25='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N25='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N26='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N26='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N27='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N27='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N28='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N28='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N29='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N29='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N30='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N30='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end

	if @N31='C'
	begin
	 set @NGHICP=@NGHICP+1
	end
	else if @N31='V'
	begin
		set @NGHIKP=@NGHIKP+1
	end
	SELECT @MATC=MATHANGCONG,@MANV=MANV FROM inserted


	update tb_THANGCONGCHITIET
	set NGAYPHEP=@NGHICP, NGHIKHONGPHEP=@NGHIKP, NGAYCONG=@NGHICP+@NGHIKP
	where MANV=@MANV and MATHANGCONG=@MATC
	
	if MONTH(GETDATE())=1 or MONTH(GETDATE())=3 or MONTH(GETDATE())=5 or MONTH(GETDATE())=7 or MONTH(GETDATE())=8 or MONTH(GETDATE())=10 or MONTH(GETDATE())=12
	begin
		update tb_THANGCONGCHITIET
		set TONGNGAYCONG=31-NGHIKHONGPHEP
		where MATHANGCONG=@MATC
	end
	if MONTH(GETDATE())=2
	begin
		update tb_THANGCONGCHITIET
		set TONGNGAYCONG=28-NGHIKHONGPHEP
		where MATHANGCONG=@MATC
	end
	if MONTH(GETDATE())=4 or MONTH(GETDATE())=6 or MONTH(GETDATE())=9 or MONTH(GETDATE())=11
	begin
		update tb_THANGCONGCHITIET
		set TONGNGAYCONG=30-NGHIKHONGPHEP
		where MATHANGCONG=@MATC
	end
	

end
-- 9 Tinh tong ngay cong

alter trigger trg_THANGCONG
on tb_THANGCONG
after insert,update
as
begin
	declare @MATC int, @NGAYCONGTRONGTHANG int
	select @MATC=MATHANGCONG
	from inserted
	select @NGAYCONGTRONGTHANG=NGAYPHEP from tb_THANGCONGCHITIET where MATHANGCONG=@MATC

	update tb_THANGCONG
	set THANG=MONTH(GETDATE()), NAM=YEAR(GETDATE()), NGAYTINHCONG=GETDATE(), NGAYCONGTRONGTHANG=@NGAYCONGTRONGTHANG
	where MATHANGCONG=@MATC

	
end

--10 Tu dong xoa nhan vien khi xoa hop dong
alter trigger trg_Xoa_HD_NV
on tb_HOPDONG
after delete
as
begin
	begin try
		declare @MANV char(5)
		select @MANV=MANV from deleted
		delete from tb_NHANVIEN
		where MANV=@MANV
		print('Xoa Thanh Cong, NV va HD da duoc xoa')
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = N'Lỗi: ' + ERROR_MESSAGE() + ' Database da duoc rollback'
			RAISERROR (@errorMessage, 16,1)
	end catch
end

--11 Them NQL khi ma phong

alter trigger trg_ThemNQL_NV
on tb_NHANVIEN
after insert,update
as
begin
	begin try
		declare @MANV char(5), @IDPB int, @MANQL char(5)
		select @MANV=MANV, @IDPB=IDPB from inserted
		if @IDPB is not null
		begin
			select @MANQL=TRUONGPHONG from tb_PHONGBAN where IDPB=@IDPB
			update tb_NHANVIEN
			set MA_NQL=@MANQL
			where MANV=@MANV
		end
	end try
	begin catch
			rollback tran 
			declare @errorMessage varchar(2000)
			select  @errorMessage = N'Lỗi: ' + ERROR_MESSAGE() + ' Database da duoc rollback'
			RAISERROR (@errorMessage, 16,1)
	end catch
end
-- 12 Kiem tra so gio tang ca cua nhan vien
create trigger trg_KT_GIO_TC
on tb_TANGCA
after insert,update
as
begin
	declare @SOGIO float
	select @SOGIO=SOGIO from inserted
	if @SOGIO>6
	begin
		raiserror ('So Gio Tang Ca Khong Duoc Lon Hon 6', 16,1)
		rollback tran
		return
	end
end


--13 Kiem tra truong phong cua phong ban

alter trigger trg_KT_TP_PB
on tb_PHONGBAN
instead of insert,update
as
begin
	declare @TENPHONGBAN nvarchar(50), @TRUONGPHONG char(5)
	select @TENPHONGBAN=TENPB,@TRUONGPHONG=TRUONGPHONG from inserted
	if exists (select TRUONGPHONG from tb_PHONGBAN where TRUONGPHONG= @TRUONGPHONG)
	begin
		raiserror ('Truong Phong Dang Quan Ly Phong Ban Khac', 16,1)
		rollback tran
		return
	end
	else
	begin
		insert into tb_PHONGBAN(TENPB,TRUONGPHONG)
		values(@TENPHONGBAN,@TRUONGPHONG)
	end
end

----14 thanh toan luong

alter trigger tt_luong
on tb_THANHTOANLUONG
after insert,update
as
begin
	declare @IDUL int, @MATC int, @MANV char(5), @IDLUONG int, @TIENPC float, @NGAYNGHI int, @LUONGBD float, @UL float, @LUONGCT float(3), @THUETNCN float(3), @Luong float(3)
	select @IDUL=ID,@MATC=MATHANGCONG,@IDLUONG=IDLUONG, @MANV=MANV from inserted
	select @MANV=MANV from tb_THANGCONGCHITIET where MATHANGCONG=@MATC
	update tb_THANHTOANLUONG
	set MANV=@MANV
	where IDLUONG=@IDLUONG
	select @NGAYNGHI=TONGNGAYCONG from tb_THANGCONGCHITIET where MATHANGCONG=@MATC and MANV=@MANV
	
	select @TIENPC=0,@LUONGCT=0,@THUETNCN=0,@Luong=0, @UL=0
	
	if exists (select MANV from tb_NHANVIEN_PHUCAP where MANV=@MANV)
	begin
		select @TIENPC=SOTIEN from tb_NHANVIEN_PHUCAP where MANV=@MANV
	end
	if exists (select ID from tb_UNGLUONG where ID=@IDUL)
	begin
		select @UL=SOTIEN from tb_UNGLUONG where ID=@IDUL
	end
	if exists (select MANV from tb_HOPDONG where MANV=@MANV)
	begin
		select @LUONGBD=LUONGBD from tb_HOPDONG where MANV=@MANV

		if MONTH(GETDATE())=1 or MONTH(GETDATE())=3 or MONTH(GETDATE())=5 or MONTH(GETDATE())=7 or MONTH(GETDATE())=8 or MONTH(GETDATE())=10 or MONTH(GETDATE())=12
		begin
			set @LUONGCT=(((@LUONGBD/31)*@NGAYNGHI)+@TIENPC)
		end
		if MONTH(GETDATE())=2
		begin
			set @LUONGCT=(((@LUONGBD/28)*@NGAYNGHI)+@TIENPC)
		end
		if MONTH(GETDATE())=4 or MONTH(GETDATE())=6 or MONTH(GETDATE())=9 or MONTH(GETDATE())=11
		begin
			set @LUONGCT=(((@LUONGBD/30)*@NGAYNGHI)+@TIENPC)
		end

		set @THUETNCN = case 
						when @LUONGCT<=5000000 then @LUONGCT*0.05
						when @LUONGCT>5000000and @LUONGCT<=10000000 then (@LUONGCT*0.1)-250000
						when @LUONGCT>10000000 and @LUONGCT<=18000000 then (@LUONGCT*0.15)-750000
						when @LUONGCT>18000000 and @LUONGCT<=32000000 then (@LUONGCT*0.2)-1650000
						when @LUONGCT>32000000 and @LUONGCT<=52000000 then (@LUONGCT*0.25)-3250000
						when @LUONGCT>52000000 and @LUONGCT<=80000000 then (@LUONGCT*0.3)-5850000
						when @LUONGCT>80000000 then (@LUONGCT*0.35)-9850000
					end
		set @Luong=@LUONGCT-@THUETNCN-@UL
					
		update tb_THANHTOANLUONG
		set THANGTT=MONTH(GETDATE()),NAMTT=YEAR(GETDATE()),MANV=@MANV,LUONGCT=@LUONGCT,THUETNCN=@THUETNCN,LUONG=@Luong
		where IDLUONG=@IDLUONG

	end
	else
	begin
		raiserror ('Nhan Vien Khong Ton Tai Hoac Khong Co Hop Dong', 16,1)
		rollback tran
		return
	end
end


----15 trigger_kt thang cong


alter trigger trg_KT_SL_TC
on tb_THANGCONG
instead of insert, update
as
begin
	declare @ID int,@MATHANGCONG int, @MATHANGCONG2 int
	select @MATHANGCONG=MATHANGCONG, @ID=ID from inserted
	if @MATHANGCONG in (select MATHANGCONG from tb_THANGCONG)
	begin
		raiserror ('Ma Thang Cong Bi Trung', 16,1)
		rollback tran
		return
	end
	else
	begin
		insert into tb_THANGCONG(MATHANGCONG)
		values (@MATHANGCONG)
	end
end





ALTER DATABASE QLNHANSU2
SET RECURSIVE_TRIGGERS OFF 
