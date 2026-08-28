**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 149-Nombres-Y-Nomenclatura
**Estado:** Implementación operativa (entregable M149)

---

# Proceso de Validación (`validation-process`) — Módulo 149

## 1. Flujo de validación de nombres (artísticos: NPC/lugares)

```
1. PROPONER   Template de npc-names.md §4 (nombre, significado, pronunciación)
2. REGLAS     ¿2-4 sílabas? ¿epíteto cálido? ¿matiz fonético de isla? ¿sin marcas/religión?
3. CULTURAL   Chequeo de significado en 6 idiomas (es/en/fr/de/pt/it) + colisión con marcas
4. CANON      ¿Colisiona con M147/M22/M161/M160? → registrar o descartar
5. ADOPTAR    Marcar CANON (fecha + quién) en M161/M160/M147 según tipo
6. REVISAR    En la revisión trimestral de M147/M149: pronunciación en voz alta, feedback de M87
```

Aprobación: agentes proponen; el **fundador confirma la adopción al canon** (nombres propios son decisión de producto, no delegable).

### Checklist de revisión cultural

- [ ] ¿El nombre significa algo vergonzoso u ofensivo en alguno de los 6 idiomas?
- [ ] ¿Tiene carga religiosa/política sensible?
- [ ] ¿Colisiona con personaje/marca protegida reconocible?
- [ ] ¿Se pronuncia igual de bien en los 6 idiomas?
- [ ] ¿El epíteto respeta el tono cozy (M146/M152)?
- [ ] ¿Está registrado en el canon con su ficha?

## 2. Proceso de code review para nombres

1. El reviewer verifica el checklist del developer (`quick-reference.md` §3) en todo PR/commit que cree archivos o IDs.
2. Ejecutar el validador: `python operativa/validar_nombres.py` (reporta archivos que violan convención).
3. Los errores de naming **bloquean** la marca `[x]` del ítem (coherencia con M111 cuando su linter esté activo).
4. Las excepciones (ej: escenas legacy snake_case) se registran aquí como deuda con dueño, no se corrigen en silencio.

## 3. Scripts de automatización

- **`operativa/validar_nombres.py`** (creado 2026-08-28): valida convenciones de archivos en `game/isla-ancestral/` (`.gd` snake_case, `.tscn` PascalCase para entidades —con lista blanca para tests/previews/main legacy—, `.tres` snake_case, backups con fecha fuera de árbol). Ejecución: `python validar_nombres.py [--root RUTA]`. Salida: `OK` o lista de violaciones + código de salida.
- **Linting general (señales, PascalCase, etc.):** dueño **M111** (en curso); este módulo le aporta las reglas de §code-conventions.
- **Validador de IDs de ítems:** regla documentada (`code-conventions.md` §3); la implementación dentro de DataValidator corresponde a M109/M111.

## 4. Herramientas y aprobación

- **Herramientas:** Python 3 (validador), git (historial de decisiones), 07-GUIA-GODOT (autoridad GDScript), buscador (chequeo de colisiones).
- **Aprobación de nombres artísticos:** fundador (con propuesta del agente y ficha completa).
- **Aprobación de convenciones técnicas:** consenso agente dueño (M05/M111) + registro aquí.

## 5. Entrenamiento, revisión e historial

- **Entrenamiento:** adaptado a 1 persona + agentes — leer `quick-reference.md` es parte del onboarding de M133; los agentes ejecutan el validador antes de marcar.
- **Revisión trimestral:** junto a la revisión de M135/M147 (¿ surgieron convenciones nuevas? ¿el validador necesita reglas?).
- **Historial de decisiones:** changelog por documento (sección Changelog) + logs numerados. Primera decisión: señal = snake_case (confirma 07-GUIA-GODOT §1.1), escenas entidad = PascalCase (formaliza lo existente), IDs de ítems = patrón M159 formalizado.

## Changelog

| Fecha | Cambio | Autor |
|---|---|---|
| 2026-08-28 | Creación del proceso y del validador de naming (implementación M149, log 201) | GLM (Kilo) |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
