# AUSTRAL

> Metroidvania espacial 2D. **Made in Argentina, papá.** 🇦🇷

Algo cruzó la galaxia, dejando silencio a su paso. Tu nave fue una víctima
más: caíste en un mundo desconocido, lejos de casa. Encontrá la fuente del
tormento. Eliminala. **Y volvé.**

Sos **el Caído**: un pequeño cartógrafo del borde sur de la galaxia, armado
solo con la aguja de navegación de su nave rota. Reconstruila fragmento a
fragmento, viajá entre planetas, y enfrentate a **el Silencio** — la entidad
que se bebe el Pulso de los mundos vivos.

*Inspirado en Hollow Knight. Hecho en Godot 4.7.*

## Estado

🚧 **En desarrollo** — demo jugable de principio a fin (arte placeholder).

- 🟤 **Páramo del Impacto** — el mundo del crash: 12 salas, 2 jefes,
  los 3 fragmentos de tu nave
- 🔵 **El Velo** — gigante gaseoso: niebla, géiseres, la Ermitaña y el Fanal
- 🟢 **Raíz** — el mundo donde el Silencio falló: mitad selva, mitad gris,
  la Jardinera y la Semilla
- ⚫ **La Garganta** — el nido: silencio absoluto, ecos, y el jefe final
  de 3 fases (una te roba las habilidades y las usa contra vos)
- **Dos finales** según lo que lleves al último cráter

## Features

- Movimiento con game feel: coyote time, jump buffer, dash, doble salto,
  wall jump — todo tuneable
- Combate melee con pogo, hitstop, knockback y screen shake
- **La nave como progresión**: fragmentos para reconstruirla, mejoras
  (Blindaje Estelar, Núcleo de Pulso) que desbloquean planetas, y viaje
  rápido entre mundos visitados
- Amuletos equipables con muescas (estilo HK), cápsulas de reposo,
  tienda del Chatarrero (antimateria: al morir la soltás y tu sombra
  la guarda)
- Mapa doble: la galaxia y el planeta actual (se revela al explorar)
- Diálogos, Ecos (fantasmas de una línea) y NPCs
- 100% jugable con teclado o joystick, sin mouse

## Controles

| Acción | Teclado | Joystick |
|---|---|---|
| Mover | ← / → | Stick / D-pad |
| Saltar | Z | A |
| Atacar | X | X |
| Dash | C | RT |
| Apuntar ↑/↓ (pogo) | ↑ / ↓ | Stick |
| Interactuar | ↑ | ↑ |
| Mapa | Tab | LT |
| Pausa | Esc | Start |

## Cómo jugarlo

1. Instalá [Godot 4.7](https://godotengine.org/) (o superior 4.x).
2. Cloná este repo y abrí la carpeta como proyecto en Godot.
3. **F5** y a jugar. (Godot importa los assets automáticamente la
   primera vez.)

## Documentación

- [`docs/GUION.md`](docs/GUION.md) — la historia completa: el Pulso, el
  Silencio, los mundos, los personajes y los finales
- [`docs/ARTE.md`](docs/ARTE.md) — guía del pipeline de arte (cómo
  reemplazar los placeholders)
- [`CLAUDE.md`](CLAUDE.md) — arquitectura y estado del proyecto

## Créditos

- **Giuli** ([@TrittoG](https://github.com/TrittoG)) — diseño, dirección,
  mundos y personajes
- **Claude** (Anthropic) — sistemas, código y salas placeholder

---

*El mejor cofre a veces está vacío.* 🌱
