**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (implementación iter. 1 núcleo; diseño original Unity/C# por Deepseek V4 Flash / OpenCode 2026-08-20)

# 04-Codigo.md — Módulo 94: Retención sin FOMO

## 1. Archivos involucrados (REAL — Godot 4.7 / GDScript)

### 1.1 Nuevos (`game/isla-ancestral/scripts/motivacion/`)
| Archivo | Propósito |
|---------|-----------|
| `motivacion_manager.gd` | Autoload `MotivacionManager`: tablero de objetivos, reseteo rotatorio, progreso, recompensas, auditoría, persistencia snapshot |
| `objetivo_data.gd` | `ObjetivoData` (Resource): definición de objetivo (id, nombre, plazo, condición, recompensa) |
| `objetivo_activo.gd` | `ObjetivoActivo` (RefCounted): estado vivo (progreso, cobrado, ciclo, completado) |
| `recompensa_acumulada.gd` | `RecompensaAcumulada` (RefCounted): cola de recompensas sin expiración, límite 50 |
| `motor_variantes.gd` | `MotorEventosVariantes` (RefCounted): variantes cíclicas 3+ por festividad, participaciones acumuladas |
| `antifomo_auditor.gd` | `AntiFomoAuditor` (RefCounted): scan de 5 reglas R1-R5, reporte de violaciones |
| `test_motivacion_m94.gd` | Test headless (38/0 OK) |
| `data/motivacion/objetivos.json` | Catálogo data-driven: 7 objetivos (3 diarios, 2 semanales, 2 mensuales) |

### 1.2 Modificado
| Archivo | Cambio |
|---------|--------|
| `project.godot` | Autoload `MotivacionManager="*res://scripts/motivacion/motivacion_manager.gd"` |

### 1.3 Diferencias vs diseño original (Unity/C#)
- `MotivacionManager.cs` → `motivacion_manager.gd` (autoload GDScript, sin class_name)
- `ObjetivoDiario.cs` → `objetivo_data.gd` (Resource) + `objetivo_activo.gd` (RefCounted, separado en estado vivo)
- `RecompensaAcumulada.cs` → `recompensa_acumulada.gd` (con límite 50, sin expiración)
- `MotorEventosVariantes.cs` → `motor_variantes.gd` (ciclo 3+, participaciones)
- `AntiFomoAuditor.cs` → `antifomo_auditor.gd` (helper estático, 5 reglas, reporte)
- `PostgameManager.cs` y `Editor/...` → pendientes (dependen de M22/M55/M74)

## 2. API pública

### 2.1 `motivacion_manager.gd` — autoload (sin class_name)
```gdscript
catalogo: Array                              # Array[Dictionary] de objetivos
activos: Dictionary                          # objetivo_id -> ObjetivoActivo
recompensas: RecompensaAcumulada
motor_variantes: MotorEventosVariantes

objetivos_por_plazo(plazo: String) -> Array  # "diario"/"semanal"/"mensual"
registrar_progreso(objetivo_id, delta=1) -> bool  # true si recién completó
cobrar_recompensa(objetivo_id) -> Array      # lista de recompensas cobradas
rotar_objetivos()                            # reseteo sin pérdida de premios
auditar() -> Array                           # violaciones anti-FOMO
snapshot() -> Dictionary                     # persistencia
restaurar(datos: Dictionary)
```

### 2.2 `objetivo_activo.gd` — ObjetivoActivo
```gdscript
var objetivo_id: String; var progreso: int; var cobrado: bool; var ciclo: int; var completado: bool
avanzar(cantidad_requerida, delta=1) -> bool  # true si recién completó
a_diccionario() / desde_diccionario(d)
```

### 2.3 `recompensa_acumulada.gd` — RecompensaAcumulada
```gdscript
agregar(id, cantidad)        # límite 50, después se descarta
cobrar_pendientes() -> Array  # vacía la cola
a_diccionario() / desde_diccionario(d)
```

### 2.4 `motor_variantes.gd` — MotorEventosVariantes
```gdscript
registrar(festividad_id, variantes: Array)
siguiente_variante(festividad_id) -> String  # rotación cíclica
participaciones(festividad_id) -> int
a_diccionario() / desde_diccionario(d)
```

### 2.5 `antifomo_auditor.gd` — AntiFomoAuditor (static)
```gdscript
escanear(objetivos, config) -> Array[String]  # violaciones detectadas
reporte(violaciones) -> String                # legible para CI/QA
```

## 3. Catálogo data-driven (objetivos.json)
7 objetivos de ejemplo: 3 diarios (recolectar_madera, hablar_con_vecinos, regalar_regalo), 2 semanales (pescar_tres, minerales), 2 mensuales (construir_mueble, explorar_isla). Cargados al arranque por el autoload.

## 4. Verificación
- Test M94: `Godot --headless --path game/isla-ancestral --script res://scripts/motivacion/test_motivacion_m94.gd` → **38 checks, 0 fallos**.
- Regresión M60: **66/0 OK** (snapshot/restaurar compatible con DataStore).

## 5. Pendientes honestos (77 ítems de checklist)
- Integración con M55 (diario UI: sección Objetivos + Sobremesa).
- Integración con M74 (eventos/festividades reales).
- Integración con M59 (save real vía DataStore: la persistencia snapshot/restaurar está lista).
- Test de ausencia simulada 7 días (requiere M29 GameClock).
- Postgame completo (3 bloques, >5h, depende de M22 epílogo).
- Contenido: descubrimientos inesperados, colecciones, misterios, postgame.

## Notas del Agente

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 liberado

### Lo que hice
- MotivacionManager autoload con tablero de objetivos por plazo, reseteo rotatorio, progreso y recompensa.
- RecompensaAcumulada con cola sin expiración, límite 50.
- MotorEventosVariantes con 3+ variantes cíclicas y participaciones acumuladas.
- AntiFomoAuditor con scan de 5 reglas (R1-R5), reporte de violaciones.
- Catálogo data-driven JSON (7 objetivos).
- Persistencia snapshot/restaurar (lista para M60 DataStore).
- Test headless 38/0 OK + regresión M60 66/0 OK.

### Lo que NO pude hacer (honestidad obligatoria)
- [M] Integración real con M55 (diario UI), M74 (eventos), M59 (save real): la API de snapshot está lista pero los hooks UI/de eventos no están implementados aún.
- [M] Test de ausencia simulada 7 días: requiere M29 GameClock para simular días sin juego.
- [M] Postgame completo: depende de M22 (epílogo) y M74 (festividades).
- [M] Contenido de descubrimientos inesperados, colecciones, misterios: son contenido, no lógica.

### Recomendaciones para el próximo agente
- Conectar con M55 (Diario): usar `motivacion_manager.objetivos_por_plazo()` para poblar la sección Objetivos y `recompensas.cobrar_pendientes()` para la sección Sobremesa.
- Conectar con M74 (Eventos): el motor_variantes ya tiene el API de variantes; solo falta cargar las festividades reales desde M74.
- Conectar con M59 (DataStore): en el guardado, incluir `mm.snapshot()` en el payload y en carga, llamar `mm.restaurar(datos.get("motivacion", {}))`.
- Para test de ausencia 7 días: crear un escenario que avance 7 días de juego (M29 GameClock) y verificar que cultivos/amistad/perfiles no cambien.