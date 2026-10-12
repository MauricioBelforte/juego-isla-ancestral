# Confirmación de Participación — Sorteos Isla Ancestral

**Plantilla oficial** — usar para todos los giveaways del proyecto.
**Categoría:** Mensajes de confirmación de participación en sorteos

---

## Plantilla (editar {variables})

```
═══════════════════════════════════════════
  CONFIRMACIÓN DE PARTICIPACIÓN
  Isla Ancestral — {nombre_sorteo}
═══════════════════════════════════════════

¡Hola, {nombre_participante}!

Gracias por participar en el sorteo "{nombre_sorteo}".

  PREMIO:       {descripción_premio}
  PERIODO:      {fecha_inicio} → {fecha_fin}
  RESULTADOS:   {fecha_revelacion}
  CANAL:        {canal_anuncio}

Tu código de participación: {codigo_participacion}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Condiciones resumidas (texto completo en {url_reglamento}):

  • Un (1) premio por persona.
  • Solo cuentas {restriccion_edad}.
  • {regionalizacion} — restringido a {regiones}.
  • El premio incluye {incluye}.
  • Sin obligación de compra.

Preguntas: {email_sorteos}

Te avisaremos por {canal_notificacion} al ganar.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Isla Ancestral
  {año} — Proyecto indie

  Síguenos:
    · Steam    → {url_steam}
    · Twitter/X → {url_x}
    · Discord   → {url_discord}
```

## Reglas de Uso

1. **NO editar el cuerpo legal** (condiciones, premio, período) sin aprobación de
   `marketing_legal_review.md` (§ M126).
2. **Idiomas:** mantener la misma estructura en ES/EN/PT (traducción de "condiciones
   resumidas" libre).
3. **Identidad visual:** usar la paleta Maldivas (`#0F4C5C`, `#5F0F40`, `#FFB627`) y
   la tipografía del projecto.
4. **Archivo:** guardar el `.md` final en `docs/legal/sorteos/{nombre}_confirmacion.md`.

## Cumplimiento Legal (M126)

- Sorteo = "prize draw" en muchas jurisdicciones. Ver
  `data/legal/contratos.json → sorteo_reglas` (M126).
- Si el premio tiene valor > {umbral_local}, se requiere formulario fiscal
  (M126 revisa por país).
- Verificar restricciones por edad del sorteo con el `menores.json`.

---
*Documento de plantilla — M126 iter. 4 (agnes-3-flash, Kilo Code).*
