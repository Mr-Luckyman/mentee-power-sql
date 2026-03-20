-- src/main/resources/sql/04-migrate-data.sql
-- Преобразуем старые orders в нормализованную структуру

-- Обновляем существующих пользователей (добавляем status и updated_at)
UPDATE users
SET status     = 'active',
    updated_at = created_at
WHERE status IS NULL;

-- Добавляем stock_quantity существующим товарам
UPDATE products
SET stock_quantity = 10
WHERE stock_quantity IS NULL;

-- Создаём order_items из старых данных orders
INSERT INTO order_items (order_id, product_id, quantity, price, created_at)
SELECT id         AS order_id,
       product_id,
       quantity,
       unit_price AS price,
       order_date AS created_at
FROM orders;

-- Удаляем из orders колонки, которые больше не нужны
-- Добавляем колонку total
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS total DECIMAL(10, 2);

-- Обновляем total из order_items
UPDATE orders o
SET total = (SELECT COALESCE(SUM(oi.quantity * oi.price), 0)
             FROM order_items oi
             WHERE oi.order_id = o.id);

-- Удаляем total_price
ALTER TABLE orders DROP COLUMN IF EXISTS total_price;

-- Удаляем quantity, product_id, unit_price
ALTER TABLE orders
    DROP COLUMN IF EXISTS product_id,
    DROP COLUMN IF EXISTS quantity,
    DROP COLUMN IF EXISTS unit_price;