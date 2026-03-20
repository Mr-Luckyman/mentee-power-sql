-- src/main/resources/sql/02-test-data.sql
-- Тестовые данные для изучения SQL

-- Добавляем 5 новых пользователей
INSERT INTO users (name, email, status, updated_at)
VALUES ('Ольга Новикова', 'olga.novikova@example.com', 'active', NOW()),
       ('Сергей Морозов', 'sergey.morozov@example.com', 'active', NOW()),
       ('Анна Васнецова', 'anna.vasnetsova@example.com', 'inactive', NOW()),
       ('Павел Григорьев', 'pavel.grigoriev@example.com', 'active', NOW()),
       ('Татьяна Кузнецова', 'tatiana.kuznetsova@example.com', 'active', NOW());

-- Добавляем 7 новых товаров
INSERT INTO products (name, price, category, stock_quantity, description)
VALUES ('Монитор Dell U2723QE', 45990.00, 'Электроника', 7, '4K IPS, USB-C'),
       ('Клавиатура Keychron K2', 8990.00, 'Электроника', 15, 'Mechanical, Bluetooth'),
       ('Книга "Spring в действии"', 3200.00, 'Книги', 45, '6-е издание'),
       ('SSD Samsung 1TB', 8990.00, 'Электроника', 30, 'NVMe PCIe 4.0'),
       ('Наушники Sony WH-1000XM4', 21990.00, 'Электроника', 12, 'Noise Cancelling'),
       ('Кресло офисное', 18990.00, 'FURNITURE', 6, 'Эргономичное'),
       ('Книга "Микросервисы на Spring"', 3500.00, 'Книги', 20, '3-е издание');

-- Создаём 5 новых заказов
INSERT INTO orders (user_id, status, order_date)
VALUES (6, 'COMPLETED', NOW() - INTERVAL '2 days'),
       (7, 'PROCESSING', NOW() - INTERVAL '1 day'),
       (8, 'PENDING', NOW()),
       (9, 'SHIPPED', NOW() - INTERVAL '3 days'),
       (10, 'COMPLETED', NOW() - INTERVAL '4 days');

-- Добавляем товары в новые заказы (order_items)

-- Заказ 11 (Ольга, user_id=6) — монитор + клавиатура
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (11, 9, 1, 45990.00),
       (11, 10, 1, 8990.00);

-- Заказ 12 (Сергей, user_id=7) — SSD + книга Spring
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (12, 12, 2, 8990.00),
       (12, 11, 1, 3200.00);

-- Заказ 13 (Анна, user_id=8) — наушники
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (13, 13, 1, 21990.00);

-- Заказ 14 (Павел, user_id=9) — кресло + книга Микросервисы
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (14, 14, 1, 18990.00),
       (14, 15, 1, 3500.00);

-- Заказ 15 (Татьяна, user_id=10) — монитор + книга Spring
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (15, 9, 1, 45990.00),
       (15, 11, 1, 3200.00);

-- Обновляем total для всех заказов (старых и новых)
UPDATE orders o
SET total = (
    SELECT COALESCE(SUM(oi.quantity * oi.price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.id
);