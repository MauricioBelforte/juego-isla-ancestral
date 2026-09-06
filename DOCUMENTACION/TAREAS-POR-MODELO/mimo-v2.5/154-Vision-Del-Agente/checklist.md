**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Módulo:** 154-Vision-Del-Agente
**Estado:** 🔵 En curso (131/155 completados)
**Prioridad:** #4
**Fortaleza:** Testing visual, documentación

# M154 — Visión del Agente: Checklist MiMo V2.5

## Reserva actual
- **Estado:** 🔵 Reservado
- **Fecha:** 2026-09-02
- **Log:** pendiente

## Pendientes (24 items)

### V3 Playwright (8)
- [ ] T-154-001: Servir localmente con python -m http.server 8080 [S]
- [ ] T-154-002: Navegar con skill webapp-testing a localhost:8080 [S]
- [ ] T-154-003: Esperar carga WASM correctamente (networkidle + timeout) [M]
- [ ] T-154-004: Capturar primer screenshot del juego en navegador [S]
- [ ] T-154-005: Verificar similitud visual razonable vs build desktop [M]
- [ ] T-154-006: Probar interacción: click/tecla mueve al personaje [M]
- [ ] T-154-007: Guardar captura con convención YYYY-MM-DD_HH-MM-SS_via_descripcion.png [S]
- [ ] T-154-008: Documentar diferencias conocidas WebGL vs desktop [S]
- [ ] T-154-009: Preparar script reutilizable del pipeline completo [M]
- [ ] T-154-010: Conectar pipeline con job de CI (M118) para regresión visual [C]

### G preview scene (5)
- [ ] T-154-011: Crear preview_personaje.tscn en el proyecto Godot [M]
- [ ] T-154-012: Fondo neutro uniforme (gris medio) para comparaciones [S]
- [ ] T-154-013: Luz de 3 puntos key/fill/rim estandarizada [M]
- [ ] T-154-014: Cámara fija con encuadre documentado [S]
- [ ] T-154-015: Slot para modelo voxel intercambiable [M]
- [ ] T-154-016: Botón/tecla de captura directa a Logs/screenshots/ [M]
- [ ] T-154-017: Integrar escena con Debug Menu (M110) si aplica [S]
- [ ] T-154-018: Documentar uso de la escena en este módulo [S]

### I reproducibilidad (1)
- [ ] T-154-019: Test de reproducibilidad: otro agente sigue la guía e instala V4 [C]

### K blender scripts (5)
- [ ] T-154-020: Crear scripts/blender/setup_estudio.py (luz 3 puntos + cámara + fondo) [M]
- [ ] T-154-021: Crear scripts/blender/personaje_voxel.py (generador paramétrico) [M]
- [ ] T-154-022: Iterar primer NPC completo end-to-end con screenshots hasta aprobación del usuario [C]
- [ ] T-154-023: Exportar personaje aprobado a .glb e importarlo en Godot [M]
- [ ] T-154-024: Documentar versiones exactas instaladas (Blender, blender-mcp, commit) [S]

## Completados esta sesión
_(ninguno aún)_

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02
**Estado:** Inicio de backlog

### Lo que voy a hacer
- Completar V3 Playwright (T-154-001 a T-154-010) — testing web
- Crear preview scene (T-154-011 a T-154-018) — capturas estandarizadas
- Scripts Blender (T-154-020 a T-154-024) — modelado procedural

### Lo que NO puedo hacer todavía
- T-154-019 requiere otro agente para test de reproducibilidad
- T-154-010 requiere M118 (CI/CD) implementado
- T-154-022 requiere hardware de Blender funcional

### Recomendaciones para el próximo agente
- V3 Playwright es el más rápido de completar — empezar por ahí
- La preview scene es útil para todos los módulos visuales
- Los scripts Blender son opcionales pero útiles para modelado procedural
