<script setup>
import { ref, computed } from 'vue'
import UserManager from './components/UserManager.vue'
import AiRoleManager from './components/AiRoleManager.vue'
import StatisticsManager from './components/StatisticsManager.vue'

// 当前激活的页面
const activePage = ref('user-manager')

// 页面配置
const pages = {
  'user-manager': { component: UserManager, title: '用户管理' },
  'ai-role-manager': { component: AiRoleManager, title: 'AI角色管理' },
  'user-stats': { component: StatisticsManager, title: '统计内容' }
}

// 登录相关
const isLoggedIn = ref(localStorage.getItem('loginUser') === 'manager')
const loginForm = ref({ username: '', password: '' })
const loginError = ref('')

const handleLogin = () => {
  if (loginForm.value.username === 'manager' && loginForm.value.password === '123456') {
    localStorage.setItem('loginUser', 'manager')
    isLoggedIn.value = true
    loginError.value = ''
  } else {
    loginError.value = '账号或密码错误'
  }
}
const handleLogout = () => {
  localStorage.removeItem('loginUser')
  isLoggedIn.value = false
  loginForm.value.username = ''
  loginForm.value.password = ''
}

// 切换页面
const switchPage = (page) => {
  activePage.value = page
}

// 获取当前页面组件
const currentComponent = computed(() => pages[activePage.value]?.component)
</script>

<template>
  <div class="app-container">
    <template v-if="!isLoggedIn">
      <!-- 登录界面 -->
      <div class="login-bg">
        <div class="login-card">
          <div class="login-logo">
            <i class="fa fa-cogs text-3xl text-primary"></i>
            <span class="ml-2 text-2xl font-bold text-primary">心屿项目管理系统</span>
          </div>
          <form @submit.prevent="handleLogin" class="login-form">
            <div class="form-group">
              <input v-model="loginForm.username" type="text" placeholder="账号" autocomplete="username" required />
            </div>
            <div class="form-group">
              <input v-model="loginForm.password" type="password" placeholder="密码" autocomplete="current-password" required />
            </div>
            <button class="login-btn" type="submit">登录</button>
            <div v-if="loginError" class="login-error">{{ loginError }}</div>
          </form>
        </div>
      </div>
    </template>
    <template v-else>
      <!-- 导航栏 -->
      <nav class="bg-white shadow-md fixed top-0 left-0 right-0 z-50 transition-all duration-300" id="navbar">
        <div class="container mx-auto px-4 py-3 flex justify-between items-center">
          <div class="flex items-center space-x-2">
            <i class="fa fa-cogs text-primary text-2xl"></i>
            <h1 class="text-xl font-bold text-primary">后台管理系统</h1>
          </div>
          <div class="hidden md:flex items-center space-x-6">
            <a 
              href="#" 
              @click.prevent="switchPage('user-manager')"
              :class="[
                'font-medium px-1 py-4 transition-colors',
                activePage === 'user-manager' 
                  ? 'text-primary border-b-2 border-primary' 
                  : 'text-gray-600 hover:text-primary'
              ]"
            >
              用户管理
            </a>
            <a 
              href="#" 
              @click.prevent="switchPage('ai-role-manager')"
              :class="[
                'font-medium px-1 py-4 transition-colors',
                activePage === 'ai-role-manager' 
                  ? 'text-primary border-b-2 border-primary' 
                  : 'text-gray-600 hover:text-primary'
              ]"
            >
              AI角色管理
            </a>
            <a 
              href="#" 
              @click.prevent="switchPage('user-stats')"
              :class="[
                'font-medium px-1 py-4 transition-colors',
                activePage === 'user-stats' 
                  ? 'text-primary border-b-2 border-primary' 
                  : 'text-gray-600 hover:text-primary'
              ]"
            >
              统计管理
            </a>
            <button class="logout-btn ml-6" @click="handleLogout">
              <i class="fa fa-sign-out mr-1"></i>退出登录
            </button>
          </div>
          <div class="md:hidden">
            <button id="menu-toggle" class="text-gray-600 focus:outline-none">
              <i class="fa fa-bars text-xl"></i>
            </button>
          </div>
        </div>
        <!-- 移动端菜单 -->
        <div id="mobile-menu" class="hidden md:hidden bg-white px-4 py-2 shadow-lg">
          <a 
            href="#" 
            @click.prevent="switchPage('user-manager')"
            :class="[
              'block py-2 transition-colors',
              activePage === 'user-manager' ? 'text-primary font-medium' : 'text-gray-600 hover:text-primary'
            ]"
          >
            用户管理
          </a>
          <a 
            href="#" 
            @click.prevent="switchPage('ai-role-manager')"
            :class="[
              'block py-2 transition-colors',
              activePage === 'ai-role-manager' ? 'text-primary font-medium' : 'text-gray-600 hover:text-primary'
            ]"
          >
            AI角色管理
          </a>
          <a 
            href="#" 
            @click.prevent="switchPage('user-stats')"
            :class="[
              'block py-2 transition-colors',
              activePage === 'user-stats' ? 'text-primary font-medium' : 'text-gray-600 hover:text-primary'
            ]"
          >
            用户统计
          </a>
          <button class="logout-btn w-full mt-2" @click="handleLogout">
            <i class="fa fa-sign-out mr-1"></i>退出登录
          </button>
        </div>
      </nav>
      <!-- 主内容区 -->
      <main class="pt-24">
        <component :is="currentComponent" />
      </main>
    </template>
  </div>
</template>

<script>
export default {
  name: 'App',
  mounted() {
    // 导航栏滚动效果
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
      if (window.scrollY > 10) {
        navbar.classList.add('py-2');
        navbar.classList.add('bg-white/95');
        navbar.classList.add('backdrop-blur-sm');
      } else {
        navbar.classList.remove('py-2');
        navbar.classList.remove('bg-white/95');
        navbar.classList.remove('backdrop-blur-sm');
      }
    });
    
    // 移动端菜单切换
    const menuToggle = document.getElementById('menu-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    if (menuToggle && mobileMenu) {
      menuToggle.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden');
      });
    }
  }
}
</script>

<style scoped>
.app-container {
  min-height: 100vh;
  background-color: #f8fafc;
}

/* 登录页样式 */
.login-bg {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(120deg, #e0e7ff 0%, #f8fafc 100%);
}
.login-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.08);
  padding: 2.5rem 2.5rem 2rem 2.5rem;
  min-width: 340px;
  max-width: 90vw;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.login-logo {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
}
.login-form {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}
.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.2s;
}
.form-group input:focus {
  border-color: #6366f1;
}
.login-btn {
  width: 100%;
  background: linear-gradient(90deg, #6366f1 0%, #60a5fa 100%);
  color: #fff;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  padding: 0.75rem;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
}
.login-btn:hover {
  background: linear-gradient(90deg, #4f46e5 0%, #2563eb 100%);
}
.login-error {
  color: #ef4444;
  margin-top: 0.5rem;
  text-align: center;
  font-size: 0.95rem;
}
.login-tip {
  margin-top: 1.5rem;
  color: #64748b;
  font-size: 0.95rem;
  text-align: center;
}

/* 导航栏样式 */
#navbar {
  backdrop-filter: blur(8px);
}
.logout-btn {
  background: #f3f4f6;
  color: #374151;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  transition: all 0.2s;
  font-weight: 500;
  border: none;
  cursor: pointer;
}
.logout-btn:hover {
  background: #e5e7eb;
}

/* 页面切换动画 */
.page-enter-active,
.page-leave-active {
  transition: opacity 0.3s ease;
}
.page-enter-from,
.page-leave-to {
  opacity: 0;
}
</style>
