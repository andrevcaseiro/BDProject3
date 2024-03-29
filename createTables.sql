drop table if exists categoria cascade;
drop table if exists categoria_simples cascade;
drop table if exists super_categoria cascade;
drop table if exists tem_outra cascade;
drop table if exists produto cascade;
drop table if exists tem_categoria cascade;
drop table if exists IVM cascade;
drop table if exists ponto_de_retalho cascade;
drop table if exists instalada_em cascade;
drop table if exists prateleira cascade;
drop table if exists planograma cascade;
drop table if exists retalhista cascade;
drop table if exists responsavel_por cascade;
drop table if exists evento_reposicao cascade;

--------------------------------------------------
--  Table creation --
--------------------------------------------------

create table categoria (
    nome_categoria varchar(80) not null,
    constraint pk_categoria primary key(nome_categoria)
);

create table categoria_simples (
    nome_categoria varchar(80) not null,
    constraint pk_categoria_simples primary key(nome_categoria),
    constraint fk_simp_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create table super_categoria (
    nome_categoria varchar(80) not null,
    constraint pk_super_categoria primary key(nome_categoria),
    constraint fk_super_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create table tem_outra (
    super_categoria varchar(80) not null,
    nome_categoria varchar(80) not null,
    constraint pk_tem_outra primary key(nome_categoria),
    constraint fk_outra_sup foreign key(super_categoria) references super_categoria(nome_categoria),
    constraint fk_outra_cat foreign key(nome_categoria) references categoria(nome_categoria),
    constraint ck_cat_supcat check(super_categoria != nome_categoria)
);

create table produto (
    ean bigint not null,
    nome_categoria varchar(80) not null,
    descricao varchar(200) not null,
    constraint pk_produto primary key(ean),
    constraint fk_prod_cat foreign key(nome_categoria) references categoria(nome_categoria),
    constraint ck_prod check(ean <= 9999999999999 and ean >= 1000000000000)
);

create table tem_categoria (
    ean bigint not null,
    nome_categoria varchar(80) not null,
    constraint pk_tem_cat primary key(ean, nome_categoria),
    constraint fk_temcat_prod foreign key(ean) references produto(ean),
    constraint fk_temcat_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create table IVM (
    num_serie int not null,
    fabricante varchar(80) not null,
    constraint pk_ivm primary key(num_serie, fabricante)
);

create table ponto_de_retalho (
    nome_retalho varchar(80) not null,
    distrito varchar(80) not null,
    concelho varchar(80) not null,
    constraint pk_retalho primary key(nome_retalho)
);

create table instalada_em (
    num_serie int not null,
    fabricante varchar(80) not null,
    ivm_local varchar(80) not null,
    constraint pk_instalada primary key(num_serie, fabricante),
    constraint fk_inst_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_inst_ret foreign key(ivm_local) references ponto_de_retalho(nome_retalho)
);

create table prateleira (
    nro int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    altura int not null,
    nome_categoria varchar(80) not null,
    constraint pk_prateleira primary key(nro, num_serie, fabricante),
    constraint fk_prat_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_prat_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create table planograma (
    ean bigint not null,
    nro int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    faces int not null,
    unidades int not null,
    constraint pk_plan primary key(ean, nro, num_serie, fabricante),
    constraint fk_plan_prod foreign key(ean) references produto(ean),
    constraint fk_plan_ivm foreign key(nro, num_serie, fabricante) 
                           references prateleira(nro, num_serie, fabricante)
);

create table retalhista (
    tin int not null,
    nome_retalhista varchar(80) not null unique,
    constraint pk_retalhista primary key(tin)
);

create table responsavel_por (
    nome_categoria varchar(80) not null,
    tin int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    constraint pk_resppor primary key(nome_categoria, num_serie, fabricante),
    constraint fk_resppor_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_resppor_ret foreign key(tin) references retalhista(tin),
    constraint fk_resppor_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create table evento_reposicao (
    ean bigint not null,
    nro int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    instante date not null,
    unidades int not null,
    tin int not null,
    constraint pk_eventorep primary key(ean, nro, num_serie, fabricante, instante),
    constraint fk_evrep_plan foreign key(ean, nro, num_serie, fabricante) 
                             references planograma(ean, nro, num_serie, fabricante),
    constraint fk_evrep_ret foreign key(tin) references retalhista(tin)
);

--------------------------------------------------
--  Procedure for category deletion --
--------------------------------------------------
drop procedure elimina_categoria(character varying);

create or replace procedure elimina_categoria(cat categoria.nome_categoria%type)
language plpgsql
as $$
declare
	num produto.ean%type;
	sub_cat categoria.nome_categoria%type;
begin
	
	for num in
		select p.ean
    	from tem_categoria p
    	where p.nome_categoria = cat
	loop
		delete from evento_reposicao e where e.ean = num;
		delete from planograma p where p.ean = num;
		delete from tem_categoria t where t.ean = num;
		delete from produto p where p.ean = num;
	end loop;
	
	for sub_cat in
		WITH RECURSIVE search_tree(super_categoria, nome_categoria) AS (
            SELECT super_categoria, nome_categoria
            FROM tem_outra
            WHERE super_categoria = cat
        UNION ALL
            SELECT t.super_categoria, t.nome_categoria
            FROM tem_outra t, search_tree st
            WHERE t.super_categoria = st.nome_categoria
        )
        VALUES (cat)
		UNION ALL
		SELECT nome_categoria FROM search_tree
	loop
		delete from tem_outra t where t.super_categoria = sub_cat or t.nome_categoria = sub_cat;
		delete from responsavel_por r where r.nome_categoria = sub_cat;
		delete from prateleira p where p.nome_categoria = sub_cat;
		delete from super_categoria c where c.nome_categoria = sub_cat;
		delete from categoria_simples c where c.nome_categoria = sub_cat;
		delete from categoria c where c.nome_categoria = sub_cat;
	end loop;

end
$$;
