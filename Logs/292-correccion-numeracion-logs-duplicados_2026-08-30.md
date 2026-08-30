# Log 292: Corrección de numeración de logs duplicados

**Fecha:** 2026-08-30
**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** Kilo Code (opencode)

## Resumen

Auditoría y corrección de numeración de logs. Se encontraron 19 logs duplicados (225-265) causados por el batch de M166 (Blender pipeline) que pisó números de otros logs. Todos los duplicados fueron renombrados y las referencias actualizadas.

## Logs Renombrados (M166 batch → 273-287)

| Original | Nuevo | Contenido |
|----------|-------|-----------|
| 225-M166-Modulo-Variantes | 273 | Módulo variantes y perfil de rendimiento |
| 226-M166-Procesamiento-Lote | 274 | Procesamiento en lote 41 assets |
| 227-M166-QA-Visual-13-Herramientas | 275 | QA visual módulo 13 |
| 228-M166-Re-QA-Visual-13-Herramientas | 276 | Re-QA visual módulo 13 |
| 229-M166-Auditoria-Numerica-82-Variantes | 277 | Auditoría numérica 82 variantes |
| 230-M166-QA-Visual-76-Hojas-Contacto | 278 | QA visual 76 hojas contacto |
| 237-M166-Rotacion-Herramientas | 279 | Rotación herramientas fix capturas |
| 238-M166-Tier-D-Cuerda-Antorcha-Pared | 280 | Tier D: cuerda + antorcha pared |
| 239-M166-Antorcha-Pared-v2 | 281 | Fix antorcha pared v2 |
| 240-M166-Cierre-Deuda-Tecnica | 282 | Cierre deuda técnica M166 |
| 241-M166-Fix-Separacion-Herramientas-Mano | 283 | Fix separación herramientas mano |
| 242-M166-Auditoria-E27-7-Assets | 284 | Auditoría E-27 scripts |
| 244-M166-Creacion-Vieira-Playa | 287 | Creación vieira playa |
| 245-M166-Creacion-Puente-Cuerda | 285 | Creación puente cuerda |
| 246-M166-Creacion-Pozo-Piedra | 286 | Creación pozo piedra |

## Logs Renombrados (no-M166 → 288-291)

| Original | Nuevo | Contenido |
|----------|-------|-----------|
| 243-documentar-posicionamiento-terrainlocator | 288 | Documentación TerrainLocator |
| 246-m19-snap-terreno-y-offset | 289 | M19 snap terreno |
| 253-Cierre-Doc-Pendientes-Sin-Vision | 290 | Cierre doc pendientes |
| 265-correccion-superposicion-widgets-hud | 291 | Corrección superposición HUD |

## Documentación Actualizada

- `DOCUMENTACION/09-GUIA-BLENDER.md`: referencias log 226→274, 227→275, 244→287, 245→285, 246→286
- `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/03-Diseno.md`: log 237→279
- Referencias a logs M104 (237), M105 (243), M21 (253), M53 (265) se mantienen intactas (no eran duplicados M166)

## Verificación

- **Total logs:** 289 archivos, 289 únicos (0 duplicados)
- **ULTIMO_NUMERO.txt:** actualizado a 292
- **Referencias internas:** todas actualizadas en logs renombrados
- **Cruzadas en docs:** verificadas, sin referencias rotas

## Causa Raíz

El batch de M166 fue creado por un agente que asignó numeración secuencial propia (225-246) sin verificar qué números ya existían. Los logs de M166 tenían timestamps más tempranos que los logs concurrentes, por lo que al verificar parecía que "los otros" eran los duplicados, pero los M166 son los que deberían haber tenido números diferentes desde el inicio.

## Prevención

Al crear logs en batch, verificar siempre `ULTIMO_NUMERO.txt` antes de asignar números, y usar la secuencia correcta.
