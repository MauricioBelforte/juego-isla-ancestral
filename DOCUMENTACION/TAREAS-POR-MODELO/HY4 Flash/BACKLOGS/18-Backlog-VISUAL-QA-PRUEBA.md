# 18-Backlog: VISUAL QA (PRUEBA - nicho nuevo)

> Creada por: agnes-3-flash - 2026-11-17 08:05
> **PRUEBA:** Si las 60 tareas se hacen bien, este nicho queda asignado permanentemente.
> Nicho: verificacion visual de capturas del juego.
> Cap: multimodal (puedes ver imagenes). 460 PNGs en 62 modulos.

## Metodo
- Leer la captura (es una imagen, usas vision)
- Verificar: 1) la escena se ve correcta, 2) no hay assets rotos/missing,
  3) no hay Z-fighting visible, 4) el terreno se ve, 5) no hay objetos flotando.
- Anotar: MODULO / CAPTURA / VEREDICTO (OK / PROBLEMA: descripcion) / EVIDENCIA (que ves)
- Si NO podes ver la imagen (error de MCP): marcar [?] con la razon.

## Criterio de calidad (lo que yo verifico)
- Maximo 20% de [?] por "no puedo ver" (deberias poder: es multimodal)
- Los PROBLEMA deben tener descripcion concreta (no "se ve raro")
- Si un modulo tiene 5/5 OK en 2 tandas seguidas = nicho aprobado

## Tareas

- [x] T18-01: 09-Terreno-Y-Geografia / anillo_arena_0.png - ver y verificar — PROBLEMA: pequeños triángulos verdes flotando sobre el terreno; HUD y reloj visibles
- [x] T18-02: 09-Terreno-Y-Geografia / anillo_arena_1.png - ver y verificar — PROBLEMA: triángulos verdes dispersos y objeto blanco diminuto en el cielo
- [x] T18-03: 09-Terreno-Y-Geografia / anillo_arena_2.png - ver y verificar — PROBLEMA: triángulos verdes sobre el terreno y punto en el cielo
- [x] T18-04: 09-Terreno-Y-Geografia / cap_09_2026-09-19_21-45-49_impostor_1300m.png - ver y verificar — PROBLEMA: captura recortada con el editor al fondo; zona blanca vacía y personaje en el borde
- [x] T18-05: 09-Terreno-Y-Geografia / cap_9_2026-09-06_19-19-20_isla_10x_interior.png - ver y verificar — PROBLEMA: solo splash de Godot; no se ve ninguna escena de juego
- [x] T18-06: 25-Ruinas / cap_21_2026-08-29_17-25-04_dialogo-catalina.png - ver y verificar — PROBLEMA: costuras negras profundas entre bloques de terreno;NPC representado como cápsula azul
- [x] T18-07: 25-Ruinas / cap_21_2026-08-29_17-29-01_dialogo-catalina2.png - ver y verificar — PROBLEMA: gran vacío blanco, franja marrón y plano azul recortado; cápsula azul
- [x] T18-08: 25-Ruinas / cap_21_2026-08-29_17-52-38_dialogo-fijado.png - ver y verificar — PROBLEMA: terreno ausente, todo azul plano; diálogo visible y objetos flotando
- [x] T18-09: 25-Ruinas / cap_21_2026-08-29_18-19-42_spawn-arena.png - ver y verificar — PROBLEMA: cápsula azul gigante ocupa el encuadre; no se ve terreno
- [x] T18-10: 25-Ruinas / cap_21_2026-08-29_18-25-35_catalina-junto-jugador.png - ver y verificar — PROBLEMA: solo cielo y franja marrón; sin escena
- [x] T18-11: 53-UI-UX / cap_53_2026-10-08_23-28-20_inventario_unificado_overlay.png - ver y verificar — PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)
- [x] T18-12: 53-UI-UX / cap_53_2026-10-08_23-37-29_inventario_unificado_overlay.png - ver y verificar — PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)
- [x] T18-13: 53-UI-UX / cap_53_2026-10-08_23-56-44_inventario_unificado_overlay.png - ver y verificar — PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)
- [x] T18-14: 53-UI-UX / cap_53_2026-10-09_00-08-13_inventario_unificado_overlay.png - ver y verificar — PROBLEMA: el reloj HUD tapa la cabecera del inventario (contador 0/24 y pestañas Ropa/Arte)
- [x] T18-15: 53-UI-UX / cap_53_2026-10-09_02-11-41_t3_bug126_hud_antes_de_h.png - ver y verificar — PROBLEMA: terreno blanco plano con manchas grises flotando
- [x] T18-16: 49-Iluminacion / cap_49_2026-09-06_07-24-15_atardecer_1800.png - ver y verificar — PROBLEMA: iluminación verde-amarilla uniforme, sin rasgo de atardecer; editor al fondo
- [x] T18-17: 49-Iluminacion / cap_49_2026-09-06_07-29-09_amanecer_0600_v2.png - ver y verificar — PROBLEMA: misma luz verde-amarilla que en atardecer; no se distingue el amanecer
- [x] T18-18: 49-Iluminacion / cap_49_2026-09-06_07-29-57_mediodia_1200.png - ver y verificar — PROBLEMA: captura completamente negra, sin escena
- [x] T18-19: 49-Iluminacion / cap_49_2026-09-06_07-31-35_amanecer_0600_v3.png - ver y verificar — PROBLEMA: misma luz que en atardecer; cápsula azul y animales sobre repisas
- [x] T18-20: 49-Iluminacion / cap_49_2026-09-06_07-31-50_mediodia_1200_v2.png - ver y verificar — PROBLEMA: misma luz, animal sobre repisa; sin diferencia de mediodía
- [x] T18-21: 51-Agua / cap_51_2026-09-06_16-23-25_agua_olas_v1.png - ver y verificar — PROBLEMA: no se ve agua, solo terreno tipo cantera
- [x] T18-22: 51-Agua / cap_51_2026-09-06_16-30-00_agua_costa_suroeste.png - ver y verificar — PROBLEMA: triángulos verdes flotando en la esquina inferior izquierda
- [x] T18-23: 51-Agua / cap_51_2026-09-06_16-30-00_agua_playa_sur.png - ver y verificar — PROBLEMA: triángulos verdes sobre el terreno; agua solo en franja lejana
- [x] T18-24: 51-Agua / cap_51_2026-09-06_17-42-50_olas_hasta_agua_clara.png - ver y verificar — OK: costa con agua clara y olas suaves, personaje y orilla visibles; sin artefactos evidentes
- [x] T18-25: 51-Agua / cap_51_2026-09-06_17-53-24_olas_cerca_premium.png - ver y verificar — OK: agua con olas y reflejos, orilla y sombra del personaje; sin artefactos evidentes
- [x] T18-26: 10-Generacion-Del-Mundo / cap_10_2026-09-02_23-49-00_chunks_384.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks
- [x] T18-27: 10-Generacion-Del-Mundo / cap_10_2026-09-02_23-50-00_chunks_384b.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks
- [x] T18-28: 10-Generacion-Del-Mundo / cap_10_2026-09-02_23-53-00_chunks_320.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks
- [x] T18-29: 10-Generacion-Del-Mundo / cap_10_2026-09-02_23-55-00_chunks_320b.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el editor; no se ven chunks
- [x] T18-30: 10-Generacion-Del-Mundo / cap_10_2026-09-03_05-26-00_chunks_512.png - ver y verificar — PROBLEMA: dos ventanas solapadas con splash; no se ve terreno
- [x] T18-31: 50-Vegetacion / cap_50_2026-09-02_05-51-00_vegetacion.png - ver y verificar — PROBLEMA: props de vegetación sobre fondo gris sin terreno; no se puede verificar ubicación
- [x] T18-32: 50-Vegetacion / cap_50_2026-09-02_23-25-00_poblada.png - ver y verificar — PROBLEMA: franja marrón uniforme en el horizonte y personaje como cápsula azul
- [x] T18-33: 50-Vegetacion / cap_50_2026-09-06_07-57-03_panoramica_inicial_escala.png - ver y verificar — PROBLEMA: captura negra con una franja del IDE
- [x] T18-34: 50-Vegetacion / cap_50_2026-10-19_05-07-30_poblado-runtime-verificacion.png - ver y verificar — PROBLEMA: extensas zonas blancas sin textura en la orilla
- [x] T18-35: 50-Vegetacion / cap_50_2026-10-19_05-12-10_fps-60-pivote.png - ver y verificar — PROBLEMA: bloque marrón flotando junto a la orilla
- [x] T18-36: 01-Fundamentos-Del-Proyecto / cap_01_2026-08-25_00-29-20.png - ver y verificar — PROBLEMA: campo marrón vacío con un punto blanco; sin terreno reconocible
- [x] T18-37: 01-Fundamentos-Del-Proyecto / cap_01_2026-08-25_00-31-24.png - ver y verificar — PROBLEMA: captura del IDE, no del juego
- [x] T18-38: 01-Fundamentos-Del-Proyecto / cap_01_2026-08-25_00-33-51.png - ver y verificar — PROBLEMA: captura del IDE, no del juego
- [x] T18-39: 01-Fundamentos-Del-Proyecto / cap_01_2026-08-25_00-38-26.png - ver y verificar — PROBLEMA: fondo gris plano y cápsula blanca; sin terreno
- [x] T18-40: 01-Fundamentos-Del-Proyecto / cap_01_2026-08-25_00-49-27.png - ver y verificar — PROBLEMA: captura de documento de texto, no del juego
- [x] T18-41: 13-Herramientas / cap_13_2026-08-25_22-15-00_verificacion_highlight.png - ver y verificar — PROBLEMA: navegador e IDE ocupan la imagen; juego reducido a una franja verde
- [x] T18-42: 13-Herramientas / cap_13_2026-08-25_22-40-00_camara_corregida_3_recursos.png - ver y verificar — PROBLEMA: escena de prueba con cubos primitivos sobre fondo verde
- [x] T18-43: 13-Herramientas / cap_13_2026-08-25_22-50-00_pico_visible_en_mano.png - ver y verificar — PROBLEMA: pico primitivo y cubos; no corresponde al juego terminado
- [x] T18-44: 13-Herramientas / cap_13_2026-08-28_19-19-35_fase3-estado-inicial.png - ver y verificar — PROBLEMA: personaje como cápsula azul bajo el agua; cámara sumergida
- [x] T18-45: 13-Herramientas / cap_13_2026-08-28_19-24-22_fase3-tras-golpes-pala.png - ver y verificar — PROBLEMA: cápsula azul y objeto flotando frente al acantilado
- [x] T18-46: 101-QA-General / cap_101_2026-09-01_22-58-00_1_spawn.png - ver y verificar — PROBLEMA: cápsula azul, franja marrón en el horizonte y editor visible
- [x] T18-47: 101-QA-General / cap_101_2026-09-01_22-58-00_2_tras_caminar.png - ver y verificar — PROBLEMA: cápsula azul y pared verde oscura con líneas diagonales
- [x] T18-48: 101-QA-General / cap_101_2026-09-01_23-00-00_3_click_extraccion.png - ver y verificar — PROBLEMA: misma cápsula y pared; no se aprecia feedback de extracción
- [x] T18-49: 101-QA-General / cap_101_2026-09-01_23-03-00_4_debugmenu.png - ver y verificar — PROBLEMA: no se ve menú debug, solo escena con cápsula azul
- [x] T18-50: 101-QA-General / cap_101_2026-09-01_23-15-00_debug_menu_F12.png - ver y verificar — PROBLEMA: ventanas solapadas y sin menú debug visible
- [x] T18-51: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_18-50-00_jugador.png - ver y verificar — PROBLEMA: cápsula azul, sin ropa visible, editor detrás
- [x] T18-52: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_19-30-00_ui_equipamiento.png - ver y verificar — PROBLEMA: captura del IDE, no de la UI de equipamiento
- [x] T18-53: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_19-33-00_ui_equip2.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el IDE
- [x] T18-54: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_19-34-00_ui_equip3.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el IDE
- [x] T18-55: 155-Vestimenta-Y-Accesorios / cap_155_2026-09-01_19-36-00_ui_equip4.png - ver y verificar — PROBLEMA: solo splash de Godot sobre el IDE
- [x] T18-56: 167-Isla-Raiz / cap_167_2026-09-01_12-28-00_overview.png - ver y verificar — PROBLEMA: cápsula azul, pared con líneas diagonales y SCRIPT ERROR en consola
- [x] T18-57: 167-Isla-Raiz / cap_167_2026-09-01_12-32-00_costa.png - ver y verificar — PROBLEMA: zona blanca/cian plana, costa sin detalle, IDE recortado
- [x] T18-58: 167-Isla-Raiz / cap_167_2026-09-01_22-40-00_smoke_regresion.png - ver y verificar — PROBLEMA: cápsula azul, bloques grises flotando y errores en consola
- [x] T18-59: 167-Isla-Raiz / cap_167_2026-10-31_20-28-35_gpt-luna_isla-reanudada.png - ver y verificar — PROBLEMA: orilla blanca sin textura y agua plana
- [x] T18-60: 167-Isla-Raiz / cap_167_2026-10-31_20-39-56_gpt-luna_continuar-reanuda.png - ver y verificar — PROBLEMA: orilla blanca sin textura, agua plana y personaje


## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)

Las **60 capturas se abrieron y se miraron individualmente** con inspección visual; ninguna quedó marcada `[?]` por no poder verla. Cada línea lleva el veredicto y la descripción concreta de lo observado. No se corrigió ninguna imagen ni asset.

| Veredicto | Tareas |
|---|---|
| OK | 2 (T18-24, T18-25) |
| PROBLEMA | 58 |
| `[?]` por imagen no visible | 0 |

Patrones repetidos (concretos, no "se ve raro"):

- **Captura inútil para QA (15):** T18-05, 18, 26-30, 33, 37, 38, 40, 52-55 muestran solo splash de Godot, pantalla negra, el IDE o un documento de texto.
- **Personaje como cápsula azul (19):** T18-06 a 09, 16, 17, 19, 20, 32, 44 a 51, 56 y 58.
- **Triángulos verdes flotando (5):** T18-01, 02, 03, 22 y 23.
- **Reloj HUD tapa el inventario (4):** T18-11 a 14 (contador 0/24 y pestañas Ropa/Arte cubiertas).
- **Franjas horarias indistinguibles (5):** T18-16, 17, 19, 20 (misma luz verde-amarilla) y T18-18 (negra).
- **Terreno blanco o con costuras negras (7):** T18-04, 06, 15, 21, 34, 57, 59 y 60.

Conclusión honesta para el criterio del director: **2/60 OK**. No se cumple la condición "5/5 OK en dos tandas seguidas"; el nicho queda a su criterio, pero el estado real de las capturas es mayoritariamente problemático, no falta de inspección.

**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05
**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x
