**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 92: Tutorial

## 1. Arquitectura general

El módulo 92 se compone de 4 subsistemas coordinados por un **TutorialManager** (autoload):

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
│ señal + cond │  │ pasos + meta   │  │ RN6 < 1 KB     │
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚                  â”‚
â”Œâ”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Pistas       â”‚  â”‚ Secuencia      â”‚  â”‚ Sistema de      â”‚
â”‚ contextuales â”‚  â”‚ guiada (paso   â”‚  â”‚ consejos (tips  â”‚
â”‚ (burbuja WF) â”‚  â”‚ con marcador)  â”‚  â”‚ opcionales)     â”‚
│ pool ≤ 2     │  │ prólogo        │  │ 1 sola vez      │
â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                 â–¼
        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
        │ UI de presentación│      │ InputMap (M57)     │
        │ (pertenece a M53) │      │ iconos dinámicos   │
        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1.1 TutorialManager (autoload `Tutorial`)
- Orquestador: recibe señales, evalúa triggers, activa/libera guiones y pistas.
- No posee UI final: expone señales y datos; M53 los dibuja (interfaz `TutorialPresentador`).
- Estado global: `ACTIVO` (guion en curso), `ESPERANDO` (sin guion, escuchando triggers), `PISTA` (burbuja informativa sin pasos), `CONSECUENCIA` (aviso "¡capítulo completado!"), `SKIPPED` (tutorial apagado), `DORMIDO` (menú/diálogo/pausa abiertos).

### 1.2 Triggers (RF2)
Objetos ligeros que asocian una condición a un guion:
- **Trigger de señal:** escucha la señal X de un sistema (M70, M33, M34, M16...) y una condición de contexto (jugador en zona, día ≥ N).
- **Trigger de mundo:** proximidad del jugador a un nodo marcado (`ITutorialTarget`, ej: tótem de bienvenida, primer campo, muelle).
- **Trigger de acción:** primera entrada de ciertas acciones (moverse, presionar E con prompt del 70).

### 1.3 Guiones (capítulos)
`CapituloGuion` como Resource:
```
id, titulo_localizable, trigger, pasos[], meta (señal de maestría), timeout_default, rejugable (bool)
Paso: { tipo: PISTA | SECUENCIA | CONSEJO, texto_clave (tr), objetivo (NodePath/ITutorialTarget), icono_tecla (InputMap action o null), duracion_min, espera_senal }
```
- Los pasos de tipo SECUENCIA muestran marcador de objetivo + aceptan solo avanzar al cumplir la meta (sin bloquear otras acciones).
- Los pasos de tipo PISTA son informativos y no esperan cumplimiento (se cierran al expirar o al ejecutar la acción).

### 1.4 Pistas contextuales
- Pool de burbujas world-space (≤ 2 vivas): el texto se proyecta en la posición del objetivo con offset según cámara; la burbuja se oculta con fade al expirar, al alejarse (distancia > 6 m), al abrir UI, o al cumplirse la acción.
- Ícono de tecla resuelto en runtime desde InputMap (M57); soporte teclado/gamepad.
- Ninguna pista bloquea input ni movimiento.

### 1.5 Sistema de consejos
- Lista de consejos (Resource `Consejo`) con: id, texto tr, contexto permitido (cargando escena, caminando > 10 s sin acción, en menú de pausa), cooldown entre consejos (≥ 90 s).
- Se muestran una sola vez (registro en `consejos_vistos`), respetan el interruptor global y no compiten con pistas activas.
- Nunca dentro de diálogos (M21) ni durante cutscenes.

## 2. Flujos

### 2.1 Flujo principal: disparo → lección → cierre

```
[Jugador entra al mundo]                    [Sistema emite señal X]
        â”‚                                            â”‚
        â–¼                                            â–¼
TutorialManager.ACTIVO/ESPERANDO ◄───── evaluar_triggers(señal, contexto)
        â”‚
        ▼ (se cumple trigger de capítulo N)
desplegar_capitulo(N)
        â”‚
        ├─ ¿meta ya cumplida antes? (revalidación RF3/RF19)
        â”‚     â””â”€â–º completar_capitulo(N) en silencio â†’ log M103
        â”‚
        â–¼ no
mostrar paso 1 (PISTA o SECUENCIA con marcador)
        â”‚
        ▼ jugador ejecuta la acción (o expira / se aleja)
paso = completado
        â–¼ (siguiente paso o fin)
completar_capitulo(N): feedback "capítulo completado" (2 s, M44) + persistir GameState.M92
        â”‚
        └─► si N == último → TutorialManager avisa "tutorial disponible en opciones"
```

### 2.2 Flujo de skip y re-play

```
Opciones (M53) ──► skip_global(): Tutorial.skipped = true; pistas activas se ocultan; capítulos futuros NO se disparan
Opciones (M53) â”€â”€â–º skip_capitulo(): libera guion actual sin marcar completo
Opciones (M53) â”€â”€â–º replay(capitulo_id | "todos"):
     1) snapshot de GameState.M92 (RN11, no contamina la partida)
     2) mostrar aviso de confirmación (M53): "Se reiniciará el tutorial de [X]"
     3) al confirmar: desplegar el guion con estado_replay (sin revalidación)
     4) al terminar: restaurar snapshot si hubo cambios conflictivos
```

### 2.3 Flujo de recuperación (watchdog) — RF23

```
capitulo_esperando_meta(> timeout_default 120 s)
   â–¼
intento += 1
   â”œâ”€ intento <= 3 â”€â”€â–º reprogramar_trigger(capitulo) (re-evaluar en 30 s)
   â””â”€ intento > 3 â”€â”€â”€â–º descartar_capitulo(capitulo, motivo) + log M103 (NUNCA bloquea partida)
```

### 2.4 Flujo de revalidación — RF3/RF19

```
Señal de maestría del capítulo N (ej: M34 "pez_capturado") llega SIN el trigger del 92 disparado
   â–¼
señal ∈ mapa revalidacion[N]
   ▼ sí
completar_capitulo(N) en silencio; no se despliega ningún paso; log M103 "revalidado por maestría previa"
```

## 3. Diseño de datos (Resources)

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
                   (menú abierto)    (menú cerrado)
                          â–¼              â–²
                        DORMIDO â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 5. Contratos de integración (resumen)

| Sistema | Qué consume el 92 | Qué entrega el 92 |
|---|---|---|
| M53 UI-UX | Normas de presentación, localización, opciones de juego | Datos de pistas/guiones y señales de estado; claves `tr()` |
| M70 Interacciones | Señal `interaccion_terminada`, prompt del HUD | Pista de tecla E alineada al prompt del 70 (sin duplicación) |
| M13 Herramientas | Señal `herramienta_equipada` | Capítulo de herramientas (pasos de equipar y usar) |
| M33 Agricultura | Señales `cultivo_plantado/regado/cosechado` | Capítulo de cultivo en el primer campo |
| M34 Pesca | Señal `pez_capturado` | Capítulo de pesca por fases (lanzar/mini-juego/recoger) |
| M35 Minería | Señal `veta_rota` | Capítulo de minería (pico + energía) |
| M16 Crafting | Señal `item_crafteado` | Capítulo de crafting en el primer banco |
| M19/M21 NPC | Señal `dialogo_iniciado/terminado`, estado de ocupación | Capítulo de primeros vecinos; respeta `set_ocupado` |
| M57 Input | InputMap (acciones: move, interact, tool1..4) | Íconos de tecla dinámicos |
| M58 Accesibilidad | Preferencias (duración xN, contraste, tamaño) | Datos en bruto de pistas (texto, posición, duración) |
| M66 Anti-Softlock | Watchdog global | Timeouts re-programables por capítulo |
| M103 Logging | Servicio de logs | Logs de degradación, revalidación y descarte |

## 6. Estado de implementación (iter. 1-4, actualizado 2026-09-17)

| Iteración | Contenido | Log |
|---|---|---|
| 1 (núcleo) | TutorialManager autoload: capítulos PISTA/SECUENCIA, triggers de señal, revalidación, estados, persistencia M59 | 259 |
| 2 (triggers) | Triggers acción vía EventBus real + mundo por proximidad (throttle 0,25 s, dist²) + watchdog RF23 + degradación + gate M19 | 336/911 |
| 3 (lógica completa) | Interruptores RF9 independientes + consejos RF6 + contexto T-016 + persistencia de pasos P4 + skip/re-play RF7-RF8 (snapshot) + feedback RF24/P15 + pistas máx. 2 (P2/P13/P14) + P5/P6/P8/P9 | 914 |
| 4 (data-driven) | Guiones `.tres` (`TutorialGuiones` + `guiones_base.tres`, fallback por código) + early-return de proximidad sin triggers + espejo documental | 987 |

Contratos vivos para M53: señales `paso_mostrado`, `capitulo_iniciado/completado`, `capitulo_timeout/descartado`, `feedback_capitulo`, `consejo_mostrado`, `pista_expirada`, `capitulo_pospuesto`, `pistas_ocultas`; API `icono_tecla_dinamico()`, `pistas_vivas()`, interruptores `set_pistas_contextuales`/`set_prologo_guiado`/`set_consejos`.

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

### Specs items degradados T220 (2026-10-26, Reflection-Beam-1.0)
- **L55 (RF19 mapeo de revalidación por dominio+señal revalidacion.gd M70/M33/M34/M35/M16/M19):** REVERTIDO por re-auditoría H2-estricta BUG-070 (atria-dawn s2 #150, 2026-10-08): artefacto inexistente + autocontradicción en 04-Codigo.md. Ver msg s2 #150.
- **L64 (RF5 prólogo guiado suave Llegada + Moverse con marcador de objetivo en HUD):** spec definida.
- **L130 (G3: 3 tipos de trigger señal/mundo/acción derivados de clase base Trigger):** spec definida.
- **L183 (L2: pistas por fase equipar caña/lanzar/mini-juego de retención/recoger pez):** spec definida.
- **L202 (N3: pasos abrir banco → seleccionar receta → fabricar → verificar en inventario M14):** spec definida.
