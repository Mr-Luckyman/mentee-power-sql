-- src/main/resources/sql/09-verification.sql

-- Подсчёт количества записей в каждой таблице
SELECT 'users'  as table_name,
       COUNT(*) as record_count
FROM users
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items;

-- 2. Проверка внешних ключей (ссылочная целостность)
-- Заказы без пользователей
SELECT COUNT(*) AS orders_without_users
FROM orders o
         LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Позиции без заказов
SELECT COUNT(*) AS items_without_orders
FROM order_items oi
         LEFT JOIN orders o ON oi.order_id = o.id
WHERE o.id IS NULL;

-- Позиции без товаров
SELECT COUNT(*) AS items_without_products
FROM order_items oi
         LEFT JOIN products p ON oi.product_id = p.id
WHERE p.id IS NULL;

-- 3. Проверка некорректных значений
-- Отрицательные цены
SELECT COUNT(*) AS negative_price_products
FROM products
WHERE price < 0;
SELECT COUNT(*) AS negative_price_items
FROM order_items
WHERE price < 0;

-- Некорректное количество
SELECT COUNT(*) AS invalid_quantity
FROM order_items
WHERE quantity <= 0;

-- Пустые обязательные поля
SELECT COUNT(*) AS null_user_fields
FROM users
WHERE name IS NULL
   OR email IS NULL;
SELECT COUNT(*) AS null_product_fields
FROM products
WHERE name IS NULL
   OR price IS NULL;

-- Некорректные статусы
SELECT COUNT(*) AS invalid_user_status
FROM users
WHERE status NOT IN ('active', 'inactive', 'deleted', 'premium');

SELECT COUNT(*) AS invalid_order_status
FROM orders
WHERE status NOT IN ('PENDING', 'COMPLETED', 'SHIPPED', 'processing', 'pending', 'completed', 'shipped', 'deleted');

-- 4. Проверка вычисляемых данных
-- Сверка total в orders с суммой в order_items
SELECT COUNT(*) AS totals_mismatch
FROM orders o
         LEFT JOIN (SELECT order_id, COALESCE(SUM(quantity * price), 0) AS calculated_total
                    FROM order_items
                    GROUP BY order_id) oi ON o.id = oi.order_id
WHERE ABS(o.total - oi.calculated_total) > 0.01;

-- Отрицательный остаток на складе
SELECT COUNT(*) AS negative_stock
FROM products
WHERE stock_quantity < 0;

-- 5. Детальный отчёт о нарушениях (если есть)
-- Показать все проблемные заказы
SELECT o.id, o.user_id, o.total, COALESCE(oi.calculated_total, 0) AS expected_total
FROM orders o
         LEFT JOIN (SELECT order_id, SUM(quantity * price) AS calculated_total
                    FROM order_items
                    GROUP BY order_id) oi ON o.id = oi.order_id
WHERE ABS(o.total - COALESCE(oi.calculated_total, 0)) > 0.01;