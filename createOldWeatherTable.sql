DROP TABLE IF EXISTS weather_processed_t;

CREATE TABLE weather_processed_t
(
    i          VARCHAR(16),
    name       VARCHAR(255),
    lat        DECIMAL(9, 6),
    lon        DECIMAL(9, 6),
    country    VARCHAR(100),
    continent  VARCHAR(100),
    elevation  DECIMAL(9, 2),
    daykey     DATE,
    hourkey    DECIMAL(4, 1),
    metric     VARCHAR(16),
    `value`    VARCHAR(255),
    `year`     SMALLINT,
    `month`    VARCHAR(2),
    `day`      VARCHAR(2),
    dt         DATE
) ENGINE=InnoDB
  DEFAULT CHARACTER SET=utf8mb4;
