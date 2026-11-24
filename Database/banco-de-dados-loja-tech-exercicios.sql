USE loja_tech;

-- ============================================================
-- EXERCICIO 1: atualizar_preco_categoria
-- Regras:
-- 1. Categoria deve existir e estar ativa
-- 2. Desconto maximo de 50% (percentual >= -50)
-- 3. Aumento maximo de 100% (percentual <= 100)
-- 4. Percentual zero nao altera nada
-- 5. Retorna quantidade de produtos alterados e mensagem
-- 6. Registra a operacao em log_operacoes
-- ============================================================
DROP PROCEDURE IF EXISTS atualizar_preco_categoria;

DELIMITER //

CREATE PROCEDURE atualizar_preco_categoria(
    IN  p_id_categoria   INT,
    IN  p_percentual     DECIMAL(5,2),
    OUT p_qtd_alterados  INT,
    OUT p_mensagem       VARCHAR(255)
)
BEGIN
    DECLARE v_categoria_existe INT DEFAULT 0;
    DECLARE v_nome_categoria   VARCHAR(100);

    -- Em caso de erro inesperado, desfaz tudo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: Falha ao atualizar os precos. Operacao cancelada.';
    END;

    SET p_qtd_alterados = 0;

    -- Validacao 1: parametros nulos
    IF p_id_categoria IS NULL OR p_percentual IS NULL THEN
        SET p_mensagem = 'ERRO: Categoria e percentual sao obrigatorios.';

    -- Validacao 2: percentual zero
    ELSEIF p_percentual = 0 THEN
        SET p_mensagem = 'AVISO: Percentual igual a zero. Nenhum preco foi alterado.';

    -- Validacao 3: desconto maximo
    ELSEIF p_percentual < -50 THEN
        SET p_mensagem = 'ERRO: O desconto maximo permitido e de 50%.';

    -- Validacao 4: aumento maximo
    ELSEIF p_percentual > 100 THEN
        SET p_mensagem = 'ERRO: O aumento maximo permitido e de 100%.';

    ELSE
        -- Validacao 5: categoria existe e esta ativa
        SELECT COUNT(*), MAX(nome)
          INTO v_categoria_existe, v_nome_categoria
          FROM categorias
         WHERE id_categoria = p_id_categoria
           AND ativo = TRUE;

        IF v_categoria_existe = 0 THEN
            SET p_mensagem = 'ERRO: Categoria nao encontrada ou inativa.';
        ELSE
            START TRANSACTION;

            UPDATE produtos
               SET preco = ROUND(preco * (1 + p_percentual / 100), 2)
             WHERE id_categoria = p_id_categoria
               AND ativo = TRUE;

            SET p_qtd_alterados = ROW_COUNT();

            INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
            VALUES ('produtos', 'UPDATE',
                    CONCAT('Reajuste de ', p_percentual, '% na categoria "',
                           v_nome_categoria, '" (ID ', p_id_categoria, '). ',
                           'Produtos alterados: ', p_qtd_alterados));

            COMMIT;

            SET p_mensagem = CONCAT('Sucesso: ', p_qtd_alterados,
                                    ' produto(s) da categoria "', v_nome_categoria,
                                    '" reajustado(s) em ', p_percentual, '%.');
        END IF;
    END IF;
END //

DELIMITER ;

-- ============================================================
-- TESTES
-- ============================================================

-- Preco antes
SELECT id_produto, nome, preco FROM produtos WHERE id_categoria = 3;

-- Teste 1: aumento valido de 10% em Perifericos
CALL atualizar_preco_categoria(3, 10.00, @qtd, @msg);
SELECT @qtd AS qtd_alterados, @msg AS mensagem;

-- Teste 2: desconto acima do limite
CALL atualizar_preco_categoria(3, -60.00, @qtd, @msg);
SELECT @qtd AS qtd_alterados, @msg AS mensagem;

-- Teste 3: aumento acima do limite
CALL atualizar_preco_categoria(3, 150.00, @qtd, @msg);
SELECT @qtd AS qtd_alterados, @msg AS mensagem;

-- Teste 4: categoria inexistente
CALL atualizar_preco_categoria(99, 10.00, @qtd, @msg);
SELECT @qtd AS qtd_alterados, @msg AS mensagem;

-- Teste 5: percentual zero
CALL atualizar_preco_categoria(3, 0, @qtd, @msg);
SELECT @qtd AS qtd_alterados, @msg AS mensagem;

-- Preco depois e log
SELECT id_produto, nome, preco FROM produtos WHERE id_categoria = 3;
SELECT * FROM log_operacoes ORDER BY id_log DESC;