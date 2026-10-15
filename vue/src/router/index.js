import { createRouter, createWebHistory } from 'vue-router'

import Login from '@/views/Login.vue'
import Register from '@/views/Register.vue'
import FourOFour from '@/views/404.vue'

import Home from '@/views/manager/Home.vue'
import User from '@/views/manager/User.vue'
import AiModelConfig from '@/views/manager/AiModelConfig.vue'
import PromptTemplate from '@/views/manager/PromptTemplate.vue'
import FunctionTool from '@/views/manager/FunctionTool.vue'
import ProductToolDebug from '@/views/manager/ProductToolDebug.vue'
import BusinessToolDebug from '@/views/manager/BusinessToolDebug.vue'
import ShoppingGuideTask from '@/views/manager/ShoppingGuideTask.vue'
import AgentRun from '@/views/manager/AgentRun.vue'
import AgentStep from '@/views/manager/AgentStep.vue'
import ShoppingRecommendation from '@/views/manager/ShoppingRecommendation.vue'
import ShoppingQa from '@/views/manager/ShoppingQa.vue'
import ShoppingReviewAnalysis from '@/views/manager/ShoppingReviewAnalysis.vue'
import ShoppingGrowthReport from '@/views/manager/ShoppingGrowthReport.vue'
import ProductCategory from '@/views/manager/ProductCategory.vue'
import ProductBrand from '@/views/manager/ProductBrand.vue'
import Product from '@/views/manager/Product.vue'
import ProductDetail from '@/views/manager/ProductDetail.vue'
import ShopOrder from '@/views/manager/ShopOrder.vue'
import ProductReview from '@/views/manager/ProductReview.vue'
import AfterSaleRule from '@/views/manager/AfterSaleRule.vue'
import ProductKnowledge from '@/views/manager/ProductKnowledge.vue'
import ProductKnowledgeChunk from '@/views/manager/ProductKnowledgeChunk.vue'
import ProductKnowledgeEmbedding from '@/views/manager/ProductKnowledgeEmbedding.vue'
import Person from '@/views/manager/Person.vue'
import Password from '@/views/manager/Password.vue'

import FrontHome from '@/views/front/Home.vue'
import FrontProductDetail from '@/views/front/ProductDetail.vue'
import FrontPerson from '@/views/front/Person.vue'
import FrontPassword from '@/views/front/Password.vue'
import FrontWallet from '@/views/front/Wallet.vue'
import FrontFavorite from '@/views/front/Favorite.vue'
import FrontCart from '@/views/front/Cart.vue'
import FrontOrder from '@/views/front/Order.vue'
import FrontGuide from '@/views/front/Guide.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/login' },
    {
      path: '/manager',
      component: () => import('@/views/Manager.vue'),
      children: [
        { path: 'home', meta: { name: '商城首页' }, component: Home },
        { path: 'user', meta: { name: '用户管理' }, component: User },
        { path: 'aiModelConfig', meta: { name: 'AI模型配置' }, component: AiModelConfig },
        { path: 'promptTemplate', meta: { name: 'Prompt模板' }, component: PromptTemplate },
        { path: 'functionTool', meta: { name: 'Function Tool' }, component: FunctionTool },
        { path: 'productToolDebug', meta: { name: '商品工具调试' }, component: ProductToolDebug },
        { path: 'businessToolDebug', meta: { name: '业务工具调试' }, component: BusinessToolDebug },
        { path: 'shoppingGuideTask', meta: { name: 'AI智能导购任务' }, component: ShoppingGuideTask },
        { path: 'agentRun', meta: { name: 'Agent Run运行记录' }, component: AgentRun },
        { path: 'agentStep', meta: { name: 'Agent Step执行步骤' }, component: AgentStep },
        { path: 'shoppingRecommendation', meta: { name: 'AI推荐商品' }, component: ShoppingRecommendation },
        { path: 'shoppingQa', meta: { name: 'AI商品问答' }, component: ShoppingQa },
        { path: 'shoppingReviewAnalysis', meta: { name: 'AI评价分析' }, component: ShoppingReviewAnalysis },
        { path: 'shoppingGrowthReport', meta: { name: 'AI运营增长报告' }, component: ShoppingGrowthReport },
        { path: 'productCategory', meta: { name: '商品分类' }, component: ProductCategory },
        { path: 'productBrand', meta: { name: '商品品牌' }, component: ProductBrand },
        { path: 'product', meta: { name: '商品管理' }, component: Product },
        { path: 'productDetail', meta: { name: '商品详情与参数' }, component: ProductDetail },
        { path: 'shopOrder', meta: { name: '订单管理' }, component: ShopOrder },
        { path: 'productReview', meta: { name: '商品评价管理' }, component: ProductReview },
        { path: 'afterSaleRule', meta: { name: '售后规则管理' }, component: AfterSaleRule },
        { path: 'productKnowledge', meta: { name: '商品知识库' }, component: ProductKnowledge },
        { path: 'productKnowledgeChunk', meta: { name: '商品知识切片' }, component: ProductKnowledgeChunk },
        { path: 'productKnowledgeEmbedding', meta: { name: 'Embedding 检索' }, component: ProductKnowledgeEmbedding },
        { path: 'person', meta: { name: '个人资料' }, component: Person },
        { path: 'password', meta: { name: '修改密码' }, component: Password },
      ]
    },
    {
      path: '/front',
      component: () => import('@/views/Front.vue'),
      children: [
        { path: 'home', component: FrontHome },
        { path: 'product/:id', component: FrontProductDetail },
        { path: 'guide', component: FrontGuide },
        { path: 'favorite', component: FrontFavorite },
        { path: 'cart', component: FrontCart },
        { path: 'order', component: FrontOrder },
        { path: 'person', component: FrontPerson },
        { path: 'wallet', component: FrontWallet },
        { path: 'password', component: FrontPassword },
      ]
    },
    { path: '/login', component: Login },
    { path: '/register', component: Register },
    { path: '/404', component: FourOFour },
    { path: '/:pathMatch(.*)', redirect: '/404' }
  ]
})

export default router


