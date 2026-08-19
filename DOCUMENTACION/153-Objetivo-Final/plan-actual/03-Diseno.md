**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 153: Objetivo Final del Proyecto

## 1. Visión General

M153 es el **contrato de visión** del proyecto: 19 objetivos del plan maestro convertidos en criterios verificables con módulos dueños, regla de integración para módulos nuevos, y `validate_vision.gd` como guardián de edición. No hay runtime: es gobernanza + validación (M150 Control Final lo aplica).

## 2. Arquitectura

```
┌─ M151 PRINCIPIOS (techo: cero combate, cero FOMO, sin grind) ─┐
│                         │ subordina                            │
│  ┌─ M153 CONTRATO DE VISIÓN ─────────────────────────────┐    │
│  │  O1..O19: criterio verificable + módulo dueño         │    │
│  │  Regla de integración (nuevos módulos declaran O#)    │    │
│  │  validate_vision.gd (editor)                          │    │
│  └───────┬───────────────────────────┬───────────────────┘    │
│          │ audita                    │ provee                  │
│  ┌───────▼────────┐     ┌────────────▼─────────────┐           │
│  │ M150 Control   │     │ M113 Playtest + M104     │           │
│  │ Final (lista   │     │ Telemetría (hogar,       │           │
│  │ O1-O19)        │     │ ruinas, pausa, memoria)  │           │
│  └────────────────┘     └──────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### 2.1 Componentes

| Componente | Responsabilidad | Tipo |
|---|---|---|
| Tabla de contrato O1-O19 | Fuente de verdad de los objetivos | Documento (`01-Requerimientos.md`) |
| Regla de integración | Módulos nuevos declaran O# | Norma (blog en `03-Diseno.md`) |
| `validate_vision.gd` | Valida contrato (criterio + dueño) y cobertura de módulos | Script editor |
| Prueba de visión | O1-O19 ejecutados en playtest (M113) y Control Final (M150) | Checklist |

### 2.2 Estados

```
ACTIVO (gobernanza en marcha)
├── CADA_MÓDULO decide sus O# (regla de integración)
├── validate_vision.gd corre en editor/CI
└── M150 lo aplica como criterio final de terminación
```

El módulo se marca ✅ solo cuando O1-O19 se cumplen (implies: final del proyecto).

## 3. Estructura de Datos

### 3.1 Tabla de contrato (resumen, la completa está en 01-Requerimientos.md)

```json
{
  "objetivos": [
    {"id": "O1", "nombre": "Aurora como hogar", "criterio": "vuelve voluntario ≥1/sesión 30 min",
     "indicador": "telemetria M104 + playtest", "duenos": ["M17","M15","M18"]},
    {"id": "O2", "nombre": "Curiosidad por siguiente isla", "criterio": "isla visible y viaje deseable",
     "indicador": "telemetria + playtest", "duenos": ["M26","M27","M28"]},
    ...
  ]
}
```

### 3.2 `validate_vision.gd` — Validación

| Validación | Condición |
|---|---|
| Contrato | Cada O tiene criterio no vacío y ≥1 dueño |
| Principios | Ningún criterio viola M151 (palabras clave: combate, FOMO, grind) |
| Cobertura | Los módulos del checklist global con gameplay declaran O# (warn si no) |
| Prueba | La checklist de playtest (M113) contiene O1-O19 |

## 4. Persistencia

- Sin estado de runtime: el contrato es estático (Resource embebido) + checklist.
- La telemetría (M104) es la huella; los eventos dedicados (volver_a_casa, acercarse_ruina, pausa_contemplativa) viajan con el save anónimo (M103).

## 5. Integración con otros módulos

| Módulo | Rol |
|---|---|
| M151 | Techo de principios (subordinación) |
| M150 | Control Final: aplica O1-O19 |
| M113 | Playtest estructurado de visión |
| M104 | Telemetría de comportamiento |
| M101 | QA transversal de coherencia (O14) |
| M21/M23 | Historia de la Resonancia (O10, O16, O17) |
| M74/M75 | Mundo vivo post-créditos (O11) |
| M06/M15 | Chequeo modular y arquitectura (O12, O13) |

## 6. Impacto en Rendimiento (M61)

- Cero impacto: sin runtime, solo editor/CI y playtest.
- Los eventos de telemetría son asíncronos y raros (M104/M103).