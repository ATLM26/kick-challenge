# Kick Challenge: puesta en marcha

## 1. Base de datos (una sola vez)
1. Entrá a Supabase, al mismo proyecto de la app de patadas.
2. SQL Editor > New query > pegá todo `schema.sql` > Run.
   Crea las tablas `kc_*` con seguridad por usuario. No toca `partidos` ni `patadas`.

## 2. Configuración
Abrí `config.js` y reemplazá `PEGAR_ACA_LA_ANON_KEY` por la anon key
(es la misma que tenés en el `config.js` de `/palos/`).

## 3. Subir a GitHub Pages
1. Creá un repo nuevo, por ejemplo `kick-challenge`.
2. Subí todos los archivos de esta carpeta (menos este LEEME, si querés).
3. Settings > Pages > Deploy from branch > `main` / root.
4. Queda en `https://atlm26.github.io/kick-challenge/`.

## 4. Link de confirmación de email
En Supabase > Authentication > URL Configuration > Redirect URLs, agregá:
`https://atlm26.github.io/kick-challenge/`
(Sin esto, el mail de confirmación manda a una página que no existe, como pasó con /palos/.)

## 5. En la tablet
Abrí el link con internet, creá la cuenta de la competencia y agregala
a la pantalla de inicio (Compartir > Agregar a inicio en iPad, menú > Instalar app en Android).
Desde ahí funciona aunque no haya señal en la cancha: lo que se carga
queda en la tablet y se sube solo cuando vuelve la conexión.

## Tené en cuenta
- Las cuentas de login son las mismas del proyecto de Supabase: si entrás con tu
  usuario de /palos/, vas a ver una competencia vacía propia. Para CUBA conviene
  crear una cuenta con otro email.
- Supabase gratis pausa el proyecto después de 7 días sin uso. Si la app no carga
  datos, entrá al panel de Supabase y tocá "Restore project".
