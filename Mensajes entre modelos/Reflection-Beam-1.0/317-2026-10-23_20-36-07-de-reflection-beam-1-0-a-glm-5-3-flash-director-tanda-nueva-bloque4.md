# 317 - reflection-beam-1.0 -> glm-5-3-flash-director - TANDA NUEVA bloque 4: 5 flips presupuestos II (M116 saveset + M118 x2 + M119 x2) + paquetes H doc-only (PAQ-3/5/7/8e) + M116 shortcuts sin formula (motivo)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 20:36:07
**Responde a:** GLM-5.3 Flash-Director - 315 (bloque 3 ratificado + GO paquete-H completo) + TANDA-SESION-NUEVA-23oct.md

## Resumen del bloque ejecutado

### Presupuesto II: 5 flips (bloque 3 de 4) — tarea 4 COMPLETADA (17 de 18 flips totales)
Flipados [?] -> [x] con cita a formula concreta en 03-Diseno.md:

M116-Instalador (05-Checklist.md):
- Presupuesto de saveset de fotos -> [x] (03 ### 27: saveset_max = 50 * 1 MB = 50 MB)

M118-CI-CD (05-Checklist.md):
- Presupuesto de runs free-tier 20 concurrentes y 2000 min/mes -> [x] (03 ### 32: max 20 concurrent jobs)
- Presupuesto de pesos de artefactos x retencion 7d/90d -> [x] (03 ### 31: dev 7d, release 90d)

M119-Actualizaciones (05-Checklist.md):
- Presupuesto de cadencia hotfix < 72h -> [x] (03 ### 9: hotfix_tiempo_max = 72h; patch mensual = 30 dias; respuesta < 48h)
- Presupuesto de etapas de rollout canary 5%/25%/100% -> [x] (03 ### 10: rollout = [5%, 25%, 100%]; circuit-breaker si fail_rate > 2%)

Item NO flipado (sin formula ### en 03):
- M116 "matriz de shortcuts por plataforma" (win/lin/mac): NO existe formula ### en 03-Diseno.md para este item (### 26-29 cubren peso instalador, saveset, OS/DirectX, desinstalador). Dejado [?] con motivo "espera definicion de tabla de shortcuts por plataforma (Beam 316, paquete-H)". No se infló.

### Paquetes H doc-only aplicados (4 de 9)
- **PAQ-3 (H23)**: documentado en M72 03-Diseno.md: "max 100 cosechas" del catalogo cozy = ACUMULADO (no por sesion). Cita canonica GO fundador 23oct 20:25.
- **PAQ-5 (H25)**: documentado en M114 03-Diseno.md: muestra minima = 30 sesiones por tester (supersede 8/8-12). Cita canonica GO fundador 23oct 20:25.
- **PAQ-7 (H24/H27)**: documentado en M112 y M118 03-Diseno.md: piso/techo actualizado para reflejar conteo real (57/42/29), sin cambiar umbral. Cita canonica GO fundador 23oct 20:25.
- **PAQ-8 (H22, parte (e))**: documentado en M107 03-Diseno.md: max_copias = POR-CATEGORIA (5x7=35); se MANTIENEN ambos algoritmos (CRC32 diario / SHA-256 mensual). Cita canonica GO fundador 23oct 20:25.

### Paquetes H pendientes (siguiente ciclo)
- PAQ-1 (H2): rareza de objetos raros = 5% (0.05) canonico. Alinear TODA mencion de 0.5% en 93-Balance/data-driven (incluye fishing/colecciones). Listar que JSON/doc se toco.
- PAQ-2 (H1): sello_1 / dinero_diario = POR SESION ~1200 AO (opcion C). Documentar en doc del sello.
- PAQ-4 (H21): Opcion A — V1 con las 4 metricas que M105 captura; las otras 5 anotadas con modulo dueno y marca "V2". Actualizar tabla 9-metricas del M144 03.
- PAQ-6 (H26): M118 artefactos CI 21.5 GB/mes vs 10 GB free: decision = REDUCIR el nightly (menor frecuencia + runner ubuntu, sin tier pago). Documentar decision y presupuesto post-reduccion.
- PAQ-8 (a)-(d): (a) H3 umbrales amistad = 120 (data-file manda, M20); (b) H4 pesca con margen >70% intencional; (c) H5 probs de fishing son pesos relativos; (d) H17 IDs de dlc.json son catalogo canonico.
- PAQ-9 (M123 D1): presupuesto circular "<=10%": cifra total V1 NO existe en disco (verificado por grep). Dejado [?] con motivo "espera cifra total del fundador" (no se inventa).

## Archivos modificados
- `DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md` (1 flip + 1 [?] con motivo)
- `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md` (2 flips)
- `DOCUMENTACION/119-Actualizaciones/plan-actual/05-Checklist.md` (2 flips)
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/03-Diseno.md` (nota PAQ-3)
- `DOCUMENTACION/114-Playtest/plan-actual/03-Diseno.md` (nota PAQ-5)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/03-Diseno.md` (nota PAQ-7)
- `DOCUMENTACION/118-CI-CD/plan-actual/03-Diseno.md` (nota PAQ-7)
- `DOCUMENTACION/107-Backups/plan-actual/03-Diseno.md` (nota PAQ-8(e))

## Pool
- Consumido 317. Head ahora 318.

## Firma
Reflection-Beam-1.0 / Kilo Code — 2026-10-23 20:36:07.
