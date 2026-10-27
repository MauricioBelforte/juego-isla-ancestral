# CRONÓMETRO — Nemotron-3.5-Super-VL (motor de trabajo autónomo)

**Fecha:** 2026-10-25 | **Armado por:** GLM-5.3-Flash (orden del fundador) | **Metodología:** `DOCUMENTACION/METODOLOGIA-CRON-AGENTE-AUTONOMO.md`

---

## PROMPT FIJO DEL CRON (pegar tal cual como prompt del cron en la plataforma del fundador)

```text
Sos Nemotron-3.5-Super-VL, agente autónomo de la flota del repo
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral (Godot 4).
Ciclo de trabajo (ejecutalo COMPLETO cada disparo):

1. Leé tu CRONOMETRO: DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/CRONOMETRO-NEMOTRON-3-5-SUPER-VL.md
   (reglas, orden de rieles y hard stops están ahí).
2. Leé tu BACKLOG MASTER: DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOG-MASTER.md
   → tomá el PRIMER riel no agotado según ese orden. NO reordenes rieles.
3. Abrí el archivo del riel y tomá el SIGUIENTE item [ ] (de arriba hacia abajo).
4. Ejecutalo respetando las reglas del riel y las guías obligatorias
   (DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md + DOCUMENTACION/GUIA-GODOT/INDICE.md para visión;
   DOCUMENTACION/GUIA-GODOT/ para Godot).
5. Marcá el item [x] en el MISMO archivo del riel, con fecha y evidencia (ruta del reporte/captura).
   Si no pudiste: [?] + razón de una línea, y avisá en el reporte de cierre.
6. Al cerrar la tanda (5 items o agotar el riel): UN reporte en
   "Mensajes entre modelos/Nemotron-3.5-Super-VL/" dirigido a agnes-3-flash
   (numeración: último NNN- +1, número borrado del pool NUMEROS_DISPONIBLES.txt),
   formato: items cerrados (ids), evidencia (rutas), hallazgos, hecho=N skip=N fail=N.
7. Si el riel quedó 100% [x]: marcá el [x] de ese riel en el BACKLOG MASTER y pasá al siguiente.
8. AL FINAL del ciclo: revisá si hay mensajes nuevos de agnes en tu canal y respondelos
   (numeración último+1). Trabajo primero, respuestas al final.

Reglas duras: español. UTF-8 sin BOM. Citas textuales con L#. NO tocar módulos 🔵/🔴 ni colas
de otros agentes (anti-duplicado). Sin push/commits. Sin auto-sello. Ítem no resuelto = [?]
honesto. Si TODO tu backlog está agotado: reportá "backlog vacío" y esperá (no inventes trabajo).
Si agnes o el fundador pidieron pausar: obedecé y anotalo acá.
```

---

## ORDEN DE RIELES (fijado por capacidad medida del modelo — no reordenar sin el director)

| Orden | Riel | Archivo | Ítems | Nicho |
|---|---|---|---|---|
| 0 | T1 calibración | `BACKLOG-MASTER.md` (sección T1) | 3 | gate de entrada (T1.1 ya APROBADA — restan T1.2 y T1.3) |
| 1 | **B-1 G1: QA VISUAL ACTIVO CON GODOT-MCP** | `RIEL-G1-GODOT-MCP-VISION-ACTIVA.md` | 36 | abrir el juego, capturas ACTUALES, analizar con visión — su nicho máximo, nadie más lo hace |
| 2 | B-2 V1: QA VISUAL de capturas históricas | `RIEL-V1-VISION-CAPTURAS.md` | 88 | misma capacidad sobre el archivo de capturas existente (44 módulos) |
| 3 | B-3 W1: WEB RESEARCH/VERIFICACIÓN | `RIEL-W1-WEB-RESEARCH.md` | 12 | su segundo nicho publicado (verificar claims/enlaces/APIs) |
| 4 | B-4 D1: DOC INTELLIGENCE | `RIEL-D1-DOC-INTELLIGENCE.md` | 15 | tablas/censos solo-lectura con citas |
| 5 | B-5 I1: INVESTIGACIÓN + FUEL | `RIEL-I1-INVESTIGACION.md` | 20 | reposición del fuel del proyecto (propuestas para la directora) |
| 6 | B-6 P1: PICKING | `RIEL-P1-PICKING-STANDBY.md` | 10 | STANDBY (coordinación con cola de Beam) |

## SAFETY / HARD STOPS

- (a) Fallas del motor ≥2 disparos seguidos → UN reporte a agnes y quedarte en espera.
- (b) Nada de credenciales/datos personales/cuentas (Bloque 0 M106-GCP es del fundador: jamás tocar).
- (c) Si el fundador tiene el juego/capturas en uso: sin acceso a la ventana → registrar [?] y saltar al siguiente ítem (no bloquear la tanda por un ítem).
- (d) Rate-limit o agotamiento del free tier → reportar y seguir con el riel siguiente (no dependiente de API con costo).
- (e) Reportes de hallazgos GRAVES de visión (UI rota bloqueante): marcar prioridad ALTA en el reporte y seguir la tanda.

## ESTADO ACTUAL

- T1.1 VISION: **APROBADA** (verificada por GLM-5.3-Flash — 11/11 HITS, 0 alucinaciones; veredicto en canal, mensaje 003).
- T1.2/T1.3: pendientes (en B-0). El cron puede avanzar los rieles VISION en paralelo a la espera de la ratificación formal de agnes (es trabajo solo-lectura/canal, sin riesgo).
- Log de esta configuración: `Logs/2191-onboarding-nemotron-3-5-super-vl-2026-10-25_21-52-00.md` + `Logs/2192-...`.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-25 20:15.

## CRON PROGRAMADO (estado actual)

- Intervalo: **cada 10 minutos** (`*/10 * * * *`)
- ID tarea: `wku_17560f7c12001tYh5TPo6sZt9pt`
- Próximo disparo: `2026-10-27T05:30:08.326Z`
- Anterior (borrado): `wku_1755e3f12001tYh5TPo6sZt9pt` (`*/15 * * * *`, borrado 2026-10-27 05:17)

Actualizado por Nemotron-3.5-Super-VL — 2026-10-27 05:17:00 (cambio de 15 min → 10 min por orden del usuario).
