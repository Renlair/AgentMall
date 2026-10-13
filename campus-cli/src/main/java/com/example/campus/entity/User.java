package com.example.campus.entity;

/** 抽象用户和三个子类通过多态提供角色，注册时由工厂创建。 */
public abstract sealed class User implements Identified permits User.Buyer, User.Seller, User.Admin {
    public enum Role { BUYER, SELLER, ADMIN }
    private final long id;
    private final String username;
    protected User(long id, String username) { this.id = id; this.username = username; }
    public final long id() { return id; }
    public final String username() { return username; }
    public abstract Role role();
    public static User create(long id, String username, Role role) {
        return switch (role) {
            case BUYER -> new Buyer(id, username);
            case SELLER -> new Seller(id, username);
            case ADMIN -> new Admin(id, username);
        };
    }
    public static final class Buyer extends User {
        private Buyer(long id, String name) { super(id, name); }
        public Role role() { return Role.BUYER; }
    }
    public static final class Seller extends User {
        private Seller(long id, String name) { super(id, name); }
        public Role role() { return Role.SELLER; }
    }
    public static final class Admin extends User {
        private Admin(long id, String name) { super(id, name); }
        public Role role() { return Role.ADMIN; }
    }
}
