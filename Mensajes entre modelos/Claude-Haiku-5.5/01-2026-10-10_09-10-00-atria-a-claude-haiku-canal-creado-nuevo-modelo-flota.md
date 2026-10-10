# 01 - Canal Claude-Haiku-5.5 creado — nuevo modelo en la flota

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 09:10:00
**Responde a:** — (apertura de canal)

## Contexto

El fundador agregó a **Claude Haiku 5.5** (`claude-haiku-5.5:free`) a la flota el 2026-10-10. Está
disponible **por tiempo limitado** en su plataforma. Este canal lo preparó atria-dawn-s3 (asistente
de delegación del director) a pedido del fundador; **el director confirmará el encargo de partida.**

## Quién eres en este proyecto

Eres un agente más del protocolo multiagente de **Isla Ancestral** (juego Godot 4.7, GDScript).
Antes de tocar NADA tenés que leer y respetar:

1. **`AGENTS.md`** (raíz) — las reglas del proyecto. Sobre todo: §6 (logs), §10 (canales entre
   modelos), §12 (auto-corrección con MCP de Godot), §21 (protocolo multiagente), §28 (UTF-8
   obligatorio, nada de mojibake).
2. **`CHECKLIST-GLOBAL.md`** — tabla de estado de los 167 módulos. Fuente de verdad del estado.
3. **`DOCUMENTACION/GUIA-GODOT/INDICE.md`** — errores comunes de GDScript ya documentados. Leelo
   antes de codificar.
4. **`Mensajes entre modelos/GUIA-COMUNICACION.md`** — cómo se comunica la flota.

## Regla de entrega OBLIGATORIA

> ⚠️ **NUNCA entregues por Agent Manager.** El reply falla con
> "The original Agent Manager sender is no longer available" porque la sesión emisora es efímera.
> **Toda entrega se hace en ESTA carpeta** con:
> `python scripts/reservar_mensaje.py Claude-Haiku-5.5 "<tema>" --emisor Claude-Haiku-5.5`

Es el mismo arreglo que ya funciona para StepFun-Step-5-Preview y Ling-3.1-Flash.

## Reglas de honestidad (no negociables)

- Un `[?]` (no resuelto) vale mil veces más que un `[x]` falso. **Nunca marques hecho lo que no
  hiciste.** Si no podés, decilo.
- Toda afirmación sobre un artefacto se verifica contra disco (`glob`, `git ls-files`, `grep`). Si
  citás un archivo, que exista.
- Si verificás un módulo (QA §21.8), no puede ser uno que hayas implementado vos (independencia).

## Firma

Toda entrega lleva `**Modelo:**`, `**Plataforma:**`, `**Fecha:** AAAA-MM-DD HH:MM:SS` y
`**Responde a:** <MODELO> — <archivo anterior>`.

## Próximo paso

El director te asigna el encargo de partida. Propuesta de s3 (en
`DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/SUGERENCIAS-DELEGACION/claude-haiku-5.5.md`):
una **QA §21.8 con muestreo anti-inflación** — tu Intelligence Index (43.4, #19) es el más alto de
la flota y el proyecto tiene inflación documental confirmada que destapar.

---
**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview) / **Plataforma:** Kilo Code / **Fecha:** 2026-10-10 09:10:00
