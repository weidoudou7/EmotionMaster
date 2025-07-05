# 心屿管理系统前端

这是一个基于 Vue 3 + ECharts + Tailwind CSS 的现代化后台管理系统前端，支持用户管理、AI角色管理、数据统计大屏等功能，界面美观、交互流畅、响应式适配。

---

## 主要特性

- 🎨 **现代化设计**：采用 Tailwind CSS + Font Awesome，风格统一，支持暗色/亮色切换
- 📱 **响应式布局**：适配桌面端和移动端
- 🔐 **登录认证**：主流风格登录页，默认账号 manager / 123456，支持登出
- 👤 **用户管理**：增删改查、批量操作、导出、搜索、分页、详情弹窗
- 🤖 **AI角色管理**：角色增删改查、类型/作者/浏览量/模板等多维度管理
- 📊 **数据统计大屏**：
  - 统计卡片（总用户、AI角色、对话数、活跃用户等）
  - 用户增长趋势（近7天）
  - AI角色类型分布
  - AI角色浏览量分布（区间统计）
  - 对话数TOP7 AI角色排行
  - 图表支持柱状图/折线图/饼图切换，渐变色、动画、响应式
- 🗂️ **统一页面标题区**：三大模块风格一致，内容对齐
- 🧩 **代码结构清晰**：组件化开发，易于维护和扩展

---

## 技术栈

- [Vue 3](https://vuejs.org/)
- [ECharts 5](https://echarts.apache.org/)
- [Tailwind CSS](https://tailwindcss.com/) (CDN)
- [Font Awesome](https://fontawesome.com/) (CDN)
- [Axios](https://axios-http.com/)
- [Vite](https://vitejs.dev/)

---

## 快速开始

1. 安装依赖
   ```bash
   npm install
   ```

2. 启动开发服务器
   ```bash
   npm run dev
   ```

3. 构建生产版本
   ```bash
   npm run build
   ```

---

## 登录说明

- 默认账号：`manager`
- 默认密码：`123456`
- 登录状态保存在 localStorage，支持登出
- 未登录时强制显示登录页，登录后进入主界面

---

## 主要模块

### 1. 用户管理

- 用户信息展示（头像、用户名、邮箱、等级、注册/更新时间、隐私、签名等）
- 支持新增、编辑、删除、批量删除、导出、搜索、分页
- 详情弹窗，状态标签、等级颜色区分

### 2. AI角色管理

- 角色信息（名称、作者、类型、浏览量、模板、描述、头像等）
- 支持增删改查、批量删除、导出、搜索、分页
- 角色类型/浏览量多彩标签，详情弹窗

### 3. 数据统计大屏

- 统计卡片：总用户、AI角色、对话数、活跃用户等
- 用户增长趋势（近7天，柱状/折线/饼图切换）
- AI角色类型分布（动态统计所有类型）
- AI角色浏览量分布（区间统计，支持多种图表）
- 对话数TOP7 AI角色排行（支持多种图表）
- 图表均为响应式，切换类型无延迟，渐变色美观

---

## 依赖

详见 `package.json`，主要依赖如下：

```json
{
  "vue": "^3.x",
  "axios": "^1.x",
  "echarts": "^5.x",
  "vite": "^7.x",
  "@vitejs/plugin-vue": "^6.x"
}
```
CDN: Tailwind CSS、Font Awesome

---

## 目录结构

```
managerFront/
  ├── src/
  │   ├── components/
  │   │   ├── UserManager.vue
  │   │   ├── AiRoleManager.vue
  │   │   └── StatisticsManager.vue
  │   ├── App.vue
  │   └── main.js
  ├── index.html
  ├── package.json
  └── README.md
```

---

## 浏览器兼容性

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

---

## 其他说明

- 后端需配合提供 RESTful API，接口路径见各组件 axios 调用
- 如需自定义LOGO、主题色、功能扩展，请参考组件源码
- 欢迎二次开发和团队协作

---

如有问题请联系开发者或提交 issue。
