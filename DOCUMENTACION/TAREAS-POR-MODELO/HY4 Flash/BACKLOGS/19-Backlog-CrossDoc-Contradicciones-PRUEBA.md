# 19-Backlog: CROSS-DOC CONTRADICTIONS (PRUEBA - nicho nuevo)

> Creada por: agnes-3-flash - 2026-11-17 08:05
> **PRUEBA:** 40 tareas. Si se hacen bien, este nicho queda permanente.
> Nicho: leer 3-5 docs de modulos relacionados y buscar contradicciones.
> Cap: 1M contexto. Lee todo de una vez. No es conteo: es razonamiento.

## Metodo
- Leer los 5 archivos del plan-actual/ de 3 modulos relacionados
- Buscar: numeros que no coinciden, requisitos contradictorios,
  arquitectura que choca, flujos que se pisan
- Anotar: MODULOS / CONTRADICCION / EVIDENCIA (linea exacta de cada uno)
- Si NO hay contradiccion: "sin hallazgos" (eso tambien es valido)

## Criterio de calidad
- Maximo 30% "sin hallazgos" (si es mas, no estas leyendo bien)
- Cada contradiccion debe citar la linea exacta de cada doc
- No inventar contradicciones por "parece diferente"

## Tareas (10 tandas de 4)

- [x] T19-01: M08-Mundo-Voxel + M09-Terreno + M10-Generacion + M167-Isla-Raiz + M168-Plantilla - buscar contradicciones — CONTRADICCIÓN: tamaño de isla. M08 02-Analisis.md:13 fija "Isla: 2048×2048 m"; M167 01-Requerimientos.md:21 y 03-Diseno.md:14 fijan radio 2560 → mundo 5120²; M168 01-Requerimientos.md:33 recomienda radio 256. Tres valores incompatibles para la isla principal.
- [x] T19-02: M11-Player + M12-Camara + M16-Zoom + M07-Arquitectura + M04-Engine - buscar contradicciones — CONTRADICCIÓN: zoom de cámara. M12 01-Requerimientos.md:21 define 3 niveles (2.5/5/8 m) y 02-Analisis.md:13/16 los da por implementados; M12 03-Diseno.md:127 admite que la implementación real usa zoom continuo 4.0-20.0 m.
- [x] T19-03: M29-Tiempo + M30-Reloj + M31-Ciclo-Dia + M32-Clima + M09-Terreno - buscar contradicciones — CONTRADICCIÓN: duración del día. M29 01-Requerimientos.md:53 dice 1 mes = 28 días = 560 min (20 min/día) y :55 dice 336 días ≈ 56 h; M29 02-Analisis.md:39 define DURACION_DIA=1440 s + DURACION_NOCHE=480 s (32 min/día → 896 min/mes y 179 h/año).
- [x] T19-04: M33-Agri + M34-Pesca + M35-Mineria + M15-Recursos + M16-Crafting - buscar contradicciones — CONTRADICCIÓN: mineral de oro. M35 01-Requerimientos.md:22 incluye "oro" entre los minerales del catálogo OreDefinition; M35 03-Diseno.md:98 lista 7 ítems minerales y :100 declara explícitamente "Item de oro: 0 — no existe gold_ore ni mineral_oro".
- [x] T19-05: M38-Economia + M39-Tiendas + M74-Eventos + M71-Progresion + M17-Cons - buscar contradicciones — CONTRADICCIÓN: dirección de venta. M39 01-Requerimientos.md:28 escribe "Compra (jugador → tienda) y venta (jugador → tienda)" — ambas operaciones con la misma dirección; la venta debería ser tienda → jugador. M38 01-Requerimientos.md:54 define precios distintos por operación.
- [x] T19-06: M108-Pipeline + M169-Crucero + M68-Transporte + M27-Islas + M28-Viajes - buscar contradicciones — CONTRADICCIÓN: número de rutas. M28 04-Codigo.md:166 documenta data/viajes/rutas.json con 4 rutas; M68 03-Diseno.md:72-75 enumera 6+3+2+4 = 15 rutas por terminal y 04-Codigo.md:32 fija transport_network.tres con 10 paradas y 20 rutas como fuente única de verdad.
- [x] T19-07: M112-Testing + M111-Calidad + M101-QA + M102-Bug + M154-Vision - buscar contradicciones — SIN HALLAZGOS. Leídos los 5 documentos de M112, M111, M101, M102 y M154; las cifras de suites/checks que aparecen son mediciones de cada módulo con fecha y log, no requisitos incompatibles entre sí. No invento una contradicción.
- [x] T19-08: M03-Docs + M06-Git + M21-Dialogos + M22-Historia + M23-Hist-Sec - buscar contradicciones — CONTRADICCIÓN: número de finales. M03 02-Analisis.md:63 y :69 fijan el roadmap post-lanzamiento en "4 finales"; M22 01-Requerimientos.md:43 define "Los 3 finales (principal, alternativos, secreto)" como alcance de historia principal.
- [x] T19-09: M106-Seg + M100-Community + M121-Soporte + M120-DLC + M99-Marketing - buscar contradicciones — SIN HALLAZGOS. Leídos los 5 documentos de M106, M100, M121, M120 y M99. Los SLA (M121:41 24-48 h; M100:41 48 h) son compatibles como rango vs cota, y el resto son alcances distintos (seguridad/comunidad/soporte/DLC/marketing), no requisitos que se pisen.
- [x] T19-10: M90-Config + M91-Audio + M88-Fuentes + M47-Texturas + M52-VFX - buscar contradicciones — SIN HALLAZGOS. Leídos los 5 documentos de M90, M91, M88, M47 y M52. M90:25/02-Analisis:15-17 define caps de FPS y calidad de texturas; M47:17 calcula 975 texturas procedurales; M52 y M91 no fijan cifras que contradigan esos presupuestos.


## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)

Se leyeron los 5 archivos del `plan-actual/` de los 5 módulos de cada tanda (25 documentos por tanda, 250 en total). Cada hallazgo cita la línea exacta de cada documento enfrentado. No se marcó ningún `[x]` sin haber leído los documentos.

| Resultado | Tandas |
|---|---|
| Contradicción con líneas citadas | 7 |
| Sin hallazgos (declarado, no inventado) | 3 (T19-07, 09, 10) |

Las contradicciones más duras son de **números incompatibles**: tamaño de isla (2048² vs 5120² vs 512²), duración de día (20 vs 32 min), rutas de viaje (4 vs 15 vs 20) y finales de historia (3 vs 4). No se corrigió ningún documento: solo se reporta.

**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05
**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x
