**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 78: Legal — Propiedad Intelectual

## A. Problema y objetivos

- [x] Identificar el problema: múltiples orígenes de activos sin registro en un indie con presupuesto cero [S]
- [x] Documentar el riesgo de uso indebido de licencias (NC, ND, share-alike) [M]
- [x] Documentar el riesgo de perder trazabilidad del origen de los activos [S]
- [x] Documentar el riesgo de atribuciones incompletas en créditos y plataformas [S]
- [x] Documentar el riesgo de colisión con marcas registradas del rubro videojuegos [M]
- [x] Documentar el riesgo de conflicto de licencias entre assets integrados [M]
- [x] Definir el objetivo general: política de propiedad intelectual transparente para presupuesto cero [S]
- [x] Definir criterios de éxito medibles (inventario completo, atribuciones cumplidas, marca revisada) [S]

## B. RF — Registro de assets

- [x] RF1: inventario único de activos con nombre, tipo, origen, autor, fuente y licencia [M]
- [x] RF1: campo de estado por asset (activo / en evaluación / retirado) [S]
- [x] RF1: fecha de ingreso registrada para cada asset [S]
- [x] RF1: los assets propios también se registran con autoría y fecha [S]
- [x] RF2: clasificación por licencia: propio, dominio público, CC0, CC-BY, CC-BY-SA, MIT, permisible comercial [M]
- [x] RF2: distinción visible entre assets propios y de terceros [S]
- [x] RF2: registro de assets rechazados con motivo y fecha (trazabilidad) [S]
- [x] RF3: texto de atribución exacto redactado para cada asset que lo exige [M]
- [x] RF3: la atribución incluye título, autor, licencia y URL [S]
- [x] RF3: atribución "No requerida (licencia X)" para assets sin obligación [S]
- [x] RF4: los créditos en pantalla (M131) consumen las atribuciones del registro [M]
- [x] RF5: checklist de incorporación con 10 ítems verificables por asset [M]
- [x] RF5: el checklist frena la integración si la licencia no está documentada [M]
- [x] RF5: el checklist verifica uso comercial, derivados y compatibilidad [M]
- [x] RF6: procedimiento de re-verificación de licencias trimestral [M]
- [x] RF6: re-verificación obligatoria antes de cada build de release [M]
- [x] RF11: listado inicial de activos propios del proyecto con declaración de autoría [M]
- [x] RF12: regla de compatibilidad documentada (evitar CC-BY-SA y GPL en contenido integrado) [M]

## C. RF — Atribución y créditos

- [x] Definir el formato estándar de atribución (título, autor, licencia, URL) [S]
- [x] Definir dónde se publica la atribución (notices + créditos en juego + página de la tienda) [M]
- [x] Definir la atribución de tipografías OFL (solo si se redistribuye la fuente) [M]
- [x] Definir la atribución de addons MIT (conservar aviso en notices) [S]
- [x] Definir la atribución de audios de Freesound (archivo por archivo, no por sitio) [M]
- [x] Definir la atribución de packs de itch.io según su EULA particular [M]
- [x] Definir la atribución de assets OGA según licencia individual del archivo [S]
- [x] Establecer que ningún asset con atribución obligatoria quede fuera de los créditos del juego [M]
- [x] Definir que los créditos del juego (M131) muestren las atribuciones antes del primer release [M]
- [x] Definir el texto de copyright del juego (© 2026 Isla Ancestral — todos los derechos reservados) [S]
- [x] Definir que terceros conservan sus derechos sobre sus assets [S]
- [x] Definir la mención de Godot Engine y Voxel Tools en créditos y notices [S]
- [x] Establecer la regla de copiar el texto oficial de la licencia sin parafrasear [S]
- [x] Establecer que el aviso de no asesoramiento legal acompaña toda la documentación legal [S]

## D. RF — Revisión de licencias

- [x] Clasificar las licencias aceptables: CC0, CC-BY, MIT, BSD, Apache, OFL, EULAs comerciales verificadas [M]
- [x] Clasificar las licencias rechazadas: CC-BY-NC, CC-BY-ND, sin licencia, "uso educativo", robadas [M]
- [x] Definir la escala de preferencia: propio > CC0 > CC-BY > MIT > CC-BY-SA aislado [M]
- [x] Documentar el riesgo de contaminación share-alike de CC-BY-SA [C]
- [x] Definir la regla de aceptación de CC-BY-SA solo aislado y con evaluación [C]
- [x] Documentar el riesgo de la GPL en contenido integrado al juego [C]
- [x] Derivar el análisis de GPL/LGPL al módulo M83 (Licencias de Software) [S]
- [x] Documentar que la licencia de Freesound varía por archivo y debe leerse individualmente [M]
- [x] Documentar que OGA exige leer la licencia de cada archivo, no la del sitio [M]
- [x] Documentar la verificación de EULAs de itch.io antes de comprar/descargar [M]
- [x] Establecer el procedimiento ante licencia revocada o cambiada (RF6) [C]
- [x] Establecer el procedimiento de retiro de asset ante licencia no verificable [M]
- [x] Registrar el resultado de la primera revisión de licencias con fecha [M]

## E. RF — Decisiones de marca

- [x] Definir el procedimiento de búsqueda de colisión para el título "Isla Ancestral" [M]
- [x] Definir el procedimiento para "Isla Aurora" (isla principal) [M]
- [x] Definir el procedimiento para nombres de templos, herramientas e islas secundarias [S]
- [x] Definir las fuentes de búsqueda gratuitas: web, Steam, itch.io, Google Play [S]
- [x] Definir las bases de marcas gratuitas: USPTO, EUIPO, WIPO, INPI regional [M]
- [x] Definir el criterio de colisión relevante: mismo rubro (videojuegos) y nombre confusamente similar [C]
- [x] Definir el criterio de aceptación con registro: riesgo bajo documentado con fecha [S]
- [x] Definir el registro de decisiones de marca con fecha y resultado de búsqueda [S]
- [x] Definir la re-revisión de marcas antes del lanzamiento comercial [M]
- [x] Definir la revisión del logo y nombre antes del primer trailer público [M]
- [x] Documentar la diferencia entre marca registrada y nombre de juego no registrado [M]
- [x] Definir que dominios y redes sociales se verifican como indicio de uso activo [S]

## F. Requisitos no funcionales

- [x] Política aplicable con presupuesto cero (sin abogados obligatorios en fase de desarrollo) [M]
- [x] Trazabilidad de decisiones: fecha y motivo en cada decisión de licencia/marca [S]
- [x] Transparencia: documentación legal pública en el repositorio [S]
- [x] Simplicidad: checklist completable en menos de 10 minutos por asset [M]
- [x] Mantenibilidad: registro actualizado en el mismo commit de incorporación del asset [M]
- [x] Lenguaje: documentación legal en español; atribuciones con versión en inglés cuando aplique [S]
- [x] Versionado: documentos legales bajo control de versiones Git [S]
- [x] Accesibilidad del registro: tabla consultable por ID, tipo y licencia [S]
- [x] Descubrimiento: documentos legales ubicados en la raíz del repo, fuera de Assets/ [S]
- [x] Ausencia de conflicto con la política del proyecto (cero violencia, cozy) [S]
- [x] Compatibilidad con la decisión de M01 (Godot 4.x + Voxel Tools, GDScript, indie) [S]
- [x] Alineación con la fecha objetivo: versión release con revisión legal completa [M]

## G. Diseño

- [x] Diseñar la estructura de archivos legales del módulo [S]
- [x] Diseñar la tabla de `ASSETS-LICENSE.md` con 11 columnas (ID a Estado) [M]
- [x] Diseñar el formato de `THIRD-PARTY-NOTICES.md` con texto oficial de cada licencia [M]
- [x] Diseñar la política de origen de activos (clasificación propio/terceros/dominio público) [M]
- [x] Diseñar la política anti-plagio redactada y exigible a colaboradores [M]
- [x] Diseñar los términos de uso del contenido por la comunidad (streaming, fan art, mods) [M]
- [x] Diseñar el registro de marcas con columnas: nombre, búsquedas, colisión, decisión, revisión [M]
- [x] Diseñar el flujo de incorporación de assets en 9 pasos [M]
- [x] Diseñar la regla de atribución "lista para copiar" en créditos del juego [S]
- [x] Diseñar la regla de assets propios registrados con autoría y fecha [S]
- [x] Diseñar la regla de conservación de filas retiradas o rechazadas (trazabilidad) [S]
- [x] Diseñar la integración del registro con M131 (Créditos) [M]
- [x] Diseñar la integración del checklist con el pipeline 108 (assets) [M]
- [x] Diseñar las entradas de ejemplo en notices (Godot, Voxel Tools, Nunito, Freesound) [S]
- [x] Diseñar plantilla de checklist de atribución con 10 ítems numerados [M]
- [x] Definir el disclaimer de no asesoramiento legal en el diseño [S]

## H. Integración con M01 y pipeline 108

- [x] Alinear la política legal con los fundamentos del proyecto M01 (indie, cozy, Godot 4.x) [S]
- [x] Respaldar la decisión de M01 de usar Voxel Tools con su verificación de licencia MIT [M]
- [x] Respetar la arquitectura de M01: documentación por componentes y versionado Git [S]
- [x] Extender el pipeline 108: exigir fila en ASSETS-LICENSE.md para integrar un asset [M]
- [x] Extender el pipeline 108: exigir checklist de atribución completo antes del merge [M]
- [x] Extender el pipeline 108: exigir entrada en THIRD-PARTY-NOTICES.md [M]
- [x] Definir que asset sin licencia documentada no entra al proyecto (regla de bloqueo) [M]
- [x] Definir que el commit de incorporación incluye asset + documentación legal juntos [M]
- [x] Notificar a M131 (Créditos) cuando un asset exige atribución en pantalla [S]
- [x] Coordinar con M88 (Fuentes Tipográficas) la verificación OFL de las fuentes del juego [M]
- [x] Coordinar con M41/M42/M43 (música, ambiente, efectos) la clasificación de audio (M84) [M]
- [x] Prever el feedback de M127 (Copyright del Juego) y M128 (Identidad de Marca) [S]
- [x] Mantener M79 (Contratos) como dependiente para acuerdos con colaboradores [S]
- [x] Mantener M86 (IA Generativa) como dependiente para la declaración de IA en tiendas [S]

## I. Edge cases (casos límite)

- [x] Asset sin licencia declarada en su página de descarga [C]
- [x] Asset con licencia revocada por el autor después de integrarse [C]
- [x] Asset cuyo autor cambió la licencia (ej: de CC-BY a CC-BY-NC) [C]
- [x] Licencia en idioma distinto sin traducción oficial [M]
- [x] Atribución solicitada por el autor con texto específico no estándar [M]
- [x] Asset de terceros dentro de otro asset (dependencia encadenada) [C]
- [x] Licencia compartida de un pack con assets con licencias distintas entre sí [C]
- [x] Asset CC-BY-SA mezclado con assets comerciales (contaminación de distribución) [C]
- [x] Asset de dominio público pero con restricciones de la plataforma de descarga [M]
- [x] Fuente OFL que requiere redistribución de la fuente (no solo texto renderizado) [M]
- [x] Créditos en pantalla demasiado largos por muchas atribuciones (UX) [M]
- [x] Nombre del juego con colisión parcial con marca de otro rubro [C]
- [x] Colaborador que aporta un asset plagiado sin saberlo [C]
- [x] Asset modificado por el equipo: ¿se sigue aplicando la licencia original? [C]
- [x] Actualización de un addon que cambia su licencia entre versiones [C]
- [x] Asset gratuito que pasa a ser de pago (cambio de términos de distribución) [M]
- [x] Reventa o redistribución ilegal de los assets del juego por usuarios [M]
- [x] Requerimiento de atribución en la tienda (Steam/itch.io) además de créditos [M]

## J. Optimización de proceso

- [x] Plantillas listas para copiar que eliminan la redacción desde cero por asset [M]
- [x] Atribución "lista para copiar" que elimina re-lectura de licencia para créditos [S]
- [x] Un solo registro central (sin dispersión de licencias en carpetas) [S]
- [x] Checklist único reutilizable para todos los tipos de asset [S]
- [x] Regla de commit único (asset + legal) que evita tareas legales pendientes [M]
- [x] Búsqueda de marcas agrupada en una sola sesión trimestral [S]
- [x] Revisión de licencias agrupada por trimestre (lote) en lugar de continua [M]
- [x] Formularios de menos de 10 minutos por asset (objetivo RN) [M]
- [x] Script opcional que valida que todos los assets importados tengan fila en el registro [C]
- [x] Script opcional que verifica que no existan assets NC/ND en el registro de activos [C]

## K. Documentación

- [x] 01-Requerimientos creado y firmado (problema, objetivos, alcance, RF1-RF12, RN) [S]
- [x] 02-Analisis creado y firmado (dominio de licencias, alternativas, decisiones clave) [S]
- [x] 03-Diseno creado y firmado (estructura legal, tablas, política, registro de marcas) [S]
- [x] 04-Codigo creado y firmado (plantillas, ejemplos, flujo de incorporación, Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo, 115+ ítems) [S]
- [x] Disclaimer de no asesoramiento legal presente en los 5 archivos [S]
- [x] Referencias cruzadas con M01, M131, M88, M83, M79, M80, M82, M84, M85, M86, M127, M128 [S]
- [x] Documentación redactada íntegramente en español [S]
- [x] Mencionar 108 (pipeline de assets) como punto de integración del checklist [S]
- [x] Dejar el módulo en estado "documentación completa, delegable para implementar" [S]

## L. Testings

- [x] Test: toda fila de ASSETS-LICENSE.md tiene licencia válida y fecha de ingreso [M]
- [x] Test: todo asset con atribución obligatoria tiene texto completo (autor, licencia, URL) [M]
- [x] Test: THIRD-PARTY-NOTICES.md contiene el texto oficial de cada licencia usada [M]
- [x] Test: el checklist de incorporación bloquea un asset sin licencia documentada [M]
- [x] Test: el checklist de incorporación bloquea assets NC/ND [M]
- [x] Test: la escala de preferencia de licencias se aplica en decisiones de muestra (3 casos) [M]
- [x] Test: el flujo de incorporación cubre asset propio, CC0, CC-BY, MIT y rechazo [M]
- [x] Test: las entradas de créditos generadas desde el registro son copiables sin edición [M]
- [x] Test: el registro de marcas tiene fecha de búsqueda y decisión en todos los nombres [M]
- [x] Test: las revisiones trimestrales de licencias quedan registradas con fecha [S]
- [x] Test: no existe ningún asset sin fila en el registro (script de validación) [C]
- [x] Test: el disclaimer de no asesoramiento legal figura en toda la documentación del módulo [S]

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode