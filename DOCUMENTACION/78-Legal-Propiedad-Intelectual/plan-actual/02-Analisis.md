**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 78: Legal — Propiedad Intelectual

> ⚠️ **Aviso legal:** Este análisis es orientativo y NO constituye asesoramiento legal profesional. Los términos aquí descriptos son generales; siempre debe verificarse el texto oficial de cada licencia en su fuente.

---

## 1. Análisis del dominio

### 1.1 El ecosistema de activos de Isla Ancestral

Un juego indie cozy voxel como *Isla Ancestral* consume activos de varios orígenes, cada uno con reglas distintas:

| Origen | Ejemplos típicos | Nivel de riesgo | Particularidad |
|---|---|---|---|
| Assets 100% propios | Código GDScript, modelos voxel propios, texturas propias, música compuesta por el equipo | Bajo | Requiere registrar autoría y decidir bajo qué términos se distribuyen (¿solo el juego, o también el código modeable?) |
| Dominio público | Obras con copyright expirado, colecciones marcadas PD | Bajo | Sin obligación de atribución, pero conviene registrar el origen para trazabilidad |
| CC0 (public domain dedication) | Muchos packs de OGA (Open Game Art), freesound.org | Bajo | Renuncia todos los derechos; no exige atribución aunque es buena práctica darla |
| CC-BY (Creative Commons — Atribución) | Fotos, texturas, música, iconos | Medio | Uso comercial permitido, pero exige atribución visible (autor, obra, licencia, URL) |
| CC-BY-SA (Atribución — Compartir Igual) | Texturas, sets de OGA, mapas | Alto | Exige atribución y, además, el resultado derivado debe publicarse bajo la misma licencia: **puede contaminar toda la distribución del juego** |
| CC-BY-NC (No Comercial) | Arte de fans, packs gratuitos | Alto | Prohibido en un juego comercial: **rechazado automáticamente por este módulo** |
| CC-BY-ND (Sin Derivados) | Música curada | Alto | Prohibido modificarlo: rechazado por completo (un juego voxel siempre modifica/trata el asset) |
| MIT / BSD / Apache | Código de addons, plugins, herramientas | Bajo | Permisivas; exigen conservar el aviso de copyright del autor en la distribución |
| GPL / LGPL | Software, shaders, librerías | Medio-Alto | GPL puede obligar a abrir el código del juego; verificar cada caso con M83 (Licencias de Software) |
| Asset packs comerciales (itch.io, asset stores) | Packs de "low poly", sonidos, tiles | Medio | Cada pack tiene su propia EULA: leer "Commercial use", "Sell assets" y la atribución requerida |
| Freesound | SFX y ambientes | Medio | Las licencias varían por archivo (algunos CC0, otros CC-BY, otros CC-BY-NC): **verificar archivo por archivo** |
| Tipografías libres | Nunito, Fredoka One, Fuente Cósmica | Bajo | OFL o CC-BY; la OFL exige incluir la licencia de la fuente si se distribuye la fuente, no el texto renderizado (ver M88 — Fuentes Tipográficas) |

### 1.2 Atribución vs dominio público

- **Dominio público:** el autor renunció a sus derechos o expiraron. No hay obligación legal de atribuir (aunque algunas plataformas igual lo piden por cortesía).
- **CC0:** contrato equivalente a dominio público con cobertura mundial. Tampoco exige atribución.
- **Atribución obligatoria (CC-BY, CC-BY-SA, MIT, OFL, varias EULAs):** exige reconocer al autor. La forma estándar incluye 4 campos: **título de la obra, autor, licencia y enlace a la obra/licencia**.
- Confusión común: "es gratis, lo uso sin créditos". Prioridad de este módulo: **todo asset de terceros registrado, con atribución cumplida o justificación documentada de por qué no se requiere**.

### 1.3 Compatibilidad entre licencias (riesgo de contaminación)

- Un asset **CC-BY-SA** integrado al juego obliga a distribuir el juego (o la parte derivada) bajo CC-BY-SA. Mezclado con música de un pack comercial con EULA privada, el resultado puede ser **incompatible o imposible de distribuir**.
- Regla del módulo: los assets **CC-BY-SA se aceptan solo si están aislados** (ej: contenido elegible para intercambio bajo esa licencia) o se prefieren alternativas CC0/CC-BY.
- Los assets **CC-BY-NC y CC-BY-ND** se rechazan por defecto (NC = no comercial; ND = no derivados).
- Licencias permisivas de código (MIT, BSD, Apache) conviven sin problema y solo exigen conservar los avisos en `THIRD-PARTY-NOTICES.md`.

### 1.4 Riesgos de marca

- **Colisión de nombre:** "Isla Ancestral" y "Isla Aurora" podrían estar registrados por terceros (títulos de juegos, marcas comerciales, editoriales). Un juego con el mismo nombre de una marca vigente puede recibir cese y desistimiento (cease & desist) o reclamo en las tiendas.
- **Mecánicas y nombres propios:** nombres de templos, islas o herramientas poco comunes tienen bajo riesgo, pero el nombre principal y el logo son los críticos.
- **Búsquedas gratuitas aplicables (presupuesto cero):**
  - Búsqueda web del nombre del juego + "game" + "Steam"/"it.io" (qué juegos existen hoy).
  - Búsqueda en tiendas (Steam, itch.io, Google Play, App Store).
  - Marcas registradas: USPTO (EE.UU.), EUIPO (UE), INPI (AR/regional), WIPO Global Brand Database — gratuitos en línea.
  - Búsqueda de dominios y redes sociales (indicio de reclamos comerciales activos).
- **Regla de decisión:** si existe un juego o marca comercial **del mismo rubro (videojuegos)** con nombre idéntico o confusamente similar, se documenta el conflicto y se elige alternativa con fecha; si existe solo en rubros ajenos, se documenta el análisis de bajo riesgo.

### 1.5 Marco legal aplicable (orientativo)

- **Copyright:** surge con la creación de la obra (Convenio de Berna); no se necesita registro para existir, aunque registrarlo (ej: en EE.UU., Copyright Office) facilita reclamar daños. Para un indie v1, el registro optativo se documenta como decisión.
- **Marcas:** en la mayoría de países, registro ante la oficina correspondiente (costoso para presupuesto cero en esta fase; se prioriza la verificación de colisión).
- **Licencias Creative Commons y software libre:** son contratos de licencia válidos; violar la atribución es violar la licencia (riesgo de reclamo de retiro de obra).
- **UNLESS la fundación contrate asesoría:** este módulo declara explícitamente que sus documentos son buenas prácticas, no opinión legal.

---

## 2. Alternativas consideradas

| # | Alternativa | Análisis | Decisión |
|---|---|---|---|
| 1 | No documentar nada y "ver después" | Riesgo altísimo: sin registro no hay forma de cumplir atribuciones ni rastrear licencias revocadas | Descartada |
| 2 | Contratar abogado especializado | Costo incompatible con presupuesto cero en esta fase del desarrollo | Descartada para la fase actual; se recomienda revisión puntual antes del lanzamiento comercial |
| 3 | Registro online tipo "legal kit" de tiendas | Útil en el lanzamiento (Steamworks legales), pero sobre la marcha no cubre el proceso interno | Se adopta como referencia futura, no como base |
| 4 | Documentos dispersos entre archivos del proyecto | Sin estructura se pierden; cada asset lleva su licencia en una carpeta distinta | Descartada |
| 5 | Registro centralizado en `THIRD-PARTY-NOTICES.md` + `ASSETS-LICENSE.md` en la raíz del repo | Un solo lugar público y versionable; plantillas simples; filtrable | **Adoptada** |
| 6 | Checklist manual de atribución pegada al pipeline 108 | Fuerza la verificación en el punto exacto de incorporación | **Adoptada** |
| 7 | Bloquear todo asset externo y crear 100% contenido propio | Ideal pero irreal para el alcance (música, fuentes, placeholders de prototipo) | Descartada como regla general; sí se prioriza contenido propio en lo jugable |
| 8 | Usar solo assets CC0 | Atractivo por simplicidad, pero limita catálogo útil (mucho buen contenido en OGA es CC-BY/CC-BY-SA) | Adoptada como **preferencia**, no como obligación |

## 3. Decisiones clave

1. **Registro centralizado dual:** un único archivo `ASSETS-LICENSE.md` (tabla funcional de activos) y un `THIRD-PARTY-NOTICES.md` (aviso legal consolidado, formato estándar usado por Godot/Steam). Orden: los terceros en el "notices"; todo lo demás en la tabla.

2. **Preferencia de licencias:** `propio > dominio público/CC0 > CC-BY > MIT/permisivas > CC-BY-SA (aislado) > rechazado (CC-BY-NC, CC-BY-ND, sin licencia, "stolen")`. Esta escala guía cada incorporación del pipeline 108.

3. **Atribución obligatoria estandarizada:** formato de 4 campos (título, autor, licencia, URL) en *créditos del juego* (M131) y en los notices; el registro guarda la atribución exacta lista para copiar.

4. **Regla de compatibilidad:** el juego se distribuye bajo licencia cerrada (todos los derechos reservados por el fundador) excepto lo que las licencias de terceros obliguen a liberar; por eso se evitan CC-BY-SA y GPL en contenido integrado.

5. **Registro de decisiones de marca:** se archiva con fecha el resultado de la búsqueda de colisiones; si no hay conflicto relevante, se declara "decisión: continuar con el nombre, revisar antes de release".

6. **Checklist pegada al pipeline 108:** un asset no entra al proyecto si la fila de atribución no existe en el commit de incorporación (revisión en la misma PR/commit).

7. **Política anti-plagio escrita y exigible:** se documenta y se exige a colaboradores; el plagio o el uso de arte sin licencia es motivo de retiro del asset y del colaborador.

8. **Disclaimer permanente:** toda documentación legal del módulo incluye el aviso de "no constituye asesoramiento legal profesional".

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode