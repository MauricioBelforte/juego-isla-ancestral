# L-06 — Timestamps stale del GLOBAL (versión abreviada por s3)

**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08
**Origen:** Ling L-06 se cerró sin entregar reporte; lo completé yo misma (método abreviado).
**Alcance:** read-only sobre CHECKLIST-GLOBAL.md y Logs/.

## Método

1. Indexé los **904 logs** de Logs/ por número y fecha (extraída del nombre del archivo).
2. Extraje los MIDs del **nombre** de cada log (patrón M\d+).
3. Para cada módulo del GLOBAL, busqué el log más reciente que lo menciona y comparé fechas.

**Caveat honesto:** el método usa el nombre del log, no su contenido. Los logs que mencionan un
módulo solo en el cuerpo (sin nombrarlo en el título) **no se computan** → el conteo de stale es
**conservador** (subreporta). Aun así, 86 es una señal clara.

## Resultado

=== MÓDULOS STALE (GLOBAL desactualizado vs log más reciente) ===
total stale: 86

  77   77-Online-Y-Red                    GLOBAL=2026-08-17 Log1356  2026-10-06 (+50d)
  03   03-Documentacion-Del-Proyecto      GLOBAL=2026-08-16 Log1283  2026-10-04 (+49d)
  85   85-Modelos-3D-Legal                GLOBAL=2026-08-21 Log1424  2026-10-07 (+47d)
  112  112-Testing-Automatico             GLOBAL=2026-08-29 Log1453  2026-10-08 (+40d)
  04   04-Game-Engine                     GLOBAL=2026-08-29 Log1403  2026-10-07 (+39d)
  08   08-Mundo-Voxel                     GLOBAL=2026-08-26 Log1263  2026-10-04 (+39d)
  20   20-Sistema-De-Amistad              GLOBAL=2026-08-30 Log1364  2026-10-06 (+37d)
  31   31-Ciclo-Dia-Noche                 GLOBAL=2026-08-31 Log1369  2026-10-06 (+36d)
  34   34-Pesca                           GLOBAL=2026-08-31 Log1375  2026-10-06 (+36d)
  35   35-Mineria                         GLOBAL=2026-08-31 Log1375  2026-10-06 (+36d)
  108  108-Pipeline-De-Assets             GLOBAL=2026-09-02 Log1433  2026-10-07 (+35d)
  156  156-Terrenos-Y-Movimiento          GLOBAL=2026-09-02 Log1388  2026-10-06 (+34d)
  16   16-Crafting                        GLOBAL=2026-09-02 Log1364  2026-10-06 (+34d)
  41   41-Musica                          GLOBAL=2026-09-02 Log1375  2026-10-06 (+34d)
  76   76-Multijugador                    GLOBAL=2026-09-03 Log1387  2026-10-06 (+33d)
  162  162-Dialogos-Contextuales-De-NPCs  GLOBAL=2026-09-04 Log1359  2026-10-06 (+32d)
  21   21-Dialogos                        GLOBAL=2026-09-04 Log1364  2026-10-06 (+32d)
  33   33-Agricultura                     GLOBAL=2026-09-04 Log1375  2026-10-06 (+32d)
  90   90-Configuracion-Grafica           GLOBAL=2026-09-04 Log1385  2026-10-06 (+32d)
  58   58-Accesibilidad                   GLOBAL=2026-09-06 Log1398  2026-10-07 (+31d)
  45   45-Arte-3D                         GLOBAL=2026-09-06 Log1356  2026-10-06 (+30d)
  51   51-Agua                            GLOBAL=2026-09-06 Log1379  2026-10-06 (+30d)
  50   50-Vegetacion                      GLOBAL=2026-09-07 Log1379  2026-10-06 (+29d)
  133  133-Gestion-Del-Proyecto           GLOBAL=2026-08-28 Log1148  2026-09-25 (+28d)
  134  134-Presupuesto                    GLOBAL=2026-08-28 Log1148  2026-09-25 (+28d)
  135  135-Riesgos-Del-Proyecto           GLOBAL=2026-08-28 Log1148  2026-09-25 (+28d)
  136  136-Roadmap                        GLOBAL=2026-08-28 Log1148  2026-09-25 (+28d)
  111  111-Codigo-De-Calidad              GLOBAL=2026-09-14 Log1450  2026-10-07 (+23d)
  119  119-Actualizaciones                GLOBAL=2026-09-02 Log1157  2026-09-25 (+23d)
  149  149-Nombres-Y-Nomenclatura         GLOBAL=2026-09-15 Log1443  2026-10-08 (+23d)
  07   07-Arquitectura-General            GLOBAL=2026-09-03 Log1155  2026-09-25 (+22d)
  107  107-Backups                        GLOBAL=2026-09-16 Log1440  2026-10-08 (+22d)
  110  110-Debug-Menu                     GLOBAL=2026-09-16 Log1440  2026-10-08 (+22d)
  113  113-Pruebas-De-Stress              GLOBAL=2026-09-15 Log1423  2026-10-07 (+22d)
  26   26-Templo-Subterraneo              GLOBAL=2026-09-14 Log1359  2026-10-06 (+22d)
  105  105-Telemetria-De-Gameplay         GLOBAL=2026-09-16 Log1433  2026-10-07 (+21d)
  155  155-Vestimenta-Y-Accesorios        GLOBAL=2026-09-15 Log1364  2026-10-06 (+21d)
  103  103-Logging                        GLOBAL=2026-09-15 Log1323  2026-10-05 (+20d)
  15   15-Recursos                        GLOBAL=2026-09-16 Log1369  2026-10-06 (+20d)
  30   30-Reloj-En-Tiempo-Real            GLOBAL=2026-09-16 Log1369  2026-10-06 (+20d)
  116  116-Instalador                     GLOBAL=2026-09-18 Log1400  2026-10-07 (+19d)
  83   83-Licencias-De-Software           GLOBAL=2026-09-17 Log1386  2026-10-06 (+19d)
  164  164-Isla-De-Combate-Endgame        GLOBAL=2026-09-18 Log1359  2026-10-06 (+18d)
  36   36-Fauna                           GLOBAL=2026-09-18 Log1375  2026-10-06 (+18d)
  52   52-Particulas-Y-VFX                GLOBAL=2026-09-18 Log1390  2026-10-06 (+18d)
  60   60-Datos-Y-Serializacion           GLOBAL=2026-09-18 Log1389  2026-10-06 (+18d)
  109  109-Herramientas-Internas          GLOBAL=2026-09-02 Log1075  2026-09-19 (+17d)
  19   19-NPC-Y-Vecinos                   GLOBAL=2026-09-02 Log1049  2026-09-19 (+17d)
  64   64-IA-De-NPC                       GLOBAL=2026-09-18 Log1330  2026-10-05 (+17d)
  80   80-Legal-Privacidad                GLOBAL=2026-08-17 Log425   2026-09-02 (+16d)
  97   97-Steam-Store-Page                GLOBAL=2026-08-17 Log420   2026-09-02 (+16d)
  114  114-Playtest                       GLOBAL=2026-08-17 Log481   2026-09-01 (+15d)
  118  118-CI-CD                          GLOBAL=2026-09-06 Log1125  2026-09-19 (+13d)
  99   99-Marketing                       GLOBAL=2026-08-20 Log422   2026-09-02 (+13d)
  98   98-Trailer                         GLOBAL=2026-08-21 Log421   2026-09-02 (+12d)
  106  106-Seguridad                      GLOBAL=2026-09-25 Log1389  2026-10-06 (+11d)
  161  161-Diseno-Visual-De-NPCs          GLOBAL=2026-08-23 Log396   2026-09-02 (+10d)
  57   57-Interfaz-De-Control             GLOBAL=2026-08-30 Log958   2026-09-09 (+10d)
  102  102-Bug-Tracking                   GLOBAL=2026-08-29 Log767   2026-09-07 (+9d)
  32   32-Clima                           GLOBAL=2026-09-16 Log1145  2026-09-25 (+9d)
  154  154-Vision-Del-Agente              GLOBAL=2026-08-24 Log302   2026-08-31 (+7d)
  159  159-Catalogo-De-Objetos            GLOBAL=2026-08-25 Log477   2026-09-01 (+7d)
  131  131-Creditos                       GLOBAL=2026-10-02 Log1447  2026-10-08 (+6d)
  160  160-Diseno-De-Ubicaciones-Del-Mund GLOBAL=2026-09-18 Log1137  2026-09-24 (+6d)
  100  100-Community-Management           GLOBAL=2026-10-03 Log1422  2026-10-07 (+4d)
  115  115-Hardware                       GLOBAL=2026-09-15 Log1078  2026-09-19 (+4d)
  165  165-Voxel-Tools-Guia               GLOBAL=2026-09-01 Log699   2026-09-05 (+4d)
  38   38-Economia                        GLOBAL=2026-10-04 Log1445  2026-10-08 (+4d)
  63   63-Cargas-Y-Streaming              GLOBAL=2026-10-02 Log1393  2026-10-06 (+4d)
  93   93-Balance                         GLOBAL=2026-10-03 Log1405  2026-10-07 (+4d)
  152  152-Principios-Innegociables       GLOBAL=2026-10-04 Log1400  2026-10-07 (+3d)
  54   54-Mapa                            GLOBAL=2026-10-03 Log1379  2026-10-06 (+3d)
  59   59-Guardado                        GLOBAL=2026-10-03 Log1397  2026-10-06 (+3d)
  62   62-Memoria                         GLOBAL=2026-10-03 Log1391  2026-10-06 (+3d)
  91   91-Configuracion-De-Audio          GLOBAL=2026-10-04 Log1398  2026-10-07 (+3d)
  09   09-Terreno-Y-Geografia             GLOBAL=2026-09-18 Log1115  2026-09-20 (+2d)
  14   14-Inventario                      GLOBAL=2026-10-04 Log1390  2026-10-06 (+2d)
  29   29-Tiempo-Y-Calendario             GLOBAL=2026-10-04 Log1369  2026-10-06 (+2d)
  53   53-UI-UX                           GLOBAL=2026-10-04 Log1379  2026-10-06 (+2d)
  12   12-Camara                          GLOBAL=2026-09-18 Log1079  2026-09-19 (+1d)
  128  128-Identidad-De-Marca             GLOBAL=2026-09-18 Log1067  2026-09-19 (+1d)
  13   13-Herramientas                    GLOBAL=2026-09-18 Log1073  2026-09-19 (+1d)
  74   74-Eventos                         GLOBAL=2026-09-06 Log777   2026-09-07 (+1d)
  75   75-Postgame                        GLOBAL=2026-09-04 Log682   2026-09-05 (+1d)
  78   78-Legal-Propiedad-Intelectual     GLOBAL=2026-10-07 Log1440  2026-10-08 (+1d)
  89   89-Diseno-De-Menus                 GLOBAL=2026-10-06 Log1395  2026-10-07 (+1d)

=== MÓDULOS SIN LOG que los mencione: 22 ===
  ---- --------                       act=-------------- (sin fecha)
  01   01-Fundamentos-Del-Proyecto    act=? (sin fecha)
  02   02-Vision-Y-Concepto           act=— (sin fecha)
  05   05-Lenguaje-Y-Programacion     act=2026-08-29 01: (sin log que lo mencione)
  06   06-Control-De-Versiones        act=2026-10-03 23: (sin log que lo mencione)
  104  104-Analytics                  act=— (sin fecha)
  125  125-Terminos-De-Servicio       act=2026-10-03 03: (sin log que lo mencione)
  129  129-Merchandising              act=2026-10-05 01: (sin log que lo mencione)
  132  132-Produccion-De-Equipo       act=2026-10-03 03: (sin log que lo mencione)
  137  137-Prototipo                  act=2026-08-19 05: (sin log que lo mencione)
  138  138-Vertical-Slice             act=2026-08-19 05: (sin log que lo mencione)
  140  140-Alpha                      act=2026-08-20 19: (sin log que lo mencione)
  141  141-Beta                       act=2026-08-20 19: (sin log que lo mencione)
  142  142-Release-Candidate          act=2026-08-20 19: (sin log que lo mencione)
  143  143-Lanzamiento                act=2026-08-20 19: (sin log que lo mencione)
  144  144-Despues-Del-Lanzamiento    act=2026-09-04 (sin log que lo mencione)
  145  145-Diseno-De-Experiencia      act=2026-08-28 22: (sin log que lo mencione)
  146  146-Diseno-Emocional           act=2026-08-28 22: (sin log que lo mencione)
  47   47-Texturas-Y-Materiales       act=— (sin fecha)
  82   82-Clasificacion-Por-Edades    act=2026-08-21 01: (sin log que lo mencione)
  84   84-Musica-Y-Audio-Legal        act=2026-09-18 (sin log que lo mencione)
  86   86-IA-Generativa               act=2026-08-17 (sin log que lo mencione)

=== RESUMEN ===
  stale:      86
  sin log:    22
  consistentes: 60

