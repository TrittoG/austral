# AUSTRAL — contexto del proyecto

Metroidvania 2D en **Godot 4.7** (GL Compatibility), feel tipo Hollow Knight.
Historia y diseño completo en **docs/GUION.md** (leerlo antes de agregar contenido).
Roadmap por fases en `~/Downloads/roadmap_metroidvania.md` (regla: cada fase termina jugable).

**División de trabajo**: Giuli diseña (arte, mundos, personajes); Claude construye
sistemas y salas placeholder (rects grises, todo `@export` para tunear en vivo).
Idioma: español rioplatense (voseo) en comentarios, textos y diálogos.

## Estado actual (actualizar al avanzar)

- ✅ Planeta 1 (Páramo del Impacto): 12 salas, Guardián (dash), Espectro (wall jump),
  orbe doble salto, Chatarrero, cápsulas, amuletos, corazones, sombra al morir.
- ✅ Planeta 2 (El Velo): 7 salas, niebla con densidad, géiseres, Ermitaña,
  el Fanal (suelta el Disipador Iónico que anula la niebla).
- ✅ Planeta 3 (Raíz): 7 salas, mitad viva/mitad muda, espinas pulsantes,
  hopper/escarabajo blindado/escupidor, el Brote (mascota por sala), la
  Jardinera (no muere: se rinde, dialoga y da la "madera"; cura interrumpible
  vía _on_hit; root spikes bajo el player). El claro que canta (claro.wav).
- ✅ Sistemas: mapa doble (Tab), amuletos con muescas (6: +savia_espesa regen
  quieto), tienda por vendedor, antimateria + rocas + sombra, diálogos + Ecos,
  objetos clave, intro/fin de demo, menús 100% teclado/joystick (layout HK),
  juice, audio procedural. Jefes: _on_hit y _should_free_on_death virtuales.
- ✅ La Garganta (mundo final): 5 salas SIN música (music_track=""), gauntlet
  de dash/doble salto + chimenea de wall jump, enemigos eco, y EL SILENCIO:
  jefe de 3 fases (_check_phase propio por tercios; fase 2 roba el dash del
  player y lo devuelve en fase 3 o al morir vía refresh_abilities en el
  respawn; fase 3 apaga música + oscurece con el FogOverlay). Al caer corta
  a ending.tscn: final normal o VERDADERO según Game.has_key_item("madera")
  (galaxia encendiéndose planeta a planeta + créditos).
- ✅ Pipeline de arte: player con AnimatedSprite2D (6 frames pixel art en
  assets/sprites/player/, generados con Pillow). Guía en docs/ARTE.md:
  pisar PNG del mismo nombre/tamaño lo actualiza solo.
- ⬜ Pendiente: quest del núcleo del portal, susurros, sprites del resto de
  entidades, balance/playtest completo, export Windows + itch.io.

## Arquitectura

- **Autoloads**: `Juice` (hitstop/shake), `Game` (estado+save JSON en user://),
  `Audio` (SFX pool + música con dedup por ruta), `Atlas` (registro de planetas
  y rects de salas para el mapa).
- **main.tscn**: RoomManager (root) + Player persistente + HUD + Fade + FogOverlay
  + menús (Pause/Charm/Shop/Map/Dialogue como CanvasLayers; los últimos hijos
  interceptan input primero).
- **Salas**: una escena por sala en `scenes/rooms/<planeta>/`. Root con `room.gd`
  (límites de cámara, music_track, fog/fog_intensity). Puertas = Area2D con
  `room_transition.gd` (target_room + target_door; el destino necesita un nodo
  con hijo Marker2D "Entry"). Anclas de llegada sin puerta = Node2D + Entry.
  Viaje interplanetario = `portal.gd` (misma transición).
- **Jefes**: `boss_base.gd` (vida, fases, feedback, reward_ability/reward_key_item)
  + script concreto con la FSM. Arena = `boss_arena.gd` (extiende room.gd; nodos
  requeridos: Gate, FightTrigger, Boss, BossUI/HealthBar).
- **Enemigos**: `enemies/enemy_base.gd` + variantes. Patrón de colisión:
  cuerpo layer 4 / hurtbox Area2D layer 16 grupo `enemy_hurtbox` (recibe golpes,
  el dueño implementa `take_damage(amount, from_pos)`) / contacto layer 32 grupo
  `enemy_hitbox` (daña al player; lee `contact_damage` del dueño).
  Player: cuerpo layer 2, espada mask 16, hurtbox layer 64 mask 32.
- **Persistencia**: todo pasa por `Game` (abilities, checkpoint, bosses, secretos
  —que también marcan compras/rocas/corazones—, amuletos, antimateria, sombra,
  key_items, salas visitadas). Los pickups se auto-borran en `_ready` si su id
  ya está en el save.

## Trampas conocidas (¡leer antes de escribir GDScript/tscn!)

- **Nunca `:=` con Variant** (retornos de `find_child`, `get_first_node_in_group`,
  elementos de Dictionary, iterar arrays sin tipar): tipar explícito o la colección.
- No redeclarar métodos de la clase base con otra firma (ej: `get_gravity`).
- El editor reescribe los .tscn (uid, unique_id, sin load_steps): **Read antes de
  Edit**, nunca Write completo sobre un .tscn que Godot tocó. Omitir `load_steps`
  en tscn nuevos. En instancias, overrides de arrays como `PackedStringArray(...)`.
- Sin `\` de continuación de línea; usar paréntesis o variable intermedia.
- No hay Godot headless: Giuli prueba en el editor y reporta errores de a uno.
- Spawns/Entries: verificar que no caigan dentro de geometría (bug clásico).
- Menús que pausan: des-pausar con `set_deferred` para no re-disparar al NPC/banco
  con la misma tecla; los menús encadenados (diálogo→tienda) mantienen la pausa.
- Cornisas escalables: columnas SIN solaparse en X (canal ≥50px), pasos ≤70px
  (salto = 80). Gap imposible sin dash: >184px; con dash: <250px.

## Controles (layout Hollow Knight)

Flechas mover · Z saltar · X atacar · C dash · ↑ interactuar · Tab mapa · Esc pausa.
Joystick: stick/d-pad · A salto · X ataque · RT dash · LT mapa · Start pausa · B atrás.
Test aislado: `test_room.tscn` con F6 (ignora el save, todo desbloqueado).
