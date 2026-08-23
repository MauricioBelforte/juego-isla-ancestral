**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 162: Diálogos Contextuales de NPCs

## 1. Estructura de Progresión de Diálogos

### 1.1 Formato por NPC

Cada NPC tiene diálogos organizados así:

```
NPC
├── Capítulo 0 (Prólogo)
│   ├── SALUDO: [...]
│   ├── HISTORIA: [...]
│   ├── MISION: [...]
│   └── AMBIENTE: [...]
├── Capítulo 1 (Cenizas)
│   ├── SALUDO: [...]
│   ├── HISTORIA: [...]
│   └── AMBIENTE: [...]
├── ... (capítulos 2-6)
├── Capítulo 7 (Final)
│   ├── SALUDO: [...]
│   ├── HISTORIA: [...]
│   └── AMBIENTE: [...]
└── Diálogos Especiales
    ├── AMISTAD (niveles 1-3)
    ├── ESTACIONAL (4 estaciones)
    └── HORA (3 franjas)
```

### 1.2 Condiciones de Activación

| Condición | Variable M21 | Valores |
|-----------|--------------|---------|
| Capítulo actual | `game_progress.chapter` | 0-7 |
| Amistad NPC | `friendship[npc_id]` | 0-100 |
| Estación | `world.season` | PRIMAVERA, VERANO, OTONIO, INVIERNO |
| Hora del día | `world.hour` | 6-12 (mañana), 12-20 (tarde), 20-6 (noche) |
| Ubicación | `player.location` | LOC-xxx |

---

## 2. ISLA RAÍZ (RIZ) — Diálogos

### 2.1 Mayor del Pueblo (NPC-RIZ-001)

**Rol:** Líder del pueblo, guía al jugador en la historia

#### Capítulo 0 — Prólogo (La Llegada)

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Bienvenido a Aurora! Soy el mayor de este pueblo. Si necesitas algo, no dudes en preguntar." | Primera vez |
| SALUDO | "¡Hola, {nombre}! ¿Ya exploraste el pueblo?" | Repeated |
| HISTORIA | "Esta isla lleva siglos en paz. Las ruinas del norte cuentan historias de una civilización antigua..." | — |
| MISION | "Deberías conocer a los vecinos. El carpintero puede ayudarte con herramientas básicas." | — |
| AMBIENTE | "Las mañanas en Aurora son mágicas. ¿Ves cómo la luz se filtra entre los árboles?" | — |

#### Capítulo 1 — Las Cenizas Futuras

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! Noto que algo te preocupa. ¿Has visto las cenizas del norte?" | — |
| HISTORIA | "Esas cenizas no parecen volcánicas. El viejo sabio dice que vienen de algo más antiguo..." | Después de ver cenizas |
| MISION | "¿Podrías investigar las cenizas? Habla con el viejo sabio, él sabe de estas cosas." | — |
| AMBIENTE | "El aire se ha vuelto extraño últimamente. Como si la isla recordara algo..." | — |

#### Capítulo 2 — El Puente de las Memorias

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Buen trabajo con el puente! Ahora podemos llegar al bosque profundo." | Puente completado |
| HISTORIA | "Ese puente fue construido por la civilización antigua. Están restaurando lo que se destruyó..." | — |
| MISION | "El jardín del sur se está inundando. Algo está bloqueando el agua..." | — |

#### Capítulo 3 — El Jardín Ahogado

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Cuidado con la sombra del templo. No es peligrosa, pero asusta a los niños." | — |
| HISTORIA | "La sombra no es de un monstruo. Es el propio templo proyectándose. La luz crea ilusiones..." | — |
| AMBIENTE | "El nivel del agua sigue subiendo. El jardín necesita ayuda..." | — |

#### Capítulo 4 — El Valle de los Vientos

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡El valle de los vientos está abierto! Dicen que los sellos están ahí..." | — |
| HISTORIA | "Los sellos protegían la isla. Si los restauramos, Aurora florecerá de nuevo." | — |
| MISION | "Necesitamos encontrar los 7 sellos. Cada uno es una pieza del rompecabezas." | — |

#### Capítulo 5 — La Noche Eterna

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡No te preocupes! La noche eterna pasará. El pueblo está unido." | — |
| HISTORIA | "El eclipse es temporal. Los antiguos lo predecían. Hay que tener fe." | — |
| AMBIENTE | "Las velas del pueblo brillan con fuerza. Es hermoso a su manera..." | — |

#### Capítulo 6 — El Corazón del Mundo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Lo lograste! Encontraste el corazón del mundo. Aurora está a salvo." | Geoda encontrada |
| HISTORIA | "La geoda es el corazón de la isla. Si la restauramos, todo volverá a la vida." | — |
| MISION | "Lleva la geoda al templo. Allí todo se completará." | — |

#### Capítulo 7 — La Brisa y el Sello (Final)

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Es hora de la decisión final. Lo que elijas, Aurora siempre será tu hogar." | — |
| HISTORIA | "El sello no estaba roto. Fue escondido para protegernos. Ahora depende de ti." | — |
| AMBIENTE | "La brisa trae recuerdos de todo lo que vivimos. Qué viaje tan increíble..." | — |

---

### 2.2 Carpintero (NPC-RIZ-002)

**Rol:** Vende herramientas T1, enseña carpintería

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Bienvenido! Soy el carpintero. ¿Necesitas una herramienta?" | Primera vez |
| HISTORIA | "Todas las herramientas de este pueblo son de madera. Respetuoso con la naturaleza." | — |
| MISION | "Te regalo esta hacha básica. Úsala con cuidado para recoger madera." | Dar hacha T1 |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! Las cenizas están arruinando la madera. ¿Puedes traerme tablas limpias?" | — |
| HISTORIA | "La ceniza no es normal. Quema de manera diferente. Como si fuera... ceniza de algo valioso." | — |
| MISION | "Necesito 5 tablas de madera limpia para reparar las puertas del pueblo." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Trabajé toda la noche en el puente! Míralo, está hermoso." | — |
| HISTORIA | "Mi abuelo me contó que su abuelo también ayudó a construir un puente. Es un legado." | — |
| MISION | "¿Me ayudas a traer vigas del bosque? Necesito 3 troncos grandes." | — |

#### Capítulo 3 — El Jardín Ahogado

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está dañando la madera. Necesito tratarla con aceite." | — |
| HISTORIA | "Los antiguos usaban resina especial para proteger la madera del agua. Yo uso aceite de pino." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Preparé herramientas especiales para el valle. Más resistentes al viento." | — |
| MISION | "Trae 3 piezas de hierro del herrero y te haré una herramienta mejor." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Trabajo a la luz de las velas. No es ideal, pero se hace." | — |
| AMBIENTE | "Las sombras mueven las formas de la madera. Da inspiración..." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! Si la traes aquí, puedo hacer un pedestal digno para ella." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Lo que decidas, Aurora siempre tendrá carpintero. Prometido." | — |

---

### 2.3 Vendedora de la Tienda General (NPC-RIZ-003)

**Rol:** Vende semillas, comida, materiales básicos

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Eres nuevo? Bienvenido a mi tienda. Tenemos de todo." | Primera vez |
| HISTORIA | "Esta tienda lleva generaciones en la familia. Mi bisabuela la abrió." | — |
| MISION | "¿Quieres empezar a cultivar? Te vendo semillas básicas." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Las cenizas están afectando los cultivos! Las hojas se vuelven grises." | — |
| HISTORIA | "Dicen que la ceniza es de algo antiguo. Mi bisabuela mencionaba 'la quema'..." | — |
| MISION | "¿Puedes traerme hierbas limpias del bosque? Las necesito para remedios." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡El puente está listo! Ahora puedo traer mercancía del otro lado." | — |
| HISTORIA | "Mi bisabuela contaba que antes había un puente. Se cayó hace mucho." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está subiendo. Necesito mover la mercancía a lugares altos." | — |
| AMBIENTE | "Los peces nadan donde antes había flores. Es raro pero bonito." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Preparé suministros para el viaje al valle! ¿Qué necesitas?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche es larga, pero la tienda sigue abierta. Siempre." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! ¿Puedo verla? Es la cosa más hermosa que he visto." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Gracias por todo lo que hiciste. Esta tienda será tuya si la quieres." | — |

---

### 2.4 Viejo Sabio (NPC-RIZ-004)

**Rol:** NPC misterioso, da pistas sobre la historia

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "...Ya llegas. He estado esperando." | Primera vez |
| HISTORIA | "Esta isla guarda secretos muy antiguos. Algunos que ni yo recuerdo del todo..." | — |
| AMBIENTE | "El viento trae ecos del pasado. ¿Los escuchas?" | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Ah, las cenizas. Ya esperaba que aparecieran." | — |
| HISTORIA | "Esas cenizas no son volcánicas. Son de una biblioteca. Los antiguos quemaron sus conocimientos para protegerlos." | Después de investigar |
| MISION | "Busca los murales en las ruinas. Allí encontrarás la verdad." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente... recuerdo cuando era niño. Mi padre me contó su historia." | — |
| HISTORIA | "El puente no solo une orillas. Une tiempos. Los antiguos lo construyeron con memoria." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La sombra del templo no es peligrosa. Es... una memoria. Un eco de luz." | — |
| HISTORIA | "El templo proyecta su sombra como un reloj. Cuando el sol está en el punto exacto, la sombra revela algo." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los sellos están listos para ser encontrados. Pero cuidado... protegen algo." | — |
| HISTORIA | "Los 7 sellos no estaban rotos. Fueron escondidos. Alguien quería que no fueran encontrados fácilmente." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna es una prueba. No de fuerza, sino de fe." | — |
| HISTORIA | "Los antiguos sabían que vendría esta noche. Dejaron pistas en las estrellas." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... el corazón del mundo. No la toques con las manos desnudas." | — |
| HISTORIA | "Esa geoda es la fuente de toda la vida de Aurora. Si la restauras, todo florecerá." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Es hora. La decisión que tomes definirá Aurora. Pero recuerda... siempre hay un camino." | — |
| HISTORIA | "El Sello no estaba roto. Fue escondido para protegernos de nosotros mismos. Ahora confío en ti." | — |

---

### 2.5 Pescador del Puerto (NPC-RIZ-005)

**Rol:** Enseña a pescar, vende cebo

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Quieres pescar? Es mi pasión. Te enseño." | Primera vez |
| HISTORIA | "El mar de Aurora es generoso. Siempre hay pez." | — |
| MISION | "Toma esta caña. Busca un lugar tranquilo y lanza el anzuelo." | Dar caña T1 |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Las cenizas están espantando a los peces! Están más profundos." | — |
| AMBIENTE | "El agua tiene un brillo extraño. Como si la ceniza brillara..." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Ahora puedo pescar desde el otro lado del puente. ¡Nuevos peces!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El jardín inundado es un paraíso para los peces. ¡Hay especies nuevas!" | — |
| AMBIENTE | "Los peces nadan entre las flores. Es como un sueño..." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Dicen que en el valle hay peces que vuelan. ¿Será verdad?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "De noche los peces brillan. Es mágico pescar con la luna." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! ¿Puedo pescar cerca de ella? Quiero ver si los peces reaccionan." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Gracias por todo. Aurora siempre tendrá mar para pescar." | — |

---

### 2.6 Agricultora (NPC-RIZ-006)

**Rol:** Vende semillas, enseña cultivo

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Quieres cultivar? Es relajante y gratificante." | Primera vez |
| MISION | "Te vendo semillas básicas. Plántalas en tierra húmeda y riega cada día." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Las cenizas están matando los cultivos! Las hojas se marchitan." | — |
| MISION | "Necesito hierbas limpias del bosque para hacer un remedio natural." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Con el puente puedo traer semillas del otro lado. ¡Nuevas variedades!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El jardín inundado puede ser una oportunidad. Los arroces crecen en agua..." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle tiene tierra fértil. Si la restauramos, podemos cultivar ahí." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las plantas necesitan luz. Durante la noche eterna uso velas especiales." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! Si la traes al jardín, todo crecerá más rápido." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Aurora siempre será tierra fértil. Gracias por salvarla." | — |

---

### 2.7 Niña del Pueblo (NPC-RIZ-007)

**Rol:** NPC decorativo, da quests simples

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Eres nuevo? ¿Quieres jugar conmigo?" | Primera vez |
| AMBIENTE | "¡Mira! Encontré una concha que brilla. ¿Es mágica?" | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas son grises. ¿Puedes traerme una piedra de colores?" | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡El puente es gigante! ¿Puedo cruzarlo?" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está fría. ¿Los peces no tienen frío?" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Quiero ir al valle! ¿Es verdad que hay vientos que susurran?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche es larga. ¿Podemos contar estrellas?" | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda brilla! ¿Puedo tocarla?" | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Gracias por salvar Aurora! ¿Jugamos mañana?" | — |

---

### 2.8 Animador de la Plaza (NPC-RIZ-008)

**Rol:** Organiza eventos, anima festivales

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Bienvenido! Soy el animador. Preparo festivales y eventos." | Primera vez |
| HISTORIA | "Cada festival cuenta una historia. El de la Brisa es el más importante." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas dan material para un festival temático. ¡Cenizas brillantes!" | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Organizaré un festival por el puente! Celebración de unión." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El jardín inundado da ideas para un festival acuático." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle de los vientos... ¡haré un festival de cometas!" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna merece un festival de luces. ¡Será hermoso!" | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! ¡El festival más grande de la historia!" | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Sea cual sea el final, celebraremos. Eso hacemos los de Aurora." | — |

---

## 3. ISLA CORAL (COR) — Diálogos

### 3.1 Herrero de Coral (NPC-COR-001)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Bienvenido! Soy el herrero. Forjo las mejores herramientas de cobre." | Primera vez |
| HISTORIA | "El cobre de esta isla es especial. Viene del volcán dormido." | — |
| MISION | "¿Necesitas herramientas de cobre? Trae el material y las forjo." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas están enfriando la fragua. El metal no.fluye bien." | — |
| MISION | "Necesito carbón limpio. Las cenizas lo contaminan." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Con el puente puedo traer hierro del continente. ¡Nuevas posibilidades!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está oxidando mis herramientas. Necesito aceite urgente." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Forjaré herramientas especiales para el valle. Resistentes al viento." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La fragua no se apaga nunca. Ni siquiera en la noche eterna." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡La geoda! Puedo forjar un pedestal digno para ella." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las herramientas que forjé siempre recordarán este viaje." | — |

---

### 3.2 Pescadora de Coral (NPC-COR-002)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Quieres pescar en el arrecife? Es mi especialidad." | Primera vez |
| HISTORIA | "El arrecife de Coral es el más hermoso del archipiélago." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los corales están cambiando de color. Las cenizas los afectan." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Ahora puedo pescar en ambos lados. ¡Más peces, más variedad!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El jardín inundado es un nuevo arrecife. ¡Hay peces de todos los colores!" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Dicen que en el valle hay peces que vuelan sobre el agua." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los peces bioluminiscentes solo salen de noche. ¡Son hermosos!" | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda brilla como un faro submarino. Los peces nadan hacia ella." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Aurora siempre tendrá mar. Y yo siempre tendré peces para pescar." | — |

---

### 3.3 Comerciante Viajero (NPC-COR-003)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Saludos, viajero! Tengo cosas que no encontrarás en ningún pueblo." | Primera vez |
| HISTORIA | "He recorrido mares lejanos. Pero Aurora... Aurora es especial." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas tienen valor. En otros lugares se venden como especia rara." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente abre rutas comerciales. ¡Nuevos mercados!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua trae tesoros del fondo. ¿Has visto las perlas que aparecen?" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Preparé suministros para el viaje al valle. ¿Qué necesitas?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna es buena para el comercio. La gente compra más velas." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... esa cosa vale más que todo mi comercio. Pero no la vendo." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Mi barco siempre volverá a Aurora. Prometido." | — |

---

### 3.4 Guardia del Puerto (NPC-COR-004)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Identificación, por favor. Ah, eres el nuevo. Bienvenido." | Primera vez |
| HISTORIA | "El puerto es la puerta de Aurora. Yo la protejo." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Vigilancia extra. Las cenizas pueden atraer cosas..." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente necesita guardia también. Ampliaré mi patrulla." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua ha cambiado las rutas de patrulla. Ahora nado más." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle es peligroso. ¿Llevas las herramientas adecuadas?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna requiere guardia constante. No duermo." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda está a salvo. Yo me aseguro de que lo siga siendo." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Mi deber termina cuando Aurora esté segura. Y lo está." | — |

---

### 3.5 Niña de la Playa (NPC-COR-005)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Quieres jugar en la arena? ¡Encontré una concha grande!" | Primera vez |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas hacen la arena más suave. ¡Es como jugar en polvo mágico!" | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡El puente tiene escalones! ¿Puedo subirme?" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua trae conchas de todos los colores. ¡Nunca había visto tantas!" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Dicen que en el valle hay conchas que cantan. ¿Es verdad?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "De noche las conchas brillan. ¡Son como estrellas en la arena!" | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda brilla más que todas las conchas juntas." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Gracias! Aurora siempre será mi playa favorita." | — |

---

## 4. ISLA CENIZA (CEN) — Diálogos

### 4.1 Herrero Avanzado (NPC-CEN-001)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Soy el herrero avanzado. Forjo herramientas de hierro. No es para cualquiera." | Primera vez |
| HISTORIA | "El hierro de Ceniza es el mejor del archipiélago. Viene de las montañas." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas contaminan el metal. Necesito carbón puro." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Con el puente puedo recibir hierro de otras islas. Compararé calidades." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está oxidando todo. Necesito acelerar el trabajo." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Forjaré herramientas de hierro especial para el valle. Las mejores." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El fuego de la fragua no se apaga. Ni siquiera en la oscuridad." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda necesita un pedestal de hierro. Lo forjaré yo mismo." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las herramientas que forjé son eternas. Como Aurora." | — |

---

### 4.2 Minero (NPC-CEN-002)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¿Quieres minería? Es peligrosa pero gratificante. Te enseño." | Primera vez |
| HISTORIA | "Las minas de Ceniza tienen minerales que no se encuentran en ningún otro lado." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas han revelado nuevas vetas de mineral. ¡Es un hallazgo!" | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente permite traer equipos de minería mejores." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está inundando las minas. ¡Necesitamos bombas!" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle tiene minerales raros. ¡Quiero ir a explorar!" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "En la mina siempre es de noche. Para mí no cambia nada." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... es el mineral más puro que he visto jamás." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Siempre habrá minerales en Ceniza. Y yo siempre estaré para extraerlos." | — |

---

### 4.3 Cocinera del Pueblo (NPC-CEN-003)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! ¿Tienes hambre? Cocino los mejores platos de Ceniza." | Primera vez |
| HISTORIA | "Las recetas de Ceniza se han pasado de generación en generación." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas dan un sabor peculiar. ¡No está mal!" | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Con el puente traigo ingredientes de otras islas. ¡Nuevas recetas!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua trae peces nuevos. ¡Puedo hacer sushi!" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Prepararé provisiones para el viaje al valle. Comida que dure." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna es ideal para guisos calientes. ¿Quieres uno?" | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... ¿puedo cocinar cerca de ella? Da un calor especial." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Siempre habrá comida caliente en Ceniza. Eso es seguro." | — |

---

### 4.4 Bibliotecario (NPC-CEN-004)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Bienvenido a la biblioteca. El silencio, por favor." | Primera vez |
| HISTORIA | "Estos libros son los últimos vestigios de la civilización antigua." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Las cenizas son de la biblioteca antigua! Estos libros sobrevivieron." | — |
| HISTORIA | "La civilización quemó sus libros para proteger el conocimiento de los invasores. Las cenizas son su legado." | Después de leer mural |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente aparece en los libros antiguos. Tenía un nombre: 'Puente de las Memorias'." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua amenaza los libros. Necesito moverlos a un lugar seguro." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los libros hablan del valle. Tenía un nombre: 'Valle de los Vientos Susurrantes'." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna... los libros la describen. Es un eclipse ancestral." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda es el corazón del mundo. Está en todos los libros antiguos." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Tu historia quedará escrita en estos libros. Para siempre." | — |

---

### 4.5 Guardia de la Mina (NPC-CEN-005)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La mina está cerrada al público. Pero tú puedes entrar." | Primera vez |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Vigilancia extra. Las cenizas han atraído criaturas a la mina." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente conecta la mina con el bosque. Ruta de escape si algo sale mal." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua está llegando a la mina. ¡Cerradura extra!" | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle puede tener minerales. ¿Llevas equipo de minería?" | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La mina es oscura siempre. La noche eterna no cambia nada." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda no entra en la mina. Es demasiado grande. Y brillante." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Mi guardia termina cuando Aurora esté segura. Y lo está." | — |

---

## 5. ISLA AURORA (AUR) — Diálogos

### 5.1 Encantador (NPC-AUR-001)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "...Veo que buscas respuestas. El encantamiento requiere paciencia." | Primera vez |
| HISTORIA | "La magia de Aurora es antigua. Viene de la tierra misma." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas tienen poder residual. Las antiguas las usaban para encantar." | — |
| HISTORIA | "La ceniza no es solo restos. Es energía concentrada de la civilización perdida." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente está cargado de magia residual. Los antiguos lo encantaron." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua amplifica la magia. El jardín inundado es un lugar de poder." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle es donde la magia es más fuerte. Los sellos resuenan con los vientos." | — |
| MISION | "Trae los 7 sellos y te enseñaré el encantamiento final." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna... la magia está en su punto máximo. Cuidado." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... puedo sentirla. Es la fuente de toda la magia de Aurora." | — |
| HISTORIA | "Esa geoda es el corazón del mundo. Si la restauras, la magia fluirá de nuevo." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La decisión que tomes resonará con la magia. Elige sabiamente." | — |
| HISTORIA | "El sello no estaba roto. Fue escondido. Los antiguos protegían algo más grande que nosotros." | — |

---

### 5.2 Sanadora del Pueblo (NPC-AUR-002)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Bienvenido. Soy la sanadora. Si te lastimas, ven a verme." | Primera vez |
| HISTORIA | "Las hierbas de Aurora tienen poder curativo. Conozco cada una." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas irritan la piel. Tengo un remedio natural." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente me permite traer hierbas de otras islas. ¡Nuevos remedios!" | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua del jardín tiene propiedades curativas. Las plantas crecen rápido." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Prepararé pociones para el viaje al valle. No vayas sin ellas." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna trae melancolía. Tengo tés para el alma." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... su energía cura. Puedo sentirlo desde aquí." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Aurora siempre tendrá sanación. Porque siempre tendrá amor." | — |

---

### 5.3 Guardia Ancestral (NPC-AUR-003)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Soy el guardia ancestral. Protejo el templo. No pases sin permiso." | Primera vez |
| HISTORIA | "Mi familia lleva generaciones cuidando este templo." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas no deben tocar el templo. Es peligroso." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente conecta el templo con el pueblo. Ahora puedo vigilar ambos." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La sombra del templo no es peligrosa. Es una protección." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los sellos están en el valle. Debo protegerlos." | — |
| MISION | "Los 7 sellos deben ser restaurados. Es tu misión. Yo te cubro." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna... es la prueba definitiva. No me moveré de aquí." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda debe llegar al templo. Yo la escoltaré." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Mi deber ha terminado. Aurora está a salvo. Gracias, guardián." | — |

---

### 5.4 Artista del Pueblo (NPC-AUR-004)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "¡Hola! Soy el artista. ¿Ves la belleza en todo?" | Primera vez |
| HISTORIA | "Aurora es mi inspiración. Cada piedra, cada hoja, es arte." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas son hermosas. Tienen texturas que nunca había visto." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente es una obra de arte. Lo pintaré." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El jardín inundado es un lienzo vivo. Los colores cambian cada día." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El valle... los vientos pintan en el aire. Quiero capturarlo." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna es oscura pero hermosa. Pinto con sombras." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... es la obra maestra de la naturaleza. No puedo pintarla. Solo admirarla." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Tu historia será mi próxima obra. El viaje del guardián de Aurora." | — |

---

### 5.5 Viajero Misterioso (NPC-AUR-005)

#### Capítulo 0 — Prólogo

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "...Solo aparezco de noche. No preguntes por qué." | Primera vez |
| HISTORIA | "Conozco secretos que otros olvidaron. Pero no puedo decirlos todos." | — |

#### Capítulo 1 — Las Cenizas

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Las cenizas son un mensaje. ¿Sabes quién lo envió?" | — |
| HISTORIA | "La ceniza no es destrucción. Es una carta de la civilización antigua." | — |

#### Capítulo 2 — El Puente

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El puente... recuerdo cuando era nuevo. Sí, soy muy viejo." | — |

#### Capítulo 3 — El Jardín

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "El agua revela lo que la tierra esconde. Mira bien." | — |

#### Capítulo 4 — El Valle

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Los sellos... yo los escondí. Pero ahora es tiempo de encontrarlos." | — |
| HISTORIA | "El sello no estaba roto. Fue escondido para proteger a Aurora de sí misma." | — |

#### Capítulo 5 — La Noche

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La noche eterna... la provocé yo para darte tiempo. Disculpa." | — |

#### Capítulo 6 — El Corazón

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "La geoda... fui yo quien la escondió. El guardián original." | — |
| HISTORIA | "Soy el Primer Guardián. Cuidé de Aurora durante siglos. Ahora es tu turno." | — |

#### Capítulo 7 — El Final

| Tipo | Diálogo | Condición |
|------|---------|-----------|
| SALUDO | "Mi trabajo ha terminado. Aurora está en tus manos. Confío en ti." | — |
| HISTORIA | "El sello no estaba roto. Fue escondido para protegernos de nosotros mismos. Ahora confío en ti, nuevo guardián." | — |

---

## 6. Tabla Resumen de Progresión

| NPC | Cap 0 | Cap 1 | Cap 2 | Cap 3 | Cap 4 | Cap 5 | Cap 6 | Cap 7 |
|-----|-------|-------|-------|-------|-------|-------|-------|-------|
| Mayor RIZ | Tutorial | Cenizas | Puente | Sombra | Sellos | Noche | Corazón | Final |
| Carpintero RIZ | Hacha T1 | Madera limpia | Vigas | Aceite | Herramientas | Velas | Pedestal | Promesa |
| Vendedora RIZ | Tienda | Hierbas | Mercancía | Agua | Suministros | Velas | Geoda | Herencia |
| Sabio RIZ | Misterio | Biblioteca | Padre | Luz | Sellos | Fe | Corazón | Guardián |
| Pescador RIZ | Caña T1 | Peces profundos | Nuevo lado | Flores | Peces voladores | Luna | Faro | Mar |
| Agricultora RIZ | Semillas | Remedios | Nuevas variedades | Arroces | Tierra fértil | Velas | Jardín | Tierra |
| Niña RIZ | Concha | Piedra | Puente | Peces | Valle | Estrellas | Geoda | Juego |
| Animador RIZ | Festival | Cenizas brillantes | Unión | Acuático | Cometas | Luces | Celebración | Fiesta |
| Herrero COR | Cobre | Carbón | Hierro | Aceite | Especial | Fragua | Pedestal | Herencia |
| Pescadora COR | Arrecife | Coral | Nuevo lado | Perlas | Peces voladores | Biolum. | Faro | Mar |
| Viajero COR | Mercancía | Especia | Mercados | Tesoros | Suministros | Velas | Valor | Vuelta |
| Guardia COR | Identificación | Vigilancia | Patrulla | Rutas | Equipo | No duerme | Seguridad | Deber |
| Niña Playa | Arena | Polvo | Escalones | Conchas | Conchas cant. | Conchas brill. | Brillante | Playa |
| Herrero CEN | Hierro | Carbón puro | Comparar | Oxidación | Especial | Fuego | Pedestal | Eternas |
| Minero CEN | Minería | Vetas | Equipos | Bombas | Minerales | Oscuridad | Puro | Siempre |
| Cocinera CEN | Recetas | Sabor | Ingredientes | Sushi | Provisiones | Guisos | Calor | Caliente |
| Bibliotecario CEN | Libros | Verdadera | Nombre | Mover | Libros hablan | Eclipse | Corazón | Historia |
| Guardia CEN | Cerradura | Criaturas | Escape | Bombas | Equipo | Oscuridad | Brillante | Seguro |
| Encantador AUR | Magia | Energía | Residuo | Amplifica | Sellos | Máximo | Fuente | Decisión |
| Sanadora AUR | Hierbas | Remedios | Nuevas | Curativas | Pociones | Tés | Energía | Amor |
| Guardia AUR | Templo | Protección | Vigilar | Sombra | Sellos | Prueba | Escoltar | Terminó |
| Artista AUR | Belleza | Texturas | Pintura | Lienzo | Vientos | Sombras | Admirar | Obra |
| Viajero AUR | Secretos | Mensaje | Viejo | Revela | Escondí | Tiempo | Primer | Confío |

---

## 7. Integración con M21 (Sistema de Diálogos)

### 7.1 Formato JSON para M21

```json
{
  "dialogue_id": "DLG-RIZ-001-CAP0-SALUDO",
  "npc_id": "NPC-RIZ-001",
  "tipo": "SALUDO",
  "capitulo": 0,
  "condiciones": {
    "game_progress.chapter": 0,
    "friendship[NPC-RIZ-001]": {"min": 0, "max": 100}
  },
  "nodes": [
    {
      "id": "start",
      "text": "¡Bienvenido a Aurora! Soy el mayor de este pueblo.",
      "next": "end"
    }
  ]
}
```

### 7.2 Variables de Estado

| Variable | Tipo | Uso |
|----------|------|-----|
| `game_progress.chapter` | int | Capítulo actual (0-7) |
| `friendship[npc_id]` | int | Nivel de amistad (0-100) |
| `world.season` | enum | Estación actual |
| `world.hour` | int | Hora del día (0-23) |
| `player.location` | string | Ubicación actual |
| `quest.completed[quest_id]` | bool | Misión completada |
