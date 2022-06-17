#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
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

@app.route("/categorias")
def list_categories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categorias.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/categorias/remover")
def delete_category():
    try:
        return render_template("remover_categoria.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/categorias/inserir")
def insert_category():
    try:
        return render_template("inserir_categoria.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/subcategorias")
def list_subcategories():

    def find_subcategories(super_categoria):
        query = "SELECT nome_categoria FROM tem_outra WHERE super_categoria = %s;"
        data = (super_categoria, )
        cursor.execute(query, data)
        res = list(cursor)
        for cat in res:
            res += find_subcategories(cat[0])
        
        return res

    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        subcategories = find_subcategories(request.args["nome_categoria"])
        return render_template("categorias.html", subcatgory=request.args["nome_categoria"], cursor=subcategories)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/update", methods=["POST"])
def update_balance():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome_categoria = request.form["nome_categoria"]
        query = "DELETE FROM categoria WHERE nome_categoria = %s"
        data = (nome_categoria, )
        cursor.execute(query, data)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

CGIHandler().run(app)
