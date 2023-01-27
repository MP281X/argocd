FROM node:18-alpine AS build
WORKDIR /app
COPY . .

RUN npx vite build && rm -r ./node_modules \
    && yarn install --production

FROM node:18-alpine
WORKDIR /app

COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build

ENV port 3000
CMD [ "node", "build" ]
