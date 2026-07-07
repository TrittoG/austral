# AUSTRAL — Guía de arte (cómo hacer y meter los gráficos)

## Cómo funciona el pipeline (ya armado con el player)

1. Dibujás (o generás) un **PNG con fondo transparente** del tamaño indicado abajo.
2. Lo guardás en `assets/sprites/<entidad>/` con el nombre del frame
   (ej: `idle_0.png`). **Si pisás un archivo existente con otro del mismo
   nombre y tamaño, el juego lo toma solo** — sin tocar código ni escenas.
3. Para entidades nuevas o más frames: se agrega en la escena (pedímelo,
   es un momento).

El player ya funciona así: mirá `assets/sprites/player/` (6 frames) y
cómo `player.tscn` los usa en un AnimatedSprite2D con animaciones
idle / run / jump / fall. Ese es el molde para todo lo demás.

## Reglas de oro

- **Fondo transparente** (PNG con alpha), nunca fondo blanco.
- **Tamaño exacto** de la tabla de abajo (el doble de la hitbox aprox.);
  el personaje centrado, los pies apoyados en el borde inferior.
- Dibujá **mirando a la derecha**: el juego espeja solo al ir a la izquierda.
- Pixel art: trabajá a la mitad del tamaño y escalá ×2 SIN suavizado
  (nearest neighbor). Godot ya está en GL Compatibility, se ve nítido.
- Silueta primero: si la sombra negra del bicho no se reconoce, el
  detalle no lo va a salvar.

## Tamaños por entidad (canvas del PNG en px)

| Entidad | Canvas | Frames mínimos |
|---|---|---|
| Player (el Caído) | 40×48 ✅ hecho | idle×2, run×2, jump, fall (+attack×2 a futuro) |
| Walker / Beetle | 40×36 | walk×2 |
| Hopper | 32×32 | idle, salto |
| Flyer / Medusa | 40×40 | flotar×2 |
| Shooter / Escupidor | 36×40 | idle, disparo |
| Charger | 40×40 | walk×2, embestida |
| Guardián (jefe 1) | 64×84 | idle×2, telegraph, embestida |
| Espectro (jefe 2) | 60×60 | flotar×2, picada |
| Fanal (jefe 3) | 76×58 | acecho, atacando (la linterna manda) |
| Jardinera (jefe 4) | 56×92 | idle×2, telegraph, cura, arrodillada |
| Chatarrero / Ermitaña / Brote | 56×80 / 56×80 / 24×32 | idle×2 |
| Cápsula de reposo | 100×84 | idle, activa (campo dorado) |
| Portal | 80×152 | idle×2 (ondulando) |
| Esquirla ◆ / corazón / amuleto / orbe | 16×16 / 32×32 / 32×32 / 32×32 | 1 (girando×4 si pinta) |
| Espinas / espinas vivas | 120×24 | 1 / extendida+retraída |
| Tiles de piso/pared (a futuro) | 32×32 | por planeta |

## Con qué hacer el arte (de más fácil a más pro)

1. **IA de imágenes** (lo que empezaste): usá el prompt del Caído que ya
   tenemos. Generá el personaje grande y lindo → después alguien (o yo
   con Pillow) lo reduce al tamaño de juego. Ideal para concept art y
   para NPCs/jefes que necesitan personalidad.
2. **Piskel** (piskelapp.com, gratis, en el navegador): editor de pixel
   art pensado para juegos. Exporta PNG por frame. La opción más directa
   para hacer los frames chicos vos misma — con 20×24 píxeles alcanza.
3. **Libresprite / Aseprite** (gratis / ~USD 20): el estándar indie para
   pixel art animado. Vale la pena si le agarrás el gusto.
4. **Packs gratis de itch.io** (itch.io/game-assets/free/tag-metroidvania):
   arte listo con licencia libre para prototipar zonas enteras. Mezclable
   con lo tuyo mientras encontrás tu estilo.

## Flujo recomendado

1. Jugá con el player nuevo y decidí si el estilo pixel ×2 te gusta.
2. Elegí UNA entidad chica (el Brote es ideal: 2 frames) y hacela en
   Piskel imitando los tamaños/paleta. Me la pasás y la conecto.
3. Cuando tengas 2-3 bichos, definimos la paleta por planeta y voy
   convirtiendo el resto de las escenas al sistema de sprites.

Paleta actual del Caído: casco #E8E4D8 · visor #7FD8FF · traje #2A3550
· bufanda #4A8B8C · acentos #FFD966.
