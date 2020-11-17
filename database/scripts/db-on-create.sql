DROP DATABASE IF EXISTS nollo_prod;
CREATE DATABASE nollo_prod;

DROP DATABASE IF EXISTS nollo_dev;
CREATE DATABASE nollo_dev;

DROP USER IF EXISTS nollo_admin@"%";
CREATE USER nollo_admin@"%" IDENTIFIED BY "NOLLO_DB_ADMIN_PW_PLACEHOLDER";
GRANT ALL ON nollo_prod.* TO nollo_admin@"%";
GRANT ALL ON nollo_dev.* TO nollo_admin@"%";

DROP USER IF EXISTS nollo_api@"%";
CREATE USER nollo_api@"%" IDENTIFIED BY "NOLLO_DB_API_PW_PLACEHOLDER";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_prod.* TO nollo_api@"%";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_dev.* TO nollo_api@"%";

COMMIT;

USE nollo_dev;
DROP TABLE IF EXISTS todos;

CREATE TABLE todos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(120),
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO todos VALUES (1, "Harcoded Todo 1", "This todo was created with the database.", "1999-01-01 06:30:00");
INSERT INTO todos VALUES (2, "Harcoded Todo 2", "This todo was created with the database.", "2000-04-14 06:30:00");

COMMIT;
