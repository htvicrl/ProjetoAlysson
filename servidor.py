import tornado.ioloop
import tornado.web
import sqlite3


def conexao_db(query, valores=()):
    conexao = sqlite3.connect("db/db.sqlite3")
    cursor = conexao.cursor()
    cursor.execute(query, valores)
    resultado = cursor.fetchall()
    conexao.commit()
    conexao.close()
    return resultado


class Login(tornado.web.RequestHandler):
    def get(self):
        self.render("templates/login.html")

    def post(self):
        usuario = self.get_argument("usuario")
        senha = self.get_argument("senha")

        query = "SELECT id_usuario FROM usuario WHERE nome=? AND senha=?"
        valores = (usuario, senha)
        resultado = conexao_db(query, valores)

        if resultado:
            id_usuario = resultado[0][0]
            self.set_secure_cookie("id_usuario", str(id_usuario))
            self.redirect("/tarefas")
        else:
            self.write("Usuário ou senha não encontrados.")


class Tarefas(tornado.web.RequestHandler):
    def get(self):
        id_usuario = self.get_secure_cookie("id_usuario")

        if not id_usuario:
            self.redirect("/")
            return

        id_usuario = id_usuario.decode()

        query = "SELECT id_tarefa, titulo, descricao, situacao FROM tarefas WHERE id_usuario=?"
        valores = (id_usuario,)
        tarefas = conexao_db(query, valores)

        self.render("templates/tarefas.html", tarefas=tarefas)

    def post(self):
        id_usuario = self.get_secure_cookie("id_usuario").decode()

        titulo = self.get_argument("titulo")
        descricao = self.get_argument("descricao")
        situacao = self.get_argument("situacao")

        query = """
                INSERT INTO tarefas (id_usuario, titulo, descricao, situacao)
                VALUES (?, ?, ?, ?) \
                """
        valores = (id_usuario, titulo, descricao, situacao)
        conexao_db(query, valores)

        self.redirect("/tarefas")


class EditarTarefa(tornado.web.RequestHandler):
    def post(self):
        id_tarefa = self.get_argument("id")
        nova_descricao = self.get_argument("descricao")

        query = "UPDATE tarefas SET descricao=? WHERE id_tarefa=?"
        valores = (nova_descricao, id_tarefa)
        conexao_db(query, valores)

        self.redirect("/tarefas")


class DeletarTarefa(tornado.web.RequestHandler):
    def post(self):
        id_tarefa = self.get_argument("id")

        query = "DELETE FROM tarefas WHERE id_tarefa=?"
        valores = (id_tarefa)
        conexao_db(query, valores)

        self.redirect("/tarefas")


class Main(tornado.web.Application):
    def __init__(self):
        rotas = [
            (r"/", Login),
            (r"/tarefas", Tarefas),
            (r"/editar", EditarTarefa),
            (r"/deletar", DeletarTarefa),
        ]
        super().__init__(rotas, cookie_secret="seguranca")


if __name__ == "__main__":
    app = Main()
    app.listen(8888)
    print("Servidor rodando em: http://localhost:8888")
    tornado.ioloop.IOLoop.current().start()
