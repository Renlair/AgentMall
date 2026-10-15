<template>
  <div class="shop-home">
    <!-- Hero Section: Modern Bento / Tech-Commerce Showcase -->
    <section class="hero-section">
      <div class="hero-content">
        <div class="hero-left">
          <div class="hero-badge">
            <span class="badge-dot"></span>
            <span>AgentMall 2.0 · 新一代 AI 智能决策商城</span>
          </div>

          <h1 class="hero-title">
            懂你所需，为您精准甄选<br />
            <span class="hero-title-gradient">每一件高品质好物</span>
          </h1>

          <p class="hero-desc">
            告别传统盲目比价与海量信息轰炸。AgentMall 聚合真实买家口碑、参数知识切片与实时库存核验，提供一站式贴心购物体验。
          </p>

          <!-- Search & Prompt Input Bar -->
          <div class="hero-search-wrapper">
            <div class="hero-search-box">
              <el-icon class="search-icon"><Search /></el-icon>
              <input
                v-model="data.name"
                class="hero-search-input"
                type="text"
                placeholder="搜索商品名称、卖点标签或描述..."
                @keyup.enter="loadProducts"
              />
              <button v-if="data.name" class="clear-btn" @click="data.name = ''; loadProducts()">
                <el-icon><CircleClose /></el-icon>
              </button>
              <button class="search-submit-btn" @click="loadProducts">
                搜索
              </button>
            </div>

            <button class="ai-guide-btn" @click="router.push('/front/guide')">
              <el-icon><MagicStick /></el-icon>
              <span>AI 帮我选</span>
            </button>
          </div>

          <!-- Quick Query Suggestions -->
          <div class="hero-tags">
            <span class="tags-label">热搜探索：</span>
            <span
              v-for="tag in quickTags"
              :key="tag"
              class="tag-chip"
              @click="quickSearch(tag)"
            >
              {{ tag }}
            </span>
          </div>
        </div>

        <!-- Hero Right: Interactive AI Assistant Showcase Card -->
        <div class="hero-right">
          <div class="ai-showcase-card">
            <div class="card-glow-bg"></div>
            <div class="card-header">
              <div class="agent-avatar-group">
                <div class="agent-avatar">
                  <img src="@/assets/imgs/logo.png" alt="AI Agent">
                  <span class="online-indicator"></span>
                </div>
                <div>
                  <div class="agent-name">AgentMall AI 导购助手</div>
                  <div class="agent-sub">多智能体实时协同分析中</div>
                </div>
              </div>
              <span class="agent-chip">智能决策引擎</span>
            </div>

            <!-- Dialogue Simulation Box -->
            <div class="dialogue-box">
              <div class="user-bubble">
                <span class="bubble-tag">我的需求</span>
                <p>“预算 5000 左右，想选一款适合写代码和做毕设的笔记本，希望轻薄、屏幕好且续航持久...”</p>
              </div>

              <div class="ai-response-bubble">
                <div class="ai-bubble-head">
                  <el-icon class="sparkle-icon"><Sunny /></el-icon>
                  <span>已完成 32 项核心参数比对与买家真实评价切片分析</span>
                </div>
                <div class="ai-stat-row">
                  <div class="stat-pill">
                    <span class="stat-val">98.9%</span>
                    <span class="stat-lbl">需求匹配度</span>
                  </div>
                  <div class="stat-pill">
                    <span class="stat-val">现货秒发</span>
                    <span class="stat-lbl">顺丰空运包邮</span>
                  </div>
                  <div class="stat-pill">
                    <span class="stat-val">保价 30 天</span>
                    <span class="stat-lbl">正品假一赔十</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Card Bottom CTA -->
            <button class="showcase-cta" @click="router.push('/front/guide')">
              <span>立即输入您的专属需求，体验 AI 导购</span>
              <el-icon><ArrowRight /></el-icon>
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Value Proposition Strip: 4 Quality Pillars -->
    <section class="features-bar">
      <div class="feature-item">
        <div class="feature-icon"><el-icon><CircleCheckFilled /></el-icon></div>
        <div class="feature-text">
          <h4>100% 官方正品保障</h4>
          <p>严苛品牌资质直供，假一赔十正品保障</p>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon"><el-icon><Van /></el-icon></div>
        <div class="feature-text">
          <h4>实时库存秒级履约</h4>
          <p>系统联动真实仓储，顺丰极速直邮到家</p>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon"><el-icon><MagicStick /></el-icon></div>
        <div class="feature-text">
          <h4>AI 真实知识切片决策</h4>
          <p>杜绝虚标软文，多维真实口碑深度提炼</p>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon"><el-icon><ShieldCheck /></el-icon></div>
        <div class="feature-text">
          <h4>七天无理由售后无忧</h4>
          <p>退换货专属绿色通道，平台担保极速退款</p>
        </div>
      </div>
    </section>

    <!-- Main Store Section: Category, Filters & Product Grid -->
    <section class="store-container" ref="productSection">
      <!-- Section Header -->
      <div class="store-header">
        <div>
          <h2 class="store-title">甄选好物清单</h2>
          <p class="store-subtitle">探索当下最受好评的精选热销爆款与科技单品</p>
        </div>
        <div class="product-count-badge">
          共收录 <span>{{ sortedProducts.length }}</span> 件优选商品
        </div>
      </div>

      <!-- Category Filter Pills Strip -->
      <div class="category-strip">
        <button
          :class="['cat-pill', data.categoryId === null ? 'active' : '']"
          @click="selectCategory(null)"
        >
          <el-icon><Grid /></el-icon>
          <span>全部商品</span>
        </button>

        <button
          v-for="cat in data.categories"
          :key="cat.id"
          :class="['cat-pill', data.categoryId === cat.id ? 'active' : '']"
          @click="selectCategory(cat.id)"
        >
          <span>{{ cat.name }}</span>
        </button>
      </div>

      <!-- Filter Controls Toolbar -->
      <div class="filter-toolbar">
        <div class="toolbar-left">
          <!-- Brand Selector -->
          <div class="brand-select-wrapper">
            <el-select
              v-model="data.brandId"
              clearable
              filterable
              placeholder="按品牌筛选"
              @change="loadProducts"
              @clear="loadProducts"
              style="width: 200px"
            >
              <el-option
                v-for="item in data.brands"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </el-select>
          </div>

          <!-- Sort Segmented Controls -->
          <div class="sort-tabs">
            <button
              :class="['sort-tab', sortType === 'default' ? 'active' : '']"
              @click="sortType = 'default'"
            >
              综合推荐
            </button>
            <button
              :class="['sort-tab', sortType === 'recommend' ? 'active' : '']"
              @click="sortType = 'recommend'"
            >
              仅看 AI 精选
            </button>
            <button
              :class="['sort-tab', sortType === 'priceAsc' ? 'active' : '']"
              @click="sortType = 'priceAsc'"
            >
              价格从低到高
            </button>
            <button
              :class="['sort-tab', sortType === 'priceDesc' ? 'active' : '']"
              @click="sortType = 'priceDesc'"
            >
              价格从高到低
            </button>
          </div>
        </div>

        <div class="toolbar-right">
          <button
            v-if="data.name || data.categoryId || data.brandId || sortType !== 'default'"
            class="reset-filters-btn"
            @click="resetAllFilters"
          >
            <el-icon><RefreshRight /></el-icon>
            <span>重置筛选</span>
          </button>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="!sortedProducts.length" class="empty-product-state">
        <div class="empty-icon-wrap">
          <el-icon :size="48"><Box /></el-icon>
        </div>
        <h3>暂未找到符合条件的商品</h3>
        <p>可以尝试调整搜索关键词、切换分类或重置品牌筛选条件</p>
        <button class="reset-action-btn" @click="resetAllFilters">
          查看全部在售商品
        </button>
      </div>

      <!-- Product Cards Grid -->
      <div class="product-grid" v-else>
        <div
          v-for="item in sortedProducts"
          :key="item.id"
          class="product-card"
          @click="goDetail(item)"
        >
          <!-- Card Image Header -->
          <div class="card-image-box">
            <el-image
              class="card-img"
              :src="item.coverImage"
              fit="cover"
              loading="lazy"
            >
              <template #error>
                <div class="image-fallback">
                  <el-icon :size="32"><Picture /></el-icon>
                </div>
              </template>
            </el-image>

            <!-- Floating Badges -->
            <div class="image-overlay-badges">
              <span v-if="item.isRecommend === 1" class="recommend-badge">
                <el-icon><StarFilled /></el-icon> AI 推荐
              </span>
              <span v-if="item.categoryName" class="category-badge">
                {{ item.categoryName }}
              </span>
            </div>

            <!-- Floating Favorite Heart Button -->
            <button
              class="fav-float-btn"
              title="收藏商品"
              @click.stop="addFavorite(item)"
            >
              <el-icon><Star /></el-icon>
            </button>
          </div>

          <!-- Card Body Content -->
          <div class="card-content">
            <div class="brand-row">
              <span class="brand-tag">{{ item.brandName || '精选品牌' }}</span>
              <span class="stock-status" :class="{ 'low-stock': item.stockQuantity < 10 }">
                {{ item.stockQuantity > 0 ? `现货 · 余 ${item.stockQuantity} 件` : '缺货登记' }}
              </span>
            </div>

            <h3 class="product-title" :title="item.name">
              {{ item.name }}
            </h3>

            <p class="product-selling-point">
              {{ item.sellingPoint || '官方自营正品，顺丰速达，品质保障' }}
            </p>

            <!-- Price & Action Section -->
            <div class="card-bottom">
              <div class="price-container">
                <span class="currency-symbol">¥</span>
                <span class="price-integer">{{ formatMoney(item.price).split('.')[0] }}</span>
                <span class="price-decimal">.{{ formatMoney(item.price).split('.')[1] }}</span>
                <del v-if="item.originalPrice && Number(item.originalPrice) > Number(item.price)" class="original-price">
                  ¥{{ formatMoney(item.originalPrice) }}
                </del>
              </div>

              <div class="card-actions" @click.stop>
                <button
                  class="btn-add-cart"
                  :disabled="item.stockQuantity <= 0"
                  @click="addCart(item)"
                  title="加入购物车"
                >
                  <el-icon><ShoppingCart /></el-icon>
                  <span>加购物车</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Bottom AI Assistant Promo Banner -->
    <section class="guide-banner-card">
      <div class="guide-banner-content">
        <div class="banner-badge">AI 选品智囊团</div>
        <h2>挑花了眼？把预算与需求告诉 AI</h2>
        <p>多智能体协同为您全维扫描在售商品，综合价格、真实评测与库存，3秒定制最合适您的推荐方案。</p>
        <button class="banner-cta-btn" @click="router.push('/front/guide')">
          <el-icon><MagicStick /></el-icon>
          <span>立即开启 AI 智能导购</span>
        </button>
      </div>
    </section>

    <!-- Floating Dock Shortcut -->
    <div class="floating-ai-dock" @click="router.push('/front/guide')" title="点击咨询 AI 导购">
      <div class="dock-pulse"></div>
      <el-icon :size="20"><MagicStick /></el-icon>
      <span>AI 导购</span>
    </div>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from "vue";
import request from "@/utils/request.js";
import { ElMessage } from "element-plus";
import router from "@/router/index.js";

const productSection = ref();
const sortType = ref('default');

const quickTags = [
  '轻薄便携本',
  '降噪耳机',
  '客制化键盘',
  '4K显示器',
  '人体工学椅'
];

const data = reactive({
  user: JSON.parse(localStorage.getItem('sys-user') || '{}'),
  products: [],
  categories: [],
  brands: [],
  name: null,
  categoryId: null,
  brandId: null
});

const formatMoney = (value) => {
  return Number(value || 0).toFixed(2);
};

const quickSearch = (tag) => {
  data.name = tag;
  loadProducts();
};

const resetAllFilters = () => {
  data.name = null;
  data.categoryId = null;
  data.brandId = null;
  sortType.value = 'default';
  loadProducts();
};

const goDetail = (product) => {
  router.push('/front/product/' + product.id);
};

const selectCategory = (categoryId) => {
  data.categoryId = categoryId;
  loadProducts();
};

const checkLogin = () => {
  if (!data.user.id) {
    ElMessage.warning('请先登录后操作');
    router.push('/login');
    return false;
  }
  return true;
};

const loadOptions = () => {
  request.get('/productCategory/selectAll', {
    params: { isEnabled: 1 }
  }).then(res => {
    if (res.code === '200') {
      data.categories = res.data || [];
    }
  });

  request.get('/productBrand/selectAll', {
    params: { isEnabled: 1 }
  }).then(res => {
    if (res.code === '200') {
      data.brands = res.data || [];
    }
  });
};

const loadProducts = () => {
  request.get('/product/selectAll', {
    params: {
      name: data.name,
      categoryId: data.categoryId,
      brandId: data.brandId,
      status: 'ON_SALE'
    }
  }).then(res => {
    if (res.code === '200') {
      data.products = res.data || [];
    }
  });
};

// Client-side sorting for snappy and responsive UX
const sortedProducts = computed(() => {
  const list = [...data.products];
  if (sortType.value === 'recommend') {
    return list.filter(item => item.isRecommend === 1);
  }
  if (sortType.value === 'priceAsc') {
    return list.sort((a, b) => Number(a.price) - Number(b.price));
  }
  if (sortType.value === 'priceDesc') {
    return list.sort((a, b) => Number(b.price) - Number(a.price));
  }
  return list;
});

const addFavorite = (product) => {
  if (!checkLogin()) return;
  request.post('/productFavorite/add', {
    userId: data.user.id,
    productId: product.id
  }).then(res => {
    if (res.code === '200') {
      ElMessage.success('已加入我的收藏');
    } else {
      ElMessage.error(res.msg);
    }
  });
};

const addCart = (product) => {
  if (!checkLogin()) return;
  request.post('/shoppingCart/add', {
    userId: data.user.id,
    productId: product.id,
    quantity: 1
  }).then(res => {
    if (res.code === '200') {
      ElMessage.success('已成功加入购物车');
    } else {
      ElMessage.error(res.msg);
    }
  });
};

loadOptions();
loadProducts();
</script>

<style scoped>
.shop-home {
  max-width: 1240px;
  margin: 0 auto;
  padding: 24px 20px 60px;
  color: var(--text-main, #0f172a);
}

/* =========================================================
   Hero Section
   ========================================================= */
.hero-section {
  position: relative;
  background: radial-gradient(120% 120% at 50% 0%, #eef2ff 0%, #f8fafc 100%);
  border: 1px solid rgba(226, 232, 240, 0.8);
  border-radius: 24px;
  padding: 48px 44px;
  overflow: hidden;
  box-shadow: 0 4px 20px -2px rgba(15, 23, 42, 0.04);
}

.hero-content {
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  gap: 40px;
  align-items: center;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 5px 14px;
  border-radius: 9999px;
  background: #ffffff;
  border: 1px solid rgba(79, 70, 229, 0.2);
  color: #4f46e5;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 2px 6px rgba(79, 70, 229, 0.08);
}

.badge-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.2);
}

.hero-title {
  margin: 18px 0 14px;
  font-size: 38px;
  font-weight: 800;
  line-height: 1.25;
  letter-spacing: -0.03em;
  color: #0f172a;
}

.hero-title-gradient {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #ec4899 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-desc {
  font-size: 15px;
  line-height: 1.7;
  color: #64748b;
  margin: 0 0 28px;
  max-width: 540px;
}

/* Hero Search & Prompt Bar */
.hero-search-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 580px;
}

.hero-search-box {
  flex: 1;
  display: flex;
  align-items: center;
  background: #ffffff;
  border: 1.5px solid #e2e8f0;
  border-radius: 9999px;
  padding: 6px 8px 6px 16px;
  box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
  transition: all 0.2s ease;
}

.hero-search-box:focus-within {
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.12);
}

.search-icon {
  font-size: 18px;
  color: #94a3b8;
  margin-right: 8px;
}

.hero-search-input {
  flex: 1;
  border: none;
  outline: none;
  font-size: 14px;
  color: #0f172a;
  background: transparent;
}

.hero-search-input::placeholder {
  color: #94a3b8;
}

.clear-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  color: #94a3b8;
  display: flex;
  align-items: center;
  padding: 4px;
}

.clear-btn:hover {
  color: #64748b;
}

.search-submit-btn {
  background: #0f172a;
  color: #ffffff;
  border: none;
  padding: 8px 20px;
  border-radius: 9999px;
  font-size: 13.5px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.search-submit-btn:hover {
  background: #1e293b;
  transform: translateY(-1px);
}

.ai-guide-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  color: #ffffff;
  font-size: 13.5px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  white-space: nowrap;
  box-shadow: 0 4px 14px rgba(79, 70, 229, 0.3);
  transition: all 0.2s;
}

.ai-guide-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(79, 70, 229, 0.4);
}

/* Quick Search Tag Chips */
.hero-tags {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 18px;
}

.tags-label {
  font-size: 12px;
  color: #94a3b8;
}

.tag-chip {
  font-size: 12px;
  color: #475569;
  background: #ffffff;
  padding: 3px 10px;
  border-radius: 9999px;
  border: 1px solid #e2e8f0;
  cursor: pointer;
  transition: all 0.2s;
}

.tag-chip:hover {
  color: #4f46e5;
  border-color: #c7d2fe;
  background: #eef2ff;
}

/* Hero Right: AI Assistant Showcase Card */
.hero-right {
  position: relative;
}

.ai-showcase-card {
  position: relative;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(226, 232, 240, 0.9);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 12px 32px -4px rgba(79, 70, 229, 0.08);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 16px;
  border-bottom: 1px solid #f1f5f9;
}

.agent-avatar-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.agent-avatar {
  position: relative;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: #eef2ff;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #e0e7ff;
}

.agent-avatar img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.online-indicator {
  position: absolute;
  bottom: -2px;
  right: -2px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #10b981;
  border: 2px solid #ffffff;
}

.agent-name {
  font-size: 14px;
  font-weight: 700;
  color: #0f172a;
}

.agent-sub {
  font-size: 11px;
  color: #64748b;
  margin-top: 2px;
}

.agent-chip {
  font-size: 11px;
  font-weight: 600;
  color: #4f46e5;
  background: #eef2ff;
  padding: 3px 8px;
  border-radius: 6px;
}

/* Dialogue Simulation */
.dialogue-box {
  margin: 16px 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-bubble {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  padding: 12px 14px;
}

.bubble-tag {
  font-size: 10px;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  display: block;
  margin-bottom: 4px;
}

.user-bubble p {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.6;
  color: #334155;
}

.ai-response-bubble {
  background: linear-gradient(135deg, #f5f3ff 0%, #eef2ff 100%);
  border: 1px solid #e0e7ff;
  border-radius: 14px;
  padding: 12px 14px;
}

.ai-bubble-head {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11.5px;
  font-weight: 600;
  color: #4f46e5;
  margin-bottom: 10px;
}

.sparkle-icon {
  color: #f59e0b;
}

.ai-stat-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}

.stat-pill {
  background: rgba(255, 255, 255, 0.85);
  border: 1px solid rgba(226, 232, 240, 0.8);
  border-radius: 8px;
  padding: 6px 8px;
  text-align: center;
}

.stat-val {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: #0f172a;
}

.stat-lbl {
  display: block;
  font-size: 10px;
  color: #64748b;
  margin-top: 2px;
}

.showcase-cta {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 11px;
  background: #ffffff;
  border: 1px solid #c7d2fe;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
  color: #4f46e5;
  cursor: pointer;
  transition: all 0.2s;
}

.showcase-cta:hover {
  background: #4f46e5;
  color: #ffffff;
  border-color: #4f46e5;
}

/* =========================================================
   Features Bar (4 Pillars)
   ========================================================= */
.features-bar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin: 32px 0 44px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 14px;
  background: #ffffff;
  padding: 18px 20px;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
  transition: all 0.2s;
}

.feature-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(15, 23, 42, 0.06);
  border-color: #cbd5e1;
}

.feature-icon {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  background: #eef2ff;
  color: #4f46e5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.feature-text h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 700;
  color: #0f172a;
}

.feature-text p {
  margin: 4px 0 0;
  font-size: 12px;
  color: #64748b;
  line-height: 1.4;
}

/* =========================================================
   Store Container & Filters
   ========================================================= */
.store-container {
  margin-top: 16px;
}

.store-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 20px;
}

.store-title {
  margin: 0;
  font-size: 24px;
  font-weight: 800;
  color: #0f172a;
  letter-spacing: -0.02em;
}

.store-subtitle {
  margin: 6px 0 0;
  font-size: 13.5px;
  color: #64748b;
}

.product-count-badge {
  font-size: 13px;
  color: #64748b;
  background: #f1f5f9;
  padding: 6px 14px;
  border-radius: 9999px;
  border: 1px solid #e2e8f0;
}

.product-count-badge span {
  font-weight: 700;
  color: #4f46e5;
}

/* Category Strip */
.category-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  padding: 12px 16px;
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.02);
  margin-bottom: 16px;
}

.cat-pill {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 18px;
  border-radius: 9999px;
  border: 1px solid transparent;
  background: #f8fafc;
  color: #475569;
  font-size: 13.5px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.cat-pill:hover {
  background: #eef2ff;
  color: #4f46e5;
}

.cat-pill.active {
  background: #4f46e5;
  color: #ffffff;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
}

/* Filter Toolbar */
.filter-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 18px;
  background: #ffffff;
  border-radius: 14px;
  border: 1px solid #e2e8f0;
  margin-bottom: 24px;
  gap: 16px;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.sort-tabs {
  display: flex;
  align-items: center;
  background: #f1f5f9;
  padding: 3px;
  border-radius: 10px;
  gap: 2px;
}

.sort-tab {
  padding: 6px 14px;
  font-size: 12.5px;
  font-weight: 500;
  color: #64748b;
  border: none;
  background: transparent;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.sort-tab:hover {
  color: #0f172a;
}

.sort-tab.active {
  background: #ffffff;
  color: #0f172a;
  font-weight: 600;
  box-shadow: 0 1px 4px rgba(15, 23, 42, 0.08);
}

.reset-filters-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12.5px;
  color: #64748b;
  background: transparent;
  border: 1px solid #e2e8f0;
  padding: 6px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.reset-filters-btn:hover {
  color: #ef4444;
  border-color: #fca5a5;
  background: #fef2f2;
}

/* =========================================================
   Product Grid & Cards
   ========================================================= */
.product-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 20px;
}

.product-card {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  position: relative;
}

.product-card:hover {
  transform: translateY(-5px);
  border-color: #c7d2fe;
  box-shadow: 0 16px 32px -6px rgba(15, 23, 42, 0.08);
}

.card-image-box {
  position: relative;
  width: 100%;
  padding-top: 85%;
  background: #f8fafc;
  overflow: hidden;
}

.card-img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  transition: transform 0.35s ease;
}

.product-card:hover .card-img {
  transform: scale(1.05);
}

.image-fallback {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  color: #94a3b8;
}

.image-overlay-badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  z-index: 2;
}

.recommend-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: #ffffff;
  font-size: 11px;
  font-weight: 700;
  padding: 3px 8px;
  border-radius: 6px;
  box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
}

.category-badge {
  display: inline-block;
  background: rgba(15, 23, 42, 0.7);
  backdrop-filter: blur(8px);
  color: #ffffff;
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 6px;
}

.fav-float-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(226, 232, 240, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #64748b;
  cursor: pointer;
  z-index: 2;
  transition: all 0.2s;
}

.fav-float-btn:hover {
  background: #fef2f2;
  color: #ef4444;
  border-color: #fca5a5;
  transform: scale(1.1);
}

.card-content {
  padding: 16px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.brand-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}

.brand-tag {
  font-size: 11px;
  font-weight: 600;
  color: #4f46e5;
  background: #eef2ff;
  padding: 2px 8px;
  border-radius: 4px;
}

.stock-status {
  font-size: 11px;
  color: #10b981;
}

.stock-status.low-stock {
  color: #f59e0b;
}

.product-title {
  margin: 0;
  font-size: 14.5px;
  font-weight: 700;
  line-height: 1.45;
  color: #0f172a;
  height: 42px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  transition: color 0.2s;
}

.product-card:hover .product-title {
  color: #4f46e5;
}

.product-selling-point {
  margin: 6px 0 12px;
  font-size: 12px;
  line-height: 1.5;
  color: #64748b;
  height: 36px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-bottom {
  margin-top: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 12px;
  border-top: 1px solid #f1f5f9;
}

.price-container {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.currency-symbol {
  font-size: 13px;
  font-weight: 700;
  color: #ef4444;
}

.price-integer {
  font-size: 20px;
  font-weight: 800;
  color: #ef4444;
  letter-spacing: -0.02em;
}

.price-decimal {
  font-size: 12px;
  font-weight: 700;
  color: #ef4444;
}

.original-price {
  margin-left: 6px;
  font-size: 11px;
  color: #94a3b8;
}

.btn-add-cart {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 7px 12px;
  border-radius: 8px;
  background: #0f172a;
  color: #ffffff;
  border: none;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-add-cart:hover:not(:disabled) {
  background: #4f46e5;
  box-shadow: 0 4px 10px rgba(79, 70, 229, 0.3);
  transform: translateY(-1px);
}

.btn-add-cart:disabled {
  background: #cbd5e1;
  cursor: not-allowed;
}

/* =========================================================
   Empty State
   ========================================================= */
.empty-product-state {
  background: #ffffff;
  border: 1px dashed #cbd5e1;
  border-radius: 20px;
  padding: 60px 20px;
  text-align: center;
  margin: 20px 0;
}

.empty-icon-wrap {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: #f1f5f9;
  color: #94a3b8;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.empty-product-state h3 {
  margin: 0;
  font-size: 17px;
  color: #0f172a;
}

.empty-product-state p {
  margin: 8px 0 20px;
  font-size: 13px;
  color: #64748b;
}

.reset-action-btn {
  background: #4f46e5;
  color: #ffffff;
  border: none;
  padding: 10px 24px;
  border-radius: 9999px;
  font-size: 13.5px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.reset-action-btn:hover {
  background: #4338ca;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);
}

/* =========================================================
   Bottom AI Promo Banner
   ========================================================= */
.guide-banner-card {
  margin-top: 60px;
  background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 60%, #312e81 100%);
  border-radius: 24px;
  padding: 44px 40px;
  color: #ffffff;
  position: relative;
  overflow: hidden;
  box-shadow: 0 20px 40px -10px rgba(15, 23, 42, 0.2);
}

.guide-banner-content {
  max-width: 680px;
}

.banner-badge {
  display: inline-block;
  background: rgba(99, 102, 241, 0.25);
  border: 1px solid rgba(165, 180, 252, 0.3);
  color: #a5b4fc;
  font-size: 12px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 9999px;
  margin-bottom: 14px;
}

.guide-banner-card h2 {
  margin: 0 0 10px;
  font-size: 28px;
  font-weight: 800;
  letter-spacing: -0.02em;
}

.guide-banner-card p {
  margin: 0 0 24px;
  font-size: 14px;
  line-height: 1.7;
  color: #cbd5e1;
}

.banner-cta-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: #ffffff;
  color: #0f172a;
  border: none;
  padding: 12px 28px;
  border-radius: 9999px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.2);
  transition: all 0.2s;
}

.banner-cta-btn:hover {
  background: #e0e7ff;
  color: #4f46e5;
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.25);
}

/* =========================================================
   Floating AI Quick Dock
   ========================================================= */
.floating-ai-dock {
  position: fixed;
  bottom: 36px;
  right: 36px;
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  color: #ffffff;
  padding: 12px 20px;
  border-radius: 9999px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13.5px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 8px 24px rgba(79, 70, 229, 0.4);
  z-index: 99;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.floating-ai-dock:hover {
  transform: translateY(-3px) scale(1.03);
  box-shadow: 0 12px 28px rgba(79, 70, 229, 0.5);
}

.dock-pulse {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 9999px;
  box-shadow: 0 0 0 0 rgba(79, 70, 229, 0.7);
  animation: dockRipple 2s infinite cubic-bezier(0.66, 0, 0, 1);
  pointer-events: none;
}

@keyframes dockRipple {
  to {
    box-shadow: 0 0 0 16px rgba(79, 70, 229, 0);
  }
}

/* =========================================================
   Responsive Breakpoints
   ========================================================= */
@media (max-width: 1100px) {
  .hero-content {
    grid-template-columns: 1fr;
  }
  .features-bar {
    grid-template-columns: repeat(2, 1fr);
  }
  .product-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .hero-section {
    padding: 32px 20px;
  }
  .hero-title {
    font-size: 28px;
  }
  .hero-search-wrapper {
    flex-direction: column;
    align-items: stretch;
  }
  .features-bar {
    grid-template-columns: 1fr;
  }
  .product-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }
  .filter-toolbar {
    flex-direction: column;
    align-items: stretch;
  }
  .toolbar-left {
    flex-direction: column;
    align-items: stretch;
  }
  .brand-select-wrapper .el-select {
    width: 100% !important;
  }
  .sort-tabs {
    overflow-x: auto;
  }
}

@media (max-width: 480px) {
  .product-grid {
    grid-template-columns: 1fr;
  }
  .floating-ai-dock {
    bottom: 20px;
    right: 20px;
    padding: 10px 16px;
    font-size: 12px;
  }
}
</style>
