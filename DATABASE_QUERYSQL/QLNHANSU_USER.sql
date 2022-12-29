--Tạo role 
create role TruongPhongDieuHanh
create role KeToan
create role NhanVien005


--Cấp quyền 
--Trưởng phòng xem thong tin phong ban của phòng ban mình và nhân viên của phòng ban mình
--Chỉ được xem, thêm vào bảng khen thưởng kỉ luật
--Được xem, thêm vào bảng tăng ca
--Được quyền cập nhật và thêm trong bảng chấm công
CREATE VIEW [XEMTTNV_DH] AS
SELECT *
FROM tb_NHANVIEN
WHERE IDPB=2002


select * from XEMTTNV_DH

grant select on XEMTTNV_DH to TruongPhongDieuHanh
grant select on tb_KHENTHUONG_KYLUAT to TruongPhongDieuHanh
grant execute on sp_KT_NV_DH  to TruongPhongDieuHanh

CREATE VIEW [XEMCNV_DH] AS
SELECT CT.MANV, CT.MATHANGCONG, N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31, NGAYCONG,NGAYPHEP,NGHIKHONGPHEP,TONGNGAYCONG
FROM tb_NHANVIEN NV, tb_THANGCONGCHITIET CT
WHERE NV.IDPB=2002
and CT.MANV=NV.MANV

grant select on tb_TANGCA to TruongPhongDieuHanh
grant execute on sp_PC_TC_DH  to TruongPhongDieuHanh
grant select on XEMCNV_DH to TruongPhongDieuHanh
grant insert, update on tb_THANGCONGCHITIET to  TruongPhongDieuHanh

--
grant select on tb_HESOLUONG to TruongPhongDieuHanh

CREATE VIEW [XEMBHNV_DH] AS
SELECT BH.IDBH, BH.SOBH, BH.NGAYCAP,BH.NOICAP,BH.NOIDK,BH.MANV
FROM tb_NHANVIEN NV, tb_BAOHIEM BH
WHERE NV.IDPB=2002
and BH.MANV=NV.MANV

grant select on XEMBHNV_DH to TruongPhongDieuHanh

grant select on tb_CHUCVU TO TruongPhongDieuHanh

grant execute on sp_THEM_NV to TruongPhongDieuHanh

grant select on tb_PHONGBAN to TruongPhongDieuHanh

grant select on tb_BOPHAN to TruongPhongDieuHanh

grant select on tb_LOAICA to TruongPhongDieuHanh

grant select on tb_PHUCAP to TruongPhongDieuHanh

grant select on tb_UNGLUONG to TruongPhongDieuHanh

CREATE VIEW [XEMLUONGNV_DH] AS
SELECT TTL.IDLUONG,TTL.THANGTT,TTL.NAMTT,TTL.MANV,TTL.MACC,TTL.LUONG,TTL.ID,TTL.IDPC
FROM tb_NHANVIEN NV,tb_THANHTOANLUONG TTL
WHERE TTL.MANV=NV.MANV
AND NV.IDPB=2002

grant select on XEMLUONGNV_DH to TruongPhongDieuHanh


--Kế toán:Xem chấm công NV, xem khen thưởng ký luật nhân viên,Xem phụ cấp, xem lương bản đầu và mã nhân viên trong bảng hợp đồng
--Tăng ca....(chưa có)
--Được thêm, cập nhật trong bảng thanh toán lương

grant select on tb_HESOLUONG to KeToan

grant select on tb_BAOHIEM to KeToan

grant select on tb_BIENDONGHSL to KeToan

grant select, insert, update on tb_THANGCONG to KeToan

grant select on tb_HOPDONG to KeToan

grant execute on SP_TC_THONGTINNV to KeToan

grant execute on sp_THEM_UL to KeToan

grant execute on sp_THEM_NV_PC to KeToan

grant execute on sp_THEM_KT_KL to KeToan

grant select on tb_LOAICA to KeToan
grant select on tb_THANGCONGCHITIET to KeToan
grant select on tb_PHUCAP to KeToan
grant select on tb_TANGCA to KeToan

--Nhân viên xem được thông tin của mình 
CREATE VIEW [XEMTT_BH_NV005] AS
select * 
from tb_BAOHIEM 
where MANV='NV005'

grant select on XEMTT_BH_NV005 to NhanVien005

CREATE VIEW [XEMTT_NV_NV005] AS
select * 
from tb_NHANVIEN
where MANV='NV005'

grant select on XEMTT_NV_NV005 to NhanVien005

CREATE VIEW [XEMTT_UL_NV005] AS
select * 
from tb_UNGLUONG
where MANV='NV005'

grant select on XEMTT_UL_NV005 to NhanVien005
CREATE VIEW [XEMTT_PC_NV005] AS
select * 
from tb_NHANVIEN_PHUCAP
where MANV='NV005'

grant select on XEMTT_PC_NV005 to NhanVien005

CREATE VIEW [XEMTT_KT_KL_NV005] AS
select * 
from tb_KHENTHUONG_KYLUAT
where MANV='NV005'

grant select on XEMTT_KT_KL_NV005 to NhanVien005

CREATE VIEW [XEMTT_TC_NV005] AS
select * 
from tb_TANGCA
where MANV='NV005'

grant select on XEMTT_TC_NV005 to NhanVien005

CREATE VIEW [XEMTT_TTL_NV005] AS
select * 
from tb_THANHTOANLUONG
where MANV='NV005'

grant select on XEMTT_TTL_NV005 to NhanVien005


--TruongPhong
create LOGIN Khoa with Password='123456' must_change, 
check_expiration = ON

create user Khoa for Login Khoa

exec sp_addrolemember TruongPhongDieuHanh, Khoa

--Ketoan
create LOGIN PTan with Password='123456' must_change, 
check_expiration = ON

create user PTan for Login PTan

exec sp_addrolemember KeToan, PTan

--Nhanvien
create LOGIN Hung with Password='123456' must_change, 
check_expiration = ON

create user Hung for Login Hung

exec sp_addrolemember NhanVien005, Hung





