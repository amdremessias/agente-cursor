# ================================================
# FRONTEND DOCKERFILE - MULTISTAGE OTIMIZADO
# ================================================
FROM node:20-alpine AS deps
WORKDIR /app

COPY package.json bun.lock ./
RUN apk add --no-cache libc6-compat && \
    npm install -g bun && \
    bun install --frozen-lockfile --production=false

# ================================================
# BUILD STAGE
# ================================================
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

RUN npm install -g bun && \
    bun run build

# ================================================
# FINAL IMAGE
# ================================================
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV TZ America/Sao_Paulo

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs && \
    apk add --no-cache tzdata

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
