-- ============================================
-- SPIRIT - PostgreSQL Initialization
-- ============================================

-- Create databases
CREATE DATABASE IF NOT EXISTS spirit;
CREATE DATABASE IF NOT EXISTS webui;
CREATE DATABASE IF NOT EXISTS langflow;

-- Connect to spirit database
\c spirit;

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id VARCHAR(255) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Decisions table
CREATE TABLE IF NOT EXISTS decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id),
    query TEXT NOT NULL,
    recommendation TEXT,
    confidence DECIMAL(5,2),
    data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agents table
CREATE TABLE IF NOT EXISTS agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    config JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Simulations table
CREATE TABLE IF NOT EXISTS simulations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_id UUID REFERENCES decisions(id),
    scenario TEXT NOT NULL,
    num_agents INTEGER DEFAULT 100,
    results JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_sessions_client ON sessions(client_id);
CREATE INDEX idx_decisions_session ON decisions(session_id);
CREATE INDEX idx_simulations_decision ON simulations(decision_id);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO spirit;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO spirit;

-- Insert default orchestrator agent
INSERT INTO agents (name, type, config) VALUES
('orchestrator', 'orchestrator', '{"model": "claude-sonnet-4", "max_workers": 10}');

COMMENT ON TABLE sessions IS 'User sessions and conversations';
COMMENT ON TABLE decisions IS 'Decision requests and recommendations';
COMMENT ON TABLE agents IS 'Agent registry and configuration';
COMMENT ON TABLE simulations IS 'Scenario simulations and predictions';
