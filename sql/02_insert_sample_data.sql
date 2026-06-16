INSERT INTO dim_banca (nome_banca)
VALUES 
('FGV'),
('Cebraspe'),
('FCC'),
('Instituto AOCP')
ON CONFLICT (nome_banca) DO NOTHING;

INSERT INTO dim_estado (sigla_estado, nome_estado, regiao)
VALUES
('PI', 'Piauí', 'Nordeste'),
('SP', 'São Paulo', 'Sudeste'),
('DF', 'Distrito Federal', 'Centro-Oeste'),
('CE', 'Ceará', 'Nordeste')
ON CONFLICT (sigla_estado) DO NOTHING;

INSERT INTO dim_cargo (nome_cargo, area, nivel)
VALUES
('Analista de Tecnologia da Informação', 'TI', 'Superior'),
('Auditor de Controle Externo - TI', 'TI', 'Superior'),
('Técnico de Informática', 'TI', 'Médio'),
('Analista de Dados', 'Dados', 'Superior');

INSERT INTO dim_orgao (nome_orgao, esfera)
VALUES
('TCE-PI', 'Estadual'),
('Prefeitura de São Paulo', 'Municipal'),
('Banco do Brasil', 'Federal'),
('TJ-CE', 'Estadual')
ON CONFLICT (nome_orgao) DO NOTHING;

INSERT INTO fato_concurso (
    id_banca,
    id_estado,
    id_cargo,
    id_orgao,
    ano,
    vagas,
    salario,
    inscricao_inicio,
    inscricao_fim,
    data_prova,
    url_edital
)
VALUES
(1, 1, 2, 1, 2026, 10, 18000.00, '2026-06-01', '2026-07-01', '2026-08-15', 'https://exemplo.com/edital-tce-pi'),
(2, 3, 1, 3, 2026, 50, 9500.00, '2026-05-10', '2026-06-20', '2026-08-01', 'https://exemplo.com/edital-bb'),
(3, 2, 3, 2, 2025, 20, 6500.00, '2025-04-01', '2025-05-01', '2025-06-20', 'https://exemplo.com/edital-prefeitura-sp'),
(4, 4, 4, 4, 2026, 5, 12000.00, '2026-03-15', '2026-04-15', '2026-06-10', 'https://exemplo.com/edital-tj-ce');