BEGIN TRANSACTION;

CREATE TABLE user (
    id             INTEGER PRIMARY KEY,
    username       TEXT    NOT NULL,
    password_hash  TEXT    NOT NULL,
    role           TEXT    NOT NULL DEFAULT 'user',
    is_blocked     INTEGER NOT NULL DEFAULT 0,
    created_at     TEXT    NOT NULL DEFAULT (datetime('now')),

    CONSTRAINT uq_user_username   UNIQUE (username),
    CONSTRAINT ck_user_role       CHECK (role IN ('user', 'admin')),
    CONSTRAINT ck_user_is_blocked CHECK (is_blocked IN (0, 1))
);

CREATE TABLE product (
    id           INTEGER PRIMARY KEY,
    name         TEXT    NOT NULL,
    description  TEXT,
    price_cents  INTEGER NOT NULL,
    stock        INTEGER NOT NULL DEFAULT 0,
    is_available INTEGER NOT NULL DEFAULT 1,
    is_deleted   INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT ck_product_price        CHECK (price_cents >= 0),
    CONSTRAINT ck_product_stock        CHECK (stock >= 0),
    CONSTRAINT ck_product_is_available CHECK (is_available IN (0, 1)),
    CONSTRAINT ck_product_is_deleted   CHECK (is_deleted IN (0, 1))
);

CREATE TABLE menu (
    id           INTEGER PRIMARY KEY,
    name         TEXT    NOT NULL,
    description  TEXT,
    price_cents  INTEGER NOT NULL,
    is_deleted   INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT ck_menu_price      CHECK (price_cents >= 0),
    CONSTRAINT ck_menu_is_deleted CHECK (is_deleted IN (0, 1))
);

CREATE TABLE menu_item (
    menu_id    INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT pk_menu_item          PRIMARY KEY (menu_id, product_id),
    CONSTRAINT fk_menu_item_menu     FOREIGN KEY (menu_id)    REFERENCES menu(id)    ON DELETE CASCADE,
    CONSTRAINT fk_menu_item_product  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT,
    CONSTRAINT ck_menu_item_quantity CHECK (quantity > 0)
);


CREATE TABLE menu_availability (
    id         INTEGER PRIMARY KEY,
    menu_id    INTEGER NOT NULL,
    start_date TEXT    NOT NULL,
    end_date   TEXT    NOT NULL,

    CONSTRAINT fk_menu_availability_menu  FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE CASCADE,
    CONSTRAINT ck_menu_availability_dates CHECK (end_date >= start_date)
);

CREATE TABLE closure_day (
    day    TEXT NOT NULL,
    reason TEXT,

    CONSTRAINT pk_closure_day PRIMARY KEY (day)
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    user_id     INTEGER NOT NULL,
    pickup_date TEXT    NOT NULL,
    status      TEXT    NOT NULL DEFAULT 'pending',
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),

    CONSTRAINT fk_orders_user   FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE RESTRICT,
    CONSTRAINT ck_orders_status CHECK (status IN ('pending', 'picked_up', 'cancelled', 'no_show'))
);

CREATE TABLE order_line (
    id               INTEGER PRIMARY KEY,
    order_id         INTEGER NOT NULL,
    product_id       INTEGER,
    menu_id          INTEGER,
    quantity         INTEGER NOT NULL,
    unit_price_cents INTEGER NOT NULL,

    CONSTRAINT fk_order_line_order    FOREIGN KEY (order_id)   REFERENCES orders(id)  ON DELETE CASCADE,
    CONSTRAINT fk_order_line_product  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_line_menu     FOREIGN KEY (menu_id)    REFERENCES menu(id)    ON DELETE RESTRICT,
    CONSTRAINT ck_order_line_quantity CHECK (quantity > 0),
    CONSTRAINT ck_order_line_price    CHECK (unit_price_cents >= 0),
    CONSTRAINT ck_order_line_one_item CHECK ((product_id IS NULL) <> (menu_id IS NULL))
);

CREATE INDEX idx_menu_item_product          ON menu_item(product_id);
CREATE INDEX idx_menu_availability_menu     ON menu_availability(menu_id);
CREATE INDEX idx_orders_user                ON orders(user_id);
CREATE INDEX idx_orders_pickup_date         ON orders(pickup_date);
CREATE INDEX idx_order_line_order           ON order_line(order_id);
CREATE INDEX idx_order_line_product         ON order_line(product_id);
CREATE INDEX idx_order_line_menu            ON order_line(menu_id);

PRAGMA user_version = 1;

COMMIT;
