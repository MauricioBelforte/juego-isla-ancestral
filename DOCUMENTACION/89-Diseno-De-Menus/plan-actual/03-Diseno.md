**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 89: Diseño de Menús

## 1. Arquitectura general

```
[ShellManager (MonoBehaviour/singleton)]
        │  navega: Abrir(IdPantalla) / Cerrar() / Reanudar()
        ├── [NavigatorManager]         ← grafo de adyacencia + atajos; foco visible
        ├── [SettingsManager]          ← settings.json local (controles/audio/gráfica/accesibilidad)
        ├── [ProfileManager]           ← perfiles 1-3 × slots 3-6 (M59)
        ├── Pantallas Shell (prefabs): Principal, Continuar, Nueva, Cargar, Ajustes, Créditos, Salir
        └── Pantallas de partida: Pausa, Inventario, Mapa, Diario, Colección, Habilidades, Relación
```

Principio rector (AGENTS.md §9): las `View`s solo llaman a managers; no tienen lógica de gameplay.

## 2. Modelo de datos
```csharp
public enum IdPantalla { Principal, Continuar, Nueva, Cargar, Ajustes, Creditos, Salir, Pausa,
                         Inventario, Mapa, Diario, Coleccion, Habilidades, Relacion }

// settings.json (local, fuera del save)
public class AjustesGlobales {
    Controles controles;        // remapeo (M58)
    Accesibilidad accesibilidad;// modo color, motion, tamaño texto
    Audio audio;                // buses master/música/SFX/ambient/voces
    Grafica grafica;            // resolución, calidad, vsync, fullscreen, escala UI
}
```

## 3. Flujos principales

### 3.1 Arranque del juego
```
Boot → ShellManager.Inicializar()
   ├─ SettingsManager.Cargar() (settings.json)
   ├─ ProfileManager.Listar()  → "Selección de perfil" si hay múltiples o primero
   └─ Mostrar(Menú Principal)  con Continuar activo si existe save reciente
```

### 3.2 Continuar / Nueva / Cargar
- **Continuar**: `SaveManager.UltimoSaveValido(perfil)` → carga directa. Si hay 2+ perfiles, primero la selección de perfil.
- **Nueva partida**: confirma que no pisa un slot ocupado (o crea uno libre) → tutorial (M139).
- **Cargar partida**: lista de slots con resumen (isla, hora de juego, sellos, temporada) → elegir → cargar.

### 3.3 Pausa
```
Input Pausa (Start/Esc) → ShellManager.Abrir(Pausa)
   ├─ WorldTime.Pausar() (M07/reloj M29) → mundo congelado
   ├─ Opciones: Reanudar / Inventario / Mapa / Diario / Colección / Habilidades /
   │            Relación / Ajustes / Guardar / Salir al título
   └─ Cerrar() → WorldTime.Reanudar()
```
- La pausa conserva "última pantalla abierta" y vuelve a ella al cerrar (estado ligero).

### 3.4 Ajustes
- Categorías: Controles (remepeo M58, sensibilidad), Accesibilidad (modo color, motion, texto, sub), Audio (5 buses), Gráfica (resolución, calidad, vsync, fullscreen).
- Aplicación en vivo: cambio → managers de juego reciben el ajuste inmediatamente.
- Persistencia: al salir de ajustes o en intervalos, guarda settings.json.

### 3.5 Pantallas de contenido (vistas de managers)
| Pantalla | Fuente | Vista |
|----------|--------|-------|
| Inventario | InventoryManager (M16) | Grid paginado 12-20; pestañas (ítems/herramientas/recetas) |
| Mapa | TravelManager (M28) | Mapa por isla; nodos de viaje; marcadores de progreso |
| Diario | DiarioManager (M55 + M148) | Pestañas: misiones/lore/sellos/estación |
| Colección | CollectionManager (M73) | Pestañas: peces/flora/fauna/minerales; fichas con lore |
| Habilidades | ProgressionManager (M71) | Árbol/lista con coste y efecto |
| Relación | FriendManager (M20) | Lista NPC con nivel, regalo del día, hitos |

## 4. Navegación (NavigatorManager)
- **Grafo por pantalla**: cada pantalla declara áreas (botones/listas) y adyacencias (arriba/abajo/izq/der).
- **Atajos globales**: Tab (próximo área), B/Esc (atrás/cerrar), A/Enter (aceptar), Start (pausa).
- **Mouse**: hover actualiza foco; click ejecuta.
- **Foco visible**: anillo/borde OSD en el elemento activo (M58).
- **Retención**: al reabrir una pantalla, el foco recuerda la última posición.

## 5. Estética (M06/M49)
- Tema único: paleta de la isla, tipografía del proyecto, iconografía de línea 2px.
- Plantillas: Header (título + contadores) / Cuerpo (contenido) / Footer (atajos visibles).
- Créditos: scroll con ralentización al final y botón de volver.
- Todas las pantallas con texto escalable al 150% (M58).

## 6. Estados de UI y persistencia
- La UI no persiste en el save v3.x (solo settings.json local).
- Excepción: "última pantalla abierta" se guarda en memoria (no en disco) para volver tras pausa.
- En pausa/cierre con partida activa: confirmación de guardado (M59).

## 7. Qué NO se hace
- No se reescribe M53 (modales/diálogos existentes se reutilizan).
- No UI con lógica de gameplay (AGENTS.md §9).
- No pantallas de contenido con datos cacheados duplicados (siempre managers).

## 8. Nota de mapeo (T-M2): diseño heredado vs. implementación Godot

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-05

Las secciones 1-7 son el diseño original (Unity). Este es el mapa estado-por-pantalla contra el disco (detalles en `04-Codigo.md` §6 y `05-Checklist.md` auditoría):

| Pantalla (diseño) | Implementación real | Estado |
|---|---|---|
| P1 Menú principal | `MenusLayer` (5/6 botones; sin open() al arrancar, sin portada M147, sin versión) | ⚠️ |
| P2 Continuar | `SaveManager` slots (sin selector de perfiles) | ⚠️ |
| P3 Nueva partida | botón "Jugar" → GameFlowManager (sin flujo de slots) | ⚠️ |
| P4 Cargar | no existe pantalla (solo API de slots) | ❌ |
| P5 Ajustes | `SettingsAudioLayer` (solo Audio) | ⚠️ 1/4 |
| P6 Créditos | `CreditsLayer` (scroll, 3 velocidades, cerrar, ThemeUx) | ✅ |
| P7 Salir | `quit()` sin confirmación (RF11) | ❌ |
| P8 Perfiles 1-3 | no existe | ❌ |
| P9 Slots | no hay pantalla propia (API en M59) | ⚠️ |
| P10 Pausa | `PauseLayer` (4 opciones vs 9; apertura solo RF18) | ⚠️ |
| P11 Inventario | `InventoryLayer` (scroll, pestañas Items/Herramientas/Construcción) | ⚠️ |
| P12 Mapa | `full_map_layer` (zona DeepSeek — no tocar) | ⚠️ ajeno |
| P13 Diario | `DiaryLayer` (M55, 89 checks) | ✅ |
| P14 Colección | manager (M73) sin UI | ❌ |
| P15 Habilidades | manager (M71) sin UI | ❌ |
| P16 Relación | manager (M20) sin UI | ❌ |
| P17 Config general | no (solo audio) | ❌ |
| P18 Controles | manager (M58) sin UI | ❌ |
| P19 Accesibilidad | managers sin UI | ❌ |
| P20 Audio | `SettingsAudioLayer` (roundtrip 51/0) | ✅ |
| P21 Gráfica | sin UI | ❌ |

> El grafo Navigator del §4 no existe como tal: `menu_navigator.gd` resuelve foco por capa, no grafo por pantalla (ítem §1 `[?]`-parcial en la auditoría).