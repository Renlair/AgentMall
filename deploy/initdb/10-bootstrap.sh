#!/bin/bash
set -euo pipefail
export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"
mysql --default-character-set=utf8mb4 --protocol=socket -uroot "$MYSQL_DATABASE" <<SQL
INSERT INTO user (id,username,password,name,role,balance)
VALUES (1,'admin','$ADMIN_INITIAL_PASSWORD','管理员','ADMIN',0);
INSERT INTO product_category (id,name,is_enabled,sort) VALUES (1,'部署验证分类',1,1);
INSERT INTO product_brand (id,name,is_enabled,sort) VALUES (1,'部署验证品牌',1,1);
INSERT INTO product (id,product_no,name,category_id,brand_id,price,original_price,stock_quantity,status,create_time,update_time)
VALUES (1,'DEPLOY-CHECK-001','部署验证商品',1,1,1.00,1.00,1,'ON_SALE',NOW(),NOW());
SQL
