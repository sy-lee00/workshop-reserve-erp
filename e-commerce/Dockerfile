# 1단계: 프론트엔드(React) 빌드 환경
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# 의존성 파일 복사 및 설치 (ci 명령어로 안전하게 설치)
COPY frontend/package*.json ./
RUN npm ci

# 프론트엔드 소스 복사 및 빌드
COPY frontend/ ./
RUN npm run build

# 2단계: 백엔드(Java Gradle) 빌드 환경
FROM gradle:8-jdk21 AS backend-build
WORKDIR /app/backend

# 프로젝트 전체 소스 복사
COPY . .

# 1단계에서 빌드된 React 결과물(build)을 스프링 부트 정적 자원 폴더(static)로 복사
# Create React App의 기본 빌드 산출물 폴더명은 'build'입니다.
COPY --from=frontend-build /app/frontend/build ./src/main/resources/static/

# Gradle 빌드 수행 (테스트 제외하여 속도 향상)
RUN ./gradlew build -x test --no-daemon

# 3단계: 최종 실행 환경 (가볍고 안전한 Slim 이미지 사용)
FROM eclipse-temurin:21-jre-jammy
EXPOSE 8080

# 빌드된 jar 파일을 실행 파일로 복사
COPY --from=backend-build /app/backend/build/libs/*-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]