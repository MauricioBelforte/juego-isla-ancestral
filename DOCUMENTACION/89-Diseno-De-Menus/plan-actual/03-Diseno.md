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

## 9. Cierres de diseño (iteración T-M3 — mimo-v2.6-flash-free, 2026-10-06)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** OpenCode
**Fecha:** 2026-10-06

Define los puntos que los ítems de `05-Checklist.md` pedían y que no estaban en §1-8.
(Aplican en vivo = el cambio se refleja sin reiniciar; persistencia = `settings.json` §6.)

### 9.1 Menú principal (P1)
- **Música del menú (M41):** bucle de menú en bus `Music`, por defecto -12 dB bajo el master,
  respetando el volumen global; se atenúa 3 s si el usuario baja `Music` a 0 desde Ajustes.
- **Versión visible:** texto micro (M88 `MICRO 10px`) discreto en esquina inferior derecha
  de P1; invisible en partidas.
- **Transiciones sin atascos:** corte o fade ≤ 300 ms entre capas; si una capa tarda más,
  se muestra igual (sin bloquear input — anti-softlock).

### 9.2 Continuar (P2)
- **Sin partida:** si no hay saves, "Continuar" queda deshabilitado con tooltip
  "No hay partidas guardadas"; "Nueva partida" recibe el foco por defecto.
- **Integridad del save (M59/M66):** antes de cargar se valida checksum/firma; si falla,
  se ofrece backup (mismo flujo del reintento guiado §3) y nunca se carga corrupto.

### 9.3 Nueva partida (P3)
- **Confirmación de sobreescribir:** diálogo explícito "¿Sobreescribir slot N? — se perderá
  la partida" con foco inicial en "Cancelar"; el botón primario es "Sobreescribir" solo si
  el usuario navega a él (confirmación explícita, no aceptación por defecto).
- **Nombre editable del perfil:** campo con 1-16 caracteres, sin caracteres de control,
  trim automático; rechaza vacío con mensaje inline (validación antes de crear).

### 9.4 Cargar partida (P4)
- **Orden de slots:** recién usado primero (fecha de último acceso descendente); los slots
  vacíos al final; el orden es estable mientras no cambie el último acceso.
- **Navegación gamepad en la lista:** D-pad arriba/abajo mueve selección con wrap; A abre;
  B vuelve; el foco visible (§4) marca el slot seleccionado.
- **Slots borrables:** acción "Borrar" (Y/Supr) con diálogo "¿Borrar slot N? (se pierde la
  partida)"; confirma → borra el save (M59) y refresca la lista; cancelar no hace nada.

### 9.5 Ajustes (P5/P17)
- **Restablecer por defecto:** botón por categoría (restaura solo esa categoría a defaults);
  diálogo de confirmación; aplica en vivo y persiste (§3.4/§6).
- **Cambios no guardados:** indicador "cambios sin guardar" en el Header mientras haya
  dirty-flag; se limpia al persistir (salir de Ajustes o tras auto-guardado en intervalo §6).

### 9.6 Créditos (P6)
- **Gamepad:** A/Enter = acelerar, B = salir, stick/d-pad = scroll continuo; el ralentizado
  al final (§5) solo aplica en auto-scroll.

### 9.7 Salir (P7)
- **Cancelación sin efectos:** "Cancelar" cierra solo el diálogo; no guarda, no cierra nada.
- **Salida limpia (M60):** si hay sesión activa → confirmación con opción "Guardar y salir"
  (guarda M59) / "Salir sin guardar" / "Cancelar"; después: flush de escrituras pendientes
  (cloud/M60 si aplica), cierre de audio (release de buses) y `quit()` — sin procesos
  residuales.

### 9.8 Selección de perfil (P8)
- **Tarjetas:** por perfil: avatar (o iniciales §9.14), nombre, estadística resumen
  (partidas, horas totales, último acceso); perfil activo con borde de la paleta (§5).
- **Selector recordado:** último perfil activo queda preseleccionado al abrir; persiste en
  `settings.json` (§6, fuera del save).
- **Creación/eliminación:** crear = diálogo con nombre (§9.3); borrar = confirmación con el
  nombre del perfil y conteo de partidas afectadas; el perfil activo no se puede borrar.

### 9.9 Selección de slot (P9)
- **Auto-selección:** al abrir, foco en el último slot usado del perfil.
- **Slots sin save:** grises (50% de opacidad) y no enfocables con A; muestran "Vacío".
- **Orden estable:** posiciones fijas (slot 1..N); nunca se reordenan al jugar.

### 9.10 Pausa (P10)
- **Inmunidad de gameplay:** mientras P10 esté abierta, los inputs de gameplay (mover,
  atacar, interactuar, inventario rápido) están bloqueados en la capa de input del mundo;
  solo pasan inputs de UI (§4). Al cerrar, se restauran.

### 9.11 Mapa (P12)
- **Viaje rápido:** nodo seleccionable → diálogo "¿Viajar a X?" → viaje (M28) con fade;
  cancelar cierra el diálogo sin mover.
- **Leyenda:** pie de mapa con los símbolos (nodo de viaje, sello, colección por zona,
  misiones) — legible con texto escalable (§5).

### 9.12 Colección (P14)
- **Contadores:** header "X/Y" por categoría y "Total X/Y" global (Header de plantilla §5).
- **Filtros:** chips Totales / Faltantes / Nuevos; el filtro es estado de vista (no de
  datos); "Nuevo" = descubierto desde la última vez que se abrió la pantalla.
- **Descubrimiento nuevo:** la ficha nueva muestra distintivo "Nuevo" hasta que se vuelva
  a abrir la pantalla.

### 9.13 Habilidades (P15)
- **Desbloqueo:** cada nodo muestra coste (XP/viento disponible) y botón "Desbloquear"
  deshabilitado si no alcanza; llama a ProgressionManager (M71) — sin lógica en la View.
- **Nivel:** badge de nivel por habilidad (0 = bloqueada, 1..N = aprendida).

### 9.14 Relación (P16)
- **Avatar/retrato:** avatar de NPC con inicial o retrato si existe arte (M06); si no hay
  arte, iniciales sobre color de la paleta de la isla.

### 9.15 Configuración general (P17)
- **Sub-pantalla general:** Idioma (M87), Región (formato fecha/números), Unidad
  (métrico/imperial); todos con aplicación en vivo (§3.4).
- **Idioma en vivo (M87):** cambiar idioma re-etiquesta la UI visible al instante (sin
  reinicio) vía el sistema i18n; persiste en `settings.json`.
- **Hora:** formato 12/24 h con toggle; aplica al HUD y diario (M32/M74).

### 9.16 Controles (P18)
- **Lista remapeable:** acciones de la tabla InputMap del proyecto, agrupadas
  (movimiento/cámaras/UI/interacción); cada acción muestra teclas actualmente asignadas.
- **Captura:** al pulsar "Asignar", se entra en escucha (un input event) — tecla, eje o
  botón de gamepad — y se escribe; Esc cancela sin cambios.
- **Restablecer:** por acción o global; confirmación si hay cambios sin guardar.
- **Conflictos:** si la nueva asignación ya está en otra acción de la misma categoría,
  se marca en rojo con opción "Mover aquí" (libera la otra) o "Cancelar".
- **Compatibilidad:** el mismo foco/atajos (§4) funcionan con teclado y gamepad en toda la
  pantalla (M58).

### 9.17 Accesibilidad (P19)
- **Retraso de diálogos:** ajuste 0-5000 ms entre líneas de diálogo (aplica a M55/relación);
  0 = actual.

### 9.18 Audio (P20)
- **Slider con prueba:** cada slider (por bus) tiene ícono de oído que reproduce 2 s de
  muestra del bus; al arrastrar, preview corto (300 ms) para validar nivel.
- **Mono/estéreo:** toggle "Modo mono" (accesibilidad auditiva) que colapsa el panorama del
  bus Master; se aplica en vivo y persiste (M41).

### 9.19 Gráfica (P21)
- **Revertir en 10 s:** al aplicar resolución/calidad, diálogo "¿Mantener cambios?"
  con cuenta regresiva de 10 s; al vencer o al cancelar, revierte a la configuración
  anterior (guardada antes de aplicar).
- **VSync y límite de FPS:** toggles de VSync (on/off) y FPS cap (30/60/120/Sin límite)
  con aplicación inmediata vía rendering server; persisten en `settings.json` (§6).

### 9.20 Pantallas de contenido — detalles de presentación
- **Detalle de ítem (P11):** al seleccionar un ítem del grid se abre panel lateral con
  nombre, descripción, stack (n/max), categoría y lore opcional (M148); botones
  Usar/Equipar (con confirmación cuando destruye) siguiendo §3.5.
- **Diario (P13):** pestaña Misiones lista las activas con objetivo actual y estado
  (en curso / lista); la pestaña Lore muestra contador por isla (X/Y, Header §5) y abre
  la entrada de M148; Estación muestra clima y estación actuales (M32/M74) con icono.
