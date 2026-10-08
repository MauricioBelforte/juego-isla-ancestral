# Frente: 86 timestamps stale del GLOBAL — clasificación a/b/c

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08
**Encargo:** director, msg 135 §3 (frente asignado a s2)
**Fuente:** `TAREAS-POR-MODELO/atria-dawn-s3/L-06-timestamps-stale.md` (86 stales)
**Estado:** desglose ANTES de tocar el GLOBAL (el director pidió ver el criterio)

## Criterio operacional propuesto

- **(a) Actividad real que avanzó el módulo → actualizar `Última actividad`.** El log registra
  trabajo sustantivo sobre el módulo: implementación/iteración con código o data nueva,
  fix de un bug del propio módulo, cierre de items pendientes, o flips de items
  (incluyendo degradaciones y correcciones de drift, que cambian la fila del GLOBAL).
- **(b) Actividad que NO cambió el estado → NO actualizar, con motivo.** El log solo
  auditó/verificó/selló sin tocar items (auditorías T-D7 "sustentado, 0 degradaciones",
  QA §21.8 confirmatoria, re-verificaciones, veredictos "deuda real" sin flip), o el
  módulo aparece como mención pasiva (fix de OTRO módulo).
- **(c) Error → arreglar.** Fecha imposible, formato roto, o log que no trata del módulo
  (falso positivo del método de s3, que indexa por nombre de archivo).

## Totales

| Categoría | Cantidad | Acción |
|-----------|----------|--------|
| (a) Avance/cambio de estado | 30 | actualizar `Última actividad` a la fecha del log |
| (b) Sin cambio de estado | 56 | NO actualizar (motivo documentado abajo) |
| (c) Error | 0 | arreglar |

**Hallazgo (c):** 0 errores. Los 86 logs existen, mencionan al módulo y las fechas del
GLOBAL son fechas pasadas válidas. El método de s3 (indexar por nombre de archivo)
no produjo falsos positivos en este lote.

## Detalle (a) — actualizar (30)

| MID | Módulo | Log | Fecha nueva | Motivo |
|-----|--------|-----|-------------|--------|
| 4 | 04-Game-Engine | 1403 | 2026-10-07 | Fix de `inferir_estado` aceptado por el director + correccion de protocolo (fix real) |
| 8 | 08-Mundo-Voxel | 1263 | 2026-10-04 | BUG-091 fix real: verificacion terraindata / fix provider |
| 12 | 12-Camara | 1079 | 2026-09-19 | Cierre FASE 3: 2 items [ ] -> [?] con dependencias documentadas (flips) |
| 41 | 41-Musica | 1375 | 2026-10-06 | Auditoria T-D7 bloque 5: 2 [x] de M41 degradados (cambio de estado) |
| 45 | 45-Arte-3D | 1356 | 2026-10-06 | Auditoria T-D7 bloque 1: M45 degradado (cambio de estado) |
| 57 | 57-Interfaz-De-Control | 958 | 2026-09-09 | Fix real de codigo: MinimapWidget robaba el scroll del zoom (bug del usuario) |
| 59 | 59-Guardado | 1397 | 2026-10-06 | BUG-115 fix real: HMAC + validacion no vacua |
| 62 | 62-Memoria | 1391 | 2026-10-06 | BUG-069: ciclos CERRADOS (A1 1 -> 0) + estado medido |
| 64 | 64-IA-De-NPC | 1330 | 2026-10-05 | Drift de la fila M64 corregido por el director (100->78). NOTA: correccion de conteo, no avance de implementacion |
| 74 | 74-Eventos | 777 | 2026-09-07 | Fix real: BOM UTF-8 en los 7 .tres de capitulos M74 (Parse Error del editor) |
| 75 | 75-Postgame | 682 | 2026-09-05 | Iter. 3: 3 items de persistencia verificados contra codigo (17/130) |
| 76 | 76-Multijugador | 1387 | 2026-10-06 | Auditoria T-D7 bloque 8: 3 [x] de M76 degradados (cambio de estado) |
| 77 | 77-Online-Y-Red | 1356 | 2026-10-06 | Auditoria T-D7 bloque 1: M77 degradado (cambio de estado) |
| 80 | 80-Legal-Privacidad | 425 | 2026-09-02 | Implementacion del nucleo iter. 1 (privacidad.json + PrivacyValidator) |
| 85 | 85-Modelos-3D-Legal | 1424 | 2026-10-07 | Re-auditoria DoD: veredicto INFLADO, 4 [x] -> [ ] + nota. NOTA: degradacion por auditoria, no avance |
| 97 | 97-Steam-Store-Page | 420 | 2026-09-02 | Implementacion iter. 1 (store_page.json + StorePageValidator) |
| 98 | 98-Trailer | 421 | 2026-09-02 | Implementacion iter. 1 (trailer_spec.json + TrailerValidator) |
| 99 | 99-Marketing | 422 | 2026-09-02 | Implementacion iter. 1 (marketing_plan.json + MarketingValidator) |
| 103 | 103-Logging | 1323 | 2026-10-05 | T-D8: cierre del falso positivo del frame-budget, [?] del checklist cerrados con justificacion |
| 112 | 112-Testing-Automatico | 1453 | 2026-10-08 | Fix real del CI: quitados los 2 `|| true` del job lint de testing.yml |
| 114 | 114-Playtest | 481 | 2026-09-01 | Implementacion iter. 1 (plantillas playtest + PlaytestValidator) |
| 115 | 115-Hardware | 1078 | 2026-09-19 | Reconciliacion post-revert: codigo real verificado y flips restaurados (0/104 -> sustentado) |
| 118 | 118-CI-CD | 1125 | 2026-09-19 | Reversion del estado M118 ✅ -> 🟡 (Caso A) + BUG-072 (cambio de estado) |
| 119 | 119-Actualizaciones | 1157 | 2026-09-25 | P-41 reconciliacion plan<->disco: 9 flips + saneo de 04-Codigo (queda 🟡 QA-drift-doc) |
| 128 | 128-Identidad-De-Marca | 1067 | 2026-09-19 | Completitud de contenido de marca: 5 -> 53/100 (avance real de items) |
| 154 | 154-Vision-Del-Agente | 302 | 2026-08-31 | Avance significativo de implementacion (131/155) |
| 156 | 156-Terrenos-Y-Movimiento | 1388 | 2026-10-06 | Auditoria: 9 [x] degradados a [?] (243 -> 234). NOTA: degradacion por auditoria, no avance |
| 159 | 159-Catalogo-De-Objetos | 477 | 2026-09-01 | Iter. 2: catalogo ampliado a 94 .tres + tests ItemDatabase |
| 160 | 160-Diseno-De-Ubicaciones-Del-Mund | 1137 | 2026-09-24 | Cierre de los 3 pendientes heredados + header M160 (cierre de items) |
| 161 | 161-Diseno-Visual-De-NPCs | 396 | 2026-09-02 | Iter. 1: base de datos visual de los 23 NPCs cargada en .tres |

## Detalle (b) — NO actualizar (56)

| MID | Módulo | Log | Motivo (no hubo cambio de estado) |
|-----|--------|-----|-------------------------------|
| 3 | 03-Documentacion-Del-Proyecto | 1283 | Auditoria T-D4 de M03 contra disco (verificacion, sin flips) |
| 7 | 07-Arquitectura-General | 1155 | P-40: cierre de discrepancia, veredicto final 'modulos limpios' (sin cambio) |
| 9 | 09-Terreno-Y-Geografia | 1115 | QA visual puntual del impostor de M09 (verificacion) |
| 13 | 13-Herramientas | 1073 | Re-verificacion §21.8 M13 (sello, sin cambio de items) |
| 14 | 14-Inventario | 1390 | QA §21.8 M14 SELLADA (solo sello) |
| 15 | 15-Recursos | 1369 | Auditoria T-D7 bloque 4: sustentado, 0 degradaciones |
| 16 | 16-Crafting | 1364 | Auditoria T-D7 bloque 3: sustentado, 0 degradaciones |
| 19 | 19-NPC-Y-Vecinos | 1049 | Triage V-3 (bug latente, antorcha no instanciada) + observacion al dueño: sin fix aplicado |
| 20 | 20-Sistema-De-Amistad | 1364 | Auditoria T-D7 bloque 3: sustentado, 0 degradaciones |
| 21 | 21-Dialogos | 1364 | Auditoria T-D7 bloque 3: sustentado, 0 degradaciones |
| 26 | 26-Templo-Subterraneo | 1359 | Auditoria T-D7 bloque 2: sustentado, 0 degradaciones |
| 29 | 29-Tiempo-Y-Calendario | 1369 | Auditoria T-D7 bloque 4: sustentado, 0 degradaciones |
| 30 | 30-Reloj-En-Tiempo-Real | 1369 | Auditoria T-D7 bloque 4: sustentado, 0 degradaciones |
| 31 | 31-Ciclo-Dia-Noche | 1369 | Auditoria T-D7 bloque 4: sustentado, 0 degradaciones |
| 32 | 32-Clima | 1145 | QA §21.8 P-31: M32 ✅ sellado (solo sello) |
| 33 | 33-Agricultura | 1375 | Auditoria T-D7 bloque 5: sustentado, 0 degradaciones |
| 34 | 34-Pesca | 1375 | Auditoria T-D7 bloque 5: sustentado, 0 degradaciones |
| 35 | 35-Mineria | 1375 | Auditoria T-D7 bloque 5: sustentado, 0 degradaciones |
| 36 | 36-Fauna | 1375 | Auditoria T-D7 bloque 5: sustentado, 0 degradaciones |
| 38 | 38-Economia | 1445 | QA §21.8 M38: verificacion OK, flag de concentracion familiar (sin sello propio) |
| 50 | 50-Vegetacion | 1379 | Auditoria T-D7 bloque 6: sustentado, 0 degradaciones |
| 51 | 51-Agua | 1379 | Auditoria T-D7 bloque 6: sustentado, 0 degradaciones |
| 52 | 52-Particulas-Y-VFX | 1390 | QA §21.8 M52 SELLADA (solo sello) |
| 53 | 53-UI-UX | 1379 | Auditoria T-D7 bloque 6: sustentado, 0 degradaciones |
| 54 | 54-Mapa | 1379 | Auditoria T-D7 bloque 6: sustentado, 0 degradaciones |
| 58 | 58-Accesibilidad | 1398 | Paquete opcion 1 bloque A: M58 sustentado, 0 degradaciones |
| 60 | 60-Datos-Y-Serializacion | 1389 | QA §21.8 M60 SELLADO (solo sello) |
| 63 | 63-Cargas-Y-Streaming | 1393 | Re-QA de tercero: sello §21.8 de M63 re-establecido (solo sello) |
| 78 | 78-Legal-Propiedad-Intelectual | 1440 | BUG-121 cerrado con fix en fauna; M78 aparece como '0 SCRIPT ERROR en M78' (mencion pasiva) |
| 83 | 83-Licencias-De-Software | 1386 | BUG-078: verificacion del job `godot-lint` en checkout limpio (verificacion) |
| 89 | 89-Diseno-De-Menus | 1395 | QA §21.8 M89 SELLADA + 1 hallazgo ajeno reportado (solo sello) |
| 90 | 90-Configuracion-Grafica | 1385 | Auditoria T-D7 bloque 7: M39 sustentado; M90 'deuda señalada' (sin flip) |
| 91 | 91-Configuracion-De-Audio | 1398 | Paquete opcion 1 bloque A: M91 sustentado, 0 degradaciones |
| 93 | 93-Balance | 1405 | Paquete opcion 1: M93 sustentado, 0 degradaciones |
| 100 | 100-Community-Management | 1422 | Re-auditoria DoD: veredicto DEUDA REAL, 'no flip, no inflado' (explicito) |
| 102 | 102-Bug-Tracking | 767 | Verificacion cruzada §21.8 M102 (solo validacion de artifacts) |
| 105 | 105-Telemetria-De-Gameplay | 1433 | Re-auditoria DoD ronda 2: 'Cero flips' (explicito) |
| 106 | 106-Seguridad | 1389 | QA §21.8 M106 SELLADO (solo sello) |
| 107 | 107-Backups | 1440 | BUG-121 cerrado con fix en fauna; M107 solo aparece como '0 SCRIPT ERROR en M107' (mencion pasiva) |
| 108 | 108-Pipeline-De-Assets | 1433 | Re-auditoria DoD ronda 2: 'Cero flips' (explicito) |
| 109 | 109-Herramientas-Internas | 1075 | Reparacion de trazabilidad documental de M109 (mantenimiento de docs, sin cambio de items) |
| 110 | 110-Debug-Menu | 1440 | BUG-121 cerrado con fix en fauna; M110 aparece como '0 SCRIPT ERROR en M110' (mencion pasiva) |
| 111 | 111-Codigo-De-Calidad | 1450 | QA §21.8 M111 (sello de DeepSeek; fixes H1/H4 son de M78, no de M111) |
| 113 | 113-Pruebas-De-Stress | 1423 | Re-auditoria DoD: veredicto DEUDA REAL, 'no flip, no inflado' (explicito) |
| 116 | 116-Instalador | 1400 | Paquete opcion 1: M116 sustentado, 0 degradaciones |
| 131 | 131-Creditos | 1447 | QA §21.8 M131: verificacion OK (solo sello) |
| 133 | 133-Gestion-Del-Proyecto | 1148 | QA cruzado §21.8 P-34: sello de doble fuente (solo sello) |
| 134 | 134-Presupuesto | 1148 | QA cruzado §21.8 P-34: sello de doble fuente (solo sello) |
| 135 | 135-Riesgos-Del-Proyecto | 1148 | QA cruzado §21.8 P-34: sello de doble fuente (solo sello) |
| 136 | 136-Roadmap | 1148 | QA cruzado §21.8 P-34: sello de doble fuente (solo sello) |
| 149 | 149-Nombres-Y-Nomenclatura | 1443 | Verificacion del [?] restante (99/100): veredicto deuda externa (sin flip) |
| 152 | 152-Principios-Innegociables | 1400 | Paquete opcion 1: M152 sustentado, 0 degradaciones |
| 155 | 155-Vestimenta-Y-Accesorios | 1364 | Auditoria T-D7 bloque 3: sustentado, 0 degradaciones |
| 162 | 162-Dialogos-Contextuales-De-NPCs | 1359 | Auditoria T-D7 bloque 2: sustentado, 0 degradaciones |
| 164 | 164-Isla-De-Combate-Endgame | 1359 | Auditoria T-D7 bloque 2: sustentado, 0 degradaciones |
| 165 | 165-Voxel-Tools-Guia | 699 | RE-QA cruzado §21.8 M165 (solo sello) |

## Notas especiales para el director

3 de los 30 (a) son cambios por **auditoría/saneamiento**, no por implementación:
- **M64** (Log 1330): drift de conteo corregido por el director (100→78).
- **M85** (Log 1424): 4 `[x]`→`[ ]` por veredicto DoD INFLADO.
- **M156** (Log 1388): 9 `[x]`→`[?]` (243→234) por auditoría.
Los cuento como (a) porque la fila del GLOBAL sí cambió y la columna `Última actividad`
debe acompañar ese cambio para mantener el tablero consistente. Si el director prefiere
reservar (a) solo para implementación real, estos 3 pasan a (b) — decisión suya.

Restricciones respetadas: no se toca Progreso/Estado/Agente de ninguna fila; no se
tocan filas 🔵/🔴 de otros agentes en curso; el GLOBAL se editará con Python
`io.open(..., newline=\"\")` (LF puro). **Nada aplicado todavía** — espero la OK del director.
