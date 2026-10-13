package com.example.campus.service;

import com.example.campus.common.*;
import com.example.campus.entity.*;
import com.example.campus.entity.User.Role;
import com.example.campus.repository.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

/** 交易门面统一处理权限、所有权和状态机，控制台不直接操作仓储。 */
public final class MarketService {
    private final Repository<User> users = new InMemoryRepository<>();
    private final Repository<Product> products = new InMemoryRepository<>();
    private final Repository<ShopOrder> orders = new InMemoryRepository<>();
    private final Repository<ProductReview> reviews = new InMemoryRepository<>();
    private final Map<Long, String> passwords = new HashMap<>();
    private final Set<Long> disabled = new HashSet<>();
    private final Map<UUID, Long> sessions = new HashMap<>();
    private long userSequence, productSequence, orderSequence, reviewSequence;

    /** 空构造不预置账号，演示工厂明确且可重复地加载种子数据。 */
    public static MarketService demo() {
        MarketService service = new MarketService();
        service.addUser("admin", "Admin123!", Role.ADMIN);
        service.register("buyer", "Buyer123!", Role.BUYER);
        service.register("seller", "Seller123!", Role.SELLER);
        UUID seller = service.login("seller", "Seller123!");
        service.publish(seller, "Java 教材", "图书", "九成新，无缺页，图书馆交接", new BigDecimal("25.00"));
        service.publish(seller, "台灯", "生活用品", "功能正常，宿舍楼下交接", new BigDecimal("35.00"));
        service.logout(seller);
        return service;
    }
    public User register(String name, String password, Role role) {
        check(role == Role.BUYER || role == Role.SELLER, "注册仅支持买家或卖家");
        return addUser(name, password, role);
    }
    private User addUser(String name, String password, Role role) {
        name = text(name, "用户名", 30);
        check(password != null && password.length() >= 6 && password.length() <= 128, "密码长度须为 6–128 位");
        String finalName = name;
        check(users.all().stream().noneMatch(u -> u.username().equalsIgnoreCase(finalName)), "用户名已存在");
        String hash = Passwords.hash(password);
        User user = User.create(++userSequence, name, role);
        users.save(user); passwords.put(user.id(), hash); return user;
    }
    public UUID login(String name, String password) {
        User user = users.all().stream().filter(u -> u.username().equalsIgnoreCase(name == null ? "" : name.trim()))
                .findFirst().orElseThrow(() -> new BusinessException("用户名或密码错误"));
        check(password != null && Passwords.matches(password, passwords.get(user.id())), "用户名或密码错误");
        check(!disabled.contains(user.id()), "账号已停用，请联系管理员");
        UUID token = UUID.randomUUID(); sessions.put(token, user.id()); return token;
    }
    public void logout(UUID token) { sessions.remove(token); }
    public User currentUser(UUID token) { return actor(token); }
    private User actor(UUID token, Role... roles) {
        Long id = sessions.get(token);
        check(id != null, "请先登录");
        User user = require(users, id, "用户");
        check(!disabled.contains(id), "账号已停用，请联系管理员");
        check(roles.length == 0 || Arrays.asList(roles).contains(user.role()), "当前角色无权执行此操作");
        return user;
    }
    public Product publish(UUID token, String name, String category, String description, BigDecimal price) {
        User seller = actor(token, Role.SELLER);
        name = text(name, "商品名", 80); category = text(category, "分类", 30);
        description = text(description, "描述", 500); price = price(price);
        Product product = new Product(++productSequence, seller.id(), name, category, description, price, Product.Status.AVAILABLE);
        products.save(product); return product;
    }
    public List<Product> search(String keyword, String category, BigDecimal maxPrice) {
        check(maxPrice == null || maxPrice.signum() >= 0, "预算不能为负数");
        String query = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);
        String group = category == null ? "" : category.trim();
        return products.all().stream().filter(p -> p.status() == Product.Status.AVAILABLE)
                .filter(p -> !disabled.contains(p.sellerId()))
                .filter(p -> (p.name() + " " + p.description()).toLowerCase(Locale.ROOT).contains(query))
                .filter(p -> group.isEmpty() || p.category().equalsIgnoreCase(group))
                .filter(p -> maxPrice == null || p.price().compareTo(maxPrice) <= 0)
                .sorted(Comparator.comparing(Product::price).thenComparingLong(Product::id)).toList();
    }
    public List<Product> myProducts(UUID token) {
        User seller = actor(token, Role.SELLER);
        return products.all().stream().filter(p -> p.sellerId() == seller.id()).toList();
    }
    public List<Product> allProducts(UUID token) { actor(token, Role.ADMIN); return products.all(); }
    public void offShelf(UUID token, long id) {
        User user = actor(token, Role.SELLER, Role.ADMIN);
        Product product = require(products, id, "商品");
        check(user.role() == Role.ADMIN || product.sellerId() == user.id(), "只能管理自己的商品");
        check(product.status() == Product.Status.AVAILABLE, "只有在售商品可下架");
        products.save(product.withStatus(Product.Status.OFF_SHELF));
    }
    /** 先验证所有条件再写入；一个订单锁定一件实物，防止重复出售。 */
    public ShopOrder buy(UUID token, long productId) {
        User buyer = actor(token, Role.BUYER);
        Product product = require(products, productId, "商品");
        check(product.sellerId() != buyer.id(), "不能购买自己的商品");
        check(!disabled.contains(product.sellerId()), "卖家已停用，无法下单");
        check(product.status() == Product.Status.AVAILABLE, "商品已被预订、售出或下架");
        ShopOrder order = new ShopOrder(++orderSequence, buyer.id(), product.sellerId(), product.id(),
                product.name(), product.price(), ShopOrder.Status.PENDING, LocalDateTime.now());
        orders.save(order); products.save(product.withStatus(Product.Status.RESERVED)); return order;
    }
    public List<ShopOrder> myOrders(UUID token) {
        User user = actor(token);
        return orders.all().stream().filter(o -> user.role() == Role.ADMIN || o.buyerId() == user.id() || o.sellerId() == user.id()).toList();
    }
    public void confirm(UUID token, long id) {
        User seller = actor(token, Role.SELLER); ShopOrder order = require(orders, id, "订单");
        check(order.sellerId() == seller.id(), "只能确认自己的卖出订单");
        check(order.status() == ShopOrder.Status.PENDING, "只有待确认订单可以确认");
        orders.save(order.withStatus(ShopOrder.Status.CONFIRMED));
    }
    public void complete(UUID token, long id) {
        User buyer = actor(token, Role.BUYER); ShopOrder order = require(orders, id, "订单");
        check(order.buyerId() == buyer.id(), "只能收货自己的订单");
        check(order.status() == ShopOrder.Status.CONFIRMED, "卖家确认后才能收货");
        orders.save(order.withStatus(ShopOrder.Status.COMPLETED));
        products.save(require(products, order.productId(), "商品").withStatus(Product.Status.SOLD));
    }
    public void cancel(UUID token, long id) {
        User user = actor(token); ShopOrder order = require(orders, id, "订单");
        check(user.role() == Role.ADMIN || order.buyerId() == user.id() || order.sellerId() == user.id(), "无权取消他人订单");
        check(order.status() == ShopOrder.Status.PENDING || order.status() == ShopOrder.Status.CONFIRMED, "已完成或已取消订单不能取消");
        orders.save(order.withStatus(ShopOrder.Status.CANCELLED));
        products.save(require(products, order.productId(), "商品").withStatus(Product.Status.AVAILABLE));
    }
    public ProductReview review(UUID token, long orderId, int rating, String content) {
        User buyer = actor(token, Role.BUYER); ShopOrder order = require(orders, orderId, "订单");
        check(order.buyerId() == buyer.id(), "只能评价自己的订单");
        check(order.status() == ShopOrder.Status.COMPLETED, "收货完成后才能评价");
        check(rating >= 1 && rating <= 5, "评分须为 1–5"); content = text(content, "评价", 500);
        check(reviews.all().stream().noneMatch(r -> r.orderId() == orderId), "该订单已评价");
        ProductReview review = new ProductReview(++reviewSequence, orderId, order.productId(), buyer.id(), rating, content, false, LocalDateTime.now());
        reviews.save(review); return review;
    }
    public List<ProductReview> reviews(long productId) {
        require(products, productId, "商品");
        return reviews.all().stream().filter(r -> r.productId() == productId && !r.hidden()).toList();
    }
    public List<ProductReview> allReviews(UUID token) { actor(token, Role.ADMIN); return reviews.all(); }
    public void hideReview(UUID token, long id) {
        actor(token, Role.ADMIN); ProductReview review = require(reviews, id, "评价"); reviews.save(review.hide());
    }
    public List<User> users(UUID token) { actor(token, Role.ADMIN); return users.all(); }
    public boolean isDisabled(UUID token, long id) { actor(token, Role.ADMIN); require(users, id, "用户"); return disabled.contains(id); }
    public void setEnabled(UUID token, long id, boolean enabled) {
        actor(token, Role.ADMIN); User user = require(users, id, "用户");
        check(user.role() != Role.ADMIN, "演示管理员账号不能停用");
        if (enabled) disabled.remove(id); else disabled.add(id);
    }
    private static String text(String value, String label, int max) {
        check(value != null && !value.isBlank(), label + "不能为空"); value = value.trim();
        check(value.length() <= max, label + "最多 " + max + " 个字符"); return value;
    }
    private static BigDecimal price(BigDecimal value) {
        check(value != null && value.signum() > 0 && value.compareTo(new BigDecimal("1000000")) <= 0, "价格须大于 0 且不超过 1000000");
        try { return value.setScale(2, java.math.RoundingMode.UNNECESSARY); }
        catch (ArithmeticException e) { throw new BusinessException("价格最多两位小数"); }
    }
    private static <T extends Identified> T require(Repository<T> repo, long id, String label) {
        return repo.find(id).orElseThrow(() -> new BusinessException(label + "不存在：" + id));
    }
    private static void check(boolean condition, String message) { if (!condition) throw new BusinessException(message); }
}
