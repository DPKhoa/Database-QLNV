--Tra cuu thong tin nhan vien
create proc sp_TC_ThongtinNV
	@MANV char(5)
as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV)
	begin
		select *
		from tb_NHANVIEN
		where MANV=@MANV
	end
	else
		print 'Ma nhan vien khong ton tai'
end

execute sp_TC_ThongtinNV 'NV001'
--Tra cuu hop dong cua Nhan Vien
ALTER proc sp_TC_HopDongNhanVien
	@MANV char(5)
as
begin
	if exists (select MANV from tb_HOPDONG where MANV=@MANV)
	begin
		select NV.HOTEN, HD.SOHD, HD.NGAYBAYDAU, HD.NGAYKETTHUC, HD.NGAYKY, HD.NOIDUNG, HD.HANHD, HD.MAHSL
		from tb_NHANVIEN NV, tb_HOPDONG HD
		where NV.MANV=HD.MANV 
		and HD.MANV=@MANV

	end
	else
		print 'Ma nhan vien khong ton tai'
end

execute sp_TC_HopDongNhanVien 'NV003'
--Tra cuu nguoi quan ly cua Nhan vien


create proc sp_TC_NHANVIEN_PHONGBAN_NQL
	@MANV char(5)
as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV)
	begin
		  select NV1.MANV, NV1.HOTEN, NV1.MA_NQL, NV2.HOTEN, PB.IDPB, PB.TENPB
		  FROM tb_NHANVIEN NV1 LEFT JOIN tb_NHANVIEN NV2 ON NV1.MA_NQL = NV2.MANV, tb_PHONGBAN PB
		  where NV1.IDPB=PB.IDPB 
		  and NV1.MANV=@MANV;
	end
	else
		print 'Ma nhan vien khong ton tai'
end

execute sp_TC_NHANVIEN_PHONGBAN_NQL 'NV023'
--Them CHUCVU Moi(co trans)

alter proc sp_Them_ChucVu
	@TENCV nvarchar(50)
as
declare @macv int
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_CHUCVU with (updlock) -- Chuyển sang update lock
	select * from tb_CHUCVU with (readcommitted)

	begin try
	waitfor delay '00:00:05'
		if(@TENCV is null)
		begin
			print 'Thong tin nhap rong'
			return
		end
		commit
	end try
	
	begin catch
		--báo lỗi
		print 'Them khong thanh cong'
	end catch
	
	set @macv=1000
	while(exists(select * from tb_CHUCVU where IDCV=@macv))
		set @macv=@macv+1

	SET IDENTITY_INSERT tb_CHUCVU ON
	Insert into tb_CHUCVU(IDCV,TENCV) values(@macv,@TENCV)
	SET IDENTITY_INSERT tb_CHUCVU OFF
	

end


execute sp_Them_ChucVu 'Nhan Vien 2'

--Xem thong tin bao hiem cua nhan vien do

create proc sp_TC_NHANVIEN_BAOHIEM
	@MANV char(5)
as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV)
	begin
		  select NV.MANV, NV.HOTEN, BH.IDBH, BH.NGAYCAP, BH.NOICAP, BH.NOIDK, BH.SOBH
		  FROM tb_NHANVIEN NV, tb_BAOHIEM BH
		  where NV.MANV=BH.MANV 
		  and NV.MANV=@MANV;
	end
	else
		print 'Ma nhan vien khong ton tai'
end

execute sp_TC_NHANVIEN_BAOHIEM 'NV002'

--Xem thong bo phan va chuc vu cua nhan vien

create proc sp_TC_BOPHAN_CHUCVU_NHANVIEN
	@MANV char(5)
as
begin
	if exists (select MANV from tb_NHANVIEN where MANV=@MANV)
	begin
		  select NV.MANV, NV.HOTEN, BP.IDBP,BP.TENBP, CV.IDCV, CV.TENCV
		  FROM tb_NHANVIEN NV, tb_BOPHAN BP, tb_CHUCVU CV
		  where NV.IDBP=BP.IDBP 
		  and NV.IDCV=CV.IDCV
		  and NV.MANV=@MANV;
	end
	else
		print 'Ma nhan vien khong ton tai'
end

execute sp_TC_BOPHAN_CHUCVU_NHANVIEN 'NV003'

--Tra cuu Nhan vien tang ca 


create proc sp_TC_NHANVIEN_TANGCA
	@MANV char(5)
as
begin
	if exists (select MANV from tb_TANGCA where MANV=@MANV)
	begin
		  select NV.HOTEN, TC.ID, TC.IDLOAICA, TC.NGAY, TC.THANG, TC.NAM, TC.SOGIO
		  from tb_TANGCA TC, tb_NHANVIEN NV
		  where TC.MANV=NV.MANV 
		  and TC.MANV=@MANV
	end
	else
		print 'Nhan Vien Khong Tang Ca'
end

execute sp_TC_NHANVIEN_TANGCA 'NV023'


--Xoa, Them, Chon PHONGBAN

CREATE PROCEDURE Insertdelete_PB (@ID int,
								  @TENPB nvarchar(50),
								  @TRUONGPHONG char(5),
                                  @StatementType NVARCHAR(20) = '')
AS
  BEGIN
      IF @StatementType = 'Insert'
        BEGIN
            INSERT INTO tb_PHONGBAN
                        (TENPB, TRUONGPHONG)
            VALUES     ( @TENPB,
                         @TRUONGPHONG)
        END

      IF @StatementType = 'Select'
        BEGIN
            SELECT *
            FROM   tb_PHONGBAN
        END

      ELSE IF @StatementType = 'Delete'
        BEGIN
            DELETE FROM tb_PHONGBAN
            WHERE  IDPB = @id
        END
  END

  execute Insertdelete_PB 2009, N'Nhân Sự Hai', 'NV027', 'Delete'


 --Cap nhat thong tin bao hiem

  
create proc sp_Update_BH
	@IDBH int,
	@Ngaycap datetime,
	@Noicap nvarchar(50),
	@NoiDK nvarchar(50)
as
begin
	if exists (select IDBH from tb_BAOHIEM where IDBH=@IDBH)
	begin
		  UPDATE tb_BAOHIEM
		  SET NGAYCAP = @Ngaycap, NOICAP= @Noicap, NOIDK=@NoiDK
		  WHERE IDBH = @IDBH;
	end
	else
		print 'Ma Bao Hiem Khong Ton Tai'
end

execute sp_Update_BH 4001, '20171204', N'Hồ Chí Minh', N'Bệnh Viện 115'

--

create proc sp_Update_BH
	@IDBH int,
	@Ngaycap datetime,
	@Noicap nvarchar(50),
	@NoiDK nvarchar(50)
as
begin
	if exists (select IDBH from tb_BAOHIEM where IDBH=@IDBH)
	begin
		  UPDATE tb_BAOHIEM
		  SET NGAYCAP = @Ngaycap, NOICAP= @Noicap, NOIDK=@NoiDK
		  WHERE IDBH = @IDBH;
	end
	else
		print 'Ma Bao Hiem Khong Ton Tai'
end

execute sp_Update_BH 4001, '20171204', N'Hồ Chí Minh', N'Bệnh Viện 115'

--Tra cuu thong tin ung luong cua nhan vien
create proc sp_TC_NHANVIEN_UNGLUONG
	@MANV char(5)
as
begin
	if exists (select MANV from tb_UNGLUONG where MANV=@MANV)
	begin
		  select *
		  from tb_UNGLUONG
		  where MANV=@MANV
	end
	else
		print 'Nhan Vien Khong Ung Luong'
end

execute sp_TC_NHANVIEN_UNGLUONG 'NV003'

--Them vao bang ung luong

alter proc sp_Insert_UL
	@Nam int,
	@Thang int,
	@Ngay int,
	@Sotien float,
	@TrangThai bit,
	@Manv char(5)
as
begin
	set xact_abort on
	begin tran
	set transaction isolation level serializable
	select * from tb_UNGLUONG with (updlock) -- Chuyển sang update lock
	select * from tb_UNGLUONG with (readcommitted)
	begin try 
	 begin
		 waitfor delay '00:00:10'
		 Insert into tb_UNGLUONG(NAM,THANG,NGAY,SOTIEN,TRANGTHAI, MANV)
		 Values(@Nam, @Thang,@Nam, @Sotien,@TrangThai,@Manv)
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

execute sp_Insert_UL 2022,10,12,4300000,Null,'NV005'

--Tra cuu thong tin cong nhan vien


create proc sp_TC_Cong_Nhanvien
	@MANV char(5),
	@Nam int,
	@Thang int,
	@Ngay int
as
begin
	if exists (select MANV from tb_BANGCONG where MANV=@MANV and NAM=@Nam and THANG=@Thang and NGAY=@Ngay)
	begin
		  select *
		  from tb_BANGCONG
		  where MANV=@MANV
		  and Nam=@Nam
		  and THANG=@Thang and NGAY=@Ngay
	end
	else
		print 'Khong tim thay cham cong cua nhan vien'
end

execute sp_TC_Cong_Nhanvien 
--Tra Cuu So Luong Nhan Vien Trong Phong Ban va Dem So Luong nhan vien trong phong ban do
Drop PROCEDURE TraCuu_DSNV_SLNV_PB
CREATE PROCEDURE TraCuu_DSNV_SLNV_PB (@IDPB int,
                                  @StatementType NVARCHAR(20) = '')
AS
  BEGIN
      IF @StatementType = 'DS'
        BEGIN
            SELECT *
			FROM tb_NHANVIEN NV
			where NV.IDPB=@IDPB
        END

      IF @StatementType = 'SL'
        BEGIN
              SELECT PB.TENPB,COUNT(NV.MANV) as 'SO LUONG NHAN VIEN'
			  FROM tb_NHANVIEN NV, tb_PHONGBAN PB
			  where PB.IDPB=NV.IDPB 
			  and PB.IDPB=@IDPB
			  GROUP BY PB.TENPB
        END
  END

  execute TraCuu_DSNV_SLNV_PB 2002, 'DS'

--Xem trinh do cua Nhan Vien trong Phong Ban
drop procedure  TraCuu_SL_TrinhDo_NV_PB
CREATE PROCEDURE TraCuu_SL_TrinhDo_NV_PB (@IDPB int,
                                  @StatementType NVARCHAR(20) = '')
AS
  BEGIN
      IF @StatementType = 'DH'
        BEGIN
            SELECT TD.TENTD, COUNT(NV.MANV) as 'SO LUONG NHAN VIEN TD DH'
			FROM tb_NHANVIEN NV, tb_TRINHDO TD
			where NV.IDPB=@IDPB and NV.IDTD=201
			and NV.IDTD=TD.IDTD
			GROUP BY TD.TENTD
        END

      IF @StatementType = 'CD'
        BEGIN
            SELECT TD.TENTD, COUNT(NV.MANV) as 'SO LUONG NHAN VIEN TD CD'
			FROM tb_NHANVIEN NV, tb_TRINHDO TD
			where NV.IDPB=@IDPB and NV.IDTD=200
			and NV.IDTD=TD.IDTD
			GROUP BY TD.TENTD
        END
  END

  execute TraCuu_SL_TrinhDo_NV_PB 2002, 'DH'

  --Xoa HopDong cua Nhan Vien va Xoa Nhan Vien

  CREATE PROCEDURE Xoa_HD_NV (@SOHD nvarchar(20), @MANV char(5))
AS
  BEGIN
      if exists (select SOHD from tb_HOPDONG where SOHD=@SOHD)
        BEGIN
            DELETE FROM tb_HOPDONG
			where SOHD=@SOHD

			Delete FROM tb_NHANVIEN
			where MANV=@MANV
        END
	  else
			print 'Hop Dong Khong Ton Tai Hoa Da Bi Xoa'

  END

  execute Xoa_HD_NV 'HDLD000031', 'NV032'

  