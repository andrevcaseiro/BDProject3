from random import *

ivms = []
shelves = []
categories = []
categoryProducts = {}
products = []
retailPoints = []
retailers = []


def insert(f, into, values):
    if len(values) == 1:
        f.write(f"insert into {into} values ({repr(values[0])})\n")
    else:
        f.write(f"insert into {into} values {values}\n")


def createCategory(f, s=[]):
    global categories
    cat = (f"CATEGORIA_{len(categories)}", )
    insert(f, "categoria", cat)
    categoryProducts[cat] = []
    categories.append(cat)

    if (s != []):
        insert(f, "tem_outra", s[-1] + cat)

    if (random() > 0.8):
        insert(f, "super_categoria", cat)
        for _ in range(randint(2, 5)):
            createCategory(f, s + [cat])
    else:
        insert(f, "categoria_simples", cat)
        for _ in range(randint(1, 5)):
            prod = (randint(1000000000000, 9999999999999), )
            insert(f, "produto",
                   prod + (f'DESCRICAO_PRODUTO_{len(products)}', ))
            products.append(prod)
            for c in s + [cat]:
                categoryProducts[c].append(prod)
                insert(f, "tem_categoria", prod + c)


with open("populate.sql", "w") as f:

    # Loop categories
    for _ in range(20):
        createCategory(f)
        f.write("\n")

    # Loop retail points
    for i in range(20):
        retPoint = (f"PONTO_DE_RETALHO_{i}", )
        insert(f, "ponto_de_retalho", retPoint)
        retailPoints.append(retPoint)
    f.write("\n")

    # Loop retailer
    for i in range(20):
        ret = (i, )
        insert(f, "retalhista", ret + (f'RETALHISTA_{i}', ))
        retailers.append(ret)
    f.write("\n")

    # Loop manufacturers
    for i in range(10):
        # Loop serial numbers
        for j in range(randint(5, 30)):
            ivm = (j, f"FABRICANTE_{i}")
            insert(f, "ivm", ivm)
            insert(f, "instalada_em", ivm + choice(retailPoints))
            ivms.append(ivm)
            catPlans = {}

            # Loop shelves
            for k in range(randint(5, 10)):
                shelf = (k, ) + ivm
                cat = choice(categories)
                insert(f, "prateleira", shelf + (randrange(10, 30), ) + cat)
                if (cat not in catPlans.keys()):
                    catPlans[cat] = []

                possibleProds = categoryProducts[cat]
                for prod in sample(possibleProds, min(len(possibleProds), 3)):
                    plan = prod + shelf
                    insert(f, "planograma",
                           plan + (randint(1, 5), randint(7, 30)))
                    catPlans[cat].append(plan)

            for cat in catPlans.keys():
                ret = choice(retailers)
                insert(f, "responsavel_por", cat + ret + ivm)

                for plan in catPlans[cat]:
                    for _ in range(randint(1, 4)):
                        insert(
                            f, "evento_reposicao", plan +
                            (f"2021.{randint(0,365)}", randint(2, 7)) + ret)

print(f"Categories: {len(categories)}")
print(f"Products: {len(products)}")