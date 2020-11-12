FROM node:14-alpine

WORKDIR /usr/src/app

COPY package*.json ./
COPY postcss.config.js ./
COPY rollup.config.js ./
COPY tailwind.config.js ./
COPY ./src ./src
COPY ./public ./public

RUN npm install

EXPOSE 5000

ARG API_URL
ENV API_URL=$API_URL
ENV HOST=0.0.0.0

RUN npm run build

CMD [ "npm", "start"]