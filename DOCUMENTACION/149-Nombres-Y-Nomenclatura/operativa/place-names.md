**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 149-Nombres-Y-Nomenclatura
**Estado:** Implementación operativa (entregable M149)

---

# Guía de Nombres de Lugares (`place-names`) — Módulo 149

> **Frontera:** las 60 ubicaciones del mundo son de **M160** (Diseño de Ubicaciones) y su lore de **M147/M148**. Aquí se define el **sistema de nombres** y se listan los lugares canónicos ya documentados, con reglas para nombrar los nuevos.

## 1. Categorías y reglas

| Categoría | Regla de naming | Ejemplos |
|---|---|---|
| **Islas** | Un sustantivo evocador único, mayúscula, sin artículo | **Aurora**, **Raíz**, **Coral**, **Ceniza** (canon M160/M27) |
| **Área natural** | `[Sustantivo evocador]` + `de/del + [elemento natural]`, máx 4 palabras | Playa del Despertar, Valle Serena (propuesta) |
| **Edificio importante** | `[Tipo]` + `de/del la/los + [elemento abstracto]` | **Templo de la Brisa** (canon M24/M139), Casa del Farolero (propuesta) |
| **Punto de referencia** | `[Objeto]` + `de/del + [deseo/momento]` | **Gran Vapor** (canon, ruta M139/M162), Fuente del Deseo (propuesta), **Mirador del Alba** (wow WM-5, M146) |
| **Área de juego** | Funcional y neutro, visible solo en HUD/debug | Zona de Construcción, Zona Segura de Inicio (spawn, M09) |

Reglas generales:
1. **Máximo 4 palabras**; idealmente 2-3.
2. **Evocadores, no descriptivos-secos:** "Templo de la Brisa" ✓ / "Edificio 3" ✗.
3. **El nombre cuenta algo** (quién lo nombró, qué pasó ahí — fodder para M147/M148): toda adopción incluye 1 línea de porqué.
4. **Coherencia fonética por isla** (misma regla que NPCs §1.5 en npc-names).
5. **Sin nombres reales** de lugares/marcas/personas.
6. Los nombres propios de lugares **nunca se traducen**; se transliteran (H-localización §h). El tipo sí se traduce ("Templo" → "Temple").

## 2. Tabla de lugares canónicos y principales

| Lugar | Categoría | Significado/intención | Estado |
|---|---|---|---|
| Isla **Aurora** | Isla | La isla del amanecer; inicio del juego | **CANON** (M09/M160) |
| Isla **Raíz** | Isla | Origen, lo antiguo; chamán del monte (M163) | **CANON** (M160) |
| Isla **Coral** | Isla | Vida marina, color | **CANON** (M160) |
| Isla **Ceniza** | Isla | Volcánica, dura | **CANON** (M160) |
| **Templo de la Brisa** | Edificio | Primer templo; puzzles con viento (M24/M26/M139) | **CANON** |
| **Gran Vapor** | Punto de referencia | Nave/ruta de vapor hacia Coral (M139/M162) | **CANON** |
| **Mirador del Alba** | Punto de referencia | Vista completa de la isla (wow WM-5, M146) | PROPUESTA (coherente con M146) |
| **Playa del Despertar** | Área natural | Spawn del jugador (M09: playa) | PROPUESTA (nombra el canon del spawn) |
| **Fuente del Deseo** | Punto de referencia | Plaza del pueblo (M74 festivales) | PROPUESTA |
| **Casa del Farolero** | Edificio | NPC guardián del faro (objetivo del slice M138) | PROPUESTA |
| **Zona Segura de Inicio** | Área de juego | Spawn seguro documentado en M09 | CANON funcional |

## 3. Mapa de referencias (dónde se usa cada nombre)

| Nombre | Aparece en |
|---|---|
| Auroras e islas | M27/M160 (mapas), M22 (historia), M54 (mapa HUD), M87 (localización) |
| Templos | M24/M26/M139, M148 (pistas), M41 (leitmotif de templo, M150) |
| Pueblos/casas | M18, M19/M161 (NPC), M74 (festivales) |
| Áreas de juego | M110 (debug menu), M63 (streaming), coordenadas internas (IDs técnicos, no nombres artísticos) |

Regla: el **nombre artístico** y el **ID técnico** son mundos separados (un lugar es "Templo de la Brisa" en juego y `templo_brisa_main.tscn` / POI `poi_tem_001` en datos — ver `code-conventions.md` §IDs).

Regla: el **nombre propio** nunca se traduce; se translitera. El **tipo** se traduce. Ejemplo de tabla de equivalencias (formato para M87; tabla completa de 60 ubicaciones = dueño M87):

| Lugar | Español (base) | English | Deutsch | Français | Português | Italiano |
|---|---|---|---|---|---|---|
| Templo de la Brisa | Templo de la Brisa | Temple of the Breeze | Tempel der Brise | Temple de la Brise | Templo da Brisa | Tempio della Brezza |
| Gran Vapor | Gran Vapor | Grand Steam | Großer Dampf | Grande Vapeur | Grande Vapor | Gran Vapore |
| Mirador del Alba | Mirador del Alba | Dawn Lookout | Dawn-Aussichtspunkt* | Belvédère de l'Aube | Mirante da Alvorada | Belvedere dell'Alba |

*En scripts de escritura no latina (M87): transliteración fonética del nombre propio, traducción del tipo.

## 4. Mapa de adoptación

Todo lugar nuevo: proponer con el template de `npc-names.md` §4 (adaptado) → validar reglas §1 → registrar en M160 (mapa) y M147 (canon) → recién entonces puede usarse en escenas/datos.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
