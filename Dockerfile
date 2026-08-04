FROM node:20-alpine

WORKDIR /aplicativo

# Copiar el archivo package.json y package-lock.json
COPY package*.json ./

# Instalar las dependencias
RUN npm install

# Copiar el archivo .env con el puerto configurado
COPY env/development.env ./env/

# Copiar el resto del código fuente
COPY dist ./dist

# Exponer el puerto
EXPOSE 3001

# Comando para iniciar la aplicación
CMD ["node", "/aplicativo/dist/index.js"]
