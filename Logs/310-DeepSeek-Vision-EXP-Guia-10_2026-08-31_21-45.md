# Log 310: DeepSeek V4 Flash Vision EXP + Actualización guía 10

**Fecha:** 2026-08-31
**Hora:** 21:45
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Se investigó y documentó DeepSeek V4 Flash Vision EXP (multimodal nativo, lanzado 21 agosto 2026), y se actualizó la guía 10 y CHECKLIST-GLOBAL para reflejar su uso en QA visual del proyecto.

## Cambios Realizados

### 1. DeepSeek V4 Flash Vision EXP — Investigación
- **Model ID:** `deepseek-v4-flash-vision-exp`
- **Tipo:** Multimodal (texto + imagen), status experimental
- **Lanzamiento:** 21 agosto 2026
- **Precio:** Igual que V4 Flash ($0.14/$0.28) — sin costo extra por visión
- **Tokens por imagen:** 384 (vs 800-1100 de GPT/Claude — 2-3x más eficiente)
- **Text task:** Misma capacidad que V4 Flash (sin regresión)
- **Vision agent:** Cerca de Opus-4.8 (ApexBench 36.5, ALA gana por 1.6 pts)
- **Soporte:** DeepSeek Harness 0.1.1

### 2. Guía 10 actualizada
- Nueva sección B2: DeepSeek V4 Flash Vision EXP con specs completas
- Matriz de recomendación: QA visual → Vision EXP (reemplaza GLM-5.3 Flash)
- Flujo delegación: paso 5 ahora es Vision EXP para QA visual
- Tabla deprecaciones actualizada

### 3. CHECKLIST-GLOBAL actualizado
- M154: notas actualizadas con 24 items delegables a Vision EXP
- M165: notas actualizadas con 8 items [V4] delegables a Vision EXP
- M167: notas actualizadas con 21 items delegables a Vision EXP

## Archivos Modificados/Creados
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (sección B2, matriz, flujo)
- `CHECKLIST-GLOBAL.md` (M154, M165, M167)
