# AgentMall

前端版本：`0.0.1` · [更新记录](CHANGELOG.md)

基于 **Vue 3 + Spring Boot + Spring AI** 的智能商城项目，将商品浏览、购物车、订单与钱包等商城功能，与 AI 智能导购、商品知识问答、评价分析和运营增长报告结合。

项目包含用户商城与管理后台，支持记录 Agent 的运行过程、工具调用步骤和推荐依据。

## 功能概览

| 模块 | 主要功能 |
| --- | --- |
| 用户商城 | 注册登录、商品浏览与详情、收藏、购物车、订单、收货地址、钱包与个人资料 |
| 商品与交易管理 | 商品分类、品牌、商品详情与参数、订单、评价、售后规则 |
| AI 智能导购 | 根据需求执行导购任务，通过工具查询候选商品、价格、库存、优惠与用户画像，生成商品推荐 |
| 商品问答 | 基于商品知识切片进行检索增强生成（RAG）；价格库存、订单状态与售后规则通过业务查询返回 |
| 知识库 | 商品知识维护、切片生成、向量生成、相似度检索与批量生成进度查看 |
| AI 分析 | 商品评价分析、运营增长报告 |
| AI 管理与调试 | 对话/向量模型配置、Prompt 模板、Function Tool 管理、商品与业务工具调试 |
| 运行追踪 | Agent Run 运行记录、Agent Step 执行步骤、推荐结果与证据查看 |

## 界面预览

以下为项目界面截图，展示用户商城、AI 导购与管理后台的主要功能。

### 登录页面

暖白与砖红配色的登录页面，支持桌面与手机布局。

![登录页面](docs/screenshots/login.png)

[查看手机端登录页](docs/screenshots/login-mobile.png)

### 商城首页

商品分类、品牌筛选、搜索与商品列表。

![商城首页](docs/screenshots/storefront.png)

### AI 智能导购

输入购物需求和预算，查看推荐商品、推荐理由与匹配结果。

![AI 智能导购](docs/screenshots/ai-shopping-guide.png)

### 商品详情与 AI 问答

展示商品价格、库存和参数，并结合知识库资料回答商品问题。

![商品详情与 AI 问答](docs/screenshots/product-qa.png)

### 后台商品管理

维护商品信息、价格、库存、推荐状态与上架状态。

![后台商品管理](docs/screenshots/product-management.png)

### Function Tool 工具中心

查看与维护业务工具的编码、调用方式、Service Bean 和启用状态。

![Function Tool 工具中心](docs/screenshots/function-tools.png)

### Embedding 检索

生成知识向量，检索相关商品资料并查看相似度结果。

![Embedding 检索](docs/screenshots/embedding-search.png)

## 技术栈

- **前端**：Vue 3、Vite 5、Vue Router 4、Element Plus、Axios、Sass、Marked。
- **后端**：Java 21、Spring Boot 3.5.14、MyBatis、PageHelper、JWT、Hutool。
- **AI**：Spring AI 1.1.7，对接 OpenAI 兼容协议的对话与向量模型；Agent 的 Function Calling 循环通过 HTTP 请求实现。
- **数据存储**：MySQL；向量以文本形式存入数据库，由应用计算余弦相似度，当前不依赖独立向量数据库。
- **文件存储**：后端进程工作目录下的 `files/`。

依赖版本以 [后端配置](springboot/pom.xml)、[前端配置](vue/package.json) 和 [依赖锁文件](vue/package-lock.json) 为准。

## 项目结构

```text
AgentMall/
├── files/                           # 仓库内已有文件资源
├── springboot/
│   ├── pom.xml                      # Maven 依赖与构建配置
│   └── src/main/
│       ├── java/com/example/
│       │   ├── common/              # 通用响应、配置与鉴权
│       │   ├── controller/          # HTTP 接口
│       │   ├── entity/              # 实体与请求/响应对象
│       │   ├── mapper/              # MyBatis 接口
│       │   ├── service/             # 商城、AI 与 Agent 业务
│       │   ├── exception/           # 异常处理
│       │   └── utils/               # 工具类
│       └── resources/
│           ├── application.yml      # 数据库、端口与文件地址
│           └── mapper/              # SQL 映射文件
└── vue/
    ├── package.json
    ├── vite.config.js
    ├── .env.development             # 开发环境 API 地址
    ├── .env.production              # 生产环境 API 地址
    └── src/
        ├── router/                  # 页面路由
        ├── utils/                   # 请求与 Markdown 工具
        └── views/
            ├── front/              # 用户商城
            └── manager/            # 管理后台
```

## 本地运行

> **数据库前提**：当前仓库未提供建表 SQL、数据库迁移或种子数据。运行前需要自行准备与实体及 Mapper 匹配的完整数据库结构和必要数据；仅创建空数据库无法使用业务功能。仓库也未提供可确认的初始管理员账号。

### 1. 准备环境与源码

- JDK 21。
- Maven（使用本机 `mvn`，仓库未提供 Maven Wrapper）。
- Node.js 20 或更高版本及 npm；锁文件中的 Marked 要求 Node.js ≥ 20。
- 可访问的 MySQL 服务。
- 使用 AI 生成功能时，准备兼容协议的模型服务地址、模型名和 API Key；智能导购需要对话模型支持 Function Calling。

```bash
git clone https://github.com/saborpunk/AgentMall.git
cd AgentMall
```

### 2. 配置数据库

编辑 [application.yml](springboot/src/main/resources/application.yml)，将以下配置改为本机实际值，保留文件中的 MyBatis 等其他配置：

```yaml
server:
  port: 9090

spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ai_shopping?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT%2b8&allowPublicKeyRetrieval=true
    username: YOUR_DB_USER
    password: YOUR_DB_PASSWORD

fileBaseUrl: http://localhost:${server.port}
```

数据库默认名称为 `ai_shopping`。请先准备对应表结构与数据，再启动业务流程；不要将真实数据库凭据提交到仓库。

### 3. 构建并启动后端

在仓库根目录执行：

```bash
mvn -f springboot/pom.xml clean package
java -jar springboot/target/springboot-0.0.1-SNAPSHOT.jar
```

默认后端地址为 `http://localhost:9090`。

上述方式从仓库根目录运行 JAR，使文件服务使用根目录下的 `files/`。若通过 IDE 或 `mvn spring-boot:run` 启动，请核对进程工作目录：文件路径由 `user.dir` 决定，切换工作目录会改变上传和下载位置。

### 4. 启动前端

在另一个终端中，从仓库根目录执行：

```bash
cd vue
npm ci
npm run dev
```

开发环境默认读取 [vue/.env.development](vue/.env.development)：

```dotenv
VITE_BASE_URL='http://localhost:9090'
```

打开 Vite 输出的本地地址（通常为 `http://localhost:5173`）。主要页面路径：

| 页面 | 路径 |
| --- | --- |
| 登录 / 注册 | `/login` / `/register` |
| 商城首页 | `/front/home` |
| 智能导购 | `/front/guide` |
| 管理后台首页 | `/manager/home` |

注册接口创建普通用户（`USER`）；管理员账号需由数据库维护者预先准备，不能将普通注册视为管理员初始化流程。

## AI 配置与体验流程

### 配置模型

进入管理后台的 **AI 模型配置**，填写提供商、模型类型、Base URL、API Key、模型名称，并启用对应配置：

| 模型类型 | 用途 |
| --- | --- |
| `CHAT` | 商品知识问答、导购 Agent、评价分析、运营报告等生成任务 |
| `EMBEDDING` | 商品知识切片向量化与查询向量生成 |

模型配置保存在 `ai_model_config` 表中。后端通过 `SpringAiModelFactory` 动态创建模型实例，已排除相关 OpenAI 自动配置，因此无需通过 `spring.ai.openai.api-key` 初始化模型。

对话模型 Base URL 应使用服务商实际提供的兼容 API 前缀（例如包含 `/v1` 的地址）或完整 `/chat/completions` 地址。请确认服务商的路径、模型能力和凭据匹配；不要在文档、截图或提交中暴露真实 API Key。同一模型类型建议只启用一条配置，当前代码取查询结果中的第一条启用配置。

### 体验商品知识问答

1. 维护商品及其知识资料。
2. 在 **商品知识切片** 中生成切片。
3. 在 **Embedding 检索** 中生成向量并检查生成进度。
4. 对指定商品提问，查看回答及召回资料证据。

未配置可用的 `EMBEDDING` 模型时，系统回退到 64 维本地哈希向量，适合演示检索流程，检索质量有限；生成 AI 回答仍需要可用的 `CHAT` 模型。更换向量模型或从本地哈希切换到真实模型后，应重新生成知识向量，避免混用不同向量空间。

商品知识问答取最多 3 条候选切片，并按相似度阈值过滤；没有相关资料时直接提示未找到资料，不调用大模型生成答案。

### 体验智能导购

1. 准备上架商品、价格、库存等基础数据。
2. 启用支持 Function Calling 的对话模型。
3. 在商城智能导购页提交需求，或在管理后台创建并执行导购任务。
4. 查看推荐商品、推荐依据，以及 **Agent Run / Agent Step** 中的执行记录。

当前导购循环最多执行 10 轮，最多生成 3 条推荐。模型可调用候选商品搜索、价格、库存、优惠和用户画像查询工具，再提交推荐结果。

## 构建与部署

后端打包命令见上文。前端在 `vue/` 目录执行：

```bash
npm run build
npm run preview
```

构建产物位于 `vue/dist/`；`preview` 用于本地检查构建结果。

部署前需要：

- 将 [vue/.env.production](vue/.env.production) 中的 `http://:9090` 占位值改为实际可访问的后端地址，再重新构建前端。该变量在构建时注入。
- 设置后端数据库连接与 `fileBaseUrl`，确保生成的文件链接能从用户浏览器访问。
- 为前端 Web 服务器配置 History 路由回退至 `index.html`，避免直接访问或刷新子页面时出现 404。
- 固定后端工作目录，并持久化、备份该目录下的 `files/` 和数据库。

## 常见问题

| 现象 | 检查项 |
| --- | --- |
| 数据库连接失败或提示表不存在 | MySQL 是否启动、连接信息是否正确、完整表结构是否已导入 |
| 前端提示网络异常 | 后端是否在 9090 端口启动，`VITE_BASE_URL` 是否正确；修改环境文件后重启开发服务 |
| 提示未配置启用的模型 | 检查模型类型、启用状态、Base URL、API Key 和模型名 |
| 模型调用失败或限流 | 检查模型平台额度、凭据、网络、模型权限及 Function Calling 支持情况 |
| 知识问答没有相关资料 | 确认商品关联、知识切片和向量已生成；切换向量模型后重新生成向量 |
| 图片或上传文件无法访问 | 核对 `fileBaseUrl`、进程工作目录以及实际 `files/` 内容 |
| 前端依赖安装报 Node 版本不匹配 | 使用 Node.js 20 或更高版本，并通过 `npm ci` 按锁文件安装 |

## 当前仓库说明

- 本 README 根据现有代码和配置整理；启动步骤仍需在准备好数据库、账号和模型服务的环境中验证。
- 当前仓库未提供自动化测试用例、数据库初始化脚本或容器部署配置。
- 当前仓库未包含 LICENSE 文件，使用与分发授权请联系项目维护者确认。
