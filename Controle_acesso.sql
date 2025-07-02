-- =========================================
-- CONTROLE DE ACESSO - SISTEMA DE VENDAS
-- =========================================

-- ========================
-- 1. CRIAÇÃO DOS USUÁRIOS
-- ========================

-- Admin (acesso total)
CREATE ROLE admin LOGIN PASSWORD 'admin123';

-- Vendedor (realiza vendas)
CREATE ROLE vendedor LOGIN PASSWORD 'vendedor123';

-- Estoquista (gerencia estoque e produtos)
CREATE ROLE estoquista LOGIN PASSWORD 'estoque123';

-- Leitor (apenas leitura)
CREATE ROLE leitor LOGIN PASSWORD 'leitor123';

-- ===================================
-- 2. REVOGAÇÃO DE ACESSO PADRÃO
-- ===================================

-- Revoga permissões padrão de todos os usuários
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

-- ===================================
-- 3. CONCESSÃO DE PERMISSÕES
-- ===================================

-- -------------------------------
-- A) ADMIN - ACESSO TOTAL
-- -------------------------------
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

-- -------------------------------
-- B) VENDEDOR - VENDAS
-- -------------------------------
GRANT SELECT ON Cliente, Produto, Venda, Parcela TO vendedor;
GRANT INSERT ON Venda, Item_Venda, Parcela TO vendedor;

-- Permissão para executar a função de venda
GRANT EXECUTE ON FUNCTION realizar_venda_completa(
    INT, DATE, INT, INT, JSON, INT, DATE, NUMERIC, NUMERIC
) TO vendedor;

-- -------------------------------
-- C) ESTOQUISTA - ESTOQUE E PRODUTOS
-- -------------------------------
GRANT SELECT, UPDATE ON Produto TO estoquista;
GRANT INSERT ON Compra, Item_Compra, Log_Estoque TO estoquista;

-- Permissões para atualizar produto e estoque
GRANT EXECUTE ON FUNCTION atualizar_produto(
    INT, VARCHAR, VARCHAR, VARCHAR, INT, DECIMAL, INT
) TO estoquista;

GRANT EXECUTE ON FUNCTION atualizar_estoque_produto(
    INT, INT, TEXT, TEXT
) TO estoquista;

-- -------------------------------
-- D) LEITOR - CONSULTAS SOMENTE
-- -------------------------------
GRANT SELECT ON 
    Cliente, Produto, Venda, Parcela, Item_Venda, Item_Compra, Compra, Fornecedor 
TO leitor;

-- ===================================
-- 4. BLOQUEIO ADICIONAL
-- ===================================

-- Proíbe DELETE para todos, exceto admin
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT DELETE ON ALL TABLES IN SCHEMA public TO admin;

-- Proíbe UPDATE para todos, exceto funções específicas
REVOKE UPDATE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT UPDATE ON Produto TO estoquista;
GRANT UPDATE ON Cliente, Venda, Parcela TO admin;

-- ===================================
-- 5. OPCIONAL: USO DE SECURITY DEFINER
-- ===================================

-- Se desejar que funções possam ser executadas sem que o usuário tenha acesso direto às tabelas,
-- adicione SECURITY DEFINER nas funções sensíveis, como abaixo:

-- Exemplo:
-- ALTER FUNCTION realizar_venda_completa(...) OWNER TO admin;
-- ALTER FUNCTION realizar_venda_completa(...) SET SECURITY DEFINER;

-- ===================================
-- FIM DO SCRIPT
-- ===================================
