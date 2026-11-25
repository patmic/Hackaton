# Imagen base del proyecto epnHackaton.
# motion se instala desde package.json/package-lock.json con npm ci,
# así queda dentro de la imagen y no depende de node_modules del equipo.
FROM node:22-alpine

WORKDIR /app

# Primero solo los manifiestos, para aprovechar la caché de capas
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Después el resto del código (node_modules se excluye en .dockerignore)
COPY . .

# Comprobación: motion debe resolverse dentro de la imagen
RUN node -e "require('motion'); console.log('motion OK')" || node --input-type=module -e "await import('motion'); console.log('motion OK')"

CMD ["node", "--input-type=module", "-e", "await import('motion'); console.log('motion disponible en el contenedor')"]
