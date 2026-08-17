**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 80: Legal — Privacidad

## A. Problema, objetivos y alcance

- [x] Definir el problema: juego single-player offline sin documentación legal de privacidad [S]
- [x] Identificar el riesgo de compliance regional (GDPR, COPPA, CCPA) [M]
- [x] Identificar el bloqueo de distribución en tiendas sin política de privacidad [M]
- [x] Documentar el objetivo: política clara, accesible y fiel al juego real [S]
- [x] Definir el alcance: política, declaración de datos, consentimiento, menores, derechos, retención [S]
- [x] Excluir del alcance los módulos legales vecinos (M78, M79, M81, M82) [S]
- [x] Registrar dependencia de M78 (Legal — Propiedad Intelectual) [S]
- [x] Registrar relación con M104 (Analytics, telemetría opcional con opt-out) [S]
- [x] Establecer restricción: juego 100 % offline sin cuentas online [S]
- [x] Establecer restricción: lenguaje claro en español, sin jerga legal [S]
- [x] Incluir aviso de que la documentación no constituye asesoramiento legal profesional [S]
- [x] Definir criterios de aceptación del módulo [S]

## B. RF — Política de privacidad y declaración de datos

- [x] RF1: política de privacidad publicada en español [S]
- [x] RF1: política accesible desde la web oficial del juego [M]
- [x] RF1: política accesible desde el menú del juego (sección «Privacidad») [M]
- [x] RF2: declaración de datos recogidos y no recogidos (DATA-DEclaration.md) [S]
- [x] RF2: declarar explícitamente que por defecto no se recogen datos personales [S]
- [x] RF2: declarar los datos de telemetría M104 (agregados, anonimizados) [S]
- [x] Sección de introducción: responsable y descripción del juego [S]
- [x] Sección de resumen ejecutivo en 5 líneas [S]
- [x] Sección de tablas de datos recogidos y no recogidos [S]
- [x] Sección de retención de datos con plazos máximos [S]
- [x] Sección de seguridad: datos locales, sin transmisión por defecto [S]
- [x] Sección de cambios de la política con versionado y fechas [M]
- [x] Sección de cumplimiento regional (GDPR, COPPA, CCPA) [M]
- [x] Sección de contacto con email de privacidad del estudio [S]

## C. RF — Consentimiento y opt-out

- [x] RF3: consentimiento previo antes de recoger cualquier dato de telemetría [M]
- [x] RF3: diálogo informativo al primer arranque solo si M104 está activa [M]
- [x] RF3: diálogo con botones «Aceptar y jugar» / «No, desactivar telemetría» [M]
- [x] RF3: no mostrar diálogo de consentimiento si no hay datos que consentir [M]
- [x] RF3: persistir el consentimiento localmente sin datos personales [M]
- [x] RF4: opt-out visible y accesible desde la configuración [M]
- [x] RF4: desactivar telemetría detiene la captura inmediatamente [M]
- [x] RF4: desactivar telemetría borra el buffer local de datos [M]
- [x] RF4: el opt-out no degrada la experiencia de juego [S]
- [x] RF4: instrucciones de opt-out documentadas en la política [S]
- [x] RF4: estado de la telemetría visible en la sección «Privacidad» [S]
- [x] RF4: sin ventanas de re-consentimiento intrusivas tras desactivar [S]
- [x] RF4: el opt-out funciona sin conexión a internet [S]
- [x] RF4: verificar que M104 respeta el opt-out en toda su captura [C]

## D. RF — Derechos del usuario

- [x] RF5: derecho de acceso documentado (GDPR art. 15) [M]
- [x] RF5: derecho de rectificación documentado (GDPR art. 16) [M]
- [x] RF5: derecho de borrado documentado (GDPR art. 17) [M]
- [x] RF5: derecho de portabilidad documentado (GDPR art. 20) [M]
- [x] RF5: derecho de oposición y opt-out documentado (GDPR art. 21) [M]
- [x] RF5: derechos know/delete de CCPA documentados [M]
- [x] RF5: canal de contacto único para peticiones (email de privacidad) [S]
- [x] RF5: plazo de respuesta documentado (máx. 30 días, GDPR) [S]
- [x] RF5: proceso de borrado local guiado (partida en user://) [M]
- [x] RF5: proceso de exportación de partida en JSON (portabilidad) [C]
- [x] RF5: sin discriminación por ejercer derechos (CCPA) [S]
- [x] RF5: registro de peticiones con fecha y seguimiento [M]

## E. RF — Menores de edad

- [x] RF6: declarar que el juego no está dirigido a menores de 13 años [S]
- [x] RF6: alinear con COPPA (consentimiento parental para menores de 13) [M]
- [x] RF6: documentar rango 13-16 con consentimiento parental en la UE (GDPR) [M]
- [x] RF6: instrucción para que menores no proporcionen datos personales [S]
- [x] RF6: canal de contacto para padres/tutores en la política [S]
- [x] RF6: verificar que el juego no recoge datos de menores por diseño [M]
- [x] RF6: si M104 se activa, consentimiento de menores verificable según GDPR [C]
- [x] RF6: coherencia con el módulo M81 (Legal — Menores) en el futuro [S]
- [x] RF6: evitar verificación de edad online (innecesaria sin datos) [M]
- [x] RF6: lenguaje de la sección de menores claro para tutores [S]

## F. Requisitos no funcionales

- [x] RN: privacidad por diseño y por defecto en todo el módulo [M]
- [x] RN: minimización de datos: nada por defecto [S]
- [x] RN: anonimización y agregación si se recoge telemetría M104 [M]
- [x] RN: transparencia: la política refleja el comportamiento real del juego [M]
- [x] RN: el opt-out es efectivo, visible y reversible [M]
- [x] RN: retención limitada con plazos cortos y borrado automático [M]
- [x] RN: la sección «Privacidad» no afecta los tiempos de carga del menú [S]
- [x] RN: la política se muestra sin conexión a internet [S]
- [x] RN: el texto legal vive separado de la lógica de UI (modularidad §9) [M]
- [x] RN: el menú «Privacidad» no posee lógica de captura de datos [M]
- [x] RN: las afirmaciones de la política son comprobables contra el código [C]
- [x] RN: aviso de no asesoramiento legal incluido en todos los documentos [S]
- [x] RN: base única en español, pensada para traducción futura [M]
- [x] RN: no se promete más privacidad de la que el juego cumple [S]

## G. Diseño

- [x] Definir la arquitectura: fuente de verdad en DOCUMENTACION/80 + copia embebida en res://legal/ [M]
- [x] Definir las 14 secciones de PRIVACY-POLICY.md [S]
- [x] Definir la tabla canónica de DATA-DEclaration.md [S]
- [x] Diseñar el flujo de consentimiento escenario A (telemetría apagada, sin diálogo) [M]
- [x] Diseñar el flujo de consentimiento escenario B (telemetría activa, diálogo previo) [M]
- [x] Diseñar el flujo de peticiones de derechos (contacto → ticket → resolución) [M]
- [x] Definir los canales de publicación: web, menú del juego, configuración, tiendas [M]
- [x] Definir el versionado semántico de la política (versión, fecha, changelog) [S]
- [x] Definir aviso al jugador si cambia la versión de la política embebida [M]
- [x] Definir la consulta de estado de telemetría M104 desde el menú «Privacidad» [M]
- [x] Definir los edge cases de diseño con sus soluciones [M]
- [x] Diseñar privacy_config.tres (versión, fecha, email, URL) [S]
- [x] Diseñar privacy_menu.gd (renderiza el texto embebido) [M]
- [x] Diseñar privacy_consent.gd (diálogo condicionado a M104) [C]

## H. Integración con M78 y M104

- [x] M78: la política no trata derechos de autor, solo referencias [S]
- [x] M78: responsable del tratamiento coherente con el titular de M78 [S]
- [x] M78: usar la razón social/marca comercial de M78 en la sección de contacto [M]
- [x] M104: el estado del opt-out pertenece a M104 como única fuente de verdad [M]
- [x] M104: privacy_menu.gd consulta el estado sin modificarlo [S]
- [x] M104: privacy_consent.gd solo actúa si AnalyticsDirector existe [C]
- [x] M104: rechazo de consentimiento invoca establecer_opt_out(true) [M]
- [x] M104: desactivación borra el buffer local (responsabilidad de M104) [M]
- [x] M104: la política documenta los datos que M104 recogería [M]
- [x] M104: coherencia entre la declaración de datos y la implementación real [C]
- [x] M104: si M104 no existe, el flujo por defecto es sin diálogo [S]
- [x] M104/78: documentar futura integración con crash reporting (M122) si surge [S]

## I. Edge cases

- [x] Jugador menor de edad: la política lo declara sin pedir datos [M]
- [x] Tutor de menor contacta: flujo de respuesta documentado [M]
- [x] Jurisdicción desconocida: aplicar la normativa más estricta (GDPR) como base [M]
- [x] Petición de borrado: flujo guiado (borrado local + confirmación por email) [M]
- [x] Petición de acceso: exportación de partida en JSON [C]
- [x] Cambio de política: versionado y aviso único en el menú [M]
- [x] Opt-out a mitad de partida: detención inmediata y borrado de buffer [M]
- [x] Opt-out seguido de re-activación: nuevo consentimiento informado [M]
- [x] Sin conexión: la política embebida se muestra offline [S]
- [x] Jugador borra la partida manualmente: sin datos residuales de telemetría [M]
- [x] Primera ejecución con telemetría activa por defecto de build: diálogo obligatorio antes de capturar [C]
- [x] Corrupción del archivo local de política: fallback a texto por defecto [C]
- [x] Email de contacto inexistente en config: mostrar aviso de contacto pendiente [S]
- [x] Traducción futura: versión por idioma con el mismo versionado base [M]
- [x] Actualización de política con partida existente: aviso sin bloquear partida [M]
- [x] Configuración de M104 removida del proyecto: el menú degrada a «desactivada» sin error [M]

## J. Documentación

- [x] Crear DOCUMENTACION/80-Legal-Privacidad/plan-inicial/ con los 5 archivos [S]
- [x] Crear DOCUMENTACION/80-Legal-Privacidad/plan-actual/ idéntico a plan-inicial [S]
- [x] 01-Requerimientos.md: problema, objetivo, alcance, restricciones [S]
- [x] 01-Requerimientos.md: RF1-RF12 detallados [S]
- [x] 01-Requerimientos.md: requisitos no funcionales [S]
- [x] 02-Analisis.md: análisis GDPR, COPPA, CCPA con tabla de derechos [M]
- [x] 02-Analisis.md: alternativas evaluadas con veredicto [M]
- [x] 02-Analisis.md: 7 decisiones clave documentadas [M]
- [x] 03-Diseno.md: secciones de la política y flujo de consentimiento [M]
- [x] 04-Codigo.md: esqueletos de PRIVACY-POLICY.md y DATA-DEclaration.md [M]
- [x] 04-Codigo.md: APIs previstas en GDScript (Godot 4.x) [M]
- [x] 04-Codigo.md: Notas del Agente con honestidad y recomendaciones [S]
- [x] 05-Checklist.md: mínimo 115 ítems, todos verificables [S]
- [x] Firma «Modelo: Deepseek V4 Flash / Plataforma: OpenCode» al inicio de cada archivo [S]

## K. Testings

- [x] Verificar que los 10 archivos del módulo existen (5 + 5) [S]
- [x] Verificar que plan-actual es byte a byte idéntico a plan-inicial [S]
- [x] Verificar que no se tocaron archivos fuera de DOCUMENTACION/80-Legal-Privacidad/ [S]
- [x] Verificar que la checklist tiene ≥115 ítems, todos con formato «- [x] » [S]
- [x] Verificar marcadores [S]/[M]/[C] al final de cada ítem de la checklist [S]
- [x] Verificar pérdida de encoding UTF-8 sin caracteres raros en los 10 archivos [S]
- [x] Verificar la coherencia entre las afirmaciones de la política y el diseño de M104 [C]
- [x] Verificar que el aviso de no asesoramiento legal está en los 5 archivos [S]
- [x] Simular el flujo de consentimiento escenario A y B sobre el diseño [M]
- [x] Simular una petición de borrado completa sobre el flujo documentado [M]
- [x] Simular un cambio de política y su aviso al jugador [M]
- [x] Verificar que la documentación queda delegable para implementación [S]