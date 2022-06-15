from random import *

ivm = []
prateleira = []
categoria = []
produto_categoria = {}
produto = []
ponto_retalho = []
retalhista = []
c = 0
p = 0


def createCategory(f, s):
    global categoria
    global c
    global p
    categoria += (f"CATEGORIA_{c}", )
    c += 1
    f.write(f"insert into categoria values ('{categoria[-1]}')\n")
    if (len(s) > 1):
        f.write(f"insert into tem_outra values {(s[-1], categoria[-1])}\n")
    if (random() > 0.8):
        f.write(f"insert into super_categoria values {(categoria[-1],)}\n")
        for _ in range(randint(1, 5)):
            createCategory(f, s + (categoria[-1], ))
    else:
        f.write(f"insert into categoria_simples values ('{categoria[-1]}')\n")
        for _ in range(randint(1, 5)):
            product = (randint(1000000000000, 9999999999999), )
            f.write(
                f"insert into produto values {product + (f'DESCRICAO_{p}', )}\n"
            )
            p += 1
            for ean in s + (categoria[-1], ):
                produto_categoria[ean] = product
                f.write(
                    f"insert into tem_categoria values {product + (ean,)}\n")


with open("populate.sql", "w") as f:

    # Loop categoria
    for _ in range(20):
        createCategory(f, ())

    # Loop ponto de retalho
    for i in range(20):
        ponto_retalho.append(f"PONTO_DE_RETALHO_{i}")
        f.write(
            f"insert into ponto_de_retalho values {(ponto_retalho[-1], f'DISTRITO_{randint(1,18)}', f'CONCELHO_{randint(1,18)}')}\n"
        )

    # Loop retalhista
    for i in range(20):
        retalhista.append(i)
        f.write(
            f"insert into retalhista values {(retalhista[-1], f'RETALHISTA_{randint(1,18)}')}\n"
        )

    # Loop fabricante
    for i in range(10):
        # Loop num_serie
        for j in range(randint(5, 30)):
            ivm.append((j, f"FABRICANTE_{i}"))
            f.write(f"insert into ivm values {ivm[-1]}\n")
            f.write(
                f"insert into instalada_em values {ivm[-1] + tuple(choices(ponto_retalho))}\n"
            )

            # Loop prateleira
            for k in range(randint(5, 10)):
                cat = choice(categoria)
                prateleira.append((k, ) + ivm[-1])
                f.write(
                    f"insert into prateleira values {prateleira[-1] + (randint(10,30), cat)}\n"
                )

                #for _ in range(3):
                #    f.write(f"insert into planograma values {prateleira[-1] + (randint(10,30), cat)}\n")
