# DS-V4.1-Flash-Opencode — M90 Config Grafica 92 items + M91/M158/M147/M15/M62
**Fuente:** BACKLOG-MASTER.md DS-V4.1-Flash-Opencode (sección dividida 4nov por fundador)
**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash / OpenCode)
**Plataforma:** OpenCode
**Estado:** [ ] Pendiente


---

# (C) FRENTE ESTÉTICO PREMIUM — PRE-ASIGNADO (directiva del fundador 2026-10-17 21:45)

> **LÉELO DESPUÉS de agotar la COLA ACTIVA (A) y las tandas en vuelo.** Cada bloque lista
> los ítems `[ ]` REALES extraídos del `05-Checklist.md` correspondiente (verificados contra
> disco por el director). No duplica lo ya hecho. Firma: GLM-5.3 Flash-Director / Kilo Code.

## M90-Configuración-Grafica (el frente grande del config settings/presets/culling/LOD/volumétrica) — 92 ítems

1. Definir culling de objetos fuera de distancia
2. Definir LODs para objetos lejanos (M50) — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 
3. Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad)
4. Definir animación por wind shader
5. Definir interacción con jugador
6. Definir normal map para olas
7. Definir parallax para profundidad
8. Definir caustics para ultra
9. Definir colisión de partículas con world
10. Definir toggle de post-processing
11. Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
12. Definir activación/desactivación de todos los efectos
13. Definir toggle de bloom — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom está **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled 
14. Definir intensidad (slider 0-1)
15. Definir threshold (slider 0-1)
16. Definir radius (slider 0-1)
17. Definir bloom shader para glow
18. Definir threshold para fuentes de luz brillantes
19. Definir toggle de motion blur
20. Definir intensidad (slider 0-1)
21. Definir sample count (slider 4-16)
22. Definir motion blur basado en velocidad de cámara
23. Definir más blur cuando la cámara se mueve más rápido
24. Definir desactivado por defecto (causa mareo)
25. Definir toggle de depth of field
26. Definir intensidad (slider 0-1)
27. Definir distancia (slider 0-100)
28. Definir aperture (slider 0-1)
29. Definir depth of field basado en distancia de la cámara
30. Definir blur para objetos fuera de foco
31. Definir aperture controla cuánto blur
32. Definir FSR 2.0 (AMD mejorado)
33. Definir detección de GPU y habilitación correspondiente
34. Definir 125% (oversampling 1.25x)
35. Definir 150% (oversampling 1.5x)
36. Definir detección de RAM (OS.get_static_memory_usage())
37. Definir detección de CPU (OS.get_processor_name())
38. Diseñar tamaño de fuente (slider 0.5x a 2x)
39. Diseñar alto contraste (toggle)
40. Diseñar reducción de motion blur (opción para reducir mareo)
41. Diseñar reducción de bloom (opción para reducir distracción visual)
42. Diseñar aplicación en tiempo real
43. Diseñar FPS counter (opcional, en debug)
44. Diseñar profiling de GPU (opcional, en debug)
45. Diseñar monitoreo de uso de GPU y RAM (opcional, en debug)
46. Diseñar FPS counter visible en debug (M110)
47. Diseñar profiling visible en debug (M110)
48. Diseñar monitoreo visible en debug (M110)
49. Diseñar tamaño de fuente (slider 0.5x a 2x)
50. Diseñar alto contraste (toggle)
51. Diseñar aplicación en tiempo real
52. Diseñar controles para resolución (dropdown)
53. Diseñar controles para pantalla completa (toggle)
54. Diseñar controles para ventana (toggle)
55. Diseñar controles para borderless (toggle)
56. Diseñar controles para VSync (dropdown)
57. Diseñar controles para FPS cap (dropdown)
58. Diseñar controles para escala de resolución (slider)
59. Diseñar controles para upscaling (dropdown)
60. Diseñar controles para calidad de sombras (dropdown)
61. Diseñar controles para calidad de texturas (dropdown)
62. Diseñar controles para distancia de dibujado (slider)
63. Diseñar controles para calidad de efectos (dropdown)
64. Diseñar controles para calidad de vegetación (dropdown)
65. Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown)
66. Diseñar controles para anti-aliasing (dropdown)
67. Diseñar controles para anisotropic filtering (dropdown)
68. Diseñar controles para post-processing (toggle)
69. Diseñar controles para bloom (toggle + slider)
70. Diseñar controles para motion blur (toggle + slider)
71. Diseñar controles para depth of field (toggle + slider)
72. Diseñar botón de detección automática
73. Diseñar método detect_hardware()
74. Diseñar lógica de recomendación según GPU, RAM, CPU
75. Diseñar método apply_resolution()
76. Diseñar método apply_vsync()
77. Diseñar método apply_fps_cap()
78. Diseñar método apply_anti_aliasing()
79. Incluir resolución como objeto {x, y}
80. Diseñar pruebas de legibilidad en 720p
81. Diseñar pruebas de legibilidad en 1080p
82. Diseñar pruebas de legibilidad en 4K
83. Diseñar pruebas de soporte de tildes
84. Diseñar pruebas de soporte de ñ
85. Diseñar pruebas de soporte de símbolos
86. Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
87. Diseñar pruebas de ajustes de accesibilidad
88. Diseñar pruebas de rendimiento (tiempo de carga)
89. Diseñar 06-Plan-Testings.md (APLICA)
90. Diseñar tests de ajustes individuales
91. Diseñar tests de aplicación en tiempo real
92. Diseñar tests de detección automática de hardware


