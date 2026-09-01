# Log 201: Implementación M149 Nombres y Nomenclatura (sistema de naming + validador)

**Fecha:** 2026-08-28
**Hora:** 23:25
**Modelo:** GLM
**Plataforma:** Kilo

## Resumen

Se implementó el módulo 149 (Nombres y Nomenclatura): 5 documentos operativos + un validador de naming ejecutable, todo anclado al canon y código reales del proyecto (no genéricos). Séptimo módulo del lote de 8. Checklist 97/100 con 3 `[?]` con dueño/programados.

## Cambios Realizados

- Creado `operativa/npc-names.md`: sistema de nombres (Nombre + Epíteto, matiz fonético por isla), 5 categorías con 15 nombres (2 canon: Catalina Oso, Finneas; 12 PROPUESTA para M161/M22), guía de pronunciación, validación cultural multilingüe, template.
- Creado `operativa/place-names.md`: 5 categorías con reglas, 11 lugares (7 canon: Aurora, Raíz, Coral, Ceniza, Templo de la Brisa, Gran Vapor, Zona Segura; 4 propuestas), mapa de referencias, tabla de equivalencias 6 idiomas (ej. para M87).
- Creado `operativa/code-conventions.md`: tabla GDScript con ejemplos reales del proyecto, convenciones de archivos por tipo (gd/tscn/tres/png/wav/glb/anim/json/gdshader), patrón de IDs de datos M159 formalizado (`item_<cat3>_<sub3>_<NNN>`), tags con prefijo de dominio, template de script.
- Creado `operativa/quick-reference.md`: cheatsheet de 1 página, checklist del developer, top-5 "no hacer", templates de escena/recurso, snippets de IDE, integración con M111.
- Creado `operativa/validation-process.md`: flujo de validación cultural/canon, code review de nombres, herramientas, changelog.
- Creado `operativa/validar_nombres.py`: validador de naming ejecutable (gd snake_case, tscn PascalCase entidades con whitelist, tres/json snake_case, backups solo en Obsoletos/). **Ejecutado sobre el proyecto real: detecta 1 violación legacy (`scenes/npc/villager.tscn`) — documentada como deuda con dueño, no corregida (rompería referencias).**
- Correcciones documentadas al doc original: señales = snake_case (07-GUIA-GODOT §1.1 manda; el checklist decía PascalCase), IDs de integración corregidos (M23→M19/M161, M30→M27/M160, M103→M87), patrón de diálogos simplificado a snake_case `dlg_*`.
- Actualizado `plan-actual/05-Checklist.md` (97/100 + 3 `[?]` con evidencia) y `plan-actual/04-Codigo.md` (implementación + Notas del Agente).
- Actualizados: fila 149 de `CHECKLIST-GLOBAL.md` (🟡 97/100), guía 08, `ESTADO-PARALELO.md`, `DOCUMENTACION/README.md`.

## Archivos Modificados/Creados

- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/npc-names.md` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/place-names.md` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/code-conventions.md` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/quick-reference.md` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validation-process.md` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validar_nombres.py` (creado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/plan-actual/05-Checklist.md` (actualizado)
- `DOCUMENTACION/149-Nombres-Y-Nomenclatura/plan-actual/04-Codigo.md` (actualizado)
- `CHECKLIST-GLOBAL.md` (fila 149)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (tabla Reserva actual)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada del lote)
- `DOCUMENTACION/README.md` (entrada módulo 149)
- `Logs/ULTIMO_NUMERO.txt` (200 → 201)

## Pendientes con dueño/programados (los 3 [?])

- Revisión de nombres con hablantes nativos → beta (fundador/comunidad).
- Pre-commit hook de naming → M111 (en curso; especificación lista).
- Evaluación de efectividad de convenciones → primera revisión trimestral con uso acumulado.