#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

# SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist199180"
DB_DATABASE = DB_USER
DB_PASSWORD = "1234567890"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)


@app.route("/categorias", methods=["GET", "POST"])
def list_categories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        message = None
        if request.method == "POST":
            try:
                action = request.form["action"]
                if action == "insert":
                    try:
                        data = (request.form["nome_categoria"], )
                        query = "INSERT INTO categoria VALUES (%s);"
                        cursor.execute(query, data)
                        query = "INSERT INTO categoria_simples VALUES (%s);"
                        cursor.execute(query, data)
                        message = f"Nova categoria inserida: {data[0]}"
                    except Exception as e:
                        message = f"Falha ao inserir categoria: {e}"
                    finally:
                        dbConn.commit()
                elif action == "delete":
                    try:
                        data = {"cat": request.form["nome_categoria"]}
                        query = "call elimina_categoria(%(cat)s);"
                        cursor.execute(query, data)
                        message = f"Categoria removida: {data['cat']}"
                    except Exception as e:
                        message = f"Falha ao remover categoria: {e}"
                    finally:
                        dbConn.commit()
            except Exception as e:
                message = f"Falha: {e}"

        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categorias.html",
                               cursor=cursor,
                               message=message)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/retalhistas", methods=["GET", "POST"])
def list_retailers():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        message = None
        if request.method == "POST":
            try:
                action = request.form["action"]
                if action == "insert":
                    try:
                        data = (request.form["tin"],
                                request.form["nome_retalhista"])
                        query = "INSERT INTO retalhista VALUES (%s, %s);"
                        cursor.execute(query, data)
                        message = f"Novo retalhista inserido: {data}"
                    except Exception as e:
                        message = f"Falha ao inserir retalhista: {e}"
                    finally:
                        dbConn.commit()
                elif action == "delete":
                    try:
                        data = (request.form["tin"], )
                        query = "DELETE FROM evento_reposicao WHERE tin = %s;"
                        cursor.execute(query, data)
                        query = "DELETE FROM responsavel_por WHERE tin = %s;"
                        cursor.execute(query, data)
                        query = "DELETE FROM retalhista WHERE tin = %s;"
                        cursor.execute(query, data)
                        message = f"Retalhista removido: {data[0]}"
                    except Exception as e:
                        message = f"Falha ao remover retalhista: {e}"
                    finally:
                        dbConn.commit()
            except Exception as e:
                message = f"Falha: {e}"

        query = "SELECT * FROM retalhista;"
        cursor.execute(query)
        return render_template("retalhistas.html",
                               cursor=cursor,
                               message=message)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/ivm")
def list_ivms():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        query = "SELECT * FROM ivm;"
        cursor.execute(query)
        return render_template("ivm.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/eventos")
def list_eventos():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        num_serie = request.args["num_serie"]
        fabricante = request.args["fabricante"]
        query = "SELECT * FROM evento_reposicao WHERE num_serie = %s AND fabricante = %s;"
        data = (num_serie, fabricante)
        cursor.execute(query, data)
        events = cursor.fetchall()

        query = """SELECT p.nome_categoria, SUM(unidades) AS sum
        FROM evento_reposicao NATURAL JOIN produto p
        WHERE num_serie = %s AND fabricante = %s
        GROUP BY nome_categoria;"""
        cursor.execute(query, data)
        cats = cursor.fetchall()

        return render_template("eventos.html", events=events, cats=cats, num_serie=num_serie, fabricante=fabricante)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route("/subcategorias")
def list_subcategories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cat = request.args["nome_categoria"]

        query = """WITH RECURSIVE search_tree(super_categoria, nome_categoria) AS (
            SELECT super_categoria, nome_categoria
            FROM tem_outra
            WHERE super_categoria = %s
        UNION ALL
            SELECT t.super_categoria, t.nome_categoria
            FROM tem_outra t, search_tree st
            WHERE t.super_categoria = st.nome_categoria
        )
        SELECT * FROM search_tree"""
        data = (cat, )
        cursor.execute(query, data)
        tree = {}
        for record in cursor.fetchall():
            superCat = record["super_categoria"]
            simpleCat = record["nome_categoria"]
            if superCat in tree.keys():
                tree[superCat].append(simpleCat)
            else:
                tree[superCat] = [simpleCat]

        return render_template("subcategorias.html",
                               tree=tree,
                               category=cat)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

CGIHandler().run(app)
