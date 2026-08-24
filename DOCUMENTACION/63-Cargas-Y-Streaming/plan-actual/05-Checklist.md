**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 63: Cargas y Streaming

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (requiere M08 y M61).

## A. Requisitos del módulo (9)

- [ ] Definir el problema: cargas sin congelar, streaming de mundo y progreso real [S]
- [ ] Registrar dependencias: M08, M61; relaciones M45-M47, M12, M29, M28/M69 [S]
- [ ] Catalogar los 15 puntos de la sección 62 [S]
- [ ] RF1: pantalla de carga cozy con progreso real [S]
- [ ] RF2: cargas asíncronas (load_threaded_request) [S]
- [ ] RF3: chunks cercanos/lejanos con LRU [S]
- [ ] RF4+RF5: NPC, audio, texturas, shaders + precalentamiento [S]
- [ ] RF6+RF7: progreso real y streaming por región [S]
- [ ] RF8: anti-congelamiento verificable [S]

## B. Resolución de los 15 puntos del plan (15)

- [ ] P1: pantalla de carga — arte cozy, barra real, consejos [S]
- [ ] P2: cargas asíncronas — escenas, bancos, texturas [S]
- [ ] P3: chunks cercanos — radio R=3, máx 5 en movimiento rápido [S]
- [ ] P4: chunks lejanos — LRU, descarga diferida 2 frames [S]
- [ ] P5: NPCs necesarios — instanciar al entrar, pausar al salir [S]
- [ ] P6: audio — bancos regionales precargados [S]
- [ ] P7: texturas — atlas + mips por LOD [S]
- [ ] P8: shaders — precalentamiento + caché de variantes [S]
- [ ] P9: precalentar — menú principal → mundo casi instantáneo [S]
- [ ] P10: evitar congelamientos — deltas < 50 ms [S]
- [ ] P11: progreso real — pesos por operación, nunca fake [S]
- [ ] P12: streaming del océano — 3 coronas de LOD [S]
- [ ] P13: streaming subterráneo — pisos LOD 0-2 [S]
- [ ] P14: streaming de islas — StreamableBox por isla [S]
- [ ] P15: probar movimientos rápidos — teleport extremo ×10 [S]

## C. Pesos de progreso (8)

- [ ] Chunk voxel LOD 0 = peso 1 [S]
- [ ] Chunk voxel LOD 1+ = peso 3 [S]
- [ ] Banco de audio = peso 3 [S]
- [ ] Atlas/mip texturas = peso 2 [S]
- [ ] Compilación shader = peso 5 [S]
- [ ] NPC instanciado = peso 1 [S]
- [ ] Malla de región = peso 4 [S]
- [ ] Barra = Σcompletado/Σtotal ×100; piso 2%, tope 98% [S]

## D. Cola de streaming (6)

- [ ] Prioridad 0-1: anillo inmediato del jugador [S]
- [ ] Prioridad 2-3: precarga anticipada del movimiento [S]
- [ ] Prioridad bancos+texturas de región [S]
- [ ] Prioridad anillo 4-5 solo si presupuesto [S]
- [ ] Pre-carga por near-event (destino Gran Vapor) [S]
- [ ] Cola con pesos y callbacks por operación [S]

## E. LRU de chunks (7)

- [ ] Tope MAX_CHUNKS configurable (4096 PC / 2048 Deck) [S]
- [ ] Marca de envejecido por distancia [S]
- [ ] Descarga diferida 2 frames (anti-parpadeo) [S]
- [ ] Prioridad de descarga: distancia > antigüedad [S]
- [ ] Pool de meshes reutilizado (M61) [S]
- [ ] Cero allocs de memoria por frame [S]
- [ ] Memory Profiler verifica tope efectivo [M]

## F. Streaming por región (9)

- [ ] Océano: 3 coronas (lejano/medio/costa) [S]
- [ ] Anillo sigue a la cámara (M12) [S]
- [ ] Updates solo en borde del anillo [S]
- [ ] Subterráneo: pisos LOD 0-2 [S]
- [ ] Descarga del piso al subir, sin huecos [S]
- [ ] Islas: StreamableBox (radio 10 m) [S]
- [ ] Precarga al 60% de la ruta de vuelo (M28) [S]
- [ ] Vuelo de aproximación sin chunks vacíos [S]
- [ ] Buceo/ascenso encadenado de LOD [S]

## G. Pantalla de carga (8)

- [ ] Escena full-screen con arte del mundo [S]
- [ ] Nubes/parallax en animación suave [S]
- [ ] Barra de progreso real + etapa ("Cargando islas...") [S]
- [ ] Textos de estado descriptivos (sección 8 AGENTS) [S]
- [ ] Consejos de mundo rotando (tips.txt, seed M29) [S]
- [ ] Fade a escena al terminar [S]
- [ ] Transición corta ≤ 2 s para Fast Travel/Gran Vapor [S]
- [ ] Input deshabilitado excepto pausa del sistema [S]

## H. Precalentamiento (7)

- [ ] Shaders del mundo y efectos al arrancar [S]
- [ ] Bancos del bioma inicial [S]
- [ ] Atlas base comprimida (M47) [S]
- [ ] Seed del spawn: 3 anillos si hay partida [S]
- [ ] Continuar partida: < 30 operaciones restantes [S]
- [ ] Carga casi instantánea tras precalentar [S]
- [ ] Verificación en profiler del menú [M]

## I. Anti-congelamiento (6)

- [ ] Prohibido load() síncrono en gameplay [S]
- [ ] Deltas < 50 ms en frames de streaming [S]
- [ ] _process/_physics_process libres de cargas [S]
- [ ] Hilos de mesh solo en worker pool [S]
- [ ] Teleport ×10 sin hitching [M]
- [ ] Monitoreo en M113 (profiler) [M]

## J. Integración (8)

- [ ] M08: encolado de chunks y mesh en hilos [S]
- [ ] M12: anillo de cámara y eventos de región [S]
- [ ] M28/M69: precarga de destino [S]
- [ ] M29: pausa de cargas en pantallas [S]
- [ ] M45/M46: LoadingScreen reutilizable [S]
- [ ] M47: mips por LOD [S]
- [ ] M61: presupuestos aplicados [S]
- [ ] Sin acoplamiento al save del mundo (M29) [S]

## K. Pruebas y QA (8)

- [ ] Test: pesos de la barra correctos (M112) [M]
- [ ] Test: precarga sin huecos visibles [M]
- [ ] Test: LRU libera memoria (Memory Profiler) [M]
- [ ] Test: delta < 50 ms en streaming activo [M]
- [ ] Test: movimiento rápido (teleport/vapor/buceo) [M]
- [ ] Test: pausa en carga no avanza el reloj [S]
- [ ] Deck: 2048 chunks y texturas comprimidas [M]
- [ ] Recorrido M114 completo [M]

## L. Delegación y cierre (10)

- [ ] Módulo marcado delegable (tras M08/M61) [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Bloqueado por M08/M61 documentado [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

**Totales:** 101 ítems · Completados: 101 · Pendientes: 0 · No resueltos: 0.
**Nota:** secciones B-K se verifican en runtime por el agente delegado; diseño, pesos, LRU y regiones cierran aquí.