<template>
  <div class="user-manager bg-gray-50 min-h-screen">
    <div class="header-container">
      <div class="page-header">
        <h1 class="text-3xl font-bold text-gray-800">用户管理</h1>
        <p class="text-gray-600 mt-2">管理平台用户信息与权限</p>
      </div>
    </div>
    <!-- 主内容区 -->
    <main class="container mx-auto px-4 pb-12">
      <!-- 数据概览卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-xl p-6 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-sm font-medium">总用户数</p>
              <h3 class="text-3xl font-bold mt-1" id="total-users">{{ stats.totalUsers }}</h3>
              <p class="text-secondary text-sm mt-2 flex items-center">
                <i :class="stats.totalGrowthRate >= 0 ? 'fa fa-arrow-up' : 'fa fa-arrow-down'" class="mr-1"></i>
                {{ Math.abs(stats.totalGrowthRate) }}% <span class="text-gray-500 ml-1">较上周</span>
              </p>
            </div>
            <div class="bg-primary/10 p-3 rounded-lg">
              <i class="fa fa-users text-primary text-xl"></i>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-xl p-6 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-sm font-medium">活跃用户</p>
              <h3 class="text-3xl font-bold mt-1" id="active-users">{{ stats.activeUsers }}</h3>
              <p class="text-secondary text-sm mt-2 flex items-center">
                <i :class="stats.activeGrowthRate >= 0 ? 'fa fa-arrow-up' : 'fa fa-arrow-down'" class="mr-1"></i>
                {{ Math.abs(stats.activeGrowthRate) }}% <span class="text-gray-500 ml-1">较上周</span>
              </p>
            </div>
            <div class="bg-warning/10 p-3 rounded-lg">
              <i class="fa fa-user-circle text-warning text-xl"></i>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-xl p-6 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-sm font-medium">新增用户</p>
              <h3 class="text-3xl font-bold mt-1" id="new-users">{{ stats.newUsers }}</h3>
              <p class="text-secondary text-sm mt-2 flex items-center">
                <i :class="stats.newUserGrowthRate >= 0 ? 'fa fa-arrow-up' : 'fa fa-arrow-down'" class="mr-1"></i>
                {{ Math.abs(stats.newUserGrowthRate) }}% <span class="text-gray-500 ml-1">较上周</span>
              </p>
            </div>
            <div class="bg-danger/10 p-3 rounded-lg">
              <i class="fa fa-user-plus text-danger text-xl"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- 用户管理主区域 -->
      <div class="bg-white rounded-xl p-6 card-shadow mb-8">
        <!-- 工具栏 -->
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <h2 class="text-lg font-bold">用户列表</h2>
          <div class="flex flex-col sm:flex-row gap-3 w-full md:w-auto">
            <div class="relative flex-1 sm:flex-none">
              <input 
                v-model="searchKeyword" 
                placeholder="搜索用户名/邮箱" 
                class="pl-10 pr-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary w-full sm:w-64"
              />
              <i class="fa fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
            </div>
            <div class="flex gap-2">
              <button class="btn-primary" @click="searchUsers">
                <i class="fa fa-search mr-1"></i>搜索
              </button>
              <button class="btn-secondary" @click="resetSearch">
                <i class="fa fa-refresh mr-1"></i>重置
              </button>
              <button class="btn-secondary" @click="exportUsers">
                <i class="fa fa-download mr-1"></i>导出
              </button>
              <button class="btn-danger" @click="batchDelete">
                <i class="fa fa-trash mr-1"></i>批量删除
              </button>
              <button class="btn-primary" @click="addUser">
                <i class="fa fa-plus mr-1"></i>新增用户
              </button>
            </div>
          </div>
    </div>

        <!-- 用户表格 -->
        <div class="overflow-x-auto rounded-lg border border-gray-200 bg-white shadow-sm">
          <table class="w-full">
            <thead>
              <tr class="text-left text-gray-600 border-b-2 border-gray-200 bg-gray-50">
                <th class="py-4 px-3 font-semibold text-sm">
                  <input type="checkbox" v-model="selectAll" @change="toggleSelectAll" class="rounded w-4 h-4" />
                </th>
                <th class="py-4 px-3 font-semibold text-sm">ID</th>
                <th class="py-4 px-3 font-semibold text-sm">用户信息</th>
                <th class="py-4 px-3 font-semibold text-sm">邮箱</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[80px]">性别</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[80px]">等级</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[120px]">注册时间</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[120px]">更新时间</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[80px]">隐私</th>
                <th class="py-4 px-3 font-semibold text-sm">签名</th>
                <th class="py-4 px-3 font-semibold text-sm">操作</th>
        </tr>
      </thead>
      <tbody>
              <tr v-for="user in pagedUsers" :key="user.id" class="border-b hover:bg-gray-50 transition-colors align-middle" style="height:70px;">
                <td class="py-4 px-3">
                  <input type="checkbox" v-model="selectedIds" :value="user.id" class="rounded w-4 h-4" />
                </td>
                <td class="py-4 px-3 text-sm text-gray-500 font-mono">{{ user.id }}</td>
                <td class="py-4 px-3 min-w-[180px]">
                  <div class="flex items-center space-x-3">
                    <img :src="user.userAvatar" alt="头像" class="w-10 h-10 rounded-full object-cover border-2 border-gray-200 shadow-sm" />
                    <div class="flex flex-col">
                      <span class="font-semibold text-gray-900 truncate" :title="user.userName">{{ user.userName }}</span>
                      <span class="text-xs text-gray-400">ID: {{ user.userUID }}</span>
                    </div>
                  </div>
                </td>
                <td class="py-4 px-3 text-sm text-gray-600 truncate max-w-[140px]" :title="user.email">{{ user.email }}</td>
                <td class="py-4 px-3 min-w-[80px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block"
                    :class="user.gender === '男' ? 'bg-blue-100 text-blue-700' : (user.gender === '女' ? 'bg-pink-100 text-pink-700' : 'bg-gray-100 text-gray-500')">
                    {{ user.gender || '未设置' }}
                  </span>
                </td>
                <td class="py-4 px-3 min-w-[80px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block"
                    :class="getLevelClass(user.level)">
                    {{ user.level }}
                  </span>
                </td>
                <td class="py-4 px-3 text-sm text-gray-600 whitespace-nowrap min-w-[120px]" :title="user.registerTime">{{ user.registerTime }}</td>
                <td class="py-4 px-3 text-sm text-gray-600 whitespace-nowrap min-w-[120px]" :title="user.updateTime">{{ user.updateTime || '-' }}</td>
                <td class="py-4 px-3 min-w-[80px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block" :class="user.privacyVisible ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'">
                    {{ user.privacyVisible ? '公开' : '私密' }}
                  </span>
                </td>
                <td class="py-4 px-3 text-sm text-gray-600 max-w-[120px] truncate" :title="user.signature">{{ user.signature || '暂无签名' }}</td>
                <td class="py-4 px-3">
                  <div class="flex space-x-2">
                    <button class="text-primary hover:text-primary/80 transition-colors p-2 rounded-lg hover:bg-primary/10" @click="editUser(user)" title="编辑用户">
                      <i class="fa fa-edit text-base"></i>
                    </button>
                    <button class="text-info hover:text-info/80 transition-colors p-2 rounded-lg hover:bg-info/10" @click="viewUserDetails(user)" title="查看详情">
                      <i class="fa fa-eye text-base"></i>
                    </button>
                    <button class="text-danger hover:text-danger/80 transition-colors p-2 rounded-lg hover:bg-danger/10" @click="deleteUser(user.id)" title="删除用户">
                      <i class="fa fa-trash text-base"></i>
                    </button>
                  </div>
          </td>
        </tr>
      </tbody>
          </table>
        </div>

    <!-- 分页 -->
        <div class="flex justify-between items-center mt-6 text-sm text-gray-500">
          <div>显示 {{ (page - 1) * pageSize + 1 }} 至 {{ Math.min(page * pageSize, filteredUsers.length) }} 条，共 {{ filteredUsers.length }} 条记录</div>
          <div class="flex items-center space-x-2">
            <button class="btn-small" :disabled="page === 1" @click="page--">
              <i class="fa fa-chevron-left mr-1"></i>上一页
            </button>
            <span class="px-3 py-1">第{{ page }}/{{ totalPages }}页</span>
            <button class="btn-small" :disabled="page === totalPages" @click="page++">
              下一页<i class="fa fa-chevron-right ml-1"></i>
            </button>
            <span class="ml-4">每页
              <select v-model="pageSize" class="bg-gray-100 rounded-md px-2 py-1 border-0 focus:ring-0 ml-1">
          <option :value="5">5</option>
          <option :value="10">10</option>
          <option :value="20">20</option>
              </select> 条
            </span>
          </div>
        </div>
    </div>
    </main>

    <!-- 编辑/新增用户弹窗 -->
    <transition name="modal">
      <div v-if="showEdit" class="modal-mask">
        <div class="modal-wrapper">
          <div class="modal-container">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-bold">{{ editUserData.id ? '编辑用户' : '新增用户' }}</h3>
              <button @click="showEdit = false" class="text-gray-400 hover:text-gray-600">
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
                    v-model="editUserData.userName" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入用户名"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">邮箱 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="editUserData.email" 
                    type="email"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入邮箱"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">性别</label>
                  <select 
                    v-model="editUserData.gender"
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
                    v-model.number="editUserData.level"
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
                    v-model="editUserData.signature" 
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
                        v-model="editUserData.privacyVisible" 
                        :value="true"
                        class="mr-2"
                      />
                      <span class="text-sm">公开</span>
                    </label>
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="editUserData.privacyVisible" 
                        :value="false"
                        class="mr-2"
                      />
                      <span class="text-sm">私密</span>
                    </label>
                  </div>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">用户状态</label>
                  <select 
                    v-model="editUserData.status"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  >
                    <option value="active">正常</option>
                    <option value="suspended">已暂停</option>
                    <option value="banned">已封禁</option>
                  </select>
                </div>
                
                <div v-if="editUserData.id">
                  <label class="block text-sm font-medium text-gray-700 mb-2">注册时间</label>
                  <input 
                    v-model="editUserData.registerTime" 
                    type="datetime-local"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    readonly
                  />
                </div>
              </div>
            </div>
            
            <!-- 操作按钮 -->
            <div class="flex justify-between items-center mt-6 pt-4 border-t">
              <div class="flex space-x-2">
                <button 
                  v-if="editUserData.id" 
                  class="btn-secondary" 
                  @click="viewUserDetails"
                >
                  <i class="fa fa-eye mr-1"></i>查看详情
                </button>
              </div>
              <div class="flex space-x-3">
                <button class="btn-secondary" @click="showEdit = false">取消</button>
                <button class="btn-primary" @click="saveUser">保存</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'UserManager',
  data() {
    return {
      users: [],
      showEdit: false,
      editUserData: {},
      searchKeyword: '',
      page: 1,
      pageSize: 10,
      selectedIds: [],
      selectAll: false,
      stats: {
        totalUsers: 0,
        totalGrowthRate: 0,
        activeUsers: 0,
        activeGrowthRate: 0,
        newUsers: 0,
        newUserGrowthRate: 0,
        vipUsers: 0
      }
    }
  },
  computed: {
    filteredUsers() {
      if (!this.searchKeyword) return this.users
      const kw = this.searchKeyword.trim().toLowerCase()
      return this.users.filter(u =>
        (u.userName && u.userName.toLowerCase().includes(kw)) ||
        (u.email && u.email.toLowerCase().includes(kw))
      )
    },
    totalPages() {
      return Math.max(1, Math.ceil(this.filteredUsers.length / this.pageSize))
    },
    pagedUsers() {
      const start = (this.page - 1) * this.pageSize
      return this.filteredUsers.slice(start, start + this.pageSize)
    }
  },
  watch: {
    pageSize() { this.page = 1 },
    filteredUsers() { if(this.page>this.totalPages) this.page=this.totalPages; }
  },
  methods: {
    async fetchUsers() {
      try {
        const res = await axios.get('/api/management/user/selectAll')
        this.users = res.data
      } catch (e) {
        console.error('获取用户失败:', e)
        alert('获取用户失败')
      }
    },
    async loadStats() {
      try {
        const res = await axios.get('/api/management/user/stats')
        this.stats = res.data
      } catch (e) {
        console.error('获取统计信息失败:', e)
      }
    },
    addUser() {
      this.editUserData = {}
      this.showEdit = true
    },
    editUser(user) {
      this.editUserData = { ...user }
      this.showEdit = true
    },
    async saveUser() {
      try {
        if (this.editUserData.id) {
          // 更新用户
          const res = await axios.put('/api/management/user', this.editUserData)
          if (res.data.error) {
            alert(res.data.error)
            return
          }
          alert('用户更新成功')
        } else {
          // 创建用户
          const res = await axios.post('/api/management/user', this.editUserData)
          if (res.data.error) {
            alert(res.data.error)
            return
          }
          alert('用户创建成功')
        }
        this.showEdit = false
        this.fetchUsers()
      } catch (e) {
        console.error('保存失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
        alert('保存失败')
        }
      }
    },
    async deleteUser(id) {
      if (!confirm('确定要删除该用户吗？')) return
      try {
        const res = await axios.delete(`/api/management/user/${id}`)
        if (res.data.error) {
          alert(res.data.error)
          return
        }
        alert('用户删除成功')
        this.fetchUsers()
      } catch (e) {
        console.error('删除失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
        alert('删除失败')
        }
      }
    },
    searchUsers() {
      this.page = 1
    },
    resetSearch() {
      this.searchKeyword = ''
      this.page = 1
    },
    toggleSelectAll() {
      if (this.selectAll) {
        this.selectedIds = this.pagedUsers.map(u => u.id)
      } else {
        this.selectedIds = []
      }
    },
    async batchDelete() {
      if (this.selectedIds.length === 0) {
        alert('请先选择要删除的用户')
        return
      }
      if (!confirm('确定要批量删除选中用户吗？')) return
      try {
        const res = await axios.post('/api/management/user/batchDelete', this.selectedIds)
        if (res.data.error) {
          alert(res.data.error)
          return
        }
        
        const { successCount, failCount, failedIds } = res.data
        let message = `批量删除完成：成功删除 ${successCount} 个用户`
        if (failCount > 0) {
          message += `，失败 ${failCount} 个用户`
        }
        alert(message)
        
        this.selectedIds = []
        this.selectAll = false
        this.fetchUsers()
      } catch (e) {
        console.error('批量删除失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
        alert('批量删除失败')
        }
      }
    },
    exportUsers() {
      const header = 'ID,UID,用户名,性别,邮箱,等级,注册时间,更新时间,隐私设置,个人签名\n'
      const rows = this.filteredUsers.map(u =>
        [u.id, u.userUID, u.userName, u.gender, u.email, u.level, u.registerTime, u.updateTime || '-', u.privacyVisible ? '公开' : '私密', u.signature || '-'].join(',')
      ).join('\n')
      const csv = header + rows
      const blob = new Blob([csv], { type: 'text/csv' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = '用户列表.csv'
      a.click()
      URL.revokeObjectURL(url)
    },
    

    
    // 查看用户详情
    viewUserDetails() {
      const details = `
用户详情：
ID: ${this.editUserData.id}
UID: ${this.editUserData.userUID}
用户名: ${this.editUserData.userName}
邮箱: ${this.editUserData.email}
性别: ${this.editUserData.gender || '未设置'}
等级: ${this.editUserData.level}
注册时间: ${this.editUserData.registerTime}
更新时间: ${this.editUserData.updateTime || '未更新'}
隐私设置: ${this.editUserData.privacyVisible ? '公开' : '私密'}
个人签名: ${this.editUserData.signature || '未设置'}
用户状态: ${this.getStatusText(this.editUserData.status)}
      `.trim()
      
      alert(details)
    },
    
    // 获取状态文本
    getStatusText(status) {
      const statusMap = {
        'active': '正常',
        'suspended': '已暂停',
        'banned': '已封禁'
      }
      return statusMap[status] || '未知'
    },
    
    // 获取等级颜色类
    getLevelClass(level) {
      if (level >= 1 && level <= 3) {
        return 'bg-gray-100 text-gray-700' // 普通用户
      } else if (level >= 4 && level <= 6) {
        return 'bg-blue-100 text-blue-700' // 初级VIP
      } else if (level >= 7 && level <= 9) {
        return 'bg-purple-100 text-purple-700' // 高级VIP
      } else if (level >= 10) {
        return 'bg-yellow-100 text-yellow-700' // 超级VIP
      } else {
        return 'bg-red-100 text-red-700' // 异常等级
      }
    },
    
    // 表格中查看用户详情
    viewUserDetails(user) {
      const details = `
用户详情：
ID: ${user.id}
UID: ${user.userUID}
用户名: ${user.userName}
邮箱: ${user.email}
性别: ${user.gender || '未设置'}
等级: ${user.level}
注册时间: ${user.registerTime}
更新时间: ${user.updateTime || '未更新'}
隐私设置: ${user.privacyVisible ? '公开' : '私密'}
个人签名: ${user.signature || '未设置'}
用户状态: ${this.getStatusText(user.status)}
      `.trim()
      
      alert(details)
    },
    

  },
  mounted() {
    this.fetchUsers()
    this.loadStats()
  }
}
</script>

<style scoped>
/* 自定义样式 */
.card-shadow {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.hover-scale {
  transition: transform 0.3s ease;
}

.hover-scale:hover {
  transform: scale(1.02);
}

/* 按钮样式 */
.btn-primary {
  @apply bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors font-medium;
}

.btn-secondary {
  @apply bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors font-medium;
}

.btn-danger {
  @apply bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition-colors font-medium;
}

.btn-small {
  @apply px-3 py-1 rounded border border-gray-200 bg-white hover:bg-gray-50 transition-colors text-sm;
}

.btn-small:disabled {
  @apply opacity-50 cursor-not-allowed;
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

.text-info {
  color: var(--info);
}

.text-warning {
  color: var(--warning);
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

/* 响应式设计 */
@media (max-width: 768px) {
  .modal-container {
    margin: 1rem;
    padding: 20px;
  }
  
  .btn-primary, .btn-secondary, .btn-danger {
    @apply px-3 py-2 text-sm;
  }
}

/* 表格样式优化 */
.user-table th, .user-table td {
  padding-left: 12px;
  padding-right: 12px;
  vertical-align: middle;
  font-size: 14px;
}

/* 表格行悬停效果 */
tbody tr:hover {
  background-color: #f8fafc;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 操作按钮悬停效果 */
.action-btn {
  transition: all 0.2s ease;
}

.action-btn:hover {
  transform: scale(1.1);
}

/* 状态标签样式 */
.status-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 500;
  letter-spacing: 0.025em;
}

.header-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  margin-bottom: 2rem;
}
</style> 