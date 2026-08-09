FROM node:22-alpine
WORKDIR /app
COPY dist ./dist
RUN mkdir -p /app/data
ENV HOST=0.0.0.0 PORT=3000 DATA_FILE=/app/data/state.json
EXPOSE 3000
CMD ["node","dist/server.js"]
