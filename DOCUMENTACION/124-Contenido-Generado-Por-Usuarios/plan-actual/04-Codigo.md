**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 124: Contenido Generado por Usuarios

## 1. Archivos involucrados (proyección post-V2)

### 1.1 Nuevos
| Archivo | Propósito |
|---------|-----------|
| `Assets/_Project/Scripts/Online/UgcManager.cs` | Publicar/listar/descargar ítems UGC |
| `Assets/_Project/Scripts/Online/UgcItem.cs` | Modelo: foto (url) o blueprint (data) |
| `Assets/_Project/Scripts/Moderacion/ModerationPipeline.cs` | Hash → IA → cola humana |
| `Assets/_Project/Scripts/Moderacion/Apelaciones.cs` | Flujo de apelación |
| `Assets/_Project/Scripts/UI/GaleriaView.cs` | Galería pública (M89 views) |
| `Assets/_Project/Scripts/UI/CompartirView.cs` | Confirmación de licencia al compartir |
| `services/ugc/` (backend) | API de subida/descarga/moderación (lógica separada) |
| `services/ugc/db.sql` | Esquemas: items, moderación, reportes, backups |

### 1.2 Modificados (proyección)
| Archivo | Cambio (V2) |
|---------|-------------|
| `CameraManager` (M56) | Botón "Compartir" (alias + licencia) |
| `BuildPlans` (M18) | Exportar blueprint a UGC |
| `ComunidadManager` (M100) | Reportes conectados a la cola de moderación |
| Telemetría (M104) | Eventos: publicar/ver/descargar/reportar |
| `TOS` (M125) | Cláusula UGC insertada |

## 2. Funciones clave
```csharp
// UgcManager
public string PublicarFoto(Texture2D foto, string titulo); // 2K + licencia
public string PublicarBlueprint(BlueprintData bp, bool diseno);
public List<UgcItem> ListarGaleria(string tag, int pagina);
public void DescargarBlueprint(string id);  // + validación M109
public void ReportarItem(string id, Categoria cat, string motivo);
public void EliminarItem(string id);        // derecho al olvido
// ModerationPipeline
public static Veredicto Evaluar(UgcItem item);  // hash → heurística → IA → cola
public static void Apelar(string itemId, string razon);
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Ítems UGC | `items` (fotos CDN + blueprints bucket) | servicio |
| Moderación | `mod_*` tablas + audit log | M103 |
| Límites por usuario | `limits` en metadata | RF13 |
| Presupuesto de almacenamiento | Infra config (presupuesto mensual) | F5 |
| Claves de apikey del servicio | Keystore (M106) | Seguridad |

## 4. Tests (M112 — proyección V2)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `UgcManagerTests` | PlayMode (mock backend) | Publicar/listar/descargar |
| `ModerationPipelineTests` | EditMode | Hash blacklist + umbrales IA |
| `ReportFlowTests` | PlayMode | Reporte → cola → remoción |
| `EliminationTests` | PlayMode | Derecho al olvido ≤ 30 días |
| `LimitsTests` | EditMode | 200 ítems / 50 al día / pesos |

## 5. CI / gates
- `ugc_check` en CI: valida formatos (2K, JSON comprimido) y límites por usuario (simulado).
- Los reportes de moderación alimentan un dashboard (M104).
- Backup de la tabla `items` diario (RPO 24 h) verificado semanal.

## 6. Notas de integración
- El backend de UGC es separado del juego (área de servicio, no Unity) y usa la política de M80 (región/data).
- Fotos vienen de M56 (ya existen) y blueprints de M18.
- El UGC se integra con el #showcase de Discord (M100) de forma opcional (compartir enlace).