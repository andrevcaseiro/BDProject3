-- Indices --

-- 1 --
select distinct R.nome
from retalhista R, responsavel_por P
where R.tin = P.tin and P. nome_cat = 'Frutos'

alter index retalhista_tin_index on retalhista hash (tin);
create index responsavelpor_tin_index on responsavel_por hash (tin, nome_categoria);

-- Dado que esta query implica filtar os valores da tabela retalhista por
-- uma igualdade com um outro valor, modifica-se o index dessa tabela no 
-- tin para um do tipo hash pois este é o melhor para seleções por igualdade
-- (modifica-se e não cria-se pois o index já existe, dado que tin é chave 
-- primária da relação retalhista).
-- Os outros dois indexes foram criados pela mesma razão, com o tipo hash
-- pois vão ser usados para seleção. 


-- 2 --
SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.desc like 'A%'
GROUP BY T.nome

