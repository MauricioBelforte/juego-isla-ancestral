# 03 — Diseño — M22: Historia Principal

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Grafo de escenas (datos, validado)

- Cada capítulo = subgrafo de nodos `Escena { id, tipo, requisitos, siguiente[] }`.
- Requisitos: puzzles (M24), sellos (M26), objetos (M25/M66), posición, estado del mundo (M08).
- Validación (Editor + tests): sin nodos huérfanos, sin ciclos infinitos, cada final alcanzable, sin requisitos rotos (M66).

```
[Prólogo] → C1 → C2 → C3 → C4 → C5 → C6 → [C7: La Brisa y el Sello]
             │     │     │     │     │     │             ├─ Final Principal (florece)
             │     │     │     │     │     │             ├─ Alternativo A (regresar)
             │     │     │     │     │     │             ├─ Alternativo B (guardián)
             │     │     │     │     │     │             └─ Final Secreto (epílogo)
             └──── pistas/foreshadows acumulados ────────────────*
```

## Arcos y ritmo

| Capítulo | Título | Tensión | Pico | Calma | Hooks |
|---|---|---|---|---|---|
| Prólogo | La Llegada | 2/5 | — | 1 | M32 tormenta, M26 hook |
| 1 | Las Cenizas Futuras | 3/5 | giro 1 | 1 | M25 mural |
| 2 | El Puente de las Memorias | 2/5 | — | 1 | M28 puente/M24 herramienta |
| 3 | El Jardín Ahogado | 4/5 | giro 2 | 2 | M24 agua, faro |
| 4 | El Valle de los Vientos | 5/5 | anillos | 2 | M26 templo |
| 5 | La Noche Eterna | 5/5 | eclipse | 1 | M31 |
| 6 | El Corazón del Mundo | 4/5 | geoda | 1 | volcán M26 |
| Final | La Brisa y el Sello | 3/5 | elección | 3 | M26 cámara |

## Giros, pistas y foreshadowing

- **Giro 1:** la "ceniza" del islote no es volcánica: es la quema de la biblioteca de la civilización (goteo de lore en mural).
- **Giro 2:** la sombra que asusta a la aldea es la sombra del propio Templo (no un monstruo) — cozy.
- **Giro 3:** el Sello no estaba roto; fue escondido para proteger a la aldea (el guardián).
- **30 pistas** sobre el final secreto (listado de colocación por punto de interés).
- **10 foreshadows** explícitos (7 glifos, la brisa del prólogo, el faro ciego...) que pagan en la Cámara.

## Revelaciones (6) e información oculta (5 caches)

Las revelaciones se desbloquean por contextualizar (mural + inscripción + objeto) — nunca por texto gratuito.
Los 5 caches de lore oculto están en: biblioteca M25, geoda volcánica, plataforma del faro, sala bajo el acuífero (M26), y la estatua del Primer Guardián.

## Secuencia de Templos y Sellos

- **Templos:** Ceniza (ruina M25) → Mar (agua M24) → Brisa (M26). Progresión, no linealidad obligatoria.
- **Sellos:** 7 (4 salas secretas + 3 intermedias); el jugador elige orden; M26 los valida.
- El gating real del capítulo 4 (Valle de los Vientos) y final es: 7 sellos + templo abierto.

## Anti-exposición (regla medible)

- Máx 4 líneas expositivas por escena; el resto por mundo (objetos inspeccionables, murales, inscripciones, diario).
- Test de guion por escena: palabras por diálogo ≤ 140; sin bloques de texto ≥ 4 líneas.

## Integración

- **M21/misiones:** la Historia Principal es la columna; las misiones verifican los requisitos del grafo.
- **M23 (secundarias):** los NPC del pueblo pueden comentar la trama (hooks), sin bloquear el grafo.
- **M26:** los 7 sellos son el puente narrativo; la Cámara del Sello es el nodo final.
- **M33 (cutscenes):** 4 momentos emotivos tienen hook de escena (Baile de la Brisa, restauración del jardín, eclipse, regreso).
- **M41/M44:** música mayordoma de los momentos; muestras del "tema de la Brisa" (leitmotif).
- **M66:** todos los requisitos del grafo son verificables (sin softlock); el final secreto es alcanzable.

## QA

- Suite de guion: validación del grafo (nodos, requisitos), test de exposición, test de leak (pista sin pagar), caminos a finales (3 + secreto) ejecutables en sesión de test automatizada.