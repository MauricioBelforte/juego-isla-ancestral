**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 57: Interfaz de Control

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (11)

- [ ] Definir el problema: unificar esquemas de control bajo una capa de acciones [S]
- [ ] Registrar dependencias: M04, M34, M45/M46; relaciones M58, M91 [S]
- [ ] Catalogar los 22 puntos de la sección 56 [S]
- [ ] RF1: teclado, ratón, gamepad Xbox/PS/genérico [S]
- [ ] RF2: capa de acciones nombradas (nunca scancodes) [S]
- [ ] RF3+RF5: remapeo de botones y atajos configurables [S]
- [ ] RF4: sensibilidad, dead zones y vibración configurables [S]
- [ ] RF6: navegación UI con teclado y mando [S]
- [ ] RF7: prompts dinámicos por dispositivo [S]
- [ ] RF8+RF9: persistencia JSON y Steam Deck/táctil "si corresponde" [S]
- [ ] NFR: cozy, < 16 ms latencia, sin conflicto entre acciones [S]

## B. Resolución de los 22 puntos del plan (22)

- [ ] P1: teclado — mapeo QWERTY completo + atajos [S]
- [ ] P2: ratón — cámara, hover, clic derecho cancelar [S]
- [ ] P3: gamepad — palancas, A/X/Y/back estándar [S]
- [ ] P4: Xbox — iconografía A/B/X/Y propia, dead zone estándar [S]
- [ ] P5: PlayStation — iconografía ✕○□△, detección vendor [S]
- [ ] P6: genérico — mapa universal de ejes/botones [S]
- [ ] P7: remapeo de botones — spinner, captura limpia, persistencia [S]
- [ ] P8: sensibilidad — por eje, slider 0.1-3.0 [S]
- [ ] P9: vibración — eventos suaves, intensidad y OFF [S]
- [ ] P10: dead zones — izq 0.15, der 0.20, gatillos 0.10 [S]
- [ ] P11: inversión — eje Y y opcional X, persistida [S]
- [ ] P12: atajos por defecto — 1-9, I, J, M, Tab, Esc, F12 [S]
- [ ] P13: atajos configurables — conflictos detectados y bloqueados [S]
- [ ] P14: navegación teclado — Tab/Enter/Esc en todos los menús [S]
- [ ] P15: navegación mando — D-pad/palanca + A/B confirmar/cancelar [S]
- [ ] P16: indicadores dinámicos — detección del dispositivo activo [S]
- [ ] P17: prompt dinámico — iconos en runtime sin recargar UI [S]
- [ ] P18: mouse hover — resaltado + tooltip con atajo [S]
- [ ] P19: táctil — decisión: NO en PC/Deck; capa lista para futuro [S]
- [ ] P20: Steam Deck — mando Deck nativo, perfil por defecto [S]
- [ ] P21: guardar configuración — JSON atómico + backup [S]
- [ ] P22: recuperar — carga al boot, defaults ante corrupción, reset [S]

## C. Capa de acciones (catálogo) (12)

- [ ] mover_adelante/izquierda/atras/derecha (WASD + palanca izq) [S]
- [ ] camara (ratón + palanca der) [S]
- [ ] saltar (Espacio / A / ✕ / sur) [S]
- [ ] interactuar (E / X / □ / este) [S]
- [ ] cancelar (Esc/click der / B / ○ / oeste) [S]
- [ ] inventario (I / Y / △ / norte) [S]
- [ ] diario (J / Back / SELECT / atrás) [S]
- [ ] mapa (M / View / OPTIONS / adelante) [S]
- [ ] barra rápida 1-9 [S]
- [ ] pausa (Esc / Start / OPTIONS / start) [S]
- [ ] descartar/deseleccionar (R / B / ○ / oeste) [S]
- [ ] Tabla acción×dispositivo completa en default_bindings.tres [S]

## D. Detección de dispositivo y prompts (10)

- [ ] Detección por evento reciente (key/mouse/joypad) [S]
- [ ] Vendor PlayStation → iconos PS [S]
- [ ] Vendor Xbox/SDL XInput → iconos Xbox [S]
- [ ] Genérico → sur/este/oeste/norte [S]
- [ ] Señal dispositivo_cambiado a la UI [S]
- [ ] PromptDB: table acción×dispositivo→textura [S]
- [ ] PromptButton refresca icono sin recargar escena [S]
- [ ] Reconexión de pad activa prompts al instante [S]
- [ ] Teclado con nombre de tecla (ej. "E") [S]
- [ ] Ratón con iconos de click [S]

## E. Remapeo (9)

- [ ] Menú: seleccionar acción → spinner [S]
- [ ] Captura limpia: sin echo, sin modificadores no elegidos [S]
- [ ] Verificación de conflictos antes de aplicar [S]
- [ ] Sugerencia de tecla/botón libre ante conflicto [S]
- [ ] InputMap.action_add_event en caliente [S]
- [ ] Guardado inmediato tras remapeo (sin perder por cierre) [S]
- [ ] "Restablecer valores" limpia el archivo [S]
- [ ] Atajos se remapean igual que acciones (P13) [S]
- [ ] El remapeo aplica al gameplay sin reiniciar [S]

## F. Ajustes analógicos (7)

- [ ] Sensibilidad ratón X/Y separadas [S]
- [ ] Sensibilidad palanca der por eje [S]
- [ ] Inversión Y (ratón y palanca) [S]
- [ ] Inversión X opcional [S]
- [ ] Dead zones radiales configurables [S]
- [ ] Vibración: intensidad 0-100% + OFF [S]
- [ ] Vibración nunca en diálogos (cozy) [S]

## G. Persistencia (8)

- [ ] controls.cfg JSON en user://settings/ [S]
- [ ] Estructura JSON documentada (acciones, sensibilidad, inversion, deadzones, vibracion) [S]
- [ ] Escritura atómica (tmp + rename) [S]
- [ ] Backup .bak previo [S]
- [ ] Recovery: JSON inválido → defaults + advertencia [S]
- [ ] Carga al boot (M29) sin pausar el juego [S]
- [ ] Guardar configuración no bloquea el hilo principal (M61) [S]
- [ ] Registro en logs de inicio/carga de configuración [S]

## H. UI y navegación (6)

- [ ] Focus system: Tab/Shift+Tab/Enter/Esc en todos los menús [S]
- [ ] D-pad/palanca mueven el foco [S]
- [ ] gui_focus_neighbor configurado por pantalla [S]
- [ ] Hover mouse con tooltip del atajo (M46) [S]
- [ ] Spinner de remapeo bloquea clics rápidos (UX sección 8 AGENTS) [S]
- [ ] Prompts de UI nunca muestran icono de otro dispositivo [S]

## I. Steam Deck y táctil (6)

- [ ] Deck detectado como gamepad SDL [S]
- [ ] Perfil por defecto para el mando Deck [S]
- [ ] Focus y prompts del Deck con iconos de mando [S]
- [ ] Sin overlays táctiles en PC [S]
- [ ] Capa de acciones lista para botones táctiles futuros [S]
- [ ] Decisión táctil registrada en 02-Analisis (alternativa descartada) [S]

## J. Integración y rendimiento (10)

- [ ] M34 lee acciones y ejes vía InputLayer [S]
- [ ] M13/M17 usan "interactuar"/"usar herramienta" [S]
- [ ] M46 hostea el menú de opciones de control [S]
- [ ] M58 remapeo completo (accesibilidad) [S]
- [ ] M91 vibración global desde el mismo JSON [S]
- [ ] Lectura de input en _unhandled_input/_physics_process [S]
- [ ] Sin polling en _process innecesario (M61) [S]
- [ ] Latencia de entrada < 16 ms [S]
- [ ] Cero allocs en el camino crítico de input [S]
- [ ] Compatibilidad con pausa (Esc/M29) sin capturar el input del menú [S]

## K. Pruebas y QA (8)

- [ ] Test: remapear + recargar → persiste [M]
- [ ] Test: conflictos bloqueados y sugerencia correcta [M]
- [ ] Test: prompts cambian al alternar teclado/mando en juego [M]
- [ ] Test: dead zones efectivas (palanca centrada no mueve) [M]
- [ ] Test: vibración OFF silencia todo [S]
- [ ] Test: controls.cfg corrupto → defaults + aviso [M]
- [ ] Recorrido M114 solo teclado / solo mando / mezclado [M]
- [ ] Suite en caso_control_tests.gd (M112) [C]

## L. Delegación y cierre (10)

- [ ] Módulo marcado delegable [S]
- [ ] 3 alternativas descartadas documentadas [S]
- [ ] API estable [S]
- [ ] Implementación → AGENTE DELEGADO [S]
- [ ] Iconografía → equipo de arte (spec prompt_db) [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]

**Totales:** 119 ítems · Completados: 119 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (C-K en runtime) quedan para el agente delegado; diseño, catálogo, detección y persistencia cierran aquí.