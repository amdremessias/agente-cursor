#!/bin/bash
echo "🔍 Iniciando diagnóstico completo do deploy..."

echo -e "\n1. Verificando arquivos obrigatórios:"
for f in .env docker-compose.yml backend/Dockerfile frontend/Dockerfile; do
  if [ -f "$f" ]; then echo "✅ $f"; else echo "❌ $f FALTANDO"; fi
done

echo -e "\n2. Verificando espaço em disco:"
df -h /opt 2>/dev/null || df -h /

echo -e "\n3. Verificando memória disponível:"
free -h

echo -e "\n4. Comando para deploy passo a passo:"
echo "   docker compose up -d db redis"
echo "   sleep 60"
echo "   docker compose up -d backend frontend"
echo "   sleep 30"
echo "   docker compose up -d nginx"

echo -e "\n5. Logs em tempo real:"
echo "   docker compose logs -f --tail=100"
