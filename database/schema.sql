-- Bondly Supabase SQL Schema MVP

-- 1. ENUMS
CREATE TYPE relationship_type AS ENUM ('casal', 'amizade', 'familia', 'colegas');
CREATE TYPE user_role AS ENUM ('normal', 'premium', 'admin');
CREATE TYPE challenge_status AS ENUM ('pending', 'completed');

-- 2. TABLES

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role user_role DEFAULT 'normal',
    language TEXT DEFAULT 'pt',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Relationships Table
CREATE TABLE relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    type relationship_type NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Relationship Spaces (Mapping Users to Relationships)
CREATE TABLE relationship_spaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    relationship_id UUID REFERENCES relationships(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(relationship_id, user_id)
);

-- Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES users(id),
    relationship_id UUID REFERENCES relationships(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    sentiment_score FLOAT, -- AI Generated
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Emotional Check-ins
CREATE TABLE emotional_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    relationship_id UUID REFERENCES relationships(id) ON DELETE CASCADE,
    mood INTEGER NOT NULL, -- Scale 1-5 or similar
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Daily Questions (pre-populated by admin or AI)
CREATE TABLE daily_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text TEXT NOT NULL,
    relationship_type relationship_type NOT NULL,
    language TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Daily Question Answers
CREATE TABLE daily_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES daily_questions(id),
    user_id UUID REFERENCES users(id),
    relationship_id UUID REFERENCES relationships(id),
    answer_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Challenges
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    points INTEGER DEFAULT 10,
    premium_only BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Challenge Participation
CREATE TABLE challenge_participation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
    status challenge_status DEFAULT 'pending',
    completed_at TIMESTAMP WITH TIME ZONE
);

-- AI Interactions Log
CREATE TABLE ai_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    type TEXT NOT NULL, -- 'coach_suggestion', 'sentiment_analysis', etc
    prompt TEXT NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Conversation Simulations
CREATE TABLE conversation_simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    simulated_message TEXT NOT NULL,
    feedback TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Achievements
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    type TEXT NOT NULL,
    points INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. INDEXES
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_relationships_created_by ON relationships(created_by);
CREATE INDEX idx_relationship_spaces_user_id ON relationship_spaces(user_id);
CREATE INDEX idx_messages_relationship_id ON messages(relationship_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_emotional_checkins_user_id ON emotional_checkins(user_id);
CREATE INDEX idx_emotional_checkins_relationship_id ON emotional_checkins(relationship_id);
CREATE INDEX idx_daily_answers_user_id ON daily_answers(user_id);
CREATE INDEX idx_challenge_participation_user_id ON challenge_participation(user_id);
