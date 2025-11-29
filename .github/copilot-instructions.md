This repository is a Spring Boot web application (Java 17) with Thymeleaf front-end templates, an H2 in-memory database for local/dev, and SMTP email integration. The instructions below focus on patterns, build/run workflows, and repository-specific conventions that help an AI coding agent be productive quickly.

**Quick Commands**
- **Build:** `./mvnw -B clean package`
- **Run (dev):** `./mvnw spring-boot:run` (bash) or `mvnw.cmd spring-boot:run` on Windows CMD
- **Run packaged JAR:** `java -jar target/*.jar --server.port=8087`
- **Run tests:** `./mvnw test`
- **Docker:** build after packaging: `docker build -t geomvp .` then `docker run -p 8087:8087 geomvp`
- **CI (GitHub Actions):** workflow runs `mvn -B clean verify` and `mvn -B clean package` (see `.github/workflows/config_sonar_cicd.yml`).

**Where to look first (entry points & patterns)**
- **Application entry:** `src/main/java/com/spring/bioMedical/BioMedicalApplication.java` (`@SpringBootApplication`).
- **Controllers:** `src/main/java/com/spring/bioMedical/Controller` — note the package name uses a capitalized `Controller` directory (non-standard).
- **Services & repos:** `src/main/java/com/spring/bioMedical/service` and `.../repository` follow typical Spring `@Service` / `@Repository` usage. Repositories are JDBC/JPA-backed and annotated with `@Repository("name")`.
- **Templates & static assets:** `src/main/resources/templates` (Thymeleaf) and `src/main/resources/static` (CSS/JS/images). Templates are used directly by controllers (look for view names like `index`, `login`, etc.).

**Runtime & config notes (important when changing behavior)**
- **Database:** default local/dev uses H2 in-memory: `spring.datasource.url=jdbc:h2:mem:userauth` and the H2 console is exposed at `/h2` (`spring.h2.console.path=/h2`). Data/schema are applied from `src/main/resources/schema.sql` and `data.sql` (spring.sql.init.mode=always). Note: schema uses a quoted table name `"USER"` — case-sensitive in H2 and important when writing SQL or JPA mappings.
- **Security:** `src/main/java/com/spring/bioMedical/config/SecurityConfiguration.java` uses JDBC-backed `UserDetailsService` with custom queries and a no-op password encoder `PasswordEnconderTest` (plain-text passwords). URL rules: `/admin/**` -> `ROLE_ADMIN`, `/user/**` -> `ROLE_USER`. Public paths: `/register`, `/confirm`, `/login/**`, `/css/**`, `/js/**`, `/static/**`, `/vendor/**`, `/resources/**`.
- **Email:** SMTP config lives in `src/main/resources/application.properties` (currently contains in-repo credentials). Treat these as secrets when changing CI/deploy. Prefer using environment variables or GitHub secrets for CI.
- **Thymeleaf:** configured with `spring.thymeleaf.mode=LEGACYHTML5` and caching disabled in dev (`spring.thymeleaf.cache=false`).

**Conventions and gotchas**
- Package naming: controllers are in `Controller` (capital C). Search must account for this exact path.
- Password handling is plain-text by design here (see `PasswordEnconderTest`). Do not assume BCrypt unless intentionally refactoring tests/security flows.
- SQL schema uses uppercase quoted table name `"USER"` — JPA mappings or native queries must match exactly.
- Static resource patterns are whitelisted in security config and also ignored by `WebSecurityCustomizer` — add new public assets to the same paths to avoid auth blocks.
- The app initializes H2 with `schema.sql` / `data.sql` — changes to those files will re-seed the DB on every start when using the current `application.properties` settings.

**Important files to inspect while editing features**
- `pom.xml` — Java 17, Spring Boot parent, dependencies (JPA, Thymeleaf, Security, H2)
- `Dockerfile` — expects `target/*.jar` (build jar before docker build)
- `src/main/resources/application.properties` — ports, mail, datasource, logging
- `src/main/resources/schema.sql` and `data.sql` — DB schema and seed data
- `src/main/resources/templates` and `static` — front-end views/assets
- `.github/workflows/config_sonar_cicd.yml` — CI steps and Maven commands used in CI

**When creating patches or PRs**
- Run `./mvnw -B clean package` locally; verify the app starts (`./mvnw spring-boot:run`) and login flows (H2 data seeded). Use `--server.port` override if port collision occurs.
- If changing authentication/encoding, update or provide migration steps for existing seeded data and tests (they rely on plain-text passwords).
- For Docker/CI, ensure the jar is produced as `target/*.jar` before building images or uploading artifacts.

If any section is unclear or you want more detail (example controller walkthrough, common test failures, or how to run with a MySQL datasource), tell me which area to expand and I will iterate.
