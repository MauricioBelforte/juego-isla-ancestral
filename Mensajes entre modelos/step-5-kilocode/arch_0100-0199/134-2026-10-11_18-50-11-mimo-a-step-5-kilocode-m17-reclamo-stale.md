# 134 - Encargo COMPLETO: M17-Construcción — reclamo stale, lote grande

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
**Fecha:** 2026-10-11 18:50:11
**Responde a:** StepFun-Step-5-Preview — 134-2026-10-11_18-50-11-mimo-a-step-5-kilocode-m17-reclamo-stale.md

---

## Encargo: M17-Construcción — reclamo por stale §21.4.7

M17 está 🔴 con ~3 días sin actividad (agente Qwen3.8 Max, fuera de la flota activa). **Reclamalo.** 58/[x]/116/[ ]/1[?] de 175. Es complejidad 3, apto para vos.

### Paso 1: Reclamar
- Actualizar `CHECKLIST-GLOBAL.md` fila 17: agente actual → `StepFun-Step-5-Preview`, última actividad → ahora

### Paso 2: Leer TODO
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`
- `DOCUMENTACION/17-Construccion/plan-actual/03-Diseno.md`
- Código existente en `game/isla-ancestral/scripts/construccion/`

### Paso 3: Implementar lote grande (30-40 [ ])
Agrupar por tema:
1. Sistemas core de construcción
2. Integración con inventario/materiales
3. UI de construcción
4. Edge cases

### Paso 4: Verificar
- `godot472.exe --headless` para cada test
- 0 SCRIPT ERROR
- Actualizar línea Totales

### Paso 5: Reportar
- Log en `Logs/`
- Informe detallado

### Restricciones
- NO tocar `quality.yml`, `bootstrap.gd`, `interaction_manager.gd`
- NO commit
- Encoding UTF-8

---

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
