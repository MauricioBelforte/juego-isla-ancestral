# 03 — Estructuras de datos y JSON (20 tareas)

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
**Regla:** leer primero el schema/validador oficial. No modificar datos de juego; generar reportes en el canal o en ruta temporal autorizada.

1. [x] J3-01 — Validar sintaxis JSON de un archivo asignado y devolver ruta, línea/columna de error o estado válido. Alcance inicial: 6 informes JSON generados en la carpeta de evidencias propia; 6/6 parsean correctamente. Evidencia: `evidencias/J3-01-validacion-json-evidencias.json`; no incluye JSON de producción ni datos de juego.
2. [?] J3-02 — Comprobar claves requeridas/extra de un JSON contra su schema existente. **No resuelto:** se comprobó el contrato que yo misma describí en C1-02, no un schema existente; el resultado no satisface el requisito. Evidencia parcial: `evidencias/J3-02-J3-03-claves-equivalencia.json`. Para resolverlo, hace falta seleccionar un JSON y su schema oficial autorizado.
3. [x] J3-03 — Comparar dos JSON equivalentes por conjunto de claves, ignorando orden de propiedades, con diff compacto. Comparación canónica de objeto extraído y copia reordenada en memoria: equivalentes con sort_keys. No se crearon datos de juego. Evidencia: `evidencias/J3-02-J3-03-claves-equivalencia.json`.
4. [?] J3-04 — Auditar IDs duplicados en un catálogo asignado y generar lista reproducible. **No resuelto:** se contaron IDs en tablas-resumen de bugs, que no son un catálogo asignado. Evidencia parcial: `evidencias/J3-04-ids-repetidos-tablas-bugs.json` (113 filas, 113 IDs únicos); queda pendiente elegir un catálogo autorizado.
5. [x] J3-05 — Detectar valores vacíos, null y placeholders en un dataset, manteniendo diferenciadas esas categorías. Scan de 15 JSON propios: 1 null y 53 strings vacías, todas en `C1-08` (celdas vacías literales de la tabla fuente) o `C1-03` (parent_id nulo para raíz); no se alteraron. Evidencia: `evidencias/J3-05-valores-vacios-evidencias.json`; alcance propio, no dataset de producción.
6. [ ] J3-06 — Validar que referencias entre dos catálogos tengan destino existente; reportar huérfanas sin repararlas.
7. [ ] J3-07 — Comprobar que cantidades numéricas cumplan tipos/rangos documentados en schema o contrato.
8. [ ] J3-08 — Comparar traducciones por claves y placeholders (`{x}`, `%s`) entre idiomas, solo lectura.
9. [ ] J3-09 — Auditar unicidad y formato de claves de traducción en un archivo PO o JSON asignado.
10. [ ] J3-10 — Comprobar consistencia de listas paralelas (IDs/nombres/rutas) y hallar longitud/desfase.
11. [ ] J3-11 — Generar JSON de reporte de enlaces rotos en un catálogo con origen y destino.
12. [ ] J3-12 — Verificar nombres de archivo/rutas citados en manifiestos contra el sistema de archivos.
13. [ ] J3-13 — Clasificar entradas que no siguen schema como error, excepción documentada o caso indeterminado.
14. [ ] J3-14 — Revisar un `.tres`/`.tscn` en modo lectura y extraer nodos/recursos nombrados como JSON simple.
15. [ ] J3-15 — Comparar conteos de recursos declarados en plan-actual contra conteo real en un directorio asignado.
16. [ ] J3-16 — Verificar que un inventario de assets no repita rutas, IDs o identificadores semánticos.
17. [ ] J3-17 — Auditar formato de fechas/timestamps en un dataset y reportar valores no parseables sin normalizar.
18. [ ] J3-18 — Revisar serialización de un fixture contra el contrato documentado, sin ejecutar ni alterar guardados reales.
19. [ ] J3-19 — Crear un validador de esquema pequeño solo con autorización expresa, incluir casos positivos/negativos y no integrarlo sin encargo.
20. [ ] J3-20 — Medir concordancia de clasificación JSON contra un conjunto de referencia elegido por el director; calcular precisión/recall si hay etiquetas válidas.

## Restricciones

- Nunca ejecutar o modificar JSON de configuración de producción como efecto lateral del análisis.
- No inferir que un campo es inválido sin schema o contrato que lo respalde.
- No incluir credenciales, tokens ni datos personales en resultados.

---

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25
