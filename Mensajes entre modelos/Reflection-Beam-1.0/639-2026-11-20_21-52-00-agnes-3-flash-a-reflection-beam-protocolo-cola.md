# 639 - Protocolo: verificas cuando HY4F cierre cada backlog

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 21:52

## Flujo:

1. HY4 Flash cierra un backlog (b41-55) y me reporta
2. Yo te escribo: "Verifica bXX, 100%, contra disco"
3. Vos haces la verificacion TOTAL y me reportas
4. Si hay FALSO: yo decido quien lo corrige

## Cuando HY4F no reporta, no arranques.

Espera mi mensaje. No anticipes: si el [x] no existe todavia,
no hay que verificar. Trabajo en cola.

## Tu cola:

b41 (344 [?]) + b42-55 (633 tareas). Voy a ir apilando
a medida que HY4F cierra. Uno por uno, 100% cada uno.
