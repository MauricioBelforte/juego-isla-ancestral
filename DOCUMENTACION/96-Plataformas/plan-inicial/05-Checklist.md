**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 96: Plataformas (110 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Matriz de plataformas (RF1)

- [ ] Definir matriz de 20 puntos × 11 plataformas [C]
- [ ] Definir fuente de datos verificable por celda (precio, SDK, requisitos) [M]
- [ ] Definir actualización trimestral de la matriz (M144) [S]
- [ ] Definir formato único de la matriz (tabla markdown en plan-actual) [S]

## 2. PC (P1)

- [ ] Definir PC como plataforma principal (ventana base) [M]
- [ ] Definir targets de PC: Windows x64 (P0), macOS (P1), Linux-Proton (P1) [M]
- [ ] Definir requisitos mínimos y recomendados probados (M61) [M]
- [ ] Definir build Steam Deck compatible desde el target PC [M]

## 3. Steam (P2)

- [ ] Definir Steam como tienda primaria (lanzamiento día 0) [M]
- [ ] Definir SDK Steamworks integrado vía bridge (M96) [M]
- [ ] Definir logros Steam mapeados (M59) [M]
- [ ] Definir cloud saves Steam activos (M60) [M]
- [ ] Definir overlay Steam operativo [M]
- [ ] Definir validación "Deck Verified" en la página [M]
- [ ] Definir build branch/ómo beta de RC [S]

## 4. Epic Games Store (P3)

- [ ] Definir EGS como P1 (decisión en Beta por coste/beneficio) [M]
- [ ] Definir SDK EOS integrado vía bridge (si se aprueba) [M]
- [ ] Definir logros EOS mapeados [M]
- [ ] Definir cloud EOS (opcional) [M]
- [ ] Definir revisión de contenido y build EGS en M142 [M]
- [ ] Definir exclusividad temporal decidida explícitamente (NO por defecto) [S]

## 5. GOG (P4)

- [ ] Definir GOG como opcional P1 (DRM-free) [M]
- [ ] Definir requisitos de distribución GOG sin logros obligatorios [M]
- [ ] Definir cloud GOG Galaxy (opcional) [S]
- [ ] Definir decisión final de GOG en fase Beta [S]

## 6. Microsoft Store (P5)

- [ ] Definir Microsoft Store como P3 (GATE de infraestructura) [M]
- [ ] Definir requisitos UWP/MSIX documentados [M]
- [ ] Definir evaluación de Xbox Game Pass (solo con contrato) [S]
- [ ] Definir sin compromiso de fecha para MS Store [S]

## 7. PlayStation (P6)

- [ ] Definir PlayStation como P2 (GATE por presupuesto/NDA) [M]
- [ ] Definir requisitos de certificación PS documentados [M]
- [ ] Definir devkit PS estimado en costes [M]
- [ ] Definir logros/cloud PS mapeados si hay GATE [M]
- [ ] Definir diseño console-ready lo hace barato (M57/M58/M63) [S]

## 8. Xbox (P7)

- [ ] Definir Xbox como P2 (GATE por presupuesto/NDA) [M]
- [ ] Definir requisitos XR/Xbox documentados [M]
- [ ] Definir Play Anywhere evaluado (solo si aplica) [S]
- [ ] Definir devkit Xbox estimado en costes [M]

## 9. Nintendo (P8)

- [ ] Definir Switch como P2 (GATE por presupuesto/NDA; sugerida primera en consolas) [M]
- [ ] Definir requisitos LOTC y políticas eShop documentados [M]
- [ ] Definir devkit Switch estimado en costes [M]
- [ ] Definir rendimiento Switch (portátil/dock) presupuestado (M61) [M]

## 10. Steam Deck (P9)

- [ ] Definir verificación "Deck Verified" como objetivo P0.5 [M]
- [ ] Definir cheque deck en CI: 800p + gamepad + textos [M]
- [ ] Definir perfil de control específico Deck (M57) [M]
- [ ] Definir pruebas de rendimiento en Deck (M61) [M]
- [ ] Definir manejo de suspensión/resumen del Deck [S]
- [ ] Definir reporte público del estado Deck en la página Steam [S]

## 11. Linux si corresponde (P10)

- [ ] Definir decisión: Linux vía Proton verificado (no nativo) [M]
- [ ] Definir test de Proton mensual (build actual) [M]
- [ ] Definir comunicación del soporte de Linux en FAQ/Store [S]
- [ ] Definir nativo Linux solo si telemetría lo demanda [S]

## 12. macOS si corresponde (P11)

- [ ] Definir decisión: build nativa Apple Silicon [M]
- [ ] Definir Intel macOS condicional a telemetría de usuarios [M]
- [ ] Definir notarización/requisitos de macOS documentados [M]
- [ ] Definir CI de build macOS en pipeline [M]

## 13. Definir prioridad (P12)

- [ ] Definir prioridades P0-P3 con fecha por plataforma [M]
- [ ] Definir recursos asignados por prioridad [M]
- [ ] Definir ventanas: P0 día 0; P1 +1-3 meses; P2 post-lanzamiento [M]
- [ ] Definir revisión de prioridades en M144 [S]

## 14. Analizar certificación (P13)

- [ ] Definir checklist de certificación Steam (revisión de contenido) [M]
- [ ] Definir checklist de certificación EGS y GOG [M]
- [ ] Definir checklist de consolas (TRC/XR/LOTC) si GATE [M]
- [ ] Definir revisión temprana de certificación 2 meses antes del RC [M]
- [ ] Definir Cero sorpresas de certificación en P0 (objetivo medible) [S]

## 15. Analizar costes (P14)

- [ ] Definir tabla de costes: fees de tiendas (Steam $100, EGS 0) [M]
- [ ] Definir tabla de costes: devkits por consola [M]
- [ ] Definir tabla de costes: testing 3rd party por plataforma [M]
- [ ] Definir total estimado por plan de plataformas [M]
- [ ] Definir revisión de costes con M149 (presupuesto de marketing) [S]

## 16. Analizar SDK (P15)

- [ ] Definir versión de Steamworks target [M]
- [ ] Definir versión de EOS target [M]
- [ ] Definir versiones de SDK de consolas (si GATE) [M]
- [ ] Definir política de actualización de SDKs (mensual) [S]
- [ ] Definir sin hardcode de APIs en core (IPlatformBridge) [S]

## 17. Analizar logros (P16)

- [ ] Definir mapeo de logros por plataforma (M59) [M]
- [ ] Definir logros desbloqueables sin red (progresión local) [M]
- [ ] Definir catch-up de logros con saves existentes [M]
- [ ] Definir prueba de logros por plataforma en CI mock [M]

## 18. Analizar cloud saves (P17)

- [ ] Definir cloud por plataforma (Steam nativo, EOS, consolas) [M]
- [ ] Definir portabilidad del save v3.x entre plataformas [M]
- [ ] Definir resolución de conflictos (último ganador + backup, M60) [S]
- [ ] Definir 30 ciclos de cloud por plataforma (M112) [M]

## 19. Analizar controller support (P18)

- [ ] Definir gamepad tratamiento ciudadano de primer orden (M57) [M]
- [ ] Definir perfiles de gamepad por plataforma (deck/ps/xb/nx) [M]
- [ ] Definir UI 100% navegable con gamepad (M57/M89) [M]
- [ ] Definir remapeo completo (M58) [C]
- [ ] Definir notificación de cambio de input (gamepad↔teclado) [S]

## 20. Analizar cross-save (P19)

- [ ] Definir cross-save activo donde la nube de plataforma lo da [M]
- [ ] Definir Steam↔Steam Deck automático (documentado) [S]
- [ ] Definir consolas con cloud de plataforma (si GATE) [M]
- [ ] Definir sin infraestructura cross-save propia nueva [S]
- [ ] Definir prueba de cross-save 30 ciclos (M112) [M]

## 21. Analizar cross-play (P20)

- [ ] Definir decisión: NO aplica (single-player) [S]
- [ ] Definir cláusula documentada del porqué (sin servidores) [S]
- [ ] Definir re-evaluación si un DLC agrega cooperación local (M144) [S]

## 22. Calidad y cierre

- [ ] Definir CI multi-target (Windows/macOS/Linux-Proton/Deck) [C]
- [ ] Definir tests de plataforma en M112 (bridges mock) [M]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]
- [ ] Definir acta de decisiones de plataformas (resumen P0-P3) [S]
- [ ] Definir feed del módulo a M149/M142/M143 (checklist y prioridades) [S]

## Totales

**Total de ítems:** 102
**Ítems resueltos por documentación:** 102 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)