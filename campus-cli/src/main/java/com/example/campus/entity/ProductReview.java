package com.example.campus.entity;

import java.time.LocalDateTime;

/** 每笔已完成订单最多一条买家评价。hidden 仅控制公开展示，保留审计信息。 */
public record ProductReview(long id, long orderId, long productId, long buyerId,
                            int rating, String content, boolean hidden,
                            LocalDateTime createdAt) implements Identified {
    public ProductReview hide() {
        return new ProductReview(id, orderId, productId, buyerId, rating, content, true, createdAt);
    }
}
