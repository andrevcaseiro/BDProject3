-- Indices --

-- 1 --
select distinct R.nome_retalhista
from retalhista R, responsavel_por P
where R.tin = P.tin and P.nome_categoria = 'CATEGORIA_2'

alter index retalhista_tin_index on retalhista using hash (tin);
create index if not exists respor_cat_index on responsavel_por using hash (tin);

-- Dado que esta query implica filtar os valores da tabela retalhista por
-- uma igualdade com um outro valor, modifica-se o index dessa tabela no 
-- tin para um do tipo hash pois este é o melhor para seleções por igualdade
-- (modifica-se e não cria-se pois o index já existe, dado que tin é chave 
-- primária da relação retalhista).
-- Criou-se também um índice para o atributo nome_categoria da tabela 
-- responsavel_por para acelerar a procura por entradas da tabela com a categoria
-- escolhida, dado que e uma igualdade usa-se hash. No nosso caso a seletividade
-- da procura do nome_categoria é igual comparando a do tin na reponsavel_por logo 
-- escolhemos o tin por ser foreign key vinda da tabela retalhista. Se as 
-- seletividades fossem diferentes criaria-mos um indice para o atributo com 
-- maior seletividade.


-- 2 --
SELECT T.nome_categoria, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.nome_categoria = T.nome_categoria and P.descricao like 'D%'
GROUP BY T.nome_categoria

