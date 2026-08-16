**Modelo:** Claude Opus 4.6 (Thinking)
**Plataforma:** Antigravity

# Log 02 — Adaptación del AGENTS.md a Unity/C#

**Fecha:** 2026-08-15 22:46:00
**Tipo:** Adaptación de protocolo

## Descripción

Se adaptó el archivo `AGENTS.md` de plantilla genérica a proyecto Unity (Isla Ancestral). La metodología documental, protocolo multiagente, logs, firma, checklist, QA cruzado y toda la estructura de documentación **permanecen intactos**. Solo se cambiaron las referencias tecnológicas.

## Cambios Realizados

### Sección 1 — Título
- **Original:** `Reglas Globales para la IA (Plantilla Genérica)`
- **Nuevo:** `Reglas Globales para la IA — Proyecto Unity (Isla Ancestral)`

### Sección 8 — Progreso Visual (UX)
- **Original:** Spinners, loaders, "Iniciando servidor...", operaciones de red genéricas
- **Nuevo:** Pantallas de carga, barras de progreso, "Cargando escena...", "Generando terreno...", carga de assets, generación procedural

### Sección 9 — Modularidad y Desacoplamiento
- **Original:** Frontend/UI genérico, capa de presentación/lógica/servicios
- **Nuevo:** MonoBehaviours de UI, managers/servicios (ScriptableObject-based, singletons, service locators), patrones MVC/MVP/ECS, interfaces (`IInteractable`, `IDamageable`), composición sobre herencia

### Sección 12 — Verificación Post-Tarea
- **Original:** `npm run dev`, `python manage.py runserver`, `cargo run`
- **Nuevo:** Compilación Unity (0 errors), verificación en Console, Play Mode, excepciones runtime (`NullReferenceException`, etc.), verificación multi-escena

### Sección 14 — Plan de Testings
- **Original:** Pruebas genéricas
- **Nuevo:** Unity Test Framework (Edit Mode Tests, Play Mode Tests), NUnit, Profiler, frame budget, memory leaks, draw calls

### Sección 15 — Modularización
- **Original:** Handlers genéricos
- **Nuevo:** Scripts/managers separados, utility classes, ScriptableObjects, interfaces compartidas, ejemplos de sistemas de juego (combate, movimiento, IA de NPCs)

### Sección 18 — Rotación de Logs
- **Original:** `console.log`, `logging`, `log4j`
- **Nuevo:** `Debug.Log()`, `Debug.LogWarning()`, `Debug.LogError()`, `Unity.Logging`, `Application.persistentDataPath`, nota sobre no crear logs dentro de `Assets/` (genera .meta)

### Sección 22 — Empaquetado y Distribución
- **Original:** Placeholder genérico con `bash` script
- **Nuevo:** Unity Build Pipeline completo: `BuildPipeline.BuildPlayer()`, plataformas objetivo (PC, consolas, mobile), `Development Build`, `Player Settings`, Addressables/AssetBundles, compresión de assets, `#if UNITY_EDITOR`

### Sección 23 — Nota de scripts
- **Original:** Scripts `.js` como alternativa
- **Nuevo:** Scripts Python por portabilidad, scripts Unity Editor en C# (`Assets/Editor/`), separación runtime/editor

### Sección 24 (NUEVA) — Stack Tecnológico del Proyecto
Se agregó sección completa con:
- Motor y lenguaje (Unity LTS, C# .NET Standard 2.1)
- Arquitectura de código (patrones, estructura de carpetas Unity completa)
- Herramientas de Unity (Input System, URP/HDRP, PhysX, UI Toolkit, AudioMixer, Test Framework, Profiler, Git)
- Convenciones de código C# (namespaces `IslaAncestral.*`, PascalCase, `[SerializeField]`, XML docs)

## Respaldo

Se guardó copia del archivo original en:
- `Obsoletos/2026-08-15_22-43-51_AGENTS.md`

## Archivos Modificados
- `AGENTS.md` (raíz del proyecto)

## Archivos Creados
- `Logs/ULTIMO_NUMERO.txt` (inicializado en 2)
- `Logs/02-ADAPTACION_AGENTS_UNITY_2026-08-15_22-46-00.md` (este archivo)
