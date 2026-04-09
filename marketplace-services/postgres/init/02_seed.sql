-- ==================================================
-- DADOS INICIAIS - CATEGORIAS DE SERVIÇO
-- ==================================================
INSERT INTO service_categories (name, slug, description, icon, base_fee, radius_km) VALUES
('Redes e Infraestrutura', 'networks', 'Instalação e manutenção de redes, cabeamento estruturado, switches e roteadores', 'wifi', 100.00, 25),
('CFTV e Segurança Eletrônica', 'cctv', 'Instalação de câmeras, DVR, alarmes e controle de acesso', 'video', 100.00, 25),
('Elétrica Residencial/Comercial', 'electrician', 'Serviços elétricos, instalações e manutenções', 'zap', 100.00, 20),
('Encanamento e Hidráulica', 'plumber', 'Reparos hidráulicos, vazamentos, encanamentos', 'droplet', 100.00, 20),
('Refrigeração e Ar Condicionado', 'hvac', 'Instalação e manutenção de ar condicionado e refrigeração', 'snowflake', 150.00, 30),
('Serralheria e Metalúrgica', 'metalwork', 'Portões, grades, estruturas metálicas', 'wrench', 120.00, 30),
('Pintura e Acabamentos', 'painting', 'Pintura residencial e comercial, texturas', 'paintbrush', 80.00, 15),
('Limpeza e Conservação', 'cleaning', 'Limpeza geral, higienização e conservação', 'broom', 70.00, 15),
('Jardinagem e Paisagismo', 'gardening', 'Manutenção de jardins, podas e paisagismo', 'scissors', 80.00, 20),
('Assistência Técnica Informática', 'it-support', 'Reparo de computadores, notebooks e suporte técnico', 'monitor', 90.00, 20)
ON CONFLICT (slug) DO NOTHING;

-- ======================
-- PLANOS PADRÃO
-- ======================
INSERT INTO plans (name, slug, description, target_role, price, features) VALUES
('Básico', 'provider_basic', 'Plano básico para prestadores de serviço', 'provider', 29.90, '{"max_quotes_per_month": 20, "radius": 20, "priority": 1}'),
('Profissional', 'provider_pro', 'Plano profissional com mais alcance', 'provider', 79.90, '{"max_quotes_per_month": 100, "radius": 50, "priority": 3}'),
('Empresa', 'provider_enterprise', 'Plano empresarial ilimitado', 'provider', 199.90, '{"max_quotes_per_month": 0, "radius": 100, "priority": 5}'),
('Cliente Premium', 'client_premium', 'Cliente premium sem taxas de serviço', 'client', 19.90, '{"no_service_fee": true, "priority_support": true}')
ON CONFLICT (slug) DO NOTHING;
