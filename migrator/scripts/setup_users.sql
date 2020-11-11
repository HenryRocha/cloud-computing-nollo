DROP DATABASE IF EXISTS nollo_prod;
CREATE DATABASE nollo_prod;

DROP DATABASE IF EXISTS nollo_dev;
CREATE DATABASE nollo_dev;

DROP USER IF EXISTS nollo_admin@"%";
CREATE USER nollo_admin@"%" IDENTIFIED BY "nollo_admin_pw";
GRANT ALL ON nollo_prod.* TO nollo_admin@"%";
GRANT ALL ON nollo_dev.* TO nollo_admin@"%";

DROP USER IF EXISTS nollo_api@"%";
CREATE USER nollo_api@"%" IDENTIFIED BY "nollo_api_pw";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_prod.* TO nollo_api@"%";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_dev.* TO nollo_api@"%";

COMMIT
