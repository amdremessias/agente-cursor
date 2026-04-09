# ================================================
# BACKEND DOCKERFILE - MULTISTAGE OTIMIZADO
# ================================================
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json bun.lockb ./
RUN apk add --no-cache libc6-compat python3 make g++ && \
    npm install -g bun && \
    bun install --frozen-lockfile --production=false

# ================================================
# BUILD STAGE
# ================================================
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm install -g bun && \
    bun run build && \
    bun install --production --ignore-scripts --prefer-offline

# ================================================
# FINAL IMAGE
# ================================================
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV TZ America/Sao_Paulo

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 backend && \
    apk add --no-cache tzdata postgresql-client

COPY --from=builder --chown=backend:nodejs /app/dist ./dist
COPY --from=builder --chown=backend:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=backend:nodejs /app/package.json ./
COPY --from=builder --chown=backend:nodejs /app/prisma ./prisma

USER backend

EXPOSE 3001

CMD ["node", "dist/main.js"]
