**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 80: Legal — Privacidad

> ⚠️ **Aviso:** Este documento describe el diseño del módulo administrativo/legal. **No constituye asesoramiento legal profesional.**

## 1. Arquitectura general

```
┌─────────────────────────────────────────────────────────────┐
│  FUENTE DE VERDAD (repositorio)                              │
│  DOCUMENTACION/80-Legal-Privacidad/                          │
│  ├── plan-inicial/ (inmutable)                               │
│  └── plan-actual/  (vigente)                                 │
│  └── PRIVACY-POLICY.md        → texto canónico de la política│
│  └── DATA-DEclaration.md      → declaración de datos         │
└─────────────────────────────────────────────────────────────┘
                     │
                     │ copia embebida en el juego
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  GODOT 4.x (GDScript, offline)                               │
│  res://legal/                                                │
│  ├── privacy_policy.md           (recurso texto embebido)    │
│  ├── data_declaration.md         (recurso texto embebido)    │
│  ├── privacy_config.tres         (versión, fecha, email)     │
│  └── privacy_menu.gd             (UI: renderiza la política) │
└─────────────────────────────────────────────────────────────┘
                     │
                     ├──► Menú principal ► Sección «Privacidad»
                     ├──► Configuración ► enlace «Política de privacidad»
                     └──► M104 (Analytics) ► estado del opt-out
```

## 2. Estructura de la política (PRIVACY-POLICY.md)

| # | Sección | Contenido |
|---|---|---|
| 1 | Introducción | Quién es el responsable, qué es el juego (single-player offline, isla Aurora) |
| 2 | Resumen ejecutivo | En 5 líneas: no recogemos datos personales; solo telemetría opcional agregada si tú la activas |
| 3 | Datos que recogemos | Tabla: «Ninguno por defecto»; «Telemetría opcional (M104)»: bioma visitado, duración de sesión, eventos de uso — agregados y anonimizados |
| 4 | Datos que NO recogemos | Ninguno de cuentas, email, ubicación, IP, nombre real, ni datos de dispositivos identificables |
| 5 | Consentimiento | Diálogo informado al primer arranque solo si la telemetría está activa; revocable en cualquier momento |
| 6 | Opt-out | Cómo desactivar la telemetría (Menú ► Configuración ► Analytics) y qué ocurre (borrado inmediato del buffer local) |
| 7 | Derechos del usuario | Acceso, rectificación, borrado, portabilidad, oposición (GDPR art. 15-21); know/delete (CCPA) |
| 8 | Menores | No dirigido a menores de 13 (COPPA); consentimiento parental 13-16 en la UE (GDPR); contacto para tutores |
| 9 | Retención | Plazos: partidas mientras el jugador las conserve; telemetría máx. 30 días; borrado automático |
| 10 | Seguridad | Datos locales en el dispositivo del jugador; sin transmisión en el estado por defecto |
| 11 | Cambios en la política | Versionado, fecha de última actualización, aviso en el menú si cambia la versión local |
| 12 | Cumplimiento regional | GDPR, COPPA, CCPA: qué aplica y cómo cumple el juego |
| 13 | Contacto | Email de privacidad del estudio; plazos de respuesta (30 días GDPR) |
| 14 | Aviso legal | Documento informativo; no constituye asesoramiento legal profesional |

## 3. Declaración de datos (DATA-DEclaration.md)

Tabla canónica que cruza: fuente de datos → ¿se recoge? → ¿con qué fin? → base legal → retención → opt-out.

| Dato | Por defecto | Con M104 activa | Fin | Base legal | Retención | Opt-out |
|---|---|---|---|---|---|---|
| Partida local (inventario, posición) | Sí (local) | Sí (local) | Progresión | Legítimo interés técnico | Hasta borrado manual | — |
| Estado de configuración | Sí (local) | Sí (local) | Experiencia | Legítimo interés técnico | Hasta borrado manual | — |
| Bioma visitado (agregado) | No | Sí | Mejora de diseño | Consentimiento | Máx. 30 días | Toggle M104 |
| Duración de sesión (agregada) | No | Sí | Balance | Consentimiento | Máx. 30 días | Toggle M104 |
| Uso de features (contadores) | No | Sí | Priorización | Consentimiento | Máx. 30 días | Toggle M104 |
| Datos personales (nombre, email, IP) | No | No | — | — | — | — |

## 4. Flujo de consentimiento

### 4.1 Escenario A — Telemetría desactivada (estado por defecto)
1. El jugador inicia el juego por primera vez.
2. No se muestra diálogo de consentimiento (no hay datos que consentir).
3. La política es accesible opcionalmente desde el menú ► «Privacidad».

### 4.2 Escenario B — Telemetría activa (configuración de desarrollo o futura build)
1. El jugador inicia el juego; el sistema detecta `analytics.enabled == true` (M104).
2. Se muestra un diálogo informativo: qué se recoge, para qué, cómo desactivarlo, enlace a la política completa.
3. Botones: «Aceptar y jugar» / «No, desactivar telemetría».
4. Si acepta: M104 comienza a capturar; el consentimiento se persiste localmente (sin datos personales).
5. En cualquier momento: Configuración ► Analytics ► «Desactivar» → M104 detiene captura y borra el buffer inmediatamente (decisión 80-D2).
6. Si el jugador desactiva: la política sigue accesible; no hay ventana de «re-consentimiento» intrusiva.

## 5. Publicación del documento

| Canal | Formato | Notas |
|---|---|---|
| Web oficial del juego | `https://juegoislaancestral.com/privacidad` (URL estable) | Versión canónica pública; enlazada desde tiendas |
| Menú del juego | Sección «Privacidad» en el menú principal (escena Godot `res://legal/`) | Versión embebida de referencia; texto plano renderizado en UI |
| Panel de configuración | Enlace corto «Política de privacidad» en Configuración | Acceso rápido sin romper la navegación |
| Tiendas (Steam/Epic/otras) | Texto o enlace según requisitos de cada plataforma | Fragmentos derivados de la sección 2 |

## 6. Telemática con M104 (integración)

- `privacy_config.tres` lee el estado de `M104` (opt-out) solo para mostrar el estado en la sección «Privacidad» («Telemetría: activa/desactivada»).
- El diálogo de consentimiento se dispara desde `privacy_menu.gd` consultando la config de M104; no posee lógica de captura propia (modularidad, AGENTS.md §9).
- Si M104 no existe aún (pendiente de implementación), el flujo A (sin diálogo) es el comportamiento correcto.

## 7. Flujo de peticiones de usuario (derechos)

1. El jugador/tutor escribe al email de privacidad (sección 13 de la política).
2. El estudio registra la petición (ticket con fecha).
3. Para borrado: se indican los pasos (borrar partida local de `user://` y desactivar telemetría) y se confirma por email.
4. Para acceso/portabilidad: se exporta la partida local en JSON (formato legible) como respuesta.
5. Plazo de respuesta: 30 días (GDPR) desde la recepción.

## 8. Edge cases de diseño

| Caso | Diseño |
|---|---|
| Jugador menor de edad | La política lo declara; no se recogen datos personales; contacto para tutores; sin verificación de edad online (innecesaria sin datos) |
| Jurisdicción desconocida | La política aplica la normativa más estricta de las citadas (GDPR) como base común |
| Petición de borrado | Flujo del punto 7; borrado local guiado + respuesta por email |
| Cambio de política | Versionado con fecha; aviso único en menú si `privacy_config.version` > versión vista |
| Opt-out a mitad de partida | Detención inmediata + borrado de buffer (M104); sin pérdida de partida |
| Sin conexión | La política está embebida; se muestra offline sin problemas |