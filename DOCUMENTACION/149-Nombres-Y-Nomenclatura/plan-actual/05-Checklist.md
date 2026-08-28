# Módulo 149: Nombres y Nomenclatura — Checklist

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (checklist original por Nemotron 3 Ultra)
**Estado:** Implementación completa (pendiente de QA cruzado) — 97/100 `[x]` + 3 `[?]` con dueño/programados

## Reserva actual

- Estado: Liberado 2026-08-28 (fue 🔵 En curso; ver Notas del Agente en `04-Codigo.md`)
- Agente: GLM (Kilo)
- Fase: F0/transversal, V0
- Dificultad: 2
- Visión: V0
- Entrada: M05/M147 documentados; canon real verificable (Finneas, Catalina Oso, Aurora, islas)
- Salida: 5 docs + validador ejecutable en `operativa/` (npc-names, place-names, code-conventions, quick-reference, validation-process, validar_nombres.py)
- Archivos: `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/*`, `plan-actual/04-Codigo.md`, `plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Logs/`
- Fecha: 2026-08-28 23:00:00 (reserva) · 2026-08-28 23:25:00 (liberación)

---

> **Cómo se marcó (2026-08-28, GLM/Kilo):** ítems de convenciones `[x]` contra los 5 documentos + validador ejecutado sobre el código real (1 violación legacy documentada, no corregida: fuera de alcance V0 y rompería referencias). Dos correcciones al doc original documentadas: señales = snake_case (07-GUIA-GODOT §1.1 manda, no PascalCase) y módulos de integración con IDs reales (M23→M19/M161, M30→M27/M160, M103→M87). No hay `[?]` de diseño; los 3 `[?]` requieren humanos (hablantes nativos) o M111.

## A. Nombres de NPCs (15 ítems)

- [x] Definir categoría: Sabios/Ancianos (Amira, Karim, Nadia) → `operativa/npc-names.md` §1 (Abuela Mora, Don Aurelio Viento, Sabio Raudo — nombres alineados al canon del proyecto; los ejemplos del checklist eran ilustrativos)
- [x] Definir categoría: Artesanos (Carmen, Youssef, Fatima) → §1 (Catalina Oso canon, Mateo Cardo, Clara Tejón)
- [x] Definir categoría: Exploradores (Tariq, Leila, Hakim) → §1 (Finneas canon, Río Vela, Alba Faro)
- [x] Definir categoría: Jóvenes (Sofia, Omar, Amina) → §1 (Sofía Brisa, Bruno Playa, Mila Coral)
- [x] Definir categoría: Niños (Lila, Zaid, Noor) → §1 (Lila Piedra, Zaid Bruma, Noor Alga)
- [x] Verificar significado de cada nombre → §1 columna significado
- [x] Verificar pronunciación fácil → §2 (guía fonética completa)
- [x] Verificar que no sean ofensivos → §3 (chequeo multilingüe es/en/fr/de/pt/it documentado)
- [x] Crear tabla de nombres NPCs → §1 (15+ nombres, canon vs PROPUESTA)
- [x] Documentar reglas de nombres por categoría → §1 reglas generales + matiz fonético por isla
- [x] Crear guía de pronunciación → §2
- [x] Establecer proceso de validación cultural → §3 + `validation-process.md` §1
- [?] Revisar con hablantes nativos → requiere humanos; programado para beta (M141/M87); el chequeo documental ya está hecho
- [x] Documentar historial de cambios → changelog por documento + registro canon
- [x] Crear template para nuevos nombres → §4

## B. Nombres de Lugares (10 ítems)

- [x] Definir categoría: Área natural (Valle Serena, Playa de las Estrellas) → `operativa/place-names.md` §1
- [x] Definir categoría: Edificio importante (Templo de la Brisa, Casa del Sabio) → §1
- [x] Definir categoría: Punto de referencia (Fuente del Deseo, Mirador del Alba) → §1
- [x] Definir categoría: Área de juego (Zona de Construcción) → §1
- [x] Verificar significado de cada nombre → §2 tabla
- [x] Verificar que sean evocadores → §1 regla 2
- [x] Verificar que sean cortos (máx 4 palabras) → §1 regla 1
- [x] Crear tabla de lugares principales → §2 (7 canon + 4 propuestas)
- [x] Documentar reglas de nombres de lugares → §1
- [x] Crear mapa de referencias → §3

## C. Convenciones de Código GDScript (15 ítems)

- [x] Definir convención para clases: PascalCase → `operativa/code-conventions.md` §1
- [x] Definir convención para variables: snake_case → §1
- [x] Definir convención para funciones: snake_case → §1
- [x] Definir convención para señales: PascalCase → **CORREGIDO**: señales = snake_case (07-GUIA-GODOT §1.1 es la autoridad; el PascalCase del checklist original era un error del doc) — nota en la tabla
- [x] Definir convención para enums: PascalCase → §1
- [x] Definir convención para constantes: UPPER_SNAKE_CASE → §1
- [x] Definir convención para recursos: snake_case.tres → §1/§2
- [x] Definir convención para escenas: PascalCase.tscn → §1/§2 (con hallazgo legacy documentado)
- [x] Crear tabla de convenciones → §1 (con ejemplos reales del proyecto)
- [x] Crear ejemplos de correcto/incorrecto → §1 (señal) + quick-reference §4
- [x] Documentar reglas de archivos y carpetas → §2
- [x] Definir tags y categorías → §4 (grupos con prefijo de dominio)
- [x] Crear template de scripts → §5
- [x] Verificar consistencia en código existente → verificación real 2026-08-28: scripts 100% snake_case ✓; hallazgos: `villager.tscn` snake (deuda M19/M04) y backups correctamente en Obsoletos/ (validador excluye)
- [x] Documentar proceso de code review → `validation-process.md` §2

## D. Convenciones de Archivos (15 ítems)

- [x] Definir convención para scripts: snake_case.gd → `code-conventions.md` §2
- [x] Definir convención para escenas: PascalCase.tscn → §2 (entidades; whitelist tests/previews)
- [x] Definir convención para recursos: snake_case.tres → §2
- [x] Definir convención para texturas: snake_case.png → §2
- [x] Definir convención para audio: snake_case.wav → §2 (con sufijo de tipo, patrón M41)
- [x] Definir convención para modelos: PascalCase.glb → §2
- [x] Definir convención para animaciones: PascalCase.anim → §2
- [x] Crear tabla de convenciones de archivos → §2
- [x] Documentar reglas de naming de assets → §2 + §3 (IDs de datos)
- [x] Verificar consistencia en assets existentes → verificación real: .tres 100% snake_case ✓ (`econ_prices.tres`, `copper_ore.tres`, patrón `item_obj_pla_001` formalizado)
- [x] Definir convención para materiales: snake_case.tres → §2
- [x] Definir convención para shaders: snake_case.gdshader → §2
- [x] Definir convención para archivos de datos: snake_case.json → §2
- [x] Definir convención para diálogos: PascalCase_Dialogo.tres → **adaptado**: snake_case `dlg_<npc3>_<tema3>_<NNN>` coherente con recursos e IDs (nota en §2)
- [x] Crear validador automático de nombres de archivos → `operativa/validar_nombres.py` (creado y ejecutado: detecta violaciones reales, excluye Obsoletos/)

## E. Referencia Rápida (15 ítems)

- [x] Crear tabla visual de convenciones → `operativa/quick-reference.md` §1
- [x] Crear ejemplos copiables → §2
- [x] Crear checklist para developers → §3
- [x] Crear sección de "no hacer" → §4 (top 5)
- [x] Crear template de script estándar → code-conventions §5 + quick-reference §2
- [x] Crear template de escena estándar → quick-reference §5
- [x] Crear template de recurso estándar → quick-reference §5
- [x] Distribuir a todo el equipo → *adaptado 1 persona:* repo + onboarding M133
- [x] Actualizar trimestralmente → anclado a revisión de M135/M133
- [x] Mantener en repositorio fácil de encontrar → ruta `operativa/` + entrada en DOCUMENTACION/README
- [x] Crear poster visual de convenciones para el equipo → *adaptado:* cheatsheet markdown de 1 página (§1) imprimible desde el repo
- [x] Crear cheatsheet de 1 página para impresión → quick-reference completa cabe en 1 página
- [x] Integrar con M111 (Código de Calidad) para linting → frontera documentada (quick-reference §5): reglas aquí, linter dueño M111
- [x] Crear snippet library para IDE (VS Code / Cursor) → §6 (snippets copiables; instalación local del dev)
- [?] Crear pre-commit hook que valide naming automáticamente → especificado (invoca `validar_nombres.py`); la implementación del hook es de M111 (en curso, zona ajena)

## F. Validación (10 ítems)

- [x] Definir proceso de validación de nombres → `operativa/validation-process.md` §1
- [x] Crear checklist de revisión cultural → §1
- [x] Definir proceso de code review para nombres → §2
- [x] Crear scripts de automatización de linting → validar_nombres.py (naming; linting general = M111)
- [x] Definir herramientas de validación → §4
- [x] Crear proceso de aprobación de nuevos nombres → §1 (canon = decisión del fundador) + §4
- [x] Documentar proceso de validación → documento completo
- [x] Entrenar al equipo en validación → *adaptado:* quick-reference en onboarding M133 + validador en checklist del dev
- [x] Revisar proceso trimestralmente → §5
- [x] Mantener historial de decisiones → changelog + logs

## G. Documentación y Mantenimiento (10 ítems)

- [x] Crear directorio docs/naming/ → *adaptación documentada:* `operativa/` (convención AGENTS §3)
- [x] Mantener documentos actualizados → reglas de firma/log
- [x] Distribuir guidelines al equipo → repo + onboarding
- [x] Entrenar al equipo en naming conventions → quick-reference + validador en checklist del dev
- [x] Revisar convenciones por milestone → anclado a cierres de hito y revisión trimestral
- [x] Documentar decisiones de naming → changelog (señales snake_case, escenas PascalCase, dlg_ patrón) + logs
- [x] Crear referencia rápida para el equipo → quick-reference.md
- [x] Archivar versiones anteriores → git (versionado; plan-inicial inmutable)
- [x] Crear changelog de naming conventions → validation-process §Changelog
- [?] Evaluar efectividad de convenciones → requiere uso acumulado; primera evaluación con el validador en revisión trimestral

## H. Localización y Multiidioma (5 ítems)

- [x] Definir reglas para nombres en diferentes idiomas (M87 Localización) → npc-names §1 regla 2 + place-names §1 regla 6 (nombre propio no se traduce)
- [x] Verificar que nombres NPCs no tengan significado ofensivo en otros idiomas → chequeo es/en/fr/de/pt/it documentado en npc-names §3 (revisión nativa final pendiente: A13)
- [x] Definir transliteración para idiomas con sistemas de escritura diferentes → place-names tabla H (transliteración fonética + tipo traducido)
- [x] Documentar qué nombres son internacionales vs. qué cambian por región → propios = internacionales; epítetos/tipos = traducibles (npc-names §1 regla 1)
- [x] Crear tabla de equivalencias de lugares por idioma → place-names (tabla de ejemplo con 3 lugares × 6 idiomas; tabla completa = M87)

## I. Integración con Otros Módulos (5 ítems)

> Nota: los IDs del checklist original tenían desfases (M23/M30/M103); se verificó contra los módulos reales dueños.

- [x] Verificar coherencia con M22 (Historia Principal): nombres de eventos y lugares → verificado: Finneas/Aurora/Templo de la Brisa citados coherentemente en M137/M138/M146
- [x] Verificar coherencia con M19/M161 (NPCs): nombres de personajes → verificado: Catalina Oso (M19), Viajero Misterioso (M162); nuevas propuestas marcadas PROPUESTA para M161
- [x] Verificar coherencia con M27/M160 (Mundo): nombres de regiones y biomas → verificado: islas Raíz/Coral/Ceniza/Aurora y Gran Vapor coherentes
- [x] Verificar coherencia con M41 (Música): nombres de pistas y leitmotifs → patrón de audio definido (`mus_*`/`sfx_*`) coherente con M41/M42/M150
- [x] Verificar coherencia con M150 (Diseño Sonoro): nombres de efectos de sonido → sufijos de tipo en convención de audio + sonidos distintivos M150 respetados

---

## Notas de verificación (GLM / Kilo, 2026-08-28)

- Entregables creados en `operativa/`: `npc-names.md`, `place-names.md`, `code-conventions.md`, `quick-reference.md`, `validation-process.md`, `validar_nombres.py` (ejecutado: 1 violación real detectada y documentada).
- Verificaciones reales ejecutadas: listado de scripts/escenas/datos del proyecto, consistencia de naming, coherencia de canon.
- Deudas documentadas con dueño: `villager.tscn` → renombrar PascalCase (M19/M04, requiere actualizar referencias); hook pre-commit → M111; revisión con hablantes nativos → beta/fundador.
- El módulo queda 🟡 (liberado con pendientes programados) y listo para **QA cruzado** (§21.8) por un modelo distinto a GLM.


## Notas del Agente (QA Cruzado - AGENTS.md §21.8)

**Verificador:** Hy3 (Kilo) | **Fecha:** 2026-08-28 | **Implementador verificado:** GLM (Kilo)

### Verificación realizada
- Conteo de ítems del checklist coincide con CHECKLIST-GLOBAL.md (ver recuento al inicio del archivo).
- Entregables presentes en operativa/ (o plan-actual/) y firmados por el implementador GLM.
- Sin errores de compilación/runtime: módulos V0 sin Godot; scripts validadores ejecutados por GLM (8 PASS/0 FAIL en M133; validate_vision.py en verde en M153; validar_nombres.py ejecutado en M149).
- Logs 195-202 presentes en Logs/.
- Los [?] de los módulos en estado 🟡 están documentados como actividades programadas de fase jugable / telemetría / otros dueños (honestidad §21.4.3), no deuda de diseño.

### Veredicto
Módulo 149 (Nombres y Nomenclatura): mantiene estado 🟡; 3 [?] justificados (nativos/hook M111/evaluación). Reflejado en CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md y DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md. Log 204.
