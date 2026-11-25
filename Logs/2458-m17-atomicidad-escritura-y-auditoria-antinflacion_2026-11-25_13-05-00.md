# Log 2458: M17 Construccion — P9: atomicidad de la escritura + auditoria anti-inflacion del propio modulo

**Fecha:** 2026-11-25
**Hora:** 13:05
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Sexta tanda de la sesión sobre **M17-Construccion**. **0 flips de items** (esta tanda es un DEFECTO
corregido, no un item nuevo): al terminar L102 hice un barrido de la clase de defecto que L102
representa — *"operaciones que reportan exito sin hacer el trabajo"* — y encontre otro, peor.

**El defecto (confirmado, no supuesto):**

```gdscript
# ANTES (build_manager.gd, confirmar_colocacion)
var escritos: int = _mundo.escribir_voxel(celdas, r.bloque)   # puede ser 0
_alta_estructura(celda, r, _rotacion)                        # se registra igual
_historial.registrar({ ... })                                 # queda entrada de undo
return { "ok": true, ... }                                    # y dice "ok"
```

Si el mundo tiene terreno pero la escritura falla (0 voxels), la pieza **quedaba registrada en la
logica de M17 sin existir en el mundo**: el jugador no veia nada, el undo no cuadraba y **el
material ya descontado se perdia**. `copiar_pieza()` tenia lo mismo; `mover_pieza()` era el peor:
**vaciaba el origen y se perdia la pieza**.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/construccion_tipos.gd` | Motivo nuevo **`NO_SE_PUDO_ESCRIBIR`** (final del enum) + **TEMPORAL** + texto de HUD. |
| `game/isla-ancestral/scripts/construccion/build_manager.gd` | Las tres rutas que escriben ahora son **atómicas**: `confirmar_colocacion()` (no registra, **devuelve el costo**, no deja entrada en el historial), `copiar_pieza()` (idem) y `mover_pieza()` (**escribe el destino ANTES de vaciar el origen**: si falla, el origen sigue en su sitio). |
| `game/isla-ancestral/tests/test_m17_atomicidad_escritura.gd` (NUEVO) | **24 checks** + minimo 20. |
| `.github/workflows/quality.yml` | Suite nueva cableada en el gate M118. |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva sección **§15**. |
| `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` | **L167** (descuento atómico) reforzado con la evidencia nueva; nota de la auditoría; Totales sin cambio (148/27/0). |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2458** consumido. |

## Modo LÓGICO (sin terreno): no se bloquea nada

Allí la pieza vive solo en la logica **por diseño** (el mundo es nulo), así que 0 voxels escritos es
lo normal y la operación es correcta. El guard solo actúa **cuando hay terreno**: es la
distinción que evita romper el modo lógico.

## Verificación (Godot 4.7.2 headless, binario real)

**Suite nueva** `tests/test_m17_atomicidad_escritura.gd`: **24 checks, 0 fallos, EXIT 0**.
El fallo de escritura se inyecta de forma **determinista** (receta con `bloque = 0` → la escritura
devuelve 0 aunque el terreno responda), no con un terrain falseado a medias.

**ROJO-VERDE:** con el guard desactivado (STUB) se reproduce el comportamiento viejo
(`"colocada pieza_sin_bloque en (2, 1, 2) (1 celdas, 0 voxeles)"`) y la suite da **7 fallos /
EXIT 1**. Restaurada → 24/0, EXIT 0.

**Regresión (15 suites, todas EXIT 0):** atomicidad 24/0 · terreno_cargado 24/0 · contenido_piezas
32/0 · hud_categorias 22/0 · categorias 24/0 · almacenamiento 33/0 · materiales_compartidos 13/0 ·
validacion 44/0 · reglas_pieza 40/0 · circulacion 36/0 · persistencia 23/0 · suites_integracion 17/0
(501 checks en las 7 suites de `scripts/construccion/`) · qa_m17_modo 9/0 · iter3 138/0 ·
**M59 carga idempotente 28/0**.

## Auditoria anti-inflacion del PROPIO modulo (regla §21.8.2)

El QA cruzado lo hace la directora, pero un módulo tampoco puede esperar a eso. Se aplicó el
**muestreo §21.8.2 al propio M17**:

1. Se extrajeron los identificadores técnicos de los **148 `[x]`** (funciones, clases, archivos y
   métodos citados en el texto literal de cada item).
2. Se comprobó **cada uno contra disco** (`scripts/`, `tests/`, `data/`, `DOCUMENTACION/`).
3. Resultado: **0 items sin artefacto** → ningún `[x]` de M17 está inflado. Coherente con
   **0 `[?]`** y con los 27 `[ ]` restantes, que según el mapa de propiedad de `04-Codigo.md`
   pertenecen a otros módulos (M18/UI, M64/IA, M08, M25, M73, M92, M93, M51, M43, M70/input, M113/M114).

## Lo que NO se hizo (honestidad)

- **M20** no se toca (reclamado por GLM-5.3-Flash).
- No se fabrican datos de otros dueños (M25, M73, M92, M93).
- Los 27 `[ ]` de M17 no se cierran desde aquí: son de otros dueños.
- No hay flips de items en esta tanda: el defecto refuerza items ya cerrados (L167) y no
  habilita por sí solo ningún item nuevo del checklist.

## Aviso para la directora (trazabilidad)

Se detectó un **choque de numeración de logs**: existen `Logs/2450-m17-hud-categorias-...` (este
agente) y `Logs/2450-m56-...` (otro agente) con el **mismo número 2450**. Es la carrera que el
protocolo advierte (§6.1.d: dos agentes leen la cabeza del pool a la vez). **No lo toco** — el pool
es de la directora — pero lo reporto para que lo sanee.
