-- src/main/resources/sql/07-update-operations.sql

-- Простые UPDATE операции
-- 1. Обновить статус заказа
UPDATE orders
SET status = 'shipped'
WHERE id = 1;

-- 2. Обновить информацию о пользователе с логированием
UPDATE users
SET name       = 'Алексей Петрович Петров',
    updated_at = NOW()
WHERE email = 'alex@example.com'
RETURNING id, name, updated_at;

-- 3. Массовое обновление цен (повышение на 10%)
UPDATE products
SET price = price * 1.1;

-- Сложные UPDATE с подзапросами
-- 4. Обновить статус пользователей на 'premium' для тех, кто потратил > 50000
UPDATE users
SET status = 'premium'
WHERE id IN (SELECT o.user_id
             FROM orders o
             GROUP BY o.user_id
             HAVING SUM(o.total) > 50000);

-- 5. Обновить количество товара на складе после заказа
UPDATE products p
SET stock_quantity = stock_quantity - sub.ordered_quantity
FROM (SELECT product_id, SUM(quantity) AS ordered_quantity
      FROM order_items
      GROUP BY product_id) sub
WHERE p.id = sub.product_id;

-- Условные обновления
-- 6. Установить статус товаров в зависимости от количества на складе
UPDATE products
SET status = CASE
                 WHEN stock_quantity = 0 THEN 'out_of_stock'
                 WHEN stock_quantity < 5 THEN 'low_stock'
                 ELSE 'in_stock'
    END;

-- 7. Обновить общую сумму заказов по товарам
UPDATE orders o
SET total = (
    SELECT COALESCE(SUM(oi.quantity * oi.price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.id
);