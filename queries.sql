select nome_retalhista
from retalhista natural join responsavel_por
group by tin, nome_retalhista
having count(distinct nome_categoria) >= ALL (
	select count(distinct nome_categoria)
	from responsavel_por
	group by tin
);

select nome_retalhista
from retalhista
except all
select nome_retalhista
from (
	select nome_retalhista, nome_categoria
	from retalhista, categoria
	except all
	select nome_retalhista, nome_categoria
	from retalhista natural join responsavel_por
) as dont_include;

select ean
from produto natural left join evento_reposicao
where nro is NULL;

select ean
from produto natural join evento_reposicao
group by ean
having count(distinct tin) = 1;
