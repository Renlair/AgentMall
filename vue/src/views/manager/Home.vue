<template>
  <div class="console-home">
    <div class="overview-heading"><span>你的日常工作台</span><time :datetime="today">{{ dateLabel }}</time></div>

    <section class="welcome-panel" aria-labelledby="welcome-title">
      <div class="welcome-copy">
        <div class="section-kicker"><span></span> 用心经营 · 智能相伴</div>
        <h1 id="welcome-title">{{ greeting }}，{{ user.name || user.username || '管理员' }}。<br>让好物，遇见对的人。</h1>
        <p>从了解一份需求，到挑选一件好物。<br>在这里，打理商城，也照顾每一次选择。</p>
        <router-link class="welcome-action" to="/manager/shoppingGuideTask">开始一次智能导购 <el-icon><ArrowRight /></el-icon></router-link>
      </div>
      <div class="welcome-art" aria-hidden="true">
        <svg viewBox="0 0 360 290" fill="none">
          <ellipse cx="183" cy="254" rx="136" ry="12" fill="#ded7ca"/>
          <path d="M94 100 216 83l32 162-136 13L94 100Z" fill="#b65c43"/>
          <path d="m216 83 30 19 31 138-29 5-32-162Z" fill="#934731"/>
          <path d="m94 100 31 17 121-15-30-19-122 17Z" fill="#cc8167"/>
          <path d="M129 124c-12-60-2-86 24-89 26-3 38 22 42 80" stroke="#653c30" stroke-width="6" stroke-linecap="round"/>
          <path d="M141 119c-10-48-3-69 15-71 18-2 26 17 30 67" stroke="#e9c9af" stroke-width="2.5" stroke-linecap="round"/>
          <path d="m153 163 36-5 8 48-36 5-8-48Z" fill="#f5eddb"/>
          <path d="m169 177 15-2m-14 9 12-2" stroke="#b65c43" stroke-width="2"/>
          <path d="m170 163-11-44" stroke="#f5eddb"/>
          <path d="m51 197 62-7 13 60-64 7-11-60Z" fill="#71816a"/>
          <path d="m113 190 16 9 13 48-16 3-13-60Z" fill="#53654e"/>
          <path d="M67 205c-6-28-1-39 10-40 12-1 19 11 23 35" stroke="#45533e" stroke-width="3.5" stroke-linecap="round"/>
          <path d="M277 221c14-23 22-55 18-83m1 42c-19-1-26-11-26-24 16-1 25 8 26 24Zm0-20c17-5 24-16 22-29-16 2-24 14-22 29Z" stroke="#71816a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
          <path d="m267 86 5-12m12 25 12-4M67 135l-10-5" stroke="#b7a487" stroke-width="2" stroke-linecap="round"/>
        </svg>
        <div class="art-caption">为生活，选点好的。<span></span></div>
      </div>
    </section>

    <section class="quick-section" aria-labelledby="quick-title">
      <div class="section-heading"><div><span class="section-number">01 /</span><h2 id="quick-title">从这里开始</h2></div><span>让日常工作，顺手一点。</span></div>
      <div class="quick-grid">
        <router-link v-for="item in quickLinks" :key="item.path" :to="item.path" class="quick-card" :class="item.tone">
          <div class="quick-card-top"><span class="quick-icon"><el-icon><component :is="item.icon" /></el-icon></span><span class="quick-label">{{ item.label }}</span><el-icon class="card-arrow"><TopRight /></el-icon></div>
          <h3>{{ item.title }}</h3><p>{{ item.description }}</p><span class="card-cta">{{ item.action }} <span aria-hidden="true">→</span></span>
        </router-link>
      </div>
    </section>

    <section class="workspace-section" aria-labelledby="workspace-title">
      <div class="section-heading"><div><span class="section-number">02 /</span><h2 id="workspace-title">把每一步，照顾好</h2></div><router-link to="/front/home">逛逛商城 <span aria-hidden="true">↗</span></router-link></div>
      <div class="workspace-panel">
        <div class="workspace-intro"><span class="section-kicker">从准备，到推荐</span><h3>好推荐，<br>从好准备开始。</h3><p>维护商品与知识，连接模型与工具，<br>再看看每次导购如何完成。</p><svg class="intro-decoration" viewBox="0 0 100 100" fill="none" aria-hidden="true"><path d="M50 12v76M12 50h76M23 23l54 54M23 77l54-54" stroke="currentColor" stroke-width="6" stroke-linecap="round"/></svg></div>
        <div class="workspace-links">
          <router-link v-for="(item, index) in workspaces" :key="item.path" :to="item.path" class="workspace-row"><span class="row-number">0{{ index + 1 }}</span><span class="row-copy"><strong>{{ item.title }}</strong><span>{{ item.description }}</span></span><span class="row-action">{{ item.action }} <el-icon><ArrowRight /></el-icon></span></router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ArrowRight, TopRight, MagicStick, Notebook, DataAnalysis } from '@element-plus/icons-vue'

const user = JSON.parse(localStorage.getItem('sys-user') || '{}')
const now = new Date()
const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
const dateLabel = new Intl.DateTimeFormat('zh-CN', { month: 'long', day: 'numeric', weekday: 'long' }).format(now)
const greeting = now.getHours() < 11 ? '上午好' : now.getHours() < 14 ? '中午好' : now.getHours() < 18 ? '下午好' : '晚上好'
const quickLinks = [
  { path: '/manager/shoppingGuideTask', icon: MagicStick, label: 'SMART GUIDE', title: '读懂需求，挑到心意', description: '创建导购任务，让 AI 查询商品与库存，给出有依据的推荐。', action: '管理导购任务', tone: 'terracotta' },
  { path: '/manager/productKnowledge', icon: Notebook, label: 'KNOWLEDGE', title: '让每个回答，有据可依', description: '整理商品知识，为每一次商品问答准备更完整的资料。', action: '维护知识库', tone: 'sage' },
  { path: '/manager/agentRun', icon: DataAnalysis, label: 'AGENT TRACE', title: '每一次推荐，都有来路', description: '查看运行记录与执行结果，了解工具调用和任务完成情况。', action: '查看运行记录', tone: 'ochre' },
]
const workspaces = [
  { path: '/manager/product', title: '打理商品', description: '维护商品信息、价格与库存', action: '商品管理' },
  { path: '/manager/aiModelConfig', title: '连接智能', description: '配置对话与向量模型', action: '模型配置' },
  { path: '/manager/functionTool', title: '准备工具', description: '维护业务工具，检查调用配置', action: '工具中心' },
  { path: '/manager/shoppingReviewAnalysis', title: '倾听反馈', description: '分析商品评价，发现用户关注点', action: '评价分析' },
]
</script>

<style scoped>
.console-home { width: 100%; max-width: 1360px; margin: 0 auto; }
.overview-heading { display: flex; justify-content: space-between; align-items: center; margin: 0 0 22px; color: #8a8071; font-size: 12px; letter-spacing: 1px; gap: 12px; }
.overview-heading > span { color: #5c5449; }
.overview-heading time { font-size: 11px; letter-spacing: .5px; }
.welcome-panel { display: grid; grid-template-columns: 1.4fr 1fr; min-height: 320px; padding: 34px 44px; background: #eeeae1; border: 1px solid #e7e0d4; position: relative; overflow: hidden; }
.section-kicker { display: flex; align-items: center; gap: 9px; color: #8b7962; font-size: 10px; letter-spacing: 2px; }
.section-kicker > span { width: 5px; height: 5px; border-radius: 50%; background: #a34e38; }
h1 { font-family: "Noto Serif CJK SC", "Songti SC", "STSong", "SimSun", serif; font-size: clamp(25px, 2.3vw, 36px); line-height: 1.65; letter-spacing: 2px; font-weight: 500; margin: 16px 0 12px; overflow-wrap: anywhere; }
.welcome-copy > p { color: #817563; font-size: 12px; line-height: 1.9; margin: 0 0 23px; letter-spacing: .5px; }
.welcome-action { display: inline-flex; align-items: center; justify-content: center; gap: 22px; min-height: 40px; padding: 0 18px; background: #a34e38; color: #fffaf5; font-size: 12px; border: 1px solid #a34e38; border-radius: 4px; transition: background .2s; }
.welcome-action:hover { background: #8e412e; }
.welcome-art { display: flex; flex-direction: column; justify-content: center; align-items: center; padding-left: 12px; }
.welcome-art svg { width: 100%; max-width: 325px; }
.art-caption { display: flex; gap: 18px; align-items: center; margin-top: -5px; font-family: "Songti SC", "SimSun", serif; font-size: 11px; color: #8b7a63; letter-spacing: 3px; }
.art-caption > span { width: 32px; height: 1px; background: #bcb09c; }
.quick-section, .workspace-section { margin-top: 32px; }
.section-heading { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 18px; }
.section-heading > div { display: flex; align-items: center; gap: 12px; }
.section-number { color: #aa9176; font-size: 10px; font-family: Georgia, serif; }
.section-heading h2 { font-size: 16px; font-weight: 500; letter-spacing: 1px; margin: 0; }
.section-heading > span, .section-heading > a { font-size: 11px; color: #928675; }
.section-heading > a:hover { color: #a34e38; }
.quick-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 18px; }
.quick-card { --accent: #a34e38; --tint: #f4e8e1; display: flex; flex-direction: column; color: #302e29; border: 1px solid #e7e1d7; background: #fffefa; border-radius: 6px; padding: 24px; transition: border-color .2s, transform .2s; }
.quick-card:hover { border-color: var(--accent); transform: translateY(-3px); }
.quick-card.sage { --accent: #687a5e; --tint: #edf0e7; }
.quick-card.ochre { --accent: #9a7a45; --tint: #f5eddf; }
.quick-card-top { display: flex; align-items: center; gap: 12px; }
.quick-icon { display: flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 5px; background: var(--tint); color: var(--accent); font-size: 19px; }
.quick-label { font-size: 8px; letter-spacing: 1.7px; color: #a29583; }
.card-arrow { margin-left: auto; color: #b3a998; font-size: 14px; }
.quick-card h3 { margin: 24px 0 9px; font-size: 16px; font-weight: 500; line-height: 1.5; }
.quick-card p { color: #8a8072; font-size: 12px; line-height: 1.9; margin: 0 0 24px; }
.card-cta { display: flex; justify-content: space-between; align-items: center; color: var(--accent); font-size: 11px; margin-top: auto; }
.card-cta > span { font-size: 16px; }
.workspace-panel { display: grid; grid-template-columns: 1fr 1.9fr; border: 1px solid #e7e1d7; border-radius: 6px; overflow: hidden; background: #fffefa; }
.workspace-intro { position: relative; padding: 30px; background: #f2f0e8; overflow: hidden; }
.workspace-intro h3 { position: relative; z-index: 1; font-family: "Songti SC", "STSong", "SimSun", serif; font-size: 25px; font-weight: 500; line-height: 1.6; letter-spacing: 2px; margin: 17px 0 10px; }
.workspace-intro p { position: relative; z-index: 1; color: #8b8172; font-size: 11px; line-height: 1.9; margin: 0; }
.intro-decoration { position: absolute; right: 14px; bottom: -34px; color: #e2e1d4; width: 160px; height: 160px; }
.workspace-links { padding: 8px 28px; }
.workspace-row { display: flex; align-items: center; gap: 18px; min-height: 70px; padding: 16px 0; color: #514b42; border-bottom: 1px solid #eee9df; }
.workspace-row:last-child { border-bottom: 0; }
.row-number { color: #b0a18c; font-size: 10px; font-family: Georgia, serif; }
.row-copy { display: flex; flex: 1; flex-direction: column; gap: 7px; }
.row-copy strong { font-size: 13px; font-weight: 500; }
.row-copy > span { color: #9a8f7e; font-size: 11px; line-height: 1.5; }
.row-action { display: inline-flex; align-items: center; gap: 20px; color: #8b7d69; font-size: 11px; }
.workspace-row:hover .row-action, .workspace-row:hover .row-copy strong { color: #a34e38; }
@media (min-width: 1500px) { .welcome-panel { padding: 38px 52px; } }
@media (max-width: 1100px) {
  .welcome-panel { padding: 28px; }
  .quick-grid { gap: 12px; }
  .quick-card { padding: 20px 16px; }
  .quick-label { font-size: 7px; letter-spacing: 1px; }
  .quick-card h3 { font-size: 14px; }
  .workspace-panel { grid-template-columns: 1fr 1.7fr; }
  .workspace-intro { padding: 26px 22px; }
  .workspace-links { padding: 8px 20px; }
  .row-action { gap: 10px; }
}
@media (max-width: 900px) and (min-width: 761px) {
  .quick-grid { grid-template-columns: 1fr; }
  .welcome-panel { grid-template-columns: 1fr; }
  .welcome-art { display: none; }
  .workspace-panel { grid-template-columns: 1fr; }
  .workspace-intro h3 br { display: none; }
}
@media (max-width: 600px) {
  .overview-heading { font-size: 11px; margin-bottom: 18px; letter-spacing: 0; }
  .overview-heading time { font-size: 10px; }
  .welcome-panel { grid-template-columns: 1fr; padding: 26px 24px; }
  .welcome-art { position: absolute; width: 145px; right: -23px; bottom: -24px; padding: 0; opacity: .65; pointer-events: none; }
  .art-caption { display: none; }
  .welcome-copy { position: relative; z-index: 1; }
  h1 { font-size: 26px; }
  .quick-grid { grid-template-columns: 1fr; }
  .quick-card { padding: 22px; }
  .quick-card h3 { margin-top: 18px; font-size: 16px; }
  .quick-card p { margin-bottom: 18px; }
  .quick-label { font-size: 8px; }
  .section-heading > span { display: none; }
  .section-heading h2 { font-size: 15px; }
  .workspace-panel { grid-template-columns: 1fr; }
  .workspace-intro { padding: 24px; }
  .workspace-intro h3 { font-size: 23px; }
  .workspace-intro h3 br { display: none; }
  .workspace-links { padding: 8px 20px; }
  .workspace-row { gap: 12px; }
  .row-action { gap: 8px; font-size: 10px; }
}
</style>
