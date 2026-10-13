# M69 — Fast Travel: Especificación Completa

**Módulo:** M69
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de fast travel.

---

## A. Requisitos
- **Problema:** Desplazamiento rápido sin fatiga ni bypass de eventos.
- **Dependencias:** M28 (Islas), M29 (Tiempo), M31 (Calendario).
- **Progresión:** Fast travel desbloqueado gradualmente (RF1).
- **Puntos marcables:** Jugador puede marcar un punto de viaje (RF2).
- **Restricciones:** Acceso por estado (combate, evento, misión) (RF3).
- **Costo:** Recursos o tiempo (RF4) — implementado.
- **Teletransporte:** A deidades/special locations (RF5).
- **Cancelación:** Jugador puede cancelar (RF6).
- **Guardado:** Último punto guardado (RF7).
- **UI:** Clara y tranquila (RF8).
- **Pausa:** Automática en single-player (RF9).
- **Día/Noche:** Integración M29 (RF10).
- **Accesibilidad:** Atajo teclado + menú intuitivo (RF10).

## B. Puntos del Plan
- P1: Progresivo ✅
- P2: Desbloqueo al descubrir (RF1)
- P3: Costo (RF4) ✅
- P4: Transición bruma/desvanecimiento
- P5: Pantalla de carga minimalista
- P6: Instantáneo o tiempo simulado
- P7: Cancelación a mitad de animación
- P8: Bloqueado en combate/eventos
- P9: Guardado último punto por sesión
- P10: Anti-bypass eventos
- P11: Anti-ruptura misiones
- P12: Prueba a todos los destinos
- P13: Delegable ✅

## C. Familia Tonal
- SFX coherente M41/M42/M43.
- Confirmación: tono ascendente cálido.
- Error: tono descendente suave.
- UI: family tones M45.
- Volumen: M91 (bloqueante).

## D. Rendimiento
- O(1) lookup ✅
- Sin cálculos complejos ✅
- Pool de estados (disponible/bloqueado/cooldown)
- Integración M29/M31
- Tests: pool, rendimiento (<16ms), integración, costo, restricciones

## E. Costo y Progresión
- **Costo base:** 5 gemas (M38) o 30s de tiempo.
- **Progresión:** Desbloqueado por historia (M22).
- **Descuento:** 20% por amistad nivel 5+ (M20).

## F. UI y UX
- **Menú:** Atajo F5 + botón en mapa.
- **Lista:** Destinos desbloqueados + nombre + distancia.
- **Confirmación:** Pantalla minimalista (nombre destino + costo).
- **Cancelación:** ESC antes de confirmar.
- **Transición:** Bruma 0.5s → fade 0.3s → reaparición.

## G. Seguridad
- **Anti-bypass:** Eventos críticos bloquean fast travel.
- **Anti-ruptura:** Misiones activas requieren confirmación.
- **Cooldown:** 5s entre viajes.

## H. Test
- 4 anclas (Isla Raíz, Este, Norte, Sur).
- Costo descontado correctamente.
- Bloqueo en estados prohibidos.
- Guardado/carga del último punto.
