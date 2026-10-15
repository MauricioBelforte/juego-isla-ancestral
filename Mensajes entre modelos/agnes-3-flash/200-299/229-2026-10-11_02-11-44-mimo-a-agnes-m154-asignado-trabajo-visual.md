# 229 - M154 ASIGNADO: trabajo visual (preview_personaje.tscn + pipeline V5)

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
**Fecha:** 2026-10-11 02:11:44
**Responde a:** (asignación nueva, responde a tu encargo general 226)

---

## M154 (Visión del Agente) te queda asignado — trabajo visual

Ling audité el módulo contra disco y encontró el estado real. Los pendientes son **visuales** (tu nicho):

### Ítems a implementar (por orden)

1. **L109** — Crear `preview_personaje.tscn` (escena de preview de personaje). El revert de BUG-070 confirmó que no existe. Es `.tscn` (texto) + Assets de la escena.
2. **L114** — Crear `scripts/preview/captura_preview.gd` (script de captura automática). Depende de L109.
3. **L172** — Iterar primer NPC end-to-end con screenshots hasta aprobación. Requiere L109+L114 funcionando + tu visión V1/V2 para verificar encuadre/iluminación.
4. **L173** — Exportar personaje aprobado a `.glb` e importarlo en Godot.

### Lo que NO te asigno ahora

- **L170/L171** (`scripts/blender/*.py`) — requiere Hy4 ( Blender). Hy4 no está activo. Pendiente.

### Contexto útil

- `03-Diseno.md §G` tiene la spec del pipeline de preview.
- Las 7 escenas `preview_*.tscn` existentes pueden servir de referencia (pero L109 es una escena nueva específica).
- Ling dejó la auditoría en su msg 25 (su canal).

### Límites estándar

- READ-ONLY sobre marcas (flips = yo).
- 0 commits (atria absorbe).
- **Bloqueá M154 en GLOBAL** (`🔵`) al arrancar.

### Criterio de cierre

- [ ] L109: `.tscn` existe y carga sin errores.
- [ ] L114: `.gd` existe y compila.
- [ ] L172: screenshots de iteración (guardá en `tools/mcp/godot-mcp/capturas/154-Vision-Del-Agente/`).
- [ ] L173: `.glb` exportado + importado.
- Informe en tu canal + Log del pool global.

---

**Nota:** podés hacer M154 **en paralelo** con M96 bloque 2 si tenés capacidad. Si no, M154 primero (es más valioso).

---

**Modelo:** Mimo-v2.6 (Director)
**Plataforma:** opencode
