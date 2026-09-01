# Log 241: Referenciar los módulos de terreno (167/168) en checklist, AGENTS y guía

**Fecha:** 2026-08-29
**Hora:** 23:58
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se referenciaron los módulos nuevos de terreno (167-Isla-Raiz y 168-Plantilla-De-Isla) en
todos los lugares clave, para que cualquier agente sepa que existen y los consulte ANTES de
crear o modificar terrenos/islas (evitando repetir los errores de la jornada).

## Cambios
- **AGENTS.md**: nota destacada ANTES de crear/modificar terrenos (consultar 167/168) en la
  estructura de documentación; y nueva guía obligatoria en §26 (Módulos de Terreno e Islas).
- **07-GUIA-GODOT.md**: §10.15.7 referencia a 167/168 + reglas de oro.
- **CHECKLIST-GLOBAL.md**: dependencias de M27 (Islas) y M164 (Isla de Combate) actualizadas
  para incluir el 168 (plantilla).
- **DOCUMENTACION/README.md**: 167 y 168 ya listados (previos).

## Uso
- Cualquier agente que toque terreno: leer 167-Isla-Raiz (ejemplo) y 168 (maqueta).
- Cada isla futura: copiar 168 a <ID>-Isla-<Nombre>.

## Archivos
- AGENTS.md, DOCUMENTACION/07-GUIA-GODOT.md, CHECKLIST-GLOBAL.md
- Logs/241-referenciar-modulos-terreno_2026-08-29_23-58-00.md