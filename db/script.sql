-- Tabelas Base
CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    senha TEXT NOT NULL
);

CREATE TABLE categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
);

CREATE TABLE status_tarefa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL
);

-- Tabela de Tarefas
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

-- Tabela de Logs
CREATE TABLE logs_tarefas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tarefa_id INTEGER,
    acao TEXT,
    data_log DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- VIEW Consolidada (Une todas as 5 tabelas)
CREATE VIEW vw_detalhes_tarefas AS
SELECT
    t.id_tarefa,
    t.titulo,
    t.descricao,
    c.nome AS categoria,
    s.descricao AS status_atual,
    u.nome AS dono_da_tarefa
FROM tarefas t
JOIN usuario u ON t.id_usuario = u.id_usuario
JOIN categorias c ON t.id_categoria = c.id
JOIN status_tarefa s ON t.id_status = s.id;

-- TRIGGERS (Automáticos)
CREATE TRIGGER trg_log_insert AFTER INSERT ON tarefas BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao) VALUES (NEW.id_tarefa, 'CRIOU: ' || NEW.titulo);
END;

CREATE TRIGGER trg_log_update AFTER UPDATE ON tarefas BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao) VALUES (NEW.id_tarefa, 'EDITOU: ' || NEW.titulo);
END;

CREATE TRIGGER trg_log_delete BEFORE DELETE ON tarefas BEGIN
    INSERT INTO logs_tarefas (tarefa_id, acao) VALUES (OLD.id_tarefa, 'DELETOU: ' || OLD.titulo);
END;

-- Dados Iniciais
INSERT INTO categorias (nome) VALUES ('Trabalho'), ('Estudos'), ('Pessoal');
INSERT INTO status_tarefa (descricao) VALUES ('Pendente'), ('Em Andamento'), ('Concluída');

insert into usuario (nome, senha)
values ('carol','123');