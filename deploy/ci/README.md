# GitHub 自动部署

`main` 分支收到 push 后，GitHub Actions 构建 Linux amd64 前后端镜像，通过 SSH 上传并更新 121.40.212.142。也可在 Actions 中手动运行 Deploy AgentMall。PR 不运行发布任务。

服务器已有的 `/root/agentmall`、`.env`、MySQL 容器和数据库/上传卷被保留。发布不执行数据库迁移，不修改 Hermes、代理或模型密钥。正常更新有短暂服务中断。数据库结构变更需另行审查、备份和迁移，镜像回滚不能回滚数据结构。

## 一次性配置

管理员将此目录的 `install.sh`、`receive-release.py` 复制到服务器并运行 `bash install.sh`。此操作要求已有 AgentMall Docker 部署，不能用于初始化空服务器。

安装器创建 `agentmall-ci` 账号。该账号不加入 Docker 组，SSH 密钥强制执行 `/usr/local/sbin/agentmall-ci-deploy`，sudo 仅允许无参数运行该接收器。禁止交互终端、端口转发和普通 shell。维护人员的长期 SSH 密钥独立保存，不上传至 GitHub。

安装器在服务器 `/root/agentmall-ci-github-ed25519` 生成权限为 600 的专用私钥。项目所有者在自己的 Termius 终端私下查看并完整复制，将其填入 GitHub 仓库 **Settings → Secrets and variables → Actions → New repository secret**：

- Name：`AGENTMALL_DEPLOY_SSH_KEY`
- Secret：该专用私钥的完整内容，包括首尾标记行

不要把私钥发送到聊天、提交到 Git 或放入构建产物。保存 Secret 后，管理员应移除服务器上这份私钥及其 `.pub` 副本，只保留专用账号的 `authorized_keys` 公钥。若需轮换，重新生成并同步更新 GitHub Secret 和受限公钥。

SSH 主机公钥固定在 `known_hosts` 中。更换服务器时必须核验新主机指纹再更新此文件，不能关闭主机密钥验证。

## 发布和回滚

工作流为每次提交构建唯一标签 `agentmall-backend:git-<sha>` 与 `agentmall-web:git-<sha>`。接收器检查包结构、大小、SHA256、镜像标签和 Linux amd64 架构，再加载镜像，只重建 backend/web。包、服务器接收文件和构建上下文均不含运行期密钥。

上线检查验证登录页面及登录查询的 SQL 路径（随机不存在的账号应返回 5004），无需把管理员密码存入 GitHub。检查失败时恢复之前的前后端镜像并再次检查。每次发布后仍应检查改动涉及的功能。

- 当前发布：`/var/lib/agentmall-deploy/current.json`
- 发布日志及前版镜像覆盖：`/var/lib/agentmall-deploy/releases/<sha>/`
- 当前镜像覆盖配置：`/root/agentmall/compose.ci.yaml`

手动管理现有自动部署实例时，需要带上镜像覆盖配置：

```bash
cd /root/agentmall
docker compose -f compose.yaml -f compose.override.yaml -f compose.ci.yaml ps
```

手动回滚（root，先从 current.json 找到 previous.yaml 路径）：

```bash
cd /root/agentmall
docker compose -f compose.yaml -f compose.override.yaml -f /var/lib/agentmall-deploy/releases/<sha>/previous.yaml up -d --no-deps --force-recreate backend web
cp /var/lib/agentmall-deploy/releases/<sha>/previous.yaml compose.ci.yaml
```

不执行 `down -v` 或镜像全量清理。保留前一版应用镜像以支持回滚。注意磁盘用量；接收器在不足 5 GiB 可用空间时拒绝新发布。

## 接收器检查

```bash
python3 deploy/ci/test_receiver.py
```
