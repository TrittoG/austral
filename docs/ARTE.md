# AUSTRAL — Guía de arte (estilo HD, no pixel art)

## El estilo del juego

**Arte 2D suave de alta resolución** — como el concept del Caído
(`docs/concept/caido_concept.png`): formas redondas, línea de contorno
gruesa y oscura, colores planos con sombreado sutil, paleta acotada.
*(Hollow Knight tampoco es pixel art: es exactamente esta familia.)*

## El flujo (probado con el Caído)

1. **Generás el personaje GRANDE y lindo** con la IA de imágenes
   (fondo blanco liso, cuerpo entero, de costado o 3/4).
2. Lo guardás en **`docs/concept/`** con un nombre claro
   (ej: `chatarrero_concept.png`).
3. **Yo lo proceso**: fondo transparente, recorte, quitar sombra de
   piso, escalado suave al tamaño del juego, y lo conecto a la escena.
4. Para **animaciones**: generá variantes del MISMO personaje
   ("same character, running pose", "same character, jumping") —
   la IA de ChatGPT mantiene consistencia si editás sobre la imagen
   original. Cada pose es un frame que yo conecto.

Mientras un personaje tenga una sola pose, el movimiento lo venden el
squash & stretch, el espejado y las partículas (ya implementados).

## Reglas para generar concepts

- **Fondo blanco liso** (lo remuevo por código) y sin marca de agua.
- **Cuerpo entero**, sin recortes, con contorno cerrado (la línea
  oscura continua es lo que protege el recorte automático).
- Mirando **a la derecha** o de frente (el juego espeja solo).
- Mismo estilo siempre: línea gruesa, formas redondas, pocos colores.
  Truco: editá sobre el concept del Caído pidiendo "otro personaje en
  el mismo estilo" para mantener coherencia.

## Tamaños en juego (a esto escalo cada uno)

| Entidad | Altura en juego (px) |
|---|---|
| Player (el Caído) | 62 ✅ hecho |
| Enemigos chicos (walker, hopper, medusa...) | 40-50 |
| Chatarrero / Ermitaña | 85 |
| Brote | 34 |
| Jefes (Guardián, Espectro, Fanal, Jardinera) | 90-120 |
| El Silencio | 150 |
| Ítems (esquirla, corazón, amuleto, fragmento) | 20-34 |
| Nave | 90 (ancho ~160) |
| Cápsula de reposo / portal | 80-150 |

## Prioridad sugerida

1. ✅ El Caído
2. El Brote y el Chatarrero (los queribles)
3. Los 4 enemigos del Páramo
4. Los jefes, uno por planeta
5. Ítems y props (cápsula, nave, carteles)
6. Fondos/tiles por planeta (lo vemos juntos: eso pide otra técnica)

Paleta canónica del Caído: crema #F2EEE4 · sombra #D6D0C0 ·
oscuro #2E2C33 · ojos #F7F0D9 · antena #8A8A90.
