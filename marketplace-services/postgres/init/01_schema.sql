-- ==================================================
-- MARKETPLACE DE SERVIÇOS - DATABASE SCHEMA v1.0
-- ==================================================

-- ======================
-- USUÁRIOS E AUTENTICAÇÃO
-- ======================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    document VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'client', 'provider')),
    location GEOGRAPHY(Point, 4326),
    address TEXT,
    city VARCHAR(100),
    state CHAR(2),
    postal_code VARCHAR(10),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_users_role ON users(role);

-- ======================
-- ASSINATURAS E PLANOS
-- ======================
CREATE TABLE plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    target_role VARCHAR(20) CHECK (target_role IN ('client', 'provider')),
    price DECIMAL(10,2) NOT NULL,
    duration_days INTEGER DEFAULT 30,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id INTEGER NOT NULL REFERENCES plans(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'canceled', 'expired', 'pending')),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    payment_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================
-- CATEGORIAS DE SERVIÇO
-- ======================
CREATE TABLE service_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    base_fee DECIMAL(10,2) DEFAULT 100.00,
    radius_km INTEGER DEFAULT 20,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ======================
-- SOLICITAÇÕES DE SERVIÇO
-- ======================
CREATE TABLE service_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id),
    category_id INTEGER NOT NULL REFERENCES service_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location GEOGRAPHY(Point, 4326) NOT NULL,
    address TEXT NOT NULL,
    urgency VARCHAR(20) DEFAULT 'normal' CHECK (urgency IN ('low', 'normal', 'high', 'emergency')),
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    fee_amount DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    fee_paid BOOLEAN DEFAULT false,
    fee_payment_id VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'pending_fee' CHECK (status IN (
        'pending_fee', 'open', 'matched', 'quoting', 'accepted', 
        'in_progress', 'completed', 'canceled', 'disputed'
    )),
    otp_token VARCHAR(6),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_service_requests_location ON service_requests USING GIST(location);
CREATE INDEX idx_service_requests_status ON service_requests(status);
CREATE INDEX idx_service_requests_client_id ON service_requests(client_id);

-- ======================
-- ORÇAMENTOS E MATCHES
-- ======================
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES users(id),
    value DECIMAL(10,2) NOT NULL,
    travel_fee DECIMAL(10,2) DEFAULT 0.00,
    estimated_time_hours DECIMAL(4,2),
    description TEXT,
    distance_km DECIMAL(6,2),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'canceled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(request_id, provider_id)
);

-- ======================
-- LOGS DE AUDITORIA
-- ======================
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
