**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 139: Pre-Alpha

## 1. Arquitectura de la fase

### 1.1 Capas (desacople M07)

- **[UI Layer]** Menú (M53) · HUD · Diario (M55) · Diálogos (M21) · Tutorial visual (M92).
- **[Gameplay Managers]** `SesionMaster` (flujo de fase) · `ZonaManager` · `ViajeManager` · `ConstruccionManager` · `TiendaManager` · `NPCManager` · `TemploManager`.
- **[World Services]** `MundoVoxel` (M08) · `BiomaManager` (M27) · `StreamingZonas` (M63) · `GuardadoV3` (M59/M60) · `AudioManager` (M41-M44) · `MetricsHub` (M104/M105).
- **[Infra]** Godot 4 + Voxel Tools (M08) · Pipeline M108 · CI (M118): compila + simulación económica M93.

Los managers NO tocan UI; la UI consume servicios expuestos. Contratos por interfaces (`IInteractable`, `ITienda`, `ITemplo`, `IViajable`).

### 1.2 Flujo de sesión

```
Menú principal (M53)
 ├─ Continuar → integridad del save v3 (M66) → carga de última zona
 ├─ Nuevo juego → intro canónica (sin spoiler de Sellos, M153) → Aurora (puerto)
 ├─ Ajustes → gráficos/audio/controles/accesibilidad (M90/M91/M57/M58)
 └─ Créditos (M131)
En mundo: ZonaManager controla carga/streaming (M63); ViajeManager intercepta el muelle (M28)
con el Gran Vapor (M67/M68) y cutscene corta de travesía.
```

### 1.3 Bucle de juego (Aurora)

- **Día** (25 min reales, M31): hablar con NPC (M19/M64) → recolectar/cultivar/pescar (M15/M33/M34) → vender/craftear (M38/M16) → construir (M17) → templo (M26) → viaje (M28).
- **Noche**: eventos suaves (M74), descanso en cama (M11/M18).
- **Reloj (M30) + calendario (M29)** disparan rutinas de NPC y ciclos de tienda.

## 2. Diseño del mundo Pre-Alpha

### 2.1 Aurora (primer bioma completo)

| Sector | Contenido | Módulos |
|---|---|---|
| Costa Este (puerto) | Muelle, Gran Vapor atracado, mercado de pescado | M28/M67/M19 |
| Pradera central | Pueblo: talleres, tienda Tía Rúa, plaza, casas 2-3 | M18/M39 |
| Bosque Oeste | Recursos (maderas, frutas), mina ligera, campamento | M15/M35/M50 |
| Colina Norte | Templo de Brisa + subida con 2 puzzles ambientales | M26/M24 |
| Acantilados Sur | Faro en ruinas (misterio visible M153), Kor vigilando | M153/M19 |

- Área ~2 km² navegables en **6 zonas de streaming** (M63) con presupuesto de memoria (M62).
- Vegetación (M50): palmeras, bambú, hibiscos, pasto alto; flora transmisora de estado (M09).
- Agua (M51): litoral con ondas suaves; pesca (M34) cerca de costa.

### 2.2 Enclave de Coral (núcleo del 2º bioma, visitable no construido)

- Muelle, 1 NPC, tienda única (arrecife glasswork), vista al océano como anzuelo de curiosidad (M152/M153).
- Se deja "inacabado a propósito" con hit explícito para Alpha (M140).

### 2.3 Elenco NPC (6-10, M19/M64)

| NPC | Rol | Rutina | Gancho |
|---|---|---|---|
| Finneas | Vecino principal (del slice M138) | Taller → plaza → faro | Ciclo de misión intro (M22/M23) |
| Maribel | Pescadora | Muelle → mercado | Compra pescado +15% al entardecer |
| Obé | Artesano | Taller → mina | Desbloquea piezas de construcción (M17) |
| Tía Rúa | Tiendera | Tienda 08:00-20:00 (M39) | Tienda AO: semillas, herramientas, deco |
| Pax | Niño explorador | Rutina libre bosque/playa | Coleccionables escondidos (M73) |
| Kor | Vigía | Acantilado S (bucle fijo) | Misterio del faro (M153) |
| Cole | (Banco miniatura) | Oficina 2 h al día | Depósito de AO con interés leve (M38) |

- Diálogos: 10+ líneas por NPC (M21), con variantes por estación/día (M29).
- IA: máquina de estados + waypoints con tolerancia (M64); anti-stuck con teleport (M66).

### 2.4 Templo de Brisa (M26/M24/M13)

```
Subida: 2 puzzles ambientales (rompecorrientes de viento)
Sala 1 "Las Velas":   3 velas; ordenarlas usando ráfagas de viento (M42 feedback)
Sala 2 "El Carillón": 5 campanas; imitar una melodía suave (memorización con feedback ASMR M44)
Recompensa: Herramienta del Viento (M13) → desbloquea viento para los puzzles ambientales; lore canónico
            del Templo (flechas, símbolos M147) SIN spoiler de otros templos (M153)
```

- Normas de templo (canon M26): 2 salas, 1 herramienta, 1 pieza de lore, dificultad progresiva con
  hint no intrusivo (M58/M66: sin softlocks, hints por formato de acceso).

### 2.5 Economía Pre-Alpha (M38/M39/M93)

- Moneda AO. Dos tiendas en Aurora (Tía Rúa + mercado de Maribel) + 1 en Coral.
- Precios según curvas M93 (lineal en rutina, logarítmica en metas largas); márgenes de venta 55-70%.
- Simulación en CI (M118): detecta grind/exploit (M93) y falla el build si el jugador más productivo
  rompe la curva en < 30 h de juego simuladas.
- Bancolocal de Cole: depósito con interés 0.5% diario (M38), techo para evitar inflación.

### 2.6 Construcción (M17/M16/M18)

- Catálogo de 30+ piezas: vallas, caminos, mobiliario, decoración y 3 estructuras (casa de campo, invernadero pequeño, gazebo).
- Colocación por grid ligero (sin física), validada contra terreno voxel y colisiones (M08/M09).
- Desbloqueo: Obé entrega piezas según progreso de amistad (M20) y misiones (M23).
- Todas las piezas se persisten en save v3.

### 2.7 Guardado v3 (M59/M60)

```
manifest.json  → versión de schema, checksums de particiones, última zona
zona_<id>.dat  → estado de la zona (NPC, inventario, tiendas, cámara, hora)
voxel_<id>.dat → delta de chunks editados (M60)
meta.json      → opciones, stats de sesión, flags de progresión global
```

- Escritura: transaccional (temp + rename), doble copia; carga < 2 s en 20/20 ciclos (M66 valida integridad).

### 2.8 Audio global (M41-M44)

- Buses: `Music`, `Ambient`, `SFX`, `ASMR`, `UI` (M41-M44) con transiciones por zona/clima (M32).
- Música adaptativa por estado (día/noche M31, lluvia M32, templo M26).
- Eventos 2D/3D por pool (M44).

## 3. Pipeline de assets (M108) — gate de calidad

```
Modelo/escena fuente → import normalizado (nombres, unidades) → materiales/texturas comprimidas
→ prefab/prefab_variante en biblioteca (M108) → validación automática (LOD, collision, bounds, frame budget M61)
→ integración en zona → playtest corto (M114) → commit
```

- El 100% de los assets del Pre-Alpha pasa por el pipeline (sin atajos); la CI falla si un asset no cumple presupuestos.

## 4. Métricas y telemetría (M104/M105)

- Métricas de fase: FPS/p99, memoria (M62), tiempos de carga por zona (M63), distancia de stream, sesiones completadas, horas hasta fin de contenido, uso de cada sistema (tienda, construcción, templo, viaje).
- Dashboards locales para playtests (M114); sin envío remoto en esta fase.

## 5. Hits de Pre-Alpha → Alpha (M140)

| Hit | Criterio de salida |
|---|---|
| H1 | Aurora completa navegable con los 6 sectores y GONOGO pasado |
| H2 | Elenco NPC completo con rutinas y diálogos validados |
| H3 | Templo de Brisa jugable de punta a punta sin guiones |
| H4 | Gran Vapor ida/vuelta a Coral operativo |
| H5 | Economía con AO, 2 tiendas y ciclo de venta estable en CI |
| H6 | Construcción con 30 piezas y persistencia perfecta |
| H7 | Save v3 con integridad (20/20) y menú completo |
| H8 | Audio global por buses y transiciones OK |
| H9 | Pipeline M108 cumplido al 100% y métricas de fase OK |
| H10 | Playtest 2-4 h con ≥ 5 testers y ≥ 80% "quería seguir" |

Se aprueba Alpha (M140) solo cuando H1-H10 estén todos cumplidos y documentados (DoD, sección 12 AGENTS.md).