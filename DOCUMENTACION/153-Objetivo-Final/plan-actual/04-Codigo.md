**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-19 (documentación original por Deepseek V4 Flash)

# 04-Codigo.md — Módulo 153: Objetivo Final del Proyecto

## 1. Archivos Involucrados

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `vision_contract.json` | Especificado: `game/isla-ancestral/data/vision/` (fase editor/CI). **Vigente: `DOCUMENTACION/153-Objetivo-Final/operativa/vision_contract.json`** | Contrato O1-O19 (máquina) | ✅ IMPLEMENTADO v1.1 (19 O con titulo/criterio/indicador/tipo/dueños/eventos) |
| `validate_vision.gd` | Especificado: `game/isla-ancestral/scripts/editor/` (fase editor/CI M118) | Guardián del contrato (GDScript) | Especificado (04 §3); equivalente ejecutable actual = `operativa/validate_vision.py` |
| `validate_vision.py` | `DOCUMENTACION/153-Objetivo-Final/operativa/validate_vision.py` | Guardián ejecutable (Python) | ✅ IMPLEMENTADO y ejecutado (en verde; cobertura con WARN real) |
| `prueba_vision.md` | `DOCUMENTACION/153-Objetivo-Final/operativa/prueba_vision.md` | Checklist O1-O19 para M114/M151 | ✅ IMPLEMENTADO (condiciones, checklist, formulario, criterio ≥80%) |

> **Adaptaciones documentadas:** (1) rutas Unity del spec original (`Assets/_Project/...`) → ubicación vigente en `operativa/` por convención `AGENTS.md` §3, con destino Godot anotado; (2) correcciones de módulos: playtest = **M114**, control final = **M151**, principios = **M152**, telemetría = **M104/M105** (el doc original citaba M113/M150/M151); (3) dueño técnico de O12 = **M07** (Arquitectura) junto a M26.

## 2. Funciones Clave

### 2.1 `validate_vision.gd` — Guardián

| Método | Propósito |
|---|---|
| `validate_contrato()` | Cada O tiene criterio y dueños |
| `validate_principios()` | Nada viola M151 (combate/FOMO/grind) |
| `validate_cobertura()` | Módulos de gameplay declaran O# |
| `validate_prueba()` | checklist O1-O19 presente en M113 |

### 2.2 `vision_contract.json` — Contrato

```json
{
  "objetivos": [
    {"id": "O1", "criterio": "vuelve voluntario ≥1/sesión 30 min", "duenos": ["M17","M15","M18"]},
    {"id": "O2", "criterio": "isla siguiente visible y viaje deseable", "duenos": ["M26","M27","M28"]},
    {"id": "O3", "criterio": "≥2 vecinos recordados tras 3 sesiones", "duenos": ["M18","M19","M21"]},
    {"id": "O4", "criterio": "aproximación a ruinas sin tutorial", "duenos": ["M24","M25"]},
    {"id": "O5", "criterio": "15+ min construcción sin historia disfrutable", "duenos": ["M15","M16","M17"]},
    {"id": "O6", "criterio": "mundo completo sin tocar misiones", "duenos": ["M22","M15","M74"]},
    {"id": "O7", "criterio": "objetivo activo siempre visible, sin ventanas", "duenos": ["M22","M53","M92"]},
    {"id": "O8", "criterio": "construir desbloquea contenido", "duenos": ["M15","M18","M74"]},
    {"id": "O9", "criterio": "decisiones alteran el mapa visible", "duenos": ["M74","M15","M54"]},
    {"id": "O10", "criterio": "jugador explica la Resonancia", "duenos": ["M21","M23"]},
    {"id": "O11", "criterio": "postgame con 10+ h de vida propia", "duenos": ["M74","M75"]},
    {"id": "O12", "criterio": "isla nueva sin tocar sistemas centrales", "duenos": ["M06","M26"]},
    {"id": "O13", "criterio": "contenido reutiliza sistemas", "duenos": ["todos"]},
    {"id": "O14", "criterio": "cero contradicciones en QA transversal", "duenos": ["M21","M23","M57"]},
    {"id": "O15", "criterio": "cada sistema declara qué experiencia sirve", "duenos": ["todos"]},
    {"id": "O16", "criterio": "cada mecánica refuerza un hilo narrativo", "duenos": ["M21","M23"]},
    {"id": "O17", "criterio": "lore integrado en el mundo", "duenos": ["M146","M147","M24"]},
    {"id": "O18", "criterio": "30 min sin eventos disfrutables", "duenos": ["M30","M31","M40"]},
    {"id": "O19", "criterio": "2+ pausas de 5 min sin input en playtest", "duenos": ["M40","M41","M42","M43","M10"]}
  ]
}
```

## 3. Fragmento de Núcleo (prototipo de diseño)

```gdscript
# validate_vision.gd — guardián del contrato de visión (M153)
extends Node

const PALABRAS_PROHIBIDAS := ["combate", "fomo", "grind", "cofre aleatorio obligatorio"]

func validate_contrato(contrato: Dictionary) -> Array[String]:
    var problemas: Array[String] = []
    for o in contrato["objetivos"]:
        if o["criterio"].is_empty():
            problemas.append("%s sin criterio verificable" % o["id"])
        if (o["duenos"] as Array).is_empty():
            problemas.append("%s sin módulo dueño" % o["id"])
    return problemas

func validate_principios(contrato: Dictionary) -> Array[String]:
    var problemas: Array[String] = []
    for o in contrato["objetivos"]:
        var c: String = o["criterio"].to_lower()
        for p in PALABRAS_PROHIBIDAS:
            if c.contains(p):
                problemas.append("%s viola M151: %s" % [o["id"], p])
    return problemas

## Cobertura: los módulos de gameplay deben declarar O# en su 01-Requerimientos.
func validate_cobertura(modulos: Array[String]) -> Array[String]:
    # Implementación en CI: leer los 01-Requerimientos de cada módulo,
    # verificar que contengan "O\d+". Warn (no error) permite operaciones.
    return []
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

Sin editor/binary Godot en el entorno: `validate_vision.gd` y `vision_contract.json` son **prototipos de diseño**; la ejecución (parse de JSON + cheat) queda para el entorno destino (criterio 3 de aceptación pendiente). Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- M153 **no modifica ningún módulo**: es gobernanza transversal (documentos + validator de editor).
- Su única acción sobre otros: exigir la declaración O# en cada 01-Requerimientos (cambio documental, no de código).

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 152 "OBJETIVO FINAL DEL PROYECTO" (19 ítems).
- TABLA GLOBAL: ID 153 — Objetivo Final del Proyecto. Desfase = +1 (la tabla global agrega módulos intermedios).

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19
**Estado:** Completado (contrato de visión documentado; validación de cumplimiento pendiente del proyecto)

### Lo que hice
- RECLAMÉ el módulo 153 por inactividad >24 h (regla 21.4.7): B2-Composer lo tenía 🔵 desde 2026-08-16 17:35 sin producción (la carpeta ni existía).
- Convertí los 19 objetivos del plan maestro en contrato verificable: cada O tiene criterio observable, indicador (playtest M113 / telemetría M104 / QA M101) y módulos dueños.
- Documenté la regla de integración (módulos nuevos declaran O#), la subordinación a M151 (principios) y la aplicación en M150 (Control Final).
- Entregué `vision_contract.json` y `validate_vision.gd` (prototipos).

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` La verificación de cumplimiento O1-O19: requiere el juego implementado (playtest/telemetría); el módulo se marca ✅ solo al final del proyecto.
- `[?]` Sin editor Godot: `validate_vision.gd` no se ejecutó (parse de JSON para entorno destino).
- `[?]` Los módulos dueños M146/M147 (World Building/Lore) aún son ⬜ en la tabla global: O17 depende de su futuro diseño.

### Intentos fallidos / decisiones
- Descarté GDD de visión genérica (no verificable): contrato por objetivo.
- Descarté solo telemetría (no mide emoción) y solo playtest (caro): indicadores mixtos.

### Recomendaciones para el próximo agente
- Al crear cualquier módulo nuevo, declarar los O# que refuerza en su 01-Requerimientos (regla M153).
- La "prueba de visión" O1-O19 debe incluirse en el plan de playtests de M113 desde el primer playtest externo.
- M150 (Control Final) usará este contrato como checklist final de terminación.

---

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 24:00:00
**Estado:** Parcial programado (con [?] futuros) — pendiente de QA cruzado

### Lo que hice
- Implementé `vision_contract.json` v1.1: 19 objetivos con titulo, criterio verificable, indicador, tipo de indicador (playtest/telemetría/QA/arquitectura), dueños corregidos a módulos reales (M114/M151/M152/M104/M105/M147/M07) y eventos de telemetría especificados.
- Implementé `validate_vision.py`: guardián **ejecutable** con los 4 checks del diseño (contrato, principios M152, cobertura O# con WARN, prueba presente). Ejecutado en verde tras una iteración real: el chequeo de palabras prohibidas detectó que O2 nombraba "FOMO" para negarlo → regla de redacción aprendida (los criterios describen el comportamiento deseado sin nombrar mecanismos prohibidos) y criterio corregido.
- Implementé `prueba_vision.md`: condiciones (30-60 min, ≥5 jugadores), checklist O1-O19, formulario por objetivo, criterio ≥80% con bloqueo de ✖ en Must, flujo de retest y subordinación a M151/M152.
- Auditado la cobertura real: **159 módulos aún sin declarar O#** en sus 01-Requerimientos — WARN documentado como línea base; la regla rige para módulos nuevos y alineación progresiva (excepciones de operación/build/legal previstas).
- Marqué el checklist 120/130 `[x]` + 10 `[?]` (instrumentación de telemetría M105 y verificaciones que exigen juego implementado).
- Reservé y liberé en los 4 registros, actualicé DOCUMENTACION/README y generé el log 202.

### Lo que NO pude hacer (honestidad obligatoria)
- No instrumenté los 5 eventos de telemetría (volver_a_casa, acercarse_puerto, aproximacion_ruinas, bloque_construccion, pausa_contemplativa): requiere M105 implementado.
- No migré `vision_contract.json`/`validate_vision.gd` dentro del árbol del juego (toca código runtime de zonas ajenas; destino documentado en el contrato _meta).
- La alineación de los 159 módulos existentes con la regla O# es progresiva: exigirla completa de golpe tocaría zonas de muchos agentes.

### Recomendaciones para el próximo agente
- QA cruzado rápido: ejecutar `validate_vision.py` (en verde), verificar el JSON (19 O) y el marcado 120/130 + 10 `[?]` justificados.
- M105 (al implementar telemetría) debe crear los 5 eventos del contrato; M114 debe usar `prueba_vision.md` en su primer corte.
- Los módulos nuevos declaran O# desde hoy (validador lo verifica con WARN); la alineación de los existentes puede hacerse por tandas en los QA cruzados.
- M151 (Control Final) consume `prueba_vision.md` como su checklist de terminación (19 en ✓ = condición de lanzamiento).