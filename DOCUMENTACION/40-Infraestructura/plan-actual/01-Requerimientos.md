**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 40: Infraestructura

## ID del Módulo
- **Código:** M40 (CHECKLIST-GLOBAL: ID 40 — Infraestructura)
- **Carpeta:** `DOCUMENTACION/40-Infraestructura/`
- **Dependencias:** M38 (Economía — ya documentado; sus autoloads se registran en esta infraestructura)
- **Bases conceptuales:** M07 (Arquitectura General — Service Locator, GameState, EventBus, Bootstrap)
- **Integraciones:** M53 (UI-UX), M63 (Cargas y Streaming)
- **Delegable desde:** hoy (diseño completo; la implementación requiere confirmar los nombres reales de autoloads de M38 y la estructura final del proyecto Godot)

## 1. Problema

El proyecto Isla Ancestral (Godot 4.x + Voxel Tools, GDScript) crece en módulos: economía (M38), inventario, crafting, clima, fauna, UI (M53), cargas y streaming (M63), decenas de sistemas que necesitan comunicarse y compartir estado. En Godot, los singletons se declaran como autoloads en `project.godot`, pero sin una infraestructura definida cada módulo termina creando sus propios accesos globales, duplicando estado, acoplándose por referencias directas y dependiendo del orden de inicialización del motor (que por defecto es frágil y poco evidente). Los síntomas conocidos en proyectos Godot sin infraestructura: escenas que consultan servicios antes de que existan, cargas circulares (A importa B y B importa A), arranques que fallan por orden de autoloads, y una capa de UI (M53) que termina conociendo la lógica interna de todo. El plan maestro (M07) ya definió la arquitectura de alto nivel: CORE (Bootstrap, EventBus, Logger, ErrorHandler, Settings, ThreadPool), dominios de gameplay (GameState, economía, inventario...), mundo voxel, IA y UI como consumidora por SPI. Falta el módulo que materialice esa arquitectura en el motor: la infraestructura técnica que garantiza un arranque determinista, un registro central de servicios, un bus de eventos común y un ciclo de vida de escenas y estados de juego controlado.

## 2. Objetivo

Definir la infraestructura técnica del juego: los autoloads CORE con su orden de carga explícito en `project.godot`, el Service Locator (ServiceRegistry, especificado por M07), el EventBus central con dominios tipados, el Bootstrap que orquesta el arranque, el GameState (M07) como dato puro de partida, las escenas raíz (boot → menú → mundo) con transiciones controladas por SceneManager (integrado con M63), y la máquina de estados de flujo que impide arranques a medio proceso. Todo respetando el principio de AGENTS.md: arquitectura por capas, servicios desacoplados de la UI, composición sobre herencia, comunicación por señales e interfaces.

## 3. Alcance

### 3.1 Dentro del alcance
- Autoloads CORE: listado definitivo, orden de carga con prioridad en `project.godot` y contrato de cada uno.
- `Bootstrap` (autoload): sanity check del arranque, carga de configuración general, registro de servicios de dominio (M38) en el ServiceRegistry y decisión de la escena inicial.
- `ServiceRegistry` (Service Locator de M07): registro por contrato (interfaz/diccionario tipado), consulta, listado y verificación de integridad.
- `EventBus` central: definición de dominios de eventos (borrador de M07 ampliado), emisión y suscripción tipada, sin acoplamiento emisor→receptor.
- `GameState` (M07): dato puro de partida con partición por dominios (meta, world, player, economy, calendar, discovery, story), carga/inicialización y exposición de solo lectura para servicios.
- Orden de inicialización determinista: prioridades documentadas y verificables en `project.godot`.
- Escenas raíz: `boot.tscn` (sanity + splash mínimo) → `main_menu.tscn` (M53) → `world.tscn` (M08/M63), orquestadas por `SceneManager` con progreso visual (AGENTS.md §8).
- `GameFlowManager` (máquina de estados de flujo): estados BOOT / MENU / CARGANDO / MUNDO / PAUSA / TRANSICION / ERROR y transiciones válidas.
- Diagnóstico: detección de dependencias circulares por scan estático de imports, verificación de autoloads faltantes y de escenas que acceden a servicios antes de su `_ready`.
- Manejo de errores de arranque: fallback a pantalla de error con reintento, sin cuelgues ni crashes crípticos.
- Integración con M38: los autoloads `EconomyManager`, `PriceManager`, `ShopManager` y `BarterSystem` se registran como servicios de dominio y se crean en el orden correcto.

### 3.2 Fuera del alcance
- La lógica interna de cada servicio de dominio (economía M38, inventario, etc.): solo se define el contrato de registro e integración.
- El diseño detallado del GameState (documento guía de M07; el detalle completo pertenece a M59/M60 según el plan maestro; aquí solo se define el contrato de uso infraestructural).
- La implementación del Logger (detalle en M103, Logging): aquí se fija solo su posición en el orden de carga.
- La UI de menú, HUD y paneles (M53): se define solo el contrato de consumo por ServiceRegistry y EventBus.
- El streaming de chunks del mundo voxel y los detalles de Cargas y Streaming (M63): aquí se consume su contrato vía SceneManager.
- La configuración del usuario (Settings, M90/M91): se carga durante el bootstrap, su detalle es de otros módulos.
- El sistema de persistencia en disco (M60/M62): GameState provee el dato; el guardado físico es responsabilidad de esos módulos.

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), GDScript tipado explícito, sin C#.
- **Mundo voxel:** la infraestructura no modifica el mundo; solo garantiza que los servicios existan antes de que VoxelWorld (M08) los necesite.
- **Desacoplamiento (AGENTS.md §9):** los autoloads CORE no referencian nodos de la capa de UI; la UI consume servicios únicamente por contrato (ServiceRegistry) y eventos (EventBus).
- **Composición sobre herencia:** los servicios exponen interfaces; la infraestructura registra contratos, no clases concretas acopladas.
- **Determinismo:** el orden de carga se declara explícitamente; ningún servicio depende de la suerte del orden interno del motor.
- **Sin red:** todo es local; la infraestructura no tiene dependencias de red ni servicios externos.
- **Data-driven:** la configuración que consume el bootstrap vive en recursos de proyecto (`.godot`/config), no hardcodeada en scripts.
- **Diagnóstico automático:** el estado de la infraestructura debe poder verificarse con un comando/script (editor y runtime), alineado con el QA cruzado y la sección 12 de AGENTS.md.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Autoloads CORE | `EventBus`, `Logger`, `GameState`, `ServiceRegistry`, `SceneManager`, `GameFlowManager` y `Bootstrap` declarados en `project.godot` con prioridad explícita y orden documentado |
| RF2 | Bootstrap último | `Bootstrap` se instancia al final del orden CORE; en su `_ready()` ejecuta sanity check, carga config, registra servicios de dominio y decide la escena inicial |
| RF3 | Service Locator | `ServiceRegistry.registrar(contrato_id, servicio)` / `obtener(contrato_id)`; registro por contrato (StringName tipado) y consulta sin referencias directas entre módulos |
| RF4 | EventBus central | Emisión y suscripción por dominios (`world`, `economy`, `inventory`, `npc`, `calendar`, `ui`, `infra`); sin que el emisor conozca receptores |
| RF5 | GameState accesible | Dato puro de partida con partición por dominios; exposición de solo lectura para servicios; inicialización y reinicio de partida |
| RF6 | Orden verificable | El orden de carga declarado se puede contrastar contra el orden real del motor (log de arranque DOM-INF-BOOT) |
| RF7 | Escenas raíz | `boot.tscn` → `main_menu.tscn` → `world.tscn`; transiciones solo vía SceneManager con progreso visual y UI deshabilitada durante la carga (AGENTS.md §8) |
| RF8 | Estados de flujo | Enum `ESTADO_BOOT`, `ESTADO_MENU`, `ESTADO_CARGANDO`, `ESTADO_MUNDO`, `ESTADO_PAUSA`, `ESTADO_TRANSICION`, `ESTADO_ERROR` |
| RF9 | Transiciones válidas | `GameFlowManager.cambiar_estado(estado)` valida la transición permitida; transiciones ilegales se loguean y rechazan |
| RF10 | Diagnóstico de circulares | Script estático que escanea imports de los scripts de `res://core/` y dominios y reporta dependencias circulares o violaciones de capas |
| RF11 | Diagnóstico de autoloads faltantes | Sanity check que verifica que todos los servicios referenciados por contrato existan antes de arrancar el juego |
| RF12 | Escena antes que servicio | Detección de accesos a servicios en `_ready()` de nodos antes de que el servicio esté disponible (registro con advertencia y fallback) |
| RF13 | Error de arranque | Si el bootstrap falla, se muestra pantalla de error con motivo y opción "reintentar"; nunca crash mudo ni loop de carga |
| RF14 | Registro de M38 | `EconomyManager`, `PriceManager`, `ShopManager` y `BarterSystem` (M38) se auto-registran en `ServiceRegistry` con sus contratos al iniciar |
| RF15 | Integración con M63 | `SceneManager` delega la carga pesada al contrato de M63 (progreso, streaming por isla); el menú y el mundo se cargan sin doble instanciación de autoloads |
| RF16 | Integración con M53 | La UI (M53) obtiene servicios por `ServiceRegistry.obtener()` y escucha eventos por `EventBus`; nunca por referencias directas a nodos de dominio |

## 6. Requisitos No Funcionales

- **Arquitectura por capas (AGENTS.md §9):** CORE → dominios → mundo → AI → UI; verificable por el script de diagnóstico (RF10).
- **Determinismo de arranque:** el mismo proyecto inicia siempre en el mismo orden; los logs de bootstrap permiten comparar arranques.
- **Rendimiento:** registro en O(1) (diccionarios); el EventBus no introduce trabajo por frame; las consultas al registry son lecturas de diccionario.
- **Tolerancia a fallos:** un servicio faltante produce error descriptivo con fallback, no excepción crítica descontrolada; el juego nunca queda en un estado indefinido.
- **Testabilidad:** los autoloads CORE son Nodes puros inyectables en Edit Mode Tests (M112) y Play Mode Tests sin escena de juego.
- **Desacoplamiento absoluto de UI:** ningún autoload CORE referencia nodos Canvas ni clases de M53.
- **Documentación viva:** `plan-actual/` debe reflejar cualquier cambio real en el orden de autoloads o contratos al implementar.
- **GDScript tipado explícito** compatible con Godot 4.x (>= 4.4.1); sin C#, sin plugins externos obligatorios.
- **Localización:** los textos de la pantalla de error y del splash de boot usan claves i18n (listo para M53/M58).
- **Sin red:** la infraestructura funciona 100% local, sin servicios remotos.

## 7. Criterios de Aceptación

1. Arranque en frío: el juego inicia boot → menú sin errores, en el orden de carga documentado y con log DOM-INF-BOOT que lo evidencia.
2. Los 4 autoloads de M38 aparecen registrados en el `ServiceRegistry` con sus contratos antes de que la UI del menú se enlace.
3. Una escena accede a un servicio de dominio por `ServiceRegistry.obtener()` sin referencia directa al nodo del servicio.
4. El diagnóstico estático reporta 0 dependencias circulares y 0 violaciones de capas en un árbol limpio.
5. Quitar un autoload de `project.godot` produce un error de diagnóstico claro (RF11), no un crash críptico ni un menú roto.
6. Iniciar "nueva partida" y "continuar" cumplen el flujo CARGANDO → MUNDO con progreso visual y sin duplicar servicios ni estado.
7. Un error simulado en el bootstrap (config corrupta) muestra la pantalla de error con reintento; el reintento recupera el flujo normal.
8. Durante cualquier transición boot→menú→mundo, la UI interactiva queda deshabilitada hasta que la carga termine (AGENTS.md §8).

## 8. Fuentes de Contexto (plan maestro)

- M07 define el CORE: Bootstrap (autoload 0), EventBus, Logger, ErrorHandler, Settings, ThreadPool; y el registro de servicios en `ServiceRegistry` por Bootstrap.
- M07 define GameState con partición por dominios y versionado/migración por dominio (detalle en M59/M60).
- M07 define las reglas anti-circulares: un script de dominio solo importa core, data y dominios inferiores; EventBus no importa dominios; GameState no importa servicios.
- M38 define los autoloads de economía que esta infraestructura debe registrar y ordenar.
- AGENTS.md §9 exige separación de responsabilidades: UI solo llama funciones expuestas por managers/servicios (singletons o service locators).