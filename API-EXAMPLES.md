# API Endpoints - DIGITRANS-CM

## Variables

```bash
# Définir les variables
set ERP_URL=http://localhost:8081
set CRM_URL=http://localhost:8082
set SC_URL=http://localhost:8083
set BI_URL=http://localhost:8084
set TOKEN=votre_token_jwt_ici
```

---

## 🔐 AUTHENTIFICATION

### Login ERP Service

```bash
curl -X POST %ERP_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"password\"}"
```

### Login CRM Service

```bash
curl -X POST %CRM_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"password\"}"
```

### Login Supply Chain Service

```bash
curl -X POST %SC_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"password\"}"
```

### Login BI Service

```bash
curl -X POST %BI_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"password\"}"
```

---

## 👥 ERP SERVICE - Employees

### Lister tous les employés

```bash
curl -X GET %ERP_URL%/api/employees ^
  -H "Authorization: Bearer %TOKEN%"
```

### Obtenir un employé par ID

```bash
curl -X GET %ERP_URL%/api/employees/1 ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer un employé

```bash
curl -X POST %ERP_URL%/api/employees ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Nkomo\",\"prenom\":\"Jean\",\"role\":\"Manager\",\"departement\":\"Production\"}"
```

```bash
curl -X POST %ERP_URL%/api/employees ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Mbarga\",\"prenom\":\"Marie\",\"role\":\"Comptable\",\"departement\":\"Finance\"}"
```

```bash
curl -X POST %ERP_URL%/api/employees ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Fotso\",\"prenom\":\"Paul\",\"role\":\"Technicien\",\"departement\":\"Logistique\"}"
```

---

## 📦 ERP SERVICE - Suppliers

### Lister tous les fournisseurs

```bash
curl -X GET %ERP_URL%/api/suppliers ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer un fournisseur

```bash
curl -X POST %ERP_URL%/api/suppliers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Agro Supplies Ltd\",\"contact\":\"+237 699 123 456\",\"localisation\":\"Bafoussam\"}"
```

```bash
curl -X POST %ERP_URL%/api/suppliers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Plantations du Noun\",\"contact\":\"+237 677 888 999\",\"localisation\":\"Foumban\"}"
```

```bash
curl -X POST %ERP_URL%/api/suppliers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Cameroun Fruits Export\",\"contact\":\"+237 655 444 333\",\"localisation\":\"Douala\"}"
```

---

## 🤝 CRM SERVICE - Customers

### Lister tous les clients

```bash
curl -X GET %CRM_URL%/api/customers ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer un client

```bash
curl -X POST %CRM_URL%/api/customers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Restaurant SavoirManger Douala\",\"email\":\"douala@savoirmanger.cm\",\"ville\":\"Douala\"}"
```

```bash
curl -X POST %CRM_URL%/api/customers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Restaurant SavoirManger Yaoundé\",\"email\":\"yaounde@savoirmanger.cm\",\"ville\":\"Yaoundé\"}"
```

```bash
curl -X POST %CRM_URL%/api/customers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Restaurant SavoirManger Bafoussam\",\"email\":\"bafoussam@savoirmanger.cm\",\"ville\":\"Bafoussam\"}"
```

```bash
curl -X POST %CRM_URL%/api/customers ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Hôtel Mont Fébé\",\"email\":\"contact@montfebe.cm\",\"ville\":\"Yaoundé\"}"
```

---

## 🛒 CRM SERVICE - Orders

### Lister toutes les commandes

```bash
curl -X GET %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%"
```

### Lister les commandes d'un client

```bash
curl -X GET %CRM_URL%/api/orders/1 ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer une commande

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":1,\"montant\":150000,\"statut\":\"EN_COURS\",\"date\":\"2024-01-15T10:30:00\"}"
```

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":1,\"montant\":85000,\"statut\":\"LIVREE\",\"date\":\"2024-01-10T14:20:00\"}"
```

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":2,\"montant\":200000,\"statut\":\"EN_COURS\",\"date\":\"2024-01-16T09:15:00\"}"
```

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":2,\"montant\":175000,\"statut\":\"LIVREE\",\"date\":\"2024-01-12T11:45:00\"}"
```

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":3,\"montant\":95000,\"statut\":\"EN_COURS\",\"date\":\"2024-01-17T08:30:00\"}"
```

```bash
curl -X POST %CRM_URL%/api/orders ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"customerId\":4,\"montant\":320000,\"statut\":\"LIVREE\",\"date\":\"2024-01-14T16:00:00\"}"
```

---

## 📦 SUPPLY CHAIN SERVICE - Products

### Lister tous les produits (avec cache Redis)

```bash
curl -X GET %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer un produit

```bash
curl -X POST %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Bananes Plantain\",\"categorie\":\"Fruits\",\"quantite\":500}"
```

```bash
curl -X POST %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Manioc\",\"categorie\":\"Tubercules\",\"quantite\":800}"
```

```bash
curl -X POST %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Tomates\",\"categorie\":\"Légumes\",\"quantite\":300}"
```

```bash
curl -X POST %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Ananas\",\"categorie\":\"Fruits\",\"quantite\":250}"
```

```bash
curl -X POST %SC_URL%/api/products ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Maïs\",\"categorie\":\"Céréales\",\"quantite\":1000}"
```

---

## 🚚 SUPPLY CHAIN SERVICE - Shipments

### Lister tous les envois

```bash
curl -X GET %SC_URL%/api/shipments ^
  -H "Authorization: Bearer %TOKEN%"
```

### Créer un envoi

```bash
curl -X POST %SC_URL%/api/shipments ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"productId\":1,\"origine\":\"Plantation Bafoussam\",\"destination\":\"Entrepôt Douala\",\"statut\":\"EN_TRANSIT\",\"date\":\"2024-01-15T08:00:00\"}"
```

```bash
curl -X POST %SC_URL%/api/shipments ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"productId\":2,\"origine\":\"Plantation Foumban\",\"destination\":\"Entrepôt Yaoundé\",\"statut\":\"EN_PREPARATION\",\"date\":\"2024-01-16T07:30:00\"}"
```

```bash
curl -X POST %SC_URL%/api/shipments ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"productId\":3,\"origine\":\"Ferme Dschang\",\"destination\":\"Entrepôt Douala\",\"statut\":\"LIVRE\",\"date\":\"2024-01-14T10:00:00\"}"
```

```bash
curl -X POST %SC_URL%/api/shipments ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"productId\":4,\"origine\":\"Plantation Kribi\",\"destination\":\"Entrepôt Yaoundé\",\"statut\":\"EN_TRANSIT\",\"date\":\"2024-01-15T12:00:00\"}"
```

### Mettre à jour le statut d'un envoi

```bash
curl -X PUT %SC_URL%/api/shipments/1/status ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"status\":\"LIVRE\"}"
```

```bash
curl -X PUT %SC_URL%/api/shipments/2/status ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"status\":\"EN_TRANSIT\"}"
```

---

## 📊 BI SERVICE - Dashboard

### Obtenir le résumé global

```bash
curl -X GET %BI_URL%/api/dashboard/summary ^
  -H "Authorization: Bearer %TOKEN%"
```

**Réponse attendue :**
```json
{
  "totalEmployees": 3,
  "totalCustomers": 4,
  "totalOrders": 6,
  "totalShipments": 4
}
```

### Obtenir les commandes par ville

```bash
curl -X GET %BI_URL%/api/dashboard/orders-by-city ^
  -H "Authorization: Bearer %TOKEN%"
```

**Réponse attendue :**
```json
{
  "ordersByCity": {
    "Douala": 2,
    "Yaoundé": 3,
    "Bafoussam": 1
  }
}
```

---

## 🧪 Script de test complet

Créer un fichier `test-all.bat` :

```batch
@echo off
echo ========================================
echo Test complet DIGITRANS-CM
echo ========================================

echo.
echo 1. Login et récupération du token...
curl -X POST http://localhost:8081/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"password\"}" > token.json

echo.
echo 2. Création d'un employé...
curl -X POST http://localhost:8081/api/employees -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"nom\":\"Test\",\"prenom\":\"User\",\"role\":\"Dev\",\"departement\":\"IT\"}"

echo.
echo 3. Création d'un client...
curl -X POST http://localhost:8082/api/customers -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"nom\":\"Test Restaurant\",\"email\":\"test@test.cm\",\"ville\":\"Douala\"}"

echo.
echo 4. Création d'un produit...
curl -X POST http://localhost:8083/api/products -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"nom\":\"Test Product\",\"categorie\":\"Test\",\"quantite\":100}"

echo.
echo 5. Consultation du dashboard...
curl -X GET http://localhost:8084/api/dashboard/summary -H "Authorization: Bearer %TOKEN%"

echo.
echo ========================================
echo Tests terminés !
echo ========================================
pause
```

---

## 📝 Notes importantes

1. **Token JWT** : Remplacer `%TOKEN%` par le token obtenu via `/api/auth/login`
2. **Expiration** : Le token expire après 24 heures
3. **Cache Redis** : Les produits sont mis en cache pendant 5 minutes
4. **IDs** : Les IDs sont auto-générés, ajuster selon vos données

---

## 🔍 Vérification du cache Redis

```bash
# Se connecter au conteneur Redis
docker exec -it redis redis-cli

# Voir toutes les clés
KEYS *

# Voir le contenu du cache des produits
GET products::all

# Voir le TTL (temps restant)
TTL products::all

# Vider le cache
FLUSHALL
```

---

## 📊 Monitoring des bases de données

```bash
# Se connecter à la base ERP
docker exec -it erp-db psql -U postgres -d erp_db

# Lister les tables
\dt

# Voir les employés
SELECT * FROM employees;

# Voir les fournisseurs
SELECT * FROM suppliers;

# Quitter
\q
```

---

## ✅ Checklist de validation

- [ ] Login retourne un token JWT valide
- [ ] Création d'employés fonctionne
- [ ] Création de fournisseurs fonctionne
- [ ] Création de clients fonctionne
- [ ] Création de commandes fonctionne
- [ ] Création de produits fonctionne
- [ ] Cache Redis fonctionne (2ème appel plus rapide)
- [ ] Création d'envois fonctionne
- [ ] Mise à jour du statut d'envoi fonctionne
- [ ] Dashboard summary retourne les bonnes données
- [ ] Dashboard orders-by-city retourne les bonnes données

---

Tous les endpoints sont maintenant documentés et prêts à être testés ! 🚀
