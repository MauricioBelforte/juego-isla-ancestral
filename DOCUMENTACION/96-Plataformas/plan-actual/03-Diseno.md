**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 96: Plataformas

## 1. Matriz de plataformas (resumen de decisiones)

| Plataforma | Prioridad | Decisión | Notas clave |
|-----------|-----------|----------|-------------|
| PC Steam | P0 | SÍ (lanzamiento primario) | SDK, logros, cloud nativa |
| Steam Deck | P0.5 | SÍ (verificación verde/plata) | Proton + controller + resolución 800p |
| Epic (EGS) | P1 | Sí si coste/beneficio (decisión en Beta) | SDK EGS: logros/c cloud |
| GOG | P1 | Opcional (DRM-free) | Sin logros; tienda menos activa |
| macOS | P1 | Sí (Apple Silicon nativo; Intel según telemetría) | Build separada; distribuir vía Steam |
| Linux | P1 | Vía Proton verificado (no nativo) | Página Steam lo informa |
| Microsoft Store | P3 | GATE (solo si infraestructura) | UWP/Xbox no prioritario |
| PlayStation | P2 | GATE por presupuesto/NDA | Diseño console-ready |
| Xbox | P2 | GATE por presupuesto/NDA | idem |
| Nintendo Switch | P2 | GATE por presupuesto/NDA (sugerida primero) | idem |

## 2. Prioridades (P0-P3) y fechas
| Prioridad | Plataforma | Ventana | Depende de |
|-----------|-----------|---------|------------|
| P0 | Steam | Lanzamiento día 0 | M143 |
| P0.5 | Steam Deck | Verificada en RC (M142) | M142 |
| P1 | EGS / GOG / macOS / Linux-Proton | +1 a +3 meses | Decisión Beta + CI multi-target |
| P2 | Consolas | GATE de presupuesto (post-lanzamiento PC) | Contrato + devkits |
| P3 | Microsoft Store / otras | Solo con infraestructura | SI re-evalúa en M144 |

## 3. Arquitectura de portabilidad (console-ready)
```
[CoreGameplay (M07/M71/...)]  ← independiente de plataforma
        │  abstractiones:
        ├── IPlatformBridge (M149):     logros, cloud, overlay, store
        ├── InputSystem (M57):          gamepad/teclado/mouse unificados
        ├── SaveManager (M59/M60):      save portable v3.x + cloud por plataforma
        ├── UI Scale (M58):             safe area, texto 150%, resoluciones 16:9/16:10/21:9/800p
        └── BuildTargets (CI):          Windows, macOS(AS), Linux(Proton), WebGL?(no)
```
- El juego nunca referencia APIs de una tienda directamente (solo IPlatformBridge).
- El Input System usa el paquete oficial de Unity con fallback de teclado (M57).

## 4. Análisis por eje (resumen de la matriz)

### 4.1 Certificación (RF7)
- **Steam**: la más simple (sin certification de tienda; solo revisión de contenido).
- **EGS**: revisión de contenido y requisitos técnicos de build.
- **GOG**: DRM-free y política de distribución.
- **Consolas**: TRC/TC (PlayStation), XR (Xbox), LOTC (Switch) — checklist completo en M142.
- **Deck**: política "Deck Verified/Playable" (3 categorías + parcial).

### 4.2 Costes (RF8)
| Concepto | Coste 1A (estimado) |
|----------|---------------------|
| Fee Steam App ($100 por app) | USD 100 |
| Devkit consola (por plataforma) | USD 500-2500 + NDA |
| Fee de registro EGS | 0 (cuotas rev share) |
| Testing por plataforma (3rd party) | USD 800-2000/plataforma |
| CI multi-target | Infra existente (M61) |
| Total consolas (estimado con testing) | USD 5-10k + devkits |

### 4.3 SDK/Logros/Cloud (RF9/RF10)
| Plataforma | SDK | Logros | Cloud |
|-----------|-----|--------|-------|
| Steam | Steamworks | Sí | Sí |
| EGS | EOS | Sí (EOS Achievements) | Sí (EOS) |
| GOG | GOG Galaxy (opcional) | No | Sí (opcional) |
| macOS/Linux | Idem Steam (build) | Steam | Steam |
| Consolas | SDK propietario | Sí | Sí |

### 4.4 Controller y accesibilidad (RF11)
- M57: gamepad completo (navegación UI, hotbar radial, tools).
- M58: textos 150%, remapeo, subtítulos — funciona en todas las plataformas.
- Steam Deck: se mapea gamepad + pantalla 800p + textos legibles.

### 4.5 Cross-save y cross-play (RF12/RF13)
- **Cross-save**: activo donde la nube de plataforma lo da: Steam↔Steam Deck (automático); consolas con su cloud por tienda. Save portable (v3.x) sin dependencia de plataforma.
- **Cross-play**: NO aplica (juego single-player). Documentado en la sección de decisiones.

## 5. Plan de certificación temprana (feed M142)
1. En Bloqueo de contenido (M141): revisar requisitos de EGS/GOG con el build.
2. En RC (M142): checklist por plataforma firmado (Steam + Deck + macOS).
3. Consolas: checklist solo si hay GATE aprobado.
4. Cero sorpresas de certificación en P0 (RF7 verificado 2 meses antes).

## 6. Qué NO se hace
- No multiplayer/cross-play (documentado).
- No build nativa de Linux si Proton pasa (se informa en la página Steam).
- No Microsoft Store/Xbox/Play/Switch sin GATE de presupuesto.
- No APIs de tienda hardcodeadas en el core (siempre IPlatformBridge).