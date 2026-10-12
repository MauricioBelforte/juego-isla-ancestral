# Dominio web — checklist de registro y mantenimiento

**Módulo:** M99 Marketing (RF2) · **Fuente de diseño:** `DOCUMENTACION/99-Marketing/plan-actual/03-Diseno.md` §2

## 1. Dominio principal

**Dominio elegido:** `islaancestral.com`

Criterio: coincide con el título del juego, es pronunciable en los 6 idiomas objetivo (M87),
sin guiones ni números, `.com` prioritario.

Acción bloqueante: **el registro queda supeditado a la luz verde de marca de M127** — si el
nombre chocara con una marca registrada, el dominio y el logo se cambian juntos.

## 2. Registro

- [ ] Verificar disponibilidad en el registrador (preferencia: Cloudflare/Namecheap por DNS
      rápidos y renovación sencilla).
- [ ] Registrar por **mínimo 2 años** (evita caídas por olvido de renovación en año 1).
- [ ] Confirmar que el registrador permite DNSSEC (integridad del dominio).

## 3. Variantes y reenvíos

Redirecciones 301 hacia el dominio principal:

| Variante | Motivo |
|---|---|
| `islaancestral.net` | Defensiva: typos comunes |
| `islaancestral.org` | Defensiva |
| `islaancestral.com.ar` | Mercado local (Argentina) si la audiencia lo justifica |

Criterio de coste: registrar `.net` y `.org` solo si el dominio principal está libre en ambos;
si alguien los tiene, se monitorea y se valora compra futura, no es bloqueante.

## 4. Correo asociado

- **Correo profesional en el dominio:** `hola@islaancestral.com` (general) y
  `prensa@islaancestral.com` (contacto de prensa dedicado — ver `web-especificaciones.md`).
- Proveedor: redirect gratuito del registrador a Gmail/Proton, o email hosting barato.
- **No usar correo personal** para comunicaciones de prensa: pierde credibilidad.

## 5. Renovación

- [ ] Activar **renovación automática** en el registrador.
- [ ] Registrar un recordatorio de calendario anual **60 días antes** del vencimiento.
- [ ] Mantinar tarjeta de pago vigente en el registrador (causa #1 de caducidad).

## 6. WHOIS

- [ ] Activar **WHOIS privado** (proxy de privacidad del registrador): el domicilio y el
      teléfono personal del desarrollador no son información pública de marketing.
- Verificación: tras activarlo, consultar el WHOIS público y confirmar que no muestra datos
  personales reales.

## 7. Mantenimiento continuo

| Frecuencia | Acción |
|---|---|
| Mensual | Verificar que el certificado HTTPS sigue vigente (renovación automática) |
| Trimestral | Comprobar que las redirecciones 301 siguen funcionando |
| Anual | Renovación del dominio + revisar precio del registrador |

## 8. Dependencias

- **M127**: luz verde de marca (antes de pagar el registro).
- **M126**: texto legal del aviso de privacidad del sitio.
- **M97**: la página de Steam a la que el dominio redirige el CTA principal.
