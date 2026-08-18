**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 92: Tutorial

## 1. Arquitectura general

El módulo 92 se compone de 4 subsistemas coordinados por un **TutorialManager** (autoload):

```
┌─────────────────────────────────────────────────────────────┐
│                    TutorialManager (autoload)                │
│  Estado: ACTIVO/ESPERANDO/PISTA/CONSECUENCIA/SKIPPED/DORMIDO │
│  Registro global: capitulos[], pistas activas, consejos vistos│
└──────┬──────────────────┬──────────────────┬────────────────┘
       │ escucha          │ instancia        │ lee/escribe
┌──────▼───────┐  ┌───────▼────────┐  ┌───────▼────────┐
│ Triggers     │  │ Guiones        │  │ GameState.M92  │
│ (RF2)        │  │ (CapituloGuion)│  │ persistencia   │
│ señal + cond │  │ pasos + meta   │  │ RN6 < 1 KB     │
└──────┬───────┘  └───────┬────────┘  └─────────────────┘
       │                  │
┌──────▼───────┐  ┌───────▼────────┐  ┌─────────────────┐
│ Pistas       │  │ Secuencia      │  │ Sistema de      │
│ contextuales │  │ guiada (paso   │  │ consejos (tips  │
│ (burbuja WF) │  │ con marcador)  │  │ opcionales)     │
│ pool ≤ 2     │  │ prólogo        │  │ 1 sola vez      │
└──────┬───────┘  └───────┬────────┘  └─────────────────┘
       └─────────┬───────┘
                 ▼
        ┌───────────────────┐      ┌────────────────────┐
        │ UI de presentación│      │ InputMap (M57)     │
        │ (pertenece a M53) │      │ iconos dinámicos   │
        └───────────────────┘      └────────────────────┘
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
        │                                            │
        ▼                                            ▼
TutorialManager.ACTIVO/ESPERANDO ◄───── evaluar_triggers(señal, contexto)
        │
        ▼ (se cumple trigger de capítulo N)
desplegar_capitulo(N)
        │
        ├─ ¿meta ya cumplida antes? (revalidación RF3/RF19)
        │     └─► completar_capitulo(N) en silencio → log M103
        │
        ▼ no
mostrar paso 1 (PISTA o SECUENCIA con marcador)
        │
        ▼ jugador ejecuta la acción (o expira / se aleja)
paso = completado
        ▼ (siguiente paso o fin)
completar_capitulo(N): feedback "capítulo completado" (2 s, M44) + persistir GameState.M92
        │
        └─► si N == último → TutorialManager avisa "tutorial disponible en opciones"
```

### 2.2 Flujo de skip y re-play

```
Opciones (M53) ──► skip_global(): Tutorial.skipped = true; pistas activas se ocultan; capítulos futuros NO se disparan
Opciones (M53) ──► skip_capitulo(): libera guion actual sin marcar completo
Opciones (M53) ──► replay(capitulo_id | "todos"):
     1) snapshot de GameState.M92 (RN11, no contamina la partida)
     2) mostrar aviso de confirmación (M53): "Se reiniciará el tutorial de [X]"
     3) al confirmar: desplegar el guion con estado_replay (sin revalidación)
     4) al terminar: restaurar snapshot si hubo cambios conflictivos
```

### 2.3 Flujo de recuperación (watchdog) — RF23

```
capitulo_esperando_meta(> timeout_default 120 s)
   ▼
intento += 1
   ├─ intento <= 3 ──► reprogramar_trigger(capitulo) (re-evaluar en 30 s)
   └─ intento > 3 ───► descartar_capitulo(capitulo, motivo) + log M103 (NUNCA bloquea partida)
```

### 2.4 Flujo de revalidación — RF3/RF19

```
Señal de maestría del capítulo N (ej: M34 "pez_capturado") llega SIN el trigger del 92 disparado
   ▼
señal ∈ mapa revalidacion[N]
   ▼ sí
completar_capitulo(N) en silencio; no se despliega ningún paso; log M103 "revalidado por maestría previa"
```

## 3. Diseño de datos (Resources)

```
res://tutorial/data/capitulos.json  → src para generar .tres (o .tres directos)
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
ACTIVO ──(paso completado)──► CONSECUENCIA(2 s) ──► ESPERANDO
  │                              │
  ├──(skip)──► SKIPPED ◄──(skip_global)
  └──(pista sin meta)──► PISTA ──(expira/alejarse)──► ESPERANDO
                   (menú abierto)    (menú cerrado)
                          ▼              ▲
                        DORMIDO ────────┘
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