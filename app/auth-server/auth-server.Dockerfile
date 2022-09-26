FROM node:16-alpine AS build
WORKDIR /app
COPY . .

# build and install dependency
RUN yarn install && npx tsc \
    && rm -r ./node_modules \
    && yarn install --production 

# build the final image
FROM node:16-alpine
WORKDIR /app

# copy the build and the package.json 
COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build

ENV port 3000
CMD [ "node", "build/app.js" ]