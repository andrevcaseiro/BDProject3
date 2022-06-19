-- Indices --

-- 1 --
explain analyze
select distinct R.nome_retalhista
from retalhista R, responsavel_por P
where R.tin = P.tin and P.nome_categoria = 'CATEGORIA_5'

alter index retalhista_tin_index on retalhista using hash (tin);
create index if not exists respor_cat_index on responsavel_por using hash (nome_categoria) --> 0.450
create index if not exists respor_cat_index on responsavel_por using hash (tin); --> 0.505
create index if not exists respor_cat_index on responsavel_por (tin); --> 0.500
create index if not exists respor_cat_index on responsavel_por (nome_categoria); -->0.500
create index if not exists respor_cat_index on responsavel_por (nome_categoria, tin); --> 0.440
drop index respor_cat_index; --> 0.5; 1.265

--------------------------- analise de seletividade para o 1 --------------------
select count(distinct R.nome_retalhista)
from retalhista R, responsavel_por P
where R.tin = P.tin 
-- resultado = 20

select count(distinct R.nome_retalhista)
from retalhista R, responsavel_por P
where P.nome_categoria = 'CATEGORIA_5' 
-- resultado = 20
---------------------------------------------------------------------------------

-- Dado que esta query implica filtar os valores da tabela retalhista por
-- uma igualdade com um outro valor, modifica-se o index dessa tabela no 
-- tin para um do tipo hash pois este é o melhor para seleções por igualdade
-- (modifica-se e não cria-se pois o index já existe, dado que tin é chave 
-- primária da tabela retalhista).
-- Criou-se também um índice para o atributo nome_categoria da tabela 
-- responsavel_por para acelerar a procura por entradas da tabela com a categoria
-- escolhida, dado que e uma igualdade usa-se hash. No nosso caso a seletividade
-- da procura do nome_categoria é maior que a do tin daí criarmos um indice para
-- esse atributo.


-- 2 --
SELECT T.nome_categoria, count(T.ean)
FROM produto P, tem_categoria T
WHERE P.nome_categoria = T.nome_categoria and P.descricao like 'D%'
GROUP BY T.nome_categoria

create index if not exists tem_cat_index on tem_categoria (nome_categoria);
create index if not exists prod_descr_index on produto (descricao);

-- Índices que se podia pensar criar:
--   - um de tipo hash na tabela produto para o nome_categoria;
--   - um de tipo hash ou btree na tabela tem_categoria para o nome_categoria;
--   - um de tipo btree na tabela produto para a descricao.

--------------------------- analise de seletividade para o 2 --------------------
SELECT count(t.nome_categoria)
FROM produto P, tem_categoria T
WHERE P.nome_categoria = T.nome_categoria 
-- resultado = 668

SELECT count(t.nome_categoria)
FROM produto P, tem_categoria T
WHERE P.descricao = 'DESCRICAO_PRODUTO_1'
-- resultado = 546
----------------------------------------------------------------------------------

-- indices do tipo btree para o atributo nome_categoria da tabela tem_categoria e 
-- tambem para o atributo descricao da tabela produto????

-- indice do tipo btree no atributo descricao da tabela produto pois estamos 
-- interessados em reconhecer padrões em que a primeira parte é especificada
-- logo queremos um indice com as informações ordenadas. Adiciona-mos ao atributo
-- descricao porque é o que tem maior seletividade.