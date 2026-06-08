# Proposal: Restaurant Operations v3

## What

Agregar 10 nuevas features avanzadas al sistema OrderFlow para completar la suite de operaciones de restaurante:

1. **Table Management & Reservations** — Gestión de mesas, estados (free/occupied/reserved), reservas con horarios
2. **Loyalty Tiers** — Sistema de niveles (Bronze/Silver/Gold) con beneficios escalonados y cálculo automático
3. **Order Scheduling** — Pedidos programados para futuro con Oban cron jobs
4. **Split Bill** — Dividir la cuenta entre comensales con múltiples pagos
5. **Customer Feedback v2** — Encuestas post-orden con NPS, comentarios estructurados, análisis de sentimiento
6. **Digital Menu QR** — Generador de QR codes para menú digital con URLs únicas
7. **Kitchen Efficiency Metrics** — Métricas de tiempo de preparación, throughput, bottleneck detection
8. **Gift Cards** — Tarjetas de regalo digitales con códigos únicos, balance y redención
9. **Allergen Detection & Nutritional Info** — Sistema de alergenos en productos, alertas automáticas, info nutricional
10. **Staff Scheduling & Shifts** — Horarios de personal, turnos, disponibilidad, conflictos

## Why

Estas features cubren las operaciones críticas faltantes de un restaurante real:
- **Table Management** es esencial para restaurantes físicos (dine-in)
- **Loyalty Tiers** aumenta retención de clientes (business value real)
- **Order Scheduling** permite pedidos anticipados (planificación de demanda)
- **Split Bill** es el feature #1 solicitado en restaurantes grupales
- **Customer Feedback** cierra el loop de calidad
- **Digital Menu QR** es post-COVID standard
- **Kitchen Efficiency** optimiza operaciones
- **Gift Cards** es revenue stream adicional
- **Allergen Detection** es compliance/legal requirement
- **Staff Scheduling** es HR core para restaurantes

## Impacto
- Incrementa el portfolio a **69+ features**
- Demuestra capacidades avanzadas de: GenServer, Oban scheduling, Ecto complex queries, Phoenix LiveView interactive forms, QR generation, NPS analytics, constraint validation
- Proporciona material rico para el artículo técnico de LinkedIn
