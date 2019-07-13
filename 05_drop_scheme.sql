------------------------------
----Kateøina Bøicháèková------
----Evidence psù v útulku-----
----NDBI026, ZS 2017/2018-----
------------------------------


drop table Adopce;
drop table SmrtPsa;
drop table PrijemPsa;
drop table Vystraha;
drop table Venceni;
drop table Vencitel;
drop table Osvojitel;
drop table Pes;
drop table Kotec;

drop package Utulek_Adopce;
drop package Utulek_Kotec;
drop package Utulek_Osvojitel;
drop package Utulek_Pes;
drop package Utulek_Venceni;
drop package Utulek_Vencitel;

drop function NextID;

drop sequence Ident;

drop view Pohled_na_osvojitele;
drop view Pohled_na_psy;
drop view Pohled_na_vencitele;
drop view Prazdne_kotce;
drop view Psi_k_adopci;
drop view Psi_na_venceni;
drop view Psi_na_vychazce;
drop view Psi_nejdele_v_utulku;
drop view Seznam_adopci;
drop view Seznam_kotcu;
drop view Seznam_venceni;
drop view Stenata_k_adopci;
drop view Vencitele_s_vystrahami;

commit;
