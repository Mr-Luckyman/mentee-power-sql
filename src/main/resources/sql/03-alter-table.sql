-- src/main/resources/sql/03-alter-table.sql
-- Расширение структуры таблиц

-- 1. Расширяем таблицу users
ALTER TABLE users
    ADD COLUMN updated_at TIMESTAMP   DEFAULT NOW(),
    ADD COLUMN status     VARCHAR(20) DEFAULT 'active';

-- 2. Добавляем stock_quantity в products
ALTER TABLE products
    ADD COLUMN stock_quantity INTEGER DEFAULT 0;

-- 3. Создаём таблицу order_items
CREATE TABLE order_items
(
    id         BIGSERIAL PRIMARY KEY,
    order_id   BIGINT         NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id BIGINT         NOT NULL REFERENCES products (id),
    quantity   INTEGER        NOT NULL CHECK (quantity > 0),
    price      DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMP DEFAULT NOW()
);