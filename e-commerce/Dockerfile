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

# e-commerce 안의 모든 것 복사
COPY . .

# 빌드된 React 결과물을 스프링 부트 정적 자원 폴더로 복사
COPY --from=frontend-build /app/frontend/build ./backend/dia/src/main/resources/static/

# 리눅스 환경에서 gradlew 실행이 가능하도록 권한 부여
WORKDIR /app/backend/backend/dia
RUN chmod +x ./gradlew

# Gradle 빌드 수행
RUN ./gradlew build -x test --no-daemon

# 3단계: 최종 실행 환경
FROM eclipse-temurin:21-jre-jammy
EXPOSE 8080

# 💡 수정: plain 파일을 확실하게 배제하고 원래의 원본 snapshot 파일만 콕 집어서 복사합니다.
COPY --from=backend-build /app/backend/backend/dia/build/libs/*-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]