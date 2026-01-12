import tornado.ioloop
import tornado.web
import sqlite3


def conexao_db(query, valores=()):
    conexao = sqlite3.connect("db/db.sqlite3")
    conexao.execute("PRAGMA foreign_keys = ON;")  # Ativa chaves estrangeiras
    cursor = conexao.cursor()
    cursor.execute(query, valores)
    resultado = cursor.fetchall()
    conexao.commit()
    conexao.close()
    return resultado


class Login(tornado.web.RequestHandler):
    def get(self):
        self.render("login.html")

    def post(self):
        usuario, senha = self.get_argument("usuario"), self.get_argument("senha")
        res = conexao_db("SELECT id_usuario FROM usuario WHERE nome=? AND senha=?", (usuario, senha))
        if res:
            self.set_secure_cookie("id_usuario", str(res[0][0]))
            self.redirect("/tarefas")
        else:
            self.write("Erro no login.")


class Tarefas(tornado.web.RequestHandler):
    def get(self):
        id_user = self.get_secure_cookie("id_usuario")
        if not id_user: return self.redirect("/")

        # Busca da VIEW filtrando pelo ID do usuário (subquery)
        query = """SELECT id_tarefa, titulo, descricao, categoria, status_atual 
                   FROM vw_detalhes_tarefas 
                   WHERE dono_da_tarefa = (SELECT nome FROM usuario WHERE id_usuario=?)"""
        tarefas = conexao_db(query, (id_user.decode(),))
        self.render("tarefas.html", tarefas=tarefas)

    def post(self):
        id_user = self.get_secure_cookie("id_usuario").decode()
        dados = (self.get_argument("titulo"), self.get_argument("descricao"),
                 id_user, self.get_argument("id_categoria"), self.get_argument("id_status"))

        query = "INSERT INTO tarefas (titulo, descricao, id_usuario, id_categoria, id_status) VALUES (?,?,?,?,?)"
        conexao_db(query, dados)
        self.redirect("/tarefas")


class EditarTarefa(tornado.web.RequestHandler):
    def post(self):
        dados = (self.get_argument("descricao"), self.get_argument("id_status"), self.get_argument("id"))
        conexao_db("UPDATE tarefas SET descricao=?, id_status=? WHERE id_tarefa=?", dados)
        self.redirect("/tarefas")


class DeletarTarefa(tornado.web.RequestHandler):
    def post(self):
        conexao_db("DELETE FROM tarefas WHERE id_tarefa=?", (self.get_argument("id"),))
        self.redirect("/tarefas")

class AdminRelatorios(tornado.web.RequestHandler):
    def get(self):
        # 1. Busca dados da VIEW (Relacionamento de todas as tabelas)
        query_view = "SELECT * FROM vw_detalhes_tarefas"
        dados_view = conexao_db(query_view)

        # 2. Busca dados dos LOGS (Gerados pelos Triggers)
        query_logs = "SELECT * FROM logs_tarefas ORDER BY data_log DESC"
        dados_logs = conexao_db(query_logs)

        self.render("relatorios.html", tarefas_view=dados_view, logs=dados_logs)


def make_app():
    return tornado.web.Application([
        (r"/", Login),
        (r"/tarefas", Tarefas),
        (r"/editar", EditarTarefa),
        (r"/deletar", DeletarTarefa),
        (r"/relatorios", AdminRelatorios),
    ], template_path="templates", static_path="static", cookie_secret="seguranca")


if __name__ == "__main__":
    make_app().listen(8001)
    print("Servidor em http://localhost:8001")
    tornado.ioloop.IOLoop.current().start()