package com.example.campus.entity;

/** 仓储中的对象统一提供主键，避免仓储依赖具体业务类型。 */
public interface Identified { long id(); }
