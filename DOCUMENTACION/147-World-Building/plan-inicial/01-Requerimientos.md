**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 147: World Building

## ID del Módulo
- **Código:** M147 (CHECKLIST-GLOBAL: ID 147 — World Building; plan maestro: sección 146 "WORLD BUILDING")
- **Carpeta:** `DOCUMENTACION/147-World-Building/`
- **Dependencias:** M22 (Historia Principal). Relaciones: M23 (Historias Secundarias), M21 (Diálogos), M24 (Templos y Puzzles), M25 (Ruinas), M26 (Templo Subterráneo), M27 (Islas del Mundo), M148 (Lore Ambiental — pendiente), M149 (Nombres y Nomenclatura — pendiente), M150 (Diseño Sonoro Narrativo — pendiente), M146 (Diseño de Experiencia — pendiente), M152 (Principios Innegociables), M153 (Objetivo Final), M86 (IA Generativa), M59 (Guardado), M87 (Localización), M61 (Rendimiento)
- **Delegable desde:** M22 (historia principal), M153 (objetivo final), M152 (principios)

## 1. Problema

El GDD y la biblia narrativa ya existen (documentos del usuario), pero el mundo necesita ser **implementable y consistente**: historia de Aurora, de cada isla, de los Arquitectos del Alba, de los Primeros Jardineros, de la Resonancia, de Elysia, de los NPC (Finneas, Lía, Bruno, Nilo, Vera y otros), religiones, costumbres, arquitectura, símbolos, lenguaje antiguo, calendario antiguo, tecnología, economía antigua, mapas antiguos, catástrofes, migraciones y leyendas. Sin un sistema de World Building: las historias se contradicen entre módulos (M22 vs. M24 vs. M25), no hay documentos únicos de referencia, el lore no se puede verificar con scripts, y la generación procedural (M08) o los diálogos (M21) indefinidos rompen la inmersión. El objetivo es una **biblia de mundo técnica**: documentos canónicos por capa, trazabilidad historia→módulo, validación de consistencia y reglas de expansión para contenido futuro.

## 2. Objetivo

Crear el sistema de World Building del juego: una biblia de mundo versionada y validable que defina la historia de Aurora y cada isla, las civilizaciones antiguas (Arquitectos del Alba, Primeros Jardineros), la Resonancia (el fenómeno central), Elysia, los NPC principales (Finneas, Lía, Bruno, Nilo, Vera y el resto), religiones, costumbres, arquitectura, símbolos, lenguaje y calendario antiguos, tecnología, economía antigua, mapas antiguos, catástrofes, migraciones y leyendas — con cada pieza de lore traducible a datos (JSON) consumibles por diálogos (M21), ruinas (M25), templos (M24/26), islas (M27) y lore ambiental (M148).

## 3. Alcance

### 3.1 Dentro del alcance
- Biblia de mundo central (`world_bible/`) con documentos por capa histórica.
- Línea de tiempo canónica (calendario antiguo → presente).
- Historia de Aurora y de cada isla (M27).
- Civilizaciones: Arquitectos del Alba, Primeros Jardineros, Resonancia.
- Elysia: misterio central, capas de revelación (M153: Sellos/era del Alba).
- Biografías de NPC: Finneas, Lía, Bruno, Nilo, Vera y secundarios (M19).
- Religiones, costumbres, arquitectura, símbolos, lenguaje antiguo, calendario, tecnología y economía antiguas.
- Mapas antiguos, catástrofes, migraciones y leyendas.
- Datos consumibles: `world_data.json` (personajes, lugares, eventos, símbolos) + `validate_world.gd`.
- Reglas de consistencia y trazabilidad historia→módulo.
- Integración con M22 (historia principal) y M148 (lore ambiental, cuando exista).

### 3.2 Fuera del alcance
- La redacción final de diálogos en sí: M21 (aquí solo los hechos del mundo que el diálogo puede mencionar).
- La implementación de la historia principal: M22 (aquí solo el canon de fondo).
- El lore ambiental visual/sonoro en el mundo: M148/M150 (aquí solo las fuentes de datos).
- La nomenclatura de nombres: M149 (aquí solo los hechos; los nombres finales los define M149).
- La generación procedural del terreno: M08/M10 (aquí solo qué datos del mundo consume).

## 4. Restricciones

- **Consistencia total:** ninguna pieza de lore puede contradecir otra; `validate_world.gd` verifica referencias cruzadas.
- **Canon único:** la biblia es la única fuente de verdad; los módulos consumen los JSON, no reescriben lore en sus scripts.
- **Cozy (M152):** el misterio (Resonancia/Elysia) se presenta sin terror ni castigos; la revelación siempre es opcional a ritmo del jugador (M153).
- **Versionado:** la biblia está versionada (git) y cada cambio de canon se registra en `world_bible/CHANGELOG.md`.
- **Localizable (M87):** textos con ids i18n; la biblia fuente está en español.
- **Rendimiento:** los JSON se cargan una vez (autoload), sin I/O por frame.
- **Validable:** `validate_world.gd` sin errores en consola.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Biblia de mundo | Estructura `world_bible/` con documentos por capa (historia, civilizaciones, geografía, personajes, cultura, tecnología, calendario, eventos) |
| RF2 | Historia de Aurora | Origen, nombres previos, relación con los Arquitectos y los Jardineros |
| RF3 | Historia de cada isla | Origen y relación de cada isla (M27) con la historia global |
| RF4 | Arquitectos del Alba | Civilización que construyó templos (M24/M26), tecnología y desaparición |
| RF5 | Primeros Jardineros | Civilización vegetal/naturaleza; relación con la agricultura (M33) y los cultivos |
| RF6 | La Resonancia | Fenómeno central (mundo/cámara/sismos M09/M12), origen y reglas |
| RF7 | Elysia | Lugar/personaje/estado misterioso; capas de revelación (Sello del Alba, M153) |
| RF8 | Finneas | Biografía, rol en la historia y arco emocional (NPC M19) |
| RF9 | Lía | Biografía, rol y arco |
| RF10 | Bruno | Biografía, rol y arco |
| RF11 | Nilo | Biografía, rol y arco |
| RF12 | Vera | Biografía, rol y arco |
| RF13 | Otros NPC | Biografías de secundarios (M19) con nivel de detalle por importancia |
| RF14 | Religiones antiguas | Creencias, rituales y su estado tras la caída de las civilizaciones |
| RF15 | Costumbres | Tradiciones actuales de Aurora derivadas de la historia |
| RF16 | Arquitectura | Estilos de construcción que cuentan historia (representados en M17/M18) |
| RF17 | Símbolos | Sistema de símbolos de los Arquitectos/Jardineros (usados en puzzles M24 y lore M148) |
| RF18 | Lenguaje antiguo | Frases/glosario mínimos; restricción: no puede existir traducción directa completa (M148: pistas parciales) |
| RF19 | Calendario antiguo | Nombres de meses/estaciones y festivales (M29/M74) |
| RF20 | Tecnología antigua | Qué sabían y qué dejaron (herramientas M13, drones de los Arquitectos) |
| RF21 | Economía antigua | Cómo funcionaba el intercambio; moneda "AO" moderna como derivación |
| RF22 | Mapas antiguos | Mapas como coleccionable (M73) y pista de exploración (M54) |
| RF23 | Catástrofes | Eventos que explican ruinas (M25), el estado de Elysia y la migración |
| RF24 | Migraciones | Por qué existen las islas habitadas y los NPC actuales |
| RF25 | Leyendas | Narrativas populares (cuentos) que esconden verdad parcial (M148) |
| RF26 | Datos validables | `world_data.json` + `validate_world.gd` (referencias cruzadas, fechas, ids) |

## 6. Criterios de Aceptación (Verificables)

1. La biblia de mundo existe con TODOS los documentos RF1-RF25.
2. No hay contradicciones: el validador de consistencia (`validate_world.gd`) pasa sin errores.
3. Todo personaje, lugar y evento con id único; los módulos (M21, M25, M24, M26, M27) pueden referenciarlo.
4. Cada bloque de lore (RF2-RF25) está trazado a los módulos que lo consumen.
5. Las biografías de los 6 NPC principales (Finneas, Lía, Bruno, Nilo, Vera y Aurora) tienen arco y relación con la Resonancia.
6. El misterio de Elysia tiene capas de revelación alineadas con los Sellos (M153), sin spoilers tempranos en el juego.
7. La línea de tiempo canónica es coherente (fechas del calendario antiguo + actual).
8. Los refranes/leyendas (RF25) solo revelan verdad parcial (regla de misterio).
9. Todo texto de la biblia usa ids i18n preparados para localización (M87).
10. El log en `Logs/` está generado y firmado.