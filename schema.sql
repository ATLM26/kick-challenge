-- =====================================================================
-- KICK CHALLENGE  ·  Esquema para Supabase
-- Pegar completo en: Supabase > SQL Editor > New query > Run
-- Usa el mismo proyecto que la app de patadas. Todas las tablas llevan
-- prefijo kc_ para no mezclarse con partidos / patadas.
-- Cada usuario = una competencia. RLS asegura que cada uno vea solo lo suyo.
-- =====================================================================

-- Perfil de la competencia (1 fila por usuario)
create table if not exists kc_perfil (
  user_id     uuid primary key default auth.uid() references auth.users on delete cascade,
  nombre      text not null default 'Mi competencia',
  created_at  timestamptz not null default now()
);

-- Jugadores de la competencia (se reutilizan entre ediciones)
create table if not exists kc_jugadores (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  nombre      text not null,
  activo      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Ediciones del torneo
create table if not exists kc_ediciones (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  nombre      text not null,
  fecha       date not null default current_date,
  finalizada  boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Parejas de cada edición
create table if not exists kc_parejas (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  edicion_id  uuid not null references kc_ediciones on delete cascade,
  numero      int  not null,
  jugador1_id uuid not null references kc_jugadores on delete restrict,
  jugador2_id uuid not null references kc_jugadores on delete restrict,
  created_at  timestamptz not null default now()
);

-- Patadas: una por jugador por estación
-- resultado: 'entro' (convirtió / le pegó al palo en la 7)
--            'izq' | 'der' | 'corta'  (erró, con dirección)
--            'erro'                     (erró sin dato, para ediciones viejas)
create table if not exists kc_patadas (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  edicion_id  uuid not null references kc_ediciones on delete cascade,
  pareja_id   uuid not null references kc_parejas on delete cascade,
  jugador_id  uuid not null references kc_jugadores on delete restrict,
  estacion    int  not null check (estacion between 1 and 8),
  resultado   text not null check (resultado in ('entro','izq','der','corta','erro')),
  updated_at  timestamptz not null default now(),
  unique (edicion_id, jugador_id, estacion)
);

-- Muerte súbita
-- tipo 'pareja': participante_id = id de la pareja
-- tipo 'individual': participante_id = id del jugador
create table if not exists kc_desempates (
  id              uuid primary key,
  user_id         uuid not null default auth.uid() references auth.users on delete cascade,
  edicion_id      uuid not null references kc_ediciones on delete cascade,
  tipo            text not null check (tipo in ('pareja','individual')),
  ronda           int  not null,
  participante_id uuid not null,
  acierto         boolean not null,
  created_at      timestamptz not null default now(),
  unique (edicion_id, tipo, ronda, participante_id)
);

create index if not exists kc_patadas_edicion_idx on kc_patadas (edicion_id);
create index if not exists kc_parejas_edicion_idx on kc_parejas (edicion_id);
create index if not exists kc_desempates_edicion_idx on kc_desempates (edicion_id);

-- ---------------------------------------------------------------------
-- Row Level Security: cada usuario solo ve y modifica sus propias filas
-- ---------------------------------------------------------------------
alter table kc_perfil     enable row level security;
alter table kc_jugadores  enable row level security;
alter table kc_ediciones  enable row level security;
alter table kc_parejas    enable row level security;
alter table kc_patadas    enable row level security;
alter table kc_desempates enable row level security;

drop policy if exists "kc_perfil_propio"     on kc_perfil;
drop policy if exists "kc_jugadores_propio"  on kc_jugadores;
drop policy if exists "kc_ediciones_propio"  on kc_ediciones;
drop policy if exists "kc_parejas_propio"    on kc_parejas;
drop policy if exists "kc_patadas_propio"    on kc_patadas;
drop policy if exists "kc_desempates_propio" on kc_desempates;

create policy "kc_perfil_propio"     on kc_perfil     for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "kc_jugadores_propio"  on kc_jugadores  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "kc_ediciones_propio"  on kc_ediciones  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "kc_parejas_propio"    on kc_parejas    for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "kc_patadas_propio"    on kc_patadas    for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "kc_desempates_propio" on kc_desempates for all using (user_id = auth.uid()) with check (user_id = auth.uid());
