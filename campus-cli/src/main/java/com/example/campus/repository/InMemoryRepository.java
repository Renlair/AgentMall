package com.example.campus.repository;

import com.example.campus.entity.Identified;
import java.util.*;

/** LinkedHashMap 保持插入顺序；返回集合副本，禁止外部修改仓储结构。 */
public final class InMemoryRepository<T extends Identified> implements Repository<T> {
    private final Map<Long, T> data = new LinkedHashMap<>();
    public void save(T entity) { data.put(entity.id(), entity); }
    public Optional<T> find(long id) { return Optional.ofNullable(data.get(id)); }
    public List<T> all() { return List.copyOf(data.values()); }
}
