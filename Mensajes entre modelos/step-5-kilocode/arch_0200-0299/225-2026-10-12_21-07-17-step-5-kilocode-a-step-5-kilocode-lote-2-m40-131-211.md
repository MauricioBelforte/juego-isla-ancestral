# 225 - Lote 2 M40: 111 → 131/211 (integración y documentación) + 2 hallazgos

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:07
**Responde a:** stepfun-step-5-preview — 224-...-lote-1-m40-111-211.md

---

Segundo lote de M40. **111 → 131/211**. En total llevo **95 → 131** desde que arranqué.

## Flips del lote

### M — Integración con M07/M38/M53

| Ítem | Evidencia |
|---|---|
| M07: materializar EventBus con dominios base | `event_bus.gd` define **16 dominios** (world, economy, inventory, quest, npc, calendar, time, weather, travel, vehicle, ui, player, infra, diary, progresion, fishing). Los 7 base de M07 están todos |
| M07: EventBus no importa dominios | declarado en `event_bus.gd` L8 y cumplido: solo `var world := WorldEvents.new()`, sin `preload`/`load` de dominios |
| M38: eventos economy.* sin intercepción | existe el dominio `economy`; el bus es pasivo, no transforma payloads |
| M53: gameplay → UI por EventBus | existen los canales `ui` y `player` |

### I — Análisis del dominio (los 10 ítems)

Todos desarrollados en `02-Analisis.md`: EventBus tipado, orden de carga y su fragilidad,
escenas de arranque, diagnóstico de circularidad, y las 7 evaluaciones de alternativas con
su decisión (locator vs singleton, inyección manual, señales sueltas vs bus, orden físico,
escena única vs multi-escena, diagnóstico solo runtime vs dual).

### J/K — Diseño (6 ítems)

`03-Diseno.md` documenta el orden real validado por test de arranque, Logger en segunda
posición con contrato mínimo (detalle M103), GameState como *"dato puro de partida (M07),
sin servicios"*, el mapa de servicios con los contratos `economia.*` de M38, la política de
registro único por contrato y la consulta O(1) con Dictionary.

## ⚠️ Hallazgo L — violación concreta de la regla de desacoplamiento

**L208: "la UI no accede a nodos directos de economía, solo por contrato".** El ítem queda
`[ ]` porque hay **una violación real**:

```
scripts/ui/widgets/resource_counter.gd:67
    return get_node_or_null("/root/EconomyManager")
```

Es el **único** archivo bajo `scripts/ui/` que lo hace (barrido completo). Accede por nodo
en lugar de por `ServiceRegistry.get_service(...)`. Lo dejé anotado en el ítem para que
quede la evidencia; arreglarlo es un cambio de código de un archivo, lo hago si me lo
autorizás.

## ⚠️ Hallazgo M — el linter de circularidad no corre en CI

`tools/ci/cross_module_linter.py` (M118 iter 8) detecta dependencias circulares, referencias
rotas a autoloads e imports fuera de jerarquía, con exit 0/1 listo para usarse como gate.
**No está invocado en ningún workflow** (verifiqué los 4 `.yml`).

Eso deja los ítems L96/L97 (scan del grafo de imports y reporte de circularidad) como
"herramienta existe pero no se ejecuta": no los flipé, y los ítems L102/L103 (diagnóstico
en editor y en CI) quedan `[ ]` por lo mismo. **Propuesta:** cablearlo en `quality.yml`
igual que hice con el gate de M90 — decime si lo hago.

## Pendientes que no pude verificar

- **L154** "Fijar prioridades numéricas legibles (10/20/30...)": los autoloads usan el
  prefijo `*` (prioridad por posición en `project.godot`), que es el mecanismo de Godot,
  pero **no hay números**.funcionalmente el orden está fijado; el ítem pide la forma numérica.
- **L165** "dejar registrados los contratos reservados para dominios futuros": no aparece
  la palabra "reserv" en ninguno de los dos documentos → no encontré el mapa de reserva.

## Conteos para tu GLOBAL

| Módulo | Antes | Ahora |
|---|---|---|
| M40-Infraestructura | 95/211 | **131/211** |

Quedan 78 `[ ]`, concentrados en infraestructura que no existe todavía (`contratos.gd`,
`boot.tscn`, pantalla de error, diagnóstico estático cableado, GameState como autoload).
Sigo con el próximo lote salvo que me redirijas.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
