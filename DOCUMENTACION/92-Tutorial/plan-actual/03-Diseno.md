**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 92: Tutorial

## 1. Arquitectura general

El mÃ³dulo 92 se compone de 4 subsistemas coordinados por un **TutorialManager** (autoload):

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    TutorialManager (autoload)                â”‚
â”‚  Estado: ACTIVO/ESPERANDO/PISTA/CONSECUENCIA/SKIPPED/DORMIDO â”‚
â”‚  Registro global: capitulos[], pistas activas, consejos vistosâ”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚ escucha          â”‚ instancia        â”‚ lee/escribe
â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Triggers     â”‚  â”‚ Guiones        â”‚  â”‚ GameState.M92  â”‚
â”‚ (RF2)        â”‚  â”‚ (CapituloGuion)â”‚  â”‚ persistencia   â”‚
â”‚ seÃ±al + cond â”‚  â”‚ pasos + meta   â”‚  â”‚ RN6 < 1 KB     â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚                  â”‚
â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Pistas       â”‚  â”‚ Secuencia      â”‚  â”‚ Sistema de      â”‚
â”‚ contextuales â”‚  â”‚ guiada (paso   â”‚  â”‚ consejos (tips  â”‚
â”‚ (burbuja WF) â”‚  â”‚ con marcador)  â”‚  â”‚ opcionales)     â”‚
â”‚ pool â‰¤ 2     â”‚  â”‚ prÃ³logo        â”‚  â”‚ 1 sola vez      â”‚
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                 â–¼
        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
        â”‚ UI de presentaciÃ³nâ”‚      â”‚ InputMap (M57)     â”‚
        â”‚ (pertenece a M53) â”‚      â”‚ iconos dinÃ¡micos   â”‚
        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1.1 TutorialManager (autoload `Tutorial`)
- Orquestador: recibe seÃ±ales, evalÃºa triggers, activa/libera guiones y pistas.
- No posee UI final: expone seÃ±ales y datos; M53 los dibuja (interfaz `TutorialPresentador`).
- Estado global: `ACTIVO` (guion en curso), `ESPERANDO` (sin guion, escuchando triggers), `PISTA` (burbuja informativa sin pasos), `CONSECUENCIA` (aviso "Â¡capÃ­tulo completado!"), `SKIPPED` (tutorial apagado), `DORMIDO` (menÃº/diÃ¡logo/pausa abiertos).

### 1.2 Triggers (RF2)
Objetos ligeros que asocian una condiciÃ³n a un guion:
- **Trigger de seÃ±al:** escucha la seÃ±al X de un sistema (M70, M33, M34, M16...) y una condiciÃ³n de contexto (jugador en zona, dÃ­a â‰¥ N).
- **Trigger de mundo:** proximidad del jugador a un nodo marcado (`ITutorialTarget`, ej: tÃ³tem de bienvenida, primer campo, muelle).
- **Trigger de acciÃ³n:** primera entrada de ciertas acciones (moverse, presionar E con prompt del 70).

### 1.3 Guiones (capÃ­tulos)
`CapituloGuion` como Resource:
```
id, titulo_localizable, trigger, pasos[], meta (seÃ±al de maestrÃ­a), timeout_default, rejugable (bool)
Paso: { tipo: PISTA | SECUENCIA | CONSEJO, texto_clave (tr), objetivo (NodePath/ITutorialTarget), icono_tecla (InputMap action o null), duracion_min, espera_senal }
```
- Los pasos de tipo SECUENCIA muestran marcador de objetivo + aceptan solo avanzar al cumplir la meta (sin bloquear otras acciones).
- Los pasos de tipo PISTA son informativos y no esperan cumplimiento (se cierran al expirar o al ejecutar la acciÃ³n).

### 1.4 Pistas contextuales
- Pool de burbujas world-space (â‰¤ 2 vivas): el texto se proyecta en la posiciÃ³n del objetivo con offset segÃºn cÃ¡mara; la burbuja se oculta con fade al expirar, al alejarse (distancia > 6 m), al abrir UI, o al cumplirse la acciÃ³n.
- Ãcono de tecla resuelto en runtime desde InputMap (M57); soporte teclado/gamepad.
- Ninguna pista bloquea input ni movimiento.

### 1.5 Sistema de consejos
- Lista de consejos (Resource `Consejo`) con: id, texto tr, contexto permitido (cargando escena, caminando > 10 s sin acciÃ³n, en menÃº de pausa), cooldown entre consejos (â‰¥ 90 s).
- Se muestran una sola vez (registro en `consejos_vistos`), respetan el interruptor global y no compiten con pistas activas.
- Nunca dentro de diÃ¡logos (M21) ni durante cutscenes.

## 2. Flujos

### 2.1 Flujo principal: disparo â†’ lecciÃ³n â†’ cierre

```
[Jugador entra al mundo]                    [Sistema emite seÃ±al X]
        â”‚                                            â”‚
        â–¼                                            â–¼
TutorialManager.ACTIVO/ESPERANDO â—„â”€â”€â”€â”€â”€ evaluar_triggers(seÃ±al, contexto)
        â”‚
        â–¼ (se cumple trigger de capÃ­tulo N)
desplegar_capitulo(N)
        â”‚
        â”œâ”€ Â¿meta ya cumplida antes? (revalidaciÃ³n RF3/RF19)
        â”‚     â””â”€â–º completar_capitulo(N) en silencio â†’ log M103
        â”‚
        â–¼ no
mostrar paso 1 (PISTA o SECUENCIA con marcador)
        â”‚
        â–¼ jugador ejecuta la acciÃ³n (o expira / se aleja)
paso = completado
        â–¼ (siguiente paso o fin)
completar_capitulo(N): feedback "capÃ­tulo completado" (2 s, M44) + persistir GameState.M92
        â”‚
        â””â”€â–º si N == Ãºltimo â†’ TutorialManager avisa "tutorial disponible en opciones"
```

### 2.2 Flujo de skip y re-play

```
Opciones (M53) â”€â”€â–º skip_global(): Tutorial.skipped = true; pistas activas se ocultan; capÃ­tulos futuros NO se disparan
Opciones (M53) â”€â”€â–º skip_capitulo(): libera guion actual sin marcar completo
Opciones (M53) â”€â”€â–º replay(capitulo_id | "todos"):
     1) snapshot de GameState.M92 (RN11, no contamina la partida)
     2) mostrar aviso de confirmaciÃ³n (M53): "Se reiniciarÃ¡ el tutorial de [X]"
     3) al confirmar: desplegar el guion con estado_replay (sin revalidaciÃ³n)
     4) al terminar: restaurar snapshot si hubo cambios conflictivos
```

### 2.3 Flujo de recuperaciÃ³n (watchdog) â€” RF23

```
capitulo_esperando_meta(> timeout_default 120 s)
   â–¼
intento += 1
   â”œâ”€ intento <= 3 â”€â”€â–º reprogramar_trigger(capitulo) (re-evaluar en 30 s)
   â””â”€ intento > 3 â”€â”€â”€â–º descartar_capitulo(capitulo, motivo) + log M103 (NUNCA bloquea partida)
```

### 2.4 Flujo de revalidaciÃ³n â€” RF3/RF19

```
SeÃ±al de maestrÃ­a del capÃ­tulo N (ej: M34 "pez_capturado") llega SIN el trigger del 92 disparado
   â–¼
seÃ±al âˆˆ mapa revalidacion[N]
   â–¼ sÃ­
completar_capitulo(N) en silencio; no se despliega ningÃºn paso; log M103 "revalidado por maestrÃ­a previa"
```

## 3. DiseÃ±o de datos (Resources)

```
res://tutorial/data/capitulos.json  â†’ src para generar .tres (o .tres directos)
GameState.M92:
{
  "capitulos": { "llegada": 1, "mover": 1, "interactuar": 1, ... },
  "pistas_off": false, "consejos_off": false,
  "consejos_vistos": ["consejo_riego", ...],
  "replay_en_curso": null
}
```

## 4. Diagrama de estados del presentador (M53)

```
ACTIVO â”€â”€(paso completado)â”€â”€â–º CONSECUENCIA(2 s) â”€â”€â–º ESPERANDO
  â”‚                              â”‚
  â”œâ”€â”€(skip)â”€â”€â–º SKIPPED â—„â”€â”€(skip_global)
  â””â”€â”€(pista sin meta)â”€â”€â–º PISTA â”€â”€(expira/alejarse)â”€â”€â–º ESPERANDO
                   (menÃº abierto)    (menÃº cerrado)
                          â–¼              â–²
                        DORMIDO â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 5. Contratos de integraciÃ³n (resumen)

| Sistema | QuÃ© consume el 92 | QuÃ© entrega el 92 |
|---|---|---|
| M53 UI-UX | Normas de presentaciÃ³n, localizaciÃ³n, opciones de juego | Datos de pistas/guiones y seÃ±ales de estado; claves `tr()` |
| M70 Interacciones | SeÃ±al `interaccion_terminada`, prompt del HUD | Pista de tecla E alineada al prompt del 70 (sin duplicaciÃ³n) |
| M13 Herramientas | SeÃ±al `herramienta_equipada` | CapÃ­tulo de herramientas (pasos de equipar y usar) |
| M33 Agricultura | SeÃ±ales `cultivo_plantado/regado/cosechado` | CapÃ­tulo de cultivo en el primer campo |
| M34 Pesca | SeÃ±al `pez_capturado` | CapÃ­tulo de pesca por fases (lanzar/mini-juego/recoger) |
| M35 MinerÃ­a | SeÃ±al `veta_rota` | CapÃ­tulo de minerÃ­a (pico + energÃ­a) |
| M16 Crafting | SeÃ±al `item_crafteado` | CapÃ­tulo de crafting en el primer banco |
| M19/M21 NPC | SeÃ±al `dialogo_iniciado/terminado`, estado de ocupaciÃ³n | CapÃ­tulo de primeros vecinos; respeta `set_ocupado` |
| M57 Input | InputMap (acciones: move, interact, tool1..4) | Ãconos de tecla dinÃ¡micos |
| M58 Accesibilidad | Preferencias (duraciÃ³n xN, contraste, tamaÃ±o) | Datos en bruto de pistas (texto, posiciÃ³n, duraciÃ³n) |
| M66 Anti-Softlock | Watchdog global | Timeouts re-programables por capÃ­tulo |
| M103 Logging | Servicio de logs | Logs de degradaciÃ³n, revalidaciÃ³n y descarte |

## 6. Estado de implementaciÃ³n (iter. 1-4, actualizado 2026-09-17)

| IteraciÃ³n | Contenido | Log |
|---|---|---|
| 1 (nÃºcleo) | TutorialManager autoload: capÃ­tulos PISTA/SECUENCIA, triggers de seÃ±al, revalidaciÃ³n, estados, persistencia M59 | 259 |
| 2 (triggers) | Triggers acciÃ³n vÃ­a EventBus real + mundo por proximidad (throttle 0,25 s, distÂ²) + watchdog RF23 + degradaciÃ³n + gate M19 | 336/911 |
| 3 (lÃ³gica completa) | Interruptores RF9 independientes + consejos RF6 + contexto T-016 + persistencia de pasos P4 + skip/re-play RF7-RF8 (snapshot) + feedback RF24/P15 + pistas mÃ¡x. 2 (P2/P13/P14) + P5/P6/P8/P9 | 914 |
| 4 (data-driven) | Guiones `.tres` (`TutorialGuiones` + `guiones_base.tres`, fallback por cÃ³digo) + early-return de proximidad sin triggers + espejo documental | 987 |

Contratos vivos para M53: seÃ±ales `paso_mostrado`, `capitulo_iniciado/completado`, `capitulo_timeout/descartado`, `feedback_capitulo`, `consejo_mostrado`, `pista_expirada`, `capitulo_pospuesto`, `pistas_ocultas`; API `icono_tecla_dinamico()`, `pistas_vivas()`, interruptores `set_pistas_contextuales`/`set_prologo_guiado`/`set_consejos`.

## Specs Tutorial (Beam 523)

### RF14: capítulo Cultivo (azada → semilla → regar → esperar → cosechar)
- Spec: RF14: capítulo Cultivo: azada → semilla → regar → esperar → cosechar con E, paso a paso. Coherente con M92 (tutorial) y M33 (agricultura).

### RF15: capítulo Pesca (equipar caña → lanzar → mini-juego → recoger pez)
- Spec: RF15: capítulo Pesca: equipar caña → lanzar → mini-juego → recoger pez, por fases. Coherente con M92 (tutorial) y M34 (pesca).

### K2: pasos cultivo con consejo de tiempo real
- Spec: K2: pasos: usar azada → plantar semilla → regar → esperar (consejo de tiempo real) → cosechar con E. Coherente con M92 (tutorial) y M33 (agricultura).

## Specs Tutorial (Beam 644)

### RF11: capítulo Moverse: guía de WASD/joystick con celebración de llegada al punto
- Spec: RF11: capítulo Moverse: guía de WASD/joystick con celebración de llegada al punto. Coherente with M92 (tutorial) and M10 (personaje).

### RF11: la pista de movimiento desaparece al detectar input de dirección
- Spec: RF11: la pista de movimiento desaparece al detectar input de dirección. Coherente with M92 (tutorial) and M10 (personaje).

### RF16: capítulo Minería: equipar pico → romper veta → recoger mineral, con aviso de energía
- Spec: RF16: capítulo Minería: equipar pico → romper veta → recoger mineral, con aviso de energía. Coherente with M92 (tutorial) and M35 (minería).

### RF17: capítulo Crafting: abrir banco → mostrar receta requerida → fabricar → verificar inventario
- Spec: RF17: capítulo Crafting: abrir banco → mostrar receta requerida → fabricar → verificar inventario. Coherente with M92 (tutorial) and M16 (crafting).

### RF4: burbuja world-space anclada al objetivo de la lección con texto <= 2 líneas
- Spec: RF4: burbuja world-space anclada al objetivo de la lección con texto <= 2 líneas. Coherente with M92 (tutorial) and M53 (UI).


## Specs Tutorial (Beam 645)

### RF4: flecha opcional apuntando al objetivo cuando esta fuera de pantalla
- Spec: RF4: flecha opcional apuntando al objetivo cuando esta fuera de pantalla. Coherente with M92 (tutorial) and M53 (UI).

### RF4: la burbuja se oculta con fade al expirar, al alejarse (> 6 m) o al cumplir la accion
- Spec: RF4: la burbuja se oculta con fade al expirar, al alejarse (> 6 m) o al cumplir la accion. Coherente with M92 (tutorial) and M53 (UI).

### RF8: confirmacion obligatoria antes de re-jugar (M53)
- Spec: RF8: confirmacion obligatoria antes de re-jugar (M53). Coherente with M92 (tutorial) and M53 (UI).

### RN1: tono amable sin urgencia ("cuando quieras"), sin castigo por ignorar pistas
- Spec: RN1: tono amable sin urgencia ("cuando quieras"), sin castigo por ignorar pistas. Coherente with M92 (tutorial) and M152 (objetivo final).

### RN2: el tiempo con pistas activas no supera el 10% de la sesion
- Spec: RN2: el tiempo con pistas activas no supera el 10% de la sesion. Coherente with M92 (tutorial) and M61 (rendimiento).


## Specs Tutorial (Beam 646)

### RN7: 100% de textos con claves tr() (soporte inicial ES/EN)
- Spec: RN7: 100% de textos con claves tr() (soporte inicial ES/EN). Coherente with M92 (tutorial) and M86 (localizacion).

### RN8: determinismo: mismo input + mismo mundo = mismo disparo de lecciones
- Spec: RN8: determinismo: mismo input + mismo mundo = mismo disparo de lecciones. Coherente with M92 (tutorial) and M08 (terreno).

### RN12: duracion de pistas escalable x1/x2/x4 y tamano/contraste desde preferencias de M58
- Spec: RN12: duracion de pistas escalable x1/x2/x4 y tamano/contraste desde preferencias de M58. Coherente with M92 (tutorial) and M58 (accesibilidad).

### H1: el 92 entrega datos de pistas y M53 dibuja la burbuja final
- Spec: H1: el 92 entrega datos de pistas y M53 dibuja la burbuja final. Coherente with M92 (tutorial) and M53 (UI).

### H3: re-play desde el menu de opciones con confirmacion
- Spec: H3: re-play desde el menu de opciones con confirmacion. Coherente with M92 (tutorial) and M53 (UI).


## Specs Tutorial (Beam 647)

### H4: localizacion: todas las claves tr() siguen el flujo de traduccion de M53
- Spec: H4: localizacion: todas las claves tr() siguen el flujo de traduccion de M53. Coherente with M92 (tutorial) and M86 (localizacion).

### H5: el mensaje "capitulo completado" respeta las normas de HUD de M53
- Spec: H5: el mensaje "capitulo completado" respeta las normas de HUD de M53. Coherente with M92 (tutorial) and M53 (UI).

### H7: el marcador de objetivo del prologo usa componentes de M53 sin duplicacion
- Spec: H7: el marcador de objetivo del prologo usa componentes de M53 sin duplicacion. Coherente with M92 (tutorial) and M53 (UI).

### I1: el capitulo Interactuar se dispara en el primer interactuable (totem de bienvenida)
- Spec: I1: el capitulo Interactuar se dispara en el primer interactuable (totem de bienvenida). Coherente with M92 (tutorial) and M06 (puzzles).

### I2: la pista de tecla E se alinea al prompt del 70 (sin iconos duplicados en pantalla)
- Spec: I2: la pista de tecla E se alinea al prompt del 70 (sin iconos duplicados en pantalla). Coherente with M92 (tutorial) and M53 (UI).


## Specs Tutorial (Beam 648)

### I3: se consume la señal interaccion_terminada para validar el paso
- Spec: I3: se consume la señal interaccion_terminada para validar el paso. Coherente with M92 (tutorial) and M06 (puzzles).

### I5: la burbuja del 92 se oculta cuando el prompt del 70 está en INTERACTUANDO
- Spec: I5: la burbuja del 92 se oculta cuando el prompt del 70 está en INTERACTUANDO. Coherente with M92 (tutorial) and M70 (progresión).

### I6: capítulo Interactuar también enseña el prompt atenuado (no disponible con razón)
- Spec: I6: capítulo Interactuar también enseña el prompt atenuado (no disponible con razón). Coherente with M92 (tutorial) and M70 (progresión).

### I7: el 92 usa la localización de nombres del 70 (obtener_nombre_prompt) si aplica
- Spec: I7: el 92 usa la localización de nombres del 70 (obtener_nombre_prompt) si aplica. Coherente with M92 (tutorial) and M86 (localización).

### J2: la pista explica brevemente la acción de la herramienta y la energía consumida
- Spec: J2: la pista explica brevemente la acción de la herramienta y la energía consumida. Coherente with M92 (tutorial) and M13 (herramientas).


## Specs Tutorial (Beam 649)

### J3: se consume la señal de herramienta equipada para validar el paso
- Spec: J3: se consume la señal de herramienta equipada para validar el paso. Coherente with M92 (tutorial) and M13 (herramientas).

### K3: se consumen las señales de cultivo (plantado, regado, cosechado) para avanzar pasos
- Spec: K3: se consumen las señales de cultivo (plantado, regado, cosechado) para avanzar pasos. Coherente with M92 (tutorial) and M33 (agricultura).

### K4: la pista de "esperar a mañana" no obliga el envejecimiento de día (consejo contextual)
- Spec: K4: la pista de "esperar a mañana" no obliga el envejecimiento de día (consejo contextual). Coherente with M92 (tutorial) and M33 (agricultura).

### K5: si el jugador destruye la parcela, reprogramar o descartar vía watchdog (RF23)
- Spec: K5: si el jugador destruye la parcela, reprogramar o descartar vía watchdog (RF23). Coherente with M92 (tutorial) and M33 (agricultura).

### L1: capítulo Pesca en el primer muelle con caña de madera
- Spec: L1: capítulo Pesca en el primer muelle con caña de madera. Coherente with M92 (tutorial) and M34 (pesca).


## Specs Tutorial (Beam 650)

### L3: después de un fallo en el mini-juego, la pista se re-muestra amable (sin castigo)
- Spec: L3: después de un fallo en el mini-juego, la pista se re-muestra amable (sin castigo). Coherente with M92 (tutorial) and M34 (pesca).

### L4: se consume la señal pez_capturado para completar el paso final
- Spec: L4: se consume la señal pez_capturado para completar el paso final. Coherente with M92 (tutorial) and M34 (pesca).

### M1: capítulo Minería en la primera veta con pico de madera
- Spec: M1: capítulo Minería en la primera veta con pico de madera. Coherente with M92 (tutorial) and M35 (minería).

### M2: pistas: equipar pico, romper veta, recoger mineral, aviso de energía
- Spec: M2: pistas: equipar pico, romper veta, recoger mineral, aviso de energía. Coherente with M92 (tutorial) and M35 (minería).

### M3: se consume la señal veta_rota para validar el paso
- Spec: M3: se consume la señal veta_rota para validar el paso. Coherente with M92 (tutorial) and M35 (minería).


## Specs Tutorial (Beam 651)

### M4: si la veta es inalcanzable (pico insuficiente), el capítulo espera la veta correcta o se re-programa
- Spec: M4: si la veta es inalcanzable (pico insuficiente), el capítulo espera la veta correcta o se re-programa. Coherente with M92 (tutorial) and M35 (minería).

### N1: capítulo Crafting en el primer banco de trabajo
- Spec: N1: capítulo Crafting en el primer banco de trabajo. Coherente with M92 (tutorial) and M16 (crafting).

### N2: la pista marca la receta requerida por la historia (ítem único)
- Spec: N2: la pista marca la receta requerida por la historia (ítem único). Coherente with M92 (tutorial) and M16 (crafting).

### N4: se consume la señal item_crafteado para completar el capítulo
- Spec: N4: se consume la señal item_crafteado para completar el capítulo. Coherente with M92 (tutorial) and M16 (crafting).

### N5: si el jugador no tiene los materiales, la pista indica dónde conseguirlos (sin misión)
- Spec: N5: si el jugador no tiene los materiales, la pista indica dónde conseguirlos (sin misión). Coherente with M92 (tutorial) and M16 (crafting).


## Specs Tutorial (Beam 652)

### O2: la pista explica la opcion de dialogo (elegir linea con E)
- Spec: O2: la pista explica la opcion de dialogo (elegir linea con E). Coherente with M92 (tutorial) and M20 (dialogos).

### O3: se consume dialogo_iniciado/dialogo_terminado para validar el paso
- Spec: O3: se consume dialogo_iniciado/dialogo_terminado para validar el paso. Coherente with M92 (tutorial) and M20 (dialogos).

### O5: la leccion termina con la entrega del primer regalo (sin mision formal de M22)
- Spec: O5: la leccion termina con la entrega del primer regalo (sin mision formal de M22). Coherente with M92 (tutorial) and M22 (historia).

### P12: jugador con lectura lenta (M58 x4): las pistas permanecen sin bloquear acciones
- Spec: P12: jugador con lectura lenta (M58 x4): las pistas permanecen sin bloquear acciones. Coherente with M92 (tutorial) and M58 (accesibilidad).

### Q8: profiler: verificar <= 0.2 ms en la zona de la plaza con NPCs y cultivos
- Spec: Q8: profiler: verificar <= 0.2 ms en la zona de la plaza con NPCs y cultivos. Coherente with M92 (tutorial) and M61 (rendimiento).
