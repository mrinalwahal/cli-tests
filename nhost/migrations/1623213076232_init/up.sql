CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE OR REPLACE FUNCTION create_constraint_if_not_exists (t_name text, c_name text, constraint_sql text)
	  RETURNS void
	AS
	$BODY$
	  BEGIN
		-- Look for our constraint
		IF NOT EXISTS (SELECT constraint_name
					   FROM information_schema.constraint_column_usage
					   WHERE constraint_name = c_name) THEN
			EXECUTE 'ALTER TABLE ' || t_name || ' ADD CONSTRAINT ' || c_name || ' ' || constraint_sql;
		END IF;
	  END;
	$BODY$
	LANGUAGE plpgsql VOLATILE;
	
	CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  _new record;
begin
  _new := new;
  _new. "updated_at" = now();
  return _new;
end;
$$;
CREATE TABLE IF NOT EXISTS public.test (
    id text NOT NULL,
    value text NOT NULL
);
CREATE TABLE IF NOT EXISTS public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    display_name text,
    avatar_url text
);
ALTER TABLE ONLY public.test
    ADD CONSTRAINT test_pkey PRIMARY KEY (id);

SELECT create_constraint_if_not_exists('public.users', 'users_pkey', 'PRIMARY KEY (id);');

DROP TRIGGER IF EXISTS set_public_users_updated_at ON public.users;
	CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
	

INSERT INTO auth.roles (role)
    VALUES ('user'), ('me'), ('anonymous') ON CONFLICT DO NOTHING;


INSERT INTO auth.providers (provider)
    VALUES ('github'), ('facebook'), ('twitter'), ('google'), ('apple'), ('linkedin'), ('windowslive'), ('spotify') ON CONFLICT DO NOTHING;

