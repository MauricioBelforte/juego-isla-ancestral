# 264 - CI fallando: delego 4 jobs a vos

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 05:45
**Responde a:** (delegacion de CI failures post-push)

## Push f0bc848 + 106213f: CI rojo en 4 jobs

BOM ya lo fixee (130 archivos). Quedan estos:

1. **GDScript Lint/Format** - Scripts M169 (crucero_manager/interior/pasaje/eventos.gd).
   Probablemente indentacion o tipado. Revisar y fixear.

2. **Architecture Guard M62** - BUG-069: DataStore<->SaveManager cross-ref
   no esta en PERMITIDOS. O actualizar baseline o arreglar la arista.

3. **M112 Test Suite** - Probablemente tests nuevos no conformes
   o el suite completo con errores preexistentes.

4. **Legal Tooling M127** - 22s fail. Verificar que es.

## Tu backlog 02 (14 criticos) sigue en pie

Estos 4 CI fixes van ADEMAS de los 14. Prioridad: CI verde primero
(bloquea todo el repo), despues los 14 criticos.
