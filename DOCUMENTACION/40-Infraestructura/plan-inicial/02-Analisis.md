**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 40: Infraestructura

## 1. Análisis del Dominio

La infraestructura del proyecto se descompone en siete dominios técnicos interconectados:

### 1.1 Autoloads vs inyección de dependencias
- **Dominio:** Godot 4.x no tiene inyección de dependencias nativa; el mecanismo oficial para singletons es el autoload declarado en `project.godot`.
- **Características:** cada autoload es un `Node` que el motor instancia al arrancar, en el orden de prioridad declarado, antes de la escena principal. El orden es determinista si se declara explícitamente; si no, es frágil e invisible.
- **Concepto clave:** los autoloads CORE son el "suelo" del juego. Todo lo demás (dominios, mundo, AI, UI) se construye sobre ellos y por ello deben cargar primero, con contratos claros y sin lógica de juego.

### 1.2 Service Locator (M07)
- **Dominio:** el plan maestro (M07) especifica un `ServiceRegistry` donde el Bootstrap registra los servicios por contrato. Es la materialización del patrón Service Locator en Godot: en lugar de 40 singletons sueltos referenciados por nombre global, los módulos piden servicios por una clave de contrato.
- **Beneficio clave:** desacoplamiento total entre consumidor y proveedor. Un módulo pide "servicio de economía" por `obtener(&"economia")` y no sabe (ni le importa) si detrás hay un autoload, un mock de test o un proxy de streaming.
- **Riesgo conocido del patrón:** el locator puede convertirse en un "acoplador universal" si los módulos abusan de él; se mitiga con contratos tipados, registro explícito en el arranque y diagnóstico que verifica que todo consumo tenga un registro previo.

### 1.3 EventBus
- **Dominio:** M07 define un EventBus central con dominios tipados (`world`, `economy`, `inventory`, `npc`, `calendar`, `travel`, `ui`). Reemplaza la telaraña de señales sueltas entre módulos por un bus con convención de nombres.
- **Características:** dominio + nombre de evento (`economy.currency_changed`); emisión sin conocer receptores; suscripción con filtro por dominio; desconexión segura al liberar nodos.
- **Concepto clave:** el EventBus no conoce la lógica de los dominios; solo define el espacio de nombres de eventos. Esto lo hace seguro de cargar primero y lo mantiene fuera de cualquier ciclo de dependencia.

### 1.4 Bootstrap
- **Dominio:** el punto de orquestación del arranque (M07 lo llama "autoload 0"). Su `_ready()` ejecuta, en orden: sanity check de servicios → carga de configuración general → inicialización de GameState (nueva partida o carga) → registro de servicios de dominio → diagnóstico → decisión de la escena inicial.
- **Característica crítica:** por diseño, el Bootstrap se instancia DESPUÉS de todos los demás autoloads CORE (último en el orden con la prioridad más baja), para que en su `_ready()` todos los servicios existan. La regla se documenta y se verifica en test (reordenar el registry rompe el test de arranque).
- **Concepto clave:** el arranque nunca es "a medias": o el juego llega a un estado estable (menú o mundo) o llega a la pantalla de error. No existe arranque flotante.

### 1.5 Orden de carga (project.godot)
- **Dominio:** Godot 4 declara cada autoload como `Nombre="Prioridad*res://ruta.gd"`. La prioridad define el orden de instanciación (mayor prioridad primero).
- **Regla de diseño:** el orden CORE es fijo y documentado (RF1): `EventBus` (sin dependencias) → `Logger` (contrato; detalle en M103) → `GameState` (dato puro) → `ServiceRegistry` (locator) → `SceneManager` (orquestador de escenas) → `GameFlowManager` (estados de flujo) → `Bootstrap` (orquestador final). Los autoloads de dominio (M38) se declaran después del CORE y antes del `Bootstrap`... **Decisión:** el registro de servicios de dominio NO depende del orden físico de sus autoloads: cada autoload de dominio se auto-registra en su `_ready()` y el Bootstrap solo verifica la integridad al final (RF11). Esto elimina la fragilidad del orden exacto entre servicios de dominio.
- **Concepto clave:** el orden importa solo dentro del CORE; entre servicios de dominio el contrato es "auto-registro + verificación final", no "orden físico mágico".

### 1.6 Escenas de arranque
- **Dominio:** tres escenas raíz: `boot.tscn` (sanity, splash mínimo, log de arranque), `main_menu.tscn` (M53) y `world.tscn` (mundo voxel, M08/M63).
- **Transiciones:** solo vía `SceneManager` (RF7), que delega la carga pesada a M63 y muestra progreso (AGENTS.md §8). La primera escena del proyecto es `boot.tscn`; el menú nunca carga mientras el bootstrap no confirme integridad.
- **Concepto clave:** separar el boot de la UI evita que un fallo de servicios rompa el menú; el boot es el "checklist de arranque" del juego.

### 1.7 Diagnóstico de dependencias circulares
- **Dominio:** en GDScript, las dependencias circulares entre scripts (`class_name`) son errores de parseo o comportamientos indefinidos difíciles de rastrear. Otro tipo de ciclo es el de runtime: A espera a B y B espera a A en `_ready()`.
- **Solución prevista (RF10):** script de diagnóstico estático que construye el grafo de imports de `res://core/` y de los dominios registrados, detecta ciclos y violaciones de capas (un dominio no puede importar UI, por ejemplo). Corre en editor como tool y en CI (M118); el QA cruzado lo usa como check objetivo.
- **Concepto clave:** la infraestructura define las capas (CORE → dominios → mundo → AI → UI) y el diagnóstico las hace cumplibles, automatizando la regla 1 de M07 ("un script de dominio X solo importa core, data y dominios de nivel inferior").

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Autoloads globales sin registro vs Service Locator (M07) | **Service Locator** | Sin registro, cada módulo referenciaría singletons por nombre global: acoplamiento oculto, imposible de mokear en tests y frágil ante renombrados. El locator centraliza y hace visible el catálogo de servicios |
| Inyección de dependencias manual (pasaje de referencias en constructores) | **Descartada como mecánica central** | Godot no la soporta nativamente; exigirla en cada nodo complica escenas y prefabs. Se adopta como práctica puntual en tests y en el Bootstrap, con el locator como mecanismo global |
| Un singleton global por módulo | **Descartado** | Duplica estado, crea 40 "Dioses" incontrolables y rompe la capa de testeo. El registro central + contrato es el patrón adoptado |
| Señales sueltas entre nodos vs EventBus central | **EventBus central** | El bus da nombres estables, evita cadenas de `get_node()` y permite respuestas de debug (espía de eventos). Las señales nativas se siguen usando dentro de cada módulo |
| Bootstrap como autoload de prioridad máxima (primero) | **Descartado** | Si Bootstrap arranca primero, en su `_ready()` los demás aún no existen. Se adopta: Bootstrap ÚLTIMO del CORE, con sanity check |
| Orden físico de autoloads de dominio como contrato | **Descartado** | Frágil ante renombrados y adiciones. Se adopta: auto-registro en `_ready()` + verificación de integridad al final |
| Escena única persistente vs multi-escena raíz | **Multi-escena (boot/menú/mundo)** | Requisito del mundo voxel por islas (M08/M63) y de la separación UI/juego; una escena única acoplaría la carga pesada al menú |
| Inicialización flotante (cada nodo inicializa en su `_ready`) vs máquina de estados de flujo | **Máquina de estados (GameFlowManager)** | El flujo explícito impide estados intermedios e ilegales; cualquier UI/pantalla sabe exactamente en qué estado está el juego |
| Diagnóstico solo en runtime | **Diagnóstico estático + runtime** | El scan estático detecta ciclos en editor y CI antes de entrar al juego; el sanity de runtime cubre lo que el estático no puede ver (autoload faltante en proyecto real) |
| Deps por plugin externo (Dependency Injection de terceros) | **Descartado** | Dependencia externa innecesaria para el tamaño del proyecto; el locator propio es suficiente y sin coste de mantenimiento |

## 3. Decisiones Clave

1. **D1 — Siete autoloads CORE con orden fijo:** `EventBus(1)`, `Logger(2)`, `GameState(3)`, `ServiceRegistry(4)`, `SceneManager(5)`, `GameFlowManager(6)`, `Bootstrap(7, último)`. Prioridad explícita en `project.godot`; ningún otro módulo agrega autoloads a este grupo.
2. **D2 — Bootstrap último y orquestador:** en su `_ready()`: sanity check → config → GameState (nueva/cargar) → registro/verificación de servicios → diagnóstico → escena inicial. Todo fallo deriva a `ESTADO_ERROR`.
3. **D3 — ServiceRegistry como Service Locator (M07):** contratos `StringName` (`&"economia"`, `&"mundo_voxel"`, ...), registro único por contrato (duplicado = error de diagnóstico), consulta O(1).
4. **D4 — Auto-registro de servicios de dominio:** cada autoload de dominio (M38: `EconomyManager`, `PriceManager`, `ShopManager`, `BarterSystem`) se registra en su `_ready()`; el Bootstrap solo verifica que todos los contratos esperados existan (RF11).
5. **D5 — EventBus con dominios tipados:** dominio + nombre (`economy.currency_changed`); el bus es `Node` sin importar dominios (regla anti-circular de M07). API: `emitir(dominio, evento, payload)`, `suscribir(dominio, evento, callable)`, `desuscribir(...)`.
6. **D6 — GameState como dato puro:** sin referencias a servicios; partición por dominios de M07; el infraestructura provee el acceso global y la inicialización; el guardado físico lo orquestan M60/M62.
7. **D7 — Escenas raíz: boot → menú → mundo:** `boot.tscn` siempre primera; las transiciones vibran solo por `SceneManager` con progreso (M63) y UI deshabilitada (AGENTS.md §8).
8. **D8 — GameFlowManager con transiciones válidas:** BOOT → MENU → CARGANDO → MUNDO ⇄ PAUSA; TRANSICION solo hacia CARGANDO; ERROR desde cualquier estado con reintento que vuelve a BOOT. Transición ilegal = warning + rechazo.
9. **D9 — Diagnóstico dual (estático + runtime):** script de editor para grafo de imports (ciclos y capas) y sanity check de runtime en Bootstrap (autoloads y contratos faltantes). Ambos con salida legible para el QA cruzado.
10. **D10 — Error de arranque con fallback:** `ESTADO_ERROR` con motivo, clave i18n y botón "reintentar" (vuelve a BOOT); prohibido crash mudo, loop de carga o menú a medio construir.

## 4. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Orden de `_ready` de autoloads distinto al esperado entre versiones de Godot | D1 (prioridades explícitas) + log DOM-INF-BOOT que registra el orden real + test de arranque que verifica el orden observado |
| Service Registry convertido en acoplador universal | Contratos tipados por dominio, registro único, diagnóstico que exige consumo con registro previo; los tests de arquitectura (M112) penalizan `obtener()` desde capas incorrectas |
| Grapa de eventos con sobrecarga | El bus no hace trabajo por frame; se limita a reenvío directo del Callable (delegado); eventos con payloads grandes se evitan por convención |
| Ciclos de carga entre GameState y servicios de dominio | GameState es dato puro (D6): no importa servicios; el diagnóstico estático lo garantiza (regla 3 de M07) |
| Escena que accede a servicio antes de tiempo | RF12: `ServiceRegistry` registra accesos tempranos y emite warning DOM-INF-ACCESO-TEMPRANO; el Bootstrap verifica al final y reporta |
| Error de arranque que deja el juego en estado fantasma | D10: todo fallo del bootstrap → `ESTADO_ERROR` con reintento; nunca se llega a un menú sin servicios |
| Renombrado de autoload roto silenciosamente | RF11 + test de integridad: el proyecto no arranca (o muestra error claro) si un contrato esperado falta |
| Duplicación de estado (dos instancias de un servicio) | Registro único por contrato en ServiceRegistry (D3) + verificación de instancias en el sanity check |
| UI acoplada por referencias directas | D5 + RF16: la UI solo usa `obtener()` y eventos; el script de capas del diagnóstico (D9) marca cualquier import de UI hacia lógica directa como violación |

## 5. Modelo Conceptual (entidades)

- `Bootstrap` (autoload `Node`): orquestador del arranque; sanity check, config, GameState, registro, diagnóstico, escena inicial.
- `ServiceRegistry` (autoload `Node`): mapa `contrato_id → servicio`; `registrar()`, `obtener()`, `esta_registrado()`, `listar_contratos()`, `verificar_integridad(esperados)`.
- `EventBus` (autoload `Node`): mapa `dominio → evento → Array[Callable]`; `emitir()`, `suscribir()`, `desuscribir()`; espía de eventos para debug.
- `GameState` (autoload `Node`): contenedor de datos de partida particionado (meta, world, player, economy, calendar, discovery, story); `inicializar_nueva()`, `cargar()`, `acceder(dominio)`, `guardar_snapshot()`.
- `SceneManager` (autoload `Node`): `cambiar_escena(ruta, modo)` con progreso (M63), `escena_actual()`, cola de transición y bloqueo de UI durante carga.
- `GameFlowManager` (autoload `Node`): máquina de estados `estado_actual`, `cambiar_estado(estado)`, `transiciones_permitidas` y señales de cambio de estado.
- `Logger` (autoload `Node`, contrato): interfaz de logging global; la implementación profunda es de M103 (rotación incluida).
- `Diagnostico` (helper `RefCounted`): scan estático de imports (editor/CI) y rutinas de sanity de runtime.
- `ContratoServicio` (constante de tipo `StringName`): claves estándar del registro (`&"economia"`, `&"inventario"`, `&"mundo_voxel"`, `&"clima"`, `&"ui"`...).

## 6. Relaciones con Otros Módulos

| Módulo | Relación |
|---|---|
| M07 (Arquitectura General) | Fuente de diseño: ServiceRegistry, GameState, EventBus y reglas anti-circulares; este módulo los materializa en autoloads Godot |
| M38 (Economía) | Provee 4 autoloads de dominio que se auto-registran en ServiceRegistry y cargan dentro del CORE; contrato `&"economia"` |
| M53 (UI-UX) | Consumidor de servicios por `obtener()` y de eventos por `EventBus`; el menú es escena raíz orquestada por SceneManager; la UI nunca inyecta lógica |
| M63 (Cargas y Streaming) | Provee el contrato de carga con progreso que SceneManager consume para boot → menú → mundo y el streaming por isla |
| M103 (Logging) | Logger CORE define el contrato y los log tags DOM-INF-*; la implementación con rotación es de M103 |
| M60/M62 (Datos y serialización / Memoria) | GameState provee el snapshot; M60/M62 orquestan el guardado físico y los límites de memoria |
| M112 (Testing Automático) | Los autoloads CORE son Nodes puros: testables en Edit Mode; la máquina de estados y el registry tienen tests unitarios |
| M118 (CI-CD) | El diagnóstico estático (D9) corre en CI como gate de calidad |
| M08 (Mundo Voxel) | El mundo se instancia dentro del flujo CARGANDO → MUNDO; recibe servicios ya verificados |

## 7. Conclusión del Análisis

La infraestructura del proyecto será un conjunto pequeño y estable de siete autoloads CORE con orden explícito, un Service Locator por contratos (M07), un EventBus de dominios tipados, un GameState de dato puro, un SceneManager que orquesta las escenas raíz con progreso (M63) y una máquina de estados de flujo que impide arranques a medias. Los servicios de dominio se auto-registran y el sistema se cierra con diagnóstico dual (estático y runtime) que hace verificables las capas y las dependencias circulares. El diseño queda listo para implementación en Godot 4.x con GDScript tipado, respetando AGENTS.md §9 (UI desacoplada por contrato) y §8 (progreso visual en cargas).