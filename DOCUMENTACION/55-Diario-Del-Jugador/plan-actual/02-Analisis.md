**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 55: Diario del Jugador

## 1. Análisis del Dominio

El dominio del diario del jugador de Aurora se descompone en siete subsistemas:

### 1.1 Registro de contenido (fuente de datos)
- **Dominio:** 14 categorías del plan maestro (sección 54) alimentadas por los sistemas de juego: NPC (M19), lugares (M09/M10/M54), criaturas (M36/M65), plantas (M50/M33), minerales (M35), recetas (M16), pistas (M24/M26), Sellos (M22/M26), ruinas (M25), cartas (M74), descubrimientos (M71), misiones (M22/M23), eventos (M74), fotografías (M56).
- **Clave:** el diario NO consulta cada sistema en vivo: los sistemas emiten eventos de registro → `DiaryService` guarda entradas compactas (id, título, descripción, icono, estado, tags).

### 1.2 Modelo de datos
- **Dominio:** cada entrada: `id, categoría, título (clave i18n M87), descripción (clave i18n), icono (M46), estado (no_visto → visto → completado), tags, favorito, secreto, refs (lugar/POI/foto)`.
- **Persistencia:** el diario se serializa en GameState (M59/M60) como una lista versionada; migraciones por campo `schema_version`.

### 1.3 UI y navegación
- **Dominio:** pantalla principal con pestañas por categoría; cada categoría es una lista con entradas; detalle con descripción, icono, estado y acciones (favorito, releer pista, ir a foto).
- **Navegación:** 2 clics a cualquier entrada (pestaña → entrada); atajos por pestaña; búsqueda con filtro por texto localizado.
- **Clave (M53):** el diario es un módulo de UI de M53 con su propio estilo; reduce texto denso (cozy).

### 1.4 Completado y logros
- **Dominio:** % por categoría = entradas completadas / total de esa categoría; % global ponderado. El diario informa a M72 (logros de colección) con el total real de entradas.
- **Clave:** el total por categoría es un dato estático del catálogo (no cambia); el jugador nunca ve entradas no descubiertas, pero el % no revela el total oculto (anti-spoiler: se muestra % de lo DESCUBIERTO, ver RF17/2.5).

### 1.5 Anti-spoilers (regla de oro)
- **Dominio:** la regla del módulo: una entrada no descubierta NO existe visualmente. Nada atenuado, nada "???" salvo contenido secreto intencional (lore).
- **Contenido secreto:** categorías/entradas con flag `secreta` que se desbloquean por acción (Sello oculto, lugar oculto); se muestran "???/Bloqueado" SOLO donde el diseño lo permite (lore), nunca en colecciones estándar.
- **Clave:** el % de completado se calcula sobre el total DESCUBIERTO (para no revelar cantidad de lo oculto); el logro (M72) sí usa el total real.

### 1.6 Pistas y misiones (ayuda al jugador)
- **Dominio:** las pistas (M24/M26) se guardan al leerse y son releíbles (resuelto/no); las misiones (M22/M23) se muestran con objetivo y progreso; nunca se da la solución en el diario (solo releer lo visto).
- **Clave:** el diario es apoyo, no guía: no muestra pasos no descubiertos.

### 1.7 Validación y rendimiento
- **Dominio:** `validate_diary.gd` verifica: mapeo de eventos → entradas, claves i18n existentes (M87), persistencia (M60) y carga perezosa (LazyLoad de listas largas; M61).
- **Clave:** el diario con 500+ entradas debe abrir en < 100 ms (solo visible + virtualización).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Consulta en vivo a cada sistema | **Descartado** | Acoplamiento y costo; eventos de registro desacoplan |
| Mostrar entradas no descubiertas atenuadas | **Descartado** | Anti-spoiler: invisibles |
| % sobre total real en la UI | **Descartado** | Revela el conteo oculto; % sobre descubierto |
| Persistencia duplicada en el diario | **Descartado** | GameState central (M59/M60) |
| Diario como HTML/webview | **Descartado** | UI nativa de Godot (M53) |
| Sin virtualización | **Descartado** | 500+ entradas → lag; LazyLoad obligatorio |

## 3. Decisiones del Módulo

1. **DiaryService (autoload)** con registro por eventos y catálogo central de entradas.
2. **Entradas compactas** con claves i18n (M87) y refs a fotos (M56).
3. **Anti-spoiler:** entradas no descubiertas invisibles; secreto solo donde el diseño lo permite.
4. **% de completado sobre lo descubierto** en UI; logros (M72) usan el total real.
5. **Persistencia en GameState** (M59/M60) versionada.
6. **LazyLoad + virtualización** para listas largas (M61).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Spoilers por descuido (entradas visibles) | Media | Alto | Regla de oro en el validador + review de UI |
| % de completado que confunde | Media | Medio | % sobre descubierto + tooltip explicativo |
| Persistencia duplicada entre sistemas | Media | Medio | GameState central y eventos |
| Diario lento con muchas entradas | Media | Medio | LazyLoad + virtualización |
| Claves i18n faltantes | Media | Medio | Validador contra M87 |
| Acoplamiento con M56 (galería) | Media | Baja | Interface `IDiaryPhotoProvider` |