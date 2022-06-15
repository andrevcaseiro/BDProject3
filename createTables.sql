drop table if exists categoria;
drop table if exists categoria_simples;
drop table if exists super_categoria;
drop table if exists tem_outra;
drop table if exists produto;
drop table if exists tem_categoria;
drop table if exists IVM;
drop table if exists ponto_de_retalho;
drop table if exists instalada_em;
drop table if exists prateleira;
drop table if exists planograma;
drop table if exists retalhista;
drop table if exists responsavel_por;
drop table if exists evento_reposicao;

--------------------------------------------------
--  Table creation --
--------------------------------------------------

create or replace table categoria (
    nome_categoria varchar(80) not null unique,
    constraint pk_categoria primary key(nome_categoria)
);

create or replace table categoria_simples (
    nome_categoria varchar(80) not null unique,
    constraint pk_categoria_simples primary key(nome_categoria),
    constraint fk_cat_catsimp foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table super_categoria (
    nome_categoria varchar(80) not null unique,
    constraint pk_super_categoria primary key(nome_categoria),
    constraint pk_cat_supcat foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table tem_outra (
    super_categoria varchar(80) not null,
    nome_categoria varchar(80) not null unique,
    constraint pk_tem_outra primary key(nome_categoria),
    constraint fk_sup_cat foreign key(super_categoria) references super_categoria(nome_categoria),
    constraint fk_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table produto (
    ean int not null unique,
    descricao varchar(200) not null,
    constraint pk_ean primary key(ean)
);

create or replace table tem_categoria (
    ean int not null unique,
    nome_categoria varchar(80) not null,
    constraint pk_temcat primary key(ean, nome_categoria),
    constraint fk_ean_cat foreign key(ean) references produto(ean),
    constraint fk_cat_prod foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table IVM (
    num_serie int not null unique,
    fabricante varchar(80) not null unique,
    constraint pk_ivm primary key(num_serie, fabricante)
);

create or replace table ponto_de_retalho (
    nome_retalho varchar(80) not null unique,
    distrito varchar(80) not null unique,
    concelho varchar(80) not null unique,
    constraint pk_retalho primary key(nome_retalho)
);

create or replace table instalada_em (
    num_serie int not null unique,
    fabricante varchar(80) not null unique,
    ivm_local varchar(80) not null unique,
    constraint pk_instalada primary key(num_serie, fabricante),
    constraint fk_inst_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_inst_ret foreign key(ivm_local) references ponto_de_retalho(nome_retalho)
);

create or replace table prateleira (
    nro int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    altura int not null,
    nome_categoria varchar(80) not null,
    constraint pk_prateleira primary key(nro, num_serie, fabricante),
    constraint fk_prat_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_prat_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table planograma (
    ean int not null,
    nro int not null,
    num_serie int not null,
    fabricante varchar(80) not null,
    faces varchar(80) not null,
    unidades int not null,
    constraint pk_plan primary key(ean, nro, num_serie, fabricante),
    constraint fk_plan_prod foreign key(ean) references produto(ean),
    constraint fk_plan_ivm foreign key(nro, num_serie, fabricante) 
                           references prateleira(nro, num_serie, fabricante)
);

create or replace table retalhista (
    tin int not null unique,
    nome_retalhista varchar(80) not null unique,
    constraint pk_retalhista primary key(tin)
);

create or replace table responsavel_por (
    num_serie int not null,
    fabricante varchar(80) not null,
    nome_categoria varchar(80) not null,
    tin int not null unique,
    constraint pk_resppor primary key(nome_categoria, num_serie, fabricante),
    constraint fk_resppor_ivm foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
    constraint fk_resppor_ret foreign key(tin) references retalhista(tin),
    constraint fk_resppor_cat foreign key(nome_categoria) references categoria(nome_categoria)
);

create or replace table evento_reposicao (
    ean int not null,
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