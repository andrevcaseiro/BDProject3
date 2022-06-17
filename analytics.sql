--OLAP--
-- 1 --
select dia_semana, concelho, sum(unidades) as soma
from vendas
where trimestre = 2  
group by grouping sets((dia_semana), (concelho), ());