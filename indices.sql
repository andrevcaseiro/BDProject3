-- Indices --

-- 1 --
explain analyze
select distinct R.nome_retalhista
from retalhista R, responsavel_por P
where R.tin = P.tin and P.nome_categoria = 'CATEGORIA_5'

alter table retalhista alter index retalhista_tin_index on retalhista using hash (tin);
create index if not exists respor_cat_index on responsavel_por using hash (nome_categoria); --> 0.450
create index if not exists respor_tin_index on responsavel_por using hash (tin); --> 0.505
create index if not exists respor_tin_index on responsavel_por (tin); --> 0.500
create index if not exists respor_cat_index on responsavel_por (nome_categoria); -->0.500
create index if not exists respor_cattin_index on responsavel_por (tin, nome_categoria); --> 0.440
drop index --> 0.5; 1.265
com os dois indices hash --> 0.520

--------------------------- analise de seletividade para o 1 --------------------
select count(distinct R.nome_retalhista)
from retalhista R, responsavel_por P
where R.tin = P.tin 
-- resultado = 20

select count(distinct R.nome_retalhista)
from retalhista R, responsavel_por P
where P.nome_categoria = 'CATEGORIA_5' 
-- resultado = 20

select count(distinct p.nome_categoria)
from responsavel_por p
-- resultado = 73

select count(distinct p.tin)
from responsavel_por p
-- resultado = 20
---------------------------------------------------------------------------------

create index if not exists respor_cat_index on responsavel_por using hash (nome_categoria);
create index if not exists respor_tin_index on responsavel_por using hash (tin);
create index if not exists retalhista_nome_index on retalhista (nome_retalhista);

-- Dado que esta query implica filtar os valores da tabela retalhista por
-- uma igualdade com um outro valor, modifica-se o index dessa tabela no 
-- tin para um do tipo hash pois este é o melhor para seleções por igualdade
-- (modifica-se e não cria-se pois o index já existe, dado que tin é chave 
-- primária da tabela retalhista).
-- Criou-se também dois índices para o atributo tin e para o nome_categoria da 
-- tabela responsavel_por, ambos do tipo hash pois queremos testar igualdades.
-- Devido ao distinct para selecionar o nome_retalhista queremos um indice que 
-- acelere a ordenação deste atributo e portanto temos um do tipo B+tree


-- 2 --
explain analyze
SELECT T.nome_categoria, count(T.ean)
FROM produto P, tem_categoria T
WHERE P.nome_categoria = T.nome_categoria and P.descricao like 'D%'
GROUP BY T.nome_categoria

create index if not exists tem_cat_index on tem_categoria (nome_categoria); --> 7.000
create index if not exists prod_descr_index on produto (nome_categoria, descricao); --> 5.000
(combinacao dos dois de cima)--> 7.500
create index if not exists tem_cat_index on tem_categoria using hash (nome_categoria); --> 6.600
(combinacao) --> 6.400
drop index --> 5.100

-- Índices que se podia pensar criar:
--   - um de tipo hash na tabela produto para o nome_categoria;
--   - um de tipo hash ou b+tree na tabela tem_categoria para o nome_categoria;
--   - um de tipo b+tree na tabela produto para a descricao.
--   - um para o ean na tem_categoria

--------------------------- analise de seletividade para o 2 --------------------
SELECT count(t.nome_categoria)
FROM produto P, tem_categoria T
WHERE P.nome_categoria = T.nome_categoria 
-- resultado = 668

SELECT count(t.nome_categoria)
FROM produto P, tem_categoria T
WHERE P.descricao = 'DESCRICAO_PRODUTO_1'
-- resultado = 546

select count(distinct p.nome_categoria)
from produto p
-- resultado = 54

select count(distinct p.descricao)
from produto p
-- resultado = 174
----------------------------------------------------------------------------------

-- indices do tipo btree para o atributo nome_categoria da tabela tem_categoria e 
-- tambem para o atributo descricao da tabela produto????

-- indice do tipo btree no atributo nome_categoria e no descricao da tabela produto 
-- pois estamos interessados em reconhecer padrões para a descricao em que a primeira parte 
-- é especificada logo queremos um indice com as informações ordenadas. Adiciona-mos ao atributo
-- nome_categoria primeiro porque é o que tem maior seletividade.