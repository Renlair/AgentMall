# AgentMall Docker 部署

Nginx + Java 21 + MySQL 8.4，默认只监听 127.0.0.1:8080。数据库和上传文件使用 agentmall_db_data、agentmall_uploads 命名卷。initdb 仅含表结构和部署测试数据，不复制旧数据或模型密钥。

## 构建（仓库根目录）

```bash
docker build --platform linux/amd64 -f deploy/backend.Dockerfile -t agentmall-backend:local-20261016 .
docker build --platform linux/amd64 -f deploy/web.Dockerfile -t agentmall-web:v0.0.1-20261017 .
```

前端使用 VITE_BASE_URL=/api，Nginx 转发 /api/ 和 /files/，HTML 重新验证缓存以避免更新后继续加载旧页面。后端使用 deploy/application.yml，数据库密码从环境变量获取。

## 首次部署

仅在确认端口和目录未被其他服务使用后，在 deploy 目录运行：

```bash
bash init-secrets.sh
docker compose up -d
python3 verify.py
docker compose restart
python3 verify.py --after-restart
```

admin 随机初始密码只在空数据库初始化时生效，保存在权限 600 的 .env，请勿提交。既有部署必须保留原 .env、项目名和数据卷，不重新初始化，也不要执行 docker compose down -v。

本地验收后，需要公网入口时复制 compose.public.yaml 为 compose.override.yaml，然后 docker compose up -d，并按需放行 HTTP 80。MySQL 和后端不映射到公网。HTTPS 和模型密钥需另行配置。

## 更新已有部署

构建带唯一版本标签的镜像，用 docker save / docker load 或镜像仓库传输到服务器。保留原 .env 和 compose.override.yaml，仅修改 compose.yaml 的对应 image 标签（前端也可在 .env 设置 WEB_IMAGE），然后：

```bash
docker compose up -d --no-deps web
python3 verify.py --after-restart
```

后端变更同理更新 backend。数据库结构变更应先备份并单独执行经过审查的迁移脚本。保留上个镜像及 compose 配置即可回滚镜像。每次发布还应在浏览器验证登录页面和受影响的功能。

## GitHub 自动发布

推送到 main 后自动构建并更新已有服务器，配置步骤和回滚说明见 [ci/README.md](ci/README.md)。需一次性设置 GitHub Actions Secret `AGENTMALL_DEPLOY_SSH_KEY`。该密钥只允许应用发布，与维护用 SSH 密钥分开。
