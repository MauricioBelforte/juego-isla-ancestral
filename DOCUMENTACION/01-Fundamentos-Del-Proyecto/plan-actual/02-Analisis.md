# 02-Analisis.md — ANALISIS DEL PROYECTO Y DECISIONES DE DISEÑO

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Componente:** 01-Fundamentos-Del-Proyecto
**Estado:** Documentación inicial (plan genérico)

---

## 1. Análisis del Dominio

### 1.1 Género y Referencias

El juego fusiona tres géneros con referencias claras:

| Sistema | Referencia | Qué tomar |
|---------|-----------|-----------|
| Mundo voxel modificable | Minecraft / Dinkum | Terreno de bloques 1×1×1 m, extracción y colocación libre |
| Vida comunitaria cozy | Stardew Valley / Animal Crossing | Economía, vecinos, afecto, tareas diarias, ASMR |
| Puzzles y templos | Zelda (BOTW/TOTK) | Templo con herramienta única, puzzles ambientales lógicos |
| Viajes entre islas | Genshin / Pokémon | Biomas diferenciados con islas temáticas |
| Capa oceánica (post-v1.0) | Subnautica | Profundidad, buceo, exploración submarina |

### 1.2 Competencia (2026)

- Más de 100 juegos cozy activos o por salir en Steam. El género está saturado.
- Competidores directos: Fields of Mistria, Roots of Pacha, Coral Island, My Time at Portia/Sandrock, Dinkum.
- **Diferenciador real del proyecto:** narrativa profunda y coherente (Arquitectos del Alba, Resonancia, 6 Sellos) + templos con mecánica única + construcción voxel con consecuencias narrativas. La narrativa es el activo más fuerte.

### 1.3 Análisis del Alcance (diagnóstico honesto)

| Sistema | Complejidad real |
|---------|------------------|
| Terreno voxel modificable en tiempo real | Motor propio: chunking, meshing, streaming, persistencia |
| Simulador de vida (economía, afecto, tareas) | Sistemas de progresión y balance profundos |
| 6 templos con mecánica única cada uno | El diseño de nivel más caro de producir por hora |
| 6+ islas diferenciadas en arte y NPCs | Multiplica el costo de arte por isla |
| Capa oceánica completa (buceo, submarino) | Un sub-juego en sí mismo (post-v1.0) |
| 4 finales + post-final | Rutas narrativas divergentes (post-v1.0) |

**Conclusión:** el alcance completo es de varios juegos. La estrategia es **v1.0 acotada + roadmap público post-lanzamiento** (estructura que la propia narrativa ya soporta con el Gran Vapor mensual).

---

## 2. Decisiones de Diseño (Análisis de Alternativas)

### 2.1 Elección del Motor — Unity vs Godot

| Criterio | Unity | Godot 4.x |
|----------|-------|-----------|
| Costo | Gratis hasta USD 200K anuales; luego ~USD 2.300/asiento | Gratis siempre (licencia MIT) |
| Voxel nativo | No trae nada; integración de terceros o desde cero | **Voxel Tools (Zylann)** — módulo C++ con terreno editable, colisiones, streaming y LOD Transvoxel |
| Animación de personajes | Mecanim/Timeline, más maduro | Mejoró pero ecosistema más chico |
| Asset Store | Enorme | Más chico, en crecimiento |
| Talento freelance | Mucho más grande | Menor pero motivado |
| MCP / IA | MCP oficial (Unity AI, beta) + Unity MCP comunitario (12.7K estrellas) | GDAI MCP, godot-mcp, Fennara MCP — sólidos, no oficiales |

**DECISIÓN PRELIMINAR:** **Godot 4.x es la opción más defendible por defecto** (costo cero + módulo voxel maduro que resuelve el problema técnico más difícil). **Unity queda recomendado si** hay presupuesto para freelancers de animación, se prioriza ecosistema, o hay experiencia previa fuerte. → **Decisión abierta, se cierra en el prototipo de preproducción.**

### 2.2 Arquitectura del Sistema Voxel (independiente del motor)

1. **Chunking:** mundo dividido en chunks (16³ o 32³ voxels). Nunca procesar el mundo entero.
2. **Mesh culling / face culling:** renderizar solo caras visibles — requisito explícito del GDD, sin esto no hay 60 FPS.
3. **Greedy meshing (evaluar):** combinar caras coplanares adyacentes del mismo bloque.
4. **Threading:** generación y remallado de chunks en hilos secundarios; prohibido bloquear el hilo principal.
5. **LOD:** chunks lejanos con menos detalle (crítico en islas grandes y océano).
6. **Persistencia por diffs:** guardar solo bloques modificados por chunk (nunca el mundo entero); serialización incremental.
7. **Colisiones por raycast a la grilla:** las herramientas apuntan a la grilla de voxels, no a la malla renderizada.
8. **Streaming entre islas:** escenas separadas con pantalla de carga diegética (barco navegando = carga con diégesis). Más simple y más fácil de optimizar que un mundo continuo.

### 2.3 Framework de Puzzles — "Emisor → Receptor"

**Decisión clave:** no programar 6 mecánicas de puzzle separadas. Construir un **framework genérico de señales**:

- Cualquier objeto **emite** una señal (luz, presión, agua, viento, semilla).
- Cualquier objeto **receptor** recibe la señal y dispara una acción (abrir puerta, mover plataforma, activar faro).
- La Red de Luz y las Placas de Presión son **el mismo sistema con distinto flavor visual**.
- Las herramientas del jugador (Gancho, Lanza-Semillas, Vara de Flujo) son inputs que activan receptores específicos.
- Cada templo = componer piezas existentes con skin temática distinta. Esto hace viable 6 templos.

### 2.4 Arquitectura de Código

- Separación estricta: gameplay / IA / voxel / I/O separados de la capa UI.
- UI solo llama a managers/servicios expuestos (ScriptableObject architecture o service locator).
- Composición sobre herencia profunda; interfaces (`IInteractable`, `IDamageable`, `ISignalEmitter`, `ISignalReceiver`) como contratos.
- Eventos/observer para el reloj central (día/noche, estación, clima) que otros sistemas escuchan.
- Un único **GameState serializable y versionado desde el día uno** (guardado completo: inventario, moneda, relaciones, historia, cultivos, fecha, islas desbloqueadas).

### 2.5 Sistema de Diálogo

- NO escribir diálogo en código. Usar editor visual (sistema de nodos de Godot / Yarn Spinner o Ink en Unity).
- Sistema de **flags narrativos** consultable desde diálogo (Sellos, grabaciones, afecto por NPC, estado del mundo) para reacciones coherentes.
- **Localización desde el día uno:** tablas de claves, nunca strings sueltos.

### 2.6 Guardado — GameState Versionado

- Formato: binario o JSON con versión de schema.
- Versionado desde el día uno + migraciones por versión.
- Copias de seguridad automáticas; detección de corrupción; recuperación de backup.
- Pruebas exhaustivas: cierre a mitad de modificación de terreno, cambio de isla, saves viejos tras actualización.

### 2.7 Audio

- Música acústica/lo-fi por bioma e isla (identidad sonora propia de cada una).
- **Middleware:** FMOD o Wwise (gratis bajo umbral de presupuesto) o audio nativo del motor si el equipo es chico.
- SFX ASMR: más sobre timing y capas de sonido que sobre calidad de grabación.

### 2.8 UI/UX y Accesibilidad

- Menús con identidad pastel propia (un juego cozy vive o muere por sus menús).
- Accesibilidad temprana: modo daltónico (crítico en puzzles de luz/color), remapeo completo de controles, mando obligatorio (Steam Deck), tamaño de texto ajustable, subtítulos.

### 2.9 Desarrollo Asistido por IA (MCP)

- **Sí delegar:** prototipado/blockout de niveles, iteración de variantes procedurales, dressing de escena, QA visual con capturas, **toda la lógica de gameplay en código**, documentación técnica.
- **NO delegar:** dirección de arte distintiva, animación de personajes con carácter, balance/feel final, narrativa central (mano autoral del usuario).
- **Steam:** herramientas de eficiencia exentas de declaración; contenido IA que llega al jugador debe declararse.

### 2.10 Economía de Juego

- Doble moneda: **Gemas de Ámbar** (principal, venta de bienes) y **Pases de Mérito** (tareas diarias). Dos wallets separadas con reglas propias.
- Sumideros de moneda: mejoras de infraestructura (Finneas), boletos de expedición, muebles.
- Balance modelado en hoja de cálculo antes de tocar el motor.

---

## 3. Decisiones Pendientes (Open Questions)

| # | Pregunta | Impacto | Se resuelve en |
|---|----------|---------|----------------|
| 1 | ¿Unity o Godot 4.x? | Arquitectura, voxel, contratación | Módulo 03 (Game Engine) / prototipo |
| 2 | ¿Middlelware de audio (FMOD/Wwise) o nativo? | Audio adaptativo | Módulo 40 (Música) |
| 3 | ¿Early Access o lanzamiento directo 1.0? | Roadmap y financiamiento | Módulo 135 (Roadmap) |
| 4 | ¿Juego base + DLC de islas o contenido gratuito? | Modelo de negocio | Módulo 94 (Monetización) |
| 5 | ¿Multijugador (local/online) o solo? | Arquitectura de red | Módulo 75 (Multijugador) |
| 6 | ¿Reloj interno o tiempo real para el Gran Vapor? | Exploits, eventos mensuales | Módulo 29 (Reloj en tiempo real) |
| 7 | ¿Fotografía y compartir imágenes? | UGC, privacidad | Módulo 55 (Fotografía) |

---

## 4. Comparación con Proyectos Reales (calibración de esfuerzo)

| Juego | Equipo | Tiempo | Lección |
|-------|--------|--------|---------|
| Stardew Valley | 1 persona + ayuda para ports | ~4.5 años | Loop diario + economía + afecto balanceados |
| Dinkum | 1 persona / equipo chico | EA desde 2022 | Isla + construcción + roadmap EA |
| My Time at Portia/Sandrock | 30-50 personas | 3-4 años por título | Vida + crafting + mazmorras integrados |
| Zelda BOTW/TOTK | Cientos de personas | 4-6 años | Vara de calidad de puzzles con herramienta única (no comparable de tamaño) |
| Subnautica | ~30 personas | EA multi-año | Capa oceánica por biomas de profundidad |

---

## 5. Estructura Modular — Los 152 Módulos

El `Plan-inicial-minimo.md` define **152 módulos** de planificación (visión, técnica, arte, audio, narrativa, legal, QA, publicación, marketing). Cada módulo será convertido en un componente `DOCUMENTACION/{NN}-Modulo/` con su propia carpeta `plan-inicial/` y `plan-actual/`, cada una con checklist de **no menos de 100 ítems** (ver `05-Checklist.md` de este componente para el listado completo).

**Estrategia de desglose:**

1. Este componente (01) define la base: decisiones, arquitectura y mapa de módulos.
2. Cada módulo individual se desarrolla siguiendo el flujo Documentation-First del `AGENTS.md` (sección 13).
3. El progreso global se controla en `CHECKLIST-GLOBAL.md` (1 fila por módulo).
4. Los módulos de mayor riesgo técnico (07 Mundo Voxel, 58 Guardado, 63 IA de NPC, 60 Rendimiento) se priorizan en la fase de prototipo.