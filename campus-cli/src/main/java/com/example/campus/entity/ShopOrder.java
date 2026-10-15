package com.example.campus.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 保存下单时的名称和价格快照，后续商品操作不改变历史交易。 */
public record ShopOrder(long id, long buyerId, long sellerId, long productId,
                        String productName, BigDecimal totalAmount, Status status,
                        LocalDateTime createdAt) implements Identified {
    public enum Status { PENDING, CONFIRMED, COMPLETED, CANCELLED }
    public ShopOrder withStatus(Status next) {
        return new ShopOrder(id, buyerId, sellerId, productId, productName, totalAmount, next, createdAt);
    }
}
