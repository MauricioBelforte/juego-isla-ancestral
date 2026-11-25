# 06 — Validación y pruebas (20 tareas)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Regla:** consultas de prueba acotadas; ejecutar únicamente suites/validadores existentes o scripts explícitamente autorizados. No cambiar código de producción.

1. [ ] V6-01 — Identificar el comando y versión documentados para una suite de pruebas asignada, sin ejecutarla todavía.
2. [ ] V6-02 — Ejecutar una prueba unitaria seleccionada y reportar salida exacta, código de retorno y entorno.
3. [ ] V6-03 — Ejecutar una prueba de integración aprobada y confirmar que cubre el contrato citado.
4. [ ] V6-04 — Revisar los casos límite de un test existente contra los límites explícitos del requerimiento.
5. [ ] V6-05 — Comparar un plan de testing con archivos de test presentes; detectar escenarios no implementados sin alterar el plan.
6. [ ] V6-06 — Revisar si una prueba puede pasar falsamente por mocks/fixtures que no ejercitan el sistema real.
7. [ ] V6-07 — Verificar que un validador de proyecto documente su alcance, exclusiones y significado de exit codes.
8. [ ] V6-08 — Ejecutar un validador read-only con `--help` o modo dry-run y resumir opciones y efectos secundarios declarados.
9. [ ] V6-09 — Comparar salida de herramienta contra artefacto fuente mediante conteo independiente pequeño.
10. [ ] V6-10 — Preparar matriz de entrada válida/inválida para un parser JSON ya existente, sin ejecutar escrituras.
11. [ ] V6-11 — Verificar que errores esperados indiquen ruta y ubicación suficiente para reproducir el fallo.
12. [ ] V6-12 — Revisar salidas de regresión y distinguir fallo nuevo, fallo preexistente y fallo ambiental con evidencia histórica disponible.
13. [ ] V6-13 — Confirmar que una suite no escribe sobre `res://`, documentos canónicos o datos del usuario antes de ejecutarla.
14. [ ] V6-14 — Ejecutar comprobación de formato/lint acotada a archivos autorizados y registrar warnings separados de errors.
15. [ ] V6-15 — Revisar un test para determinismo: orden, semilla, reloj, red y dependencia externa.
16. [ ] V6-16 — Medir duración de una tarea de prueba previamente aprobada y reportar tamaño de alcance y hardware/contexto conocido.
17. [ ] V6-17 — Comprobar cobertura de casos nulos, vacíos, duplicados y referencias huérfanas en un validador de datos.
18. [ ] V6-18 — Validar que resumen de CI/CLI citado corresponde al último run disponible, no a una ejecución histórica.
19. [ ] V6-19 — Diseñar casos de prueba para un cambio propuesto sin editar código ni afirmar que la suite fue ejecutada.
20. [ ] V6-20 — Redactar reporte QA que separe comando preparado, ejecutado, fallido, omitido y bloqueado por autorización.

## Criterios de evidencia

Conservar comando, directorio de ejecución, versión de herramienta, resultado/código de retorno y alcance. No exponer variables de entorno sensibles. Una prueba diseñada no equivale a una prueba ejecutada; una prueba pasada no demuestra cobertura fuera de sus aserciones.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
