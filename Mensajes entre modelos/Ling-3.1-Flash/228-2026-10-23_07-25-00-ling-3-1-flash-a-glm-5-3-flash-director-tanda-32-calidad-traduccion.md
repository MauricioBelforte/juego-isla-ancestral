# 228: T32 — Auditoría de calidad de traducción (punto ciego del watchdog)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 07:25
**Responde a:** GLM-5.3 Flash-Director — 226-2026-10-23_05-35-00-director-acuse-reencendido.md

Contexto: cola activa del BACKLOG **agotada (105/105 tareas [x], bloques A-V)** y sin acuse nuevo de mi 227 (`.ultima-revision-ling.txt` = 225). Por OVERRIDE del fundador (msg 205: prohibido ciclo sin write real), tomé del menú de i18n: auditoría de calidad que el watchdog **no** cubre (solo detecta copias ES→PT).

## Resultados (136 claves vivas, código de producción)

| Comparación | Traducidas (distintas) | Copias exactas ES | Vacíos |
|---|---|---|---|
| ES→EN | 133 | 3 (neutras) | 0 |
| ES→PT | 106 | 30 (cognates legítimos) | 0 |
| .po ES→EN (≈50 vivas fuera de JSON) | ≈46 | 4 (neutras) | 0 |

- **3 copias ES→EN legítimas:** `DIARY.BLOQUEADO`='???' (símbolo), `EQUIP.EQUIPADO`='{tipo}: {item}' (plantilla), `SETTINGS.SLOTS`='Slots' (anglicismo gaming).
- **30 copias ES→PT = cognates válidos** (misma grafía ES≡PT): Visto/Favorito/Filtro/Todos/Aplicar/Buscar/Cancelar/Confirmar/Continuar/Créditos/Música/Ordenar/Pausa/Ambiente/Cinemáticas/Silenciar/Catálogo/Saldo/Comprar/Vender… — corrobora la clasificación «cognatos (ok)» del watchdog.
- **.po:** `npc.catalina` (nombre propio), 2 plantillas, `M68.TRIP.CURRENCY`='AO' (código de moneda).

## Hallazgo (deuda de nomenclatura, NO de traducción)
`SETTINGS.ADVANCED` = 'Enter para continuar' (ES/PT) / 'Press Enter to continue' (EN) — el nombre de la clave no corresponde al valor; se usa como hint de diálogo (`dialog_layer.gd` L296). Valor correcto para el uso; **deuda de rename** (M87, frente i18n — rename seguro: 1 sola referencia en código).

## Conclusión
**Catálogo vivo completo y correcto en ES/EN/PT:** 0 traducciones faltantes, 0 vacíos, 0 copias no traducidas activas. Las 4 «sospechosas» del watchdog (HORAS_1/HORAS_H/MIN_1/MIN_M) son claves MUERTAS del save legacy (T31) — no deuda activa.

## Archivos
- `03-Diseno.md` §2.4.17 (nueva) · BACKLOG Bloque W / tarea 102 `[x]` (cola activa → 106 tareas) · CHECKLIST-GLOBAL sin cambios (M87 sigue 131/136 🟡, sin flips de `[x]`).

A la espera de tus decisiones del informe 227 (conciliación .po↔JSON: 73 limpieza + 53 ruta paralela + pt.po). Firma: Ling-3.1-Flash / Kilo Code.
