# Log 1093: Barrido histórico completo — sección 7 del doc empírico

**Fecha:** 2026-09-20
**Hora:** 21:45
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen
Se completó el barrido histórico pedido por el usuario (2026-09-19: "mañana revisamos todos los
logs para agregar los modelos que trabajaron anteriormente"). La sección 7 del doc empírico pasó
de placeholder a **evidencia completa y verificable**: línea temporal fundacional, tabla de 20
modelos y correcciones a creencias previas. Todo medido desde el repo (1039 logs, 168
plan-iniciales, 167 plan-actual), sin un solo benchmark de internet.

## Cambios Realizados
- `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md`:
  - **§7 reescrita** (antes "Pendiente"): línea temporal fundacional (12 modelos ordenados por
    primer log), tabla histórica completa (logs / plan-inicial / plan-actual / carpeta por modelo),
    hallazgos numerados, sección de "no verificable hoy" e implicaciones de asignación.
  - **§2 ampliada** con tabla de modelos históricos (fundadores + inactivos).
  - Footer actualizado (476 lín, **0 mojibake verificado**).

## Hallazgos clave (todos verificables, reproducibles)

1. **Deepseek V4 Flash es EL FUNDADOR del proyecto** — primer log 2026-08-15 (log 4); escribió la
   arquitectura core (M07 Arquitectura, M08 Mundo-Voxel, M09 Terreno, M10, M11, M12, M13, M29, M30
   — logs 7-20 del 2026-08-16). 114/168 plan-iniciales (68%), ~227 logs, 57 plan-actual (implementador
   top también). **Ahora solo tareas cortas por límite de tokens** (directiva usuario).
2. **Devin (SWE-1.6)** llegó 2° (2026-08-16, Antigravity): 21 plan-iniciales (13%) — **no es el
   autor mayoritario** (corrección confirmada). Creó la capa de infraestructura (M103, M107, M110,
   M111, M122, M41-M44, M88, M90, M91, M31, M32, M152).
3. **Nemotron 3 Ultra**: 13 specs en **ráfaga de 12 minutos** (2026-08-21 01:23→01:35), un log por
   módulo, **solo diseño**. 6 de sus 13 módulos siguen firmados solo por él en plan-actual
   (M81/M83/M84/M85/M119/M132); los otros 7 los implementaron MiMo (M82), MiniMax/MiMo (M115),
   GLM (M134/M145/M146/M149), Hy3 (M128).
4. **Nemotron 3.5 Lightning**: 4 plan-iniciales (M69 Fast-Travel, M104 Analytics, M118 CI-CD, M131
   Créditos) y **CERO logs** — el modelo más invisible del proyecto. M69/M131 siguen firmados solo
   por él; M104→ox-alpha, M118→glm-5.3-flash.
5. **Corrección temporal al reporte del usuario**: glm-5.3/glm-5.3-flash **no son temporalmente
   fundadores** — llegaron 2026-09-01, dos semanas después que DeepSeek (08-15) y Devin (08-16). Sí
   fundaron la **segunda oleada** (sistemas: M118 CI-CD + producción documental; glm-5.3-flash =
   142 logs, el más prolífico junto a agnes-2.5-flash) y llegaron antes que todos los modelos hoy
   activos. Distinción documentada: DeepSeek/Devin fundaron el proyecto; glm fundó la capa de
   sistemas operativos.
6. **agnes-2.5-flash** = el sobre-cierre histórico más grande (M126/M128/M115 revertidos por
   auditoría 2026-09-14; mi Log 1048 verificó que la reversión fue correcta para M126/M128). **El
   volumen de logs no es señal de confiabilidad.**
7. **Modelos fantasmas** (trabajaron sin carpeta en TAREAS-POR-MODELO): Devin, Nemotron 3 Ultra,
   Nemotron 3.5 Lightning, ox-alpha (~42 logs, Cline/Kilo), GitHub Copilot (4 logs), Claude (4).

## Corrección a mi propio pre-scan
Mi entrada 36 del backlog citaba un "Log 47" con conteos inflados de devin — **ese log no existe**
(búsqueda directa en `Logs/`, 0 resultados). No se propagó el claim al doc empírico (su propia
regla exige un Log concreto por afirmación).

## Archivos Modificados/Creados
- `DOCUMENTACION/Auditorias/evaluacion-empirica-modelos-2026-09-19.md` (§7 + §2 + footer)
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn/BACKLOG-MASTER.md` (entrada 36 → completada)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (sección del barrido)
- `Logs/1093-*` (este log)

## Verificación
- Conteo de firmas reproducible: 168 plan-iniciales (114/21/13/11/4/5), 1039 logs con 56 variantes
  de firma, 167 plan-actual.
- Cruce diseñó-vs-implementó de los 17 módulos Nemotron: hecho uno por uno.
- Doc empírico: 476 lín, 0 mojibake.

## Notas
- Push NEGATIVO (sin commit).
- No había entregas nuevas en ESTADO-PARALELO desde mi batería 05:32 del 09-19 (última actividad
  de otros agentes: kimi-k3 05:35 del 09-19) — el rol de verificación de entregas no tuvo cola.
