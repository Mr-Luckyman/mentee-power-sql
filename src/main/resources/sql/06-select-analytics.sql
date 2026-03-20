-- src/main/resources/sql/06-select-analytics.sql

-- Базовые SELECT запросы
-- 1. Получить всех пользователей, зарегистрированных за последний месяц
SELECT name, email, created_at
FROM users
WHERE created_at >= NOW() - INTERVAL '1 month'
ORDER BY created_at DESC;

-- 2. Найти самые дорогие товары в каждой категории
SELECT category, name, price
FROM products p1
WHERE price = (SELECT MAX(price) FROM products p2 WHERE p2.category = p1.category)
ORDER BY category;

-- 3. Получить топ-5 клиентов по сумме покупок
SELECT u.name, SUM(o.total) AS total_spent
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC
LIMIT 5;

-- Продвинутые SELECT с JOIN
-- 4. Получить информацию о заказах с именами клиентов
SELECT o.id   AS order_id,
       u.name AS customer_name,
       o.total,
       o.status,
       o.order_date
FROM orders o
         JOIN users u ON o.user_id = u.id
ORDER BY o.order_date DESC;

-- 5. Получить детальную информацию о заказах с товарами
SELECT o.id                     AS order_id,
       u.name                   AS customer_name,
       p.name                   AS product_name,
       oi.quantity,
       oi.price,
       (oi.quantity * oi.price) AS item_total,
       o.status,
       o.order_date
FROM orders o
         JOIN users u ON o.user_id = u.id
         JOIN order_items oi ON o.id = oi.order_id
         JOIN products p ON oi.product_id = p.id
ORDER BY o.id, p.name;

-- Аналитические запросы с агрегацией
-- 6. Статистика продаж по категориям товаров
SELECT p.category,
       SUM(oi.quantity)            AS total_items_sold,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
         JOIN products p ON oi.product_id = p.id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 7. Средний чек клиентов
SELECT u.name,
       AVG(o.total) AS avg_order_value,
       SUM(o.total) AS total_spent,
       COUNT(o.id)  AS orders_count
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY avg_order_value DESC;

-- 8. Товары которые ни разу не заказывались
SELECT p.id,
       p.name,
       p.category,
       p.price
FROM products p
         LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.product_id IS NULL;

-- Сложные запросы с подзапросами
-- 9. Клиенты, потратившие больше среднего
SELECT u.name,
       SUM(o.total) AS total_spent
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING SUM(o.total) > (SELECT AVG(total) FROM orders);

-- 10. Самый популярный товар в каждой категории
SELECT category, name, total_orders
FROM (SELECT p.category,
             p.name,
             COUNT(oi.id)                                                           AS total_orders,
             ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY COUNT(oi.id) DESC) AS rn
      FROM products p
               LEFT JOIN order_items oi ON p.id = oi.product_id
      GROUP BY p.id, p.category, p.name) ranked
WHERE rn = 1
ORDER BY category;