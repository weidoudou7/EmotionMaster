<template>
  <div class="statistics-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1 class="text-3xl font-bold text-gray-800">数据统计</h1>
      <p class="text-gray-600 mt-2">实时监控系统各项数据指标</p>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <i class="fa fa-refresh fa-spin text-2xl text-primary"></i>
        <p class="mt-2 text-gray-600">正在加载统计数据...</p>
      </div>
    </div>

    <!-- 统计卡片区域 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon bg-blue-100">
          <i class="fa fa-users text-blue-600"></i>
        </div>
        <div class="stat-content">
          <h3 class="stat-title">总用户数</h3>
          <p class="stat-value">{{ totalUsers }}</p>
          <p class="stat-change text-green-600">
            <i class="fa fa-arrow-up"></i> +{{ userGrowth }}%
          </p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon bg-green-100">
          <i class="fa fa-cogs text-green-600"></i>
        </div>
        <div class="stat-content">
          <h3 class="stat-title">AI角色数</h3>
          <p class="stat-value">{{ totalAiRoles }}</p>
          <p class="stat-change text-green-600">
            <i class="fa fa-arrow-up"></i> +{{ aiRoleGrowth }}%
          </p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon bg-purple-100">
          <i class="fa fa-comments text-purple-600"></i>
        </div>
        <div class="stat-content">
          <h3 class="stat-title">对话总数</h3>
          <p class="stat-value">{{ totalConversations }}</p>
          <p class="stat-change text-green-600">
            <i class="fa fa-arrow-up"></i> +{{ conversationGrowth }}%
          </p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon bg-orange-100">
          <i class="fa fa-user-circle text-orange-600"></i>
        </div>
        <div class="stat-content">
          <h3 class="stat-title">活跃用户</h3>
          <p class="stat-value">{{ activeUsers }}</p>
          <p class="stat-subtitle text-gray-500">最近7天有更新的用户</p>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <div class="charts-section">
      <!-- 用户增长趋势图 -->
      <div class="chart-container">
        <div class="chart-header">
          <h3 class="chart-title">用户增长趋势</h3>
          <div class="chart-controls">
            <button 
              v-for="type in chartTypes" 
              :key="type.value"
              @click="currentChartType = type.value"
              :class="[
                'chart-type-btn',
                currentChartType === type.value ? 'active' : ''
              ]"
            >
              <i :class="type.icon"></i>
              {{ type.label }}
            </button>
          </div>
        </div>
        <div class="chart-content">
          <div ref="userGrowthChart" style="width: 100%; height: 300px;"></div>
        </div>
      </div>

      <!-- AI角色分布图 -->
      <div class="chart-container">
        <div class="chart-header">
          <h3 class="chart-title">AI角色分布</h3>
          <div class="chart-controls">
            <button 
              v-for="type in chartTypes" 
              :key="type.value"
              @click="currentAiRoleChartType = type.value"
              :class="[
                'chart-type-btn',
                currentAiRoleChartType === type.value ? 'active' : ''
              ]"
            >
              <i :class="type.icon"></i>
              {{ type.label }}
            </button>
          </div>
        </div>
        <div class="chart-content">
          <div ref="aiRoleChart" style="width: 100%; height: 300px;"></div>
        </div>
      </div>

      <!-- AI角色浏览量分布图 -->
      <div class="chart-container">
        <div class="chart-header">
          <h3 class="chart-title">AI角色浏览量分布</h3>
          <div class="chart-controls">
            <button 
              v-for="type in chartTypes" 
              :key="type.value"
              @click="currentViewChartType = type.value"
              :class="[
                'chart-type-btn',
                currentViewChartType === type.value ? 'active' : ''
              ]"
            >
              <i :class="type.icon"></i>
              {{ type.label }}
            </button>
          </div>
        </div>
        <div class="chart-content">
          <div ref="aiRoleViewChart" style="width: 100%; height: 300px;"></div>
        </div>
      </div>

      <!-- AI角色对话数TOP7图表 -->
      <div class="chart-container">
        <div class="chart-header">
          <h3 class="chart-title">AI角色对话TOP7</h3>
          <div class="chart-controls">
            <button 
              v-for="type in chartTypes" 
              :key="type.value"
              @click="currentTopConversationChartType = type.value"
              :class="[
                'chart-type-btn',
                currentTopConversationChartType === type.value ? 'active' : '',
              ]"
            >
              <i :class="type.icon"></i>
              {{ type.label }}
            </button>
          </div>
        </div>
        <div class="chart-content">
          <div ref="topConversationChart" style="width: 100%; height: 300px;"></div>
        </div>
      </div>
    </div>

    <!-- 数据表格区域 -->
    <div class="tables-section">
      <!-- 用户统计表格 -->
      <div class="table-container">
        <div class="table-header">
          <h3 class="table-title">用户统计详情</h3>
          <div class="table-actions">
            <input 
              type="text" 
              v-model="userSearchQuery" 
              placeholder="搜索用户..."
              class="search-input"
            >
            <select v-model="userSortBy" class="sort-select">
              <option value="username">按用户名</option>
              <option value="registerDate">按注册时间</option>
              <option value="lastLogin">按最后登录</option>
            </select>
          </div>
        </div>
        <div class="table-wrapper">
          <table class="data-table">
            <thead>
              <tr>
                <th>用户名</th>
                <th>注册时间</th>
                <th>更新时间</th>
                <th>等级</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in pagedUsers" :key="user.id">
                <td>{{ user.userName }}</td>
                <td>{{ formatDate(user.registerTime) }}</td>
                <td>{{ formatDate(user.updateTime) }}</td>
                <td>{{ user.level || 1 }}</td>
                <td>
                  <button class="action-btn view-btn" @click="viewUser(user)">查看</button>
                  <button class="action-btn edit-btn" @click="editUser(user)">编辑</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="table-pagination">
          <div>显示 {{ (currentPage - 1) * itemsPerPage + 1 }} 至 {{ Math.min(currentPage * itemsPerPage, filteredUsers.length) }} 条，共 {{ filteredUsers.length }} 条记录</div>
          <div class="flex items-center space-x-2">
            <button @click="prevPage" :disabled="currentPage === 1">上一页</button>
            <span>{{ currentPage }} / {{ totalPages }}</span>
            <button @click="nextPage" :disabled="currentPage === totalPages">下一页</button>
          </div>
        </div>
      </div>

      <!-- AI角色统计表格 -->
      <div class="table-container">
        <div class="table-header">
          <h3 class="table-title">AI角色统计详情</h3>
          <div class="table-actions">
            <input 
              type="text" 
              v-model="aiRoleSearchQuery" 
              placeholder="搜索角色..."
              class="search-input"
            >
            <select v-model="aiRoleSortBy" class="sort-select">
              <option value="name">按名称</option>
              <option value="usageCount">按浏览量</option>
              <option value="createDate">按创建时间</option>
            </select>
          </div>
        </div>
        <div class="table-wrapper">
          <table class="data-table">
            <thead>
              <tr>
                <th>角色名称</th>
                <th>创建时间</th>
                <th>浏览量</th>
                <th>角色类型</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="role in pagedAiRoles" :key="role.id">
                <td>{{ role.roleName }}</td>
                <td>{{ formatDate(role.createdAt) }}</td>
                <td>{{ role.viewCount || 0 }}</td>
                <td>{{ role.roleType || 'custom' }}</td>
                <td>
                  <button class="action-btn view-btn" @click="viewRole(role)">查看</button>
                  <button class="action-btn edit-btn" @click="editRole(role)">编辑</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="table-pagination">
          <div>显示 {{ (currentAiRolePage - 1) * itemsPerPage + 1 }} 至 {{ Math.min(currentAiRolePage * itemsPerPage, filteredAiRoles.length) }} 条，共 {{ filteredAiRoles.length }} 条记录</div>
          <div class="flex items-center space-x-2">
            <button @click="prevAiRolePage" :disabled="currentAiRolePage === 1">上一页</button>
            <span>{{ currentAiRolePage }} / {{ totalAiRolePages }}</span>
            <button @click="nextAiRolePage" :disabled="currentAiRolePage === totalAiRolePages">下一页</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户编辑/查看弹窗 -->
    <transition name="modal">
      <div v-if="showUserModal" class="modal-mask">
        <div class="modal-wrapper">
          <div class="modal-container">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-bold">{{ userModalData.id ? (isUserEdit ? '编辑用户' : '查看用户') : '新增用户' }}</h3>
              <button @click="showUserModal = false" class="text-gray-400 hover:text-gray-600">
                <i class="fa fa-times text-xl"></i>
              </button>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- 基本信息 -->
              <div class="space-y-4">
                <h4 class="font-medium text-gray-800 border-b pb-2">基本信息</h4>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">用户名 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="userModalData.userName" 
                    :readonly="!isUserEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入用户名"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">邮箱 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="userModalData.email" 
                    type="email"
                    :readonly="!isUserEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入邮箱"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">性别</label>
                  <select 
                    v-model="userModalData.gender"
                    :disabled="!isUserEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  >
                    <option value="">请选择性别</option>
                    <option value="男">男</option>
                    <option value="女">女</option>
                  </select>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">等级</label>
                  <select 
                    v-model.number="userModalData.level"
                    :disabled="!isUserEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  >
                    <option value="1">1 - 普通用户</option>
                    <option value="2">2 - 普通用户</option>
                    <option value="3">3 - 普通用户</option>
                    <option value="4">4 - 初级VIP</option>
                    <option value="5">5 - 初级VIP</option>
                    <option value="6">6 - 初级VIP</option>
                    <option value="7">7 - 高级VIP</option>
                    <option value="8">8 - 高级VIP</option>
                    <option value="9">9 - 高级VIP</option>
                    <option value="10">10 - 超级VIP</option>
                    <option value="11">11 - 超级VIP</option>
                    <option value="12">12 - 超级VIP</option>
                  </select>
                </div>
              </div>
              
              <!-- 高级设置 -->
              <div class="space-y-4">
                <h4 class="font-medium text-gray-800 border-b pb-2">高级设置</h4>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">个人签名</label>
                  <textarea 
                    v-model="userModalData.signature" 
                    :readonly="!isUserEdit"
                    rows="3"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入个人签名"
                  ></textarea>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">隐私设置</label>
                  <div class="flex items-center space-x-4">
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="userModalData.privacyVisible" 
                        :value="true"
                        :disabled="!isUserEdit"
                        class="mr-2"
                      />
                      <span class="text-sm">公开</span>
                    </label>
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="userModalData.privacyVisible" 
                        :value="false"
                        :disabled="!isUserEdit"
                        class="mr-2"
                      />
                      <span class="text-sm">私密</span>
                    </label>
                  </div>
                </div>
                
                <div v-if="userModalData.id">
                  <label class="block text-sm font-medium text-gray-700 mb-2">注册时间</label>
                  <input 
                    v-model="userModalData.registerTime" 
                    type="datetime-local"
                    readonly
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-gray-50"
                  />
                </div>
              </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="flex justify-between items-center mt-6 pt-4 border-t">
              <div class="flex space-x-2">
                <button 
                  v-if="userModalData.id && isUserEdit" 
                  class="btn-secondary" 
                  @click="viewUser(userModalData)"
                >
                  <i class="fa fa-eye mr-1"></i>查看详情
                </button>
              </div>
              <div class="flex space-x-3">
                <button class="btn-secondary" @click="showUserModal = false">取消</button>
                <button v-if="isUserEdit" class="btn-primary" @click="saveUser">保存</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <!-- AI角色编辑/查看弹窗 -->
    <transition name="modal">
      <div v-if="showRoleModal" class="modal-mask">
        <div class="modal-wrapper">
          <div class="modal-container">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-bold">{{ roleModalData.id ? (isRoleEdit ? '编辑角色' : '查看角色') : '新增角色' }}</h3>
              <button @click="showRoleModal = false" class="text-gray-400 hover:text-gray-600">
                <i class="fa fa-times text-xl"></i>
              </button>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- 基本信息 -->
              <div class="space-y-4">
                <h4 class="font-medium text-gray-800 border-b pb-2">基本信息</h4>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色名称 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="roleModalData.roleName" 
                    :readonly="!isRoleEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入角色名称"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色作者 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="roleModalData.roleAuthor" 
                    :readonly="!isRoleEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入角色作者"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色类型</label>
                  <select 
                    v-model="roleModalData.roleType"
                    :disabled="!isRoleEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  >
                    <option value="system">系统预设</option>
                    <option value="custom">自定义</option>
                    <option value="community">社区分享</option>
                  </select>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">头像URL</label>
                  <input 
                    v-model="roleModalData.avatarUrl" 
                    :readonly="!isRoleEdit"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入头像URL"
                  />
                </div>
              </div>
              
              <!-- 高级设置 -->
              <div class="space-y-4">
                <h4 class="font-medium text-gray-800 border-b pb-2">高级设置</h4>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色描述</label>
                  <textarea 
                    v-model="roleModalData.roleDescription" 
                    :readonly="!isRoleEdit"
                    rows="4"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入角色详细描述"
                  ></textarea>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">是否为模板</label>
                  <div class="flex items-center space-x-4">
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="roleModalData.isTemplate" 
                        :value="true"
                        :disabled="!isRoleEdit"
                        class="mr-2"
                      />
                      <span class="text-sm">是</span>
                    </label>
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="roleModalData.isTemplate" 
                        :value="false"
                        :disabled="!isRoleEdit"
                        class="mr-2"
                      />
                      <span class="text-sm">否</span>
                    </label>
                  </div>
                </div>
                
                <div v-if="roleModalData.id">
                  <label class="block text-sm font-medium text-gray-700 mb-2">创建时间</label>
                  <input 
                    v-model="roleModalData.createdAt" 
                    type="datetime-local"
                    readonly
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary bg-gray-50"
                  />
                </div>
              </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="flex justify-between items-center mt-6 pt-4 border-t">
              <div class="flex space-x-2">
                <button 
                  v-if="roleModalData.id && isRoleEdit" 
                  class="btn-secondary" 
                  @click="viewRole(roleModalData)"
                >
                  <i class="fa fa-eye mr-1"></i>查看详情
                </button>
              </div>
              <div class="flex space-x-3">
                <button class="btn-secondary" @click="showRoleModal = false">取消</button>
                <button v-if="isRoleEdit" class="btn-primary" @click="saveRole">保存</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch, nextTick } from 'vue'
import axios from 'axios'
import * as echarts from 'echarts'

// 响应式数据
const totalUsers = ref(0)
const totalAiRoles = ref(0)
const totalConversations = ref(0)
const activeUsers = ref(0)

const userGrowth = ref(0)
const aiRoleGrowth = ref(0)
const conversationGrowth = ref(0)
const activeUserDecline = ref(0)

// 加载状态
const loading = ref(false)

// 图表相关
const currentChartType = ref('bar')
const currentAiRoleChartType = ref('pie')
const currentViewChartType = ref('bar')
const currentTopConversationChartType = ref('bar')
const userGrowthChart = ref(null)
const aiRoleChart = ref(null)
const aiRoleViewChart = ref(null)
const topConversationChart = ref(null)
const userChartInstance = ref(null)
const aiRoleChartInstance = ref(null)
const aiRoleViewChartInstance = ref(null)
const topConversationChartInstance = ref(null)

const chartTypes = [
  { value: 'bar', label: '柱状图', icon: 'fa fa-bar-chart-o' },
  { value: 'line', label: '折线图', icon: 'fa fa-area-chart' },
  { value: 'pie', label: '饼图', icon: 'fa fa-circle-o' }
]

// 表格相关
const userSearchQuery = ref('')
const aiRoleSearchQuery = ref('')
const userSortBy = ref('username')
const aiRoleSortBy = ref('name')
const currentPage = ref(1)
const currentAiRolePage = ref(1)
const itemsPerPage = 10

// 数据
const users = reactive([])
const aiRoles = reactive([])

// 弹窗相关数据
const showUserModal = ref(false)
const showRoleModal = ref(false)
const isUserEdit = ref(false)
const isRoleEdit = ref(false)
const userModalData = reactive({})
const roleModalData = reactive({})

// AI角色对话TOP7数据缓存
const topConversationChartData = reactive({ labels: [], data: [] })

// 计算属性
const filteredUsers = computed(() => {
  let filtered = users.filter(user => 
    user.userName.toLowerCase().includes(userSearchQuery.value.toLowerCase())
  )
  
  filtered.sort((a, b) => {
    switch (userSortBy.value) {
      case 'username':
        return a.userName.localeCompare(b.userName)
      case 'registerDate':
        return new Date(a.registerTime) - new Date(b.registerTime)
      case 'lastLogin':
        return new Date(a.updateTime) - new Date(b.updateTime)
      default:
        return 0
    }
  })
  
  return filtered
})

const filteredAiRoles = computed(() => {
  let filtered = aiRoles.filter(role => 
    role.roleName.toLowerCase().includes(aiRoleSearchQuery.value.toLowerCase())
  )
  
  filtered.sort((a, b) => {
    switch (aiRoleSortBy.value) {
      case 'name':
        return a.roleName.localeCompare(b.roleName)
      case 'usageCount':
        return (b.viewCount || 0) - (a.viewCount || 0)
      case 'createDate':
        return new Date(a.createdAt) - new Date(b.createdAt)
      default:
        return 0
    }
  })
  
  return filtered
})

const totalPages = computed(() => Math.ceil(filteredUsers.value.length / itemsPerPage))
const totalAiRolePages = computed(() => Math.ceil(filteredAiRoles.value.length / itemsPerPage))

// 分页数据
const pagedUsers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  return filteredUsers.value.slice(start, start + itemsPerPage)
})

const pagedAiRoles = computed(() => {
  const start = (currentAiRolePage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredAiRoles.value.slice(start, end)
})

// 方法
const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('zh-CN')
}

const getStatusClass = (status) => {
  return status === '活跃' || status === '启用' 
    ? 'status-active' 
    : 'status-inactive'
}

const prevPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const prevAiRolePage = () => {
  if (currentAiRolePage.value > 1) currentAiRolePage.value--
}

const nextAiRolePage = () => {
  if (currentAiRolePage.value < totalAiRolePages.value) currentAiRolePage.value++
}

// 用户相关方法
const viewUser = (user) => {
  Object.assign(userModalData, user)
  isUserEdit.value = false
  showUserModal.value = true
}

const editUser = (user) => {
  Object.assign(userModalData, user)
  isUserEdit.value = true
  showUserModal.value = true
}

const saveUser = async () => {
  try {
    if (userModalData.id) {
      // 更新用户
      const res = await axios.put('/api/management/user', userModalData)
      if (res.data.error) {
        alert(res.data.error)
        return
      }
      alert('用户更新成功')
    } else {
      // 创建用户
      const res = await axios.post('/api/management/user', userModalData)
      if (res.data.error) {
        alert(res.data.error)
        return
      }
      alert('用户创建成功')
    }
    showUserModal.value = false
    fetchUserStatistics()
  } catch (e) {
    console.error('保存失败:', e)
    if (e.response && e.response.data && e.response.data.error) {
      alert(e.response.data.error)
    } else {
      alert('保存失败')
    }
  }
}

// AI角色相关方法
const viewRole = (role) => {
  Object.assign(roleModalData, role)
  isRoleEdit.value = false
  showRoleModal.value = true
}

const editRole = (role) => {
  Object.assign(roleModalData, role)
  isRoleEdit.value = true
  showRoleModal.value = true
}

const saveRole = async () => {
  try {
    if (roleModalData.id) {
      // 更新角色
      const res = await axios.put('/api/management/role', roleModalData)
      if (!res.data.success) {
        alert(res.data.error || '更新失败')
        return
      }
      alert('角色更新成功')
    } else {
      // 创建角色
      const res = await axios.post('/api/management/role', roleModalData)
      if (!res.data.success) {
        alert(res.data.error || '创建失败')
        return
      }
      alert('角色创建成功')
    }
    showRoleModal.value = false
    fetchAiRoleStatistics()
  } catch (e) {
    console.error('保存失败:', e)
    if (e.response && e.response.data && e.response.data.error) {
      alert(e.response.data.error)
    } else {
      alert('保存失败')
    }
  }
}

// ECharts图表初始化
const initCharts = async () => {
  try {
    await nextTick()
    
    // 初始化用户增长趋势图
    if (userGrowthChart.value && !userChartInstance.value) {
      userChartInstance.value = echarts.init(userGrowthChart.value, null, {
        renderer: 'canvas'
      })
    }
    
    // 初始化AI角色分布图
    if (aiRoleChart.value && !aiRoleChartInstance.value) {
      aiRoleChartInstance.value = echarts.init(aiRoleChart.value, null, {
        renderer: 'canvas'
      })
    }
    
    // 初始化AI角色浏览量分布图
    if (aiRoleViewChart.value && !aiRoleViewChartInstance.value) {
      aiRoleViewChartInstance.value = echarts.init(aiRoleViewChart.value, null, {
        renderer: 'canvas'
      })
    }
    
    // 初始化AI角色对话数TOP7图表
    if (topConversationChart.value && !topConversationChartInstance.value) {
      topConversationChartInstance.value = echarts.init(topConversationChart.value, null, {
        renderer: 'canvas'
      })
    }
  } catch (error) {
    console.error('图表初始化失败:', error)
  }
}

// 绘制用户增长趋势图
const drawUserGrowthChart = (data, labels) => {
  if (!userChartInstance.value) return
  
  const option = {
    title: {
      text: '用户增长趋势',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: labels,
      axisLabel: {
        rotate: 45
      }
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '用户数量',
        type: currentChartType.value,
        data: data,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        },
        emphasis: {
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: '#2378f7' },
              { offset: 0.7, color: '#2378f7' },
              { offset: 1, color: '#83bff6' }
            ])
          }
        }
      }
    ]
  }
  
  // 如果是折线图，调整样式
  if (currentChartType.value === 'line') {
    option.series[0].smooth = true
    option.series[0].lineStyle = {
      width: 3
    }
    option.series[0].symbol = 'circle'
    option.series[0].symbolSize = 8
  }
  
  // 如果是饼图，调整配置
  if (currentChartType.value === 'pie') {
    option.series[0] = {
      name: '用户数量',
      type: 'pie',
      radius: '50%',
      data: labels.map((label, index) => ({
        name: label,
        value: data[index]
      })),
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }
    delete option.xAxis
    delete option.yAxis
    delete option.grid
  }
  
  userChartInstance.value.setOption(option, true)
}

// 绘制AI角色分布图
const drawAiRoleChart = (data, labels) => {
  if (!aiRoleChartInstance.value) return
  
  const option = {
    title: {
      text: 'AI角色分布',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: currentAiRoleChartType.value === 'pie' ? 'item' : 'axis',
      formatter: function(params) {
        if (currentAiRoleChartType.value === 'pie') {
          return `${params.seriesName}<br/>${params.name}: ${params.value} 个角色 (${params.percent}%)`;
        } else {
          if (Array.isArray(params)) params = params[0];
          return `${params.name}: ${params.value} 个角色`;
        }
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      data: labels
    },
    series: [
      {
        name: '角色类型',
        type: currentAiRoleChartType.value,
        radius: currentAiRoleChartType.value === 'pie' ? '50%' : ['40%', '70%'],
        avoidLabelOverlap: false,
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '30',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: labels.map((label, index) => ({
          name: label,
          value: data[index]
        }))
      }
    ]
  }
  
  // 如果是柱状图或折线图，调整配置
  if (currentAiRoleChartType.value === 'bar' || currentAiRoleChartType.value === 'line') {
    option.xAxis = {
      type: 'category',
      data: labels,
      axisLabel: {
        rotate: 45
      }
    }
    option.yAxis = {
      type: 'value'
    }
    option.grid = {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    }
    option.series[0] = {
      name: '角色数量',
      type: currentAiRoleChartType.value,
      data: data,
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#91d5ff' },
          { offset: 1, color: '#1890ff' }
        ])
      }
    }
    delete option.legend
  }
  
  aiRoleChartInstance.value.setOption(option, true)
}

// 绘制AI角色浏览量分布图
const drawAiRoleViewChart = (data, labels) => {
  if (!aiRoleViewChartInstance.value) return
  
  const option = {
    title: {
      text: 'AI角色浏览量分布',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: currentViewChartType.value === 'pie' ? 'item' : 'axis',
      formatter: function(params) {
        if (currentViewChartType.value === 'pie') {
          return `${params.seriesName}<br/>${params.name}: ${params.value} 个角色 (${params.percent}%)`;
        } else {
          if (Array.isArray(params)) params = params[0];
          return `${params.name}: ${params.value} 个角色`;
        }
      }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      data: labels
    },
    series: [
      {
        name: '浏览量区间',
        type: currentViewChartType.value,
        radius: currentViewChartType.value === 'pie' ? '50%' : ['40%', '70%'],
        avoidLabelOverlap: false,
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '30',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: labels.map((label, index) => ({
          name: label,
          value: data[index]
        }))
      }
    ]
  }
  
  // 如果是柱状图或折线图，调整配置
  if (currentViewChartType.value === 'bar' || currentViewChartType.value === 'line') {
    option.xAxis = {
      type: 'category',
      data: labels,
      axisLabel: {
        rotate: 45
      }
    }
    option.yAxis = {
      type: 'value'
    }
    option.grid = {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    }
    option.series[0] = {
      name: '角色数量',
      type: currentViewChartType.value,
      data: data,
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#ffd666' },
          { offset: 1, color: '#faad14' }
        ])
      }
    }
    delete option.legend
  }
  
  aiRoleViewChartInstance.value.setOption(option, true)
}

// 绘制AI角色对话数TOP7图表
const drawTopConversationChart = (data, labels) => {
  if (!topConversationChartInstance.value) return
  topConversationChartInstance.value.clear();
  const option = {
    title: {
      text: 'AI角色对话TOP7',
      left: 'center',
      textStyle: { fontSize: 16, fontWeight: 'bold' }
    },
    tooltip: {
      trigger: currentTopConversationChartType.value === 'pie' ? 'item' : 'axis',
      formatter: function(params) {
        if (currentTopConversationChartType.value === 'pie') {
          return `${params.seriesName}<br/>${params.name}: ${params.value} 次对话 (${params.percent}%)`;
        } else {
          if (Array.isArray(params)) params = params[0];
          return `${params.name}: ${params.value} 次对话`;
        }
      }
    },
    legend: currentTopConversationChartType.value === 'pie' ? {
      orient: 'vertical',
      left: 'left',
      top: 'center',
      data: labels
    } : undefined,
    series: [
      {
        name: '对话数',
        type: currentTopConversationChartType.value,
        radius: currentTopConversationChartType.value === 'pie' ? ['40%', '70%'] : undefined,
        center: currentTopConversationChartType.value === 'pie' ? ['60%', '50%'] : undefined,
        data: labels.map((label, idx) => ({ name: label, value: data[idx] })),
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#ffbb96' },
            { offset: 1, color: '#d4380d' }
          ])
        }
      }
    ],
  }
  if (currentTopConversationChartType.value === 'bar' || currentTopConversationChartType.value === 'line') {
    option.xAxis = { type: 'category', data: labels, axisLabel: { rotate: 45 } }
    option.yAxis = { type: 'value',minInterval: 1,axisLabel:{formatter: '{value} 次'} }
    option.grid = { left: '3%', right: '4%', bottom: '3%', containLabel: true }
    option.series[0].type = currentTopConversationChartType.value
    option.series[0].itemStyle = {
      color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 0, color: '#ffbb96' },
        { offset: 1, color: '#d4380d' }
      ])
    }
    delete option.legend
    delete option.series[0].radius
    delete option.series[0].center
  }
  topConversationChartInstance.value.setOption(option, true)
}

// 监听图表类型变化
watch(currentChartType, () => {
  // 重新获取数据并绘制图表
  fetchUserGrowthTrend()
})

watch(currentAiRoleChartType, () => {
  // 重新获取数据并绘制图表
  fetchAiRoleDistribution()
})

watch(currentViewChartType, () => {
  // 重新获取数据并绘制图表
  fetchAiRoleViewDistribution()
})

watch(currentTopConversationChartType, () => {
  drawTopConversationChart(topConversationChartData.data, topConversationChartData.labels)
})

// 监听搜索和排序变化，重置页码
watch(userSearchQuery, () => {
  currentPage.value = 1
})

watch(userSortBy, () => {
  currentPage.value = 1
})

watch(aiRoleSearchQuery, () => {
  currentAiRolePage.value = 1
})

watch(aiRoleSortBy, () => {
  currentAiRolePage.value = 1
})

// API调用方法
const fetchDashboardCards = async () => {
  try {
    loading.value = true
    const res = await axios.get('/api/management/statistics/dashboard-cards')
    if (res.data.success) {
      const cardsData = res.data.data.cards
      totalUsers.value = cardsData.totalUsers
      totalAiRoles.value = cardsData.totalAiRoles
      totalConversations.value = cardsData.totalConversations
      activeUsers.value = cardsData.activeUsers
      userGrowth.value = cardsData.userGrowth
      aiRoleGrowth.value = cardsData.aiRoleGrowth
      conversationGrowth.value = cardsData.conversationGrowth
      activeUserDecline.value = cardsData.activeUserDecline
    }
  } catch (error) {
    console.error('获取统计数据失败:', error)
    alert('获取统计数据失败')
  } finally {
    loading.value = false
  }
}

const fetchUserGrowthTrend = async () => {
  try {
    const res = await axios.get('/api/management/statistics/user-growth-trend')
    if (res.data.success) {
      const data = res.data.data
      const userData = data.userCounts
      const userLabels = data.days
      drawUserGrowthChart(userData, userLabels)
    }
  } catch (error) {
    console.error('获取用户增长趋势失败:', error)
    alert('获取用户增长趋势失败')
  }
}

const fetchAiRoleDistribution = async () => {
  try {
    const res = await axios.get('/api/management/statistics/ai-role-distribution')
    if (res.data.success) {
      const data = res.data.data
      const roleData = data.roleCounts
      const roleLabels = data.roleTypes
      drawAiRoleChart(roleData, roleLabels)
    }
  } catch (error) {
    console.error('获取AI角色分布失败:', error)
    alert('获取AI角色分布失败')
  }
}

const fetchUserStatistics = async () => {
  try {
    const res = await axios.get('/api/management/statistics/user-statistics')
    if (res.data.success) {
      users.length = 0
      users.push(...res.data.data.users)
    }
  } catch (error) {
    console.error('获取用户统计详情失败:', error)
    alert('获取用户统计详情失败')
  }
}

const fetchAiRoleStatistics = async () => {
  try {
    const res = await axios.get('/api/management/statistics/ai-role-statistics')
    if (res.data.success) {
      aiRoles.length = 0
      aiRoles.push(...res.data.data.aiRoles)
    }
  } catch (error) {
    console.error('获取AI角色统计详情失败:', error)
    alert('获取AI角色统计详情失败')
  }
}

const fetchAiRoleViewDistribution = async () => {
  try {
    const res = await axios.get('/api/management/statistics/ai-role-view-distribution')
    if (res.data.success) {
      const data = res.data.data
      const viewData = data.rangeCounts
      const viewLabels = data.rangeLabels
      drawAiRoleViewChart(viewData, viewLabels)
    }
  } catch (error) {
    console.error('获取AI角色浏览量分布失败:', error)
    alert('获取AI角色浏览量分布失败')
  }
}

const fetchTopConversationChart = async () => {
  try {
    const res = await axios.get('/api/management/statistics/top-ai-roles-by-conversation')
    if (res.data.success) {
      const topRoles = res.data.data.topRoles
      topConversationChartData.labels = topRoles.map(r => r.roleName)
      topConversationChartData.data = topRoles.map(r => r.conversationCount)
      drawTopConversationChart(topConversationChartData.data, topConversationChartData.labels)
    }
  } catch (error) {
    console.error('获取AI角色对话数TOP7失败:', error)
    alert('获取AI角色对话数TOP7失败')
  }
}

// 生命周期
onMounted(async () => {
  // 初始化图表
  await initCharts()
  
  // 获取所有统计数据
  await Promise.all([
    fetchDashboardCards(),
    fetchUserGrowthTrend(),
    fetchAiRoleDistribution(),
    fetchAiRoleViewDistribution(),
    fetchTopConversationChart(),
    fetchUserStatistics(),
    fetchAiRoleStatistics()
  ])
  
  // 监听窗口大小变化，自适应图表
  window.addEventListener('resize', () => {
    if (userChartInstance.value) {
      userChartInstance.value.resize()
    }
    if (aiRoleChartInstance.value) {
      aiRoleChartInstance.value.resize()
    }
    if (aiRoleViewChartInstance.value) {
      aiRoleViewChartInstance.value.resize()
    }
    if (topConversationChartInstance.value) {
      topConversationChartInstance.value.resize()
    }
  })
})
</script>

<style scoped>
.statistics-container {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 2rem;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: transform 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.stat-content {
  flex: 1;
}

.stat-title {
  font-size: 0.875rem;
  color: #6B7280;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 2rem;
  font-weight: bold;
  color: #1F2937;
  margin-bottom: 0.25rem;
}

.stat-change {
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.stat-subtitle {
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.charts-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.chart-container {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.chart-title {
  font-size: 1.25rem;
  font-weight: bold;
  color: #1F2937;
}

.chart-controls {
  display: flex;
  gap: 0.5rem;
}

.chart-type-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #E5E7EB;
  border-radius: 6px;
  background: white;
  color: #6B7280;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.chart-type-btn:hover {
  border-color: #3B82F6;
  color: #3B82F6;
}

.chart-type-btn.active {
  background: #3B82F6;
  border-color: #3B82F6;
  color: white;
}

.chart-content {
  height: 300px;
  width: 100%;
}

.tables-section {
  display: grid;
  gap: 2rem;
}

.table-container {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.table-title {
  font-size: 1.25rem;
  font-weight: bold;
  color: #1F2937;
}

.table-actions {
  display: flex;
  gap: 1rem;
}

.search-input {
  padding: 0.5rem 1rem;
  border: 1px solid #E5E7EB;
  border-radius: 6px;
  outline: none;
  transition: border-color 0.2s ease;
}

.search-input:focus {
  border-color: #3B82F6;
}

.sort-select {
  padding: 0.5rem 1rem;
  border: 1px solid #E5E7EB;
  border-radius: 6px;
  outline: none;
  background: white;
}

.table-wrapper {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th,
.data-table td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #E5E7EB;
}

.data-table th {
  background: #F9FAFB;
  font-weight: 600;
  color: #374151;
}

.data-table tr:hover {
  background: #F9FAFB;
}

.status-active {
  background: #D1FAE5;
  color: #065F46;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.875rem;
}

.status-inactive {
  background: #FEE2E2;
  color: #991B1B;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.875rem;
}

.action-btn {
  padding: 0.25rem 0.75rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  margin-right: 0.5rem;
  transition: background-color 0.2s ease;
}

.view-btn {
  background: #DBEAFE;
  color: #1E40AF;
}

.view-btn:hover {
  background: #BFDBFE;
}

.edit-btn {
  background: #FEF3C7;
  color: #92400E;
}

.edit-btn:hover {
  background: #FDE68A;
}

.table-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.table-pagination .flex {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.table-pagination button {
  padding: 0.5rem 1rem;
  border: 1px solid #E5E7EB;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.table-pagination button:hover:not(:disabled) {
  border-color: #3B82F6;
  color: #3B82F6;
}

.table-pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 颜色变量 */
:root {
  --primary: #165DFF;
  --secondary: #36D399;
  --warning: #FFAB00;
  --danger: #F87272;
  --info: #3B82F6;
  --dark: #1E293B;
  --light: #F8FAFC;
}

/* 按钮样式 */
.btn-primary {
  background: var(--primary);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
  font-weight: 500;
  border: none;
  cursor: pointer;
}

.btn-primary:hover {
  background: #1451d9;
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
  font-weight: 500;
  border: none;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

/* 模态框样式 */
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(4px);
}

.modal-wrapper {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.modal-container {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  padding: 24px 32px;
  min-width: 320px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalIn 0.3s ease-out;
}

@keyframes modalIn {
  from { 
    transform: scale(0.8); 
    opacity: 0; 
  }
  to { 
    transform: scale(1); 
    opacity: 1; 
  }
}

/* 过渡动画 */
.modal-enter-active, .modal-leave-active {
  transition: all 0.3s cubic-bezier(.55,0,.1,1);
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  text-align: center;
}

@media (max-width: 768px) {
  .statistics-container {
    padding: 1rem;
  }
  
  .charts-section {
    grid-template-columns: 1fr;
  }
  
  .chart-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .table-header {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
  
  .table-actions {
    width: 100%;
    flex-direction: column;
  }
  
  .modal-container {
    margin: 1rem;
    padding: 20px;
  }
  
  .btn-primary, .btn-secondary {
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
  }
}
</style>
