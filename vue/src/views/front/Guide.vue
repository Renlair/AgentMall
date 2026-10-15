<template>
  <div class="guide-page">
    <!-- Top Hero Banner -->
    <section class="guide-hero">
      <div class="hero-copy">
        <div class="assistant-mark">
          <div class="mark-icon-wrap">
            <img src="@/assets/imgs/logo.png" alt="AI 导购">
          </div>
          <div class="mark-text">
            <span class="mark-title">AGENTMALL AI INTELLIGENCE</span>
            <span class="mark-sub">多智能体协同导购引擎 · 实时精准比选</span>
          </div>
        </div>
        <h1>告诉 AI 您的专属诉求，3秒生成精选清单</h1>
        <p>我们结合全网真实评价知识切片、实时仓储库存、预算范围及您的历史偏好，摒弃软文营销，为您量身甄选最值得购买的商品。</p>
      </div>

      <div class="hero-capabilities">
        <div class="cap-item">
          <span class="cap-dot"></span>
          <div>
            <strong>多维需求理解</strong>
            <small>精准拆解参数与预算</small>
          </div>
        </div>
        <div class="cap-item">
          <span class="cap-dot"></span>
          <div>
            <strong>实时库存校验</strong>
            <small>仓储直连拒绝缺货</small>
          </div>
        </div>
        <div class="cap-item">
          <span class="cap-dot"></span>
          <div>
            <strong>知识切片决策</strong>
            <small>客观提炼买家口碑</small>
          </div>
        </div>
        <div class="cap-item">
          <span class="cap-dot"></span>
          <div>
            <strong>可解释性推荐</strong>
            <small>明晰列出入选缘由</small>
          </div>
        </div>
      </div>
    </section>

    <!-- Workspace: 2 Column Layout -->
    <section class="guide-workspace">
      <!-- Left Column: Demand Input Form -->
      <div class="demand-card">
        <div class="card-section-head">
          <div class="head-title-wrap">
            <span class="step-badge">STEP 01</span>
            <h2>输入您的购物诉求</h2>
          </div>
          <div class="online-pill">
            <span class="live-dot"></span>
            <span>AI 在线</span>
          </div>
        </div>

        <!-- Prompt Suggestions -->
        <div class="suggestion-wrapper">
          <span class="sugg-label">快捷灵感：</span>
          <div class="suggestion-list">
            <button
              v-for="item in suggestions"
              :key="item"
              type="button"
              class="sugg-btn"
              @click="data.demandText = item"
            >
              {{ item }}
            </button>
          </div>
        </div>

        <!-- Textarea -->
        <div class="textarea-wrap">
          <el-input
            v-model="data.demandText"
            type="textarea"
            :rows="5"
            maxlength="500"
            show-word-limit
            resize="none"
            placeholder="例如：想买一台预算 5000 左右、适合大学生写代码和日常做设计的轻薄本，希望续航给力、键盘手感好..."
          />
        </div>

        <!-- Filters Grid: Budget & Reference Product -->
        <div class="condition-grid">
          <div class="condition-item">
            <label class="item-label">
              <span>预算上限 (元)</span>
            </label>
            <el-input-number
              v-model="data.budgetAmount"
              :min="0"
              :precision="2"
              :step="500"
              controls-position="right"
              style="width: 100%"
            />
          </div>

          <div class="condition-item">
            <label class="item-label">
              <span>对标相似商品</span>
              <small class="optional-tag">可选</small>
            </label>
            <el-select
              v-model="data.productId"
              clearable
              filterable
              placeholder="选择一件已有商品作为参考"
              style="width: 100%"
            >
              <el-option
                v-for="item in data.productOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </div>
        </div>

        <!-- Action Button -->
        <button
          class="btn-generate-rec"
          :disabled="data.generating"
          @click="generate"
        >
          <el-icon v-if="data.generating" class="is-loading"><Loading /></el-icon>
          <el-icon v-else><MagicStick /></el-icon>
          <span>{{ data.generating ? 'AI 正在分析知识库与库存...' : '开始生成智能推荐' }}</span>
        </button>

        <p class="privacy-note">
          <el-icon><Lock /></el-icon>
          <span>推荐过程仅用于本次导购决策，严格保障您的个人隐私安全</span>
        </p>
      </div>

      <!-- Right Column: Result Panel -->
      <div class="result-card" ref="resultRef">
        <div class="card-section-head result-head">
          <div class="head-title-wrap">
            <span class="step-badge step-badge-purple">STEP 02</span>
            <h2>AI 推荐方案</h2>
          </div>
          <el-tag
            v-if="data.currentTask"
            :type="statusType(data.currentTask.status)"
            effect="light"
            round
          >
            {{ statusName(data.currentTask.status) }}
          </el-tag>
        </div>

        <!-- Thinking State -->
        <div v-if="data.generating" class="status-panel thinking-state">
          <div class="thinking-avatar-pulse">
            <img src="@/assets/imgs/logo.png" alt="AI Agent">
          </div>
          <div class="thinking-dots">
            <span></span><span></span><span></span>
          </div>
          <h3>正在理解您的诉求并筛选全网候选</h3>
          <p>正在执行：用户画像提取 → 商品知识召回 → 真实评价分析 → 实时价格库存校验</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="!data.currentTask" class="status-panel empty-state">
          <div class="empty-icon-box">
            <el-icon :size="40"><ChatLineSquare /></el-icon>
          </div>
          <h3>您的专属推荐清单将在这里展示</h3>
          <p>在左侧输入具体的购买需求与预算，AI 将基于真实库存为您定制最具性价比的精选好物。</p>
        </div>

        <!-- Result Content -->
        <template v-else>
          <div class="task-info-strip">
            <div class="task-main-text">
              <span class="task-no">{{ data.currentTask.taskNo }}</span>
              <p class="task-demand">“{{ data.currentTask.demandText }}”</p>
            </div>
            <time class="task-time">{{ data.currentTask.executeTime || data.currentTask.createTime }}</time>
          </div>

          <!-- Failed State -->
          <div v-if="data.currentTask.status === 'FAILED'" class="failed-box">
            <el-icon :size="24" class="failed-icon"><WarningFilled /></el-icon>
            <div>
              <strong>本次暂未匹配到符合条件的商品</strong>
              <p>{{ data.currentTask.executeMessage || '建议放宽预算限制，或补充更具体的商品特征与用途后重试。' }}</p>
            </div>
          </div>

          <!-- Recommendations List -->
          <div v-else-if="data.recommendations.length" class="recommendation-list">
            <article
              v-for="item in data.recommendations"
              :key="item.id"
              class="recommendation-item"
              @click="goDetail(item)"
            >
              <div class="rank-ribbon">TOP {{ item.recommendRank }}</div>

              <div class="rec-image-wrap">
                <el-image
                  class="rec-product-image"
                  :src="item.productImage"
                  fit="cover"
                >
                  <template #error>
                    <div class="image-fallback">
                      <el-icon><Picture /></el-icon>
                    </div>
                  </template>
                </el-image>
              </div>

              <div class="rec-content">
                <div class="rec-header-row">
                  <h3 class="rec-title" :title="item.productName">{{ item.productName }}</h3>
                  <span class="match-score-pill">
                    <el-icon><Sunny /></el-icon>
                    {{ item.recommendScore }}% 匹配
                  </span>
                </div>

                <div class="rec-reason-box">
                  <span class="reason-tag">推荐理由</span>
                  <p>{{ item.recommendReason }}</p>
                </div>

                <p v-if="item.evidenceSummary" class="rec-evidence">
                  <el-icon><Document /></el-icon>
                  <span>{{ item.evidenceSummary }}</span>
                </p>

                <div class="rec-meta-row" @click.stop>
                  <div class="rec-price">
                    <span class="curr">¥</span>
                    <span class="price-val">{{ formatMoney(item.priceSnapshot) }}</span>
                    <del v-if="Number(item.originalPriceSnapshot) > Number(item.priceSnapshot)" class="del-price">
                      ¥{{ formatMoney(item.originalPriceSnapshot) }}
                    </del>
                  </div>

                  <span class="rec-stock">
                    现货余 {{ item.availableQuantity }} 件
                  </span>

                  <button class="btn-rec-cart" @click="addCart(item)">
                    <el-icon><ShoppingCart /></el-icon>
                    <span>加入购物车</span>
                  </button>
                </div>
              </div>
            </article>
          </div>

          <div v-else class="loading-result">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>推荐明细加载中...</span>
          </div>
        </template>
      </div>
    </section>

    <!-- Bottom History Section -->
    <section class="history-card">
      <div class="card-section-head">
        <div class="head-title-wrap">
          <span class="step-badge step-badge-gray">HISTORY</span>
          <h2>历史导购记录</h2>
        </div>
        <span class="history-tip">点击历史卡片可快速回溯推荐方案</span>
      </div>

      <div v-if="data.history.length" class="history-grid">
        <div
          v-for="item in data.history"
          :key="item.id"
          class="history-item"
          :class="{ active: data.currentTask?.id === item.id }"
        >
          <div class="history-main" @click="selectTask(item)">
            <span class="history-dot" :class="item.status.toLowerCase()"></span>
            <div class="history-text">
              <strong :title="item.demandText">{{ item.demandText }}</strong>
              <small>{{ item.taskNo }} · {{ item.executeTime || item.createTime }}</small>
            </div>
            <span class="history-status-tag">{{ statusName(item.status) }} →</span>
          </div>

          <button
            class="history-del-btn"
            title="删除此记录"
            @click.stop="delTask(item)"
          >
            <el-icon><Delete /></el-icon>
          </button>
        </div>
      </div>

      <div v-else class="history-empty">
        <p>暂无历史导购记录，快在上方提交一次购物需求试试吧</p>
      </div>
    </section>
  </div>
</template>

<script setup>
import { nextTick, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import request from '@/utils/request.js';
import router from '@/router/index.js';

const suggestions = [
  '5000 元左右的高性能轻薄办公本',
  '送父母的智能健康养生家电',
  '通勤降噪且音质出色的无线蓝牙耳机',
  '久坐护腰的人体工学电脑椅'
];

const resultRef = ref();

const data = reactive({
  user: JSON.parse(localStorage.getItem('sys-user') || '{}'),
  demandText: '',
  budgetAmount: 5000,
  productId: null,
  productOptions: [],
  generating: false,
  currentTask: null,
  recommendations: [],
  history: []
});

const checkLogin = () => {
  if (!data.user.id || !data.user.token) {
    ElMessage.warning('请先登录后使用 AI 智能导购');
    router.push('/login');
    return false;
  }
  return true;
};

const formatMoney = (value) => Number(value || 0).toFixed(2);

const statusName = (status) => {
  if (status === 'DONE') return '推荐已生成';
  if (status === 'FAILED') return '暂未匹配';
  return '分析中';
};

const statusType = (status) => {
  if (status === 'DONE') return 'success';
  if (status === 'FAILED') return 'danger';
  return 'warning';
};

const loadProducts = () => {
  request.get('/product/selectAll', { params: { status: 'ON_SALE' } }).then((res) => {
    if (res.code === '200') data.productOptions = res.data || [];
  });
};

const loadRecommendations = (taskId) => {
  data.recommendations = [];
  if (!taskId) return Promise.resolve();
  return request.get('/shoppingRecommendation/selectAll', {
    params: { taskId, userId: data.user.id }
  }).then((res) => {
    if (res.code === '200') data.recommendations = res.data || [];
  });
};

const loadHistory = (autoSelect = true) => {
  if (!checkLogin()) return;
  request.get('/shoppingGuideTask/selectAll', {
    params: { userId: data.user.id }
  }).then((res) => {
    if (res.code !== '200') return;
    data.history = (res.data || []).slice(0, 8);
    if (autoSelect && !data.currentTask && data.history.length) {
      selectTask(data.history[0]);
    }
  });
};

const delTask = (item) => {
  ElMessageBox.confirm('删除后该导购记录与对应的推荐清单将无法恢复，确定删除吗？', '删除提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    request.delete('/shoppingGuideTask/delete/' + item.id).then((res) => {
      if (res.code !== '200') {
        ElMessage.error(res.msg);
        return;
      }
      ElMessage.success('记录已成功删除');
      if (data.currentTask?.id === item.id) {
        data.currentTask = null;
        data.recommendations = [];
      }
      loadHistory(!data.currentTask);
    });
  }).catch(() => {});
};

const selectTask = (task) => {
  data.currentTask = { ...task };
  if (task.status === 'DONE') {
    loadRecommendations(task.id);
  } else {
    data.recommendations = [];
  }
  nextTick(() => {
    resultRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
};

const generate = async () => {
  if (!checkLogin()) return;
  if (!data.demandText.trim()) {
    ElMessage.warning('请先输入您的购物诉求');
    return;
  }
  data.generating = true;
  data.currentTask = null;
  data.recommendations = [];
  try {
    const addRes = await request.post('/shoppingGuideTask/add', {
      userId: data.user.id,
      demandText: data.demandText.trim(),
      budgetAmount: data.budgetAmount,
      productId: data.productId
    });
    if (addRes.code !== '200' || !addRes.data?.id) {
      ElMessage.error(addRes.msg || '导购任务提交失败');
      return;
    }
    const executeRes = await request.post('/shoppingGuideTask/execute/' + addRes.data.id);
    if (executeRes.code !== '200') {
      ElMessage.error(executeRes.msg || 'AI 导购执行失败');
      return;
    }
    data.currentTask = executeRes.data;
    await loadRecommendations(executeRes.data.id);
    loadHistory(false);
    ElMessage.success(executeRes.data.status === 'DONE' ? '推荐方案已成功生成' : '本次暂未匹配到合适商品');
  } catch (error) {
    ElMessage.error(error?.message || 'AI 导购服务繁忙，请稍后重试');
  } finally {
    data.generating = false;
  }
};

const goDetail = (item) => {
  router.push('/front/product/' + item.productId);
};

const addCart = (item) => {
  request.post('/shoppingCart/add', {
    userId: data.user.id,
    productId: item.productId,
    quantity: 1
  }).then((res) => {
    if (res.code === '200') ElMessage.success('已加入购物车');
    else ElMessage.error(res.msg);
  });
};

loadProducts();
loadHistory();
</script>

<style scoped>
.guide-page {
  max-width: 1240px;
  margin: 0 auto;
  padding: 24px 20px 60px;
  color: #0f172a;
}

/* =========================================================
   Hero Banner
   ========================================================= */
.guide-hero {
  background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
  border-radius: 24px;
  padding: 38px 44px;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 36px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 16px 36px -8px rgba(15, 23, 42, 0.25);
}

.assistant-mark {
  display: flex;
  align-items: center;
  gap: 12px;
}

.mark-icon-wrap {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.mark-icon-wrap img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.mark-text {
  display: flex;
  flex-direction: column;
}

.mark-title {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.1em;
  color: #a5b4fc;
}

.mark-sub {
  font-size: 12px;
  color: #cbd5e1;
}

.hero-copy h1 {
  margin: 14px 0 10px;
  font-size: 30px;
  font-weight: 800;
  letter-spacing: -0.02em;
  line-height: 1.3;
}

.hero-copy p {
  margin: 0;
  font-size: 14px;
  line-height: 1.7;
  color: #cbd5e1;
  max-width: 620px;
}

.hero-capabilities {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  width: 320px;
  flex-shrink: 0;
}

.cap-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  padding: 12px;
  border-radius: 12px;
}

.cap-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #38bdf8;
  margin-top: 5px;
  flex-shrink: 0;
  box-shadow: 0 0 8px #38bdf8;
}

.cap-item strong {
  display: block;
  font-size: 13px;
  color: #ffffff;
}

.cap-item small {
  display: block;
  font-size: 11px;
  color: #94a3b8;
  margin-top: 2px;
}

/* =========================================================
   Workspace 2-Column
   ========================================================= */
.guide-workspace {
  display: grid;
  grid-template-columns: 440px 1fr;
  gap: 20px;
  margin-top: 24px;
}

.demand-card,
.result-card,
.history-card {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 28px;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.03);
}

.card-section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.head-title-wrap {
  display: flex;
  align-items: center;
  gap: 10px;
}

.step-badge {
  font-size: 11px;
  font-weight: 800;
  padding: 3px 8px;
  border-radius: 6px;
  background: #eef2ff;
  color: #4f46e5;
  letter-spacing: 0.04em;
}

.step-badge-purple {
  background: #f5f3ff;
  color: #7c3aed;
}

.step-badge-gray {
  background: #f1f5f9;
  color: #475569;
}

.card-section-head h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: #0f172a;
}

.online-pill {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 9999px;
  background: #ecfdf5;
  color: #059669;
  font-size: 12px;
  font-weight: 600;
}

.live-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #10b981;
}

/* Prompt Suggestions */
.suggestion-wrapper {
  margin-bottom: 16px;
}

.sugg-label {
  font-size: 12px;
  color: #94a3b8;
  display: block;
  margin-bottom: 8px;
}

.suggestion-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.sugg-btn {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 9999px;
  padding: 5px 12px;
  font-size: 12px;
  color: #475569;
  cursor: pointer;
  transition: all 0.2s;
}

.sugg-btn:hover {
  background: #eef2ff;
  color: #4f46e5;
  border-color: #c7d2fe;
}

.textarea-wrap :deep(.el-textarea__inner) {
  border-radius: 14px;
  background: #f8fafc;
  padding: 14px;
  font-size: 14px;
  line-height: 1.6;
  border-color: #e2e8f0;
  transition: all 0.2s;
}

.textarea-wrap :deep(.el-textarea__inner:focus) {
  background: #ffffff;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.condition-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-top: 18px;
}

.item-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 12.5px;
  font-weight: 600;
  color: #334155;
  margin-bottom: 8px;
}

.optional-tag {
  color: #94a3b8;
  font-weight: 400;
}

.btn-generate-rec {
  width: 100%;
  margin-top: 24px;
  padding: 14px;
  border-radius: 14px;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  color: #ffffff;
  font-size: 15px;
  font-weight: 700;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 6px 18px rgba(79, 70, 229, 0.3);
  transition: all 0.25s;
}

.btn-generate-rec:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 24px rgba(79, 70, 229, 0.4);
}

.btn-generate-rec:disabled {
  opacity: 0.7;
  cursor: wait;
}

.privacy-note {
  margin: 14px 0 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-size: 12px;
  color: #94a3b8;
}

/* =========================================================
   Result Card
   ========================================================= */
.result-head {
  padding-bottom: 16px;
  border-bottom: 1px solid #f1f5f9;
}

.status-panel {
  min-height: 420px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 40px 20px;
}

.empty-icon-box {
  width: 72px;
  height: 72px;
  border-radius: 20px;
  background: #f1f5f9;
  color: #94a3b8;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.status-panel h3 {
  margin: 0;
  font-size: 17px;
  color: #0f172a;
}

.status-panel p {
  margin: 8px 0 0;
  font-size: 13.5px;
  color: #64748b;
  max-width: 440px;
  line-height: 1.6;
}

.thinking-avatar-pulse img {
  width: 64px;
  height: 64px;
  border-radius: 18px;
  object-fit: cover;
  box-shadow: 0 8px 24px rgba(79, 70, 229, 0.2);
}

.thinking-dots {
  display: flex;
  gap: 6px;
  margin: 16px 0;
}

.thinking-dots span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4f46e5;
  animation: bounce 1.4s infinite ease-in-out both;
}

.thinking-dots span:nth-child(1) { animation-delay: -0.32s; }
.thinking-dots span:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.task-info-strip {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 14px 18px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  margin: 16px 0;
  gap: 16px;
}

.task-no {
  font-size: 11px;
  font-weight: 700;
  color: #4f46e5;
}

.task-demand {
  margin: 4px 0 0;
  font-size: 13.5px;
  color: #1e293b;
  font-weight: 600;
}

.task-time {
  font-size: 11px;
  color: #94a3b8;
  white-space: nowrap;
}

.failed-box {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  background: #fef2f2;
  border: 1px solid #fee2e2;
  border-radius: 14px;
  padding: 20px;
  margin-top: 16px;
}

.failed-icon {
  color: #ef4444;
  margin-top: 2px;
}

.failed-box strong {
  display: block;
  font-size: 14px;
  color: #991b1b;
}

.failed-box p {
  margin: 6px 0 0;
  font-size: 13px;
  color: #b91c1c;
  line-height: 1.5;
}

/* Recommendation Cards */
.recommendation-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 16px;
}

.recommendation-item {
  position: relative;
  display: grid;
  grid-template-columns: 110px 1fr;
  gap: 18px;
  padding: 16px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.2s;
  overflow: hidden;
}

.recommendation-item:hover {
  border-color: #c7d2fe;
  box-shadow: 0 8px 24px -4px rgba(79, 70, 229, 0.08);
  transform: translateY(-2px);
}

.rank-ribbon {
  position: absolute;
  top: 0;
  left: 0;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  color: #ffffff;
  font-size: 10px;
  font-weight: 800;
  padding: 3px 10px;
  border-radius: 0 0 10px 0;
  z-index: 2;
}

.rec-image-wrap {
  width: 110px;
  height: 110px;
  border-radius: 12px;
  overflow: hidden;
  background: #f1f5f9;
}

.rec-product-image {
  width: 100%;
  height: 100%;
}

.rec-content {
  display: flex;
  flex-direction: column;
}

.rec-header-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.rec-title {
  margin: 0;
  font-size: 15px;
  font-weight: 700;
  color: #0f172a;
  line-height: 1.4;
}

.rec-title:hover {
  color: #4f46e5;
}

.match-score-pill {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: #ecfdf5;
  color: #059669;
  font-size: 11px;
  font-weight: 700;
  padding: 3px 8px;
  border-radius: 9999px;
  white-space: nowrap;
}

.rec-reason-box {
  background: #f8fafc;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 8px 0;
}

.reason-tag {
  font-size: 10px;
  font-weight: 700;
  color: #4f46e5;
  display: block;
  margin-bottom: 2px;
}

.rec-reason-box p {
  margin: 0;
  font-size: 12.5px;
  color: #334155;
  line-height: 1.5;
}

.rec-evidence {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 0 0 10px;
  font-size: 12px;
  color: #64748b;
}

.rec-meta-row {
  margin-top: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.rec-price {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.rec-price .curr {
  font-size: 13px;
  font-weight: 700;
  color: #ef4444;
}

.rec-price .price-val {
  font-size: 18px;
  font-weight: 800;
  color: #ef4444;
}

.rec-price .del-price {
  font-size: 12px;
  color: #94a3b8;
  margin-left: 6px;
}

.rec-stock {
  font-size: 12px;
  color: #64748b;
  margin-right: auto;
}

.btn-rec-cart {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 8px;
  background: #0f172a;
  color: #ffffff;
  border: none;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-rec-cart:hover {
  background: #4f46e5;
}

.loading-result {
  min-height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #64748b;
  font-size: 14px;
}

/* =========================================================
   History Card
   ========================================================= */
.history-card {
  margin-top: 24px;
}

.history-tip {
  font-size: 12px;
  color: #94a3b8;
}

.history-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.history-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  transition: all 0.2s;
}

.history-item:hover,
.history-item.active {
  border-color: #4f46e5;
  background: #ffffff;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.08);
}

.history-main {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
  cursor: pointer;
}

.history-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #f59e0b;
  flex-shrink: 0;
}

.history-dot.done {
  background: #10b981;
}

.history-dot.failed {
  background: #ef4444;
}

.history-text {
  flex: 1;
  min-width: 0;
}

.history-text strong {
  display: block;
  font-size: 13px;
  color: #0f172a;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.history-text small {
  display: block;
  font-size: 11px;
  color: #94a3b8;
  margin-top: 2px;
}

.history-status-tag {
  font-size: 12px;
  font-weight: 600;
  color: #4f46e5;
  white-space: nowrap;
}

.history-del-btn {
  background: transparent;
  border: none;
  color: #cbd5e1;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: all 0.2s;
}

.history-del-btn:hover {
  color: #ef4444;
  background: #fef2f2;
}

.history-empty {
  padding: 30px;
  text-align: center;
  color: #94a3b8;
  font-size: 13px;
}

/* Responsive */
@media (max-width: 1024px) {
  .guide-hero {
    flex-direction: column;
    align-items: stretch;
  }
  .hero-capabilities {
    width: 100%;
  }
  .guide-workspace {
    grid-template-columns: 1fr;
  }
  .history-grid {
    grid-template-columns: 1fr;
  }
}
</style>
