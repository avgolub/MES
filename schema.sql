-- Database schema for users, roles, authentication (bcrypt), and 2FA.
-- Target: PostgreSQL

CREATE TABLE roles (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL
);

INSERT INTO roles (name, description) VALUES
  ('operator', 'Оператор'),
  ('shift_supervisor', 'Мастер смены'),
  ('admin', 'Администратор'),
  ('qc_specialist', 'Специалист контроля качества'),
  ('engineer', 'Инженер');

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  login TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  password_algo TEXT NOT NULL DEFAULT 'bcrypt',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

CREATE TABLE user_roles (
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE user_two_factor (
  user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  is_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  method TEXT NOT NULL DEFAULT 'totp',
  secret TEXT NOT NULL,
  digits SMALLINT NOT NULL DEFAULT 6,
  period_seconds SMALLINT NOT NULL DEFAULT 30,
  enabled_at TIMESTAMPTZ,
  last_used_at TIMESTAMPTZ
);

CREATE TABLE user_recovery_codes (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code_hash TEXT NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_recovery_codes_user_id ON user_recovery_codes(user_id);

COMMENT ON COLUMN users.password_hash IS 'bcrypt hash of the password';
COMMENT ON COLUMN user_recovery_codes.code_hash IS 'bcrypt hash of recovery code';
