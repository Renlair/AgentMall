<template>
  <div class="manager-container">
    <div class="manager-header">
      <div class="manager-header-left">
        <router-link to="/manager/home" class="manager-brand" aria-label="AgentMall 控制台首页">
          <svg viewBox="0 0 32 36" fill="none" aria-hidden="true"><path d="M4 11h24l2 22H2L4 11Z" stroke="currentColor" stroke-width="2"/><path d="M10 13V8a6 6 0 0 1 12 0v5" stroke="currentColor" stroke-width="2"/></svg>
          <span>AgentMall<small>智选商城 · 控制台</small></span>
        </router-link>
      </div>
      <div class="manager-header-center">
        <button class="sidebar-toggle" type="button" :aria-expanded="sidebarOpen" aria-controls="manager-navigation" :aria-label="sidebarOpen ? '收起导航' : '展开导航'" @click="sidebarOpen = !sidebarOpen"><el-icon><Menu /></el-icon></button>
        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ path: '/manager/home' }">工作台</el-breadcrumb-item>
          <el-breadcrumb-item v-if="router.currentRoute.value.path !== '/manager/home'">{{ router.currentRoute.value.meta.name }}</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div class="manager-header-right">
        <router-link class="store-link" to="/front/home">前往商城 <el-icon><TopRight /></el-icon></router-link>
        <el-dropdown trigger="click" popper-class="manager-account-menu">
          <button type="button" class="account-button" aria-label="账号菜单">
            <el-avatar :size="32" :src="data.user.avatar">{{ (data.user.name || data.user.username || '管').slice(0, 1) }}</el-avatar>
            <span class="account-name">{{ data.user.name || data.user.username || '管理员' }}</span><el-icon><ArrowDown /></el-icon>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="router.push('/manager/person')">个人资料</el-dropdown-item>
              <el-dropdown-item @click="router.push('/manager/password')">修改密码</el-dropdown-item>
              <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    <div class="manager-body">
      <button v-if="sidebarOpen" class="sidebar-backdrop" type="button" aria-label="关闭导航" @click="sidebarOpen = false"></button>
      <aside id="manager-navigation" class="manager-main-left" :class="{ 'is-open': sidebarOpen }" aria-label="控制台导航" @keydown.esc="sidebarOpen = false">
        <div class="navigation-label">WORKSPACE <span>日常管理</span></div>
        <el-menu :default-active="router.currentRoute.value.path" :default-openeds="data.openeds" router>
          <el-menu-item index="/manager/home">
            <el-icon><HomeFilled /></el-icon>
            <span>工作台概览</span>
          </el-menu-item>

          <!-- 普通商城管理：用户、商品、订单、评价、售后等传统电商功能 -->
          <el-sub-menu index="shop">
            <template #title>
              <el-icon><Goods /></el-icon>
              <span>商城管理</span>
            </template>
            <el-menu-item index="/manager/user">
              <el-icon><User /></el-icon>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="/manager/productCategory">
              <el-icon><Menu /></el-icon>
              <span>商品分类</span>
            </el-menu-item>
            <el-menu-item index="/manager/productBrand">
              <el-icon><CollectionTag /></el-icon>
              <span>商品品牌</span>
            </el-menu-item>
            <el-menu-item index="/manager/product">
              <el-icon><Goods /></el-icon>
              <span>商品管理</span>
            </el-menu-item>
            <el-menu-item index="/manager/productDetail">
              <el-icon><Document /></el-icon>
              <span>商品详情与参数</span>
            </el-menu-item>
            <el-menu-item index="/manager/shopOrder">
              <el-icon><Tickets /></el-icon>
              <span>订单管理</span>
            </el-menu-item>
            <el-menu-item index="/manager/productReview">
              <el-icon><ChatDotRound /></el-icon>
              <span>商品评价</span>
            </el-menu-item>
            <el-menu-item index="/manager/afterSaleRule">
              <el-icon><Service /></el-icon>
              <span>售后规则</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- AI 基础配置：模型、Prompt、Function Calling 工具与工具调试 -->
          <el-sub-menu index="aiConfig">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>AI 基础配置</span>
            </template>
            <el-menu-item index="/manager/aiModelConfig">
              <el-icon><Connection /></el-icon>
              <span>AI模型配置</span>
            </el-menu-item>
            <el-menu-item index="/manager/promptTemplate">
              <el-icon><Tickets /></el-icon>
              <span>Prompt模板</span>
            </el-menu-item>
            <el-menu-item index="/manager/functionTool">
              <el-icon><Connection /></el-icon>
              <span>Function Tool</span>
            </el-menu-item>
            <el-menu-item index="/manager/productToolDebug">
              <el-icon><DataAnalysis /></el-icon>
              <span>商品工具调试</span>
            </el-menu-item>
            <el-menu-item index="/manager/businessToolDebug">
              <el-icon><DataAnalysis /></el-icon>
              <span>业务工具调试</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- AI 知识库(RAG)：商品知识、切片与向量检索 -->
          <el-sub-menu index="aiRag">
            <template #title>
              <el-icon><Notebook /></el-icon>
              <span>AI 知识库(RAG)</span>
            </template>
            <el-menu-item index="/manager/productKnowledge">
              <el-icon><Notebook /></el-icon>
              <span>商品知识库</span>
            </el-menu-item>
            <el-menu-item index="/manager/productKnowledgeChunk">
              <el-icon><Files /></el-icon>
              <span>商品知识切片</span>
            </el-menu-item>
            <el-menu-item index="/manager/productKnowledgeEmbedding">
              <el-icon><DataAnalysis /></el-icon>
              <span>Embedding检索</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- AI 智能导购与运营：Agent 导购、运行记录、推荐对比问答与运营分析 -->
          <el-sub-menu index="aiAgent">
            <template #title>
              <el-icon><MagicStick /></el-icon>
              <span>AI 智能导购与运营</span>
            </template>
            <el-menu-item index="/manager/shoppingGuideTask">
              <el-icon><Service /></el-icon>
              <span>AI智能导购任务</span>
            </el-menu-item>
            <el-menu-item index="/manager/agentRun">
              <el-icon><DataAnalysis /></el-icon>
              <span>Agent Run运行记录</span>
            </el-menu-item>
            <el-menu-item index="/manager/agentStep">
              <el-icon><DataAnalysis /></el-icon>
              <span>Agent Step执行步骤</span>
            </el-menu-item>
            <el-menu-item index="/manager/shoppingRecommendation">
              <el-icon><Goods /></el-icon>
              <span>AI推荐商品</span>
            </el-menu-item>
            <el-menu-item index="/manager/shoppingQa">
              <el-icon><ChatDotRound /></el-icon>
              <span>AI商品问答</span>
            </el-menu-item>
            <el-menu-item index="/manager/shoppingReviewAnalysis">
              <el-icon><DataAnalysis /></el-icon>
              <span>AI评价分析</span>
            </el-menu-item>
            <el-menu-item index="/manager/shoppingGrowthReport">
              <el-icon><DataAnalysis /></el-icon>
              <span>AI运营增长报告</span>
            </el-menu-item>
          </el-sub-menu>

          <el-menu-item @click="logout">
            <el-icon><Bell /></el-icon>
            <span>退出系统</span>
          </el-menu-item>
        </el-menu>
        <div class="sidebar-note"><span class="sidebar-note-line"></span><p>为生活，选点好的。</p><small>AgentMall · 智选商城</small></div>
      </aside>
      <main class="manager-main-right" id="manager-content">
        <RouterView @updateUser="updateUser" />
        <footer class="manager-footer"><span>AgentMall · 智选商城</span><span>把每一份用心，带进日常。</span></footer>
      </main>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, watch } from "vue";
import router from "@/router/index.js";
import { ElMessage } from "element-plus";
import { ArrowDown, TopRight, Bell, ChatDotRound, CollectionTag, Connection, DataAnalysis, Document, Files, Goods, HomeFilled, MagicStick, Menu, Notebook, Service, Setting, Tickets, User } from "@element-plus/icons-vue";

const sidebarOpen = ref(false)
watch(() => router.currentRoute.value.path, () => { sidebarOpen.value = false })

// 各二级菜单分组包含的路由路径，用于进入页面时自动展开对应分组
const menuGroups = {
  shop: ['/manager/user', '/manager/productCategory', '/manager/productBrand', '/manager/product', '/manager/productDetail', '/manager/shopOrder', '/manager/productReview', '/manager/afterSaleRule'],
  aiConfig: ['/manager/aiModelConfig', '/manager/promptTemplate', '/manager/functionTool', '/manager/productToolDebug', '/manager/businessToolDebug'],
  aiRag: ['/manager/productKnowledge', '/manager/productKnowledgeChunk', '/manager/productKnowledgeEmbedding'],
  aiAgent: ['/manager/shoppingGuideTask', '/manager/agentRun', '/manager/agentStep', '/manager/shoppingRecommendation', '/manager/shoppingQa', '/manager/shoppingReviewAnalysis', '/manager/shoppingGrowthReport']
}

// 根据当前路由找到它所属的分组，只默认展开当前所在分组，其余分组保持收缩
const currentPath = router.currentRoute.value.path
const activeGroup = Object.keys(menuGroups).find(key => menuGroups[key].includes(currentPath))

const data = reactive({
  user: JSON.parse(localStorage.getItem('sys-user') || '{}'),
  // 默认仅展开当前页面所属分组
  openeds: activeGroup ? [activeGroup] : []
})

watch(() => router.currentRoute.value.path, (path) => {
  const group = Object.keys(menuGroups).find(key => menuGroups[key].includes(path))
  data.openeds = group ? [group] : []
})

const logout = () => {
  localStorage.removeItem('sys-user')
  router.push('/login')
}

const updateUser = () => {
  data.user = JSON.parse(localStorage.getItem('sys-user') || '{}')
}

if (!data.user.id) {
  logout()
  ElMessage.error('请登录')
}
</script>

<style src="@/assets/css/manager.css"></style>



