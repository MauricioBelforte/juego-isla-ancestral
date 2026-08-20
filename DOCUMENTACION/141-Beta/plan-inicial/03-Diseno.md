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