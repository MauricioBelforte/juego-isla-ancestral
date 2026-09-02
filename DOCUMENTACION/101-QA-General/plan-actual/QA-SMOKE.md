**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-SMOKE.md — Smoke Test por Build (Módulo 101)

> **Propósito:** filtro más barato del pipeline. Si cualquiera de los 7 pasos falla, la build se rechaza y NO se corre QA completo. Tiempo máximo: **15 minutos**.

## Paso 1 — Arranque (2 min)

- [ ] 1.1 La build arranca y llega al menú principal sin errores en consola (revisar M103 para errores; warnings no bloquean, se anotan).
- [ ] 1.2 El log de arranque no repite el mismo error más de 3 veces (bucle de inicialización).

## Paso 2 — Menú (1 min)

- [ ] 2.1 El menú principal es navegable (teclado/mouse/gamepad si aplica).
- [ ] 2.2 Configuración abre y cierra sin crashear; los sliders principales responden.

## Paso 3 — Mundo nuevo (2 min)

- [ ] 3.1 Partida nueva con **semilla fija 42** genera el mundo sin excepciones en < 60 s (anotar el tiempo).
- [ ] 3.2 El jugador aparece sobre el terreno estable (no flotando ni bajo el mundo).

## Paso 4 — Movimiento (2 min)

- [ ] 4.1 Movimiento WASD relativo a cámara, salto y cámara sin clipping en el terreno.
- [ ] 4.2 Sin caída al vacío en 30 s de caminata arbitraria.

## Paso 5 — Herramienta (2 min)

- [ ] 5.1 Con la herramienta inicial, extraer 1 bloque correcto (recurso esperado entra al inventario) sin warnings.
- [ ] 5.2 Colocar 1 bloque en un hueco/plataforma: el bloque queda en la celda esperada.

## Paso 6 — Guardar/Cargar (3 min)

- [ ] 6.1 Guardar partida → cargar la partida → la posición y el inventario son idénticos.
- [ ] 6.2 No hay errores en el log durante el ciclo completo.

## Paso 7 — Debug menu (3 min, si M110 disponible)

- [ ] 7.1 El debug menu (M110) abre con el atajo definido.
- [ ] 7.2 El teletransporte funciona a 3 coordenadas (playa, montaña, bosque) — `🎮`.
- [ ] 7.3 La exportación de diagnóstico (RF20) genera un archivo legible.

## Veredicto

- [ ] **SMOKE APROBADO** → continuar a QA completo por áreas (QA-CHECKLIST.md) y registrar sesión.
- [ ] **SMOKE RECHAZADO** → crear issue M102 de severidad **alta o crítica** por cada paso fallido (con el paso #), avisar al dueño del build, y NO correr el QA completo. Registrar el rechazo en `sesiones/` con la plantilla QA-SESSION.md (conclusión: rechazado).

## Reglas

1. No aprobar un smoke si no se tiene evidencia del log (M103) — para agentes sin visión el paso 5/6 se verifica por log.
2. Si el paso 3 falla con otra semilla distinta de 42, probar semilla 0 por determinismo antes de rechazar.
3. El smoke corre sobre la **build exacta** que será evaluada (no sobre una compilación más antigua).
