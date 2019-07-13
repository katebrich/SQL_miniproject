------------------------------
----Kateøina Bøicháèková------
----Evidence psù v útulku-----
----NDBI026, ZS 2017/2018-----
------------------------------

--------OSVOJITELE-----------

--Jak vypada tabulka osvojitelu
select * from Pohled_na_osvojitele;
--Neplnolety osvojitel, vyhozena vyjimka z triggeru Brichak.Osvojitel_minvek
exec Utulek_osvojitel.Pridat(123456789, 'ds', 'fsddsf', to_date('2008/06/11', 'yyyy/mm/dd'));
--Neplatne cislo OP, vyhozena vyjimka z triggeru Brichak.Osvojitel_ch_cisloOP
exec Utulek_osvojitel.Pridat(12345678, 'ds', 'fsddsf', to_date('1999/06/11', 'yyyy/mm/dd'));
--Pridame noveho osvojitele
exec Utulek_osvojitel.Pridat(123456789, 'ds', 'fsddsf', to_date('1999/06/11', 'yyyy/mm/dd'));
--Zkusime pridat osvojitele se stejnym cislem OP -> vyjimka
exec Utulek_osvojitel.Pridat(123456789, 'dmnskdj', 'lsfg', to_date('1999/06/11', 'yyyy/mm/dd'));
--Smaze osvojitele.
exec Utulek_osvojitel.Smazat(123456789);
--Tento osvojitel neni v databazi, nic se nestane
exec Utulek_osvojitel.Smazat(555555555);
--Jak vypada tabulka osvojitelu ted? Nezmenila se
select * from Pohled_na_osvojitele;

----------ADOPCE-----------------

--Jaci psi jsou v databazi?
select * from Pohled_na_psy;
--Jaci psi jsou k dispozici k adopci (jeste nejsou adoptovani a nezemreli)
select * from Psi_k_adopci;
--Zobrazime seznam stenat k adopci
select * from Stenata_k_adopci;
--Zkusime adoptovat psa, ktery neni k dispozici. Vyhozena vyjimka
exec UTULEK_ADOPCE.NOVA_ADOPCE(990635871, 1);
--Zkusime adoptovat psa, ktery neni v databazi. Vyhozena vyjimka
exec UTULEK_ADOPCE.NOVA_ADOPCE(990635871, 400000);
--Neplatne cislo OP }neni v databazi), vyhozena vyjimka
exec UTULEK_ADOPCE.NOVA_ADOPCE(4444, 3);
--Zobrazime dosud provedene adopce:
select * from Seznam_adopci;
--Pridame novou adopci
exec UTULEK_ADOPCE.NOVA_ADOPCE(990635871, 3);
--Znovu zobrazime adopce:
select * from Seznam_adopci;
--U adoptovaneho psa se timto vymazal kotec a nastavil se na null:
select * from Pes where ID = 3;
--Nyni uz tohoto psa nelze adoptovat. Vyhozena vyjimka
exec UTULEK_ADOPCE.NOVA_ADOPCE(990635871, 3);

-------------VENCENI--------------

--Zobrazime seznam psu dostupnych k venceni (ti, co jsou v utulku a nejsou v soucasne dobe venceni:
select * from Psi_na_venceni;
--Zobrazime psy, kteri jsou prave venceni (zadny nyni neni na vychazce)
select * from Psi_na_vychazce;
--Vytvorime nove venceni psa, ktery je k dispozici
exec Utulek_venceni.Nove_venceni(548962137, 4);
--znovu zobrazime psy, kteri jsou na vychazce
select * from Psi_na_vychazce;
--Zkusime vencit psa, ktery uz je vencen, vyhodi se vyjimka
exec Utulek_venceni.Nove_venceni(257703168, 4);
--Zobrazime sencitele, kteri maji vystrahu
select * from Vencitele_s_vystrahami;
--Zkusime vlozit venceni clovekem, ktery uz ma dve vystrahy (tedy maximalni pocet), vyhozena vyjimka
exec Utulek_venceni.Nove_venceni(424160286, 5);
--Nasimulujeme udeleni vystrahy: je potreba, aby venceni trvalo vice nez 6 hodin
--vlozime tedy venceni, ktere zacalo pred 7 hodinami
insert into Venceni values(null, (sysdate - (7/24)), null, 257703168, 7);
--a pote ho ukoncime.
exec Utulek_venceni.Ukoncit_venceni(7);
--a ukazeme, ze byla venciteli udelena vystraha
select * from Vystraha where Vencitel_cislo_OP = 257703168;

-----------KOTCE-------------

--Ukazene si seznam kotcu
select * from Seznam_kotcu;
--Neplatne oznaceni kotce, vyhozena vyjimka
select UTULEK_KOTEC.MA_VOLNO('XXX', 2) from dual;
--Zobrazime prazdne kotce
select * from Prazdne_kotce;
--Ukazeme, jaci psi jsou v kotci 'MRH'
select * from Pes where kotec_ozn = 'MRH';
--Premistime z nej vsechny psy do kotce 'GTH', ktery je prazdny, ale nema dostatek mista. Vyhozena vyjimka
exec Utulek_kotec.Premistit_vsechny('MRH', 'GTH');
--Nyni zkusime kotec 'ZDK', tam uz misto je
exec Utulek_kotec.Premistit_vsechny('MRH', 'ZDK');
--A nyni presuneme jednoho psa zpet do 'MRH'
exec Utulek_pes.Premistit_do_kotce('MRH', 15);
--Ukazeme, jaci psi jsou v kotci 'ZDK'
select * from Pes where kotec_ozn = 'ZDK';
--A jaci jsou v 'MRH' (tom puvodnim). Bude prazdny
select * from Pes where kotec_ozn = 'MRH';
--Kolik je psu v kotci 'MRH'?
select Utulek_kotec.Pocet_psu_v_kotci('MRH') from dual;
--Smazat se smi jen prazdny kotec - vyhozena vyjimka
exec Utulek_kotec.Smazat('MRH');

------------PSI-----------------

--Zobrazime seznam vsech psu
select * from Pohled_na_psy;
--Smazeme psa
exec Utulek_pes.Smazat(31);
--Zkusime smazat neexistujiciho psa. Nestane se nic
exec Utulek_pes.Smazat(100);
--Znovu zobrazime seznam vsech psu. Pes cislo 1 je nyni smazany
select * from Pohled_na_psy;
--Zaznamename, ze pes zemrel
exec Utulek_Pes.Zemrel(4);
--Zobrazime seznam psu, kteri zemreli
select * from SmrtPsa;
--Tento pes je mrtvy:
select Utulek_pes.Je_mrtvy(4) from dual;
--Neni adoptovany:
select Utulek_pes.Je_adoptovany(4) from dual;
--Koukneme se, v jakem je kotci - nemel by byt v zadnem, procedura Zemrel ho smazala
select kotec_ozn from Pes where ID = 4;
--Zobrazime 5 psu, kteri jsou v utulku nejdele:
select * from Psi_nejdele_v_utulku;

