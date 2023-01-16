FROM node:16 AS build
WORKDIR /app
COPY . .

# build and install dependency
RUN npx vite build && yarn install --production && npx prisma generate

# build the final image
FROM node:16
WORKDIR /app

# copy the build and the package.json
COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build

ENV port 3000
CMD [ "node", "build" ]