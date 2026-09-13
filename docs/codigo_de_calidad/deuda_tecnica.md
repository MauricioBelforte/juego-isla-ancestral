# Registro de Deuda Técnica - Isla Ancestral

> **Módulo:** M111 Código de Calidad
> **Versión:** 1.0
> **Fecha:** 2026-08-28
> **Ubicación:** `docs/codigo_de_calidad/deuda_tecnica.md`

---

## Formato de Registro

| Campo | Descripción |
|-------|-------------|
| **ID** | Identificador único (TD-XXX) |
| **Descripción** | Qué deuda técnica existe |
| **Prioridad** | Alta / Media / Baja |
| **Estado** | Abierta / En Progreso / Resuelta / Aceptada |
| **Dueño** | Responsable |
| **Estimación** | Horas/días estimados |
| **Módulo Afectado** | Módulo(s) relacionado(s) |
| **Fecha Creación** | YYYY-MM-DD |
| **Fecha Objetivo** | YYYY-MM-DD (opcional) |
| **Notas** | Contexto adicional, bloqueadores, dependencias |

---

## Criterios de Prioridad

| Prioridad | Criterios | Ejemplos |
|-----------|-----------|----------|
| **Alta** | Bloquea hito mayor, causa crashes, vulnerabilidad seguridad, memory leak crítico | SaveManager corrompe saves, EventBus memory leak, voxel web build roto |
| **Media** | Impacta performance significativa, dificulta testing/mantenimiento, bloquea feature | Godot warnings spam, falta tests en módulo core, acoplamiento excesivo |
| **Baja** | Mejoras cosméticas, refactorizaciones opcionales, documentación faltante | Nomenclatura inconsistente en archivos viejos, comentarios desactualizados |

---

## Registro Activo

### TD-001: Voxel Addon sin soporte Web (WASM)
- **Prioridad:** Alta
- **Estado:** Abierta
- **Dueño:** ox-alpha / Agente Voxel
- **Estimación:** 2-4 semanas (requiere fork/addon alternativo)
- **Módulo Afectado:** M04 Game Engine, M13 Herramientas, M27 Islas del Mundo
- **Fecha Creación:** 2026-08-25
- **Fecha Objetivo:** 2026-09-15
- **Notas:** El addon `zylann.voxel` no tiene binarios `wasm32`. En build web `main_isla.gd` falla al parsear y gameplay (WASD) está muerto. Desktop sin afectación. Ver tema `Mensajes entre modelos/04-Voxel-Sin-Soporte-Web/`. Bloquea M143 Lanzamiento en plataforma web.

### TD-002: Bootstrap deferred scene loading - race condition potencial
- **Prioridad:** Media
- **Estado:** Abierta
- **Dueño:** ox-alpha
- **Estimación:** 4-8 horas
- **Módulo Afectado:** M07 Arquitectura (Bootstrap)
- **Fecha Creación:** 2026-08-26
- **Fecha Objetivo:** 2026-09-01
- **Notas:** `bootstrap.gd` usa `call_deferred()` para cargar escenas. Si múltiples sistemas dependen de autoloads inicializados, puede haber orden indeterminado. Revisar `await` pattern o inicialización sincrónica por fases.

### TD-003: VillagerManager - iteración O(n) en _process para 100+ NPCs
- **Prioridad:** Media
- **Estado:** Abierta
- **Dueño:** ox-alpha / Agente M64 IA NPC
- **Estimación:** 1-2 días
- **Módulo Afectado:** M19 NPC y Vecinos, M64 IA NPC
- **Fecha Creación:** 2026-08-27
- **Fecha Objetivo:** 2026-09-10
- **Notas:** `villager_manager.gd` itera todos los villagers cada frame. Para escalar a 100+ NPCs, implementar: spatial partitioning, tick staggering, o mover lógica a thread (con Mutex + call_deferred).

### TD-004: EconomyManager - anti-grind band caps hardcoded en test
- **Prioridad:** Baja
- **Estado:** En Progreso
- **Dueño:** ox-alpha
- **Estimación:** 2-4 horas
- **Módulo Afectado:** M38 Economía
- **Fecha Creación:** 2026-08-26
- **Fecha Objetivo:** 2026-08-30
- **Notas:** Los topes por banda de rareza (anti-grind) están validados en `test_topos_banda.gd` pero la configuración vive en código. Mover a `PriceDefinition` resource (.tres) para que sea data-driven y editable en editor.

### TD-005: SaveManager - falta validación de checksum en saves
- **Prioridad:** Media
- **Estado:** Abierta
- **Dueño:** ox-alpha
- **Estimación:** 4-6 horas
- **Módulo Afectado:** M59 Guardado
- **Fecha Creación:** 2026-08-25
- **Fecha Objetivo:** 2026-09-05
- **Notas:** `save_writer.gd` y `save_loader.gd` no verifican integridad de archivos. Añadir CRC32 o SHA-256 en header del save para detectar corrupción. Requiere versión de schema bump (v4).

### TD-006: EventBus - 9 dominios sin documentación de contrato
- **Prioridad:** Baja
- **Estado:** Abierta
- **Dueño:** ox-alpha
- **Estimación:** 2-3 horas
- **Módulo Afectado:** M07 Arquitectura (EventBus)
- **Fecha Creación:** 2026-08-26
- **Fecha Objetivo:** 2026-09-05
- **Notas:** `event_bus.gd` define 9 dominios (GAMEPLAY, UI, AUDIO, SYSTEM, NPC, WORLD, TIME, ECONOMY, SAVE) pero no hay documento que especifique qué señales emite cada dominio, payloads esperados, y orden de emisión.

### TD-007: ItemDatabase - búsqueda lineal O(n) en get_item()
- **Prioridad:** Baja
- **Estado:** Abierta
- **Dueño:** ox-alpha / Agente M159 Catálogo
- **Estimación:** 1-2 horas
- **Módulo Afectado:** M159 Catálogo de Ítems
- **Fecha Creación:** 2026-08-24
- **Fecha Objetivo:** 2026-09-15
- **Notas:** `item_database.gd` usa Array + `find()` para lookup por ID. Con 500+ ítems, cambiar a Dictionary `id -> ItemData` para O(1). Requiere refactor de `register_item()`.

### TD-008: CodeQualityCheck - falsos positivos en complejidad ciclomática
- **Prioridad:** Baja
- **Estado:** Abierta
- **Dueño:** ox-alpha
- **Estimación:** 2-4 horas
- **Módulo Afectado:** M111 Código de Calidad
- **Fecha Creación:** 2026-08-28
- **Fecha Objetivo:** 2026-09-05
- **Notas:** El análisis de complejidad cuenta `match` arms y `when` clauses como flow control, inflando métrica. Refinar `_is_flow_control()` para distinguir estructuras reales vs pattern matching.

### TD-009: Pre-commit hooks - requieren Godot instalado localmente
- **Prioridad:** Media
- **Estado:** Abierta
- **Dueño:** ox-alpha
- **Estimación:** 4-8 horas
- **Módulo Afectado:** M111 Código de Calidad, M118 CI/CD
- **Fecha Creación:** 2026-08-28
- **Fecha Objetivo:** 2026-09-10
- **Notas:** `.pre-commit-config.yaml` usa `godot` command directamente. Para contributors sin Godot en PATH, falla. Opciones: (a) Docker image con Godot, (b) GitHub Actions only, (c) Documentar requisito en guía.

### TD-010: Falta tests de integración cross-módulo (M14+M38+M39)
- **Prioridad:** Media
- **Estado:** Abierta
- **Dueño:** ox-alpha / Agente M112 Testing
- **Estimación:** 1-2 días
- **Módulo Afectado:** M112 Testing Automático, M14 Inventario, M38 Economía, M39 Tiendas
- **Fecha Creación:** 2026-08-26
- **Fecha Objetivo:** 2026-09-15
- **Notas:** Loop end-to-end comprar→inventario→vender→saldo→reputación verificado manualmente (14/14 checks). Automatizar como test de integración GdUnit4 en CI.

---

## Historial Resuelto

### TD-R001: M29 TimeCalendar - anti-drift tick 1:40 implementado
- **Prioridad:** Alta (era)
- **Estado:** Resuelta
- **Resuelto:** 2026-08-28
- **Dueño:** ox-alpha
- **Notas:** `TimeCalendar` implementado con tick 1:40 (1 seg real = 40 seg juego), anti-drift accumulador, pausa/avanzar_hasta, EventBus calendar + ISaveProvider M59. Test 13/13 OK.

### TD-R002: M14 Inventario - class_name ItemData colisión con M159
- **Prioridad:** Alta (era)
- **Estado:** Resuelta
- **Resuelto:** 2026-08-26
- **Dueño:** ox-alpha
- **Notas:** Renombrado `ItemData` (M14) a `InventoryItemData` para evitar colisión con `ItemData` de M159 Catálogo. Contrato `/root/Inventario` verificado.

### TD-R003: M38 Economía - PriceManager anti-arbitraje/anti-grind
- **Prioridad:** Alta (era)
- **Estado:** Resuelta
- **Resuelto:** 2026-08-26
- **Dueño:** ox-alpha
- **Notas:** `PriceManager` implementado con precios dinámicos, clamp MAX_SALDO, descuento amistad verificado, test_loop_economico.gd 14/14 OK.

---

## Métricas de Deuda Técnica

| Métrica | Valor | Tendencia |
|---------|-------|-----------|
| **Total items abiertos** | 10 | ↑ |
| **Prioridad Alta** | 1 | → |
| **Prioridad Media** | 5 | ↑ |
| **Prioridad Baja** | 4 | → |
| **Items resueltos (últimos 30d)** | 3 | ↑ |
| **Tiempo medio resolución** | ~3 días | → |
| **Deuda técnica estimada total** | ~40-60 horas | ↑ |

---

## Políticas de Gestión

### Sprint Técnico (cada 3 meses / antes de hitos)
1. Revisar todas las deudas **Alta** - deben resolverse antes del hito
2. Seleccionar 2-3 deudas **Media** para el sprint
3. Opcional: 1 deuda **Baja** si capacidad permite
4. Actualizar estimaciones y dueños

### Umbral de Alerta (M133 Gestión del Proyecto)
- Si items **Alta** > 3 → Bloqueo de features nuevas
- Si items **Media** > 10 → Sprint técnico obligatorio
- Si deuda estimada total > 100h → Revisión arquitectura

### Definición de "Resuelta"
- [ ] Fix implementado y compila
- [ ] Tests pasan (unitarios + integración si aplica)
- [ ] CodeQualityCheck limpio (sin regresiones)
- [ ] Documentación actualizada (guía, CHANGELOG)
- [ ] Code review aprobado
- [ ] Merge a main

---

## Plantilla para Nuevo Registro

```markdown
### TD-XXX: Título descriptivo
- **Prioridad:** Alta / Media / Baja
- **Estado:** Abierta
- **Dueño:** [nombre/agente]
- **Estimación:** [horas/días]
- **Módulo Afectado:** [Módulo(s)]
- **Fecha Creación:** YYYY-MM-DD
- **Fecha Objetivo:** YYYY-MM-DD
- **Notas:** [Contexto, bloqueadores, dependencias, pasos para reproducir]
```

---

*Registro mantenido como parte del Módulo 111 - Código de Calidad*
*Actualizar en cada sprint técnico o cuando se detecte nueva deuda*