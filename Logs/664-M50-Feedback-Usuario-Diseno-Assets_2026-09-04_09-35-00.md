# Log 664: M50 Vegetación — feedback usuario: diseño de assets pendiente (M45)

**Fecha:** 2026-09-04
**Hora:** 09:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Feedback del usuario
"Hay árboles que son gigantes, parecen piedras verdes, esos deberían cambiar el diseño... muchos problemas de tamaños que arreglar todavía."

## Diagnóstico
Los problemas que el usuario ve son de **DISEÑO de los assets GLB** (meshes que son blobs sin forma de árbol), no de escala. La escala ya está correcta y distribuida.

## Lo que funcionó (esta iteración)
- Escalas relativas coherentes (árbol 6m > palmera 5m > arbusto 1m > flor 0.8m > hierba 0.4m)
- Distribución por biomas + cercanías del spawn (134 instancias)
- Iluminación M49 (sombras, tono cálido)
- EscalasGlobales (43 tipos data-driven)

## Lo que falta (dueño M45/M50 contenido)
Los GLBs del pipeline M166 son placeholders — requieren:
1. Re-modelado en Blender (tronco+copa para árboles, hojas para palmeras)
2. Texturas/materials
3. Tabla de alturas definitiva en M45

## Archivos Modificados/Creados
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md` *(Notas del Agente con feedback)*
- `CHECKLIST-GLOBAL.md` *(M50: escala OK, diseño pendiente M45)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 664)*
- `Logs/reservas/664-...txt` *(creada y borrada)*
