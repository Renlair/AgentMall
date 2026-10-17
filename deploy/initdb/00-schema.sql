SET NAMES utf8mb4;
CREATE TABLE `after_sale_rule`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `rule_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则名称',
  `rule_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则类型',
  `category_id` int NULL DEFAULT NULL COMMENT '适用分类ID',
  `apply_scene` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '适用场景',
  `condition_text` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '适用条件',
  `process_text` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '处理流程',
  `time_limit` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '处理时效',
  `contact_channel` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系渠道',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_after_sale_rule_type`(`rule_type` ASC) USING BTREE,
  INDEX `idx_after_sale_rule_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_after_sale_rule_enabled`(`is_enabled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '售后规则表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `agent_run`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `run_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '运行编号',
  `task_id` int NULL DEFAULT NULL COMMENT '关联导购任务ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `run_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'SHOPPING_GUIDE' COMMENT '运行类型：SHOPPING_GUIDE导购',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'RUNNING' COMMENT '运行状态：RUNNING运行中，DONE已完成，FAILED失败',
  `input_snapshot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '输入快照',
  `output_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '输出摘要',
  `error_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '失败原因',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `duration_ms` bigint NULL DEFAULT 0 COMMENT '耗时，单位毫秒',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_agent_run_no`(`run_no` ASC) USING BTREE,
  INDEX `idx_agent_run_task`(`task_id` ASC) USING BTREE,
  INDEX `idx_agent_run_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_agent_run_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Agent运行记录表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `agent_step`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `run_id` int NOT NULL COMMENT '所属Agent Run运行记录ID',
  `step_order` int NULL DEFAULT NULL COMMENT '步骤顺序',
  `step_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '步骤编码',
  `step_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '步骤名称',
  `tool_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具编码，多个工具用逗号分隔',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '步骤状态：RUNNING、DONE、FAILED',
  `input_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '步骤输入内容',
  `output_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '步骤输出内容',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '失败原因',
  `start_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结束时间',
  `duration_ms` bigint NULL DEFAULT NULL COMMENT '步骤耗时，单位毫秒',
  `create_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_step_run`(`run_id` ASC) USING BTREE,
  INDEX `idx_agent_step_code`(`step_code` ASC) USING BTREE,
  INDEX `idx_agent_step_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Agent执行步骤表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `ai_model_config`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `provider` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型供应商',
  `model_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型名称',
  `model_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'CHAT' COMMENT '模型类型：CHAT对话，EMBEDDING向量',
  `base_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口地址',
  `api_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口密钥',
  `temperature` decimal(3, 2) NULL DEFAULT 0.70 COMMENT '温度参数',
  `max_tokens` int NULL DEFAULT 2048 COMMENT '最大输出Token数',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用途说明',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI模型配置表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `function_tool`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tool_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工具编码',
  `tool_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工具名称',
  `tool_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工具类型：商品、库存、订单、用户、售后',
  `invoke_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调用类型',
  `service_bean` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '实现该工具的Spring Bean名称',
  `service_method` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '实现该工具的方法名',
  `input_schema` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '入参JSON Schema',
  `output_schema` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '出参JSON Schema',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用：0停用，1启用',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_function_tool_code`(`tool_code` ASC) USING BTREE,
  INDEX `idx_function_tool_type`(`tool_type` ASC) USING BTREE,
  INDEX `idx_function_tool_enabled`(`is_enabled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Function Calling工具中心表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `product_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品编号',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称',
  `category_id` int NOT NULL COMMENT '分类ID',
  `brand_id` int NOT NULL COMMENT '品牌ID',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品封面',
  `album_images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '商品相册',
  `price` decimal(10, 2) NOT NULL COMMENT '售价',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价',
  `stock_quantity` int NULL DEFAULT 0 COMMENT '库存数量',
  `selling_point` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品卖点',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品标签',
  `is_recommend` tinyint NULL DEFAULT 0 COMMENT '是否首页推荐',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ON_SALE' COMMENT '商品状态',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_product_no`(`product_no` ASC) USING BTREE,
  INDEX `idx_product_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_product_brand_id`(`brand_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_brand`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '品牌名称',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌Logo',
  `official_site` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '官网地址',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌介绍',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品品牌表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_category`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类说明',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品分类表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_detail`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `detail_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品详情',
  `package_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '包装清单',
  `after_sale_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '售后说明',
  `ai_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI摘要',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_product_detail_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品详情表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_favorite`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_favorite_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE,
  INDEX `idx_favorite_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品收藏表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_knowledge`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '知识ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `knowledge_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识类型',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识内容',
  `source_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MANUAL' COMMENT '来源类型',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_product_knowledge_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_product_knowledge_type`(`knowledge_type` ASC) USING BTREE,
  INDEX `idx_product_knowledge_enabled`(`is_enabled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品知识库表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_knowledge_chunk`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '切片ID',
  `knowledge_id` int NOT NULL COMMENT '知识ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `knowledge_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识类型',
  `chunk_no` int NOT NULL COMMENT '切片序号',
  `chunk_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '切片标题',
  `chunk_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '切片内容',
  `character_count` int NULL DEFAULT 0 COMMENT '字符数',
  `chunk_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'READY' COMMENT '切片状态',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_knowledge_chunk_knowledge`(`knowledge_id` ASC) USING BTREE,
  INDEX `idx_knowledge_chunk_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_knowledge_chunk_type`(`knowledge_type` ASC) USING BTREE,
  INDEX `idx_knowledge_chunk_status`(`chunk_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品知识切片表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_knowledge_embedding`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '向量ID',
  `chunk_id` int NOT NULL COMMENT '切片ID',
  `knowledge_id` int NOT NULL COMMENT '知识ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `embedding_model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '向量模型',
  `vector_dimension` int NOT NULL COMMENT '向量维度',
  `vector_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '向量文本',
  `embedding_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'READY' COMMENT '向量状态',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_embedding_chunk`(`chunk_id` ASC) USING BTREE,
  INDEX `idx_embedding_knowledge`(`knowledge_id` ASC) USING BTREE,
  INDEX `idx_embedding_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_embedding_status`(`embedding_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品知识向量表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_param`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `param_group` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数分组',
  `param_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数名称',
  `param_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数值',
  `sort` int NULL DEFAULT 1 COMMENT '排序',
  `is_core` tinyint NULL DEFAULT 0 COMMENT '是否核心参数',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_product_param_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品参数表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `product_review`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `order_id` int NOT NULL COMMENT '订单ID',
  `order_item_id` int NOT NULL COMMENT '订单明细ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `rating` int NOT NULL COMMENT '评分',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评价内容',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价图片',
  `audit_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'APPROVED' COMMENT '审核状态',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_review_order_item`(`order_item_id` ASC) USING BTREE,
  INDEX `idx_review_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_review_product_id`(`product_id` ASC) USING BTREE,
  INDEX `idx_review_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品评价表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `prompt_template`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `template_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模板编码',
  `template_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模板名称',
  `business_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `system_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '系统提示词',
  `user_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户提示词',
  `output_format` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '输出格式',
  `is_enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用途说明',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_prompt_template_code`(`template_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Prompt模板表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shop_order`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `user_id` int NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `total_quantity` int NOT NULL COMMENT '商品总件数',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单状态',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人',
  `receiver_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货地址',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `ship_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_shop_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_shop_order_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_shop_order_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商城订单表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shop_order_item`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` int NOT NULL COMMENT '订单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `product_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品编号',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品封面',
  `price` decimal(10, 2) NOT NULL COMMENT '成交单价',
  `quantity` int NOT NULL COMMENT '购买数量',
  `subtotal_amount` decimal(10, 2) NOT NULL COMMENT '明细小计',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_item_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_order_item_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商城订单明细表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_cart`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` int NULL DEFAULT 1 COMMENT '购买数量',
  `selected` tinyint NULL DEFAULT 1 COMMENT '是否选中：0否，1是',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_cart_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE,
  INDEX `idx_cart_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '购物车表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_growth_report`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `report_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '报告编号',
  `report_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '报告标题',
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'OVERALL' COMMENT '报告类型：OVERALL综合，GUIDE导购增长，PRODUCT商品运营',
  `order_count` int NULL DEFAULT 0 COMMENT '有效订单数',
  `sales_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '销售额',
  `guide_task_count` int NULL DEFAULT 0 COMMENT '导购任务数',
  `guide_done_count` int NULL DEFAULT 0 COMMENT '导购完成数',
  `recommendation_count` int NULL DEFAULT 0 COMMENT '推荐记录数',
  `qa_count` int NULL DEFAULT 0 COMMENT '问答记录数',
  `review_analysis_count` int NULL DEFAULT 0 COMMENT '评价分析数',
  `conversion_rate` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '导购转化率（百分比）',
  `top_product_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'Top商品摘要',
  `qa_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '问答摘要',
  `review_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '评价摘要',
  `growth_suggestion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '增长建议',
  `data_snapshot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '数据快照',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'DONE' COMMENT '状态：DONE已完成，FAILED失败',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_growth_report_no`(`report_no` ASC) USING BTREE,
  INDEX `idx_growth_report_type`(`report_type` ASC) USING BTREE,
  INDEX `idx_growth_report_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI运营增长报告表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_guide_task`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务编号',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `demand_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '购物需求',
  `budget_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '预算金额',
  `product_id` int NULL DEFAULT NULL COMMENT '基准商品ID，用于相似商品召回',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'WAITING' COMMENT '任务状态：WAITING待执行，DONE已完成，FAILED执行失败',
  `matched_product_ids` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '匹配到的推荐商品ID，逗号分隔',
  `recommendation_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '推荐结果文本',
  `execute_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '执行结果说明',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `execute_time` datetime NULL DEFAULT NULL COMMENT '执行时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_shopping_guide_task_no`(`task_no` ASC) USING BTREE,
  INDEX `idx_shopping_guide_task_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_shopping_guide_task_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_shopping_guide_task_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能导购任务表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_qa`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `qa_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问答编号',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `question_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问题类型：PRODUCT商品知识，PRICE_STOCK价格库存，ORDER订单状态，AFTER_SALE售后咨询',
  `question_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '问题内容',
  `product_id` int NULL DEFAULT NULL COMMENT '关联商品ID',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联商品名称',
  `order_id` int NULL DEFAULT NULL COMMENT '关联订单ID',
  `order_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联订单编号',
  `answer_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '回答内容',
  `evidence_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '证据内容',
  `tool_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '工具调用链路',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'DONE' COMMENT '状态：DONE已完成，FAILED失败',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_shopping_qa_no`(`qa_no` ASC) USING BTREE,
  INDEX `idx_shopping_qa_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_shopping_qa_type`(`question_type` ASC) USING BTREE,
  INDEX `idx_shopping_qa_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_shopping_qa_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_shopping_qa_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI商品问答表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_recommendation`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` int NOT NULL COMMENT '导购任务ID',
  `run_id` int NULL DEFAULT NULL COMMENT '所属Agent Run运行记录ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '推荐商品ID',
  `product_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品编号快照',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称快照',
  `product_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片快照',
  `price_snapshot` decimal(10, 2) NULL DEFAULT NULL COMMENT '推荐时商品价格快照',
  `original_price_snapshot` decimal(10, 2) NULL DEFAULT NULL COMMENT '推荐时商品原价快照',
  `discount_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '优惠金额',
  `discount_rate` decimal(10, 2) NULL DEFAULT NULL COMMENT '折扣率',
  `available_quantity` int NULL DEFAULT NULL COMMENT '推荐时的商品库存',
  `recommend_rank` int NULL DEFAULT NULL COMMENT '推荐排名',
  `recommend_score` int NULL DEFAULT NULL COMMENT '推荐评分',
  `recommend_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '推荐理由',
  `evidence_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '推荐证据摘要',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '状态：VALID有效',
  `create_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_shopping_recommendation_task`(`task_id` ASC) USING BTREE,
  INDEX `idx_shopping_recommendation_run`(`run_id` ASC) USING BTREE,
  INDEX `idx_shopping_recommendation_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_shopping_recommendation_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_shopping_recommendation_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI导购推荐商品结果表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `shopping_review_analysis`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `analysis_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分析编号',
  `product_id` int NOT NULL COMMENT '商品ID',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名称快照',
  `review_count` int NULL DEFAULT 0 COMMENT '评价总数',
  `average_rating` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '平均评分',
  `positive_count` int NULL DEFAULT 0 COMMENT '好评数',
  `neutral_count` int NULL DEFAULT 0 COMMENT '中评数',
  `negative_count` int NULL DEFAULT 0 COMMENT '差评数',
  `positive_rate` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '好评率（百分比）',
  `sentiment_level` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NEUTRAL' COMMENT '情绪等级：POSITIVE正向，NEUTRAL中性，NEGATIVE负向',
  `advantage_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优点摘要',
  `problem_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '问题摘要',
  `keyword_summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关键词摘要',
  `improvement_suggestion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '改进建议',
  `sample_reviews` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '评价样本',
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'DONE' COMMENT '状态：DONE已完成，FAILED失败',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_review_analysis_no`(`analysis_no` ASC) USING BTREE,
  INDEX `idx_review_analysis_product`(`product_id` ASC) USING BTREE,
  INDEX `idx_review_analysis_sentiment`(`sentiment_level` ASC) USING BTREE,
  INDEX `idx_review_analysis_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI商品评价分析表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `user`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电话',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `balance` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '账户余额',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_user_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `user_address`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人',
  `receiver_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货电话',
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '省份',
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市',
  `district` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区县',
  `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '详细地址',
  `postal_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮政编码',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认地址',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_address_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收货地址表' ROW_FORMAT = DYNAMIC;

CREATE TABLE `wallet_record`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流水类型',
  `amount` decimal(10, 2) NOT NULL COMMENT '变动金额',
  `balance_after` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '变动后余额',
  `business_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_wallet_record_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT=1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '钱包流水表' ROW_FORMAT = DYNAMIC;
