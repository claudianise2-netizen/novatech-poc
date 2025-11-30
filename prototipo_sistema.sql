/* =======================================================
   1. TABELAS DE CADASTRO (ENTIDADES)
   ======================================================= */

CREATE TABLE CLIENTE (
    idCliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    cpf VARCHAR(14) UNIQUE
);

CREATE TABLE FUNCIONARIO (
    idFuncionario INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    senha VARCHAR(50) NOT NULL
);

CREATE TABLE MESA (
    idMesa INT PRIMARY KEY,
    numeroMesa INT UNIQUE NOT NULL,
    statusMesa VARCHAR(20) DEFAULT 'Livre'
);

CREATE TABLE PRODUTO (
    idProduto INT PRIMARY KEY,
    nomeProduto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    preco DECIMAL(10, 2) NOT NULL,
    disponibilidade BOOLEAN DEFAULT TRUE
);

/* =======================================================
   2. TABELAS DE TRANSAÇÃO (RELACIONAMENTOS)
   ======================================================= */

CREATE TABLE PEDIDO (
    idPedido INT PRIMARY KEY,
    idMesa INT NOT NULL,
    idFuncionario INT NOT NULL,
    dataHora DATETIME NOT NULL,
    statusPedido VARCHAR(20) DEFAULT 'recebido',
    
    FOREIGN KEY (idMesa) REFERENCES MESA(idMesa),
    FOREIGN KEY (idFuncionario) REFERENCES FUNCIONARIO(idFuncionario)
);

CREATE TABLE ITEM_PEDIDO (
    idItem INT PRIMARY KEY,
    idPedido INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL,
    observacoes VARCHAR(255),

    FOREIGN KEY (idPedido) REFERENCES PEDIDO(idPedido),
    FOREIGN KEY (idProduto) REFERENCES PRODUTO(idProduto)
);

CREATE TABLE TRANSACAO_FINANCEIRA (
    idTransacao INT PRIMARY KEY,
    idPedido INT UNIQUE NOT NULL,
    valorBruto DECIMAL(10, 2) NOT NULL,
    taxa DECIMAL(10, 2),
    desconto DECIMAL(10, 2),
    valorFinal DECIMAL(10, 2) NOT NULL,
    formaPagamento VARCHAR(50),
    statusPagamento VARCHAR(20) DEFAULT 'Aguardando',

    FOREIGN KEY (idPedido) REFERENCES PEDIDO(idPedido)
);

/* =======================================================
   3. INSERÇÃO DE DADOS BÁSICOS
   ======================================================= */

INSERT INTO FUNCIONARIO VALUES
(101, 'Marcos Ribeiro', 'Atendente', '1234'),
(102, 'Julia Silva', 'Caixa', 'abcd');

INSERT INTO MESA VALUES
(1, 1, 'Livre'),
(2, 2, 'Livre'),
(3, 3, 'Livre'),
(4, 4, 'Livre');

INSERT INTO PRODUTO VALUES
(5, 'Café', 'Bebida', 3.00, TRUE),
(25, 'Carne Grelhada', 'Prato', 25.00, TRUE);

/* =======================================================
   4. MÓDULO DE ATENDIMENTO — ENVIO DO PEDIDO
   ======================================================= */

-- 4.1 Inserir Pedido
INSERT INTO PEDIDO (idPedido, idMesa, idFuncionario, dataHora, statusPedido)
VALUES (500, 4, 101, NOW(), 'recebido');

-- 4.2 Inserir Itens
INSERT INTO ITEM_PEDIDO (idItem, idPedido, idProduto, quantidade, observacoes)
VALUES (1, 500, 25, 2, 'bem passado');

INSERT INTO ITEM_PEDIDO (idItem, idPedido, idProduto, quantidade, observacoes)
VALUES (2, 500, 5, 1, 'sem gelo');

/* =======================================================
   5. MÓDULO DA COZINHA
   ======================================================= */

-- 5.1 Exibir pedidos pendentes
SELECT
    P.idPedido,
    M.numeroMesa,
    P.dataHora,
    PR.nomeProduto,
    IP.quantidade,
    IP.observacoes
FROM PEDIDO P
JOIN MESA M ON P.idMesa = M.idMesa
JOIN ITEM_PEDIDO IP ON P.idPedido = IP.idPedido
JOIN PRODUTO PR ON IP.idProduto = PR.idProduto
WHERE P.statusPedido IN ('recebido', 'em preparo')
ORDER BY P.dataHora ASC;

-- 5.2 Atualizar status para "em preparo"
UPDATE PEDIDO
SET statusPedido = 'em preparo'
WHERE idPedido = 500;

-- 5.3 Atualizar status para "pronto"
UPDATE PEDIDO
SET statusPedido = 'pronto'
WHERE idPedido = 500;

/* =======================================================
   6. MÓDULO FINANCEIRO
   ======================================================= */

-- 6.1 Cálculo do valor bruto
SELECT
    SUM(IP.quantidade * P2.preco) AS valorBrutoTotal
FROM ITEM_PEDIDO IP
JOIN PRODUTO P2 ON IP.idProduto = P2.idProduto
WHERE IP.idPedido = 500;

-- 6.2 Inserção da transação financeira
INSERT INTO TRANSACAO_FINANCEIRA (
    idTransacao, idPedido, valorBruto, taxa, desconto, valorFinal, formaPagamento, statusPagamento
)
VALUES (900, 500, 150.00, 15.00, 0.00, 165.00, 'Dinheiro', 'Concluído');

-- 6.3 Atualizar status do pedido para "pago"
UPDATE PEDIDO
SET statusPedido = 'pago'
WHERE idPedido = 500;
