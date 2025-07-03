-- =======================================
-- VIEWS DE RELATÓRIOS - SISTEMA DE VENDAS
-- =======================================

-- 🔹 Produtos com estoque baixo
CREATE OR REPLACE VIEW vw_produtos_estoque_baixo AS
SELECT id_produto, nome, estoque
FROM Produto
WHERE estoque < 5
ORDER BY estoque ASC;

-- 🔹 Total de vendas por cliente
CREATE OR REPLACE VIEW vw_total_gasto_por_cliente AS
SELECT 
    c.id_cliente,
    c.nome,
    SUM(p.valor + p.multa) AS total_gasto
FROM Cliente c
JOIN Venda v ON v.id_cliente = c.id_cliente
JOIN Parcela p ON p.id_venda = v.id_venda
GROUP BY c.id_cliente, c.nome
ORDER BY total_gasto DESC;

-- 🔹 Parcelas vencidas e não pagas
CREATE OR REPLACE VIEW vw_parcelas_vencidas AS
SELECT 
    p.id_parcela,
    p.id_venda,
    p.dt_venc,
    p.valor,
    c.nome AS cliente,
    v.data AS data_venda
FROM Parcela p
JOIN Venda v ON v.id_venda = p.id_venda
JOIN Cliente c ON c.id_cliente = v.id_cliente
WHERE p.dt_pag IS NULL AND p.dt_venc < CURRENT_DATE
ORDER BY p.dt_venc ASC;

-- 🔹 Histórico de movimentação de estoque
CREATE OR REPLACE VIEW vw_log_estoque AS
SELECT 
    le.id,
    le.id_produto,
    pr.nome AS produto,
    le.operacao,
    le.quantidade,
    le.origem,
    le.data
FROM Log_Estoque le
JOIN Produto pr ON pr.id_produto = le.id_produto
ORDER BY le.data DESC;

-- 🔹 Vendas realizadas em um período (view simples para exibição, com todos os dados)
-- Para filtro por data, use WHERE em SELECT
CREATE OR REPLACE VIEW vw_vendas_com_detalhes AS
SELECT 
    v.id_venda,
    v.data,
    c.nome AS cliente,
    f.nome AS funcionario
FROM Venda v
JOIN Cliente c ON c.id_cliente = v.id_cliente
JOIN Funcionario f ON f.id_funcionario = v.id_funcionario
ORDER BY v.data;

-- 🔹 Faturamento total do mês atual
CREATE OR REPLACE VIEW vw_faturamento_mes_atual AS
SELECT 
    EXTRACT(MONTH FROM dt_pag) AS mes,
    SUM(valor + multa) AS total_pago
FROM Parcela
WHERE dt_pag IS NOT NULL AND DATE_TRUNC('month', dt_pag) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY mes;

-- 🔹 Produtos mais vendidos (TOP 10)
CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT 
    p.id_produto,
    p.nome,
    SUM(iv.quantidade) AS total_vendido
FROM Item_Venda iv
JOIN Produto p ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY total_vendido DESC
LIMIT 10;

-- 🔹 Evolução de vendas por mês
CREATE OR REPLACE VIEW vw_evolucao_vendas_mensal AS
SELECT 
    DATE_TRUNC('month', v.data) AS mes,
    COUNT(DISTINCT v.id_venda) AS total_vendas,
    SUM(p.valor + p.multa) AS total_receita
FROM Venda v
JOIN Parcela p ON p.id_venda = v.id_venda
GROUP BY mes
ORDER BY mes;

-- 🔹 Funcionário com mais vendas
CREATE OR REPLACE VIEW vw_funcionario_top_vendas AS
SELECT 
    f.id_funcionario,
    f.nome,
    COUNT(DISTINCT v.id_venda) AS total_vendas
FROM Funcionario f
JOIN Venda v ON v.id_funcionario = f.id_funcionario
GROUP BY f.id_funcionario, f.nome
ORDER BY total_vendas DESC;

-- 🔹 Compras feitas por fornecedor
CREATE OR REPLACE VIEW vw_compras_por_fornecedor AS
SELECT 
    fo.id_fornecedor,
    fo.nome,
    co.id_compra,
    co.data
FROM Fornecedor fo
JOIN Fornece fz ON fz.id_fornecedor = fo.id_fornecedor
JOIN Compra co ON co.id_compra = fz.id_compra
ORDER BY co.data DESC;

-- ===============================
-- FIM DAS VIEWS DE RELATÓRIOS
-- ===============================
