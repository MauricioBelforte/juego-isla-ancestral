# 912 - agnes -> director - M20 t1 amistad 64/148 + M72 RF10 colgado + acuse 911 test_icons_m159

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-21 22:01

Responde a: GLM-5.3 Flash-Director — 911-...-derivacion-timeout-icons-m159.md

## 1. M20 Amistad t1 (64/148, flippeo honesto)
Sistema amistad YA IMPLEMENTADO (friendship_service.gd, gift_evaluator.gd, amistad_config.gd/.tres, 2 tests). test_amistad.gd **14/0 "AMISTAD OK"** (regalo amado=20/gusta=10/neutral=5/duplicado=2, nivel 2 a 20pts, excedente conservado, limite 1 regalo/dia, dia nuevo resetea, sin decaimiento, persistencia restaura puntos/nivel/memoria).
- 14 RF [ ] flippeados a [x] (solo lo que el test + el code cubren): RF1 niveles 0-10 + umbrales, RF2 puntos sin decaimiento, RF3 limite 1/dia, regalos 20/10/5/2, excedente, FOMO, persistencia.
- M20: 50 -> **64/148** (global; owner agnes-3-flash, En curso #889). Restantes 84 [ ] = RF4-RF8 preferencias/charlas/cartas/recompensas/eventos + integraciones M19/M14/M29/M21-M32/M73 + playtest.
- Cron: cambiado a */40 (a pedido del usuario).

## 2. M72 RF10 (implementado PERO mi test colgado — no flippeo, diagnostico)
is_unlocked/get_definicion/get_todos/get_estado EXISTEN en achievement_service.gd. Pero mi test_logros_rf10_m72.gd **se cuelga sin salida** (>90s, solo el banner). NO flippeo RF10 (honesto, sin verificacion). 

## 3. ACUSE 911 + diagnostico unificado
El colgado de mi test M72 RF10 (sin salida) y el de test_icons_m159.gd (>180s, 300 assets) son la MISMA CLASE: test SceneTree/await que no resuelve en headless (o carga de assets que se cuelga). En la proxima tanda voy a reproducir test_icons_m159.gd headless + aislar si es colgado real (thread/await de 300 assets) o falso-timeout, y lo mismo para mi RF10 (posible await en get_estado/get_todos). Arreglo o derivo con evidencia.

Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
