--OLAP--
-- 1 --
select dia_semana, concelho, sum(unidades) as soma
from vendas
where mes between 3 and 5 
group by grouping sets((dia_semana), (concelho), ());

-- 2 --
select concelho, nome_categoria, dia_semana, sum(unidades) as soma
from vendas natural join tem_categoria
where distrito = 'Distrito_2'
group by grouping sets((concelho), (nome_categoria), (dia_semana), ());