# 03 — Diseño — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Estructura (lineal-ramificada, voxel-compatible)

```
ENTRADA (pórtico, puerta principal sellada)
 └── VESTÍBULO (3 vías)
     ├── Sala de los Vientos (tutorial + 3 puzzles viento)   ← nucleo
     ├── 6 HABITACIONES INTERMEDIAS (2 luz, 1 agua, 1 presión, 1 sonido, 1 secuencia)
     │    └── pasillo del Artesano (alternativa lateral)
     ├── 4 SALAS SECRETAS (2+ caminos cada una)
     ├── SALA CENTRAL (mecanismo: 7 anillos de viento)
     ├── PUZZLE FINAL (3 fases: luz + sonido + agua)
     ├── CÁMARA DEL SELLO (pedestal, cutscene mínima)
     └── SALIDA (túnel del amanecer → puerto)
```

## Zonas y puzzles (ganchos M24)

| Zona | Puzzles | Banda | Checkpoint |
|---|---|---|---|
| Entrada | nada (intro) | — | — |
| Vestíbulo | nada (orientación) | — | CP1 |
| Sala de los Vientos | 3 de viento + tutorial guiado | Exploración | CP2 |
| Habitaciones intermedias | 6 (2 luz, 1 agua, 1 presión, 1 sonido, 1 secuencia) | Ritual | — |
| Pasillo del Artesano | 1 de herramientas (inventario M24) | Ritual | — |
| Salas secretas | 4 (2 luz, 1 símbolos, 1 gravidez) | Ritual | — |
| Sala central | mecanismo de 7 anillos (multilateral) | Antiguo | CP3 |
| Puzzle final | 3 fases (luz+sonido+agua) | Antiguo | CP4 |
| Cámara del Sello | pedestal (no-puzzle: narrativa) | — | CP5 |

## Mecanismo principal (7 anillos de la Columna)

- La rotonda contiene la Columna con 7 anillos de viento giratorios.
- 4 sellos de cristal se consiguen en las salas secretas; 3 se obtienen de habitaciones intermedias.
- Activar un anillo requiere el sello correspondiente + girar el anillo a la posición del glifo (M24 familia símbolos).
- Los 7 anillos juntos abren el puzzle final (estado de sala multiplex: `S[anillos]`).

## Sala del puzzle final (3 fases)

1. **Luz:** alinear el espejo maestro al rayo cenital (M24 luz, prisma).
2. **Sonido:** tocar 3 gongs en el orden de los glifos (M24 sonido, pista siempre visible tras 2 intentos).
3. **Agua:** timón de agua sube el nivel y trae el sello de la isla pequeña (M24 agua, barca).
→ Se abre la Cámara del Sello.

## Sistemas de soporte

- **Iluminación:** faros de cristal + luz volumétrica suave "brisa"; contraste ≥ 4.5:1 en iconografía (M58).
- **Sonido (M42/M43):** brisa por corredor, goteo, ambiences por banda (M41: capas hora/clima).
- **Partículas (M52):** polvo de luz en rotonda, viento visible; sin partículas decorativas sin función.
- **Materiales (M47):** piedra de brisa, cristal, bronce — 3 bases + variantes por edad.
- **Texturas (M47/M63):** 12 clave con LOD 0-2.
- **Iconografía:** 8 glifos del Sello (4 comunes + 4 de cámara); glosario en la Guía del Templo.
- **Navegación:** NavigationServer3D por piso; vínculos verticales (rampas 20°, huecos discretos); sin teleports (anti-exploit).
- **Orientación:** mojones visuales cada 40 m + mapa de zona simplificado (panel M58), prueba de deriva < 2 min.

## Checkpoints (patrón M66)

5 CP (porte, vestíbulo, vientos, central, sello) con guardado **atómico** (tmp+rename+.bak) y respaldo `.bak`. La telemetría de puzzle exporta JSON a M24.

## Reglas de gating (anti-exploit)

- La salida se abre **solo** con el sello restaurado (estado de mundo guardado).
- Sellos y llaves son objetos únicos que respetan el cofre de M66 (1 copia).
- Rampas con pendiente ≤ 20°; huecos con barreras invisibles; cero teleports (excepto recuperación M66 discreta).
- Acceleración por salto: se corona la rampa con borde superior; testeo automatizado del salto.

## Accesibilidad (M58)

- Iconografía en tamaño ≥ 16 px (LOD de texto), contraste ≥ 4.5:1, sin presión temporal en puzzles, subtítulos activables (M43), opciones de reducción de partículas y de parpadeo (fotosensibilidad).

## Rendimiento (M61)

- Sala de rotonda: ≤ 500k poligonos drawcall-friendly (1 dc por faro, instancing de columnas).
- Partículas ≤ 256 por escena; luz volumétrica solo en 2 salas fijas.
- El plano entero del templo cabe en el presupuesto por región de M63 (streaming por piso activable).