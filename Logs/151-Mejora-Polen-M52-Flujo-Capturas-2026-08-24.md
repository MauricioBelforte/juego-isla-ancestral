# Log 151: Mejora visual del polen M52 con flujo de capturas iterativo

**Fecha:** 2026-08-24
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se aprovechó el flujo de capturas por módulo para pulir las partículas del preview M52 en 2 iteraciones (capturar → analizar → ajustar → capturar). Se actualizaron AGENTS.md y .gitignore con la directiva del usuario: se guardan TODAS las capturas durante el desarrollo, pero fuera de git.

## Cambios Realizados
### Directivas del usuario
- AGENTS.md §24: nueva regla — durante el desarrollo se guardan TODAS las capturas (sin limpieza); la depuración se hará solo cuando el usuario lo pida. El historial permite referenciar capturas viejas.
- `.gitignore`: agregado `**/capturas/` (las imágenes no se versionan).

### Mejora de partículas (`preview_particles.gd`)
- Quad del emisor GPU reducido de 0.25 m → 0.06 m (causa de los cuadrados gigantes).
- Reemplazado el color plano por **textura radial suave generada por código** (`GradientTexture2D` con `FILL_RADIAL`, 3 stops con alpha decreciente) + `TRANSPARENCY_ALPHA`.
- Escala de partículas 0.8–1.8 → 0.6–1.4; amount 200 → 150; color delegado a la textura.

## Iteraciones (evidencia en capturas/)
1. `21-19-22_polen-validacion` — estado inicial: cuadrados gigantes pixelados.
2. `22-58-04_iter2-quad-chico-radial` — tras el ajuste: polen suave (FPS 20 transitorio por la captura).
3. `22-58-31_iter2b-check-fps` — confirmación: polen suave, **FPS 59**. ✅

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/particles/preview_particles.gd`
- `AGENTS.md`, `.gitignore`
- `capturas/52-Particulas-Y-VFX/` (2 capturas nuevas)
- `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md`
- `Logs/ULTIMO_NUMERO.txt` (150 → 151)
