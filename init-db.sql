-- Initialisation de la base de données pour l'historique des transcriptions

CREATE TABLE IF NOT EXISTS transcriptions (
    id SERIAL PRIMARY KEY,
    youtube_url VARCHAR(500) NOT NULL,
    video_title VARCHAR(500),
    transcription_text TEXT,
    srt_content TEXT,
    language VARCHAR(10),
    duration_seconds INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);

CREATE INDEX idx_transcriptions_created_at ON transcriptions(created_at);
CREATE INDEX idx_transcriptions_status ON transcriptions(status);

-- Table pour les statistiques d'utilisation
CREATE TABLE IF NOT EXISTS usage_stats (
    id SERIAL PRIMARY KEY,
    date DATE UNIQUE NOT NULL,
    total_transcriptions INTEGER DEFAULT 0,
    total_duration_seconds BIGINT DEFAULT 0
);

