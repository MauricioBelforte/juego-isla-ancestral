**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 79: Legal — Contratos

## 1. Archivos involucrados

### 1.1 Plantillas y documentos legales (carpeta `Legal/Contratos/`)
| Archivo | Propósito |
|---------|-----------|
| `Legal/Contratos/plantilla-base.md` | Plantilla de contrato de contribución (sección 1 de 03-Diseno) |
| `Legal/Contratos/anexo-arte.md` | Anexo artistas |
| `Legal/Contratos/anexo-programacion.md` | Anexo programadores |
| `Legal/Contratos/anexo-musica.md` | Anexo músicos/compositores |
| `Legal/Contratos/anexo-diseno.md` | Anexo diseñadores |
| `Legal/Contratos/anexo-escritura.md` | Anexo escritores |
| `Legal/Contratos/anexo-voz.md` | Anexo actores de voz |
| `Legal/Contratos/anexo-freelancer.md` | Anexo freelancers |
| `Legal/Contratos/indice-contratos.md` | Registro de contratos firmados (alimenta M151) |
| `Legal/Contratos/legislacion.md` | Notas de legislación aplicable y foro |

### 1.2 No es código de runtime
- Son documentos/datos de gestión; no requieren scripts Unity.
- Si se digitaliza la firma, se usa un servicio de firma electrónica (as pipe externa).

## 2. Guía de uso (por rol)
| Rol | Plantilla | Anexo | Particularidades |
|-----|-----------|-------|------------------|
| Artista | base | arte | Revisiones múltiples; entregables PNG/psd/FBX |
| Programador | base | programación | Código + documentación; propiedad del código |
| Músico | base | música | Master + royalties opcionales (≤ X%) |
| Compositor | base | música | OST; royalties |
| Diseñador | base | diseño | Niveles/UX; paquete de diseño |
| Escritor | base | escritura | Lore/diálogos; royalties opcionales |
| Actor de voz | base | voz | Uso de la voz; licencia (no cesión de imagen) |
| Freelancer | base | freelancer | Obra puntual; cesión total |
- Firma digital del contrato + anexo por ambas partes.

## 3. Registro (alimenta M151)
```
Legal/Contratos/indice-contratos.md
| Contrato | Rol | Colaborador | Fecha | CESION | Royalty | Abogado | Estado |
```
- El índice se revisa en la auditoría de M151 (cumplimiento de cesión/licencias).

## 4. Proceso de revisión legal (RF12)
- El abogado revisa: plantilla base (cuando se crea), anexos (al crearse) y contratos individuales relevantes (colaboraciones grandes, royalties, obra de terceros).
- Acta de revisión por contrato (¿revisado? ¿fecha? ¿abogado?).

## 5. Tests / QA
| Prueba | Criterio |
|--------|----------|
| Plantillas completas | Las 20 cláusulas del maestro presentes en base + anexo |
| Índice actualizado | Todo contrato firmado en el índice (M151) |
| Distinción comunidad | Colaboraciones comunitarias fuera del marco documentadas |
| IA declarada | Cláusula de IA no declarada (M86) en garantía |

## 6. Notas de integración
- El índice de contratos es insumo directo de M151 (auditoría legal).
- La PI del juego se consolida en M78; el copyright final en M127.
- Los créditos de los colaboradores van a M131, obligatorios por contrato.