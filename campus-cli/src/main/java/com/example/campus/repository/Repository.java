package com.example.campus.repository;

import com.example.campus.entity.Identified;
import java.util.List;
import java.util.Optional;

/** 泛型仓储接口对应 AgentMall 的 Mapper 层，但不执行任何 SQL。 */
public interface Repository<T extends Identified> {
    void save(T entity);
    Optional<T> find(long id);
    List<T> all();
}
