DROP TABLE IF EXISTS access_tokens;
DROP TABLE IF EXISTS schema_migrations;
DROP TABLE IF EXISTS users;

CREATE TABLE access_tokens (
    id SERIAL NOT NULL PRIMARY KEY,
    user_id integer,
    token text,
    session_key text,
    last_valid timestamp without time zone
);

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);

CREATE TABLE users (
    id SERIAL NOT NULL PRIMARY KEY,
    email text,
    name text,
    login text,
    source_id text
);
