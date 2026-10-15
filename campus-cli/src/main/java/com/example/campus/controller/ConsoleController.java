package com.example.campus.controller;

import com.example.campus.common.*;
import com.example.campus.entity.*;
import com.example.campus.entity.User.Role;
import com.example.campus.service.MarketService;
import java.io.*;
import java.lang.reflect.*;
import java.math.BigDecimal;
import java.util.*;

/** Command 模式：指令注册表负责分发，注解负责菜单适配，服务负责业务规则。 */
public final class ConsoleController {
    private final MarketService market;
    private final BufferedReader input;
    private final PrintWriter output;
    private final Map<String, Command> commands = new LinkedHashMap<>();
    private UUID session;
    private boolean running = true;
    private record Command(String hint, Method method) {}
    private static final class EndInput extends RuntimeException {}

    public ConsoleController(MarketService market, Reader input, Writer output) {
        this.market = market; this.input = new BufferedReader(input); this.output = new PrintWriter(output, true);
        add("help", "显示菜单"); add("register", "注册买家/卖家"); add("login", "登录");
        add("logout", "退出登录"); add("search", "按关键词、分类、预算查询商品");
        add("publish", "发布二手商品"); add("products", "我的商品"); add("off", "下架商品");
        add("buy", "购买商品"); add("orders", "我的订单/管理员全部订单"); add("confirm", "卖家确认订单");
        add("receive", "买家确认收货"); add("cancel", "取消订单并释放商品"); add("review", "评价订单");
        add("reviews", "查看商品评价"); add("users", "管理用户"); add("disable", "停用用户");
        add("enable", "启用用户"); add("allproducts", "管理全部商品");
        add("allreviews", "查看全部评价"); add("hide", "隐藏违规评价"); add("exit", "退出程序");
    }
    private void add(String name, String hint) {
        try { commands.put(name, new Command(hint, getClass().getDeclaredMethod(name))); }
        catch (NoSuchMethodException e) { throw new IllegalStateException(e); }
    }
    public void run() {
        output.println("AgentMall 校园二手交易实验（纯内存，退出后数据清空）");
        help();
        while (running) {
            try {
                String line = read("指令").trim().toLowerCase(Locale.ROOT);
                if (line.isEmpty()) continue;
                Command command = commands.get(line);
                if (command == null) { output.println("错误：未知指令，输入 help 查看菜单。"); continue; }
                if (!allowed(command)) throw new BusinessException("请登录具有对应权限的账号");
                command.method().invoke(this);
            } catch (InvocationTargetException e) {
                if (e.getCause() instanceof EndInput) break;
                if (e.getCause() instanceof BusinessException || e.getCause() instanceof IllegalArgumentException)
                    output.println("错误：" + e.getCause().getMessage());
                else throw new IllegalStateException("命令执行失败", e.getCause());
            } catch (EndInput e) { break; }
            catch (BusinessException e) { output.println("错误：" + e.getMessage()); }
            catch (IllegalAccessException e) { throw new IllegalStateException(e); }
        }
        market.logout(session); output.println("程序结束，内存数据已释放。");
    }
    private boolean allowed(Command command) {
        AllowedRoles roles = command.method().getAnnotation(AllowedRoles.class);
        if (roles == null) return true;
        if (session == null) return false;
        return Arrays.asList(roles.value()).contains(market.currentUser(session).role());
    }
    private String read(String label) {
        output.print(label + "> "); output.flush();
        try { String line = input.readLine(); if (line == null) throw new EndInput(); return line; }
        catch (IOException e) { throw new UncheckedIOException(e); }
    }
    private long id(String label) {
        try { long id = Long.parseLong(read(label).trim()); if (id <= 0) throw new NumberFormatException(); return id; }
        catch (NumberFormatException e) { throw new BusinessException("编号须为正整数"); }
    }
    private BigDecimal decimal(String value) {
        try { return new BigDecimal(value.trim()); }
        catch (NumberFormatException e) { throw new BusinessException("金额须为有效数字，如 25.00"); }
    }
    private <T> void list(List<T> items, java.util.function.Function<T, String> format) {
        if (items.isEmpty()) output.println("暂无记录。"); else items.forEach(item -> output.println(format.apply(item)));
    }
    private String product(Product p) {
        return "#%d %s | %s | ¥%s | %s | 卖家#%d | %s".formatted(p.id(), p.name(), p.category(), p.price(), p.status(), p.sellerId(), p.description());
    }
    public void help() {
        if (session != null) {
            User user = market.currentUser(session); output.println("当前用户：" + user.username() + " / " + user.role());
        } else output.println("当前身份：访客");
        commands.forEach((name, command) -> { if (allowed(command)) output.println(name + " — " + command.hint()); });
    }
    public void register() {
        String name = read("用户名"); String password = read("密码（6–128 位，控制台明文输入）");
        String role = read("角色（1 买家 / 2 卖家）").trim();
        Role selected = switch (role) { case "1" -> Role.BUYER; case "2" -> Role.SELLER; default -> throw new BusinessException("角色只能输入 1 或 2"); };
        User user = market.register(name, password, selected); output.println("注册成功，用户编号 #" + user.id());
    }
    public void login() {
        String name = read("用户名"); String password = read("密码（控制台明文输入）");
        UUID next = market.login(name, password); market.logout(session); session = next;
        output.println("登录成功。"); help();
    }
    public void logout() { market.logout(session); session = null; output.println("已退出登录。"); help(); }
    public void search() {
        String keyword = read("关键词（留空不限）"); String category = read("分类（留空不限）"); String max = read("最高价格（留空不限）");
        list(market.search(keyword, category, max.isBlank() ? null : decimal(max)), this::product);
    }
    @AllowedRoles(Role.SELLER)
    public void publish() {
        String name = read("商品名"); String category = read("分类"); String description = read("成色与交接描述"); BigDecimal price = decimal(read("价格"));
        Product p = market.publish(session, name, category, description, price); output.println("发布成功：" + product(p));
    }
    @AllowedRoles(Role.SELLER)
    public void products() { list(market.myProducts(session), this::product); }
    @AllowedRoles({Role.SELLER, Role.ADMIN})
    public void off() { market.offShelf(session, id("商品编号")); output.println("下架成功。"); }
    @AllowedRoles(Role.BUYER)
    public void buy() { ShopOrder o = market.buy(session, id("商品编号")); output.println("下单成功，订单 #" + o.id() + "，等待卖家确认。"); }
    @AllowedRoles({Role.BUYER, Role.SELLER, Role.ADMIN})
    public void orders() {
        list(market.myOrders(session), o -> "#%d %s | ¥%s | %s | 买家#%d 卖家#%d | %s".formatted(o.id(), o.productName(), o.totalAmount(), o.status(), o.buyerId(), o.sellerId(), o.createdAt()));
    }
    @AllowedRoles(Role.SELLER)
    public void confirm() { market.confirm(session, id("订单编号")); output.println("订单已确认，请线下交接。"); }
    @AllowedRoles(Role.BUYER)
    public void receive() { market.complete(session, id("订单编号")); output.println("交易完成，可以评价。"); }
    @AllowedRoles({Role.BUYER, Role.SELLER, Role.ADMIN})
    public void cancel() { market.cancel(session, id("订单编号")); output.println("订单已取消，商品恢复可售。"); }
    @AllowedRoles(Role.BUYER)
    public void review() {
        long order = id("订单编号"); int rating;
        try { rating = Integer.parseInt(read("评分（1–5）").trim()); }
        catch (NumberFormatException e) { throw new BusinessException("评分须为 1–5 的整数"); }
        ProductReview review = market.review(session, order, rating, read("评价内容")); output.println("评价成功，编号 #" + review.id());
    }
    public void reviews() { printReviews(market.reviews(id("商品编号"))); }
    private void printReviews(List<ProductReview> items) {
        list(items, r -> "#%d 商品#%d 订单#%d | %d 星 | %s | %s".formatted(r.id(), r.productId(), r.orderId(), r.rating(), r.content(), r.hidden() ? "已隐藏" : "公开"));
    }
    @AllowedRoles(Role.ADMIN)
    public void users() {
        list(market.users(session), u -> "#%d %s | %s | %s".formatted(u.id(), u.username(), u.role(), market.isDisabled(session, u.id()) ? "停用" : "启用"));
    }
    @AllowedRoles(Role.ADMIN)
    public void disable() { market.setEnabled(session, id("用户编号"), false); output.println("用户已停用。"); }
    @AllowedRoles(Role.ADMIN)
    public void enable() { market.setEnabled(session, id("用户编号"), true); output.println("用户已启用。"); }
    @AllowedRoles(Role.ADMIN)
    public void allproducts() { list(market.allProducts(session), this::product); }
    @AllowedRoles(Role.ADMIN)
    public void allreviews() { printReviews(market.allReviews(session)); }
    @AllowedRoles(Role.ADMIN)
    public void hide() { market.hideReview(session, id("评价编号")); output.println("评价已隐藏。"); }
    public void exit() { running = false; }
}
