from random import *

ivms = []
shelves = []
categories = []
simpleCats = []
categoryProducts = {}
products = []
retailPoints = []
retailers = []


def insert(f, into, values):
    if len(values) == 1:
        f.write(f"insert into {into} values ({repr(values[0])});\n")
    else:
        f.write(f"insert into {into} values {values};\n")


def createCategory(f, s=[]):
    global categories
    cat = (f"CATEGORIA_{len(categories)}", )
    insert(f, "categoria", cat)
    categoryProducts[cat] = []
    categories.append(cat)

    if (s != []):
        insert(f, "tem_outra", s[-1] + cat)

    if (len(s) < 2):
        insert(f, "super_categoria", cat)
        for _ in range(randint(2, 5)):
            createCategory(f, s + [cat])
    else:
        insert(f, "categoria_simples", cat)
        simpleCats.append(cat)
        for _ in range(randint(1, 5)):
            prod = (randint(1000000000000, 9999999999999), )
            insert(f, "produto",
                   prod + cat + (f'DESCRICAO_PRODUTO_{len(products)}', ))
            products.append(prod)
            for c in s + [cat]:
                categoryProducts[c].append(prod)
                insert(f, "tem_categoria", prod + c)


with open("createTables.sql", "r") as f:
    read_data = f.read()

with open("populate.sql", "w") as f:

    f.write(read_data)

    s = 31736 # randint(1, 99999)
    seed(s)
    print(f"Seed: {s}")
    f.write("\n--------------------------------------------------\n")
    f.write(f"-- Populate tables, generated using seed {s} --\n")
    f.write("--------------------------------------------------\n\n")

    # Loop categories
    for _ in range(5):
        createCategory(f)
        f.write("\n")

    # Loop retail points
    for i in range(40):
        retPoint = (f"PONTO_DE_RETALHO_{i}", )
        district = randint(1,5)
        insert(f, "ponto_de_retalho", retPoint + (f"Distrito_{district}", f"CONCELHO_{district}_{randint(1,5)}"))
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
                    for day in sample(range(1,365), randint(0, 4)):
                        insert(
                            f, "evento_reposicao", plan +
                            (f"2021.{day:03}", randint(2, 7)) + ret)
            
            f.write("\n")
    
    # Create a retailer responsible for all simple categories
    ret = (9999999, )
    insert(f, "retalhista", ret + (f'RETALHISTA_9999999', ))
    ivm = (9999999, f"FABRICANTE_{9999999}")
    insert(f, "ivm", ivm)
    for cat in simpleCats:
        insert(f, "responsavel_por", cat + ret + ivm)
    f.write("\n")
    
    # Create a product that was never resupplied
    prod = (randint(1000000000000, 9999999999999), )
    insert(f, "produto", prod + simpleCats[0] + (f'DESCRICAO_PRODUTO_9999999', ))
    f.write("\n")

    # Create a product that was always resupplied by the same retailer
    prod = (randint(1000000000000, 9999999999999), )
    insert(f, "produto", prod + simpleCats[0] + (f'DESCRICAO_PRODUTO_9999998', ))
    plan = prod + (0, ) + ivms[0]
    insert(f, "planograma", plan + (randint(1, 5), randint(7, 30)))
    insert(f, "evento_reposicao", plan + (f"2022.001", randint(2, 7)) + ret)

print(f"Categories: {len(categories)}")
print(f"Products: {len(products)}")
