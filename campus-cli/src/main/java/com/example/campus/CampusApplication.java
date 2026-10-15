package com.example.campus;

import com.example.campus.controller.ConsoleController;
import com.example.campus.service.MarketService;
import java.io.*;
import java.nio.charset.StandardCharsets;

/** 组合根：显式组装仓储和服务，无需启动 Spring、MySQL 或模型服务。 */
public final class CampusApplication {
    public static void main(String[] args) {
        new ConsoleController(MarketService.demo(), new InputStreamReader(System.in, StandardCharsets.UTF_8),
                new OutputStreamWriter(System.out, StandardCharsets.UTF_8)).run();
    }
}
