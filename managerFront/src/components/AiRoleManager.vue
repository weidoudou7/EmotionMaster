<template>
  <div class="ai-role-manager bg-gray-50 min-h-screen">
    <div class="header-container">
      <div class="page-header">
        <h1 class="text-3xl font-bold text-gray-800">AI角色管理</h1>
        <p class="text-gray-600 mt-2">管理与维护AI角色信息</p>
      </div>
    </div>
    <!-- 主内容区 -->
    <main class="container mx-auto px-4 pb-12">
      <!-- 数据概览卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-white rounded-xl p-8 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-base font-medium">总角色数</p>
              <h3 class="text-4xl font-bold mt-2">{{ stats.totalCount }}</h3>
              <p class="text-secondary text-sm mt-3 flex items-center">
                <i class="fa fa-robot mr-1"></i> <span class="text-gray-500 ml-1">全部</span>
              </p>
            </div>
            <div class="bg-primary/10 p-4 rounded-lg">
              <i class="fa fa-users text-primary text-2xl"></i>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-xl p-8 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-base font-medium">系统角色</p>
              <h3 class="text-4xl font-bold mt-2">{{ stats.systemCount }}</h3>
              <p class="text-secondary text-sm mt-3 flex items-center">
                <i class="fa fa-shield mr-1"></i> 预设角色
              </p>
            </div>
            <div class="bg-warning/10 p-4 rounded-lg">
              <i class="fa fa-cog text-warning text-2xl"></i>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-xl p-8 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-base font-medium">本周新增</p>
              <h3 class="text-4xl font-bold mt-2 text-green-500">{{ stats.newRolesThisWeek }}</h3>
            </div>
            <div class="bg-info/10 p-4 rounded-lg flex items-center justify-center">
              <i class="fa fa-plus text-info text-2xl"></i>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-xl p-8 card-shadow hover-scale">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-500 text-base font-medium">总浏览量</p>
              <h3 class="text-4xl font-bold mt-2">{{ stats.totalViewCount }}</h3>
              <p class="text-secondary text-sm mt-3 flex items-center">
                <i class="fa fa-eye mr-1"></i> 平均浏览
              </p>
            </div>
            <div class="bg-danger/10 p-4 rounded-lg">
              <i class="fa fa-eye text-danger text-2xl"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- AI角色管理主区域 -->
      <div class="bg-white rounded-xl p-6 card-shadow mb-8">
        <!-- 工具栏 -->
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <h2 class="text-lg font-bold">AI角色列表</h2>
          <div class="flex flex-col sm:flex-row gap-3 w-full md:w-auto">
            <div class="relative flex-1 sm:flex-none">
              <input 
                v-model="searchKeyword" 
                placeholder="搜索角色名/作者" 
                class="pl-10 pr-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary w-full sm:w-64"
              />
              <i class="fa fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
            </div>
            <div class="flex gap-2">
              <button class="btn-primary" @click="searchRoles">
                <i class="fa fa-search mr-1"></i>搜索
              </button>
              <button class="btn-secondary" @click="resetSearch">
                <i class="fa fa-refresh mr-1"></i>重置
              </button>
              <button class="btn-secondary" @click="exportRoles">
                <i class="fa fa-download mr-1"></i>导出
              </button>
              <button class="btn-danger" @click="batchDelete">
                <i class="fa fa-trash mr-1"></i>批量删除
              </button>
              <button class="btn-primary" @click="addRole">
                <i class="fa fa-plus mr-1"></i>新增角色
              </button>
            </div>
          </div>
        </div>

        <!-- 角色表格 -->
        <div class="overflow-x-auto rounded-lg border border-gray-200 bg-white shadow-sm">
          <table class="w-full">
            <thead>
              <tr class="text-left text-gray-600 border-b-2 border-gray-200 bg-gray-50">
                <th class="py-4 px-3 font-semibold text-sm">
                  <input type="checkbox" v-model="selectAll" @change="toggleSelectAll" class="rounded w-4 h-4" />
                </th>
                <th class="py-4 px-3 font-semibold text-sm">ID</th>
                <th class="py-4 px-3 font-semibold text-sm">角色信息</th>
                <th class="py-4 px-3 font-semibold text-sm">作者</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[100px]">类型</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[80px]">浏览量</th>
                <th class="py-4 px-3 font-semibold text-sm min-w-[120px]">创建时间</th>
                <th class="py-4 px-3 font-semibold text-sm">模板</th>
                <th class="py-4 px-3 font-semibold text-sm">操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="role in pagedRoles" :key="role.id" class="border-b hover:bg-gray-50 transition-colors align-middle" style="height:70px;">
                <td class="py-4 px-3">
                  <input type="checkbox" v-model="selectedIds" :value="role.id" class="rounded w-4 h-4" />
                </td>
                <td class="py-4 px-3 text-sm text-gray-500 font-mono">{{ role.id }}</td>
                <td class="py-4 px-3 min-w-[200px]">
                  <div class="flex items-center space-x-3">
                    <img :src="role.avatarUrl || '/default-avatar.png'" alt="头像" class="w-10 h-10 rounded-full object-cover border-2 border-gray-200 shadow-sm" />
                    <div class="flex flex-col">
                      <span class="font-semibold text-gray-900 truncate" :title="role.roleName">{{ role.roleName }}</span>
                      <span class="text-xs text-gray-400 max-w-[150px] truncate" :title="role.roleDescription">{{ role.roleDescription || '暂无描述' }}</span>
                    </div>
                  </div>
                </td>
                <td class="py-4 px-3 text-sm text-gray-600 truncate max-w-[120px]" :title="role.roleAuthor">{{ role.roleAuthor }}</td>
                <td class="py-4 px-3 min-w-[100px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block"
                    :class="getRoleTypeClass(role.roleType)">
                    {{ getRoleTypeText(role.roleType) }}
                  </span>
                </td>
                <td class="py-4 px-3 min-w-[80px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block"
                    :class="getViewCountClass(role.viewCount)">
                    {{ role.viewCount }}
                  </span>
                </td>
                <td class="py-4 px-3 text-sm text-gray-600 whitespace-nowrap min-w-[120px]" :title="role.createdAt">{{ formatDate(role.createdAt) }}</td>
                <td class="py-4 px-3 min-w-[80px]">
                  <span class="px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap inline-block" :class="role.isTemplate ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'">
                    {{ role.isTemplate ? '是' : '否' }}
                  </span>
                </td>
                <td class="py-4 px-3">
                  <div class="flex space-x-2">
                    <button class="text-primary hover:text-primary/80 transition-colors p-2 rounded-lg hover:bg-primary/10" @click="editRole(role)" title="编辑角色">
                      <i class="fa fa-edit text-base"></i>
                    </button>
                    <button class="text-info hover:text-info/80 transition-colors p-2 rounded-lg hover:bg-info/10" @click="viewRoleDetails(role)" title="查看详情">
                      <i class="fa fa-eye text-base"></i>
                    </button>
                    <button class="text-danger hover:text-danger/80 transition-colors p-2 rounded-lg hover:bg-danger/10" @click="deleteRole(role.id)" title="删除角色">
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
          <div>显示 {{ (page - 1) * pageSize + 1 }} 至 {{ Math.min(page * pageSize, filteredRoles.length) }} 条，共 {{ filteredRoles.length }} 条记录</div>
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

    <!-- 编辑/新增角色弹窗 -->
    <transition name="modal">
      <div v-if="showEdit" class="modal-mask">
        <div class="modal-wrapper">
          <div class="modal-container">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-bold">{{ editRoleData.id ? '编辑角色' : '新增角色' }}</h3>
              <button @click="showEdit = false" class="text-gray-400 hover:text-gray-600">
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
                    v-model="editRoleData.roleName" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入角色名称"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色作者 <span class="text-red-500">*</span></label>
                  <input 
                    v-model="editRoleData.roleAuthor" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                    placeholder="请输入角色作者"
                    required
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">角色类型</label>
                  <select 
                    v-model="editRoleData.roleType"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
                  >
                    <option value="dongman">动漫</option>
                    <option value="keai">可爱</option>
                    <option value="kehuan">科幻</option>
                    <option value="xieshi">写实</option>
                  </select>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">头像URL</label>
                  <input 
                    v-model="editRoleData.avatarUrl" 
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
                    v-model="editRoleData.roleDescription" 
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
                        v-model="editRoleData.isTemplate" 
                        :value="true"
                        class="mr-2"
                      />
                      <span class="text-sm">是</span>
                    </label>
                    <label class="flex items-center">
                      <input 
                        type="radio" 
                        v-model="editRoleData.isTemplate" 
                        :value="false"
                        class="mr-2"
                      />
                      <span class="text-sm">否</span>
                    </label>
                  </div>
                </div>
                
                <div v-if="editRoleData.id">
                  <label class="block text-sm font-medium text-gray-700 mb-2">创建时间</label>
                  <input 
                    v-model="editRoleData.createdAt" 
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
                  v-if="editRoleData.id" 
                  class="btn-secondary" 
                  @click="viewRoleDetails(editRoleData)"
                >
                  <i class="fa fa-eye mr-1"></i>查看详情
                </button>
              </div>
              <div class="flex space-x-3">
                <button class="btn-secondary" @click="showEdit = false">取消</button>
                <button class="btn-primary" @click="saveRole">保存</button>
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
  name: 'AiRoleManager',
  data() {
    return {
      roles: [],
      showEdit: false,
      editRoleData: {},
      searchKeyword: '',
      page: 1,
      pageSize: 10,
      selectedIds: [],
      selectAll: false,
      stats: {
        totalCount: 0,
        systemCount: 0,
        customCount: 0,
        newRolesThisWeek: 0,
        templateCount: 0,
        totalViewCount: 0
      }
    }
  },
  computed: {
    filteredRoles() {
      if (!this.searchKeyword) return this.roles
      const kw = this.searchKeyword.trim().toLowerCase()
      return this.roles.filter(r =>
        (r.roleName && r.roleName.toLowerCase().includes(kw)) ||
        (r.roleAuthor && r.roleAuthor.toLowerCase().includes(kw))
      )
    },
    totalPages() {
      return Math.max(1, Math.ceil(this.filteredRoles.length / this.pageSize))
    },
    pagedRoles() {
      const start = (this.page - 1) * this.pageSize
      return this.filteredRoles.slice(start, start + this.pageSize)
    },
    systemRolesCount() {
      return this.stats.systemCount
    },
    newRolesThisWeek() {
      return this.stats.newRolesThisWeek
    },
    totalViewCount() {
      return this.stats.totalViewCount
    }
  },
  watch: {
    pageSize() { this.page = 1 },
    filteredRoles() { if(this.page>this.totalPages) this.page=this.totalPages; }
  },
  methods: {
    async fetchRoles() {
      try {
        const res = await axios.get('/api/management/role/selectAll')
        this.roles = res.data || []
      } catch (e) {
        console.error('获取角色失败:', e)
        // 使用模拟数据
        this.roles = [
          {id: 1, roleName: '智能助理', roleAuthor: '系统', roleType: 'xieshi', viewCount: 100, createdAt: '2024-01-01', roleDescription: '智能对话助手', avatarUrl: '', isTemplate: true, userId: null},
          {id: 2, roleName: '社区小助手', roleAuthor: '张三', roleType: 'xieshi', viewCount: 50, createdAt: '2024-02-01', roleDescription: '社区管理助手', avatarUrl: '', isTemplate: false, userId: 1},
          {id: 3, roleName: '学习导师', roleAuthor: '李四', roleType: 'xieshi', viewCount: 80, createdAt: '2024-03-01', roleDescription: '专业学习指导', avatarUrl: '', isTemplate: true, userId: 2}
        ]
      }
    },
    async fetchStats() {
      try {
        const res = await axios.get('/api/management/role/stats')
        if(res.data && res.data.success && res.data.data) {
          this.stats = res.data.data
        }
      } catch (e) {
        console.error('获取统计信息失败:', e)
      }
    },
    addRole() {
      this.editRoleData = {
        roleType: 'custom',
        isTemplate: false,
        viewCount: 0
      }
      this.showEdit = true
    },
    editRole(role) {
      this.editRoleData = { ...role }
      this.showEdit = true
    },
    async saveRole() {
      try {
        if (this.editRoleData.id) {
          // 更新角色
          const res = await axios.put('/api/management/role', this.editRoleData)
          if (!res.data.success) {
            alert(res.data.error || '更新失败')
            return
          }
          alert('角色更新成功')
        } else {
          // 创建角色
          const res = await axios.post('/api/management/role', this.editRoleData)
          if (!res.data.success) {
            alert(res.data.error || '创建失败')
            return
          }
          alert('角色创建成功')
        }
        this.showEdit = false
        this.fetchRoles()
      } catch (e) {
        console.error('保存失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
          alert('保存失败')
        }
      }
    },
    async deleteRole(id) {
      if (!confirm('确定要删除该角色吗？')) return
      try {
        const res = await axios.delete(`/api/management/role/${id}`)
        if (!res.data.success) {
          alert(res.data.error || '删除失败')
          return
        }
        alert('角色删除成功')
        this.fetchRoles()
      } catch (e) {
        console.error('删除失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
          alert('删除失败')
        }
      }
    },
    async searchRoles() {
      if (!this.searchKeyword.trim()) {
        this.fetchRoles()
        return
      }
      
      try {
        const res = await axios.get(`/api/management/role/search?keyword=${encodeURIComponent(this.searchKeyword.trim())}`)
        if (res.data.success) {
          this.roles = res.data.data || []
        } else {
          alert(res.data.error || '搜索失败')
        }
      } catch (e) {
        console.error('搜索失败:', e)
        alert('搜索失败')
      }
      this.page = 1
    },
    resetSearch() {
      this.searchKeyword = ''
      this.page = 1
    },
    toggleSelectAll() {
      if (this.selectAll) {
        this.selectedIds = this.pagedRoles.map(r => r.id)
      } else {
        this.selectedIds = []
      }
    },
    async batchDelete() {
      if (this.selectedIds.length === 0) {
        alert('请先选择要删除的角色')
        return
      }
      if (!confirm('确定要批量删除选中角色吗？')) return
      try {
        const res = await axios.post('/api/management/role/batchDelete', this.selectedIds)
        if (!res.data.success) {
          alert(res.data.error || '批量删除失败')
          return
        }
        
        const { successCount, failCount, failedIds } = res.data
        let message = `批量删除完成：成功删除 ${successCount} 个角色`
        if (failCount > 0) {
          message += `，失败 ${failCount} 个角色`
        }
        alert(message)
        
        this.selectedIds = []
        this.selectAll = false
        this.fetchRoles()
      } catch (e) {
        console.error('批量删除失败:', e)
        if (e.response && e.response.data && e.response.data.error) {
          alert(e.response.data.error)
        } else {
          alert('批量删除失败')
        }
      }
    },
    exportRoles() {
      const header = 'ID,角色名,作者,类型,浏览量,创建时间,描述,模板\n'
      const rows = this.filteredRoles.map(r =>
        [r.id, r.roleName, r.roleAuthor, this.getRoleTypeText(r.roleType), r.viewCount, r.createdAt, r.roleDescription || '', r.isTemplate ? '是' : '否'].join(',')
      ).join('\n')
      const csv = header + rows
      const blob = new Blob([csv], { type: 'text/csv' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'AI角色列表.csv'
      a.click()
      URL.revokeObjectURL(url)
    },
    
    // 获取角色类型文本
    getRoleTypeText(type) {
      const typeMap = {
        'dongman': '动漫',
        'keai': '可爱',
        'kehuan': '科幻',
        'xieshi':'写实'
      }
      return typeMap[type] || type
    },
    
    // 获取角色类型颜色类
    getRoleTypeClass(type) {
      const classMap = {
        '动漫': 'bg-blue-100 text-blue-700',
        '可爱': 'bg-green-100 text-green-700',
        '科幻': 'bg-purple-100 text-purple-700',
        '写实':'bg-yellow-100 text-yellow-700'
      }
      return classMap[type] || 'bg-gray-100 text-gray-600'
    },
    
    // 获取浏览量颜色类
    getViewCountClass(count) {
      if (count >= 1000) {
        return 'bg-red-100 text-red-700'
      } else if (count >= 500) {
        return 'bg-yellow-100 text-yellow-700'
      } else if (count >= 100) {
        return 'bg-blue-100 text-blue-700'
      } else {
        return 'bg-gray-100 text-gray-600'
      }
    },
    
    // 格式化日期
    formatDate(dateStr) {
      if (!dateStr) return '-'
      return new Date(dateStr).toLocaleDateString('zh-CN')
    },
    
    // 查看角色详情
    viewRoleDetails(role) {
      const details = `
角色详情：
ID: ${role.id}
角色名: ${role.roleName}
作者: ${role.roleAuthor}
类型: ${this.getRoleTypeText(role.roleType)}
浏览量: ${role.viewCount}
创建时间: ${role.createdAt}
描述: ${role.roleDescription || '暂无描述'}
模板: ${role.isTemplate ? '是' : '否'}
用户ID: ${role.userId || '系统'}
      `.trim()
      
      alert(details)
    }
  },
  mounted() {
    this.fetchRoles()
    this.fetchStats()
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