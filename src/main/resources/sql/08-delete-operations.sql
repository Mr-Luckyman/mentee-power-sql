-- src/main/resources/sql/08-delete-operations.sql

-- Безопасные DELETE операции
-- 1. Удалить заказы старше 2 лет
DELETE
FROM orders
WHERE created_at < NOW() - INTERVAL '2 years'
RETURNING id, created_at;

-- 2. Мягкое удаление неактивных пользователей (вместо физического)
--    (чтобы не нарушать внешние ключи)
UPDATE users
SET status = 'deleted',
    updated_at = NOW()
WHERE status = 'inactive'
RETURNING id, name;

-- 3. Удалить товары с нулевой ценой
DELETE FROM products
WHERE price = 0
RETURNING id, name, price;

-- Каскадные удаления
-- 4. Удалить заказ вместе со всеми позициями
-- (должно работать автоматически если настроен CASCADE)
-- Удаляем заказ 13 (Анна Васнецова, статус pending)
DELETE FROM orders
WHERE id = 13
RETURNING id, user_id, status;

-- Мягкие удаления (рекомендуемый подход)
-- 5. Мягкое удаление пользователя
UPDATE users
SET status     = 'deleted',
    updated_at = NOW()
WHERE id = 999;

-- 6. Создать представление для активных пользователей
CREATE VIEW active_users AS
SELECT *
FROM users
WHERE status != 'deleted';

-- 7. Создать представление для удалённых пользователей (для аудита)
CREATE OR REPLACE VIEW deleted_users AS
SELECT
    id,
    name,
    email,
    created_at,
    updated_at,
    status
FROM users
WHERE status = 'deleted';