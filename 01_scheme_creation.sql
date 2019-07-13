------------------------------
----Kateøina Bøicháèková------
----Evidence psù v útulku-----
----NDBI026, ZS 2017/2018-----
------------------------------

-------------------TABULKY--------------------------

create table Kotec(
    --tripismenne oznaceni kotce
	Ozn character varying(3)
		constraint Kotec_Pk
			primary key,
	Kapacita numeric(3,0) not null
		constraint Kotec_Chk_Kapacita
			check (Kapacita > 0)
);

create table Pes(
	Id number(9,0)
		constraint Pes_Pk
			primary key,
	Jmeno character varying(20) not null,
    --Pes nebo Fena
	Pohlavi character varying(4) not null
		constraint Pes_Chk_Pohlavi
			check (Pohlavi in ('Pes', 'Fena')),
	Datum_Narozeni date,
	Rasa character varying(20),
    --kotec, ve kterem je pes umisten
	Kotec_Ozn character varying(3)
		constraint Pes_Fk_Kotec_Ozn
			references Kotec(Ozn)
);

--clovek, ktery muze adoptovat psa. Musi mit minimalni vek 18 let.
create table Osvojitel(
    --cislo obcanskeho prukazu
	Cislo_OP number(9,0)
		constraint Osvojitel_Pk
			primary key,
	Jmeno character varying(15) not null,
	Prijmeni character varying(15) not null,
	Datum_Narozeni date not null
);

--clovek, ktery muze vencit psa. Musi mit minimalni vek 15 let.
create table Vencitel(
    --cislo obcanskeho prukazu
	Cislo_OP number(9,0)
		constraint Vencitel_Pk
			primary key,
	Jmeno character varying(15) not null,
	Prijmeni character varying(15) not null,
	Datum_Narozeni date not null
);

--zaznam o adopci psa
create table Adopce(
	Id number(9,0)
		constraint Adopce_Pk
			primary key,
	Datum date not null,
	Pes_Id number(9,0)
		constraint Adopce_Fk_Pes_Id
			references Pes(Id)
				on delete set null,
	Osvojitel_Cislo_OP number(9,0)
		constraint Adopce_Fk_Osvojitel_Cislo_OP
			references Osvojitel(Cislo_OP)
				on delete set null
);

--zaznam o prijmu psa do utulku
create table PrijemPsa(
	Id number(9,0)
		constraint PrijemPsa_Pk
			primary key,
	Datum date not null,
	Popis character varying(150),
	Pes_Id number(9,0) not null
		constraint PrijemPsa_Fk_Pes_Id
			references Pes(Id)
				on delete cascade
);

--zaznam o venceni psa
create table Venceni(
	Id number(9,0)
		constraint Venceni_Pk
			primary key,
    --kdy zacalo venceni
	Cas_Zacatku date not null,
    --cas konce venceni, doplni se az po ukonceni venceni
	Cas_Konce date, 
	Vencitel_Cislo_OP number(9,0)
		constraint Venceni_Fk_Vencitel_Cislo_OP
			references Vencitel(Cislo_OP)
                on delete set null,
	Pes_Id number(9,0)
		constraint Venceni_Fk_Pes_Id
			references Pes(Id)
                		on delete set null
);

--zaznam o smrti psa. Kazdy pes muze mit maximalne jeden zaznam.
create table SmrtPsa(
    	Id number(9,0)
		constraint SmrtPsa_Pk
			primary key,
	Datum date not null,
	Popis character varying(50),
	Pes_Id number(9,0) 
		constraint SmrtPsa_U_Pes_ID unique
		constraint SmrtPsa_Fk_Pes_Id
			references Pes(Id)
				on delete cascade
);

--Vystraha, ktera se udeluje vencitelum za urcity prestupek pri venceni, typicky za prekrocenou dobu venceni.
--Vencitel s maximalnim poctem vystrah dale nemuze vencit.
create table Vystraha(
    Id number(9,0)
        constraint Vystraha_Pk
            primary key,
    Duvod character varying(50),
    Vencitel_Cislo_OP number(9,0) not null
        constraint Vystraha_Fk_Vencitel_Cislo_OP
            references Vencitel(Cislo_OP)
                on delete cascade,
    Venceni_Id number(9,0)
        constraint Vystraha_Fk_Venceni_Id
            references Venceni(Id)  
                on delete set null
);

------------------SEKVENCE--------------------------------

--Slouzi k udelovani unikatnich ID v triggerech
create sequence ident
	minvalue 1
	maxvalue 999999999
	start with 100
	nocycle
	cache 25;
	

------------------PROCEDURY A FUNKCE--------------------------------

--vraci dalsi unikatni cislo ze sekvence Ident
create function NextID return number
as
  ret number;
begin
  select ident.nextval
    into ret
    from dual;
  return ret;
end;
/


------------------TRIGGERY---------------------------------

--pokud radka nema ID, priradi ho
create  or replace trigger Pes_Nxt_ID
before insert
on Pes
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--pokud radka nema ID, priradi ho
create or replace trigger Adopce_Nxt_ID
before insert
on Adopce
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--pokud radka nema ID, priradi ho
create  or replace trigger PrijemPsa_Nxt_ID
before insert
on PrijemPsa
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--pokud radka nema ID, priradi ho
create  or replace trigger SmrtPsa_Nxt_ID
before insert
on SmrtPsa
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--pokud radka nema ID, priradi ho
create  or replace trigger Venceni_Nxt_ID
before insert
on Venceni
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--pokud radka nema ID, priradi ho
create  or replace trigger Vystraha_Nxt_ID
before insert
on Vystraha
for each row
begin
  IF :NEW.ID IS NULL
  THEN
    :NEW.ID := NextID;
  END IF;
end;
/

--Hlida, jestli nedoslo k prekroceni kapacity kotce. 
create or replace trigger Kotec_chk_Prekroceni_Kapacity
before update or insert
on Kotec
for each row
declare 
    pocet Kotec.Kapacita%TYPE;
begin
    select count(*)
    into pocet
    from Pes
    where Kotec_Ozn = :NEW.Ozn;
       
    if pocet > :NEW.Kapacita
    then
        raise_application_error(-20100, 'Pocet psu v kotci nesmi prekrocit kapacitu.');
    end if;
end;
/

--Kontrola, jestli je cislo OP deviticiferne
create or replace trigger Osvojitel_chk_CisloOP
before insert
on Osvojitel
for each row
begin
    if (:NEW.Cislo_OP < 100000000 or :NEW.Cislo_OP > 999999999)
    then
        raise_application_error(-20100, 'Cislo obcanskeho prukazu musi byt deviticiferne');
    end if;
end;
/

--Oavojiteli musi byt minimalne 18 let
create or replace trigger Osvojitel_MinVek
before insert or update
on Osvojitel
for each row
begin
    if (months_between(sysdate, :NEW.Datum_Narozeni) < 18*12)
    then
        raise_application_error(-20100, 'Minimalni vek osvojitele musi byt 18 let.');
    end if;
end;
/

--Venceni musi zacinat drive nez skooncilo
create or replace trigger Venceni_chk_Dates
before insert or update
on Venceni
for each row
begin
    if (:NEW.CAS_KONCE < :NEW.CAS_ZACATKU)
    then
        raise_application_error(-20100, 'Venceni nesmi skoncit drive nez zacalo');
    end if;
end;
/

--Kontrola, jestli je cislo OP deviticiferne
create or replace trigger Vencitel_chk_CisloOP
before insert
on Vencitel
for each row
begin
    if (:NEW.Cislo_OP < 100000000 or :NEW.Cislo_OP > 999999999) --musi byt deviticiferne
    then
        raise_application_error(-20100, 'Cislo obcanskeho prukazu musi byt deviticiferne');
    end if;
end;
/

--Venciteli musi byt minimalne 15 let
create or replace trigger Vencitel_MinVek
before insert or update
on Vencitel
for each row
begin
    if (months_between(sysdate, :NEW.Datum_Narozeni) < 15*12)
    then
        raise_application_error(-20100, 'Minimalni vek vencitele musi byt 15 let.');
    end if;
end;
/


---------------PACKAGE--------------------------


create or replace package Utulek_Osvojitel
as
    --pridat noveho Osvojitele
    procedure Pridat(cislo_OP OSVOJITEL.CISLO_OP%TYPE, jmeno OSVOJITEL.JMENO%TYPE, prijmeni OSVOJITEL.PRIJMENI%TYPE, datum_narozeni OSVOJITEL.DATUM_NAROZENI%TYPE);
    --smazat existujiciho Osvojitele
    procedure Smazat(cislo_OP_osvoj OSVOJITEL.CISLO_OP%TYPE);  
end;
/

create or replace package body Utulek_Osvojitel
as
    procedure  Pridat(cislo_OP OSVOJITEL.CISLO_OP%TYPE, jmeno OSVOJITEL.JMENO%TYPE, prijmeni OSVOJITEL.PRIJMENI%TYPE, datum_narozeni OSVOJITEL.DATUM_NAROZENI%TYPE)
    as
    begin
        insert into Osvojitel values (cislo_OP, jmeno, prijmeni, datum_narozeni);
    exception
        when DUP_VAL_ON_INDEX then
            raise_application_error(-20100, 'Osvojitel s timto cislem OP je jiz v databazi.');
    end;
    
    procedure Smazat(cislo_OP_osvoj OSVOJITEL.CISLO_OP%TYPE)
    as
    begin
        delete from Osvojitel where CISLO_OP = cislo_OP_osvoj;
    end;  
end;
/

create or replace package Utulek_Vencitel
as
    --Pridat noveho Vencitele
    procedure  Pridat(cislo_OP VENCITEL.CISLO_OP%TYPE, jmeno VENCITEL.JMENO%TYPE, prijmeni VENCITEL.PRIJMENI%TYPE, datum_narozeni VENCITEL.DATUM_NAROZENI%TYPE);
    --Pocet vystrah udelenych Venciteli
    function Pocet_vystrah(cislo_OP_venc VENCITEL.CISLO_OP%TYPE) return number;
    --Odstranit existujiciho Vencitele
    procedure Smazat(cislo_OP_venc VENCITEL.CISLO_OP%TYPE);
   
end;
/

create or replace package body Utulek_Vencitel
as
    procedure  Pridat(cislo_OP VENCITEL.CISLO_OP%TYPE, jmeno VENCITEL.JMENO%TYPE, prijmeni VENCITEL.PRIJMENI%TYPE, datum_narozeni VENCITEL.DATUM_NAROZENI%TYPE)
    as
    begin
        insert into Vencitel values(cislo_OP, jmeno, prijmeni, datum_narozeni);
    exception
        when DUP_VAL_ON_INDEX then
            raise_application_error(-20100, 'Vencitel s timto cislem OP je jiz v databazi.');
    end;
    
    procedure Smazat(cislo_OP_venc VENCITEL.CISLO_OP%TYPE)
    as
    begin
        delete from Vencitel where CISLO_OP = cislo_OP_venc;
    end;  
    
    function Pocet_vystrah(cislo_OP_venc VENCITEL.CISLO_OP%TYPE) return number
    as
        pocet number; --pocet vystrah
        x Vencitel.CISLO_OP%TYPE;
    begin 
    --overeni, jestli je v databazi . aby vznikla no_data_found exception
        select CISLO_OP
        into x
        from Vencitel
        where CISLO_OP = cislo_op_venc;
    --protoze tady vyjimka nevznika a vrati se count = 0
        select count(*)
        into pocet
        from Vystraha
        where VENCITEL_CISLO_OP = cislo_op_venc;
    
        return pocet;
    exception
      when no_data_found then --tento vencitel neexistuje
            raise_application_error(-20100, 'Vencitel s timto cislem OP neni v databazi.');
    end;
    
end;
/

create or replace package Utulek_Venceni
as
    --Zaznamenat nove venceni psa
    procedure Nove_venceni(cislo_OP_ven VENCITEL.CISLO_OP%TYPE, id_psa PES.ID%TYPE);
    --Doplni cas_konce do existujiciho zaznamu o venceni daneho psa, kde je cas_konce null
    --Pokud byla prekrocena maximalni doba venceni, udeli Venciteli vystrahu
    procedure Ukoncit_venceni(id_psa PES.ID%TYPE);
    --Udeli vystrahu venciteli
    procedure Udelit_vystrahu(cislo_OP VENCITEL.CISLO_OP%TYPE, venceni_id VENCENI.ID%TYPE, duvod VYSTRAHA.DUVOD%TYPE);
end;
/

create or replace package body Utulek_Venceni
as
    max_pocet_vystrah constant number := 1; --muze mit jen tolikhle vystrah, aby mohl vencit
    max_doba_venceni constant number := 4; --maximalni pocet hodin, kolik muze trvat venceni
    
    --najde pro daneho psa zaznam venceni, kde neni doplnen cas_konce
    function id_neukonceneho_venceni(id_psa PES.ID%TYPE) return VENCENI.ID%TYPE
    as
        vysledek VENCENI.ID%TYPE;
    begin
        select v.ID
        into vysledek
        from Venceni v
        where (id_psa = pes_id and cas_konce is null);
        
        return vysledek;
    exception
        when no_data_found then
            raise_application_error(-20100, 'Tento pes nema zadne neukoncene venceni.');
    end;
    
    -- 0 = pes neni momentalne vencen
    -- 1 = pes je prave na prochazce
    function je_vencen(id_psa PES.ID%TYPE) return number
    as
        pocet number;
    begin
        select count(*)
        into pocet
        from Venceni
        where (PES_ID = id_psa and CAS_KONCE is null);
        
        return pocet;
    end;
    
    procedure Nove_venceni(cislo_OP_ven VENCITEL.CISLO_OP%TYPE, id_psa PES.ID%TYPE)
    as
        x Vencitel.CISLO_OP%TYPE; --pomocna
        y Pes.ID%TYPE; --pomocna
    begin
        select CISLO_OP
        into x
        from Vencitel
        where CISLO_OP = cislo_OP_ven
        for update;
        
        select ID
        into y
        from Pes
        where ID = id_psa
        for update;
    
        if (UTULEK_VENCITEL.POCET_VYSTRAH(cislo_OP_ven) > max_pocet_vystrah)
        then
            raise_application_error(-20100, 'Vencitel prekrocil maximalni povoleny pocet vystrah, venceni neni povoleno.');
        end if;
        
        if (je_vencen(id_psa) = 1)
        then
            raise_application_error(-20100, 'Nelze vencit psa, ktery je v soucasnosti vencen!');
        end if;
        
        if (Utulek_pes.Je_v_utulku(id_psa) = 0)
        then
            raise_application_error(-20100, 'Nelze vencit psa, ktery jiz neni v utulku.');
        end if;
        
        insert into Venceni values (null, sysdate, null, cislo_op_ven, id_psa);
    exception
        when no_data_found then
            raise_application_error(-20100, 'Pes nebo vencitel s timto ID neni v databazi.');
    end;
    
    procedure Ukoncit_venceni(id_psa PES.ID%TYPE)
    as
        venceni_id VENCENI.ID%TYPE; --ID nalezeneho neukonceneho venceni
        cas_zac date;
        cas_kon date;
        op VENCITEL.CISLO_OP%TYPE; --cislo op vencitele prirazeneho k ukoncovaneho venceni
        x Pes.ID%TYPE; --pomocna
    begin
        select ID --overeni, jestli je v databazi
        into x
        from Pes
        where ID = id_psa;
    
        venceni_id := id_neukonceneho_venceni(id_psa); --venceni, ktere ma jako cas_konce null
              
        select cas_zacatku, vencitel_cislo_op
        into cas_zac, op
        from Venceni
        where venceni_id = id
        for update;
           
        cas_kon := sysdate;
        if ((24 * (cas_kon - cas_zac)) > max_doba_venceni)
        then
            Udelit_vystrahu(op, venceni_id, 'Prekrocena maximalni doba venceni');
            DBMS_OUTPUT.PUT_LINE ('Udelena vystraha za pozdni vraceni psa.');
        end if;
        
        update Venceni set cas_konce = cas_kon
            where id = venceni_id;
    exception
        when no_data_found
            then raise_application_error(-20100, 'Pes s timto ID neni v databazi.');
    end;
    
    procedure Udelit_vystrahu(cislo_OP VENCITEL.CISLO_OP%TYPE, venceni_id VENCENI.ID%TYPE, duvod VYSTRAHA.DUVOD%TYPE)
    as
    parent_not_found    exception;
    PRAGMA EXCEPTION_INIT(parent_not_found, -2291);
    begin
        insert into Vystraha values (null, duvod, cislo_OP, venceni_id);
    exception
        when parent_not_found then
            raise_application_error(-20100, 'Cislo OP vencitele nebo ID venceni nejsou v databazi.');
    end;
end;
/

create or replace package Utulek_Kotec
as
    --Vlozeni noveho kotce
    procedure Pridat(ozn_kotce KOTEC.OZN%TYPE, kapacita KOTEC.KAPACITA%TYPE);
    --Smazani existujiciho kotce
    procedure Smazat(ozn_kotce KOTEC.OZN%TYPE);
    -- 1 = v kotci je alespon pozadovany pocet mist
    -- 0 = v kotci je mene nez pozadovany pocet mist
    function Ma_volno(ozn_kotce KOTEC.OZN%TYPE, kolik_mist KOTEC.KAPACITA%TYPE) return number;
    --Pokud je v zadanem kotci dostatek mista, premisti vsechny psy z jednoho kotce do druheho (neboli zmeni kotec_ozn v tabulce Pes)
    procedure Premistit_vsechny(odkud KOTEC.OZN%TYPE, kam KOTEC.OZN%TYPE);
    --vrati pocet psu, kteri maji prirazeny kotec
    function Pocet_psu_v_kotci(ozn_kotce KOTEC.OZN%TYPE) return number;  
end;
/

create or replace package body Utulek_Kotec
as
    procedure Pridat(ozn_kotce KOTEC.OZN%TYPE, kapacita KOTEC.KAPACITA%TYPE)
    as
    begin
        insert into Kotec values (ozn_kotce, kapacita);
    exception
        when DUP_VAL_ON_INDEX then
            raise_application_error(-20100, 'Kotec s timto oznacenim je jiz v databazi.');
    end;
    
    procedure Smazat(ozn_kotce KOTEC.OZN%TYPE)
    as
        child_record_found exception;
        pragma exception_init(child_record_found,-02292);
    begin
        delete from Kotec where (OZN = ozn_kotce);
    exception
        when child_record_found then
            raise_application_error(-20100, 'Nelze smazat kotec, ktery neni prazdny!');
    end;
    
    function Pocet_psu_v_kotci(ozn_kotce KOTEC.OZN%TYPE) return number
    as
        pocet number;
    begin
        select count(*)
        into pocet
        from Pes
        where KOTEC_OZN = ozn_kotce;  
        
        return pocet;
    exception
      when no_data_found then -- kotec s danym oznacenim neexistuje
            raise_application_error(-20100, 'Kotec s timto oznacenim neni v databazi');
    end;

    function Ma_volno(ozn_kotce KOTEC.OZN%TYPE, kolik_mist KOTEC.KAPACITA%TYPE)
        return number
    as
        pocet_psu number;
        kapac KOTEC.KAPACITA%TYPE;
        pocet_kotcu number;
        pragma autonomous_transaction;
    begin
        
        if (kolik_mist < 0)
        then
            raise_application_error(-20100, 'Pozadovany pocet mist musi byt nezaporne cislo!');
        end if;
    
        select KAPACITA
        into kapac
        from KOTEC
        where OZN = ozn_kotce
        for update;

        pocet_psu := Pocet_psu_v_kotci(ozn_kotce);
        
        if (kapac - pocet_psu >= kolik_mist)
        then
            commit;
            return 1;
        end if;
        commit;
        return 0;
        
    exception
      when no_data_found then -- kotec s danym oznacenim neexistuje
            raise_application_error(-20100, 'Kotec s timto oznacenim neni v databazi');
    end;
    
    procedure Premistit_vsechny(odkud KOTEC.OZN%TYPE, kam KOTEC.OZN%TYPE)
    as
        pocet_presouvanych number;
        x number;
    begin   
        pocet_presouvanych := Pocet_psu_v_kotci(odkud);
        
        select Ma_volno(odkud, 0) into x from dual; --zamknuti kotce Odkud
    
        if (Ma_volno(kam, pocet_presouvanych) = 1)
        then
            update Pes set KOTEC_OZN = kam
                where KOTEC_OZN = odkud;
        else
            raise_application_error(-20100, 'V kotci neni dostatek mista.');
        end if;
    end;
    
end;
/

create or replace package Utulek_Pes
as
    --Prida noveho psa do tabulky Pes a vytvori prislusny zaznam v PrijemPsa
    procedure Pridat(jmeno PES.JMENO%TYPE, pohlavi PES.POHLAVI%TYPE, datum_narozeni date default null, rasa Pes.RASA%TYPE default null, popis PRIJEMPSA.POPIS%TYPE default null);
    --Smaze existujiciho psa
    procedure Smazat(id_psa PES.ID%TYPE);
    --Vytvori zaznam SmrtPsa a odstrani u psa kotec
    procedure Zemrel(pes_id PES.ID%TYPE, popis SMRTPSA.POPIS%TYPE default null);
    --1, pokud pes je v utulku (tedy neni mrtvy ani adoptovany); jinak 0
    function Je_v_utulku(id_psa PES.ID%TYPE) return number;
    --1, pokud mrtvy, 0 jinak
    function Je_mrtvy(id_psa PES.ID%TYPE) return number;
    --1, pokud adoptovany, 0 jinak
    function Je_adoptovany(id_psa PES.ID%TYPE) return number;
    --Pokud je v kotci misto, zmeni kotec_ozn u daneho psa
    procedure Premistit_do_kotce(ozn_kotce KOTEC.OZN%TYPE, pes_id PES.ID%TYPE);
end;
/

create or replace package body Utulek_Pes
as
    function Je_mrtvy(id_psa PES.ID%TYPE)
        return number
    as
        pocet number;
    begin
        select count(*)
            into pocet
            from SmrtPsa
            where (Pes_Id = id_psa);
        
        return pocet;
    end;

    function Je_adoptovany(id_psa PES.ID%TYPE)
        return number
    as
        pocet number;
    begin
        select count(*)
            into pocet
            from Adopce
            where (Pes_Id = id_psa);
        
        return pocet;
    end;
    
    procedure Smazat(id_psa PES.ID%TYPE)
    as
    begin
        delete from Pes where (ID = id_psa);
    end;

    procedure Pridat(jmeno PES.JMENO%TYPE, pohlavi PES.POHLAVI%TYPE, datum_narozeni date default null, rasa Pes.RASA%TYPE default null, popis PRIJEMPSA.POPIS%TYPE default null)
    as
        newId PES.ID%TYPE; --vygenerovane ID pro noveho psa
    begin
        newId := NEXTID;    
        insert into Pes values (newId, jmeno, pohlavi, datum_narozeni, rasa, null);          
        insert into PrijemPsa values (null, sysdate, popis, newId);    --trigger pridari id pro PrijemPsa
    end;
    
    procedure Zemrel(pes_id PES.ID%TYPE, popis SMRTPSA.POPIS%TYPE default null)
    as
        x Pes.ID%TYPE;
    begin
        select ID
        into x
        from Pes
        where ID = pes_id
        for update;
        
        insert into SMRTPSA values (null, sysdate, popis, pes_id);
        
        --uvolnit kotec
        update Pes set KOTEC_OZN = null
            where ID = pes_id;
    exception
        when no_data_found then
            raise_application_error(-20100, 'Pes s timto ID neni v databazi.');
    end;
    
    function Je_V_Utulku(id_psa Pes.Id%TYPE)
        return number
    as 
        x Pes.ID%TYPE;
        pragma autonomous_transaction;
    begin        
        select ID --overeni, jestli je v databazi
        into x
        from Pes
        where ID = id_psa;
        
        if (je_adoptovany(id_psa) = 1 
            or je_mrtvy(id_psa) = 1)
        then
            commit;
            return 0;
        end if;
        
        commit;
        return 1;
    exception
        when no_data_found then
            raise_application_error(-20100, 'Pes s timto ID neni v databazi.');
    end;
    
    procedure Premistit_do_kotce(ozn_kotce KOTEC.OZN%TYPE, pes_id PES.ID%TYPE)
    as
        x PES.ID%TYPE;
        kapac Kotec.KAPACITA%TYPE;
        pocet_psu number;
    begin
        select ID
        into x
        from Pes
        where ID = pes_id
        for update;
        
        if (je_mrtvy(pes_id) = 1 or je_adoptovany(pes_id) = 1)
        then
            raise_application_error(-20100, 'Nelze premistit psa, ktery neni v utulku.');
        end if;
        
        select KAPACITA
        into kapac
        from Kotec
        where OZN = ozn_kotce
        for update;

        select count(*)
        into pocet_psu
        from Pes
        where KOTEC_OZN = ozn_kotce;  
        
        if (kapac - pocet_psu = 0)
        then
            raise_application_error(-20100, 'V tomto kotci neni volne misto.');
        end if;
        
        update Pes set KOTEC_OZN = ozn_kotce
            where ID = pes_id;
    exception
        when no_data_found then
            raise_application_error(-20100, 'Pes nebo kotec s timto ID neni v databazi.');
    end;
     
end;
/


create or replace package Utulek_Adopce
as
    --vytvori novy zaznam o adopci
    procedure  Nova_adopce(cislo_OP_osvojitele OSVOJITEL.CISLO_OP%TYPE, id_psa PES.ID%TYPE);
end;
/

create or replace package body Utulek_Adopce
as
    procedure  Nova_adopce(cislo_OP_osvojitele OSVOJITEL.CISLO_OP%TYPE, id_psa PES.ID%TYPE)
    as
        x Pes.ID%TYPE;
        y Osvojitel.Cislo_OP%TYPE;
    begin
        select ID
        into x
        from Pes p
        where (p.ID = id_psa)
        for update;
        
        select Cislo_OP
        into y
        from Osvojitel o
        where (o.CISLO_OP = cislo_OP_osvojitele);

        if (Utulek_Pes.Je_mrtvy(id_psa) = 1 or Utulek_Pes.Je_adoptovany(id_psa) = 1)
        then
            raise_application_error(-20100, 'Tohoto psa nelze adoptovat, neni jiz v utulku');
        end if;
        
        insert into Adopce values(null, sysdate, id_psa, cislo_OP_osvojitele); --id doplni trigger

        --smazat kotec u psa
        update Pes set Kotec_ozn = null
            where ID = id_psa;
    exception
        when no_data_found then
            raise_application_error(-20100, 'Pes nebo osvojitel s timto ID neni v databazi.');
    end;
    
end;
/


------------INDEXY------------------------------

create index Pes_Kotec_Inx on Pes(Kotec_Ozn);
create index Adopce_Pes_Inx on Adopce(Pes_Id);
create index Adopce_Osvojitel_Inx on Adopce(Osvojitel_Cislo_OP);
create index PrijemPsa_Pes_Inx on PrijemPsa(Pes_Id);
create index Venceni_Vencitel_Inx on Venceni(Vencitel_Cislo_OP);
create index Venceni_Pes_Inx on Venceni(Pes_Id);
create index Vystraha_Vencitel_Inx on Vystraha(Vencitel_Cislo_OP);
create index Vystraha_Venceni_Inx on Vystraha(Venceni_Id);
create index venceni_nvl_cas_konce on venceni(nvl(cas_konce,to_date('31.12.3000','dd.mm.yyyy')));

------------POHLEDY-------------------------------------

-------seznam psu k adopci (nejsou dosud adoptovani ani nezemreli)--------------
create or replace view Psi_k_adopci
as
 select p.ID, p.Jmeno, p.Pohlavi, p.Datum_narozeni, p.Rasa
 from PES p
 left outer join ADOPCE a 
    on (p.ID = a.PES_ID)
 left outer join SMRTPSA s
    on (p.ID = s.PES_ID)
 where a.ID is null
    and s.ID is null
order by p.ID;


-----seznam stenat k adopci (psi, kterym je mene nez 1 rok)--------
create or replace view Stenata_k_adopci
as
 select p.ID, p.Jmeno, p.Pohlavi, p.Datum_narozeni, p.Rasa
 from PES p
 left outer join ADOPCE a 
    on (p.ID = a.PES_ID)
 left outer join SMRTPSA s
    on (p.ID = s.PES_ID)
 where a.ID is null
    and s.ID is null
    and months_between(sysdate, p.DATUM_NAROZENI) < 12;
    
    
------adoptovani psi a jejich osvojitele, serazeno podle data adopce-------
create or replace view Seznam_adopci
as
select a.Datum as Datum_adopce, o.Cislo_OP, o.Jmeno as Jmeno_osvojitele, o.Prijmeni as Prijmeni_osvojitele, p.ID as ID_psa, p.Jmeno as Jmeno_psa, p.Pohlavi, p.Datum_narozeni, p.Rasa
from PES p
inner join ADOPCE a
    on (p.ID = a.PES_ID)
inner join OSVOJITEL o
    on (a.Osvojitel_cislo_OP = o.Cislo_OP)
order by a.DATUM;

-------kotce a volna mista v nich------------
create or replace view Seznam_kotcu
as
--nejdriv kotce, ktere nejsou prazdne
select k.Ozn, k.Kapacita, (k.Kapacita - count(k.Ozn)) as Volna_mista 
from Kotec k
inner join Pes p
    on (k.OZN = p.Kotec_Ozn)
group by k.OZN, k.Kapacita
--plus
union
--kotce, ktere jsou prazdne
select k.Ozn, k.Kapacita, k.Kapacita
from Kotec k
left outer join Pes p
    on (k.OZN = p.Kotec_Ozn)
where p.ID is null;

-------seznam vsech venceni serazeny podle ID psa a data zacatku venceni----------
create or replace view Seznam_venceni
as
select p.ID, p.Jmeno as Jmeno_Psa, p.Pohlavi, p.Rasa, v.ID as Venceni_ID, v.Cas_zacatku, v.Cas_konce, ven.Cislo_OP, ven.Jmeno as Jmeno_vencitele, ven.Prijmeni as Prijmeni_vencitele
from Pes p
inner join Venceni v
    on (p.ID = v.Pes_ID)
inner join Vencitel ven
    on (v.Vencitel_cislo_OP = ven.Cislo_OP)
order by p.ID, v.cas_zacatku;

-------seznam psu, kteri jsou prave na vychazce (tedy existuje k nim polozka Venceni s nezaznamenanym casem konce)-------------
create or replace view Psi_na_vychazce
as
select *
from Pes p
where p.ID in
    (select v.Pes_ID
    from Venceni v
    where (nvl(v.Cas_Konce,to_date('31.12.3000','dd.mm.yyyy'))=to_date('31.12.3000','dd.mm.yyyy')
    ));
    
    
------seznam psu, ktere je nyni mozne vencit (tedy nejsou ani adoptovani, ani nezemreli, ani nejsou prave na vychazce)----------
create or replace view Psi_na_venceni
as
select p.ID, p.Jmeno, p.Pohlavi, p.Datum_narozeni, p.Rasa, p.Kotec_Ozn
from Pes p
left outer join ADOPCE a 
    on (p.ID = a.PES_ID)
left outer join SMRTPSA s
    on (p.ID = s.PES_ID)
where a.ID is null --neni adoptovany
    and s.ID is null --nezemrel
    and p.ID not in  --neni na prochazce
        (select v.Pes_ID
            from Venceni v
            where (v.Cas_Konce is null))
order by p.ID;


-----5 psu, kteri jsou stale v utulku a jsou tu nejdelsi dobu------------
create view Psi_nejdele_v_utulku
as
select * from
(
    select pp.Datum as Datum_prijmu, p.ID as ID_Psa, p.Jmeno, p.Pohlavi, p.Datum_narozeni, p.rasa, pp.Popis
    from Pes p
    inner join PrijemPsa pp
        on (p.ID = pp.PES_ID)
    left outer join ADOPCE a 
       on (p.ID = a.PES_ID)
    left outer join SMRTPSA s
        on (p.ID = s.PES_ID)
    where a.ID is null
        and s.ID is null
    order by pp.DATUM
)
where rownum < 6;

-------seznam prazdnych kotcu--------------
create or replace view Prazdne_kotce
as
select k.Ozn, k.Kapacita
from Kotec k
left outer join Pes p
    on (k.OZN = p.Kotec_Ozn)
where p.ID is null;

-------seznam vencitelu s vystrahami a pocet vystrah--------

create or replace view Vencitele_s_vystrahami
as
select v.Cislo_OP, v.Jmeno, v.Prijmeni, count(*) as Pocet_vystrah
from Vencitel v
inner join Vystraha vy
    on (v.CISLO_OP = vy.Vencitel_cislo_OP)
group by v.Cislo_OP, v.Jmeno, v.Prijmeni;


create or replace view Pohled_na_vencitele
as
select *
from Vencitel;

create or replace view Pohled_na_osvojitele
as
select *
from Osvojitel;

create or replace view Pohled_na_psy
as
select *
from Pes;

commit;