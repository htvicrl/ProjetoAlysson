CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    senha TEXT NOT NULL
);

CREATE TABLE tarefas (
    id_tarefa INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT NOT NULL,
    descricao TEXT,
    situacao TEXT NOT NULL,
    id_usuario INTEGER,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
);

CREATE TABLE status_tarefa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL
);

CREATE TABLE logs_tarefas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tarefa_id INTEGER,
    acao TEXT,
    data_log DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Removendo a versão antiga e criando com os vínculos
DROP TABLE IF EXISTS tarefas;

CREATE TABLE tarefas (
    id_tarefa INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT NOT NULL,
    descricao TEXT,
    id_usuario INTEGER,
    id_categoria INTEGER,
    id_status INTEGER,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id),
    FOREIGN KEY (id_status) REFERENCES status_tarefa(id)
);
CREATE VIEW vw_detalhes_tarefas AS
SELECT
    t.id_tarefa,
    t.titulo,
    t.descricao,
    u.nome AS dono_da_tarefa,
    c.nome AS categoria,
    s.descricao AS status_atual
FROM tarefas t
JOIN usuario u ON t.id_usuario = u.id_usuario
JOIN categorias c ON t.id_categoria = c.id
JOIN status_tarefa s ON t.id_status = s.id;

-- Trigger para INSERT (Criação)
CREATE TRIGGER trg_log_insert_tarefa
AFTER INSERT ON tarefas
BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao)
    VALUES (NEW.id_tarefa, 'CRIAÇÃO: ' || NEW.titulo);
END;

-- Trigger para UPDATE (Edição)
CREATE TRIGGER trg_log_update_tarefa
AFTER UPDATE ON tarefas
BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao)
    VALUES (NEW.id_tarefa, 'ATUALIZAÇÃO: ' || NEW.titulo);
END;

-- Trigger para DELETE (Exclusão)
CREATE TRIGGER trg_log_delete_tarefa
BEFORE DELETE ON tarefas
BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao)
    VALUES (OLD.id_tarefa, 'EXCLUSÃO: ' || OLD.titulo);
END;

-- 1. Criar um usuário
INSERT INTO usuario (nome, senha) VALUES ('Dev Tornado', '123456');

-- 2. Criar categorias
INSERT INTO categorias (nome) VALUES ('Trabalho'), ('Estudos'), ('Pessoal');

-- 3. Criar status possíveis
INSERT INTO status_tarefa (descricao) VALUES ('Pendente'), ('Em Andamento'), ('Concluído');

INSERT INTO tarefas (titulo, descricao, id_usuario, id_categoria, id_status)
VALUES ('Finalizar API', 'Terminar os handlers do Tornado', 1, 1, 1);

SELECT * FROM vw_detalhes_tarefas;

select * from usuario;

INSERT INTO usuario (nome, senha) VALUES ('carol', '123');

UPDATE tarefas SET id_status = 2 WHERE id_tarefa = 1;