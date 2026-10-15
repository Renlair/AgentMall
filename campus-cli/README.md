# AgentMall Java 实验：校园二手商品交易

本模块依据《Java实验.pages》中的题目 2 实现：全部操作通过命令行完成，数据仅存于 Java 内存集合，包含买家、卖家、管理员及用户、商品、订单、评价四类实体。

## 与 AgentMall 脚手架的对应关系

保留项目已有的 `com.example` 包前缀，采用 `controller → service → repository → entity` 分层。领域命名沿用原商城的 `User`、`Product`、`ShopOrder`、`ProductReview`，针对一件一卖的校园二手商品重新定义状态和所有权。

原 `springboot` 模块中的实体、Service 依赖 MyBatis、MySQL 和 Web 请求，直接启动不符合本次实验要求。因此新增 `campus-cli` 独立模块：继承项目的分层和领域设计，不加载原数据库、Vue、Spring AI 或文件服务。原商城运行方式仍见根目录 README。

## 构建与运行

环境：JDK 21。无需安装 Maven，也无需任何数据库或网络服务。

在仓库根目录运行（macOS / Linux / Git Bash）：

```sh
sh campus-cli/build.sh
java -jar campus-cli/target/campus-cli.jar
sh campus-cli/test.sh
```

若系统有多个 JDK，先设置 `JAVA_HOME` 为 JDK 21 目录，并使用 `"$JAVA_HOME/bin/java"` 运行。IDE 可以直接运行 `CampusApplication.main`。Windows PowerShell 或 CMD 可通过 IDE 导入 `campus-cli/pom.xml`，或使用 Maven：

```sh
mvn -f campus-cli/pom.xml clean package
java -jar campus-cli/target/campus-cli-1.0.0.jar
```

Maven 的 `test` 阶段通过 exec 插件执行同一组业务回归测试；首次运行 Maven 需要下载构建插件。源码本身只依赖 JDK 标准库。

## 演示账号

| 用户名 | 密码 | 角色 | 初始编号 |
| --- | --- | --- | --- |
| admin | Admin123! | 管理员 | 1 |
| buyer | Buyer123! | 买家 | 2 |
| seller | Seller123! | 卖家 | 3 |

启动时加载两件商品：`#1 Java 教材，25.00 元`、`#2 台灯，35.00 元`。账号和商品是本地演示数据，不是原商城数据库账号。输入 `register` 可创建新的买家或卖家，不能注册管理员。

## 交互方式

每次输入一条英文指令，程序再逐项提示需要填写的内容。商品名、描述、评价可以包含空格，不需要自行拼接复杂命令。指令不区分大小写。输入 `help` 查看当前身份可以使用的指令，输入 `logout` 切换账号，输入 `exit` 或文件结束符退出。

| 身份 | 指令 |
| --- | --- |
| 所有人 | help、register、login、logout、search、reviews、exit |
| 买家 | buy、orders、receive、cancel、review |
| 卖家 | publish、products、off、orders、confirm、cancel |
| 管理员 | users、disable、enable、allproducts、off、orders、cancel、allreviews、hide |

演示完整交易：

1. `login`，输入 `seller`、`Seller123!`；`publish`，按提示输入商品名、分类、成色与交接描述、价格。
2. `logout` 后 `login` 买家；`search`，按提示输入关键词、分类和最高价格（可留空）；`buy` 输入商品编号。
3. 切换卖家，`orders` 查看订单；`confirm` 输入订单编号。
4. 线下交接完成后切换买家；`receive` 输入订单编号；`review` 输入订单编号、1–5 分和评价内容。
5. `reviews` 输入商品编号查看公开评价。
6. 管理员可下架在售商品、取消未完成订单、启停用户及隐藏违规评价。

## 数据与状态规则

- 数据分别存于 `InMemoryRepository<T>` 的 `LinkedHashMap<Long,T>`，账号密码派生值和会话保存在内存 `HashMap`，停用用户编号保存在 `HashSet`。
- 程序不写业务数据文件，也不执行 SQL。退出后数据清空，再次启动重新生成演示数据。
- 价格使用 `BigDecimal`，必须大于零、不超过 1000000 元且最多两位小数。订单保存成交时的价格与商品名快照。
- 一件商品下单后变为 `RESERVED`，其他买家不能再次购买。卖家确认后由订单买家确认收货，商品才变为 `SOLD`。
- 买家或卖家只能操作自己的交易；管理员可查看全部订单并取消未完成交易。取消恢复商品可售，已完成订单不能取消。
- 每笔已完成订单只能评价一次。管理员隐藏评价后公开查询不再展示，管理列表保留原记录。
- 停用账号不能登录或执行已登录会话的业务操作。停用卖家的商品不参与公开搜索，也不能被购买；既有订单由管理员或其他仍启用的交易参与者取消。
- 本实验以单线程控制台执行服务操作，不实现支付系统，确认代表线下交易交接，不发生真实资金扣款。

## 实验材料

- [实验报告草稿](docs/实验报告.md)：功能组织、设计模式、流程图、类关系、核心代码、AI 使用及测试分析。
- [验证记录](docs/验证记录.md)：实际构建、业务回归及命令行运行结果。
