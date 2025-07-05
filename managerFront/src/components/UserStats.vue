<template>
  <div>
    <h2>用户统计分析</h2>
    <div>总用户数：{{ totalUsers }}</div>
    <div>等级分布：</div>
    <ul>
      <li v-for="(count, level) in levelStats" :key="level">等级{{ level }}：{{ count }}人</li>
    </ul>
    <!-- 可扩展为图表展示 -->
  </div>
</template>

<script>
export default {
  name: 'UserStats',
  data() {
    return {
      totalUsers: 10,
      levelStats: {
        1: 5,
        2: 3,
        3: 2
      }
    }
  }
}
</script> 