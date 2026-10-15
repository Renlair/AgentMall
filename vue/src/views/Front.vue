<template>
  <div class="front-wrapper">
    <!-- Top Announcement Strip -->
    <div class="front-announcement">
      <div>
        <span class="badge">PRO</span>
        <span>✨ AgentMall 2.0 全新上线：多智能体深度导购引擎 · 实时库存联动 · 正品假一赔十</span>
      </div>
      <div class="announcement-right">
        <span>客服热线: 400-800-8899</span>
        <span>·</span>
        <a @click="router.push('/front/guide')">开启智能导购体验 →</a>
      </div>
    </div>

    <!-- Frosted Sticky Header -->
    <header class="front-header">
      <div class="front-header-left" @click="router.push('/front/home')">
        <div class="brand-icon-wrapper">
          <img src="@/assets/imgs/logo.png" alt="AgentMall">
        </div>
        <div class="brand-text">
          <div class="brand-title">
            AgentMall
            <span class="brand-badge">AI 2.0</span>
          </div>
          <span class="brand-subtitle">新一代 AI 智能电商平台</span>
        </div>
      </div>

      <!-- Pill Nav Tabs -->
      <nav class="front-header-center">
        <router-link
          to="/front/home"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/home' }"
        >
          <el-icon><Shop /></el-icon>
          <span>商城首页</span>
        </router-link>

        <router-link
          to="/front/guide"
          class="nav-pill-item ai-pill"
          :class="{ active: currentPath === '/front/guide' }"
        >
          <el-icon><MagicStick /></el-icon>
          <span>AI 智能导购</span>
          <span class="ai-sparkle-tag">AI</span>
        </router-link>

        <router-link
          to="/front/favorite"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/favorite' }"
        >
          <el-icon><Star /></el-icon>
          <span>我的收藏</span>
        </router-link>

        <router-link
          to="/front/cart"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/cart' }"
        >
          <el-icon><ShoppingCart /></el-icon>
          <span>购物车</span>
        </router-link>

        <router-link
          to="/front/order"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/order' }"
        >
          <el-icon><Tickets /></el-icon>
          <span>我的订单</span>
        </router-link>

        <router-link
          to="/front/wallet"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/wallet' }"
        >
          <el-icon><Wallet /></el-icon>
          <span>我的钱包</span>
        </router-link>

        <router-link
          to="/front/person"
          class="nav-pill-item"
          :class="{ active: currentPath === '/front/person' }"
        >
          <el-icon><User /></el-icon>
          <span>个人中心</span>
        </router-link>
      </nav>

      <!-- User Area / Auth Buttons -->
      <div class="front-header-right">
        <template v-if="!data.user.id">
          <button class="btn-login" @click="router.push('/login')">登录</button>
          <button class="btn-register" @click="router.push('/register')">免费注册</button>
        </template>

        <template v-else>
          <el-dropdown trigger="hover">
            <div class="user-profile-capsule">
              <img
                class="user-avatar-img"
                :src="data.user.avatar || defaultAvatar"
                alt="Avatar"
              >
              <div class="user-info-text">
                <span class="user-name">{{ data.user.name || '买家用户' }}</span>
                <span class="user-role-tag">已认证会员</span>
              </div>
              <el-icon :size="12" style="color: #94a3b8;"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="router.push('/front/person')">
                  <el-icon><User /></el-icon> 个人资料
                </el-dropdown-item>
                <el-dropdown-item @click="router.push('/front/wallet')">
                  <el-icon><Wallet /></el-icon> 账户钱包
                </el-dropdown-item>
                <el-dropdown-item @click="router.push('/front/order')">
                  <el-icon><Tickets /></el-icon> 历史订单
                </el-dropdown-item>
                <el-dropdown-item divided @click="logout" style="color: #ef4444;">
                  <el-icon><SwitchButton /></el-icon> 退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
      </div>
    </header>

    <!-- Main Body -->
    <main class="main-body">
      <RouterView @updateUser="updateUser" />
    </main>

    <!-- Refined Minimalist Footer -->
    <footer class="front-footer">
      <div class="footer-container">
        <div class="footer-top">
          <div class="footer-brand">
            <h4>
              <img src="@/assets/imgs/logo.png" style="width: 24px; height: 24px; border-radius: 6px;" alt="">
              AgentMall 智能商城
            </h4>
            <p>基于大语言模型、知识库切片检索与多智能体协同架构，重构电商搜索与选品体验，懂你所需，省心决策。</p>
            <div class="footer-status-pill">
              <span class="status-dot"></span>
              <span>AI 服务集群正常运行 · 决策延迟 42ms</span>
            </div>
          </div>
          <div class="footer-column">
            <h5>智能导购</h5>
            <ul>
              <li><a @click="router.push('/front/guide')">个性化需求分析</a></li>
              <li><a @click="router.push('/front/guide')">参数智能对比</a></li>
              <li><a @click="router.push('/front/guide')">真实口碑摘要</a></li>
              <li><a @click="router.push('/front/home')">新品热卖榜单</a></li>
            </ul>
          </div>
          <div class="footer-column">
            <h5>品质服务</h5>
            <ul>
              <li><a href="javascript:void(0)">100% 官方正品保障</a></li>
              <li><a href="javascript:void(0)">七天无理由退换货</a></li>
              <li><a href="javascript:void(0)">顺丰极速履约送达</a></li>
              <li><a href="javascript:void(0)">全天候智能问答支持</a></li>
            </ul>
          </div>
          <div class="footer-column">
            <h5>关于平台</h5>
            <ul>
              <li><a href="javascript:void(0)">知识库与模型架构</a></li>
              <li><a href="javascript:void(0)">数据隐私与安全规范</a></li>
              <li><a href="javascript:void(0)">开发者与商家合作</a></li>
              <li><a href="javascript:void(0)">服务条款及免责声明</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <span>© 2026 AgentMall Platform. All rights reserved. 现代化 AI 赋能消费体验。</span>
          <span>Designed with precision & craftsmanship</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, reactive } from "vue";
import { useRoute } from "vue-router";
import router from "@/router/index.js";
import defaultAvatar from "@/assets/imgs/avatar.png";

const route = useRoute();
const currentPath = computed(() => route.path);

const data = reactive({
  user: JSON.parse(localStorage.getItem('sys-user') || '{}'),
});

const logout = () => {
  localStorage.removeItem('sys-user');
  router.push('/login');
};

const updateUser = () => {
  data.user = JSON.parse(localStorage.getItem('sys-user') || '{}');
};
</script>

<style scoped>
@import "@/assets/css/front.css";
</style>
