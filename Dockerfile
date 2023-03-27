# Build step #1: build the React front end
FROM node:18-alpine as build-step
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY ["sys-stats/package.json", "sys-stats/package-lock.json*", "./"]
COPY sys-stats/. .
RUN npm install
RUN npm run build

# Build step #2: build the API with the client as static files
FROM python:3.8-slim-buster
WORKDIR /app
COPY --from=build-step /app/build ./build
#RUN mkdir ./api
COPY api/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
RUN pip3 install psutil flask flask_cors gunicorn

COPY api/. .
#EXPOSE 5000
EXPOSE 3000

#CMD ["python3", "./app.py"]
#WORKDIR /app/api
#CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]


#WORKDIR /app/api
CMD ["gunicorn", "-b", ":3000", "app:app"]