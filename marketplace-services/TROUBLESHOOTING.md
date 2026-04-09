# ==============================================
# DEBUG E TROUBLESHOOTING - DEPLOY
# ==============================================

## ❌ ERROS MAIS COMUNS NO PRIMEIRO DEPLOY

### 1. ERRO: Permissão negada nos volumes
```
ERROR: for marketplace_db  Cannot start service db: error while creating mount source path '/opt/marketplace/postgres': mkdir /opt/marketplace: permission denied
```

✅ **SOLUÇÃO**:
```bash
sudo mkdir -p /opt/marketplace/{postgres,redis,nginx}
sudo chmod 777 /opt/marketplace -R
# OU melhor:
sudo chown 999:999 /opt/marketplace/postgres
sudo chown 999:999 /opt/marketplace/redis
```

---

### 2. ERRO: PostGIS não carrega
```
function st_distance does not exist
```

✅ **SOLUÇÃO**:
Execute manualmente as extensões:
```bash
docker compose exec db psql -U marketplace -d marketplace -c "CREATE EXTENSION IF NOT EXISTS postgis; CREATE EXTENSION IF NOT EXISTS postgis_topology;"
```

---

### 3. ERRO: Backend não conecta no banco
```
Error: connect ECONNREFUSED db:5432
```

✅ **SOLUÇÃO**:
1. Aumente o `healthcheck` timeout no docker-compose:
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER"]
  interval: 5s
  timeout: 10s
  retries: 10
  start_period: 30s
```

2. Adicione dependência com condição:
```yaml
depends_on:
  db:
    condition: service_healthy
  redis:
    condition: service_healthy
```

---

### 4. ERRO: Nginx retorna 502 Bad Gateway

✅ **SOLUÇÃO**:
Verifique se os containers estão na mesma rede:
```bash
docker network inspect marketplace_internal
```

Verifique se o frontend está ouvindo em 0.0.0.0:
Adicione no `next.config.js`:
```javascript
module.exports = {
  output: 'standalone',
  experimental: {
    serverActions: true,
  },
  server: {
    host: '0.0.0.0',
    port: 3000
  }
}
```

---

## 🛠️ COMANDOS DE DEBUG

### Ver todos os logs ao mesmo tempo:
```bash
docker compose logs -f --tail=50
```

### Logs individuais:
```bash
# Banco de dados
docker compose logs db -f

# Backend
docker compose logs backend -f --since 5m

# Apenas erros:
docker compose logs backend 2>&1 | grep -i error
```

### Verificar conexão entre containers:
```bash
# Testar backend -> db
docker compose exec backend nc -zv db 5432

# Testar backend -> redis
docker compose exec backend nc -zv redis 6379
```

### Reset COMPLETO do ambiente (CUIDADO: APAGA DADOS):
```bash
docker compose down -v
sudo rm -rf /opt/marketplace/*
docker system prune -af
./setup.sh
```

---

## ✅ CHECKLIST ANTES DO DEPLOY
1. 👉 Você editou o arquivo `.env` e alterou TODAS as senhas padrão?
2. 👉 Diretórios `/opt/marketplace/` existem com permissões corretas?
3. 👉 Portas 80 e 443 estão liberadas no firewall?
4. 👉 Não tem nenhum outro serviço usando essas portas?
5. 👉 Você tem pelo menos 4GB de RAM livre?

---

## 📊 Status esperado dos containers
```
NAME                 IMAGE                   STATUS               PORTS
marketplace_db       postgis/postgis:16      Up (healthy)         5432/tcp
marketplace_redis    redis:7.2-alpine        Up (healthy)         6379/tcp
marketplace_backend  marketplace-backend     Up                   3001/tcp
marketplace_frontend marketplace-frontend    Up                   3000/tcp
marketplace_nginx    nginx:1.25-alpine       Up                   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```
