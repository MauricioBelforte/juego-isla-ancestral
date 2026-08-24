**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 80: Legal — Privacidad

## A. Problema, objetivos y alcance

- [ ] Definir el problema: juego single-player offline sin documentación legal de privacidad [S]
- [ ] Identificar el riesgo de compliance regional (GDPR, COPPA, CCPA) [M]
- [ ] Identificar el bloqueo de distribución en tiendas sin política de privacidad [M]
- [ ] Documentar el objetivo: política clara, accesible y fiel al juego real [S]
- [ ] Definir el alcance: política, declaración de datos, consentimiento, menores, derechos, retención [S]
- [ ] Excluir del alcance los módulos legales vecinos (M78, M79, M81, M82) [S]
- [ ] Registrar dependencia de M78 (Legal — Propiedad Intelectual) [S]
- [ ] Registrar relación con M104 (Analytics, telemetría opcional con opt-out) [S]
- [ ] Establecer restricción: juego 100 % offline sin cuentas online [S]
- [ ] Establecer restricción: lenguaje claro en español, sin jerga legal [S]
- [ ] Incluir aviso de que la documentación no constituye asesoramiento legal profesional [S]
- [ ] Definir criterios de aceptación del módulo [S]

## B. RF — Política de privacidad y declaración de datos

- [ ] RF1: política de privacidad publicada en español [S]
- [ ] RF1: política accesible desde la web oficial del juego [M]
- [ ] RF1: política accesible desde el menú del juego (sección «Privacidad») [M]
- [ ] RF2: declaración de datos recogidos y no recogidos (DATA-DEclaration.md) [S]
- [ ] RF2: declarar explícitamente que por defecto no se recogen datos personales [S]
- [ ] RF2: declarar los datos de telemetría M104 (agregados, anonimizados) [S]
- [ ] Sección de introducción: responsable y descripción del juego [S]
- [ ] Sección de resumen ejecutivo en 5 líneas [S]
- [ ] Sección de tablas de datos recogidos y no recogidos [S]
- [ ] Sección de retención de datos con plazos máximos [S]
- [ ] Sección de seguridad: datos locales, sin transmisión por defecto [S]
- [ ] Sección de cambios de la política con versionado y fechas [M]
- [ ] Sección de cumplimiento regional (GDPR, COPPA, CCPA) [M]
- [ ] Sección de contacto con email de privacidad del estudio [S]

## C. RF — Consentimiento y opt-out

- [ ] RF3: consentimiento previo antes de recoger cualquier dato de telemetría [M]
- [ ] RF3: diálogo informativo al primer arranque solo si M104 está activa [M]
- [ ] RF3: diálogo con botones «Aceptar y jugar» / «No, desactivar telemetría» [M]
- [ ] RF3: no mostrar diálogo de consentimiento si no hay datos que consentir [M]
- [ ] RF3: persistir el consentimiento localmente sin datos personales [M]
- [ ] RF4: opt-out visible y accesible desde la configuración [M]
- [ ] RF4: desactivar telemetría detiene la captura inmediatamente [M]
- [ ] RF4: desactivar telemetría borra el buffer local de datos [M]
- [ ] RF4: el opt-out no degrada la experiencia de juego [S]
- [ ] RF4: instrucciones de opt-out documentadas en la política [S]
- [ ] RF4: estado de la telemetría visible en la sección «Privacidad» [S]
- [ ] RF4: sin ventanas de re-consentimiento intrusivas tras desactivar [S]
- [ ] RF4: el opt-out funciona sin conexión a internet [S]
- [ ] RF4: verificar que M104 respeta el opt-out en toda su captura [C]

## D. RF — Derechos del usuario

- [ ] RF5: derecho de acceso documentado (GDPR art. 15) [M]
- [ ] RF5: derecho de rectificación documentado (GDPR art. 16) [M]
- [ ] RF5: derecho de borrado documentado (GDPR art. 17) [M]
- [ ] RF5: derecho de portabilidad documentado (GDPR art. 20) [M]
- [ ] RF5: derecho de oposición y opt-out documentado (GDPR art. 21) [M]
- [ ] RF5: derechos know/delete de CCPA documentados [M]
- [ ] RF5: canal de contacto único para peticiones (email de privacidad) [S]
- [ ] RF5: plazo de respuesta documentado (máx. 30 días, GDPR) [S]
- [ ] RF5: proceso de borrado local guiado (partida en user://) [M]
- [ ] RF5: proceso de exportación de partida en JSON (portabilidad) [C]
- [ ] RF5: sin discriminación por ejercer derechos (CCPA) [S]
- [ ] RF5: registro de peticiones con fecha y seguimiento [M]

## E. RF — Menores de edad

- [ ] RF6: declarar que el juego no está dirigido a menores de 13 años [S]
- [ ] RF6: alinear con COPPA (consentimiento parental para menores de 13) [M]
- [ ] RF6: documentar rango 13-16 con consentimiento parental en la UE (GDPR) [M]
- [ ] RF6: instrucción para que menores no proporcionen datos personales [S]
- [ ] RF6: canal de contacto para padres/tutores en la política [S]
- [ ] RF6: verificar que el juego no recoge datos de menores por diseño [M]
- [ ] RF6: si M104 se activa, consentimiento de menores verificable según GDPR [C]
- [ ] RF6: coherencia con el módulo M81 (Legal — Menores) en el futuro [S]
- [ ] RF6: evitar verificación de edad online (innecesaria sin datos) [M]
- [ ] RF6: lenguaje de la sección de menores claro para tutores [S]

## F. Requisitos no funcionales

- [ ] RN: privacidad por diseño y por defecto en todo el módulo [M]
- [ ] RN: minimización de datos: nada por defecto [S]
- [ ] RN: anonimización y agregación si se recoge telemetría M104 [M]
- [ ] RN: transparencia: la política refleja el comportamiento real del juego [M]
- [ ] RN: el opt-out es efectivo, visible y reversible [M]
- [ ] RN: retención limitada con plazos cortos y borrado automático [M]
- [ ] RN: la sección «Privacidad» no afecta los tiempos de carga del menú [S]
- [ ] RN: la política se muestra sin conexión a internet [S]
- [ ] RN: el texto legal vive separado de la lógica de UI (modularidad §9) [M]
- [ ] RN: el menú «Privacidad» no posee lógica de captura de datos [M]
- [ ] RN: las afirmaciones de la política son comprobables contra el código [C]
- [ ] RN: aviso de no asesoramiento legal incluido en todos los documentos [S]
- [ ] RN: base única en español, pensada para traducción futura [M]
- [ ] RN: no se promete más privacidad de la que el juego cumple [S]

## G. Diseño

- [ ] Definir la arquitectura: fuente de verdad en DOCUMENTACION/80 + copia embebida en res://legal/ [M]
- [ ] Definir las 14 secciones de PRIVACY-POLICY.md [S]
- [ ] Definir la tabla canónica de DATA-DEclaration.md [S]
- [ ] Diseñar el flujo de consentimiento escenario A (telemetría apagada, sin diálogo) [M]
- [ ] Diseñar el flujo de consentimiento escenario B (telemetría activa, diálogo previo) [M]
- [ ] Diseñar el flujo de peticiones de derechos (contacto → ticket → resolución) [M]
- [ ] Definir los canales de publicación: web, menú del juego, configuración, tiendas [M]
- [ ] Definir el versionado semántico de la política (versión, fecha, changelog) [S]
- [ ] Definir aviso al jugador si cambia la versión de la política embebida [M]
- [ ] Definir la consulta de estado de telemetría M104 desde el menú «Privacidad» [M]
- [ ] Definir los edge cases de diseño con sus soluciones [M]
- [ ] Diseñar privacy_config.tres (versión, fecha, email, URL) [S]
- [ ] Diseñar privacy_menu.gd (renderiza el texto embebido) [M]
- [ ] Diseñar privacy_consent.gd (diálogo condicionado a M104) [C]

## H. Integración con M78 y M104

- [ ] M78: la política no trata derechos de autor, solo referencias [S]
- [ ] M78: responsable del tratamiento coherente con el titular de M78 [S]
- [ ] M78: usar la razón social/marca comercial de M78 en la sección de contacto [M]
- [ ] M104: el estado del opt-out pertenece a M104 como única fuente de verdad [M]
- [ ] M104: privacy_menu.gd consulta el estado sin modificarlo [S]
- [ ] M104: privacy_consent.gd solo actúa si AnalyticsDirector existe [C]
- [ ] M104: rechazo de consentimiento invoca establecer_opt_out(true) [M]
- [ ] M104: desactivación borra el buffer local (responsabilidad de M104) [M]
- [ ] M104: la política documenta los datos que M104 recogería [M]
- [ ] M104: coherencia entre la declaración de datos y la implementación real [C]
- [ ] M104: si M104 no existe, el flujo por defecto es sin diálogo [S]
- [ ] M104/78: documentar futura integración con crash reporting (M122) si surge [S]

## I. Edge cases

- [ ] Jugador menor de edad: la política lo declara sin pedir datos [M]
- [ ] Tutor de menor contacta: flujo de respuesta documentado [M]
- [ ] Jurisdicción desconocida: aplicar la normativa más estricta (GDPR) como base [M]
- [ ] Petición de borrado: flujo guiado (borrado local + confirmación por email) [M]
- [ ] Petición de acceso: exportación de partida en JSON [C]
- [ ] Cambio de política: versionado y aviso único en el menú [M]
- [ ] Opt-out a mitad de partida: detención inmediata y borrado de buffer [M]
- [ ] Opt-out seguido de re-activación: nuevo consentimiento informado [M]
- [ ] Sin conexión: la política embebida se muestra offline [S]
- [ ] Jugador borra la partida manualmente: sin datos residuales de telemetría [M]
- [ ] Primera ejecución con telemetría activa por defecto de build: diálogo obligatorio antes de capturar [C]
- [ ] Corrupción del archivo local de política: fallback a texto por defecto [C]
- [ ] Email de contacto inexistente en config: mostrar aviso de contacto pendiente [S]
- [ ] Traducción futura: versión por idioma con el mismo versionado base [M]
- [ ] Actualización de política con partida existente: aviso sin bloquear partida [M]
- [ ] Configuración de M104 removida del proyecto: el menú degrada a «desactivada» sin error [M]

## J. Documentación

- [ ] Crear DOCUMENTACION/80-Legal-Privacidad/plan-inicial/ con los 5 archivos [S]
- [ ] Crear DOCUMENTACION/80-Legal-Privacidad/plan-actual/ idéntico a plan-inicial [S]
- [ ] 01-Requerimientos.md: problema, objetivo, alcance, restricciones [S]
- [ ] 01-Requerimientos.md: RF1-RF12 detallados [S]
- [ ] 01-Requerimientos.md: requisitos no funcionales [S]
- [ ] 02-Analisis.md: análisis GDPR, COPPA, CCPA con tabla de derechos [M]
- [ ] 02-Analisis.md: alternativas evaluadas con veredicto [M]
- [ ] 02-Analisis.md: 7 decisiones clave documentadas [M]
- [ ] 03-Diseno.md: secciones de la política y flujo de consentimiento [M]
- [ ] 04-Codigo.md: esqueletos de PRIVACY-POLICY.md y DATA-DEclaration.md [M]
- [ ] 04-Codigo.md: APIs previstas en GDScript (Godot 4.x) [M]
- [ ] 04-Codigo.md: Notas del Agente con honestidad y recomendaciones [S]
- [ ] 05-Checklist.md: mínimo 115 ítems, todos verificables [S]
- [ ] Firma «Modelo: Deepseek V4 Flash / Plataforma: OpenCode» al inicio de cada archivo [S]

## K. Testings

- [ ] Verificar que los 10 archivos del módulo existen (5 + 5) [S]
- [ ] Verificar que plan-actual es byte a byte idéntico a plan-inicial [S]
- [ ] Verificar que no se tocaron archivos fuera de DOCUMENTACION/80-Legal-Privacidad/ [S]
- [ ] Verificar que la checklist tiene ≥115 ítems, todos con formato «- [ ] » [S]
- [ ] Verificar marcadores [S]/[M]/[C] al final de cada ítem de la checklist [S]
- [ ] Verificar pérdida de encoding UTF-8 sin caracteres raros en los 10 archivos [S]
- [ ] Verificar la coherencia entre las afirmaciones de la política y el diseño de M104 [C]
- [ ] Verificar que el aviso de no asesoramiento legal está en los 5 archivos [S]
- [ ] Simular el flujo de consentimiento escenario A y B sobre el diseño [M]
- [ ] Simular una petición de borrado completa sobre el flujo documentado [M]
- [ ] Simular un cambio de política y su aviso al jugador [M]
- [ ] Verificar que la documentación queda delegable para implementación [S]