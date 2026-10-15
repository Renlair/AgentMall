package com.example.campus;

import com.example.campus.common.BusinessException;
import com.example.campus.controller.ConsoleController;
import com.example.campus.entity.*;
import com.example.campus.entity.User.Role;
import com.example.campus.service.MarketService;
import java.io.*;
import java.math.BigDecimal;
import java.util.*;

/** 无第三方依赖的业务回归测试；失败抛 AssertionError，构建返回非零退出码。 */
public final class MarketServiceTest {
    private static int checks;
    public static void main(String[] args) {
        MarketService m = MarketService.demo();
        UUID buyer = m.login("buyer", "Buyer123!"), seller = m.login("seller", "Seller123!"), admin = m.login("admin", "Admin123!");
        m.register("otherBuyer", "secret123", Role.BUYER); UUID otherBuyer = m.login("otherBuyer", "secret123");
        m.register("otherSeller", "secret123", Role.SELLER); UUID otherSeller = m.login("otherSeller", "secret123");
        reject(() -> m.register("BUYER", "secret123", Role.BUYER), "重复用户名");
        reject(() -> m.register("evilAdmin", "secret123", Role.ADMIN), "禁止注册管理员");
        reject(() -> m.register("short", "123", Role.BUYER), "短密码");
        reject(() -> m.login("buyer", "wrong"), "错误密码");
        reject(() -> m.publish(buyer, "x", "y", "z", BigDecimal.ONE), "买家发布越权");
        reject(() -> m.publish(seller, " ", "y", "z", BigDecimal.ONE), "空商品名");
        reject(() -> m.publish(seller, "x", "y", "z", BigDecimal.ZERO), "零价格");
        reject(() -> m.publish(seller, "x", "y", "z", new BigDecimal("1.001")), "超精度价格");
        equal(1, m.search("java", "图书", new BigDecimal("25")).size(), "联合筛选与预算边界");
        equal(0, m.search("java", "图书", new BigDecimal("24.99")).size(), "预算不足");
        reject(() -> m.search("", "", new BigDecimal("-1")), "负预算");
        ShopOrder order = m.buy(buyer, 1);
        equal(new BigDecimal("25.00"), order.totalAmount(), "价格快照");
        equal(Product.Status.RESERVED, m.myProducts(seller).getFirst().status(), "下单锁定");
        reject(() -> m.buy(otherBuyer, 1), "重复购买锁定商品");
        reject(() -> m.buy(seller, 2), "卖家购买越权");
        reject(() -> m.complete(buyer, order.id()), "确认前收货");
        reject(() -> m.review(buyer, order.id(), 5, "好"), "收货前评价");
        reject(() -> m.confirm(otherSeller, order.id()), "他人卖家确认");
        reject(() -> m.cancel(otherBuyer, order.id()), "取消他人订单");
        reject(() -> m.offShelf(admin, 1), "下架锁定商品");
        m.confirm(seller, order.id());
        reject(() -> m.confirm(seller, order.id()), "重复确认");
        reject(() -> m.complete(otherBuyer, order.id()), "他人收货");
        m.complete(buyer, order.id());
        equal(Product.Status.SOLD, m.myProducts(seller).getFirst().status(), "售出状态");
        reject(() -> m.cancel(admin, order.id()), "已完成订单取消");
        reject(() -> m.review(buyer, order.id(), 6, "好"), "评分上界");
        reject(() -> m.review(buyer, order.id(), 0, "好"), "评分下界");
        reject(() -> m.review(buyer, order.id(), 5, " "), "空评价");
        reject(() -> m.review(otherBuyer, order.id(), 5, "好"), "他人评价");
        ProductReview r = m.review(buyer, order.id(), 5, "描述准确，交接顺利");
        equal(1, m.reviews(1).size(), "公开评价");
        reject(() -> m.review(buyer, order.id(), 4, "重复"), "重复评价");
        reject(() -> m.hideReview(buyer, r.id()), "评价管理越权");
        m.hideReview(admin, r.id()); equal(0, m.reviews(1).size(), "隐藏公开评价");
        equal(1, m.allReviews(admin).size(), "隐藏保留记录");
        ShopOrder second = m.buy(buyer, 2); m.confirm(seller, second.id()); m.cancel(buyer, second.id());
        equal(Product.Status.AVAILABLE, m.myProducts(seller).get(1).status(), "确认后取消恢复商品");
        reject(() -> m.cancel(buyer, second.id()), "重复取消");
        ShopOrder third = m.buy(otherBuyer, 2); m.cancel(admin, third.id());
        equal(ShopOrder.Status.CANCELLED, m.myOrders(otherBuyer).get(0).status(), "管理员取消待确认订单");
        reject(() -> m.offShelf(otherSeller, 2), "商品所有权");
        m.offShelf(admin, 2); reject(() -> m.buy(buyer, 2), "下架商品购买");
        equal(0, m.myOrders(otherSeller).size(), "卖家订单隔离");
        equal(3, m.myOrders(admin).size(), "管理员全部订单");
        reject(() -> m.users(buyer), "用户管理越权");
        reject(() -> m.setEnabled(admin, 1, false), "保护管理员");
        m.setEnabled(admin, 2, false); reject(() -> m.login("buyer", "Buyer123!"), "停用账号登录");
        reject(() -> m.buy(buyer, 2), "旧会话停用校验");
        m.setEnabled(admin, 2, true); equal(Role.BUYER, m.currentUser(buyer).role(), "重新启用账号");
        Product p = m.publish(seller, "耳机", "电子", "正常", new BigDecimal("99"));
        m.setEnabled(admin, 3, false); equal(0, m.search("耳机", "", null).size(), "停用卖家商品不可见");
        reject(() -> m.buy(buyer, p.id()), "停用卖家不能交易");
        m.setEnabled(admin, 3, true);
        reject(() -> m.buy(buyer, 999), "不存在商品");
        m.logout(buyer); reject(() -> m.myOrders(buyer), "失效会话");
        MarketService fresh = MarketService.demo(); equal(0, fresh.myOrders(fresh.login("admin", "Admin123!")).size(), "新实例无历史订单");
        consoleFlow(); consoleErrors();
        System.out.println("PASS: " + checks + " checks（交易流程、角色权限、边界、控制台交互）");
    }
    private static void consoleFlow() {
        String script = String.join("\n", "login", "seller", "Seller123!", "publish", "测试教材", "图书", "全新", "10", "logout",
                "login", "buyer", "Buyer123!", "buy", "3", "logout", "login", "seller", "Seller123!", "confirm", "1", "logout",
                "login", "buyer", "Buyer123!", "receive", "1", "review", "1", "5", "很好", "reviews", "3", "exit", "");
        String result = console(script);
        equal(true, result.contains("发布成功") && result.contains("交易完成") && result.contains("评价成功") && result.contains("很好"), "控制台完整交易");
        equal(false, result.contains("错误："), "完整交易无错误");
    }
    private static void consoleErrors() {
        String result = console("nonsense\nbuy\nlogin\nbuyer\nBuyer123!\nbuy\nabc\nbuy\n-1\nsearch\n\n\nxyz\norders\nexit\n");
        equal(true, result.contains("未知指令") && result.contains("对应权限") && result.contains("编号须为正整数") && result.contains("金额须为有效数字") && result.contains("暂无记录"), "错误输入后恢复交互");
        result = console("login\nseller\nSeller123!\npublish\n未完成\n");
        equal(true, result.contains("程序结束") && !result.contains("发布成功"), "EOF 不产生半条商品");
    }
    private static String console(String script) {
        StringWriter output = new StringWriter(); new ConsoleController(MarketService.demo(), new StringReader(script), output).run(); return output.toString();
    }
    private static void equal(Object expected, Object actual, String label) {
        if (!Objects.equals(expected, actual)) throw new AssertionError(label + ": expected=" + expected + ", actual=" + actual);
        checks++;
    }
    private static void reject(Runnable action, String label) {
        try { action.run(); } catch (BusinessException e) { checks++; return; }
        throw new AssertionError("应拒绝：" + label);
    }
}
