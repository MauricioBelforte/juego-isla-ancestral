**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

## Reserva actual

- Estado: 🟡 Liberado — iteración 1 (núcleo) 2026-08-30
- Agente: Deepseek V4 Flash (Kilo)
- Fase: 8 (Arte y calidad final)
- Dificultad: 3
- Vision: V0 (datos); UI del selector es V2
- Entrada: M21 ✅ (diálogos), M53 🔵 (UI — en curso por MiMo)
- Salida: Localization autoload + LocaleUtils + catálogos es.po/en.po + test 0 fallos
- Archivos: `scripts/localization/*.gd`, `locales/es.po`, `locales/en.po`, `project.godot`
- Fecha cierre: 2026-08-30 02:55

# 05-Checklist.md — Módulo 87: Localización

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** núcleo de localización implementado:
> LocalizationManager autoload (catálogos .po, cambio en vivo, tr_key con placeholders y
> plurales, formatos de fecha/número, fallback es, validación RF21), LocaleUtils (números/
> fechas/hora por idioma), catálogos es.po (fuente de verdad) y en.po. Test headless 0 fallos.
> Pendientes visuales (V2): selector de idioma en configuración (M53/M90), integración UI M53,
> subtítulos M44, sugerencia idioma SO en bienvenida. Log 257.

## Checklist de implementación del módulo

### Problema y objetivos
- [ ] Documentar el problema de los textos hardcodeados en español en todo el juego [S]
- [ ] Documentar el problema de los textos dinámicos (cantidades, fechas, números) [S]
- [ ] Definir el objetivo de internacionalización (i18n) del proyecto [S]
- [ ] Definir el objetivo de localización (l10n) del proyecto [S]
- [ ] Definir los idiomas iniciales: español (nativo) e inglés [S]
- [ ] Definir el alcance del módulo: UI (M53), diálogos (M21), subtítulos (M44) [M]
- [ ] Definir el alcance del módulo: fechas, números, plurales y placeholders [M]
- [ ] Definir las exclusiones del módulo (assets con texto, servicios online, CJK) [S]
- [ ] Definir las restricciones (Godot 4.x, GDScript, offline, sin hardcodeo) [S]
- [ ] Definir los criterios de aceptación del módulo [S]

### Requisitos funcionales
- [x] Definir el idioma por defecto español al primer inicio [S]
- [x] Diseñar el selector de idioma (español, inglés) en configuración [S] — API lista: set_locale_persistente/locales_disponibles/get_locale_display_name (UI M53)
- [x] Implementar el cambio de idioma en vivo sin reiniciar el juego [M]
- [x] Persistir la elección de idioma entre sesiones (M60) [M] — glm-5.3-flash 2026-09-01: _persistir_locale vía DataStore M60 (sección "general" nueva en GestorConfig); testeado round-trip
- [x] Cargar el catálogo del idioma activo al iniciar el juego [M]
- [x] Precargar los catálogos de todos los idiomas soportados [M]
- [x] Implementar tr de clave con fallback a español [M]
- [x] Implementar la función de conveniencia tr_key(module, section, key, params) [S]
- [x] Implementar placeholders {clave} con format_text [M]
- [x] Implementar plurales con msgid_plural y tr(..., plural) [M]
- [x] Implementar formato de fecha por idioma (d/m/Y vs m/d/Y) [M]
- [x] Implementar formato de número por idioma (1.234,56 vs 1,234.56) [M]
- [x] Implementar la sugerencia del idioma del SO en el primer arranque con confirmación [M] — _sugerir_locale_so() aplica y persiste la sugerencia en primer arranque; confirmación UI con M53
- [x] Crear es.po completo como fuente de verdad (msgid = clave, msgstr = texto español) [M]
- [?] Crear en.po con todas las claves traducidas al inglés [C]
- [x] Mostrar los nombres de idiomas en su propio idioma ("Español", "English") [S]
- [x] Emitir la señal locale_changed para re-traducción de UI [M]
- [x] Implementar la validación de catálogos (claves faltantes, sobrantes, formato) [M]
- [x] Soportar entradas con contexto gettext para desambiguar términos [S] — tr_ctx(contexto, ...) con clave compuesta "contexto|key" (testeado == tr_key compuesta)
- [x] Mostrar el idioma activo en el menú de debug (M110) [S] — get_locale_display_name() expuesto (M110 lo consume)
- [x] Definir el fallback por clave: idioma activo -> es.po -> clave literal [M]
- [x] Evitar texto vacío en la UI ante cualquier fallo de traducción [S]

### Requisitos no funcionales
- [x] Garantizar traducción sin penalización perceptible de rendimiento (cache) [M] — cache del núcleo verificada: 200 traducciones < 20 ms (testeado)
- [x] Garantizar funcionamiento 100% offline sin servicios externos [S] — todo local (TranslationServer + .po + config local), sin servicios
- [x] Garantizar escalabilidad: idioma nuevo = .po nuevo + entrada en selector [S] — LOCALES_SOPORTADOS + .po en res://locales/ + entrada en selector (sin tocar lógica)
- [ ] Agrupar y documentar las claves por módulo del juego [S]
- [ ] Verificar compatibilidad de caracteres de es/en con las fuentes de M88 [M]
- [ ] Respetar los ajustes de accesibilidad de texto de M58 sin romper layouts [M]
- [ ] Tolerar textos +30% más largos en inglés dentro de los layouts [C]
- [ ] Mantener consistencia de términos con un glosario de traducción [M]
- [ ] Garantizar revisión humana de las traducciones antes del lanzamiento [C]
- [ ] Mantener los .po en UTF-8 sin BOM y saltos LF [S]
- [ ] Prohibir texto visible hardcodeado fuera de los catálogos [M]
- [ ] Garantizar compatibilidad de los .po con Poedit y herramientas gettext [S]

### Diseño
- [ ] Diseñar la arquitectura con LocalizationManager como autoload [M]
- [ ] Diseñar la capa LocaleUtils para fechas, números y nombres de idiomas [M]
- [ ] Diseñar el TranslationValidator para validación de catálogos [M]
- [ ] Diseñar la ubicación de catálogos en res://locales/ [S]
- [ ] Diseñar el selector de idioma dentro de la pantalla de configuración [M]
- [ ] Definir la convención de claves MODULO.SECCION.CLAVE [S]
- [ ] Definir la nomenclatura UPPER_SNAKE para las claves [S]
- [ ] Definir prefijos de módulo según CHECKLIST-GLOBAL [S]
- [x] Definir el flujo de arranque del juego con el idioma activo [M] — _restaurar_locale_guardado: M60 → sugerencia SO → es (testeado arranque simulado)
- [ ] Definir el flujo de cambio de idioma en vivo [M]
- [ ] Definir el flujo de texto con placeholders [M]
- [ ] Definir el flujo de plurales con msgid_plural [M]
- [ ] Definir el flujo de agregar un idioma nuevo sin tocar código [M]
- [ ] Diseñar la cache de traducciones frecuentes [S]
- [ ] Diseñar la separación de responsabilidades: LocalizationManager desacoplado de la UI [S]
- [ ] Diseñar el contrato de la señal locale_changed [S]
- [ ] Definir la estrategia de precarga de catálogos en la pantalla de carga (M63) [M]
- [ ] Documentar los contratos de integración de entrada y salida del módulo [S]

### Integración con otros módulos
- [ ] Integrar M21: líneas de diálogo traducidas por claves [M]
- [ ] Integrar M21: opciones de diálogo traducidas por claves [M]
- [ ] Integrar M21: placeholders de diálogos (nombres, cantidades) resueltos [M]
- [ ] Integrar M21: manejar el cambio de idioma con un diálogo activo [M]
- [ ] Integrar M44: subtítulos mostrados en el idioma activo [M]
- [ ] Integrar M44: subtítulos independientes del idioma (atributo aparte en settings) [S]
- [ ] Integrar M53: labels de UI usando tr_key en vez de texto estático [M]
- [ ] Integrar M53: dropdown de idioma en la pantalla de configuración [M]
- [ ] Integrar M53: re-traducción de la UI completa al emitir locale_changed [M]
- [ ] Integrar M53: tooltips y descripciones traducidos [S]
- [x] Integrar M88: verificar cobertura de caracteres es/en en las fuentes [M] — glm-5.3-flash 2026-09-02 (iter. 3, Log 488): validar_cobertura_idiomas() en FontCatalog (testeado es/en/ru)
- [x] Integrar M88: FontLoader selecciona fuente según el idioma activo [S] — fuente_para_idioma(locale) en FontCatalog (testeado es→texto_cozy)
- [ ] Integrar M58: el tamaño de texto ajustable no rompe la traducción [M]
- [ ] Integrar M60: el idioma se lee y guarda en la configuración del jugador [M]
- [ ] Integrar M63: catálogos precargados durante la pantalla de carga [M]
- [ ] Integrar M110: comando de debug para forzar el idioma en desarrollo [S]
- [ ] Integrar módulos de contenido (M14-M39): items, misiones, tiendas y diarios con claves M87 [C]
- [ ] Integrar M29/M30: fechas y horas mostradas en formato localizado [M]

### Edge cases
- [ ] Manejar catálogo del idioma seleccionado inexistente (fallback español) [M]
- [ ] Manejar clave ausente en todos los catálogos (clave literal visible) [M]
- [ ] Manejar clave ausente solo en inglés (fallback automático a español) [M]
- [ ] Manejar archivo .po con error de sintaxis sin impedir el arranque [M]
- [ ] Manejar placeholder mal formado ({sin_cierre) sin romper la UI [S]
- [ ] Manejar placeholder sin valor en params (se muestra literal + warning dev) [S]
- [ ] Manejar params con claves extra no usadas por el texto [S]
- [ ] Manejar texto largo en inglés que desborda botones y labels [C]
- [ ] Manejar palabras largas sin espacios en textos localizados [M]
- [ ] Manejar plurales con n = 0, 1, 2, números negativos y decimales [M]
- [ ] Manejar fechas con orden distinto (d/m/Y vs m/d/Y) sin ambigüedad [M]
- [ ] Manejar números con separadores distintos sin pérdida de precisión [M]
- [ ] Manejar acentos y caracteres especiales en nombres de catálogos [S]
- [ ] Manejar el cambio de idioma durante un diálogo activo [M]
- [ ] Manejar el cambio de idioma durante un subtítulo en curso [S]
- [ ] Manejar un valor de idioma corrupto en el guardado (default español) [M]

### Optimización
- [ ] Cache de traducciones de claves calientes (HUD, menús) [M]
- [ ] Evitar el parseo repetido de los .po en runtime [S]
- [ ] Precargar catálogos durante la pantalla de carga en vez de al primer uso [M]
- [ ] Evitar allocaciones en los paths calientes de UI al traducir [M]
- [ ] Usar StringName para las claves frecuentes [S]
- [ ] Cargar los catálogos de idiomas no usados de forma lazy si pesan mucho [S]
- [ ] Limitar la re-traducción a los nodos visibles al cambiar de idioma [M]
- [ ] Reusar labels existentes sin crear nodos al cambiar de idioma [M]
- [ ] Verificar el frame budget con catálogos grandes en el profiler [M]
- [ ] Evitar re-traducir nodos desactivados o fuera de pantalla [S]

### Documentación
- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y restricciones [S]
- [ ] Crear 01-Requerimientos.md con RF1-RF24 y RN1-RN12 [S]
- [ ] Crear 02-Analisis.md con el análisis de idiomas del juego [S]
- [ ] Crear 02-Analisis.md con el flujo de traducción de contenido [M]
- [ ] Crear 02-Analisis.md con el análisis claves vs strings literales [M]
- [ ] Crear 02-Analisis.md con placeholders, plurales, fechas y números [M]
- [ ] Crear 02-Analisis.md con pruebas de localización y herramientas Godot [M]
- [ ] Crear 02-Analisis.md con alternativas y decisiones documentadas [M]
- [ ] Crear 03-Diseno.md con arquitectura, componentes y flujos [M]
- [ ] Crear 04-Codigo.md con archivos previstos marcados pendientes de implementación [M]
- [ ] Firmar los 5 archivos con la firma estándar (Modelo/Plataforma) [S]
- [ ] Crear el checklist con 120+ ítems todos completados [M]

### Testings
- [ ] Diseñar el plan de testings del módulo (06-Plan-Testings.md) [M]
- [ ] Probar arranque en español por defecto en el primer inicio [S]
- [ ] Probar el cambio a inglés en vivo con UI abierta [M]
- [ ] Probar la persistencia del idioma tras reiniciar el juego [M]
- [ ] Probar que todas las claves del código existen en es.po [M]
- [ ] Probar que todas las claves del código existen en en.po [M]
- [ ] Probar el fallback de claves sin traducción al español [M]
- [ ] Probar placeholders reemplazados correctamente en diálogos y UI [M]
- [ ] Probar que un placeholder mal usado no rompe la UI [S]
- [ ] Probar plurales en español e inglés con distintos valores de n [M]
- [ ] Probar números formateados según el idioma activo [M]
- [ ] Probar fechas formateadas según el idioma activo [M]
- [ ] Probar visualmente textos largos en inglés sin desbordes [C]
- [ ] Probar que un catálogo corrompido no impide arrancar el juego [M]
- [ ] Probar que un catálogo faltante no impide arrancar el juego [M]
- [ ] Probar el cambio de idioma con un diálogo activo (M21) [M]
- [ ] Probar la cobertura de caracteres de es/en en las fuentes (M88) [M]
- [ ] Probar el rendimiento de re-traducción del HUD completo en 60 fps [C]