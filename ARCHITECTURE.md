# Architecture DIGITRANS-CM

## Vue d'ensemble

DIGITRANS-CM est un système d'information distribué basé sur une architecture microservices pour AGROCAM S.A., une entreprise agroalimentaire camerounaise.

## Diagramme d'architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client / Browser                         │
│                    (Swagger UI / Postman / App)                  │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ HTTP/REST + JWT
             │
┌────────────┴────────────────────────────────────────────────────┐
│                      API Gateway (Future)                        │
└────┬────────────┬────────────┬────────────┬─────────────────────┘
     │            │            │            │
     │            │            │            │
┌────▼─────┐ ┌───▼──────┐ ┌──▼───────┐ ┌──▼──────┐
│   ERP    │ │   CRM    │ │  Supply  │ │   BI    │
│ Service  │ │ Service  │ │  Chain   │ │ Service │
│  :8081   │ │  :8082   │ │ Service  │ │  :8084  │
│          │ │          │ │  :8083   │ │         │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬────┘
     │            │            │            │
     │            │            │            │ Agrège
     │            │            │            │ données
     │            │            │            └────────┐
     │            │            │                     │
┌────▼─────┐ ┌───▼──────┐ ┌──▼───────┐         WebClient
│   ERP    │ │   CRM    │ │ Supply   │              │
│    DB    │ │    DB    │ │ Chain DB │              │
│ :5432    │ │ :5433    │ │  :5434   │              │
└──────────┘ └──────────┘ └────┬─────┘              │
                                │                    │
                           ┌────▼─────┐              │
                           │  Redis   │◄─────────────┘
                           │  Cache   │
                           │  :6379   │
                           └──────────┘
```

## Microservices

### 1. ERP Service (Port 8081)

**Responsabilité** : Gestion des ressources humaines et des approvisionnements

**Entités** :
- `Employee` : Employés de l'entreprise
- `Supplier` : Fournisseurs

**Endpoints** :
- `GET/POST /api/employees`
- `GET /api/employees/{id}`
- `GET/POST /api/suppliers`

**Base de données** : PostgreSQL `erp_db` (port 5432)

**Technologies** :
- Spring Boot 3.2
- Spring Data JPA
- Spring Security + JWT
- PostgreSQL

---

### 2. CRM Service (Port 8082)

**Responsabilité** : Gestion de la relation client pour les restaurants SavoirManger

**Entités** :
- `Customer` : Clients (restaurants)
- `Order` : Commandes

**Endpoints** :
- `GET/POST /api/customers`
- `GET/POST /api/orders`
- `GET /api/orders/{customerId}`

**Base de données** : PostgreSQL `crm_db` (port 5433)

**Technologies** :
- Spring Boot 3.2
- Spring Data JPA
- Spring Security + JWT
- PostgreSQL

---

### 3. Supply Chain Service (Port 8083)

**Responsabilité** : Suivi des marchandises entre plantations et points de vente

**Entités** :
- `Product` : Produits agricoles
- `Shipment` : Envois/Livraisons

**Endpoints** :
- `GET/POST /api/products` (avec cache Redis)
- `GET/POST /api/shipments`
- `PUT /api/shipments/{id}/status`

**Base de données** : PostgreSQL `supplychain_db` (port 5434)

**Cache** : Redis (port 6379)
- Cache sur `GET /api/products`
- TTL : 5 minutes
- Clé : `products::all`

**Technologies** :
- Spring Boot 3.2
- Spring Data JPA
- Spring Security + JWT
- Spring Data Redis
- Spring Cache
- PostgreSQL
- Redis

---

### 4. BI Service (Port 8084)

**Responsabilité** : Tableaux de bord analytiques pour les dirigeants

**Pas d'entité propre** : Ce service agrège les données des 3 autres services

**Endpoints** :
- `GET /api/dashboard/summary` : Résumé global (total employees, customers, orders, shipments)
- `GET /api/dashboard/orders-by-city` : Répartition des commandes par ville

**Communication inter-services** : WebClient (Spring WebFlux)

**Technologies** :
- Spring Boot 3.2
- Spring WebFlux (WebClient)
- Spring Security + JWT

---

## Sécurité

### JWT (JSON Web Token)

**Configuration** :
- Secret partagé : `digitrans-secret-key-for-jwt-token-generation-2024-agrocam-sa`
- Expiration : 24 heures (86400000 ms)
- Algorithme : HS256

**Flux d'authentification** :

```
1. Client → POST /api/auth/login {username, password}
2. Service → Génère JWT token
3. Service → Retourne {token: "eyJhbGc..."}
4. Client → Stocke le token
5. Client → Envoie le token dans header "Authorization: Bearer <token>"
6. Service → Valide le token via JwtAuthenticationFilter
7. Service → Autorise l'accès aux ressources
```

**Endpoints publics** :
- `/api/auth/**`
- `/swagger-ui/**`
- `/api-docs/**`
- `/v3/api-docs/**`

**Endpoints protégés** : Tous les autres

---

## Cache Redis

### Configuration

**Service** : Supply Chain Service uniquement

**Stratégie** :
- Annotation : `@Cacheable(value = "products", key = "'all'")`
- TTL : 5 minutes (300 secondes)
- Sérialisation : JSON (GenericJackson2JsonRedisSerializer)

**Bénéfices** :
- Réduction de la charge sur la base de données
- Amélioration des performances de lecture
- Réponse plus rapide pour les requêtes fréquentes

---

## Base de données

### Stratégie de base de données par service

Chaque microservice possède sa propre base de données PostgreSQL :

| Service       | Base de données  | Port  |
|---------------|------------------|-------|
| ERP           | erp_db           | 5432  |
| CRM           | crm_db           | 5433  |
| Supply Chain  | supplychain_db   | 5434  |
| BI            | Aucune (agrège)  | -     |

**Avantages** :
- Isolation des données
- Scalabilité indépendante
- Pas de couplage entre services
- Choix technologique flexible par service

**Configuration JPA** :
- `spring.jpa.hibernate.ddl-auto=update` : Création automatique des tables
- `spring.jpa.show-sql=true` : Logs SQL pour le développement

---

## Documentation API

### Swagger/OpenAPI 3

**Configuration** : Springdoc OpenAPI 3

**URLs** :
- ERP : http://localhost:8081/swagger-ui.html
- CRM : http://localhost:8082/swagger-ui.html
- Supply Chain : http://localhost:8083/swagger-ui.html
- BI : http://localhost:8084/swagger-ui.html

**Fonctionnalités** :
- Documentation interactive
- Test des endpoints directement depuis l'interface
- Schémas des modèles de données
- Exemples de requêtes/réponses

---

## Communication inter-services

### BI Service → Autres Services

**Technologie** : Spring WebFlux WebClient

**Flux** :
```
BI Service
    │
    ├─→ WebClient.get(erp-service/api/employees) + JWT
    ├─→ WebClient.get(crm-service/api/customers) + JWT
    ├─→ WebClient.get(crm-service/api/orders) + JWT
    └─→ WebClient.get(supplychain-service/api/shipments) + JWT
    │
    └─→ Agrégation des données
    └─→ Retour au client
```

**Propagation du JWT** :
Le BI Service propage le token JWT reçu du client vers les autres services pour maintenir le contexte de sécurité.

---

## Déploiement

### Docker Compose

**Services déployés** :
- 4 microservices (ERP, CRM, Supply Chain, BI)
- 3 bases PostgreSQL
- 1 instance Redis

**Réseau** : `digitrans-network` (bridge)

**Volumes persistants** :
- `erp-data`
- `crm-data`
- `supplychain-data`

**Variables d'environnement** :
- URLs de base de données
- Configuration Redis
- URLs inter-services

---

## Évolutions futures

### Phase 2 - API Gateway

- Centralisation des appels API
- Load balancing
- Rate limiting
- Authentification centralisée

### Phase 3 - Service Discovery

- Eureka Server
- Enregistrement dynamique des services
- Health checks

### Phase 4 - Configuration centralisée

- Spring Cloud Config Server
- Gestion centralisée des configurations
- Refresh dynamique

### Phase 5 - Monitoring & Observabilité

- Spring Boot Actuator
- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Distributed tracing (Zipkin/Jaeger)

### Phase 6 - Message Broker

- RabbitMQ ou Kafka
- Communication asynchrone
- Event-driven architecture

---

## Bonnes pratiques appliquées

✅ **Séparation des responsabilités** : Chaque service a un domaine métier clair

✅ **Base de données par service** : Isolation et indépendance

✅ **API RESTful** : Standards HTTP, codes de statut appropriés

✅ **Sécurité JWT** : Authentification stateless

✅ **Documentation API** : Swagger pour tous les services

✅ **Cache** : Optimisation des performances avec Redis

✅ **Containerisation** : Docker pour le déploiement

✅ **Configuration externalisée** : application.properties

✅ **Lombok** : Réduction du boilerplate code

✅ **Gestion des dépendances** : Maven multi-modules

---

## Contraintes et limitations

⚠️ **Pas de gestion des transactions distribuées** : Chaque service gère ses propres transactions

⚠️ **Pas de circuit breaker** : Pas de gestion de la résilience (Hystrix/Resilience4j)

⚠️ **Authentification simplifiée** : Pas de vérification réelle des credentials (MVP)

⚠️ **Pas de versioning d'API** : Pas de gestion des versions d'API

⚠️ **Pas de pagination** : Les endpoints retournent toutes les données

⚠️ **Pas de validation métier avancée** : Validation basique uniquement

---

## Conclusion

DIGITRANS-CM est un MVP fonctionnel démontrant une architecture microservices moderne avec Spring Boot 3, PostgreSQL, Redis, et Docker. Le projet est prêt pour une démonstration universitaire et peut être étendu avec les évolutions proposées.
