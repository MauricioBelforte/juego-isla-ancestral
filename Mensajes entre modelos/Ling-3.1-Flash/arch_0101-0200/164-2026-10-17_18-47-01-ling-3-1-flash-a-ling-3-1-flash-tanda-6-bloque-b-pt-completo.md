# 164 — Tanda 6: Bloque B completo (tareas 6-18) — catálogo PT 147/147/147, 2 correcciones aplicadas

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 18:47:01
**Responde a:** Ling-3.1-Flash - 163-2026-10-17_18-32-30-ling-3-1-flash-a-ling-3-1-flash-tanda-5-analisis-3er-idioma-pt.md

Vuelta del cronómetro V2: sin mensajes nuevos del director → backlog (§2), Bloque B tareas 6-18 (completar/verificar strings_pt.json).

## Medición (control_i18n_tanda6.py)

- **Paridad final: ES/EN/PT = 147/147/147, 0/0/0 en todas las direcciones** (antes: PT 148 con 1 huérfana).
- 116 claves traducidas (difieren de ES) + 31 válidas: 28 cognatos idénticos ES/pt-BR (Visto, Favorito, Filtro, Todos, Vistos, Mapa, Pausa, Saldo, Ambiente, Aplicar, Buscar, Cancelar, Confirmar, Continuar, Créditos, Descartar, Música, Ordenar, Suave, Silenciar, Catálogo, Comprar, Comprar máx., Vender, Vender máx....) + `'???'` (símbolo) + `'{tipo}: {item}'` (placeholder puro) + `'Slots'` (técnico). **0 pendientes de traducción.**
- **Estructura del catálogo (plano, 147 claves):** DIARY (23), SETTINGS (61), TIENDAS (20), EQUIP (13), TUTORIAL (7), eventos.historia_c1-c7 (14), ui (6), msg (3), npc (2), LOADING (3), ITEMS (1), HUD (1), MAIN_MENU (1). El contenido de fauna M65/M36, vegetación M50, museo M37, MP M76, DLC M95, ubicaciones M160, WEAPONS M13/M15 y festival_* M74 son **datos dinámicos de cada módulo** (no claves del catálogo central) — la paridad 0/0 prueba consistencia PT↔ES donde el catálogo tiene claves.

## Correcciones aplicadas a strings_pt.json (2)

1. **Tarea 16 — huérfana `eventos.historia_c2_nome`: DECISIÓN = ELIMINAR, no rename.** La canónica `historia_c2_nombre` YA existía en PT con la traducción correcta ('A Ponte das Memórias'); `historia_c2_nome` era un fósil duplicado (mismo valor, **0 referencias** en código/tests — grep verificado). Renombrar hubiera colisionado con la clave existente. Resultado: PT 148→147, paridad exacta.
2. **Tarea 15 — `DIARY.CAT_LUGARES`: 'Lugares' → 'Locais'** (era la única copia-ES no cognato; clave consumida por prefijo dinámico `DIARY.CAT_` — reconocida por AuditorClaves, auditor_claves.gd L204).

## Tarea 17 — fallback revisado

`localization_manager.gd` L180-185: si la clave falta en el locale activo, cae a `LOCALE_DEFECTO` (ES) y avisa (`_avisar_faltante`, dedup). Como PT no está en el runtime (Tanda 4: `LOCALES_SOPORTADOS=[es,en]`), el fallback PT→ES no aplica hoy; al habilitar PT el fallback ya estará implementado.

## Trazabilidad (transparencia)

Las marcas `[x]` de las tareas 6-18 en BACKLOG-MASTER.md entraron en git vía el commit del fundador `faca499` (21:45, "Pre-asignacion del frente estetico premium") que capturó el working tree — hash worktree==HEAD verificado (`4ba5ac05`). Las 2 correcciones de strings_pt.json las commitea este mensaje (Ling). Durante la marcación, un script de aplicación masiva tocó 5 líneas de REGLAS del backlog (numeradas 6-10, mismos números que las tareas) — reparadas desde HEAD antes del commit del fundador; verificado limpio.

## Estado

Tareas 6-18 `[x]` en BACKLOG-MASTER. **Bloque B cerrado.** Sin flips de módulos. M87 sigue 🟡 131/136; conciliación .po↔JSON sigue en espera del fundador (msg 153). Próxima tanda: Bloque I (tarea 51, log de iteración) o lo que ordene el director.

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-17
