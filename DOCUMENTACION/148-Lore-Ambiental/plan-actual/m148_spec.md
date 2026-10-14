# M148 — Lore Ambiental: Especificación de Composición y Plantillas

**Módulo:** M148
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para contenido de lore.

---

## Composición por Isla

| Isla | Ruinas | Objetos | Arquitectura | Vegetación | Daños | Murales | Estatuas | Mapas | Canciones | Rumores | Total |
|------|--------|---------|-------------|-----------|-------|---------|----------|-------|-----------|---------|-------|
| Raíz | 3 | 3 | 2 | 3 | 2 | 2 | 2 | 1 | 1 | 1 | 18 |
| Coral | 3 | 2 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | 14 |
| Ceniza | 2 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | 14 |
| Aurora | 2 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1 | 1 | 14 |

## Plantillas de Texto por Tipo

| Tipo | Líneas | Ejemplo |
|------|--------|---------|
| Ruina | 3-5 | "Esta torre fue el faro de los Ancestrales. Su luz no guiaba barcos: guiaba recuerdos. Cuando el Sello se rompió, el faro se apagó y la isla olvidó." |
| Objeto | 2-3 | "Una concha tallada. Adentro, una inscripción: 'Para Elysia, que nunca se pierda en el mar de las mareas altas.'" |
| Vegetación | 2-3 | "Estos árboles no crecen solos: son las raíces del Árbol Primordial. Cada hoja es un recuerdo que la isla no pudo guardar." |
| Danno | 2 | "La fisura en la roca no es natural. Alguien la cortó. Con qué, nadie recuerda. Con quién, tampoco." |
| Mural | 3-4 | "Seis figuras danzan alrededor de un sol. La séptima está borrada. No por el tiempo: a propósito. La séptima fue la que se fue." |
| Estatua | 2-3 | "Piedra con forma de mujer, manos extendidas. No está pidiendo: está ofreciendo. Lo que ofrece, no se ve." |
| Mapa | 2 | "Un mapa de la isla hecho con hebras de coral. La ruta al Templo está trazada en hilo de plata. El hilo está roto." |
| Canción | 2-3 | "'Brilla donde nadie mira, / calla donde todos gritan. / El que escucha la brisa / tiene oídos de Ancestral.'" |
| Rumor | 2 | "Dicen que de noche, el Templo suena. Dicen que es el viento. Dicen que no es el viento." |

## Reglas
- Sin contradecir M147 (Biblia).
- Sin spoilers de M22 (Historia Principal).
- Sin duplicar lore de M66 (Anti-Softlock).
- Cada pieza tiene `CanonRef` obligatorio.

---

## Sección 4: Arquitectura cuenta historias (P3)

### 4.1 Estilo constructivo narrado por isla (cultura del constructor)

| Isla | Cultura constructora | Estilo | Pista narrativa |
|------|---------------------|--------|-----------------|
| **Raíz** | Ancestrales (pueblo fundacional) | Piedra caliza tallada a mano, arcos de medio punto, sin mortero visible. Los bloques se encajan por peso y forma. | Las cicatrices de talla en las columnas cuentan años: 7 surcos = 7 generaciones. |
| **Coral** | Pueblo de Mareas (nómadas marinos) | Cúpulas de coral vivo adherido, techos de hojas trenzadas que se regeneran cada marea. | El coral "crece" con las historias: nuevas salientes aparecen donde se cantó más fuerte. |
| **Ceniza** | Errantes del Volcán (refugiados) | Madera carbonizada entablada en seco, sin clavos. Estructuras ligeras que se reemplazan, no reparan. | Las vigas viejas se cuelgan de la casa nueva: "la casa recordaba antes de olvidarse". |
| **Aurora** | Guardias del Alba (orden monástica) | Bloques de basalto pulido, líneas rectas, proporciones áureas. Sin decoración: la forma ES el adorno. | Las sombras que proyecta el muro al mediodía forman runas que solo se leen de pie. |

**CanonRef:** M147 §2 "Cuatro sangres de la Isla", M167 (Isla Raíz, piedra caliza).

### 4.2 Piezas de arquitectura inspeccionables (columnas, arcos, casas)

| Pieza | Inspección (texto 60/40) | Hint para el jugador |
|-------|--------------------------|---------------------|
| **Columna de 7 surcos** (Raíz) | 60%: "Siete cicatrices. Siete personas tallaron esta columna a lo largo de una vida. La octava nunca llegó." 40%: "¿Y la que falta? ¿Murió? ¿Se fue?" | Lleva a buscar la historia de la 8ª generacional (M22 hook). |
| **Arco de coral vivo** (Coral) | 60%: "El arco no es piedra: es coral que aprendió a doblarse. Lo cantaron durante tres mareas para que se formara." 40%: "Si cantas otra vez, ¿se dobla más?" | Sugerencia: el canto de la marea (M43/M44). |
| **Casa de vigas colgadas** (Ceniza) | 60%: "Las vigas carbonizadas de la casa vieja cuelgan del tejado nuevo. No son decorativas: son memorias." 40%: "Tócalas y sientes el frío de la ceniza, no el calor del sol." | El jugador puede "limpiar" la ceniza (interacción M70) para revelar inscripciones. |
| **Muro de basalto rúnico** (Aurora) | 60%: "Al mediodía, la sombra del muro dibuja una runa. Las monjas dicen que la runa cambia con las estaciones." 40%: "¿Qué runa habrá en invierno?" | Pista de acceso al Templo de Aurora (M26). |

**CanonRef:** M70 (interacciones), M147 §5 "Piezas duraderas".

### 4.3 Relación arquitectura ↔ biblia sin contradicciones

Reglas de coherencia:
1. **Los Ancestrales no construyeron templos de piedra maciza:** el Templo Primordial es de coral y hueso (M147 §3). Cualquier "ruina de templo" en la Isla Raíz debe ser **pre-ancestral** (antes del pueblo fundacional).
2. **El pueblo de Mareas no deja fundaciones:** sus estructuras son orgánicas y se disuelven. No hay "cimientos de coral" en el suelo — solo salientes que quedan.
3. **Los Errantes no construyen para siempre:** sus casas se desmontan. Si hay una casa "permanente" en Ceniza, es una excepción narrativa (algo que la isla "decidió" mantener).
4. **Los Guardias sí construyen para siempre:** el basalto es permanente. Sus murallas son las únicas que no se derrumban con el tiempo.

**CanonRef:** M147 (Biblia) §2-§5, M26 (Templo Subterráneo).

### 4.4 Arquitectura que delata antigüedad (materiales por época)

| Época | Material | Cómo se ve | Cuándo |
|-------|----------|-----------|--------|
| **Pre-ancestral** (antes de la Isla) | Hueso de ballena + coral fosilizado | Blanco-amarillo, fragmentado, incrustado en la roca | Solo en la Isla Raíz (ruinas más profundas) |
| **Ancestral** (pueblo fundacional) | Piedra caliza sin mortero + madera de drago | Gris-rosado, tallada a mano, surcos visibles | Isla Raíz y Coral (las primeras aldeas) |
| **Marea viva** (nómadas marinos) | Coral orgánico + fibras marinas | Colores vivos (rosa, turquesa), "crece" lentamente | Isla Coral (estructuras actuales) |
| **Ceniza errante** (refugiados) | Madera carbonizada + fibras de caña | Negro-marrón, en seco, sin clavos | Isla Ceniza (todas las casas) |
| **Alba monástica** (orden) | Basalto pulido + hilo de plata | Gris oscuro, líneas perfectas, runas | Isla Aurora (murallas, templos) |
| **Actual** (juegador) | Lo que el jugador construya (M17) | Variable | Todas las islas |

**CanonRef:** M167 (Isla Raíz, perfil en capas), M50 (Vegetación, estacionalidad).

### 4.5 Arquitectura con pistas de acceso a templos (M26)

| Templo | Pista arquitectónica | Ubicación | Cómo se descifra |
|--------|---------------------|-----------|-----------------|
| **Templo de Raíz** (subterráneo, M26) | El "pilón" de caliza en el centro de la aldea tiene 7 surcos. El 7º está inacabado: es la entrada. | Isla Raíz, centro | El jugador debe "completar" el surco (interacción M70 + M13 pico) para revelar la escalera. |
| **Templo de Coral** (bajo el mar) | Las cúpulas de coral "cantan" en mareas altas. El canto marca la profundidad exacta del acceso. | Isla Coral, orilla | Escuchar el canto (M43) y sumergirse donde el tono es más grave (M11/F/11). |
| **Templo de Ceniza** (en la loma) | Las vigas colgadas de la casa más vieja forman, vistas desde el aire, un arco. El arco señala la puerta. | Isla Ceniza, loma | Vista aérea (cámara M07) + interacción con las vigas. |
| **Templo de Aurora** (en la muralla) | La runa de sombra del mediodía (basalto) cambia en solsticio: apunta al túnel. | Isla Aurora, muralla norte | Esperar al solsticio (M29) o usar el reloj (M29). |

**CanonRef:** M26 (Templo Subterraneo), M29 (Tiempo), M07 (Cámara), M43 (Audio).

---

## Sección 5: Vegetación cuenta historias (P5)

### 5.1 Vegetación narrativa (bosques/árboles ancestrales)

| Isla | Vegetación clave | Historia que cuenta |
|------|-----------------|-------------------|
| **Raíz** | Bosque de drago anular (12 árboles, 7 generaciones cada uno) | Cada anillo es un año. El árbol más viejo (84 anillos) cayó la noche del Sello: la fisura en el tronco es donde el Sello "se rompió" (M147 §3). |
| **Coral** | Manglar cantante (raíces sumergidas que vibran con la marea) | Las raíces "recordaron" la canción de fundación. Si el manglar se tala, la isla pierde la melodía (M43/M73). |
| **Ceniza** | Campo de caña-carbón (negra por dentro, verde por fuera) | La caña "bebió" la ceniza del volcán. Su jugo es negro: es el tinte que los Errantes usan para escribir memorias (M50/M16). |
| **Aurora** | Pradera de helecho-rúnico (hojas que se tiñen de plata en solsticio) | Las monjas plantaron el helecho "para que la tierra no se olvide". En solsticio, las hojas dibujan las mismas runas que el muro (M50/M29). |

**CanonRef:** M50 (Vegetación), M73 (Coleccionables), M147 §3 "El Sello".

### 5.2 Árboles/plantas inspeccionables con historia local

| Pieza | Inspección 60/40 | Hint |
|-------|-------------------|------|
| **Drago de 84 anillos** (Raíz) | 60%: "Cienta y cuatro anillos. La última cicatriz no es un año: es una herida." 40%: "¿Qué le hirió? ¿Quién?" | El drago cayó en la noche del Sello (M147 hook). |
| **Mangle cantante** (Coral) | 60%: "Sus raíces tocan el agua como un peine toca una corda. La melodía cambia con la marea." 40%: "¿Y si la marea se detiene?" | El mangle "guarda" la canción de fundación (M43). |
| **Caña-carbón** (Ceniza) | 60%: "Vista de lejos, es verde. Vista de cerca, el tallo es negro. El jugo mancha para siempre." 40%: "¿Para qué sirve un tinte que no se borra?" | El tinte para memorias (M16 escritura). |
| **Helecho-rúnico** (Aurora) | 60%: "En solsticio, las hojas se tiñen de plata y dibujan runas en el suelo. Las monjas dicen que la tierra escribe." 40%: "¿Qué runa habrá en el otro solsticio?" | Pista del Templo de Aurora (M26). |

**CanonRef:** M70 (interacciones), M43 (audio), M16 (crafting/escritura).

### 5.3 Vegetación vinculada a eventos pasados (quemas, curaciones)

| Evento | Vegetación resultante | Dónde |
|--------|----------------------|-------|
| **La Quema** (M147 §4): el pueblo de Ceniza quemó su aldea para "empezar de nuevo" | El campo de caña-carbón (5.1): la caña creció "sobre la ceniza" y la absorbió. Donde hubo fuego, hay tinte negro. | Isla Ceniza, centro |
| **La Curación** (M147 §4): el Árbol Primordial sanó la fisura del Sello | El bosque de drago anular (5.1): los 12 árboles son "ramas" del Árbol. La cicatriz del drago de 84 anillos es donde la curación "costó". | Isla Raíz, noroeste |
| **La Marea Negra** (M147 §4): la marea que mató al pueblo de Coral | El manglar cantante: los mangles "recordaron" el silencio de esa marea. Por eso su canción tiene una pausa de 7 segundos cada 12 mareas. | Isla Coral, orilla sur |

**CanonRef:** M147 §4 "Los Tres Días", M50 (Vegetación, eventos).

### 5.4 Vegetación con cambio estacional que revela lore (M50)

| Estación (M29) | Cambio visual | Lore revelado |
|----------------|--------------|---------------|
| **Primavera** | Los dragos brotan hojas nuevas (rojo anaranjado) | El rojo es el color del "recuerdo nuevo". El jugador ve que los anillos "crecen". |
| **Verano** | El manglar se expande (raíces visibles en la orilla) | La marea baja más: se ven las inscripciones de coral "quecantan" (M43). |
| **Otoño** | La caña-carbón se seca (tallo dorado) | El jugo se espesa: el tinte se vuelve dorado (recuerdos viejos vs nuevos). |
| **Invierno** | El helecho-rúnico se recoge (hojas plegadas, plata oculta) | La tierra "duerme": las runas no se dibujan hasta el solsticio (M29). |

**CanonRef:** M50 (Vegetación, estacionalidad), M29 (Tiempo).

### 5.5 Sin contradicción con la flora de colección (M73)

Reglas:
1. **Los coleccionables de M73 son sub-conjunto de la flora M50:** cada planta coleccionable EXISTE también como lore en 5.1-5.4. No hay "planta fantasma" que solo aparece en el catálogo.
2. **La flora narrativa NO es coleccionable:** el drago de 84 anillos, el mangle cantante, la caña-carbón y el helecho-rúnico son **piezas de ambiente** (M50), no drops (M15). El jugador puede inspeccionarlos pero no "recolectarlos".
3. **Si M73 agrega una nueva flor coleccionable en un bioma**, el lore de M148 debe mencionar esa flor en la sección correspondiente (actualizar 5.1 con la fila nueva).
4. **La flora procedural (M50 shader) no cuenta historias:** los parches de hierba "genérica" que llenan el terreno NO tienen lore. Solo las 4 piezas clave (5.1-5.4) cuentan.

**CanonRef:** M73 (Coleccionables), M50 (Vegetación), M15 (Recursos).

---

## Sección 12: Peces revelan información (P12)

### 12.1 Lore en fichas de peces raros/descritos (M34/M73)

Regla: cada pez coleccionable en M73 tiene una **ficha de 2 líneas** en el catálogo (M34). La ficha mezcla **dieta/hábitat real** (60%) con **mito local** (40%). Ejemplo:

> "El pez-luna come algas bioluminiscentes de la fosa del Templo. Los pescadores de Coral dicen que su luz NO es bioluminiscencia: es el reflejo de un recuerdo que alguien dejó caer en el agua y que el pez 'guarda'."

**CanonRef:** M34 (Pesca), M73 (Coleccionables), M147 §4 "Marea Negra".

### 12.2 Mínimo 6 peces con lore pivotal (mito de la isla)

| # | Pez | Lore pivotal | Mito |
|---|-----|-------------|------|
| 1 | **Pez-luna** (fosa del Templo de Coral) | Come algas de la fosa; su luz es "recuerdo atrapado" | El Mito de la Marea Negra: la marea que mató al pueblo dejó un recuerdo en el agua; el pez lo "come" y lo lleva a la superficie como luz. |
| 2 | **Peque-vidrio** (lago de Ceniza) | Transparente; solo se ve cuando hay ceniza en el agua | El Mito de la Quema: el pueblo quemó su aldea; el agua se volvió negra; el pez "aprendió" a ser transparente para "no recordar". |
| 3 | **Carpa-anillo** (bajo el drago caído, Raíz) | Tiene 84 anillos en el costado (igual que el drago) | El Mito del Sello: cada anillo es un año del Sello. El pez "guarda" el tiempo que el drago no vivió. |
| 4 | **Peje-vela** (banco de Coral) | Su aleta es translúcida y "catcha" la luz del sol | El Mito de la Fundación: la primera vela del pueblo fue hecha del aleta de este pez. "El sol navegó por el mar hasta que alguien lo atrapó." |
| 5 | **Arenque-runas** (muralla de Aurora) | Su escama tiene un patrón que parece escritura | El Mito de las Runas: las monjas dicen que el pez "escribió" las runas en el muro antes de que existieran. |
| 6 | **Pez-sello** (solo aparece en la fosa del Templo de Raíz, no coleccionable) | Opaco, negro, sin aletas. "No nada: cae." | El Mito del Sello roto: es el "pedazo" del Sello que cayó al fondo. No se puede capturar: se disuelve si lo tocas. |

**CanonRef:** M147 §3-§4, M34 (Pesca), M73 (Coleccionables).

### 12.3 Pez-lore desbloqueado al capturarlo/completar ficha

Regla: al capturar un pez por **primera vez** (M34), el catálogo (M73) muestra la ficha completa (60/40). Al capturarlo por **segunda vez**, se desbloquea el **mito** (la parte 40%). Al completar **todos los peces de un bioma**, se desbloquea una **pista de la fosa** (hook M22/M147).

- 1ª captura: "Pez-luna. Come algas de la fosa. Su luz es bioluminiscencia." (60% solo)
- 2ª captura: "+ Los pescadores dicen que NO es bioluminiscencia: es un recuerdo. La marea negra dejó algo en el agua y el pez lo guarda." (40% desbloqueado)
- **Todos los peces de Coral:** "Hay algo en la fosa que NO es un pez. No nada: cae." (pista fosa M26)

**CanonRef:** M34 (Pesca, desbloqueo), M73 (Coleccionables, progreso).

### 12.4 Grafo: pez → secreto de aguas profundas (M34)

```
Pez-luna (Coral) ──► "La fosa guarda un recuerdo" ──► Templo de Coral (M26)
Peque-vidrio (Ceniza) ──► "El agua negra no recuerda" ──► Loma de Ceniza (M26)
Carpa-anillo (Raíz) ──► "84 años, una cicatriz" ──► Bosque de drago (M50)
Peje-vela (Coral) ──► "La primera vela" ──► Mito de Fundación (M147)
Arenque-runas (Aurora) ──► "Runas antes de murallas" ──► Muro de Aurora (M26)
Pez-sello (Raíz, no coleccionable) ──► "El pedazo del Sello" ──► Fosa del Templo de Raíz (M26)
```

Cada pez es un **nodo en el grafo de pistas** (M148 §12). El jugador que complete el grafo (todos los peces + mitos) tiene la información para **elegir** su propia ruta al Templo (anti-infodump: la isla NO te dice dónde está el Templo, te da 4 pistas y tú las conectas).

**CanonRef:** M34 (Pesca, grafo), M26 (Templo), M147 (Biblia).

### 12.5 Pez con descripción de dieta/hábitat mezclada con mito

Ejemplo de ficha completa (Pez-luna):

> **Dieta (60%):** Algas bioluminiscentes de la fosa del Templo de Coral. Se alimenta en la penumbra, a 4-8 m de profundidad. Su luz atrae plancton.
>
> **Mito (40%):** "El pez-luna no come: escucha. La fosa guarda un recuerdo de la Marea Negra y el pez 'come' el recuerdo para que el agua pueda soltarlo. Por eso brilla: no es luz, es memoria."
>
> **Hábitat (mezclado):** Solo aparece en la fosa del Templo de Coral. No en el manglar. No en la orilla. "Porque fuera de la fosa, el recuerdo no existe."

**CanonRef:** M34 (Pesca, fichas), M147 §4 "Marea Negra".

---

## Sección 13: Plantas revelan secretos (P13)

### 13.1 Lore en fichas de plantas de colección (M50/M73)

Regla: cada planta coleccionable tiene una ficha de 2 líneas. 60% botánica + 40% secreto (cura/clima/ritual). Ejemplo:

> "Lirio de marea. Florece solo 4 noches al año, cuando la marea baja 3 m. Su raíz extrae sales que curan la 'fiebre de ceniza' (M33)."

**CanonRef:** M50 (Vegetación), M73 (Coleccionables), M33 (Clima).

### 13.2 Mínimo 6 plantas con secretos (cura, clima, ritual)

| # | Planta | Secreto | Tipo |
|---|--------|---------|------|
| 1 | **Lirio de marea** (Coral) | Florece 4 noches/año; su raíz cura la "fiebre de ceniza" | Cura |
| 2 | **Musgo de runa** (Aurora) | Crece solo donde hay piedra expuesta al solsticio; "escribe" con el sol | Ritual |
| 3 | **Círculo de hongo** (Ceniza) | Crece en espiral; el centro marca el punto exacto donde "empezó la Quema" | Clima/Geografía |
| 4 | **Flor de drago joven** (Raíz) | Un brote del Árbol Primordial; si crece, el Sello "vive"; si se seca, "murió" | Ritual/Progreso |
| 5 | **Alga de canto** (Coral) | Absorbe vibración del manglar; al morderla, se "escucha" la canción de fundación | Cura (auditiva) |
| 6 | **Tallo de caña-carbón joven** (Ceniza) | El primer brote verde sobre ceniza; "la isla eligió vivir otra vez" | Clima/Esperanza |

**CanonRef:** M50 (Vegetación), M73 (Coleccionables), M147 §4.

### 13.3 Planta-lore desbloqueada al cosechar/ficha

Progresión (igual que peces 12.3):
- 1ª cosecha: ficha botánica (60%)
- 2ª cosecha: secreto (40%) — "El lirio NO florece por la luna: florece por el silencio de la marea. Si hay ruido, no abre."
- **Todas las 6 plantas:** se desbloquea la **receta escondida** (M16) — "Caldo de memoria" (lirio + alga de canto + tallo de caña): "olvidar lo que duele y guardar lo que sirve" (hook M22).

**CanonRef:** M73 (progreso), M16 (crafting), M22 (Historia).

### 13.4 Grafo: planta → receta culinaria/curativa (M16)

```
Lirio de marea ──► cura "fiebre de ceniza" (M33) ──► receta "Té de marea baja"
Musgo de runa ──► tinta solar (M16 escritura) ──► receta "Tinta de solsticio"
Círculo de hongo ──► marca geográfica ──► receta "Comida de inicio" (M16, señaliza el "primer día")
Flor de drago joven ──► indicador del Sello ──► receta "Infusión de vigilia" (M16, M26 hook)
Alga de canto ──► audición de la canción ──► receta "Caldo de memoria" (M16, M43 hook)
Tallo de caña-carbón ──► esperanza/post-Quema ──► receta "Primer brote" (M16, M22 hook)
```

**CanonRef:** M16 (Crafting, recetas), M33 (Clima), M43 (Audio), M22 (Historia).

### 13.5 Planta con estacionalidad coherente (M33/M29)

| Planta | Estación (M29) | Comportamiento | Coherencia M33 |
|--------|---------------|----------------|-----------------|
| Lirio de marea | Primavera + Verano (mareas bajas) | Florece 4 noches (sigue calendario lunar M29) | La marea baja coincide con el "viento del norte" (M33) |
| Musgo de runa | Solo solsticio de verano (Aurora) | Crece 3 días y muere | El solsticio es "el día más largo" (M33: sol alto = runa visible) |
| Círculo de hongo | Otoño (descomposición) | Aparece, permanece 1 estación | El otoño es "la isla suelta" (M33: viento del oeste) |
| Flor de drago joven | Permanente (no estacional) | Crece 1 cm/año | Es el "pulso" del Árbol (M147): no depende del clima |
| Alga de canto | Invierno (marea alta) | Se recoge solo en marea alta | El invierno es "la isla escucha" (M33: silencio) |
| Tallo de caña-carbón | Primavera (rebrote) | El primer brote verde | El rebrote es "la isla eligió vivir" (M33: viento del este) |

**CanonRef:** M33 (Clima), M29 (Tiempo/Estaciones), M50 (Vegetación).

---

## Sección 14: Minerales activan ruinas (P14)

### 14.1 Minerales que activan ruinas/altaríos (M35/M24)

Regla: cada ruina/altar (M24) tiene **un mineral activador** específico. Al colocar el mineral en el punto de activación (interacción M70), la ruina "enciende" (cambio visual + sonido M43). La activación es **persistente** (una vez encendida, queda — M66 anti-softlock).

**CanonRef:** M35 (Minería), M24 (Puzzles/Ruinas), M70 (Interacciones).

### 14.2 Mínimo 3 minerales activadores (uno por isla/s)

| Mineral | Isla | Ruina que activa | Efecto |
|---------|------|-----------------|--------|
| **Cristal de marea** (rosa translúcido) | Coral | Altar del Manglar | El manglar "recuerda" la canción; las raíces se iluminan (M43) |
| **Pedra de ceniza fría** (negra, lisa) | Ceniza | Lintel de la Quema | La loma "suelta" el olor a humo; el campo de caña brota (M50) |
| **Hilo de basalto** (gris con veta de plata) | Aurora | Muro runico del Templo | La runa de sombra "se completa"; el túnel se abre (M26) |
| **Fragmento de sello** (caliza griñosa, cálido al tacto) | Raíz | Pilón de 7 surcos | El 7º surco "se talla solo"; la escalera aparece (M26) |

**CanonRef:** M35 (Minería), M24 (Puzzles), M26 (Templo), M147 §3 "El Sello".

### 14.3 Grafo: mineral → ruina/altar que enciende

```
Cristal de marea (Coral, extraído en arrecife M35)
  ──► Altar del Manglar ──► manglar se ilumina ──► pista: "la canción está en las raíces"

Pedra de ceniza fría (Ceniza, extraída en ladera M35)
  ──► Lintel de la Quema ──► loma suelta humo ──► pista: "el campo brota otra vez"

Hilo de basalto (Aurora, extraído en cantera M35)
  ──► Muro runico ──► runa se completa ──► pista: "el túnel apunta al solsticio"

Fragmento de sello (Raíz, solo en fosa del Templo M35)
  ──► Pilón de 7 surcos ──► 7º surco se talla ──► pista: "la escalera está aquí"
```

Cada mineral es **único y no se repite**: no hay "farmeo" (cozy, M147). Si el jugador lo pierde, no puede re-extrajlo (la veta se agota tras 1 uso).

**CanonRef:** M35 (Minería, vetas), M24 (Puzzles), M26 (Templo).

### 14.4 Mineral con lore de extracción (dónde y cómo)

| Mineral | Dónde | Cómo se extrae | Lore |
|---------|-------|---------------|------|
| Cristal de marea | Arrecife de Coral (bajo 3 m, M11/nadar) | Con cuchillo (M13, 1 golpe). NO con pico: "el cristal no rompe: se deja ir." | "Cada cristal es una lágrima de la Marea Negra. El arrecife la guardó para que no se perdiera en el mar." |
| Pedra de ceniza fría | Ladera de Ceniza (a media loma, M13 pico) | 3 golpes con pico. La piedra está "fría" aunque el sol la da. | "La ceniza no se enfría: se acuerda. Esta piedra recuerda el frío de la noche que empezó la Quema." |
| Hilo de basalto | Cantera de Aurora (muralla norte, M13 pico) | 5 golpes. La veta de plata "brilla" al exponerse al aire. | "Las monjas dicen que el basalto 'escribió' antes de ser piedra. La veta de plata es la palabra que quedó." |
| Fragmento de sello | Fosa del Templo de Raíz (solo accesible tras completar M26) | NO se extrae: se **recibe** (evento M73). "El Sello te lo da si lo mereces." | "No es un mineral: es un pedazo del Sello roto. No se extrae: se hereda." |

**CanonRef:** M35 (Minería), M13 (Herramientas), M11 (Nadar), M26 (Templo), M147 §3.

### 14.5 Activación persistente (una vez encendida, queda)

Regla: la activación de ruinas es **permanente** (M66 anti-softlock):
- Una vez que el cristal enciende el Altar del Manglar, **no se apaga** al guardar/cargar (persiste en M59 save data).
- El sonido de activación (M43) se reproduce **una vez**. En cargas posteriores, el manglar ya está iluminado (sin sonido).
- Si el jugador **nunca** activa la ruina, el juego NO se bloquea: hay rutas alternativas (M66). La ruina inactiva es "estética" hasta que se activa.
- El estado de activación se guarda en `GameState.M70` como `flag_ruina_activada: bool` (M59).

**CanonRef:** M66 (Anti-Softlock), M59 (Persistencia), M70 (Interacciones).

---

## Sección 15: Terreno revela información (P15)

### 15.1 Cambios del terreno que destapan secretos (M50/M74)

Regla: el terreno (M08/M50) cambia con las estaciones (M29) y con eventos (M74). Cada cambio **revela** algo que estaba oculto:
- **Erosión de lluvia** (M33): la tierra se desliza y aparece una inscripción bajo la ladera.
- **Floración de marea** (M74 evento): la orilla se inunda y aparecen las inscripciones de coral "quecantan" (M43).
- **Humedad de invierno** (M33): la niebla baja y el helecho-rúnico (5.1) se tiñe de plata antes de tiempo.

**CanonRef:** M50 (Vegetación), M74 (Eventos), M33 (Clima), M08 (Mundo).

### 15.2 Tres ubicaciones por temporada (12 anuales)

| Temporada (M29) | Ubicación 1 | Ubicación 2 | Ubicación 3 |
|-----------------|------------|------------|------------|
| **Primavera** | Ladera norte de Raíz: erosión revela inscripción del Árbol Primordial | Orilla sur de Coral: marea baja 3 m, inscripciones de coral visibles | Loma de Ceniza: niebla se disipa, círculo de hongo aparece |
| **Verano** | Muralla oeste de Aurora: solsticio, runa de sombra completa | Arrecife de Coral: pez-luna aparece en fosa (12.2) | Cañada de Raíz: drago joven brota (5.1) |
| **Otoño** | Bosque de Raíz: hojas caen, 84 anillos visibles en corteza | Orilla de Ceniza: caña se seca, tinte dorado (5.4) | Muralla norte de Aurora: helecho se recoge, plata oculta |
| **Invierno** | Fosa del Templo de Coral: marea alta, canto del manglar audible (5.2) | Ladera de Ceniza: ceniza "duerme", piedra fría palpable (14.4) | Pico de Aurora: niebla baja, runas solo visibles en luna llena |

**CanonRef:** M29 (Tiempo/Estaciones), M33 (Clima), M50 (Vegetación), M43 (Audio).

### 15.3 Secretos de terreno registrados en el diario

Regla: cuando el jugador **descubre** un secreto de terreno (p. ej. ve la inscripción por primera vez), el **diario** (M22/M53) registra automáticamente:
- **Qué:** "Inscripción del Árbol Primordial"
- **Dónde:** "Ladera norte de Raíz"
- **Cuándo:** "Primavera, tras la primera lluvia"
- **Estado:** "Descubierto" (no se puede "olvidar": M66 anti-softlock)

El diario NO explica el secreto: solo registra que se vio. El **lore** lo da la inspección (M70) o el NPC (M19).

**CanonRef:** M22 (Historia), M53 (UI), M66 (Anti-Softlock), M70 (Interacciones).

### 15.4 Sin recompensa duplicada de lore ya explorado

Regla: si el jugador ya vio un secreto de terreno en una temporada, la temporada siguiente **no repite** el mismo lore:
- La inscripción de primavera se "desdibuja" (erosión natural) en otoño: el jugador ya la vio.
- El canto del manglar en invierno es "más fuerte" (marea alta), pero la información es la misma que en verano (15.2): no hay "nuevo lore", hay "refuerzo".
- **Anti-duplicación:** el secreto del terreno NO es un "achievement" (M71): no hay "¡lo encontraste!" la 2ª vez. Solo la 1ª.

**CanonRef:** M66 (Anti-Softlock), M71 (Recompensas), M50 (Vegetación).

---

## Sección 16: Regla anti-infodump (P16/RF7)

### 16.1 Proporción mínima 60% lore ambiental vs diálogo explicativo

Regla: **60% del lore se entrega por el mundo** (inspecciones, murales, objetos, terreno) y **40% por NPCs** (diálogos, rumores). Invertir = infodump.

- Un NPC NO explica "dónde está el Templo": el Templo se encuentra por pistas ambientales (14.5, 15.2).
- Un NPC NO enumera "los 4 mitos de la isla": cada mito se descubre por un pez/planta/mineral (12.2, 13.2, 14.2).
- El diálogo del NPC es **reactivo**: "¿ya viste el drago caído?" → "Mmm, la cicatriz de la 7ª generación. Extraña, ¿no?" (no: "El drago cayó en la noche del Sello, hace 84 años, porque...").

**CanonRef:** M19 (NPC), M22 (Historia), M147 (Biblia).

### 16.2 Auditoría de muestreo: 10 zonas (2 por isla)

Checklist de auditoría (se ejecuta en QA M148):
- [ ] ¿La zona cuenta algo que el mundo YA cuenta en otra pieza? → SI = eliminar/duplicado.
- [ ] ¿La zona requiere más de 3 líneas de texto para entenderse? → SI = acortar a 60/40.
- [ ] ¿La zona explica un concepto que otro NPC ya explicó? → SI = mover a pieza ambiental.
- [ ] ¿La zona es "flavor text" sin hint? → ACEPTABLE (mínimo 1 hint por isla).

**CanonRef:** M148 §16, M22 (Historia).

### 16.3 Checklist de auditoría (¿explica algo que el mundo ya cuenta?)

Pregunta clave por cada pieza: **"¿Si quito esta pieza, el jugador pierde la pista del Templo?"**
- SI pierde → la pieza es **necesaria** (conservar).
- NO pierde → la pieza es **redundante** (eliminar o acortar).

Regla: máximo **4 pistas por Templo** (M26). Si hay 5+, fusionar las dos más débiles.

**CanonRef:** M26 (Templo), M148 §14.3-15.4.

---

## Sección 17: Diario de Lore Ambiental

### 17.1 Sección "Lore Ambiental" en el diario

El diario (M22/M53) tiene una pestaña **"Lore"** separada de "Misiones":
- **Entrada:** tipo de pieza (ícono) + texto corto (1 línea) + isla
- **Orden:** cronológico (cuándo se descubrió)
- **Capacidad:** ilimitada (no se borra: M66 anti-softlock)

**CanonRef:** M22 (Historia), M53 (UI).

### 17.2 Contador "Lore de {isla} x/12"

Cada isla tiene **12 piezas de lore** (18 total × 4 islas = 72, pero M148 define 12 por isla como objetivo). El diario muestra:
- "Raíz: 7/12" → el jugador sabe cuánto falta
- **No muestra cuáles faltan** (anti-spoiler: el jugador debe buscar)

**CanonRef:** M148 §1, M53 (UI).

### 17.3 Filtros: nuevos / leídos / pistas

3 filtros en la pestaña "Lore":
- **Nuevos:** piezas descubiertas en la sesión actual (destacadas)
- **Leídas:** piezas que el jugador ya abrió (texto completo visible)
- **Pistas:** piezas que dan hint para el Templo (subconjunto de "leídas")

**CanonRef:** M53 (UI), M26 (Templo).

### 17.4 Notificación ligera de nuevo lore (no modal)

Al descubrir una pieza nueva:
- **No** modal interrumpente (regla cozy M58)
- **Sí** toast inferior: "📜 Nueva pieza: Drago de 84 anillos (Raíz)"
- El toast dura 3s y desaparece. Sin sonido (M58 Reduce Motion).

**CanonRef:** M58 (Accesibilidad), M53 (UI).

### 17.5 Entrada con tipo de pieza, texto e isla

Formato de entrada en el diario:
```
[Ícono: Drago] "Cic7 — 7 generaciones" — Isla Raíz
  ↳ Texto corto: "La 7ª generación nunca llegó. La cicatriz sigue abierta."
```
- **Ícono:** tipo de pieza (árbol, columna, pez, mineral, etc.)
- **Texto corto:** 1 línea (60/40 resumido)
- **Isla:** de dónde viene

**CanonRef:** M53 (UI), M148 §4.2.

### 17.6 Sin UI fuera del diario/colecciones (M55/M73)

El lore **NO** tiene su propio panel de UI:
- Se lee en el **diario** (M22) o en las **colecciones** (M73/M55)
- No hay "menú de lore" separado (evita acoplamiento M53)
- Las piezas se "inspeccionan" en el mundo (M70) y se registran en el diario

**CanonRef:** M55 (Colecciones), M73 (Coleccionables), M53 (UI).

### 17.7 Accesible con gamepad (M57/M58)

El diario "Lore" se navega con gamepad:
- **D-pad/arrows:** scroll por entradas
- **A/X:** abrir texto completo
- **B/O:** cerrar
- **L2/R2:** cambiar filtro (nuevos/leídas/pistas)
- Compatible con M58 Reduce Motion (sin animaciones de scroll)

**CanonRef:** M57 (Gamepad), M58 (Accesibilidad).

---

## Sección 18-20: Rendimiento, descubrimiento, narrativa

### 18.1 Sin draw calls extras (solo triggers/colisiones)

Las piezas de lore **no son mallas nuevas**: son **triggers (Area3D)** sobre mallas existentes:
- El drago caído ya es una malla M50: el trigger es un Area3D invisible de 2m de radio.
- El pilón de 7 surcos ya es malla M167: el trigger es el mismo Area3D de interacción M70.
- **Cero mallas nuevas = cero draw calls extra.**

**CanonRef:** M61 (Rendimiento), M70 (Interacciones), M50 (Vegetación).

### 18.2 Memoria estable (SO referenciados, sin cargas duplicadas)

- El texto de lore se carga **una vez** al iniciar la isla (preload en M08/M50).
- El diario almacena **índices** (int) al texto, no copias (string).
- **Sin duplication:** si el jugador ve la pieza en el mundo Y en el diario, es el mismo texto (referencia, no copia).

**CanonRef:** M61 (Rendimiento), M53 (UI), M59 (Persistencia).

### 18.3 Triggers desactivados cuando ya explorados (bajo costo)

Al descubrir una pieza (primera vez):
- El trigger **se desactiva** (disabled) → no hace más raycasts/colisiones.
- Al cargar (M59): los triggers ya descubiertos **no se activan** (ahorro de CPU).
- Solo los triggers **no descubiertos** están activos en runtime.

**CanonRef:** M61 (Rendimiento), M59 (Persistencia), M70 (Interacciones).

### 18.4 Sin impacto en tiempos de carga (M63)

- El preload de lore (M18.2) es **paralelo** a la carga de la isla (M08/M63).
- **No bloquea** la carga: el jugador puede entrar al mundo antes de que el lore esté listo.
- Si el lore no está listo, el trigger NO muestra prompt (hasta que se cargue).

**CanonRef:** M63 (Streaming), M61 (Rendimiento).

### 19.1 Puente de descubrimiento por rumores (no lore invisible)

Regla: **ningún secreto de M148 es invisible**:
- Cada pieza tiene al menos **1 rumor** (M19/NPC) que la menciona.
- El rumor NO dice "está en el bosque de drago": dice "dicen que el árbol más viejo cayó la noche que el cielo se partió".
- El jugador **conecta** el rumor con la pieza (anti-spoiler + cozy: "descubrir" es parte del juego).

**CanonRef:** M19 (NPC), M148 §4-§15.

### 20.1 Revisión narrativa de todas las piezas contra M147

Antes de cerrar M148 (QA §21.8):
- [ ] Cada pieza tiene `CanonRef` válido (M147 §X existe)
- [ ] 0 contradicciones con M147 (la biblia)
- [ ] 0 spoilers de M22 (la historia principal)
- [ ] 0 duplicados de M66 (anti-softlock: cada pieza es única)
- **Si hay contradicción:** se corrige en M148, no en M147 (la biblia es inmutable).

**CanonRef:** M147 (Biblia), M22 (Historia), M66 (Anti-Softlock).

### 20.2 Cero contradicciones detectables con la biblia

Regla final: **M148 NO añade nueva mitología.** Solo "rellena" lo que M147 ya定义了:
- M147 dice "hay 4 sangres" → M148 define sus arquitecturas (4.1), vegetación (5.1), peces (12.2), minerales (14.2).
- M147 dice "el Sello se rompió" → M148 define **dónde y cómo** se ve (4.2, 5.3, 12.2, 14.2, 15.1).
- **Nada nuevo:** si M148 inventa un "quinto mito", **se rechaza** (debe estar en M147 primero).

**CanonRef:** M147 (Biblia, inmutable).
