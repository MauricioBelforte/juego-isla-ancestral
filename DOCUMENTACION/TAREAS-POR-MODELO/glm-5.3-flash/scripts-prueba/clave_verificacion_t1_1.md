# CLAVE DE VERIFICACIÓN T1.1 VISION (USO EXCLUSIVO DEL VERIFICADOR — NO compartir con Nemotron)

**Verificador:** GLM-5.3-Flash | **Fecha:** 2026-10-25
**Captura:** `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-18_00-45-30_despues_equipamiento_centralizado.png` (64.595 bytes)
**Propósito:** comparar el informe 002 de Nemotron-3.5-Super-VL contra lo que la captura MUESTRA de verdad. Yo (GLM-5.3-Flash) la vi el 25oct antes de mandarla.

## Elementos verificables (lo que el informe DEBE poder citar)

- Título de la ventana del juego: **"isla-ancestral (DEBUG)"**
- Encabezado del panel: **"Vestimenta del jugador"** (panel oscuro con borde amarillo/naranja, esquinas redondeadas)
- Texto: **"Bono de terreno del equipo: +0%"**
- Contador: **"16 prendas en el catálogo"**
- **4 slots "Head: Vacío"** en grilla de 2 columnas x 2 filas (botones oscuros)
- Separador y subtítulo: **"Prendas del catálogo (click para equipar)"**
- Lista del catálogo (con scrollbar a la derecha):
  - "🔒 Amuleto ancestral (acc_amulet_ancestral)" — texto gris (bloqueado)
  - "Brújula — common (acc_compass)"
  - "Capa impermeable — uncommon (body_coat_rain)"
  - "🔒 Chaleco explorador (body_vest_explorer)" — gris (bloqueado)
  - "Botas de barro — common (feet_boots_mud)" — cortada en el borde inferior (corte visible con scroll necesario)
- Detrás de la ventana del juego: editor de código (VS Code) — la captura fue tomada con la ventana del juego flotando sobre el editor; arriba a la derecha se ve una línea de consola tipo "Acceso: 129. tanda 11 verificada (109/300)."

## Defectos/matices que un QA visual competente podría detectar

- Los 4 slots duplican el texto "Head: Vacío" — si el diseño era 1 por tipo (casco/corona/etc.), repetir "Head" 4 veces parece bug de render o etiqueta genérica.
- Ítems bloqueados solo se diferencian por gris+candado — contraste accesible cuestionable.
- El panel se corta en el borde inferior sin paginación (scroll implícito).
- La ventana DEBUG flotando sobre el editor: la captura no es "limpia" (contaminación de fondo).

## Reglas de calificación del informe 002

- **HIT:** cita textual de un elemento presente arriba (títulos, textos, ids, cantidades).
- **MISS (alucinación):** menciona elementos/textos que NO existen en la captura (p.ej. inventar menús, botones "Guardar", "Opciones", números distintos, items que no están).
- **Veredicto:** APROBADO si la descripción base es esencialmente correcta (≥80% de los elementos clave sin alucinaciones mayores); el detalle fino de defectos suma, no resta si está justificado.
