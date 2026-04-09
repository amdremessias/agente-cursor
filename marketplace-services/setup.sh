#!/bin/bash
set -e

# ==============================================
# MARKETPLACE DE SERVIÇOS - SETUP AUTOMATIZADO
# ==============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}
╔════════════════════════════════════════════════════╗
║        MARKETPLACE DE SERVIÇOS - SETUP            ║
╚════════════════════════════════════════════════════╝
${NC}"

echo -e "\n${GREEN}▶️  Criando diretórios de dados persistentes...${NC}"
sudo mkdir -p /opt/marketplace/{postgres,redis}
sudo chown -R 1001:1001 /opt/marketplace/

echo -e "\n${GREEN}▶️  Copiando arquivo de ambiente...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Arquivo .env criado. Edite as credenciais antes de continuar!${NC}"
fi

echo -e "\n${GREEN}▶️  Construindo imagens Docker...${NC}"
docker compose build --pull

echo -e "\n${GREEN}▶️  Subindo banco de dados...${NC}"
docker compose up -d db redis
sleep 15

echo -e "\n${GREEN}▶️  Verificando status dos serviços...${NC}"
docker compose ps

echo -e "\n${GREEN}✅ Setup inicial concluído!${NC}"
echo -e "\n📌 Próximos passos:"
echo "   1. Edite o arquivo .env com suas credenciais"
echo "   2. Execute: docker compose up -d"
echo "   3. Acesse: https://marketplace.internal.lab"
echo -e "\n🔍 Comandos de debug:"
echo "   docker compose logs -f backend"
echo "   docker compose exec db psql -U marketplace"
echo "   docker compose exec redis redis-cli ping"
