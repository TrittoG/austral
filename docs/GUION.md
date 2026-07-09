# AUSTRAL — Guion y biblia de diseño

> Metroidvania espacial. Tono: melancólico pero cálido, misterio ambiental estilo
> Hollow Knight — poco texto, mucho sugerido. Todo diálogo es corto y raro.
> Regla de oro narrativa: **nunca explicar de más**. El jugador arma la historia
> con pedazos.

---

## 1. LOGLINE

Un pequeño cartógrafo del borde sur de la galaxia cae en un mundo muerto mientras
huía de **el Silencio**, una entidad que apaga el Pulso de los mundos vivos, uno
por uno. Para volver a casa —el último mundo que todavía canta— tendrá que cruzar
los planetas que el Silencio ya devoró, aprender de sus ruinas… y apagarlo a él
primero.

---

## 2. EL UNIVERSO

### El Pulso
Todo mundo vivo **canta**: una vibración lenta que los viajeros llaman *el Pulso*.
Se siente, no se escucha. Los mundos con Pulso tienen agua, viento, criaturas…
y **madera** — la materia más rara del universo, porque solo nace donde hay vida.

### El Silencio
Nadie sabe si nació del vacío entre las estrellas o si alguien lo despertó.
Viaja de mundo en mundo y **se bebe el Pulso**. Lo que deja atrás no es
destrucción: es peor. Deja mundos *intactos y mudos* — piedra que ya no vibra,
ecos de criaturas que no terminaron de morir. Por eso la intro dice:
*"Algo cruzó la galaxia, dejando silencio a su paso."*

### La antimateria (◆)
En los mundos apagados, el Pulso robado se condensa en **esquirlas de
antimateria**: restos de canción cristalizada. Es la moneda universal de los
que quedaron: chatarreros, ermitaños, ecos. *(Ya implementado.)*

### Las sombras
Cuando algo muere en un mundo mudo, su eco queda un rato sosteniendo lo que
llevaba. Por eso, al morir, tu antimateria queda con **tu sombra** esperándote.
*(Ya implementado — ahora tiene explicación.)*

---

## 3. EL PROTAGONISTA

**Nombre en el juego: no tiene.** Los NPCs le dicen **"el Caído"** (o "la Caída"
— nunca se especifica género). Los jugadores lo van a llamar Austral.

- **Especie**: un **austral** — cartógrafos del borde sur de la galaxia, de
  **Alba Austral**, el último mundo con Pulso. Los australes mapean la galaxia
  desde hace generaciones; por eso el juego tiene *dos mapas* (galaxia y mundo).
  Ser cartógrafo ES la justificación del sistema de mapa.
- **Diseño sugerido** (para tus dibujos): pequeño (2 cabezas), casco redondo con
  **un solo visor** que brilla (el punto celeste del mapa es su visor), bufanda
  o antena quebrada de la nave, silueta simple y legible.
- **Arma**: **la Aguja** — la aguja de navegación de su nave rota, afilada.
  Un cartógrafo pelea con su instrumento. (El "nail" del juego.)
- **Personalidad**: muda. Se expresa con el cuerpo (squash & stretch 😉).

**Motivación**: no es venganza — es **volver**. Pero en el camino descubre que
el Silencio va rumbo al sur… hacia Alba Austral. Volver y detenerlo se vuelven
la misma cosa.

### Las habilidades (reliquias de su nave)
Las tres habilidades son **piezas de la nave estrellada**, dispersas o robadas:
- **Propulsor de Vacío** (dash) — lo tenía el Guardián *(ya implementado)*.
- **Botas Antigravedad** (doble salto) — quedaron en la Grieta *(ya)*.
- **Garfio Magnético** (wall jump) — lo tragó el Espectro *(ya)*.

---

## 4. LOS MUNDOS

> Estructura: 4 mundos. El Páramo (hecho), dos planetas nuevos, y la zona final.
> Cada planeta: 8-12 salas, 1 jefe mayor, 1 mecánica propia, 1 NPC, 2-3 secretos.
> ⚠️ Recortable: si el alcance aprieta, P2 y P3 pueden bajar a 6-7 salas.

### 🟤 PLANETA 1 — EL PÁRAMO DEL IMPACTO *(ya construido)*
El mundo donde caés. Fue el primer mundo que el Silencio devoró — el "paciente
cero". Roca seca, ruinas de una civilización minera, cuevas y un abismo.

- **Lore retrofit de lo ya hecho**:
  - **El Guardián** (jefe 1): un centinela de la civilización minera que sigue
    cumpliendo órdenes de un mundo que ya no existe. No es malo: está *roto*.
    Al caer suelta el Propulsor que arrancó de tu nave.
  - **El Espectro del Abismo** (jefe 2): el eco de la última criatura viva del
    Páramo, que bajó al Abismo huyendo del Silencio y murió a oscuras. Guarda
    el Garfio como un tesoro sin sentido.
  - **El Chatarrero**: ver personajes (§5).
- **Mecánica propia**: el Abismo vertical + la niebla de las Profundidades
  (teaser del Velo).
- **LA NAVE (sistema de viaje)**: tu nave se partió en **3 FRAGMENTOS**
  repartidos por el Páramo (cabina en la Grieta alta, motor en las
  Profundidades, ala junto al Espectro). Con los 3, la **plataforma de
  vuelo** la reconstruye y podés volar al Velo. La progresión entre
  mundos son MEJORAS de la nave: el **Blindaje Estelar** (corazón del
  Velo) cruza el cinturón de asteroides hacia Raíz; el **Núcleo de
  Pulso** (al pie del árbol madre) da energía para llegar a la
  Garganta. Volar entre mundos ya visitados = viaje rápido.

### 🔵 PLANETA 2 — EL VELO *(gaseoso — el planeta de la niebla)*
Un gigante gaseoso sin superficie: se juega sobre **plataformas flotantes,
esqueletos de ballenas-globo y estaciones colgantes** de una civilización
recolectora de gas. **Casi todo el planeta tiene niebla** *(mecánica fog ya
implementada)*: entrás casi ciego.

- **Gating principal**: el **DISIPADOR IÓNICO** está acá, custodiado por el
  jefe. Estructura del planeta: un anillo exterior jugable a ciegas (niebla
  suave), y el corazón del planeta imposible sin el Disipador → *conseguirlo
  acá y volver a usarlo acá* (backtracking interno) + abre las Profundidades
  del Páramo (backtracking entre planetas ✓).
- **Mecánica propia**: **corrientes ascendentes** (géiseres de gas que te
  elevan — nuevo hazard/mecánica a construir: área que empuja hacia arriba).
- **Enemigos nuevos sugeridos**: medusas eléctricas (flyer con aura de daño),
  globos explosivos (se inflan y estallan), anguilas que salen de la niebla.
- **JEFE — EL FANAL**: una criatura abisal enorme de la que solo ves **una luz
  hermosa flotando en la niebla**. La luz te guía… es un señuelo. La pelea:
  la arena está con niebla; el Fanal solo es visible cuando ataca. Al matarlo,
  su órgano de luz ES el Disipador Iónico. *(Diseño de pelea: la luz telegrafia
  todo — el jugador aprende a leer la luz, no al bicho.)*
- **NPC — LA ERMITAÑA**: una recolectora de gas anciana, última habitante,
  ciega (no necesita ojos en la niebla). Vende el amuleto **"Oído Fino"**
  (ver §7) y dice cosas que parecen locura pero son el lore más directo del
  juego. *"El Silencio no odia, nene. Tiene hambre. Como todos."*

### 🟢 PLANETA 3 — RAÍZ *(el mundo tipo tierra — el planeta de la MADERA)*
El único mundo del recorrido donde el Silencio **falló**. Llegó, empezó a
beber… y algo lo mordió de vuelta. Se fue herido. Raíz quedó **medio vivo**:
mitad selva exuberante, mitad zonas mudas grises donde nada crece. La frontera
entre las dos mitades se VE en el arte (verde → gris).

- **Gating principal**: acá está **LA MADERA** — no cualquier madera: **la
  Última Semilla**, el corazón del árbol madre de Raíz. La custodia la
  Jardinera (jefe). La Madera es la llave del **final verdadero** (§8).
- **Mecánica propia**: **espinas vivas** que crecen y se retraen con ritmo
  (hazard pulsante — variante de spikes con timer), y **charcas de ácido**
  (ya existe el hazard) como defensa natural del bosque.
- **Enemigos nuevos sugeridos**: brotes saltarines, escupidores de savia
  (shooter reskin), escarabajos blindados (solo vulnerables por atrás o pogo).
- **JEFE — LA JARDINERA**: la guardiana del árbol madre. **No es enemiga** —
  es la que mordió al Silencio. Pelea contra vos porque *cualquiera que busca
  la Semilla es una amenaza*, y tiene razón. Es la pelea triste del juego:
  patrones con lianas, raíces que emergen del suelo, y cura-áreas que TENÉS
  que interrumpir. Al vencerla no muere: se arrodilla y **te da la Semilla**
  — *"Entonces sos vos. Llevala donde duela más."*
- **NPC — EL BROTE**: una criaturita del bosque que te sigue en 2-3 salas
  (no pelea, solo acompaña — carisma barato y efectivo). Si encontrás su
  flor perdida (secreto), te espera en el mercado del Páramo al final.

### ⚫ MUNDO FINAL — LA GARGANTA *(la fuente del tormento)*
No es un planeta: es **el primer mundo que el Silencio devoró del todo**,
hace tanto que colapsó — un cascarón hueco y negro que el Silencio usa de
nido. Se llega por el portal, con las 3 habilidades y (opcional) la Semilla.

- **Estructura**: 5-6 salas lineales pero brutales — el "examen final" de
  plataformeo (dash + doble salto + wall jump encadenados) con los enemigos
  élite de los 3 planetas en versión "eco" (reskin oscuro, +vida).
- **Sin cápsulas de reposo salvo una**, justo antes del final.
- **Mecánica propia**: zonas de **silencio absoluto** — la música se apaga
  (¡ya podemos! `music_track = ""`), el HUD parpadea, y tus SFX suenan
  amortiguados. El silencio como presión psicológica.

---

## 5. PERSONAJES SECUNDARIOS

### EL CHATARRERO *(ya implementado — ahora con historia)*
Un carroñero de mundos muertos, especie desconocida (¿es un traje vacío?).
Sigue al Silencio **a distancia prudente** desde hace décadas: donde el
Silencio come, él recoge. No es valiente ni cobarde: es *práctico*.
- **Rol mecánico**: tienda (ya), y **encendedor del portal** (gancho de
  progresión: pedile que lo encienda y te manda a buscar el combustible —
  primera misión inter-planeta).
- **Arco**: si le comprás todo + le hablás en cada planeta (aparece en los
  tres mercados), en el final está **frente a tu nave reparándola gratis**.
  *"No me mires así. Un cliente muerto no compra."*
- **Líneas de muestra**:
  - "¿Caíste? Mala suerte. ¿Tenés antimateria? Buena suerte."
  - "El Guardián era buen cliente. Pagaba en tornillos."
  - "Yo no robo, Caído. Los muertos no son dueños de nada."

### LA ERMITAÑA (P2, El Velo)
Vieja, ciega, flota en una silla de gas. Habla del Silencio sin miedo, casi
con ternura. Vende un amuleto y lore. Si le llevás un **recuerdo del Fanal**
(drop del jefe), te cuenta la única descripción del Silencio del juego.

### EL BROTE (P3, Raíz)
Mascota temporal. No habla: hace ruiditos (SFX agudos del sintetizador 😄).
Su mini-quest (la flor) es el secreto "cálido" del juego.

### LOS ECOS (todos los planetas)
NPCs fantasma de una sola línea — criaturas que no terminaron de morir.
Aparecen en 1-2 salas por planeta, dicen su línea al pasar y se disuelven.
Son los **carteles con alma**: reemplazan/complementan los signs actuales.
- Eco del Páramo: *"…la nave… vi caer una nave… ¿era tuya? qué suerte… morir
  mirando algo nuevo…"*
- Eco del Velo: *"…la luz… no sigas la luz…"*
- Eco de Raíz: *"…verde… acá el gris no ganó… todavía…"*

---

## 6. PROGRESIÓN COMPLETA (ruta crítica)

```
PÁRAMO (P1) ────────────────────────────────────────────── [HECHO]
  caída → tutorial → Guardián → DASH → grieta → BOTAS (doble salto)
  → Abismo → Espectro → GARFIO (wall jump) → portal (apagado)
       ↓
  Chatarrero: "el portal come antimateria condensada: traeme 1 NÚCLEO"
  → el NÚCLEO está en las Profundidades… tras la niebla → no podés → P2
       ↓  (portal a medias: solo llega al Velo, el mundo más cercano)
VELO (P2)
  anillo exterior (niebla suave) → Ermitaña → corazón del planeta (niebla
  total, imposible) → EL FANAL → DISIPADOR IÓNICO → corazón del Velo
  (ahora visible): NÚCLEO DEL PORTAL + salida
       ↓  (volvés al Páramo: Profundidades ahora visibles → secreto + lore
           del Silencio; portal encendido del todo)
RAÍZ (P3)
  mitad viva → frontera → mitad muda → LA JARDINERA → LA SEMILLA (madera)
       ↓
LA GARGANTA (final)
  gauntlet de 3 habilidades → cápsula final → EL SILENCIO
```

**Los "ahá" de backtracking** (mínimo 4):
1. La niebla de las Profundidades (P1) se cruza recién con el Disipador (P2).
2. El corazón del Velo se juega dos veces: ciego y viendo.
3. La pared de espinas vivas del tutorial (agregar una en p1_crash) se pasa
   recién con dash → esconde un secreto para el que vuelve.
4. Con wall jump, el Abismo y la Grieta se recorren distinto (atajos).

---

## 7. AMULETOS (los 4 actuales + 4 nuevos)

| Amuleto | Efecto | Muescas | Dónde |
|---|---|---|---|
| Filo Largo *(ya)* | Alcance +40% | 1 | P1 crash |
| Garra Veloz *(ya)* | Dash recarga ×2 | 1 | P1 grieta |
| Corazón Férreo *(ya)* | +2 vida máx | 2 | P1 jefe |
| Imán Estelar *(ya)* | Atrae ◆ ×3 | 1 | Tienda |
| **Oído Fino** | La niebla se aclara un 30% extra y los enemigos ocultos brillan | 1 | Ermitaña (P2) |
| **Púa Voltaica** | El pogo hace +1 daño y rebota más alto | 1 | Secreto P2 |
| **Savia Espesa** | Regenerás 1 HP al descansar 4 seg quieto (lento) | 2 | Secreto P3 |
| **Eco Fiel** | Tu sombra no se pierde nunca (la pila vieja no se borra) | 2 | La Garganta (secreto) |

Muescas: arrancás con 3 → +1 tienda P1 → +1 tienda P2 → +1 secreto P3 = **6**.

---

## 8. EL JEFE FINAL — **EL SILENCIO**

**Presencia**: no tiene cuerpo fijo. Es un **agujero con forma** — una silueta
negra que absorbe la paleta de la sala (el arte alrededor pierde color cerca
de él). Tamaño: 3-4 veces el player.

**LA PELEA (3 fases):**
- **Fase 1 — El Hambre**: patrones físicos: se desarma en enjambre y te
  embiste desde los bordes (telegrafiado por *dónde se apaga la música*,
  panning del audio). Vulnerable al re-formarse.
- **Fase 2 — El Robo**: te **come las habilidades una por una** (primero el
  dash, después el doble salto…) y las usa contra vos — dashea, salta doble.
  Recuperás cada una pegándole al "órgano" donde la guarda. Es la fase
  espejo: peleás contra tu propio moveset.
- **Fase 3 — El Silencio de verdad**: música muerta, HUD apagado, sala a
  oscuras salvo tu visor. Él ya casi no tiene vida — pero vos tampoco ves.
  Patrones lentos, telegrafía solo con **sonido amortiguado**. Terminarlo se
  siente como apagar una vela.

**FINAL NORMAL** *(sin la Semilla)*: lo matás. La Garganta colapsa. Escapás al
portal. Pantalla final: tu nave reparada (Chatarrero) despegando del Páramo,
rumbo al sur. Texto: *"La galaxia no volvió a cantar. Pero tampoco volvió a
callarse."* → créditos.

**FINAL VERDADERO** *(con la Semilla)*: al matarlo, en vez de escapar, podés
**plantar la Madera en su cráter**. La Semilla bebe lo que el Silencio tenía
adentro: todo el Pulso robado de mil mundos. Cutscene simple: el negro se
vuelve verde. Texto: *"Donde más dolía, algo empezó a cantar."* La pantalla
final muestra la GALAXIA del mapa… con los planetas grises encendiéndose de
a poco. → créditos + gracias.

*(El final verdadero reusa el mapa de galaxia ya implementado — barato y
emotivo.)*

---

## 9. ZONAS OCULTAS Y SECRETOS (lista completa)

**P1 Páramo** *(3 ya existen)*: corazón barranca ✓, corazón profundidades ✓,
corazón abismo ✓ + **nuevo**: pared falsa en la sala del crash (detrás de la
nave) con un Eco que cuenta la caída + 1 roca gorda de ◆.

**P2 Velo**: ① plataforma invisible en la niebla que un Eco te señala
(*"…tres pasos a la izquierda del faro…"*) → amuleto Púa Voltaica.
② géiser secreto que te dispara ARRIBA de la sala → mini-zona "El Techo del
Mundo": vista sin niebla (momento contemplativo) + corazón.

**P3 Raíz**: ① la flor del Brote (quest). ② tras una cascada de ácido:
amuleto Savia Espesa. ③ un claro donde TODAVÍA canta el Pulso — no hay
nada que agarrar: solo música distinta y luz. El secreto es el lugar.
*(El mejor cofre a veces está vacío.)*

**Garganta**: ① Eco Fiel tras un desvío de wall jump brutal. ② los restos
de la PRIMERA víctima del Silencio, con el lore final opcional.

**Meta-secreto — LOS SUSURROS**: 8 piedras que susurran (1 por zona grande).
Coleccionable puro. Juntar los 8 desbloquea en el menú un texto: la historia
del Silencio contada por él mismo. *(Sistema: reuso de secrets_found ✓.)*

---

## 10. TEXTOS CLAVE (listos para implementar)

**Intro** *(ya en el juego)* ✓

**Cartel título de cada mundo** (al entrar, estilo HK):
- "EL PÁRAMO DEL IMPACTO — donde el Silencio aprendió a tragar"
- "EL VELO — el mundo que respira"
- "RAÍZ — donde el gris no ganó"
- "LA GARGANTA — acá empezó"

**Chatarrero, primer encuentro**: "Un caído vivo. Eso es nuevo. Los vivos
pagan mejor — ¿ves algo que te guste?"

**Ermitaña, con el recuerdo del Fanal**: "¿Sabés qué es? Un pedazo de canción
con hambre. Igual que vos. Igual que yo. La diferencia es cuánta hambre."

**Jardinera, al entregarte la Semilla**: "Entonces sos vos. Llevala donde
duela más."

**Antes de la pelea final** (cartel roto): "no pelees con él / apagalo"

---

## 11. SCOPE Y ORDEN DE CONSTRUCCIÓN SUGERIDO

| Bloque | Salas | Sistemas nuevos | Estado |
|---|---|---|---|
| P1 Páramo | 12 | — | ✅ hecho |
| Diálogo NPC (sistema) | — | cajas de diálogo por líneas | próximo |
| P2 Velo | 8-10 | géiseres, jefe Fanal, niebla parcial | a construir |
| Vuelta a P1 | +1 | núcleo del portal, pared falsa | a construir |
| P3 Raíz | 8-10 | espinas pulsantes, Jardinera, Brote | a construir |
| Garganta + Silencio | 5-6 | jefe final 3 fases, zonas mudas | a construir |
| Finales + créditos | 2 | cutscene simple, galaxia que enciende | a construir |

**Total estimado: ~35 salas, 5 jefes.** Es más grande que el roadmap original
(15-25) — si hay que recortar: el Velo baja a 6 salas, Raíz a 7, y los
secretos ②/③ se caen. **El corte mínimo digno**: P1 + P2 + Garganta corta
(la Semilla y el final verdadero se convierten en DLC de uno mismo 😄).

---

*Documento vivo. Cambialo sin culpa: el guion sirve al juego, no al revés.*
