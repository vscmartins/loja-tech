

-- ============================================================
-- BANCO DE DADOS DA AULA: loja_tech
-- Contexto: Loja de produtos de tecnologia (e-commerce)
-- ============================================================
DROP DATABASE IF EXISTS loja_tech;
CREATE DATABASE loja_tech
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE loja_tech;

-- ------------------------------------------------------------
-- TABELA: categorias
-- ------------------------------------------------------------
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABELA: produtos
-- ------------------------------------------------------------
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 5,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- ------------------------------------------------------------
-- TABELA: clientes
-- ------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    data_nascimento DATE,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABELA: pedidos
-- ------------------------------------------------------------
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pendente','processando','enviado','entregue','cancelado') DEFAULT 'pendente',
    valor_total DECIMAL(10,2) DEFAULT 0.00,
    observacao TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- ------------------------------------------------------------
-- TABELA: itens_pedido
-- ------------------------------------------------------------
CREATE TABLE itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
    CONSTRAINT fk_item_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    CONSTRAINT fk_item_produto
        FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- ------------------------------------------------------------
-- TABELA: log_operacoes
-- ------------------------------------------------------------
CREATE TABLE log_operacoes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(100),
    operacao VARCHAR(50),
    descricao TEXT,
    usuario VARCHAR(100) DEFAULT (CURRENT_USER()),
    data_operacao DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- CARGA DE DADOS INICIAIS
-- ============================================================
INSERT INTO categorias (nome, descricao) VALUES
('Notebooks', 'Notebooks e laptops'),
('Smartphones', 'Celulares e smartphones'),
('Periféricos', 'Teclados, mouses, headsets'),
('Monitores', 'Monitores e telas'),
('Armazenamento', 'HDs, SSDs e pen drives');

INSERT INTO produtos (id_categoria, nome, preco, estoque, estoque_minimo) VALUES
(1, 'Notebook Dell Inspiron 15', 3499.90, 25, 5),
(1, 'Notebook Lenovo IdeaPad 3', 2899.00, 18, 5),
(2, 'Samsung Galaxy S24', 4299.00, 40, 10),
(2, 'iPhone 15', 6499.00, 15, 5),
(3, 'Teclado Mecânico Redragon', 249.90, 60, 10),
(3, 'Mouse Logitech G502', 349.90, 45, 10),
(3, 'Headset HyperX Cloud II', 499.90, 30, 8),
(4, 'Monitor LG UltraWide 29"', 1599.00, 12, 3),
(4, 'Monitor Samsung Curvo 27"', 1899.00, 10, 3),
(5, 'SSD Kingston 480GB', 219.90, 80, 15),
(5, 'HD Externo Seagate 1TB', 329.90, 35, 8);

INSERT INTO clientes (nome, email, cpf, telefone, data_nascimento) VALUES
('Ana Silva', 'ana.silva@email.com', '12345678901', '11987654321', '1995-03-15'),
('Bruno Oliveira', 'bruno.oliveira@email.com', '23456789012', '11976543210', '1990-07-22'),
('Carla Santos', 'carla.santos@email.com', '34567890123', '21965432109', '1988-11-08'),
('Daniel Costa', 'daniel.costa@email.com', '45678901234', '31954321098', '2000-01-30'),
('Elena Ferreira', 'elena.ferreira@email.com', '56789012345', '41943210987', '1998-06-12');

INSERT INTO pedidos (id_cliente, status, valor_total) VALUES
(1, 'entregue', 3749.80),
(2, 'enviado', 4299.00),
(3, 'pendente', 1099.70),
(1, 'processando', 6499.00),
(4, 'cancelado', 249.90);

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 3499.90),
(1, 5, 1, 249.90),
(2, 3, 1, 4299.00),
(3, 6, 1, 349.90),
(3, 5, 3, 249.90),
(4, 4, 1, 6499.00),
(5, 5, 1, 249.90);

-- ============================================================
-- EXEMPLO 1: Olá Mundo
-- ============================================================
DELIMITER //
CREATE PROCEDURE ola_mundo()
BEGIN
    SELECT 'Olá, mundo! Esta é minha primeira Stored Procedure!' AS mensagem;
END //
DELIMITER ;

CALL ola_mundo();

-- ============================================================
-- EXEMPLO 2: Listar todos os produtos ativos
-- ============================================================
DELIMITER //
CREATE PROCEDURE listar_produtos_ativos()
BEGIN
    SELECT
        p.id_produto,
        p.nome AS produto,
        c.nome AS categoria,
        p.preco,
        p.estoque,
        CASE
            WHEN p.estoque <= p.estoque_minimo THEN 'BAIXO'
            WHEN p.estoque <= p.estoque_minimo * 2 THEN 'ATENÇÃO'
            ELSE 'OK'
        END AS situacao_estoque
    FROM produtos p
    INNER JOIN categorias c ON c.id_categoria = p.id_categoria
    WHERE p.ativo = TRUE
    ORDER BY c.nome, p.nome;
END //
DELIMITER ;

CALL listar_produtos_ativos();

-- Comandos de gerenciamento
SHOW PROCEDURE STATUS WHERE Db = 'loja_tech';
SHOW CREATE PROCEDURE listar_produtos_ativos;
DROP PROCEDURE IF EXISTS ola_mundo;

-- Recriar (padrão comum: DROP + CREATE)
DROP PROCEDURE IF EXISTS listar_produtos_ativos;
DELIMITER //
CREATE PROCEDURE listar_produtos_ativos()
BEGIN
    SELECT * FROM produtos WHERE ativo = TRUE;
END //
DELIMITER ;

-- ============================================================
-- EXEMPLO 3: Variáveis locais com DECLARE
-- ============================================================
DELIMITER //
CREATE PROCEDURE resumo_estoque()
BEGIN
    DECLARE v_total_produtos INT DEFAULT 0;
    DECLARE v_valor_estoque DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_produtos_baixo INT DEFAULT 0;

    SELECT COUNT(*),
           SUM(preco * estoque)
      INTO v_total_produtos,
           v_valor_estoque
      FROM produtos
     WHERE ativo = TRUE;

    SELECT COUNT(*)
      INTO v_produtos_baixo
      FROM produtos
     WHERE ativo = TRUE
       AND estoque <= estoque_minimo;

    SELECT
        v_total_produtos AS total_produtos_ativos,
        v_valor_estoque AS valor_total_em_estoque,
        v_produtos_baixo AS produtos_estoque_baixo;
END //
DELIMITER ;

CALL resumo_estoque();

-- ============================================================
-- EXEMPLO 4: Parâmetro IN
-- ============================================================
DELIMITER //
CREATE PROCEDURE buscar_produtos_por_categoria(
    IN p_id_categoria INT
)
BEGIN
    SELECT
        p.id_produto,
        p.nome,
        p.preco,
        p.estoque
    FROM produtos p
    WHERE p.id_categoria = p_id_categoria
      AND p.ativo = TRUE
    ORDER BY p.nome;
END //
DELIMITER ;

CALL buscar_produtos_por_categoria(1);
CALL buscar_produtos_por_categoria(3);

-- ============================================================
-- EXEMPLO 5: Parâmetro OUT
-- ============================================================
DELIMITER //
CREATE PROCEDURE contar_pedidos_cliente(
    IN p_id_cliente INT,
    OUT p_total_pedidos INT,
    OUT p_classificacao VARCHAR(20)
)
BEGIN
    SELECT COUNT(*)
      INTO p_total_pedidos
      FROM pedidos
     WHERE id_cliente = p_id_cliente
       AND status <> 'cancelado';

    IF p_total_pedidos >= 10 THEN
        SET p_classificacao = 'VIP';
    ELSEIF p_total_pedidos >= 5 THEN
        SET p_classificacao = 'Frequente';
    ELSEIF p_total_pedidos >= 1 THEN
        SET p_classificacao = 'Regular';
    ELSE
        SET p_classificacao = 'Novo';
    END IF;
END //
DELIMITER ;

CALL contar_pedidos_cliente(1, @total, @classe);
SELECT @total AS total_pedidos, @classe AS classificacao;

-- ============================================================
-- EXEMPLO 6: Parâmetro INOUT
-- ============================================================
DELIMITER //
CREATE PROCEDURE aplicar_desconto(
    INOUT p_preco DECIMAL(10,2),
    IN p_percentual DECIMAL(5,2)
)
BEGIN
    SET p_preco = p_preco - (p_preco * p_percentual / 100);
END //
DELIMITER ;

SET @meu_preco = 1000.00;
CALL aplicar_desconto(@meu_preco, 15);
SELECT @meu_preco AS preco_com_desconto;

-- ============================================================
-- EXEMPLO 7: IF / ELSEIF / ELSE (frete)
-- ============================================================
DELIMITER //
CREATE PROCEDURE calcular_frete(
    IN p_valor_pedido DECIMAL(10,2),
    OUT p_valor_frete DECIMAL(10,2),
    OUT p_mensagem VARCHAR(100)
)
BEGIN
    IF p_valor_pedido >= 500.00 THEN
        SET p_valor_frete = 0.00;
        SET p_mensagem = 'Parabéns! Frete grátis!';
    ELSEIF p_valor_pedido >= 200.00 THEN
        SET p_valor_frete = 25.00;
        SET p_mensagem = CONCAT('Frete: R$ 25,00. Faltam R$ ',
                                FORMAT(500.00 - p_valor_pedido, 2),
                                ' para frete grátis!');
    ELSE
        SET p_valor_frete = 45.00;
        SET p_mensagem = CONCAT('Frete: R$ 45,00. Faltam R$ ',
                                FORMAT(500.00 - p_valor_pedido, 2),
                                ' para frete grátis!');
    END IF;
END //
DELIMITER ;

CALL calcular_frete(350.00, @frete, @msg);
SELECT @frete, @msg;

-- ============================================================
-- EXEMPLO 8: CASE (status do pedido)
-- ============================================================
DELIMITER //
CREATE PROCEDURE descrever_status_pedido(
    IN p_id_pedido INT,
    OUT p_descricao VARCHAR(200)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
      FROM pedidos
     WHERE id_pedido = p_id_pedido;

    CASE v_status
        WHEN 'pendente' THEN SET p_descricao = 'Pedido recebido, aguardando pagamento.';
        WHEN 'processando' THEN SET p_descricao = 'Pagamento confirmado, preparando envio.';
        WHEN 'enviado' THEN SET p_descricao = 'Pedido a caminho! Acompanhe pelo rastreio.';
        WHEN 'entregue' THEN SET p_descricao = 'Pedido entregue com sucesso!';
        WHEN 'cancelado' THEN SET p_descricao = 'Pedido foi cancelado.';
        ELSE SET p_descricao = 'Status desconhecido.';
    END CASE;
END //
DELIMITER ;

CALL descrever_status_pedido(1, @desc);
SELECT @desc;

-- ============================================================
-- EXEMPLO 9: WHILE (gerar cupons)
-- ============================================================
CREATE TABLE cupons_desconto (
    id_cupom INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    percentual DECIMAL(5,2) NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE PROCEDURE gerar_cupons(
    IN p_quantidade INT,
    IN p_percentual DECIMAL(5,2)
)
BEGIN
    DECLARE v_contador INT DEFAULT 0;
    DECLARE v_codigo VARCHAR(10);

    WHILE v_contador < p_quantidade DO
        SET v_codigo = UPPER(SUBSTRING(MD5(RAND()), 1, 8));

        INSERT IGNORE INTO cupons_desconto (codigo, percentual)
        VALUES (v_codigo, p_percentual);

        SET v_contador = v_contador + 1;
    END WHILE;

    SELECT CONCAT(v_contador, ' cupons de ',
                  p_percentual, '% gerados com sucesso!') AS resultado;
END //
DELIMITER ;

CALL gerar_cupons(10, 20.00);
SELECT * FROM cupons_desconto;

-- ============================================================
-- CENÁRIO 1: Cadastrar produto (com validações)
-- ============================================================
DELIMITER //
CREATE PROCEDURE cadastrar_produto(
    IN p_id_categoria INT,
    IN p_nome VARCHAR(200),
    IN p_descricao TEXT,
    IN p_preco DECIMAL(10,2),
    IN p_estoque INT,
    IN p_estoque_minimo INT,
    OUT p_id_gerado INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_categoria_existe INT DEFAULT 0;
    DECLARE v_produto_existe INT DEFAULT 0;

    -- Validação 1: nome não vazio
    IF p_nome IS NULL OR TRIM(p_nome) = '' THEN
        SET p_id_gerado = 0;
        SET p_mensagem = 'ERRO: O nome do produto é obrigatório.';

    -- Validação 2: preço positivo
    ELSEIF p_preco <= 0 THEN
        SET p_id_gerado = 0;
        SET p_mensagem = 'ERRO: O preço deve ser maior que zero.';

    ELSE
        -- Validação 3: categoria existe?
        SELECT COUNT(*) INTO v_categoria_existe
          FROM categorias
         WHERE id_categoria = p_id_categoria AND ativo = TRUE;

        IF v_categoria_existe = 0 THEN
            SET p_id_gerado = 0;
            SET p_mensagem = 'ERRO: Categoria não encontrada ou inativa.';
        ELSE
            -- Validação 4: produto duplicado?
            SELECT COUNT(*) INTO v_produto_existe
              FROM produtos
             WHERE nome = p_nome AND id_categoria = p_id_categoria;

            IF v_produto_existe > 0 THEN
                SET p_id_gerado = 0;
                SET p_mensagem = 'ERRO: Já existe um produto com este nome nesta categoria.';
            ELSE
                INSERT INTO produtos (id_categoria, nome, descricao, preco, estoque, estoque_minimo)
                VALUES (p_id_categoria, TRIM(p_nome), p_descricao, p_preco,
                        IFNULL(p_estoque, 0), IFNULL(p_estoque_minimo, 5));

                SET p_id_gerado = LAST_INSERT_ID();
                SET p_mensagem = CONCAT('Produto cadastrado com sucesso! ID: ', p_id_gerado);

                INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
                VALUES ('produtos', 'INSERT',
                        CONCAT('Produto criado: ', p_nome, ' | Preço: R$ ',
                               FORMAT(p_preco, 2)));
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

-- Teste 1: cadastro válido
CALL cadastrar_produto(3, 'Webcam Logitech C920', 'Full HD 1080p', 399.90, 20, 5, @id, @msg);
SELECT @id AS id_gerado, @msg AS mensagem;

-- Teste 2: preço inválido
CALL cadastrar_produto(3, 'Mouse Barato', NULL, -10.00, 5, 2, @id, @msg);
SELECT @id AS id_gerado, @msg AS mensagem;

-- Teste 3: categoria inexistente
CALL cadastrar_produto(99, 'Produto Fantasma', NULL, 100.00, 5, 2, @id, @msg);
SELECT @id AS id_gerado, @msg AS mensagem;

-- ============================================================
-- CENÁRIO 2: Registrar pedido completo (com transação)
-- ============================================================
DELIMITER //
CREATE PROCEDURE registrar_pedido(
    IN p_id_cliente INT,
    IN p_observacao TEXT,
    IN p_produto_1 INT, IN p_qtd_1 INT,
    IN p_produto_2 INT, IN p_qtd_2 INT,
    IN p_produto_3 INT, IN p_qtd_3 INT,
    OUT p_id_pedido INT,
    OUT p_valor_total DECIMAL(10,2),
    OUT p_mensagem VARCHAR(500)
)
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_nome_prod VARCHAR(200);
    DECLARE v_total DECIMAL(10,2) DEFAULT 0.00;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_id_pedido = 0;
        SET p_valor_total = 0;
        SET p_mensagem = 'ERRO: Falha ao registrar pedido. Operação cancelada.';
    END;

    START TRANSACTION;

    -- 1. Cabeçalho do pedido
    INSERT INTO pedidos (id_cliente, observacao)
    VALUES (p_id_cliente, p_observacao);

    SET p_id_pedido = LAST_INSERT_ID();

    -- 2. Item 1
    IF p_produto_1 IS NOT NULL AND p_produto_1 > 0 THEN
        SELECT preco, estoque, nome
          INTO v_preco, v_estoque, v_nome_prod
          FROM produtos WHERE id_produto = p_produto_1;

        IF v_estoque < p_qtd_1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque insuficiente para o produto 1';
        END IF;

        INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES (p_id_pedido, p_produto_1, p_qtd_1, v_preco);

        UPDATE produtos SET estoque = estoque - p_qtd_1
         WHERE id_produto = p_produto_1;

        SET v_total = v_total + (v_preco * p_qtd_1);
    END IF;

    -- 3. Item 2
    IF p_produto_2 IS NOT NULL AND p_produto_2 > 0 THEN
        SELECT preco, estoque, nome
          INTO v_preco, v_estoque, v_nome_prod
          FROM produtos WHERE id_produto = p_produto_2;

        IF v_estoque < p_qtd_2 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque insuficiente para o produto 2';
        END IF;

        INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES (p_id_pedido, p_produto_2, p_qtd_2, v_preco);

        UPDATE produtos SET estoque = estoque - p_qtd_2
         WHERE id_produto = p_produto_2;

        SET v_total = v_total + (v_preco * p_qtd_2);
    END IF;

    -- 4. Item 3
    IF p_produto_3 IS NOT NULL AND p_produto_3 > 0 THEN
        SELECT preco, estoque, nome
          INTO v_preco, v_estoque, v_nome_prod
          FROM produtos WHERE id_produto = p_produto_3;

        IF v_estoque < p_qtd_3 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque insuficiente para o produto 3';
        END IF;

        INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES (p_id_pedido, p_produto_3, p_qtd_3, v_preco);

        UPDATE produtos SET estoque = estoque - p_qtd_3
         WHERE id_produto = p_produto_3;

        SET v_total = v_total + (v_preco * p_qtd_3);
    END IF;

    -- 5. Valor total do pedido
    UPDATE pedidos SET valor_total = v_total
     WHERE id_pedido = p_id_pedido;

    -- 6. Log
    INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
    VALUES ('pedidos', 'INSERT',
            CONCAT('Pedido #', p_id_pedido,
                   ' | Cliente: ', p_id_cliente,
                   ' | Valor: R$ ', FORMAT(v_total, 2)));

    COMMIT;

    SET p_valor_total = v_total;
    SET p_mensagem = CONCAT('Pedido #', p_id_pedido,
                            ' registrado com sucesso! Total: R$ ',
                            FORMAT(v_total, 2));
END //
DELIMITER ;

-- Teste: Ana Silva comprando Notebook + Teclado + Mouse
CALL registrar_pedido(
    1,
    'Presente de aniversário',
    1, 1,
    5, 2,
    6, 1,
    @pedido, @total, @msg
);
SELECT @pedido, @total, @msg;

-- Conferir estoque
SELECT id_produto, nome, estoque FROM produtos WHERE id_produto IN (1, 5, 6);

-- ============================================================
-- CENÁRIO 3: Relatório de vendas por período
-- ============================================================
DELIMITER //
CREATE PROCEDURE relatorio_vendas_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    -- Resumo geral
    SELECT
        COUNT(DISTINCT p.id_pedido) AS total_pedidos,
        COUNT(DISTINCT p.id_cliente) AS clientes_distintos,
        SUM(p.valor_total) AS receita_total,
        AVG(p.valor_total) AS ticket_medio,
        MAX(p.valor_total) AS maior_pedido,
        MIN(p.valor_total) AS menor_pedido
    FROM pedidos p
    WHERE p.data_pedido BETWEEN p_data_inicio AND CONCAT(p_data_fim, ' 23:59:59')
      AND p.status <> 'cancelado';

    -- Ranking de produtos mais vendidos
    SELECT
        pr.nome AS produto,
        SUM(ip.quantidade) AS qtd_vendida,
        SUM(ip.subtotal) AS total_vendido
    FROM itens_pedido ip
    INNER JOIN pedidos pe ON pe.id_pedido = ip.id_pedido
    INNER JOIN produtos pr ON pr.id_produto = ip.id_produto
    WHERE pe.data_pedido BETWEEN p_data_inicio AND CONCAT(p_data_fim, ' 23:59:59')
      AND pe.status <> 'cancelado'
    GROUP BY pr.id_produto, pr.nome
    ORDER BY qtd_vendida DESC
    LIMIT 10;

    -- Ranking de melhores clientes
    SELECT
        c.nome AS cliente,
        COUNT(pe.id_pedido) AS qtd_pedidos,
        SUM(pe.valor_total) AS total_gasto
    FROM clientes c
    INNER JOIN pedidos pe ON pe.id_cliente = c.id_cliente
    WHERE pe.data_pedido BETWEEN p_data_inicio AND CONCAT(p_data_fim, ' 23:59:59')
      AND pe.status <> 'cancelado'
    GROUP BY c.id_cliente, c.nome
    ORDER BY total_gasto DESC
    LIMIT 5;
END //
DELIMITER ;

CALL relatorio_vendas_periodo('2026-11-01', '2026-11-30');

-- ============================================================
-- CENÁRIO 4: Cancelar pedido (com estorno de estoque)
-- ============================================================
DELIMITER //
CREATE PROCEDURE cancelar_pedido(
    IN p_id_pedido INT,
    IN p_motivo TEXT,
    OUT p_mensagem VARCHAR(500)
)
BEGIN
    DECLARE v_status_atual VARCHAR(20);
    DECLARE v_cliente VARCHAR(150);
    DECLARE v_total DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensagem = 'ERRO: Falha ao cancelar pedido.';
    END;

    SELECT pe.status, c.nome, pe.valor_total
      INTO v_status_atual, v_cliente, v_total
      FROM pedidos pe
     INNER JOIN clientes c ON c.id_cliente = pe.id_cliente
     WHERE pe.id_pedido = p_id_pedido;

    IF v_status_atual IS NULL THEN
        SET p_mensagem = 'ERRO: Pedido não encontrado.';
    ELSEIF v_status_atual NOT IN ('pendente', 'processando') THEN
        SET p_mensagem = CONCAT('ERRO: Não é possível cancelar pedido com status "',
                                v_status_atual, '". Só pedidos pendentes ou em processamento.');
    ELSE
        START TRANSACTION;

        UPDATE produtos pr
         INNER JOIN itens_pedido ip ON ip.id_produto = pr.id_produto
           SET pr.estoque = pr.estoque + ip.quantidade
         WHERE ip.id_pedido = p_id_pedido;

        UPDATE pedidos
           SET status = 'cancelado',
               observacao = CONCAT(IFNULL(observacao, ''),
                                   '\n[CANCELADO] ', NOW(), ' - ',
                                   IFNULL(p_motivo, 'Sem motivo'))
         WHERE id_pedido = p_id_pedido;

        INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
        VALUES ('pedidos', 'CANCELAMENTO',
                CONCAT('Pedido #', p_id_pedido,
                       ' | Cliente: ', v_cliente,
                       ' | Valor: R$ ', FORMAT(v_total, 2),
                       ' | Motivo: ', IFNULL(p_motivo, 'Não informado')));

        COMMIT;

        SET p_mensagem = CONCAT('Pedido #', p_id_pedido,
                                ' cancelado com sucesso. Estoque restaurado.');
    END IF;
END //
DELIMITER ;

CALL cancelar_pedido(3, 'Cliente desistiu da compra', @msg);
SELECT @msg;

-- ============================================================
-- BLOCO 5: HANDLERS
-- ============================================================
DELIMITER //
CREATE PROCEDURE demonstrar_handlers()
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SELECT 'ERRO: Registro duplicado! Verifique os dados.' AS erro;
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERRO: Algo deu errado. Operação revertida.' AS erro;
    END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN
        SELECT 'AVISO: Nenhum registro encontrado.' AS aviso;
    END;

    SELECT 'Demonstração de handlers' AS info;
END //
DELIMITER ;

CALL demonstrar_handlers();

-- ============================================================
-- BLOCO 5: SIGNAL
-- ============================================================
DELIMITER //
CREATE PROCEDURE validar_idade_cliente(
    IN p_data_nascimento DATE
)
BEGIN
    DECLARE v_idade INT;

    SET v_idade = TIMESTAMPDIFF(YEAR, p_data_nascimento, CURDATE());

    IF v_idade < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cliente deve ter pelo menos 18 anos.',
                MYSQL_ERRNO = 5001;
    ELSEIF v_idade > 120 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de nascimento inválida.',
                MYSQL_ERRNO = 5002;
    ELSE
        SELECT CONCAT('Idade válida: ', v_idade, ' anos.') AS resultado;
    END IF;
END //
DELIMITER ;

-- Teste com data válida
CALL validar_idade_cliente('1995-03-15');

-- Teste de menor de idade: gera erro de propósito (ERRO 5001).
-- Execute esta linha separadamente, pois o erro interrompe o script.
-- CALL validar_idade_cliente('2015-06-20');

-- ============================================================
-- BLOCO 5: SEGURANÇA (permissões)
-- Requer usuário com privilégio para criar usuários (ex: root)
-- ============================================================
DROP USER IF EXISTS 'vendedor'@'localhost';
CREATE USER 'vendedor'@'localhost' IDENTIFIED BY 'senha123';

GRANT EXECUTE ON PROCEDURE loja_tech.buscar_produtos_por_categoria TO 'vendedor'@'localhost';
GRANT EXECUTE ON PROCEDURE loja_tech.registrar_pedido TO 'vendedor'@'localhost';
GRANT EXECUTE ON PROCEDURE loja_tech.relatorio_vendas_periodo TO 'vendedor'@'localhost';