SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'routes';

SELECT *
FROM trips
LIMIT 10;

SELECT *
FROM routes
LIMIT 10;

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('trips', 'loads', 'routes')
ORDER BY table_name, ordinal_position;

SELECT *
FROM loads
LIMIT 5;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'loads';