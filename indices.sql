-- Indices --

-- 1 --
explain analyze
select distinct R.nome_retalhista
from retalhista R, responsavel_por P
where R.tin = P.tin and P.nome_categoria = 'CATEGORIA_5'

--------------------------- analise de seletividade para o 1 --------------------
select count(*)
from responsavel_por p
-- resultado = 1452

select count(distinct p.nome_categoria)
from responsavel_por p
-- resultado = 73
select count(*)
from responsavel_por p
where p.nome_categoria = 'CATEGORIA_5'
--resultado = 24

select count(distinct p.tin)
from responsavel_por p
-- resultado = 20
---------------------------------------------------------------------------------

create index if not exists respor_cat_index on responsavel_por using hash (nome_categoria);
create index if not exists retalhista_nome_index on retalhista (nome_retalhista);

-- Criou-se um índice para o atributo nome_categoria da tabela responsavel_por, 
-- do tipo hash pois queremos testar uma igualdade. Escolheu-se criar o índice 
-- para o nome_categoria pois como se consegue ver este atributo tem uma 
-- seletividade maior dado que só existem 24 entradas com a CATEGORIA_5 e também
-- existem mais categorias diferentes que tin logo uma filtragem pela categoria
-- é suficiente.
-- Devido ao distinct para selecionar o nome_retalhista queremos um indice
-- que acelere a ordenação deste atributo e portanto temos um do tipo B+tree
 

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
SELECT count(*)
FROM produto P, tem_categoria T
WHERE P.nome_categoria = T.nome_categoria 
-- resultado = 670



SELECT count(*)
from tem_categoria
-- resultado = 522
SELECT count(distinct ean)
from tem_categoria
-- resultado = 174
SELECT count(distinct nome_categoria)
from tem_categoria
-- resultado = 73

SELECT count(*)
FROM produto P
--resultado = 174
select count(distinct p.nome_categoria)
from produto p
-- resultado = 54
select count(distinct p.descricao)
from produto p
-- resultado = 174
SELECT count(*)
FROM produto P
WHERE P.descricao like 'D%'
-- resultado = 20

-- filtrar o produto pelo nome_categoria e mais eficiente  20 > 174/54
-- já que o nome_categoria é mais seletivo
----------------------------------------------------------------------------------

-- indices do tipo btree para o atributo nome_categoria da tabela tem_categoria e 
-- tambem para o atributo descricao da tabela produto????

-- indice do tipo btree no atributo nome_categoria e no descricao da tabela produto 
-- pois estamos interessados em reconhecer padrões para a descricao em que a primeira parte 
-- é especificada logo queremos um indice com as informações ordenadas. Adiciona-mos ao atributo
-- nome_categoria primeiro porque é o que tem maior seletividade.