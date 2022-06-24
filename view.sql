create view vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades) 
as 
select o.ean as ean,
	o.nome_categoria as cat,
	extract(year from instante) as ano,
	extract(quarter from instante) as trimestre,
	extract(month from instante) as mes,
	extract(day from instante) as dia_mes,
	extract(dow from instante) as dia_semana,
	r.distrito as distrito,
	r.concelho as concelho,
	e.unidades as unidades
from produto o 
	join evento_reposicao e on o.ean=e.ean
	join instalada_em i on e.num_serie=i.num_serie and e.fabricante=i.fabricante
	join ponto_de_retalho r on i.ivm_local=r.nome_retalho;