**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 141: Beta

## 1. Arquitectura general (sin cambios de arquitectura, solo cierre)
Beta **no introduce arquitectura nueva**: usa los managers de Alpha (HistoriaMaster, SelloManager, Almanaque, Croft, SaveManager v3) y agrega **capas de cierre**:

```
[Gameplay de Alpha (M140)]  ← estabilizado, solo fixes
        │
        ├── Cierre de Contenido   (ContentRegister: inventarios 100%)
        ├── Cierre de Historia    (Acto 3 + epílogo en HistoriaMaster)
        ├── Cierre de Audio       (MusicDirector por acto/zona)
        ├── Cierre de Localización(LocalizationManager M87)
        ├── Cierre de Accesibilidad (AccessibilityService M58)
        ├── Cierre de Plataforma  (PlatformBridge: logros, cloud, store, cert.)
        └── Cierre de Marketing   (StorePageData + Trailer, M149)
```

## 2. Flujos principales

### 2.1 Flujo de cierre de contenido (W1)
```
ContentRegister.VerificarInventario()  → lista maestra vs escena
   └─ ReporteGaps() → tickets en Cierre de Contenido
   └─ (gaps == 0) → FreeceDeContenido()
```
- `ContentRegister` (nuevo, M108-hard): tabla `itemId | recetaId | coleccionableId | eventoId | misiónId | zonaId` desde ScriptableObjects; herramienta de Editor para comprar el inventario contra las listas maestras (M73/M16/M36/M28/M23/M74).

### 2.2 Flujo de historia completa (W2)
```
HistoriaMaster.CompletarHistoria(Acto3)
   ├─ Acto3.Epílogo(ModoFaro)          → escena del faro post-Sello6
   ├─ 3 RutasDeSellos.Verificar()       → (M66) sin softlock
   └─ SinTextoPlaceholder.Verificar()   → búsqueda CI de strings TODO/placeholder
```

### 2.3 Flujo de audio al 100% (W1-W3)
- `MusicDirector` (M41): playlists por acto (Acto1/2/3) y por zona; transiciones por estado de Sello.
- `SFXSystem` (M42): enganchado a todas las interacciones finales; hitos de sellos con SFX heroicos.
- `AmbientSystem` (M43): biomas finales de las 6 islas; mezcla por estación.
- `DialogueVoice` (M44): voces en los hitos (EN principal + ES).

### 2.4 Localización (RF6, M87)
- `LocalizationManager` con un archivo por idioma: ES, EN, + 4 (PT, FR, DE, IT si M87 lo define).
- Flujo: Glosario centralizado → strings SO → export/import (CSV) → revisión humana → build.
- Subtítulos forzados para voces (accesibilidad).

### 2.5 Accesibilidad (RF7, M58)
- Remapeo de inputs completo (gamepad/teclado).
- Subtítulos configurables (tamaño, opacidad, fondo).
- Modos de color alternativos para puzzles (espejos, sombras, colores de biome).
- Reducción de efectos visuales y sacudidas; cámara con límite de zoom.
- Reduce Motion y Reduce Flashing aplican a pantallas de carga y transiciones.

### 2.6 Plataformas y certificación (RF10/RF13, M149)
- `PlatformBridge`: abstracción común de la API de plataforma (logros, cloud saves, DLC/índice, overlay).
- Perfil objetivo: **PC (Steam)**; consolas si el contrato M149 las define; cada plataforma con su checklist de certificación (build, saves, cloud, políticas).
- Cloud saves (M60): sincronización con mapa de conflictos; logros (M59) mapeados a hitos de historia/coleccionables.

### 2.7 Marketing y trailler (RF11/RF12, M149)
- `StorePageData` (ScriptableObject): textos, capturas referenciadas, tags, requisitos mínimos/recomendados, caja de puntuación.
- Trailer: secuencia de 90s grabada en build W6 (captura real) + variante 15s.

### 2.8 Cierre de los 3 `[?]` de contenido (cerrado 2026-10-14, step-5-kilocode)

Cierra los 3 `[?]` que el QA de s2 (Log 1791) había marcado como "concepto sin definición".
Uno de ellos era un **falso negativo del QA**: el sistema de créditos sí existe.

**Coleccionables localizables sin guía (definido):** cada coleccionable del catálogo
(`data/coleccionables/catalog.json`, 15 ítems hoy) recibe una **pista de diario** que se activa al
descubrir la isla o zona donde aparece. La pista es textual y ambiguada a propósito ("algo brilla
donde la marea deja sus cosas"), nunca coordenadas. El diario (M55, verificado: `test_diario.gd`,
`test_diario_persist.gd`, `test_diario_ui.gd`) es el único contenedor de pistas; no hay marcadores
de mapa. Para Beta el objetivo es 80/80 localizables sin guía externa.

**Evento de cierre: festival con todos los NPC (definido):** tras el último sello de Beta se dispara
el **Festival de la Brisa** usando el motor de eventos existente (`event_manager.gd`,
`event_definition.gd`, `contexto_festival.gd`). Todos los NPC del elenco (los 8 de M139 más los de
Beta) convergen a la plaza de Aurora con rutina excepcional; el evento dura un ciclo de día
completo y es la antesala de los créditos. No introduce lógica nueva de eventos: es una instancia
del motor M74.

**Créditos de cierre con equipo (PROMOVIDO con cita — era falso negativo del QA):** el sistema
existe y es data-driven — `scripts/legal/credits_manager.gd` (autoload de M131, 12 KB) que carga
`data/legal/creditos.json` (7 entradas: secciones/políticas/idiomas/version) y expone API para la
UI (M53) con conmutación de idioma. El QA de s2 reportó "grep 0 hits fuera de checklist/spec" porque
el archivo vive en `scripts/legal/`, no en una ruta obvia. Para Beta solo hay que completar las
secciones del JSON con el equipo real.

## 3. Contenido final (objetivos de inventario)
| Frente | Objetivo Beta |
|--------|---------------|
| Islas (M50) | 6/6 finales |
| Templos (M24/M26) | 6/6 resueltos con puzzles finales |
| Sellos (M22) | 6/6 + Acto 3 + epílogo |
| NPC con cadenas (M23/M20) | 30+ (todos con rutinas y regalos) |
| Misiones secundarias | 45+ finitas |
| Coleccionables (M73) | 100/100 |
| Recetas (M16) | 90+ |
| Eventos estacionales (M74) | 8+ (4 anuales × 2 temporadas por ciclo) |
| Artefactos (M13) | 6 pasivos + 1 oculto |
| ítems únicos (M66) | todos con anti-softlock |
| Audio | música por acto/zona, SFX ambiental por bioma, 6-8 voces de hitos |

## 4. Hitos de cierre (Beta)
| Hito | Semana | Criterio |
|------|--------|----------|
| G1 | W1 | Freeze de features/contenido firmado; inventarios 100% |
| G2 | W2 | Historia completa sin placeholder; 3 rutas verificadas |
| G3 | W3 | Puzzles finales, balance, rendimiento en presupuesto |
| G4 | W4 | Cero P0/P1; cloud saves y logros en plataforma |
| G5 | W5 | Store page + tráiler + requisitos aprobados |
| G6 | W6 | Certificación checklist completa; candidato RC congelado |

## 5. Plan de semanas W1-W6
| Semana | Actividades clave |
|--------|-------------------|
| W1 | Inventarios (ContentRegister), freeze contenido, audio 100%, 6 islas finales |
| W2 | Acto 3 + epílogo, 3 rutas, localización arranque, accesibilidad 100% |
| W3 | Puzzles finales, balance final, rendimiento objetivo (informe M61) |
| W4 | QA intensivo hasta cero P0/P1, cloud/logros, build de estabilización |
| W5 | Store page, tráiler 90s, material de prensa, requisitos |
| W6 | Checklist certificación, build final, candidato RC, acta de cierre |

## 6. Qué NO se hace en Beta
- No features nuevas (freeze en G1).
- No cambios de arquitectura (solo capas de cierre y fixes).
- No rebalanceo estructural (solo tuning fino M93).
- No expansión de contenido más allá del inventario aprobado.