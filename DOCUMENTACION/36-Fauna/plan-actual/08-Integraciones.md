# 08-Integraciones.md — M36: Fauna

> Consolidación de diseño "vitrinas del museo" en el contexto real de M36=Fauna —
> Patrón D, 2026-10-13, Hy3 / WorkBuddy. Solo evidencia ya en disco.

## M36 ↔ M37 (Museos) / M159 (Catálogo de Objetos): vitrinas

- **Contenido de M36 para vitrinas:** `03-Diseno.md:19` — `FaunaSpecies (Resource)
  → datos puros + validación + ventana horaria/bioma`. Las especies son los datos
  que se exhiben en vitrinas de museo (M37).
- **Consumidores declarados:** `02-Analisis.md:27` —
  *"M09 Biomas / M32 Clima / M45 Visuales / M55-M37 UI (pendientes con dueño)"*.
  M37 (Museos) y M55 (UI diario) son los dueños de la vitrina/visualización.
- **Catálogo de especies:** M36 expone `FaunaCatalog` (`04-Codigo.md:21`,
  `candidatas_para(hora, bioma)`) — fuente de datos para el catálogo de objetos
  M159 y para las vitrinas de M37. M159 ya lista `OBJ-EST-006 | Vitrina` en
  `03-Diseno.md:65` y referencia M25/M37 en su 05-Checklist (items `[?]`).
- **Estado:** la integración Fauna→vitrinas está documentada a nivel de diseño
  (FaunaSpecies como dato exhibible; consumidores M37/M55/M159 declarados). La
  vitrina como asset/colocación es dueño de M37/M159. **No hay `[ ]` discreto de
  "vitrinas" en el 05-Checklist de M36 que cerrar** — el diseño ya está en
  02/03/04.

## Nota de etiqueta (no corregida aquí)

El director (msg 190) aclaró que la etiqueta "dueño de vitrinas" aplicada a M36
en diseños previos es una intención válida pero la reconciliación de etiquetas en
GLOBAL queda diferida ("no la corrijas ahora"). Se respeta: no se altera GLOBAL ni
la etiqueta.
