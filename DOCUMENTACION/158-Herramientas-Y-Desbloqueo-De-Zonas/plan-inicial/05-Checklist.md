**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Modulo 158: Herramientas y Desbloqueo de Zonas

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del modulo (15)

- [ ] Definir el problema: progresion de herramientas por tier que desbloquee contenido sin copiar a Zelda [S]
- [ ] Registrar dependencias: M13, M38, M27, M28, M71, M22 [S]
- [ ] Definir 4 tiers: Madera(T1), Cobre(T2), Hierro(T3), Encantada(T4) [S]
- [ ] T1 se obtiene gratis en isla principal (auto-coleccion) [S]
- [ ] T2-T4 se forjan en islas distintas con profesional especializado [M]
- [ ] Forja requiere materiales + monedas [M]
- [ ] Precios progresivos por isla (+50% minimo entre islas) [M]
- [ ] Cursos de oficio por isla (carpinteria, herreria, encantamiento) [M]
- [ ] Cursos permiten vender herramientas en tienda del jugador [M]
- [ ] Historia principal requiere T4 para completarse [C]
- [ ] Progresion no lineal (jugador elige orden de islas) [M]
- [ ] Construccion en otras islas posible [M]
- [ ] NPCs visitantes compran herramientas 1x/dia [M]
- [ ] Premium permite comprar monedas por Steam [M]
- [ ] Checklist minimo 100 items verificables [S]

## B. Sistema de Tiers (12)

- [ ] Enum ToolTier definido (T1_MADERA, T2_COBRE, T3_HIERRO, T4_ENCANTADA) [S]
- [ ] ToolTierDefinition como Resource con propiedades por tier [M]
- [ ] T1: dano 1.0, velocidad 1.0, area 1x1 [S]
- [ ] T2: dano 2.0, velocidad 1.5, area 1x1 [S]
- [ ] T3: dano 3.5, velocidad 2.0, area 2x2 [S]
- [ ] T4: dano 5.0, velocidad 3.0, area 2x2 [S]
- [ ] Cada tier tiene color visual distintivo [S]
- [ ] Cada tier tiene sonido de uso diferenciado [S]
- [ ] Cada tier tiene particulas diferenciadas [S]
- [ ] La herramienta mejorada reemplaza visualmente a la anterior [M]
- [ ] ToolTierSystem como autoload central [M]
- [ ] Persistencia de tier maximo alcanzado por tipo de herramienta [M]

## C. Gates por Zona (15)

- [ ] ZoneGateDefinition como Resource (gate_id, required_tier, required_tool) [M]
- [ ] ZoneGate como Node3D con mesh visual por tipo [M]
- [ ] Gate tipo rama gruesa: requiere T1, hacha [S]
- [ ] Gate tipo muro de piedra: requiere T2, pico [S]
- [ ] Gate tipo raiz anciana: requiere T2, hacha [S]
- [ ] Gate tipo sello ancestral: requiere T3, pico [S]
- [ ] Gate tipo cristal bloqueado: requiere T4, encantada [S]
- [ ] Gate tipo tumba encantada: requiere T4, encantada [S]
- [ ] Verificacion de tier: can_access_zone() retorna bool [M]
- [ ] Feedback visual al no tener tier (brillo rojo suave) [S]
- [ ] Tooltip informativo cuando el jugador no tiene tier [S]
- [ ] Gate desaparece permanentemente al desbloquearlo [M]
- [ ] Se registra en PlayerToolProgress cada gate desbloqueado [M]
- [ ] Se emite signal gate_unlocked(zone_id) [S]
- [ ] Gates que bloquean historia marcados con blocks_story=true [M]

## D. Forja por Isla (15)

- [ ] ForgeRecipe como Resource (result_tool, result_tier, materials, coins) [M]
- [ ] Isla Principal: forja T1 gratis (auto-coleccion) [S]
- [ ] Isla 2: forja T2 con 10 cobre + 500 monedas [M]
- [ ] Isla 3: forja T3 con 20 hierro + 2000 monedas [M]
- [ ] Isla 4: forja T4 con 5 cristales + 5000 monedas [M]
- [ ] ForgeUI como Control con lista de recetas [M]
- [ ] ForgeUI muestra materiales necesarios y monedas [S]
- [ ] ForgeUI valida que el jugador tenga todo antes de forjar [M]
- [ ] Se consumen materiales y monedas al forjar [M]
- [ ] Se entrega herramienta al inventario [S]
- [ ] Se actualiza PlayerToolProgress [M]
- [ ] Se emite signal tool_forged(tier, tool_type) [S]
- [ ] Se registra en M71 (Progresion) el hito de tier [M]
- [ ] Animacion de forja (brillo, sonido, particulas) [M]
- [ ] Herrero NPC con dialogo contextual segun isla [M]

## E. Cursos de Oficio (12)

- [ ] CourseDefinition como Resource (course_id, profession, cost, required_tier) [M]
- [ ] Curso Carpinteria (Principal): 300 monedas, vende T1 [S]
- [ ] Curso Herreria (Isla 2): 1500 monedas, vende T1-T2 [S]
- [ ] Curso Herreria Avanzada (Isla 3): 5000 monedas, vende T1-T3 [S]
- [ ] Curso Encantamiento (Isla 4): 10000 monedas, vende T1-T4 [S]
- [ ] CourseUI como Control con info del curso [M]
- [ ] CourseUI valida tier requerido para tomar el curso [M]
- [ ] Se registran cursos aprendidos en PlayerToolProgress [M]
- [ ] Cursos desbloquean la opcion de vender herramientas [M]
- [ ] Cursos son unicos (no se pueden repetir) [S]
- [ ] Precio de venta de herramientas varia segun curso [M]
- [ ] Se emite signal course_completed(course_id) [S]

## F. NPCs Visitantes (12)

- [ ] ShopVisitorManager como autoload [M]
- [ ] 1 NPC por dia maximo como visitante [S]
- [ ] Pool de NPCs visitantes configurable [M]
- [ ] NPC visita la tienda del jugador [M]
- [ ] Compra 1-3 items del stock del jugador [M]
- [ ] Paga precio de venta de M38 [M]
- [ ] Prefiere items de la profesion del NPC [M]
- [ ] Si no hay tienda abierta, no vienen [S]
- [ ] NPC trae monedas propias (no infinito) [M]
- [ ] Se registra transaccion en log [S]
- [ ] Se emite signal visitor_sale(item, price) [S]
- [ ] Animacion de NPC llegando a la tienda [M]

## G. Fuentes de Ingreso (15)

- [ ] Jarrones: 10-15 por isla principal [S]
- [ ] Jarrones se reponen cada 7 dias (M29 calendario) [M]
- [ ] Contenido jarrones: 5-15 monedas cada uno [S]
- [ ] Maximo ~150 monedas/semana por jarrones [S]
- [ ] Peces dorados: 1-3 por dia en cuerpos de agua [S]
- [ ] Cada pez dorado: 1-5 monedas al vender [S]
- [ ] Arboles con frutos dorados: 2-5 por dia [S]
- [ ] Cada fruto: 2-8 monedas al vender [S]
- [ ] Puzzles: 50-200 monedas por puzzle resuelto [M]
- [ ] Total estimado puzzles: ~3000 monedas [S]
- [ ] JarSpawner como Node3D con logica de reposicion [M]
- [ ] GoldFishSpawner como Node3D [M]
- [ ] GoldTreeSpawner como Node3D [M]
- [ ] Integracion con GameClock para reposicion [M]
- [ ] UI de inventario muestra monedas actuales [S]

## H. Premium y Monetizacion (10)

- [ ] Paquete 500 monedas (.99) [S]
- [ ] Paquete 2000 monedas (.99) [S]
- [ ] Paquete 5000 monedas (.99) [S]
- [ ] PremiumManager autoload para compras [M]
- [ ] Integracion con Steam IAP [C]
- [ ] Monedas premium son identicas a monedas normales [S]
- [ ] No hay limite de compra premium [S]
- [ ] Premium NO compra herramientas directamente [S]
- [ ] Premium solo da monedas, jugador debe ir a islas [M]
- [ ] Log de compras premium para analytics [S]

## I. Integracion con Historia (10)

- [ ] Capitulo 1-2 requiere T2 para avance [M]
- [ ] Capitulo 3-4 requiere T3 para avance [M]
- [ ] Capitulo 5-6 requiere T4 para avance [M]
- [ ] Capitulo 7 (final) requiere T4 completo [M]
- [ ] Sellos de M22 verifican tier de herramienta [M]
- [ ] Templos verifican tier de herramienta [M]
- [ ] El jugador puede explorar sin completar historia [S]
- [ ] El jugador puede vivir en su pueblo sin avanzar [S]
- [ ] Progresion de historia visible en UI [M]
- [ ] Anti-softlock: nunca quedarse sin opcion de avance [M]

## J. Persistencia y Guardado (8)

- [ ] PlayerToolProgress serializado en GameState.M158 [M]
- [ ] Tiers maximos alcanzados persistidos [M]
- [ ] Cursos aprendidos persistidos [M]
- [ ] Gates desbloqueados persistidos [M]
- [ ] Conteo de forjas persistido [M]
- [ ] Ventas a NPCs visitantes persistidas [M]
- [ ] Estado de jarrones (ultima reposicion) persistido [M]
- [ ] Restauracion correcta tras guardar/cargar [M]

## K. Verificacion Final (8)

- [ ] El jugador obtiene T1 gratis en isla principal [S]
- [ ] El jugador puede viajar a isla 2 y forjar T2 [M]
- [ ] Cada isla subsiguiente tiene precios +50% minimo [M]
- [ ] Templos de historia no se completan sin T3/T4 [M]
- [ ] Jugador premium puede comprar monedas [M]
- [ ] Jarrones se reponen cada 7 dias del juego [M]
- [ ] NPCs visitantes compran 1x/dia [M]
- [ ] El jugador puede construir en otras islas [M]

## L. Documentacion y Cierre (8)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Tabla de tiers documentada [S]
- [ ] Tabla de costos por isla documentada [S]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 122 items · Completados: 0 · Pendientes: 122 · No resueltos: 0
