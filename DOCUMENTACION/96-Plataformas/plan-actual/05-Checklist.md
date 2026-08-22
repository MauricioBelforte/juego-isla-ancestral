**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 96: Plataformas (102 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Matriz de plataformas (RF1)

- [x] Definir matriz de 20 puntos × 11 plataformas [C]
- [x] Definir fuente de datos verificable por celda (precio, SDK, requisitos) [M]
- [x] Definir actualización trimestral de la matriz (M144) [S]
- [x] Definir formato único de la matriz (tabla markdown en plan-actual) [S]

## 2. PC (P1)

- [x] Definir PC como plataforma principal (ventana base) [M]
- [x] Definir targets de PC: Windows x64 (P0), macOS (P1), Linux-Proton (P1) [M]
- [x] Definir requisitos mínimos y recomendados probados (M61) [M]
- [x] Definir build Steam Deck compatible desde el target PC [M]

## 3. Steam (P2)

- [x] Definir Steam como tienda primaria (lanzamiento día 0) [M]
- [x] Definir SDK Steamworks integrado vía bridge (M96) [M]
- [x] Definir logros Steam mapeados (M59) [M]
- [x] Definir cloud saves Steam activos (M60) [M]
- [x] Definir overlay Steam operativo [M]
- [x] Definir validación "Deck Verified" en la página [M]
- [x] Definir build branch/ómo beta de RC [S]

## 4. Epic Games Store (P3)

- [x] Definir EGS como P1 (decisión en Beta por coste/beneficio) [M]
- [x] Definir SDK EOS integrado vía bridge (si se aprueba) [M]
- [x] Definir logros EOS mapeados [M]
- [x] Definir cloud EOS (opcional) [M]
- [x] Definir revisión de contenido y build EGS en M142 [M]
- [x] Definir exclusividad temporal decidida explícitamente (NO por defecto) [S]

## 5. GOG (P4)

- [x] Definir GOG como opcional P1 (DRM-free) [M]
- [x] Definir requisitos de distribución GOG sin logros obligatorios [M]
- [x] Definir cloud GOG Galaxy (opcional) [S]
- [x] Definir decisión final de GOG en fase Beta [S]

## 6. Microsoft Store (P5)

- [x] Definir Microsoft Store como P3 (GATE de infraestructura) [M]
- [x] Definir requisitos UWP/MSIX documentados [M]
- [x] Definir evaluación de Xbox Game Pass (solo con contrato) [S]
- [x] Definir sin compromiso de fecha para MS Store [S]

## 7. PlayStation (P6)

- [x] Definir PlayStation como P2 (GATE por presupuesto/NDA) [M]
- [x] Definir requisitos de certificación PS documentados [M]
- [x] Definir devkit PS estimado en costes [M]
- [x] Definir logros/cloud PS mapeados si hay GATE [M]
- [x] Definir diseño console-ready lo hace barato (M57/M58/M63) [S]

## 8. Xbox (P7)

- [x] Definir Xbox como P2 (GATE por presupuesto/NDA) [M]
- [x] Definir requisitos XR/Xbox documentados [M]
- [x] Definir Play Anywhere evaluado (solo si aplica) [S]
- [x] Definir devkit Xbox estimado en costes [M]

## 9. Nintendo (P8)

- [x] Definir Switch como P2 (GATE por presupuesto/NDA; sugerida primera en consolas) [M]
- [x] Definir requisitos LOTC y políticas eShop documentados [M]
- [x] Definir devkit Switch estimado en costes [M]
- [x] Definir rendimiento Switch (portátil/dock) presupuestado (M61) [M]

## 10. Steam Deck (P9)

- [x] Definir verificación "Deck Verified" como objetivo P0.5 [M]
- [x] Definir cheque deck en CI: 800p + gamepad + textos [M]
- [x] Definir perfil de control específico Deck (M57) [M]
- [x] Definir pruebas de rendimiento en Deck (M61) [M]
- [x] Definir manejo de suspensión/resumen del Deck [S]
- [x] Definir reporte público del estado Deck en la página Steam [S]

## 11. Linux si corresponde (P10)

- [x] Definir decisión: Linux vía Proton verificado (no nativo) [M]
- [x] Definir test de Proton mensual (build actual) [M]
- [x] Definir comunicación del soporte de Linux en FAQ/Store [S]
- [x] Definir nativo Linux solo si telemetría lo demanda [S]

## 12. macOS si corresponde (P11)

- [x] Definir decisión: build nativa Apple Silicon [M]
- [x] Definir Intel macOS condicional a telemetría de usuarios [M]
- [x] Definir notarización/requisitos de macOS documentados [M]
- [x] Definir CI de build macOS en pipeline [M]

## 13. Definir prioridad (P12)

- [x] Definir prioridades P0-P3 con fecha por plataforma [M]
- [x] Definir recursos asignados por prioridad [M]
- [x] Definir ventanas: P0 día 0; P1 +1-3 meses; P2 post-lanzamiento [M]
- [x] Definir revisión de prioridades en M144 [S]

## 14. Analizar certificación (P13)

- [x] Definir checklist de certificación Steam (revisión de contenido) [M]
- [x] Definir checklist de certificación EGS y GOG [M]
- [x] Definir checklist de consolas (TRC/XR/LOTC) si GATE [M]
- [x] Definir revisión temprana de certificación 2 meses antes del RC [M]
- [x] Definir Cero sorpresas de certificación en P0 (objetivo medible) [S]

## 15. Analizar costes (P14)

- [x] Definir tabla de costes: fees de tiendas (Steam $100, EGS 0) [M]
- [x] Definir tabla de costes: devkits por consola [M]
- [x] Definir tabla de costes: testing 3rd party por plataforma [M]
- [x] Definir total estimado por plan de plataformas [M]
- [x] Definir revisión de costes con M149 (presupuesto de marketing) [S]

## 16. Analizar SDK (P15)

- [x] Definir versión de Steamworks target [M]
- [x] Definir versión de EOS target [M]
- [x] Definir versiones de SDK de consolas (si GATE) [M]
- [x] Definir política de actualización de SDKs (mensual) [S]
- [x] Definir sin hardcode de APIs en core (IPlatformBridge) [S]

## 17. Analizar logros (P16)

- [x] Definir mapeo de logros por plataforma (M59) [M]
- [x] Definir logros desbloqueables sin red (progresión local) [M]
- [x] Definir catch-up de logros con saves existentes [M]
- [x] Definir prueba de logros por plataforma en CI mock [M]

## 18. Analizar cloud saves (P17)

- [x] Definir cloud por plataforma (Steam nativo, EOS, consolas) [M]
- [x] Definir portabilidad del save v3.x entre plataformas [M]
- [x] Definir resolución de conflictos (último ganador + backup, M60) [S]
- [x] Definir 30 ciclos de cloud por plataforma (M112) [M]

## 19. Analizar controller support (P18)

- [x] Definir gamepad tratamiento ciudadano de primer orden (M57) [M]
- [x] Definir perfiles de gamepad por plataforma (deck/ps/xb/nx) [M]
- [x] Definir UI 100% navegable con gamepad (M57/M89) [M]
- [x] Definir remapeo completo (M58) [C]
- [x] Definir notificación de cambio de input (gamepad↔teclado) [S]

## 20. Analizar cross-save (P19)

- [x] Definir cross-save activo donde la nube de plataforma lo da [M]
- [x] Definir Steam↔Steam Deck automático (documentado) [S]
- [x] Definir consolas con cloud de plataforma (si GATE) [M]
- [x] Definir sin infraestructura cross-save propia nueva [S]
- [x] Definir prueba de cross-save 30 ciclos (M112) [M]

## 21. Analizar cross-play (P20)

- [x] Definir decisión: NO aplica (single-player) [S]
- [x] Definir cláusula documentada del porqué (sin servidores) [S]
- [x] Definir re-evaluación si un DLC agrega cooperación local (M144) [S]

## 22. Calidad y cierre

- [x] Definir CI multi-target (Windows/macOS/Linux-Proton/Deck) [C]
- [x] Definir tests de plataforma en M112 (bridges mock) [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir acta de decisiones de plataformas (resumen P0-P3) [S]
- [x] Definir feed del módulo a M149/M142/M143 (checklist y prioridades) [S]

## Totales

**Total de ítems:** 102
**Ítems resueltos por documentación:** 102 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)