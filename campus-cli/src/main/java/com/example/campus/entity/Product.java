package com.example.campus.entity;

import java.math.BigDecimal;

/** 一件二手实物只对应一个订单；不可变对象防止调用方绕过服务修改状态。 */
public record Product(long id, long sellerId, String name, String category,
                      String description, BigDecimal price, Status status) implements Identified {
    public enum Status { AVAILABLE, RESERVED, SOLD, OFF_SHELF }
    public Product withStatus(Status next) {
        return new Product(id, sellerId, name, category, description, price, next);
    }
}
