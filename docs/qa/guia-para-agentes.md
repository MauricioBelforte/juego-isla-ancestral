# Guía de Verificación Post-Tarea para el Protocolo Multiagente

> Guía de verificación obligatoria para **cada tarea completada** por un agente, según el protocolo multiagente (AGENTS.md §12/§21).

## Checklist de verificación
1. **Código implementado** y funcional (tests headless 0 fallos).
2. **Documentación actualizada** — plan-actual/ refleja el estado real del código.
3. **05-Checklist.md** con marcas [x] honestas (solo lo que se implementó realmente).
4. **Log generado** en Logs/ con el formato estándar (§6).
5. **Firma del agente** en todos los documentos que modificó.
6. **Registro de coordinación actualizado** — CHECKLIST-GLOBAL, guía 08, ESTADO-PARALELO.
7. **Regresión M60** ejecutada y 66/0 OK (si se tocaron sistemas de datos).
8. **QA cruzado (§21.8)** solicitado a Hy3/WorkBuddy.

## Errores comunes
- No marcar [x] sin verificar (honestidad §21.4).
- Olvidar la firma en los documentos nuevo creados.
- No actualizar la columna Recom/Agente de CHECKLIST-GLOBAL al bloquear/liberar.
- Escribir con encoding incorrecto (UTF-8 sin BOM, ver §28 de AGENTS.md).