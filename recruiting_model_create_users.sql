use recruiting_model;

-- Creamos los ususarios Martin y Gabriel en localhost
CREATE USER 'martin'@'localhost' IDENTIFIED BY '12345678';
CREATE USER 'gabriel'@'localhost' IDENTIFIED BY '87654321';


-- Le damos a Martin privilegio para hacer select a las tablas del schema
GRANT SELECT ON recruiting_model.* TO 'martin'@'localhost';


-- Le damos a Gabriel privilegios para hacer select, update e insert a las tablas del schema
GRANT SELECT, UPDATE, INSERT ON recruiting_model.* TO 'gabriel'@'localhost';

-- Flusheamos los privilegios
FLUSH PRIVILEGES;


-- Show martin
SHOW GRANTS FOR 'martin'@'localhost';

-- Show Gabriel
SHOW GRANTS FOR 'gabriel'@'localhost';

-- Limpieza
DROP USER ‘user_name’@‘localhost’;
