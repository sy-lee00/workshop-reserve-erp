# 1단계: 프론트엔드(React) 빌드 환경
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

COPY ./frontend/package*.json ./
RUN npm ci

COPY ./frontend/ ./
RUN npm run build

# 2단계: 백엔드(Java Gradle) 빌드 환경
FROM gradle:8-jdk21 AS backend-build
WORKDIR /app/backend

# e-commerce 안의 모든 것(backend, frontend 등)을 복사
COPY . .

# 1단계에서 빌드된 React 결과물(build)을 스프링 부트 정적 자원 폴더(static)로 복사
# gradlew가 backend/dia 안에 있으므로, 리소스 경로는 backend/dia/src/... 로 들어갑니다.
COPY --from=frontend-build /app/frontend/build ./backend/dia/src/main/resources/static/

# 💡 수정: gradlew 파일이 있는 backend/dia 폴더 안으로 정확히 진입합니다.
WORKDIR /app/backend/backend/dia
RUN ./gradlew build -x test --no-daemon

# 3단계: 최종 실행 환경
FROM eclipse-temurin:21-jre-jammy
EXPOSE 8080

# 💡 수정: backend/dia 내부에서 빌드된 jar 파일을 최종 실행 이미지로 복사합니다.
COPY --from=backend-build /app/backend/backend/dia/build/libs/*-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]