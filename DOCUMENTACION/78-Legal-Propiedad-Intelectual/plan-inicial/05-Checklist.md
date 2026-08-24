**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 78: Legal — Propiedad Intelectual

## A. Problema y objetivos

- [ ] Identificar el problema: múltiples orígenes de activos sin registro en un indie con presupuesto cero [S]
- [ ] Documentar el riesgo de uso indebido de licencias (NC, ND, share-alike) [M]
- [ ] Documentar el riesgo de perder trazabilidad del origen de los activos [S]
- [ ] Documentar el riesgo de atribuciones incompletas en créditos y plataformas [S]
- [ ] Documentar el riesgo de colisión con marcas registradas del rubro videojuegos [M]
- [ ] Documentar el riesgo de conflicto de licencias entre assets integrados [M]
- [ ] Definir el objetivo general: política de propiedad intelectual transparente para presupuesto cero [S]
- [ ] Definir criterios de éxito medibles (inventario completo, atribuciones cumplidas, marca revisada) [S]

## B. RF — Registro de assets

- [ ] RF1: inventario único de activos con nombre, tipo, origen, autor, fuente y licencia [M]
- [ ] RF1: campo de estado por asset (activo / en evaluación / retirado) [S]
- [ ] RF1: fecha de ingreso registrada para cada asset [S]
- [ ] RF1: los assets propios también se registran con autoría y fecha [S]
- [ ] RF2: clasificación por licencia: propio, dominio público, CC0, CC-BY, CC-BY-SA, MIT, permisible comercial [M]
- [ ] RF2: distinción visible entre assets propios y de terceros [S]
- [ ] RF2: registro de assets rechazados con motivo y fecha (trazabilidad) [S]
- [ ] RF3: texto de atribución exacto redactado para cada asset que lo exige [M]
- [ ] RF3: la atribución incluye título, autor, licencia y URL [S]
- [ ] RF3: atribución "No requerida (licencia X)" para assets sin obligación [S]
- [ ] RF4: los créditos en pantalla (M131) consumen las atribuciones del registro [M]
- [ ] RF5: checklist de incorporación con 10 ítems verificables por asset [M]
- [ ] RF5: el checklist frena la integración si la licencia no está documentada [M]
- [ ] RF5: el checklist verifica uso comercial, derivados y compatibilidad [M]
- [ ] RF6: procedimiento de re-verificación de licencias trimestral [M]
- [ ] RF6: re-verificación obligatoria antes de cada build de release [M]
- [ ] RF11: listado inicial de activos propios del proyecto con declaración de autoría [M]
- [ ] RF12: regla de compatibilidad documentada (evitar CC-BY-SA y GPL en contenido integrado) [M]

## C. RF — Atribución y créditos

- [ ] Definir el formato estándar de atribución (título, autor, licencia, URL) [S]
- [ ] Definir dónde se publica la atribución (notices + créditos en juego + página de la tienda) [M]
- [ ] Definir la atribución de tipografías OFL (solo si se redistribuye la fuente) [M]
- [ ] Definir la atribución de addons MIT (conservar aviso en notices) [S]
- [ ] Definir la atribución de audios de Freesound (archivo por archivo, no por sitio) [M]
- [ ] Definir la atribución de packs de itch.io según su EULA particular [M]
- [ ] Definir la atribución de assets OGA según licencia individual del archivo [S]
- [ ] Establecer que ningún asset con atribución obligatoria quede fuera de los créditos del juego [M]
- [ ] Definir que los créditos del juego (M131) muestren las atribuciones antes del primer release [M]
- [ ] Definir el texto de copyright del juego (© 2026 Isla Ancestral — todos los derechos reservados) [S]
- [ ] Definir que terceros conservan sus derechos sobre sus assets [S]
- [ ] Definir la mención de Godot Engine y Voxel Tools en créditos y notices [S]
- [ ] Establecer la regla de copiar el texto oficial de la licencia sin parafrasear [S]
- [ ] Establecer que el aviso de no asesoramiento legal acompaña toda la documentación legal [S]

## D. RF — Revisión de licencias

- [ ] Clasificar las licencias aceptables: CC0, CC-BY, MIT, BSD, Apache, OFL, EULAs comerciales verificadas [M]
- [ ] Clasificar las licencias rechazadas: CC-BY-NC, CC-BY-ND, sin licencia, "uso educativo", robadas [M]
- [ ] Definir la escala de preferencia: propio > CC0 > CC-BY > MIT > CC-BY-SA aislado [M]
- [ ] Documentar el riesgo de contaminación share-alike de CC-BY-SA [C]
- [ ] Definir la regla de aceptación de CC-BY-SA solo aislado y con evaluación [C]
- [ ] Documentar el riesgo de la GPL en contenido integrado al juego [C]
- [ ] Derivar el análisis de GPL/LGPL al módulo M83 (Licencias de Software) [S]
- [ ] Documentar que la licencia de Freesound varía por archivo y debe leerse individualmente [M]
- [ ] Documentar que OGA exige leer la licencia de cada archivo, no la del sitio [M]
- [ ] Documentar la verificación de EULAs de itch.io antes de comprar/descargar [M]
- [ ] Establecer el procedimiento ante licencia revocada o cambiada (RF6) [C]
- [ ] Establecer el procedimiento de retiro de asset ante licencia no verificable [M]
- [ ] Registrar el resultado de la primera revisión de licencias con fecha [M]

## E. RF — Decisiones de marca

- [ ] Definir el procedimiento de búsqueda de colisión para el título "Isla Ancestral" [M]
- [ ] Definir el procedimiento para "Isla Aurora" (isla principal) [M]
- [ ] Definir el procedimiento para nombres de templos, herramientas e islas secundarias [S]
- [ ] Definir las fuentes de búsqueda gratuitas: web, Steam, itch.io, Google Play [S]
- [ ] Definir las bases de marcas gratuitas: USPTO, EUIPO, WIPO, INPI regional [M]
- [ ] Definir el criterio de colisión relevante: mismo rubro (videojuegos) y nombre confusamente similar [C]
- [ ] Definir el criterio de aceptación con registro: riesgo bajo documentado con fecha [S]
- [ ] Definir el registro de decisiones de marca con fecha y resultado de búsqueda [S]
- [ ] Definir la re-revisión de marcas antes del lanzamiento comercial [M]
- [ ] Definir la revisión del logo y nombre antes del primer trailer público [M]
- [ ] Documentar la diferencia entre marca registrada y nombre de juego no registrado [M]
- [ ] Definir que dominios y redes sociales se verifican como indicio de uso activo [S]

## F. Requisitos no funcionales

- [ ] Política aplicable con presupuesto cero (sin abogados obligatorios en fase de desarrollo) [M]
- [ ] Trazabilidad de decisiones: fecha y motivo en cada decisión de licencia/marca [S]
- [ ] Transparencia: documentación legal pública en el repositorio [S]
- [ ] Simplicidad: checklist completable en menos de 10 minutos por asset [M]
- [ ] Mantenibilidad: registro actualizado en el mismo commit de incorporación del asset [M]
- [ ] Lenguaje: documentación legal en español; atribuciones con versión en inglés cuando aplique [S]
- [ ] Versionado: documentos legales bajo control de versiones Git [S]
- [ ] Accesibilidad del registro: tabla consultable por ID, tipo y licencia [S]
- [ ] Descubrimiento: documentos legales ubicados en la raíz del repo, fuera de Assets/ [S]
- [ ] Ausencia de conflicto con la política del proyecto (cero violencia, cozy) [S]
- [ ] Compatibilidad con la decisión de M01 (Godot 4.x + Voxel Tools, GDScript, indie) [S]
- [ ] Alineación con la fecha objetivo: versión release con revisión legal completa [M]

## G. Diseño

- [ ] Diseñar la estructura de archivos legales del módulo [S]
- [ ] Diseñar la tabla de `ASSETS-LICENSE.md` con 11 columnas (ID a Estado) [M]
- [ ] Diseñar el formato de `THIRD-PARTY-NOTICES.md` con texto oficial de cada licencia [M]
- [ ] Diseñar la política de origen de activos (clasificación propio/terceros/dominio público) [M]
- [ ] Diseñar la política anti-plagio redactada y exigible a colaboradores [M]
- [ ] Diseñar los términos de uso del contenido por la comunidad (streaming, fan art, mods) [M]
- [ ] Diseñar el registro de marcas con columnas: nombre, búsquedas, colisión, decisión, revisión [M]
- [ ] Diseñar el flujo de incorporación de assets en 9 pasos [M]
- [ ] Diseñar la regla de atribución "lista para copiar" en créditos del juego [S]
- [ ] Diseñar la regla de assets propios registrados con autoría y fecha [S]
- [ ] Diseñar la regla de conservación de filas retiradas o rechazadas (trazabilidad) [S]
- [ ] Diseñar la integración del registro con M131 (Créditos) [M]
- [ ] Diseñar la integración del checklist con el pipeline 108 (assets) [M]
- [ ] Diseñar las entradas de ejemplo en notices (Godot, Voxel Tools, Nunito, Freesound) [S]
- [ ] Diseñar plantilla de checklist de atribución con 10 ítems numerados [M]
- [ ] Definir el disclaimer de no asesoramiento legal en el diseño [S]

## H. Integración con M01 y pipeline 108

- [ ] Alinear la política legal con los fundamentos del proyecto M01 (indie, cozy, Godot 4.x) [S]
- [ ] Respaldar la decisión de M01 de usar Voxel Tools con su verificación de licencia MIT [M]
- [ ] Respetar la arquitectura de M01: documentación por componentes y versionado Git [S]
- [ ] Extender el pipeline 108: exigir fila en ASSETS-LICENSE.md para integrar un asset [M]
- [ ] Extender el pipeline 108: exigir checklist de atribución completo antes del merge [M]
- [ ] Extender el pipeline 108: exigir entrada en THIRD-PARTY-NOTICES.md [M]
- [ ] Definir que asset sin licencia documentada no entra al proyecto (regla de bloqueo) [M]
- [ ] Definir que el commit de incorporación incluye asset + documentación legal juntos [M]
- [ ] Notificar a M131 (Créditos) cuando un asset exige atribución en pantalla [S]
- [ ] Coordinar con M88 (Fuentes Tipográficas) la verificación OFL de las fuentes del juego [M]
- [ ] Coordinar con M41/M42/M43 (música, ambiente, efectos) la clasificación de audio (M84) [M]
- [ ] Prever el feedback de M127 (Copyright del Juego) y M128 (Identidad de Marca) [S]
- [ ] Mantener M79 (Contratos) como dependiente para acuerdos con colaboradores [S]
- [ ] Mantener M86 (IA Generativa) como dependiente para la declaración de IA en tiendas [S]

## I. Edge cases (casos límite)

- [ ] Asset sin licencia declarada en su página de descarga [C]
- [ ] Asset con licencia revocada por el autor después de integrarse [C]
- [ ] Asset cuyo autor cambió la licencia (ej: de CC-BY a CC-BY-NC) [C]
- [ ] Licencia en idioma distinto sin traducción oficial [M]
- [ ] Atribución solicitada por el autor con texto específico no estándar [M]
- [ ] Asset de terceros dentro de otro asset (dependencia encadenada) [C]
- [ ] Licencia compartida de un pack con assets con licencias distintas entre sí [C]
- [ ] Asset CC-BY-SA mezclado con assets comerciales (contaminación de distribución) [C]
- [ ] Asset de dominio público pero con restricciones de la plataforma de descarga [M]
- [ ] Fuente OFL que requiere redistribución de la fuente (no solo texto renderizado) [M]
- [ ] Créditos en pantalla demasiado largos por muchas atribuciones (UX) [M]
- [ ] Nombre del juego con colisión parcial con marca de otro rubro [C]
- [ ] Colaborador que aporta un asset plagiado sin saberlo [C]
- [ ] Asset modificado por el equipo: ¿se sigue aplicando la licencia original? [C]
- [ ] Actualización de un addon que cambia su licencia entre versiones [C]
- [ ] Asset gratuito que pasa a ser de pago (cambio de términos de distribución) [M]
- [ ] Reventa o redistribución ilegal de los assets del juego por usuarios [M]
- [ ] Requerimiento de atribución en la tienda (Steam/itch.io) además de créditos [M]

## J. Optimización de proceso

- [ ] Plantillas listas para copiar que eliminan la redacción desde cero por asset [M]
- [ ] Atribución "lista para copiar" que elimina re-lectura de licencia para créditos [S]
- [ ] Un solo registro central (sin dispersión de licencias en carpetas) [S]
- [ ] Checklist único reutilizable para todos los tipos de asset [S]
- [ ] Regla de commit único (asset + legal) que evita tareas legales pendientes [M]
- [ ] Búsqueda de marcas agrupada en una sola sesión trimestral [S]
- [ ] Revisión de licencias agrupada por trimestre (lote) en lugar de continua [M]
- [ ] Formularios de menos de 10 minutos por asset (objetivo RN) [M]
- [ ] Script opcional que valida que todos los assets importados tengan fila en el registro [C]
- [ ] Script opcional que verifica que no existan assets NC/ND en el registro de activos [C]

## K. Documentación

- [ ] 01-Requerimientos creado y firmado (problema, objetivos, alcance, RF1-RF12, RN) [S]
- [ ] 02-Analisis creado y firmado (dominio de licencias, alternativas, decisiones clave) [S]
- [ ] 03-Diseno creado y firmado (estructura legal, tablas, política, registro de marcas) [S]
- [ ] 04-Codigo creado y firmado (plantillas, ejemplos, flujo de incorporación, Notas del Agente) [S]
- [ ] 05-Checklist creado y firmado (este archivo, 115+ ítems) [S]
- [ ] Disclaimer de no asesoramiento legal presente en los 5 archivos [S]
- [ ] Referencias cruzadas con M01, M131, M88, M83, M79, M80, M82, M84, M85, M86, M127, M128 [S]
- [ ] Documentación redactada íntegramente en español [S]
- [ ] Mencionar 108 (pipeline de assets) como punto de integración del checklist [S]
- [ ] Dejar el módulo en estado "documentación completa, delegable para implementar" [S]

## L. Testings

- [ ] Test: toda fila de ASSETS-LICENSE.md tiene licencia válida y fecha de ingreso [M]
- [ ] Test: todo asset con atribución obligatoria tiene texto completo (autor, licencia, URL) [M]
- [ ] Test: THIRD-PARTY-NOTICES.md contiene el texto oficial de cada licencia usada [M]
- [ ] Test: el checklist de incorporación bloquea un asset sin licencia documentada [M]
- [ ] Test: el checklist de incorporación bloquea assets NC/ND [M]
- [ ] Test: la escala de preferencia de licencias se aplica en decisiones de muestra (3 casos) [M]
- [ ] Test: el flujo de incorporación cubre asset propio, CC0, CC-BY, MIT y rechazo [M]
- [ ] Test: las entradas de créditos generadas desde el registro son copiables sin edición [M]
- [ ] Test: el registro de marcas tiene fecha de búsqueda y decisión en todos los nombres [M]
- [ ] Test: las revisiones trimestrales de licencias quedan registradas con fecha [S]
- [ ] Test: no existe ningún asset sin fila en el registro (script de validación) [C]
- [ ] Test: el disclaimer de no asesoramiento legal figura en toda la documentación del módulo [S]

---

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode