--- IC-1 --- 
create or replace function check_no_loops_category() returns trigger as
$$
declare cat char(80);
begin
    if new.nome_categoria = new.super_categoria then
        raise exception 'Uma categoria nao pode estar contida nela propria';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger check_no_loops_category_trigger
before insert or update on tem_outra
for each row execute procedure check_no_loops_category();


--- IC-4 ---
create or replace function check_repo_exceed_units() returns trigger as
$$
declare uni integer;
begin 
    select unidades into uni
    from planograma pl 
    where pl.ean = new.ean and pl.nro = new.nro and 
          pl.num_serie = new.num_serie and pl.fabricante = new.fabricante;

    if new.unidades > uni then
        raise exception 'Unidades repostas nao podem exceder as estipuladas no planograma!';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger repo_exceed_units_trigger
before update or insert on evento_reposicao
for each row execute procedure check_repo_exceed_units();


-- IC-5 --
create or replace function check_prod_cat_replacement() returns trigger as
$$
declare prat_cat char(80);
begin 
    select nome_categoria into prat_cat --categoria da prateleira
    from evento_reposicao e natural join prateleira p 
    where nro = new.nro and num_serie = new.num_serie and 
          fabricante = new.fabricante;

    if prat_cat not in (
        select nome_categoria --categorias do produto
        from tem_categoria t
        where t.ean = new.ean
        ) then
            raise exception 'Um produto só pode ser colocado numa prateleira que apresente uma das suas categorias!';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger prod_cat_replacement_trigger
before update or insert on evento_reposicao
for each row execute procedure check_prod_cat_replacement();