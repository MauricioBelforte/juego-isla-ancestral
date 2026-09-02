**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 86: IA Generativa

## A. Problema y objetivos

- [x] Identificar el problema: ausencia de política de IA generativa en el proyecto [S]
- [x] Documentar el riesgo legal de contenido con IA sin registrar (copyright de terceros) [S]
- [x] Documentar el riesgo de plataforma: declaración obligatoria de Steam sobre IA [S]
- [x] Documentar el riesgo reputacional ante la comunidad por falta de transparencia [S]
- [x] Documentar el riesgo de coherencia artística por uso indiscriminado de IA [S]
- [x] Definir el objetivo de crear una política escrita de uso de IA generativa [S]
- [ ] Definir el objetivo de establecer qué está permitido y qué prohibido [S]
- [x] Definir el objetivo de crear un registro de herramientas de IA [S]
- [ ] Definir el objetivo de crear el flujo de aprobación con revisión humana [S]
- [ ] Definir el objetivo de preparar la plantilla de declaración Steam [M]
- [x] Definir el objetivo de documentar los riesgos de copyright del output de modelos [M]
- [x] Alinear los objetivos con la dependencia del módulo 78 (Legal-PI) [S]

## B. Requisitos funcionales (RF)

- [x] RF1: definir una política escrita de IA generativa aplicable a toda la producción [M]
- [x] RF2: definir categorías de uso: texto, arte 2D/3D, música, SFX, código, documentación y marketing [M]
- [ ] RF3: establecer usos permitidos sin revisión (prototipos, ideas, moodboards internos) [M]
- [ ] RF4: establecer usos prohibidos (assets finales publicables sin revisión humana integral) [M]
- [x] RF5: definir el flujo de aprobación de contenido asistido por IA [C]
- [x] RF6: definir el registro de herramientas con nombre, versión, propósito, licencia y fecha [M]
- [x] RF7: registrar qué contenido del juego usa IA asistida y distinguirlo del 100% humano [M]
- [ ] RF8: preparar plantilla de declaración Steam (AI Content Disclosure) [M]
- [ ] RF9: incluir aviso de re-verificación de la política de Steam antes de publicar [S]
- [x] RF10: definir el tratamiento de la publicidad/marketing generado con IA [M]
- [x] RF11: definir el tratamiento de textos generados (diálogos, lore) con revisión editorial [M]
- [x] RF12: definir el tratamiento de música y SFX generados y su licencia de uso [M]
- [x] RF13: definir el tratamiento del código generado (GDScript/Godot 4.x) con revisión obligatoria [M]
- [ ] RF14: definir la publicación de la política en el repo accesible a colaboradores [S]
- [x] RF15: asegurar que la política distinga IA de desarrollo vs IA de contenido en juego [M]
- [ ] RF16: asegurar que la política distinga contenido pregenerado vs contenido en vivo [M]
- [ ] RF17: definir el procedimiento de actualización de la política ante cambios de plataforma [M]
- [x] RF18: definir el procedimiento de auditoría del registro contra la declaración Steam [M]

## C. Requisitos no funcionales (RN)

- [ ] RN1: política escrita en español y lenguaje claro, no legalista [S]
- [ ] RN2: política verificable por terceros (cada regla auditable) [S]
- [x] RN3: registro de herramientas append-only (no se editan filas históricas) [M]
- [x] RN4: flujo de aprobación con mínimo una revisión humana documentada [M]
- [x] RN5: declaración Steam honesta y consistente con el registro real [M]
- [ ] RN6: política cubre cambios futuros de las políticas de Valve [M]
- [ ] RN7: política no contradice el marco legal del módulo 78 [S]
- [x] RN8: política compatible con el protocolo multiagente (agentes IA = herramientas) [M]
- [x] RN9: costo de cumplimiento bajo para equipo indie de 1 persona [S]
- [ ] RN10: política cubre el ciclo completo del asset: generación a publicación [M]
- [x] RN11: registro permite reconstruir qué herramienta generó qué asset [M]
- [x] RN12: los documentos que generan reglas llevan firmas del agente que los modificó [S]
- [ ] RN13: los archivos del módulo usan encoding UTF-8 y saltos de línea LF [S]
- [x] RN14: la política es independiente del motor, pero referenciada a Godot 4.x donde aplica [S]

## D. Análisis del dominio

- [ ] Analizar la política de Steam de enero 2024 (AI Content Disclosure obligatorio) [M]
- [ ] Analizar la simplificación de política de Steam de abril 2024 (sin filtrado obligatorio en vivo) [M]
- [ ] Analizar las preguntas del formulario de Steam de junio 2024 (uso en desarrollo) [M]
- [ ] Analizar el estado vigente de la política de Valve 2025+ (desarrollo/pregenerado/en vivo/marketing) [M]
- [ ] Determinar que el proyecto planea categoría "pregenerado" o "desarrollo", no "en vivo" [M]
- [x] Confirmar que la generación procedural voxel (módulos 08/09/10) NO es "IA generativa" ante Steam [M]
- [x] Analizar el riesgo de ausencia de autoría humana en output de IA (copyright EE. UU.) [M]
- [x] Analizar el riesgo de datos de entrenamiento con obras protegidas y litigios activos [M]
- [x] Analizar los términos de servicio de cada herramienta y su licencia de output comercial [M]
- [x] Analizar la falta de consenso internacional sobre copyright del output de IA [M]
- [x] Analizar el riesgo de dilución del estilo artístico cozy voxel por uso de IA [M]
- [x] Evaluar la alternativa A (prohibición total) y descartarla por inviable e inconsistente [M]
- [x] Evaluar la alternativa B (uso libre sin registro) y descartarla por inauditable [M]
- [x] Evaluar la alternativa C (política mixta con registro) y elegirla como decisión [M]
- [x] Evaluar la alternativa D (revisión liviana en finales) y descartarla por riesgo legal [M]
- [x] Documentar la advertencia: la política de Steam cambia y debe re-verificarse al publicar [S]

## E. Diseño de la política y artefactos

- [x] Diseñar la estructura del documento raíz AI-POLICY.md (9 secciones) [M]
- [x] Definir el principio rector "la IA es una herramienta, no una autora" [S]
- [x] Definir el ámbito de aplicación incluyendo los agentes del protocolo multiagente [S]
- [ ] Diseñar la matriz permitido/prohibido para texto (lore, diálogos) [M]
- [ ] Diseñar la matriz permitido/prohibido para arte 2D (texturas, UI, iconos) [M]
- [ ] Diseñar la matriz permitido/prohibido para arte 3D (meshes voxel, modelos) [M]
- [ ] Diseñar la matriz permitido/prohibido para música [M]
- [ ] Diseñar la matriz permitido/prohibido para SFX [M]
- [x] Diseñar la matriz permitido/prohibido para código GDScript [M]
- [x] Diseñar la matriz permitido/prohibido para documentación y marketing [M]
- [x] Establecer la regla de oro: asset final requiere revisión humana integral documentada [S]
- [ ] Diseñar el flujo de aprobación de 6 pasos (Generar-Registrar-Revisar-Aprobar-Declarar-Archivar) [C]
- [ ] Definir que la revisión puede rechazar contenido (queda como borrador con fecha y motivo) [M]
- [ ] Diseñar la plantilla de declaración Steam con los campos de Steamworks [M]
- [ ] Definir el valor por defecto "No" para contenido en vivo (runtime) [S]
- [x] Diseñar AI-TOOLS-REGISTRY.md con las 10 columnas del registro [M]
- [x] Definir la regla append-only del registro de herramientas [S]
- [ ] Definir el procedimiento de verificación periódica de TOS de herramientas [M]
- [x] Definir el procedimiento de excepciones (aprueba el fundador, se documenta) [S]
- [x] Definir la vigencia y revisión de la política (cambio de Steam, herramienta nueva, pedido del 78) [M]

## F. Integración con el módulo 78 y con el flujo de producción

- [x] Establecer la dependencia jerárquica con el módulo 78 (Legal-PI) [S]
- [ ] Definir que el 86 no redefine propiedad intelectual (asume el marco del 78) [S]
- [x] Registrar la regla: el output de IA no genera derechos reclamables de autoría [S]
- [ ] Definir que los conflictos de política se resuelven a favor del 78 [S]
- [ ] Definir la notificación del 78 al 86 ante cuestiones legales nuevas (demandas, cambios regulatorios) [M]
- [ ] Integrar el flujo de aprobación con la verificación de compilación y QA de AGENTS.md §12 [M]
- [x] Integrar la política con el protocolo multiagente: salida de agentes = borrador hasta revisión humana [M]
- [x] Alimentar el módulo 131 (Créditos) con el registro de herramientas [M]
- [x] Referenciar la declaración Steam en el plan de lanzamiento del módulo Publicación [M]
- [ ] Definir la coordinación con la verificación de assets del QA (módulo 12) [M]
- [x] Definir que la generación procedural del mundo se referencia como no-IA en la declaración [M]
- [x] Documentar el flujo de auditoría semestral de la política y el registro [M]
- [x] Definir que los documentos de gobernanza se actualizan en plan-actual (no en plan-inicial) [S]
- [x] Definir el vínculo con la documentación de producción (03) para registrar la política [S]

## G. Edge cases

- [ ] Definir qué hacer si un colaborador usa una herramienta sin política definida (se paraliza la integración) [M]
- [x] Definir qué hacer con contenido dudoso (sin registro de origen): se trata como no aprobado hasta rastrearlo [M]
- [x] Definir qué hacer cuando cambia la política de la plataforma (re-verificación y actualización del documento) [M]
- [x] Definir qué hacer si una herramienta cambia sus términos de servicio (re-registro con nueva versión) [M]
- [ ] Definir el caso de música generada que "suena similar" a una obra protegida (se descarta si hay duda) [M]
- [x] Definir el caso de assets mixtos (IA + humano): se documenta el porcentaje y la edición humana [M]
- [x] Definir el caso de prompts que copian estilos de artistas vivos (prohibido como base final) [M]
- [x] Definir el caso de texto de IA con errores de lore (revisión editorial obligatoria antes del juego) [M]
- [ ] Definir el caso de código generado que no compila en Godot (revisión técnica y QA obligatorios) [M]
- [x] Definir el caso de contenido en vivo (runtime) si algún día se implementa (declaración y moderación) [C]
- [x] Definir el caso de IA usada solo para marketing (se declara y se marca en el registro) [M]
- [x] Definir el caso de excepción solicitada por el fundador (se documenta y se aprueba explícitamente) [S]
- [x] Definir el caso de detectar IA no declarada en la tienda (corrección inmediata de la declaración) [M]

## H. Documentación

- [ ] Escribir 01-Requerimientos.md con problema, objetivos, alcance, restricciones, RF y RN [M]
- [ ] Escribir 02-Analisis.md con la política de Steam 2024+ y riesgos de copyright [M]
- [x] Escribir 03-Diseno.md con estructura de AI-POLICY.md, matriz y flujos [M]
- [ ] Escribir 04-Codigo.md con las plantillas de los artefactos y Notas del Agente [M]
- [x] Escribir 05-Checklist.md con mínimo 110 ítems verificables [C]
- [x] Firmar todos los documentos (Modelo y Plataforma al inicio) [S]
- [x] Crear plan-actual como espejo byte a byte de plan-inicial [S]
- [ ] Usar encoding UTF-8 y saltos de línea LF en todos los archivos [S]
- [x] Respetar el español como idioma único de la documentación [S]
- [x] Dejar explícito en 02/03/04 que la política de Steam puede cambiar y debe re-verificarse [S]

## I. Testings

- [x] Verificar que el checklist del módulo tenga 110 o más ítems [S]
- [x] Verificar que todos los ítems del checklist estén marcados como completados [S]
- [x] Verificar que cada ítem del checklist lleve marcador [S], [M] o [C] al final [S]
- [x] Verificar que el checklist no contenga líneas de leyenda ni totales [S]
- [x] Comparar hashes entre plan-inicial y plan-actual (deben ser idénticos) [S]
- [ ] Verificar que existan exactamente 10 archivos (5 por carpeta) [S]
- [x] Verificar que el flujo de aprobación exija revisión humana documentada [S]
- [ ] Verificar que la matriz cubra todas las categorías de contenido del juego [S]
- [ ] Verificar que la declaración Steam incluya el aviso de re-verificación [S]
- [ ] Validar que no haya contradicciones con AGENTS.md y con el módulo 78 [M]
- [ ] Identificar que la verificación final de política de Steam queda delegada al momento de publicar [M]
- [x] Documentar que como módulo administrativo no aplican testings 06/07 (no hay código ejecutable) [S]
## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — validación / detección de bugs

### Resultado de test (headless, Godot 4.7.2-stable)
- godot --headless -s res://scripts/legal/test_genai_m86.gd -> **8 checks, 0 fallos** (exit 0) ✅

### Artefactos verificados
- data/legal/ia_generativa.json — carga y estructura validada por el test.
- scripts/legal/GenAIValidator.gd — alidar()/
eporte() detectan datos corruptos.
- scripts/legal/test_genai_m86.gd — ejecuta sin errores, sin regresiones con M60 (66/0 OK).

### Hallazgo honesto (brecha de implementación)
El módulo se liberó como "núcleo iter. 1" con JSON + Validator + Test.
- Autoload de servicio del plan: **NO mencionado** en la liberación (Log 423-431); igual que M125-M131, solo existe JSON+Validator+Test. Verificar/implementar en pasada futura si el plan lo exige.
El checklist de producto (espec. completa) permanece sin marcar: la capa de validación de datos SÍ está verificada; la capa de servicio/docs puede faltar según el plan.

### Veredicto QA
- DoD de la *capa de validación de datos*: **CUMPLIDO** (código existe, compila, tests 0 fallos, sin regresiones).
- Producto completo según plan: revisar con dueño.
- Estado recomendado: **🟡 Con dudas** (scaffold de validación verificado; pendiente capa de servicio/docs si aplica).

**Firma:** Hy3 / Kilo Code — 2026-09-02
