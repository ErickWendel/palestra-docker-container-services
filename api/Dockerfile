FROM node:8-alpine

ADD . /src

WORKDIR src

ENV PORT=4000

RUN npm i -g typescript --silent

RUN npm install --silent --production

RUN npm run build

CMD npm start

EXPOSE $PORT