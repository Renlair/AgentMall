<template>
  <div class="auth-page">
    <header class="page-header">
      <div class="brand" aria-label="AgentMall 智选商城">
        <svg class="brand-mark" viewBox="0 0 32 36" fill="none" aria-hidden="true">
          <path d="M4 11h24l2 22H2L4 11Z" stroke="currentColor" stroke-width="2"/>
          <path d="M10 13V8a6 6 0 0 1 12 0v5" stroke="currentColor" stroke-width="2"/>
        </svg>
        <span>AgentMall<small>智选商城</small></span>
      </div>
      <span class="header-note">日常所需，用心挑选。</span>
    </header>

    <main class="auth-shell">
      <section class="shop-story" aria-labelledby="story-title">
        <div class="story-copy">
          <span class="story-kicker">好物 · 日常</span>
          <h1 id="story-title">好东西，<br>慢慢挑。</h1>
          <p>从一件心仪的好物开始，<br>给日常添一点喜欢。</p>
        </div>
        <svg class="shopping-illustration" viewBox="0 0 480 350" fill="none" aria-hidden="true">
          <ellipse cx="257" cy="310" rx="160" ry="15" fill="#d9d2c5"/>
          <path d="m132 112 155-22 45 207-177 17-23-202Z" fill="#b65c43"/>
          <path d="m287 90 40 26 39 174-34 7-45-207Z" fill="#934731"/>
          <path d="m132 112 39 21 156-17-40-26-155 22Z" fill="#cc8167"/>
          <path d="M177 146c-15-77-3-110 30-114 34-4 49 28 53 103" stroke="#653c30" stroke-width="7" stroke-linecap="round"/>
          <path d="M191 139c-12-62-3-88 19-91 23-3 34 22 38 86" stroke="#e9c9af" stroke-width="3" stroke-linecap="round"/>
          <path d="m157 311 175-14-18-39" stroke="#934731" stroke-width="1.5"/>
          <path d="m217 187 46-5 7 63-46 5-7-63Z" fill="#f5eddb" transform="rotate(-8 244 216)"/>
          <path d="m233 205 21-5m-19 12 16-4" stroke="#b65c43" stroke-width="2"/>
          <circle cx="238" cy="193" r="2" fill="#934731"/>
          <path d="m238 191-14-61" stroke="#f5eddb"/>
          <path d="m70 241 76-9 17 76-79 8-14-75Z" fill="#71816a"/>
          <path d="m146 232 18 12 17 61-18 3-17-76Z" fill="#53654e"/>
          <path d="M90 252c-7-35-1-48 13-49 14-2 23 13 28 44" stroke="#45533e" stroke-width="4" stroke-linecap="round"/>
          <path d="m88 301 44-5" stroke="#aab49c"/>
          <path d="M349 251c19-22 24-49 23-75m-1 35c-22-2-29-14-28-29 18 0 28 9 28 29Zm1-18c20-4 30-16 28-32-18 1-28 14-28 32Z" stroke="#71816a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        <div class="story-caption"><span>为生活，选点好的。</span><span class="caption-line"></span></div>
      </section>

      <section class="login-panel" aria-labelledby="login-title">
        <div class="login-content">
          <div class="login-header">
            <h2 id="login-title">欢迎回来</h2>
            <p>登录账号，接着逛逛。</p>
          </div>
          <el-form ref="formRef" :model="data.form" :rules="data.rules" class="login-form" @submit.prevent="login">
            <label class="field-label" for="login-username">账号</label>
            <el-form-item prop="username">
              <el-input id="login-username" v-model="data.form.username" name="username" autocomplete="username" placeholder="请输入账号" size="large"/>
            </el-form-item>
            <label class="field-label" for="login-password">密码</label>
            <el-form-item prop="password">
              <el-input id="login-password" v-model="data.form.password" name="password" type="password" autocomplete="current-password" placeholder="请输入密码" size="large" show-password/>
            </el-form-item>
            <el-form-item class="submit-item">
              <el-button type="primary" native-type="submit" size="large" class="submit-btn" :loading="data.loading">登 录</el-button>
            </el-form-item>
          </el-form>
          <div class="login-footer">还没有账号？<router-link to="/register">注册一个<span aria-hidden="true"> ↗</span></router-link></div>
        </div>
      </section>
    </main>
    <footer class="page-footer"><span>AgentMall · 智选商城</span><span>把喜欢，带回生活。</span></footer>
  </div>
</template>

<script setup>
import { reactive, ref } from "vue";
import request from "@/utils/request.js";
import { ElMessage } from "element-plus";

const data = reactive({
  form: {},
  rules: {
    username: [
      { required: true, message: '请输入账号', trigger: 'blur' }
    ],
    password: [
      { required: true, message: '请输入密码', trigger: 'blur' }
    ]
  },
  loading: false
})

const formRef = ref()

const login = () => {
  formRef.value.validate(valid => {
    if (valid) {
      data.loading = true
      request.post('/user/login', data.form).then(res => {
        if (res.code === '200') {
          ElMessage.success('登录成功')
          localStorage.setItem('sys-user', JSON.stringify(res.data))
          setTimeout(() => {
            if (res.data.role === 'USER') {
              location.href = '/front/home'
            } else {
              location.href = '/manager/home'
            }
          }, 500)
        } else {
          ElMessage.error(res.msg)
        }
      }).finally(() => {
        data.loading = false
      })
    }
  })
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  min-height: 100svh;
  display: flex;
  flex-direction: column;
  padding: 0 6vw;
  color: #302e29;
  background: #faf9f6;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
}
.page-header, .page-footer {
  width: min(1160px, 100%);
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.page-header { min-height: 112px; gap: 24px; }
.brand { display: flex; align-items: center; gap: 12px; }
.brand-mark { width: 27px; height: 32px; color: #a34e38; }
.brand > span { font-size: 22px; font-weight: 650; letter-spacing: -.8px; }
.brand small { display: block; margin-top: 4px; font-size: 10px; font-weight: 400; letter-spacing: 3px; color: #726e64; }
.header-note { color: #77736b; font-size: 12px; letter-spacing: 1px; }
.auth-shell {
  display: grid;
  grid-template-columns: 1fr 1fr;
  width: min(1080px, 100%);
  min-height: 610px;
  margin: auto;
}
.shop-story { position: relative; overflow: hidden; background: #eeeae1; padding: 47px 48px 30px; }
.story-kicker { font-size: 12px; color: #7a7162; letter-spacing: 4px; }
.story-copy h1 {
  position: relative;
  z-index: 1;
  margin: 25px 0 19px;
  font-family: "Noto Serif CJK SC", "Songti SC", "STSong", "SimSun", serif;
  font-size: clamp(42px, 4vw, 52px);
  font-weight: 500;
  line-height: 1.3;
  letter-spacing: 4px;
}
.story-copy p { margin: 0; color: #756d60; font-size: 13px; line-height: 1.9; letter-spacing: 1px; }
.shopping-illustration { display: block; width: 86%; max-width: 360px; margin: -25px 0 0 auto; }
.story-caption { display: flex; align-items: center; gap: 20px; margin-top: 3px; font-size: 11px; letter-spacing: 2px; color: #777061; }
.caption-line { width: 55px; height: 1px; background: #bab2a3; }
.login-panel { display: flex; align-items: center; justify-content: center; padding: 60px 55px; }
.login-content { width: 100%; max-width: 330px; }
.login-header { margin-bottom: 40px; }
.login-header h2 { margin: 0; font-size: 30px; line-height: 1.5; letter-spacing: 2px; font-weight: 500; }
.login-header p { margin: 10px 0 0; font-size: 13px; color: #807b72; }
.field-label { display: block; margin-bottom: 10px; font-size: 13px; color: #4e4941; }
.login-form { --el-color-primary: #a34e38; --el-color-danger: #b13e30; }
.login-form :deep(.el-form-item) { margin-bottom: 26px; }
.login-form :deep(.el-input__wrapper) {
  min-height: 49px;
  padding: 0 14px;
  border-radius: 4px;
  background: #fffefa;
  box-shadow: 0 0 0 1px #d6d1c8 inset;
  transition: box-shadow .2s;
}
.login-form :deep(.el-input__wrapper:hover) { box-shadow: 0 0 0 1px #a69c8e inset; }
.login-form :deep(.el-input__wrapper.is-focus) { box-shadow: 0 0 0 1px #a34e38 inset, 0 0 0 3px #a34e3812; }
.login-form :deep(.is-error .el-input__wrapper) { box-shadow: 0 0 0 1px #b13e30 inset; }
.login-form :deep(.el-input__inner) { color: #302e29; font-size: 13px; --el-input-placeholder-color: #999187; }
.login-form :deep(.submit-item) { margin: 34px 0 0; }
.submit-btn {
  width: 100%;
  height: 49px;
  border: 1px solid #a34e38;
  border-radius: 4px;
  background: #a34e38;
  color: #fffaf5;
  font-size: 14px;
  transition: background .2s, border-color .2s;
}
.submit-btn:hover, .submit-btn:focus-visible { background: #8e412e; border-color: #8e412e; }
.submit-btn:focus-visible { outline: 2px solid #a34e38; outline-offset: 3px; }
.login-footer { margin-top: 28px; color: #827b72; font-size: 12px; text-align: center; }
.login-footer a { margin-left: 9px; color: #91452f; text-underline-offset: 4px; }
.login-footer a:hover { text-decoration: underline; }
.page-footer { min-height: 86px; gap: 16px; color: #857f74; font-size: 10px; letter-spacing: 1px; }
@media (min-width: 1600px) { .auth-shell { min-height: 660px; } .shopping-illustration { margin-top: 12px; } }
@media (max-width: 900px) {
  .auth-page { padding: 0 5vw; }
  .shop-story { padding: 40px 30px 28px; }
  .login-panel { padding: 48px 30px; }
  .auth-shell { min-height: 550px; }
  .shopping-illustration { width: 110%; margin-left: -5%; margin-top: 15px; }
}
@media (max-width: 640px) {
  .auth-page { padding: 0 26px; }
  .page-header { min-height: 94px; }
  .brand > span { font-size: 20px; }
  .header-note { display: none; }
  .auth-shell { grid-template-columns: 1fr; min-height: auto; margin: 12px auto auto; max-width: 380px; }
  .shop-story { padding: 25px; min-height: 145px; }
  .story-kicker, .story-copy p, .story-caption { display: none; }
  .story-copy h1 { font-size: 28px; line-height: 1.55; margin: 0; letter-spacing: 2px; }
  .shopping-illustration { position: absolute; width: 196px; margin: 0; right: -12px; top: 5px; }
  .login-panel { padding: 37px 0 44px; }
  .login-content { max-width: none; }
  .login-header { margin-bottom: 29px; }
  .login-header h2 { font-size: 25px; }
  .page-footer { min-height: 65px; font-size: 9px; letter-spacing: 0; }
}
</style>
