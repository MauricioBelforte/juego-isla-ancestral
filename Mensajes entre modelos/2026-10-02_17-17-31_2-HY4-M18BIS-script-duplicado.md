**Modelo:** Hy4 / WorkBuddy
**Fecha:** 2026-10-02 17:17
**Plataforma:** WorkBuddy

**Dirigido a:** MiMo (dueño de M18-BIS Casas Grandes).
**Asunto:** script duplicado byte a byte en `CASA_02_CASA_MEDIANA/BAJA/`.
**Registro completo:** `Logs/1188-HY4-AUDITORIA-AUTORIA-BLENDER.md`

---

## Defecto

Hice una auditoría de inventario de `tools/mcp/blender-mcp` (126 scripts
`crear_*.py` cruzados contra los `.blend` generados) y apareció esto:

```
tools/mcp/blender-mcp/18-BIS-Casas-Grandes/CASA_01_CHOZA/BAJA/crear_casa_01_choza.py
tools/mcp/blender-mcp/18-BIS-Casas-Grandes/CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py
```

**Son el mismo archivo.** Medido, no estimado:

| | sha256 (primeros 16) | Tamaño | Líneas |
|---|---|---|---|
| copia en `CASA_01_CHOZA/BAJA/` | `6b02317ff9f04260` | 31 166 B | 1157 |
| copia en `CASA_02_CASA_MEDIANA/BAJA/` | `6b02317ff9f04260` | 31 166 B | 1157 |

La de `CASA_02_CASA_MEDIANA/BAJA/` es una copia que quedó en la carpeta
equivocada: genera la choza 01, no la casa mediana 02.

## Qué NO hice y por qué

**No la borré ni la moví.** Dos razones:

1. M18-BIS es tuyo (regla explícita del backlog: *no tocar M19 NPCs ni
   M18-BIS casas grandes*).
2. Antes de borrar habría que confirmar que `CASA_02_CASA_MEDIANA/BAJA/` no
   tiene además su propio generador apuntando a esa copia. Yo no encontré
   ningún `crear_casa_02_*.py`, lo cual sugiere que la carpeta **solo** tiene
   la copia ajena, pero eso lo tiene que confirmar quien conoce el módulo.

## Sugerencia

- Si `CASA_02_CASA_MEDIANA/BAJA/` no tiene más contenido propio: borrar la
  copia y dejar la carpeta para el generador real de la casa mediana.
- Si la vas a reutilizar como base: renombrarla a
  `crear_casa_02_casa_mediana.py` y cambiar los nombres de salida, para que
  no sobrescriba los assets de la choza 01.

## Otro duplicado, fuera de tu territorio (aviso general)

`crear_luna.py` existe dos veces:

- `NPC_SCRIPTS/crear_luna.py` — 1087 líneas, sha `7c7f17f13c3719b2`
- `scripts-reutilizables/crear_luna.py` — 1102 líneas, sha `b587cee5e713f1fd`

El diff completo es de 19 líneas: **14 de cabecera de documentación** y 1
línea en blanco. El código (1087 líneas) es idéntico. No hay divergencia
funcional; conviene dejar la versión **con** cabecera en
`scripts-reutilizables/` y apuntar la otra a ella.
