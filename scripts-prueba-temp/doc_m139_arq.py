# -*- coding: utf-8 -*-
import io

p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/04-Codigo.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

# 1) marcar que sesion_master.gd ya fue creado (fila de la tabla 1.1)
viejo = "| `scripts/core/sesion_master.gd` | Flujo de fase: men\xc3\xba → mundo, GONOGO local, inicializaci\xc3\xb3n de managers | M07/M53/M139 |"
nuevo = "| `scripts/core/sesion_master.gd` | Flujo de fase: men\xc3\xba → mundo, GONOGO local, inicializaci\xc3\xb3n de managers — **CREADO 2026-10-14** (contrato de ciclo de vida; activaci\xc3\xb3n pendiente, ver secci\xc3\xb3n 7) | M07/M53/M139 |"
if viejo in t:
    t = t.replace(viejo, nuevo, 1)
    print("fila 1.1 actualizada")
else:
    print("AVISO: no se encontro la fila de sesion_master")

seccion = """
## 7. Arquitectura de arranque (implementada 2026-10-14 por step-5-kilocode)

Cierra los 4 primeros \xedtems `[ ]` de la secci\xc3\xb3n 1 del `05-Checklist.md` (Arquitectura de la
fase, M07) con artefactos reales en disco.

### 7.1 Contratos de interfaces entre capas — COMPLETO

| Interfaz | Archivo | Estado |
|---|---|---|
| `IInteractable` | `scripts/interfaces/i_interactable.gd` | preexistente (M70, 2026-09-01) |
| `ITienda` | `scripts/interfaces/i_tienda.gd` | **creado** — comprar/vender/precio/stock/horario |
| `ITemplo` | `scripts/interfaces/i_templo.gd` | **creado** — ofrendar/bendici\xc3\xb3n/puzzle |
| `IViajable` | `scripts/interfaces/i_viajable.gd` | **creado** — solicitar/cancelar/progreso/destinos |

Las 3 nuevas siguen el patr\xc3\xb3n de `IInteractable` v2: m\xc3\xa9todos con default neutro para no
romper implementadores parciales. Consumidores previstos identificados: `ShopManager`/`shop.gd`
(M39), servicio de viajes `travel_service.gd` (M28) y templos (M26, sin script a\xfan).

### 7.2 `SesionMaster` — DEFINIDO, activaci\xc3\xb3n pendiente

`scripts/core/sesion_master.gd` define el \xc3\xbanico orquestador de arranque: m\xc3¡quina de estados
`INACTIVA → INICIALIZANDO → ACTIVA → CERRANDO → CERRADA`, inicializaci\xc3\xb3n por capas
(Infra → World Services → Managers → UI), cierre en orden inverso y registro de servicios v\xc3\xada
`ServiceRegistry` (autoload existente).

**Estado honesto:** el juego hoy arranca con `run/main_scene="res://scenes/main_island.tscn"` +
~20 autoloads en `project.godot`; **no hay SesionMaster activo**. El script es la definici\xc3\xb3n del
contrato. Activarlo como autoload requiera validaci\xc3\xb3n en runtime (no hecha en este frente para
no romper producci\xc3\xb3n), por eso el \xedtem del checklist qued\xc3\xb3 `[ ]` con esa nota.

### 7.3 Flujo de sesi\xc3\xb3n documentado

`men\xc3\xba principal` → (`continuar` | `nuevo juego`) → `SesionMaster.inicializar(nueva_partida)` →
carga de zona (`ZonaManager`, M63) → mundo activo → tick de sesi\xc3\xb3n → cierre en orden inverso.
Durante la carga la UI queda deshabilitada (regla M53: la UI nunca decide gameplay).

### 7.4 Modo degradaci\xc3\xb3n si un servicio falla al arrancar (M66)

Si un servicio de capa Infra/World/Managers falla al inicializar, la sesi\xc3\xb3n **no aborta**:
1. Se registra el fallo (`GameLogger` + telemetr\xc3\xada M105) con el nombre del servicio y el motivo.
2. El servicio queda marcado como degradado; sus consumidores reciben el default neutro del contrato.
3. Si el fallo es de guardado (`SaveManager`/M59), se ofrece recuperar copia o empezar partida nueva
   (patr\xc3\xb3n ya usado por `integridad_save`/M66 y por el ant\xed-softlock `SoftlockGuard`).
4. La sesi\xc3\xb3n contin\xc3\xba en modo degradado; el GONOGO de fase (M140) exige que los fallos
   degradados est\xc3\xa9n documentados antes de pasar a Alpha.
"""

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t.rstrip("\n") + "\n" + seccion)
print("seccion 7 agregada")
