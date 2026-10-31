# RIEL-V2 — QA VISUAL RUNTIME 2ª BATERÍA (módulos CORE no cubiertos en G1/V1; 20 items)

**Creado por:** GLM-5.3-Flash (28oct) | **Destino:** Nemotron-3.5-Super-VL — para su cron (continuación de V1/G1, sus nichos máximos)
**Reglas:** capturas NUEVAS en la carpeta de cada módulo (`tools/mcp/godot-mcp/capturas/<ID-Modulo>/`, nomenclatura `cap_<ID>_<fecha>_nemotron_<nota>.png`), output CORTO por ítem (anti-truncamiento), español/UTF-8, sin push/commits, hallazgos con L#.

| # | Módulo | Tarea (captura runtime + análisis visual + defectos con L#) | Estado |
|---|---|---|---|
| V2-001 | 22 Combate | Capturar el sistema de combate si alcanzable; describir mecanica visible, enemigos, HUD de combate; defectos | [ ] |
| V2-002 | 38 Tienda | Capturar la tienda/comercio si alcanzable (compra-venta); precios visibles, layout, consistencia | [ ] |
| V2-003 | 41 Musica | Estado de la música en runtime: ¿se percibe el cambio per-escenario? (captura + análisis del cambio si visible) | [ ] |
| V2-004 | 57 Controles UI | Capturar el panel de configuración de controles; mapeo visible, legibilidad | [ ] |
| V2-005 | 58 Accesibilidad | Capturar settings de accesibilidad si alcanzables; opciones visibles y legibles | [ ] |
| V2-006 | 46 Arte 2D | Capturar elementos 2D visibles (sprites, icons, UI art): coherencia de paleta con 3D | [ ] |
| V2-007 | 92 Tutorial | Si el tutorial es alcanzable: capturar sus mensajes y flujo inicial; legibilidad | [ ] |
| V2-008 | 97 Steam | Verificación visual de assets Steam citados (si existen en disco: captura de la ficha local/screenshot set) | [ ] |
| V2-009 | 99 Compras | Si el UI de compras (IAP) es alcanzable: capturarlo; precios/monedas legibles | [ ] |
| V2-010 | 85 Legal | Verificación visual de los avisos legales en pantalla inicial (términos/licencias si visibles) | [ ] |
| V2-011 | 15 Recursos | Capturar HUD de recursos en runtime (madera/piedra/etc.); iconos legibles, contadores coherentes | [ ] |
| V2-012 | 16 Crafting | Si el crafteo es alcanzable: capturar recetas visibles (vs recetas M16 flipadas el 28oct — spec → ¿visible?) | [ ] |
| V2-013 | 13 Herramientas | Capturar herramientas equipadas/usable; estados visual y coherencia con M13 | [ ] |
| V2-014 | 67 Vehiculos | Capturar vehículo en runtime (specs flipadas M67 del 26-28oct: LOD audio, presupuesto draw calls — spec → ¿visible?) | [ ] |
| V2-015 | 74 Festivales | Capturar festival/evento si alcanzable (I1-017: 15/15 eventos .tres — spec → ¿visible?) | [ ] |
| V2-016 | 33 Agricultura | Capturar los 6 flips del 28oct (P21 recetas, selector de semillas, cancelación, navegación M64, cosecha inventario lleno, borrado de parcela) — spec → ¿visible? | [ ] |
| V2-017 | 54 Mapa | Captura del mapa con niebla por zonas visitadas (T105-54: "más clara en visitadas") — spec → ¿visible? | [ ] |
| V2-018 | 50 Vegetación | Capturar vegetación SIN viento (confirmar el SKIP de viento_shader: no existe, sin animación visible) | [ ] |
| V2-019 | 11 Personaje | Capturar sin step-up/aire/stamina (confirmar los 3 "NO implementado" de T158 spec §1) | [ ] |
| V2-020 | 40 Infraestructura | Captura de estructuras tras los fixes recientes (si los hubo): estado visual y defectos residuales | [ ] |

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-28.
