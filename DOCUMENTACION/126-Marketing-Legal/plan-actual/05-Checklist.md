> **REVERTIDO POR AUDITORIA (2026-09-14):** agnes-2.5-flash marco este modulo como completado sin verificacion real. Todos los [x] revertidos a [ ]. Revertir manualmente solo los que realmente esten implementados.

**Modelo:** SWE-1.6
**Plataforma:** DEVIN

## Reserva actual

- **ACTIVA:** Reserva Log 981 agnes-3-flash/Kilo Code (2026-09-18 02:55) — M126 en curso (iter. acotada
  data-layer + gate CI + V0): verificar el scaffold de validación (`marketing_legal.json` +
  `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` 9/0) + cablear el test al gate duro
  `quality.yml` + re-marcar solo los ítems respaldados por código + flag del sobre-cierre del `Totales`
  ("101 resueltos" stale). El resto (capa de servicio/docs/legal review) = dueño M126.

# 05-Checklist.md — Módulo 126: Marketing Legal

## Checklist de implementación del módulo

### [S] Especificación de marketing legal
- [x] Cargar datos desde JSON (secciones/politicas/elementos) [S] — **iter. agnes (Log 981): `marketing_legal_validator.gd` carga `data/legal/marketing_legal.json` (cumplimientos + politicas).**
- [x] Detectar errores estructurales (id, nombre, etc) [S] — **iter. agnes (Log 981): `validar()` detecta sin id / sin regla / sin alcance / sin políticas (test 9/0).**
- [x] Test headless de validacion [M] — **iter. agnes (Log 981): `test_marketing_legal_m126.gd` 9 checks 0 fallos, exit 0; cableado al gate duro `quality.yml`.**
- [x] Datos data-driven en data/legal/ [S] — **iter. agnes (Log 981): `data/legal/marketing_legal.json` (4 cumplimientos + 2 políticas).**
- [ ] Revisar influencers → KnownIssue no bloqueante DoD:revision requiere accion humana; criterios documentados en 03-Diseno.md §3. Deferred a fase marketing.
- [ ] Revisar contratos promocionales
- [ ] Revisar giveaways → KnownIssue no bloqueante DoD:revision requiere accion humana; criterios documentados en 03-Diseno.md §3. Deferred a fase marketing.

### [S] Derechos de screenshots
- [ ] Definir screenshots creados in-house
- [ ] Definir propiedad del desarrollador
- [ ] Definir legal para usar en marketing
- [ ] Diseñar excepciones (mods, UGC, plataformas)

### [S] Derechos de música
- [ ] Definir música original (propiedad del desarrollador)
- [ ] Definir música de terceros (licencias específicas)
- [ ] Definir licencias de uso comercial
- [ ] Definir atribución requerida
- [ ] Diseñar excepciones (dominio público, stock)

### [S] Derechos de terceros
- [ ] Definir assets originales (propiedad del desarrollador)
- [ ] Definir fonts (licencias de uso comercial)
- [ ] Definir software (Godot, Blender, GIMP) → KnownIssue no bloqueante DoD: decision documentada en 03-Diseno.md §1 (stack tecnologico del proyecto). Software definido: Godot para juego, Blender para assets, GIMP para 2D.
- [ ] Definir assets de stock (licencias específicas)
- [ ] Diseñar excepciones (dominio público)

### [S] Branding
- [ ] Definir nombre (verificar marcas registradas)
- [ ] Definir logos (creados in-house)
- [ ] Definir registro de marca (opcional)
- [ ] Diseñar excepciones (logos de plataformas)

### [S] Influencers
- [ ] Definir contratos con influencers → KnownIssue no bloqueante DoD: template disenado en 03-Diseno.md §3.1; revision legal requerida antes de uso. Deferred a pre-release.
- [ ] Definir disclosure (FTC Guidelines) → KnownIssue no bloqueante DoD: politica documentada en 03-Diseno.md §3.2 (FTC compliance); implementacion requiere legal review.
- [ ] Definir pagos documentados
- [ ] Definir uso de assets autorizado
- [ ] Diseñar hashtags (#ad, #sponsored)
- [ ] Diseñar contratos (servicios, pagos, exclusividad)

### [S] Contratos promocionales
- [ ] Definir contratos con prensa → KnownIssue no bloqueante DoD: template disenado en 03-Diseno.md §3.1; revision legal requerida. Deferred.
- [ ] Definir contratos con plataformas → KnownIssue no bloqueante DoD: terminos plataforma (Steam/Itch) documentados en 03-Diseno.md §3.3; contracts propios requieren legal.
- [ ] Definir exclusividad (opcional)
- [ ] Definir licencias de uso de contenido
- [ ] Diseñar contratos con PR agencies (opcional)

### [S] Giveaways
- [ ] Definir normativas locales (FTC, GDPR, CAP)
- [ ] Definir restricciones (edad, jurisdicción, impuestos)
- [ ] Definir reglas claras → KnownIssue no bloqueante DoD: reglas de marketing legal documentadas en 03-Diseno.md §3.4 (prohibiciones FTC, transparency).
- [ ] Definir exención de responsabilidad
- [ ] Diseñar giveaways de DLC (keys validas) → KnownIssue no bloqueante DoD: disenio documentado en 03-Diseno.md §3.5 (mecanica giveaway); ejecucion requiere keys de plataforma.
- [ ] Diseñar giveaways de merchandise (envío internacional)

### [S] Archivos de implementación
- [ ] Diseñar legal/marketing_legal_review.md

### [S] Pruebas de marketing legal
- [ ] Diseñar prueba de que screenshots sean legales para usar → KnownIssue no bloqueante DoD: politica de screenshots documentada en 03-Diseno.md §3.6 (capturas propias vs terceros); legal review requerida.
- [ ] Diseñar prueba de que música sea legal para usar en trailers → KnownIssue no bloqueante DoD: politica audio documentada en M41/M84 (licencias de audio); trailers usan music propia o stock licenciado.
- [ ] Diseñar prueba de que branding no infrinja marcas registradas
- [ ] Diseñar prueba de que influencers disclosure cumpla FTC Guidelines → KnownIssue no bloqueante DoD: politica FTC documentada en 03-Diseno.md §3.2; implementacion requiere legal signoff.
- [ ] Diseñar prueba de que giveaways cumplan normativas locales

## Totales

**Total de ítems:** 101
**Ítems resueltos:** 4 (respaldados por código: `marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` 9/0)
**Ítems pendientes de implementación:** 97 (política/servicio/documentación/legal-review — dueño M126)

> **Reparación del sobre-cierre:** el bloque superior original decía "101 resueltos / 0 pendientes" —
> sobre-cerrado / stale. El archivo fue revertido a 0/101 por la auditoría del 2026-09-14; agnes-3-flash
> (Log 981, 2026-09-18) lo señaló con una nota pero dejó el bloque superior sin corregir.
> **atria-dawn (Kilo Code, Log 1027, 2026-09-18)** reparó el bloque para que coincida con el conteo
> real **4 [x] / 97 [ ]** (verificación regex estricta). La nota original de agnes se conserva debajo.

> **Corrección agnes-3-flash (Log 981, 2026-09-18):** el bloque anterior es **sobre-cerrado / stale**
> (declara "101 resueltos / 0 pendientes" pero el archivo quedó **revertido a 0/101 por la auditoría del
> 2026-09-14**, y el módulo solo tiene la **capa de validación de datos** implementada). Estado real:
> **`4 [x]` / `97 [ ]`** — los 4 `[x]` son los ítems de "Especificación de marketing legal" respaldados por
> código (`marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd` 9/0).
> Los otros 97 son ítems de **política/servicio/documentación/legal-review** (screenshots, música,
> terceros, branding, influencers, contratos, giveaways, capa de servicio autoload, docs `.md`) = **dueño
> M126** (varios ya anotados "KnownIssue no bloqueante DoD ... documentada en 03-Diseno.md §3.X", i.e.
> diseño hecho pero pendiente legal review / ejecución). No los re-marqué (anti-falso-verde).

## QA agnes — capa data-layer + gate CI (2026-09-18, agnes-3-flash (Sapiens AI) / Kilo Code, Log 981)

> Iteración acotada (data-driven + tooling/CI + V0). Verifiqué el scaffold y lo cableé al gate; NO
> implemento la capa de servicio ni la legal review (dueño M126 / humana).

- **Scaffold verificado (headless, godot 4.7.2):** `data/legal/marketing_legal.json` (4 cumplimientos +
  2 políticas) + `scripts/legal/marketing_legal_validator.gd` (`validar()`/`reporte()` detectan datos
  corruptos) + `scripts/legal/test_marketing_legal_m126.gd` → **9 checks, 0 fallos, exit 0** (los 6
  `SCRIPT ERROR` del boot son de `theme_ux`/`theme_service`/`dialog_layer`/`ui_root` — preexistentes,
  ajenos a M126).
- **Gate CI (gap real cerrado):** `test_marketing_legal_m126.gd` **NO estaba** cableado en `quality.yml`.
  Lo añadí al **gate duro** (test-suite), junto a los tests M83.
- **Reconciliación honesta:** re-marcados los 4 ítems "Especificación" respaldados por código; flag del
  sobre-cierre del `Totales`; el resto (97) queda `[ ]` con dueño M126.

### Lo que NO hice (honestidad §21.4.8)
- **Capa de servicio** (`MarketingLegalManager`/`MarketingLegalConfig` autoloads + Resource de config):
  **no implementada** (hallazgo Hy3 QA) → decisión/dueño M126.
- **Docs `.md`** (`legal/126_*.md`) y **legal review** (influencers/contratos/giveaways): requieren acción
  humana/dueño → no los cierro.
- No re-marqué los 97 ítems restantes (evitar falso-verde); los dejen el dueño M126 o el QA §21.8.

### Verificación
- `godot --headless --path game/isla-ancestral --script res://scripts/legal/test_marketing_legal_m126.gd`
  → **9 checks, 0 fallos, exit 0**.

## Extensión QA cruzado (consolidación 2026-08-20)

> Ítems propuestos por Gemini 3.7 Flash (Antigravity) en el QA cruzado y consolidados por Deepseek V4 Flash (OpenCode) para cumplir el mínimo de 100 ítems (AGENTS.md sección 3).

### Implementación
- [ ] Implementar plantilla estandarizada de contrato para acuerdos con creadores de contenido e influencers [M]
- [ ] Crear sistema de verificación automatizada de disclaimers publicitarios (#ad, #sponsored) en contenidos promocionales [M]
- [ ] Diseñar matriz de verificación de licencias comerciales para tipografías usadas en banners y tráilers [S]
- [ ] Implementar flujo formal de aprobación legal previa para todo material gráfico y audiovisual de marketing [M]
- [ ] Crear formulario digital de consentimiento y cesión de derechos de imagen → KnownIssue no bloqueante DoD: formulario disenado en 03-Diseno.md §3.7; requiere legal draft before use.
- [ ] Diseñar sistema de registro y custodia de bases de datos de participantes en sorteos bajo normativas GDPR/CCPA [M]
- [ ] Implementar checklist de compliance legal específico para la página de la tienda en Steam (Steamworks Guidelines) [S]
- [ ] Crear protocolo de distribución y revocación segura de claves promocionales (Steam keys) con registro de seriales [S]
- [ ] Diseñar calendario y sistema de seguimiento de embargos y acuerdos de confidencialidad con prensa [M]

### Integración
- [ ] Integrar con M100 (Community Management) para validar bases legales de concursos → KnownIssue no bloqueante DoD: integracion documentada en 03-Diseno.md §3.8; M100 existe pero validacion legal pendiente.
- [ ] Integrar con M97 (Steam Store Page) para revisión legal de capturas de pantalla, vídeos y descripciones comerciales [S]
- [ ] Integrar con M41 (Música) para verificar derechos de sincronización de pistas musicales en tráilers y teasers [M]
- [ ] Integrar con M88 (Fuentes Tipográficas) para auditar licencias comerciales de fuentes en material promocional [S]
- [ ] Integrar con M78 (Propiedad Intelectual) para verificar uso correcto de marcas registradas, logos y nombres [M]
- [ ] Integrar con M80 (Privacidad) para el tratamiento y eliminación de correos recolectados en giveaways [S]
- [ ] Integrar con M125 (Términos de Servicio) para asegurar coherencia entre promociones comerciales y el EULA [S]
- [ ] Integrar con M120 (DLC y Expansiones) para la gestión legal de sorteos y promociones de pases o contenidos extra [S]
- [ ] Integrar con M104 (Analytics) para asegurar que el tracking publicitario cuente con consentimiento previo de cookies [M]

### Edge cases
- [ ] Definir protocolo ante influencers que omitan o retiren el disclosure (#ad) tras la publicación remunerada [M]
- [ ] Diseñar procedimiento legal ante reclamos indebidos de Content ID o DMCA en videos promocionales de gameplay [M]
- [ ] Establecer mecanismo de verificación y descalificación ante participantes menores de edad en sorteos internacionales [S]
- [ ] Diseñar plan de contingencia legal ante disputas por marcas similares al nombre "Isla Ancestral" en territorios clave [M]
- [ ] Definir procedimiento de cancelación o reprogramación de giveaways por fuerza mayor o fallos técnicos [S]
- [ ] Establecer protocolo de respuesta ante filtraciones de material publicitario bajo embargo o acuerdos de confidencialidad [M]
- [ ] Diseñar gestión de premios físicos en sorteos hacia países con restricciones aduaneras o aranceles prohibitivos [M]
- [ ] Establecer procedimiento de retirada urgente de material promocional ante revocación imprevista de licencias de terceros [M]

### Optimización
- [ ] Diseñar pipeline de revisión ágil de material publicitario para reducir tiempos de aprobación legal [S]
- [ ] Crear plantillas modulares de contratos parametrizables según el nivel del influencer (micro, mid o macro) [S]
- [ ] Automatizar la validación de requisitos legales y términos en plataformas de giveaways de terceros [M]
- [ ] Centralizar el archivo digital de contratos y licencias de marketing con alertas automáticas de caducidad [M]
- [ ] Estandarizar cláusulas de exención de responsabilidad para campañas de marketing globales [S]
- [ ] Redactar guías de auto-revisión rápida para equipo creativo → KnownIssue no bloqueante DoD: guias disenadas en 03-Diseno.md §3.9 (checklist rapido); implementacion como documento interno.
- [ ] Implementar auditoría trimestral de cumplimiento normativo en publicaciones de redes sociales [S]
- [ ] Optimizar el almacenamiento y cifrado de consentimientos de marketing para facilitar auditorías legales [M]

### Documentación
- [ ] Redactar manual interno de marketing legal y directrices de transparencia publicitaria para el equipo [M]
- [ ] Documentar guía comparativa de normativas publicitarias: FTC (EE.UU.), CAP Code (Reino Unido) y directivas UE [M]
- [ ] Mantener registro histórico exhaustivo de acuerdos, contratos y facturas con agencias de prensa y creadores [S]
- [ ] Publicar bases y condiciones generales de sorteos y promociones en el sitio web oficial del juego [S]
- [ ] Elaborar Brand Guidelines oficiales con pautas de uso de marca y logos para medios de comunicación [M]
- [ ] Redactar protocolo de actuación frente a campañas publicitarias difamatorias o suplantación de identidad [M]
- [ ] Documentar registro de licencias de software de diseño y edición audiovisual utilizado en las campañas [S]
- [ ] Elaborar FAQ legal de marketing para dar respuesta rápida a dudas frecuentes de prensa y streamers [S]

### Polish
- [ ] Redactar bases y condiciones de promociones con lenguaje claro, transparente y accesible sin tecnicismos excesivos [S]
- [ ] Diseñar placas y badges de atribución visualmente integrados y estéticos para tráilers y piezas de video [S]
- [ ] Crear comunicados amigables para creadores de contenido explicando pautas de embargo y buenas prácticas [S]
- [ ] Homogeneizar el estilo visual y tipográfico de todos los anexos y documentos legales de marketing [S]
- [ ] Diseñar banners de avisos legales de promociones alineados con la identidad visual cozy del juego [S]
- [ ] Crear mensajes de confirmación de participación en sorteos con diseño corporativo impecable [S]
- [ ] Revisar el tono de las comunicaciones legales para mantener cercanía y confianza con la comunidad [S]
- [ ] Elaborar kit de prensa digital con lineamientos de uso de marca en formato interactivo y visual [M]
- [ ] Diseñar verificación de disclosure (#ad/#sponsored) en streams multilingües aplicando la normativa del idioma del streamer, no el del juego [S]
- [ ] Diseñar cláusula de confidencialidad específica para beta-testers que compartan material promocional con prensa sin autorización previa [S]
- [ ] Diseñar protocolo de retirada de trailers y material promocional obsoleto para evitar expectativas incumplidas en la comunidad [M]

## Verificación QA Cruzado — Hy3 / Kilo Code (2026-09-02)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Rol:** QA cruzado (AGENTS.md §21.8) — especialidad validación / detección de bugs

### Resultado de tests (headless, Godot 4.7.2-stable)
- godot --headless --path <proyecto> -s res://scripts/legal/test_marketing_legal_m126.gd -> **9 checks, 0 fallos** (exit 0) ✅

### Artefactos verificados
- data/legal/marketing_legal.json — carga y estructura validada por el test.
- scripts/legal/marketing_legal_validator.gd — alidar() y 
eporte() funcionan y detectan datos corruptos.
- scripts/legal/test_marketing_legal_m126.gd — ejecuta sin errores, sin regresiones con M60 (66/0 OK según liberación).

### Hallazgo honesto (brecha de implementación)
El módulo fue liberado como "núcleo iter. 1" con JSON + Validator + Test. **No se implementaron** los autoloads de servicio del plan (MarketingLegalManager/MarketingLegalConfig), el Resource de configuración, ni los documentos .md (legal/126_*.md). El checklist de producto (espec. completa) permanece sin marcar: la capa de validación de datos SÍ existe y está verificada; la capa de servicio/docs NO.

### Veredicto QA
- DoD de la *capa de validación de datos*: **CUMPLIDO** (código existe, compila, tests 0 fallos, sin regresiones).
- Producto completo según plan: **INCOMPLETO** (falta capa de servicio + docs).
- Estado recomendado: **🟡 Con dudas** (scaffold de validación verificado; pendiente capa de servicio/docs).

**Firma:** Hy3 / Kilo Code — 2026-09-02
