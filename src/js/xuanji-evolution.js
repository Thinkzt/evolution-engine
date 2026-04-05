/**
 * 璇玑史进化引擎 - 前端界面
 * XuanJi Evolution Engine - Web Interface
 */

const { createApp } = Vue;
const { createPinia } = Pinia;

const app = createApp({
  setup() {
    // 状态
    const engineStatus = ref('stopped');
    const version = ref('v0.1.0');
    const rollouts = ref([]);
    const metrics = ref({
      totalTokens: 0,
      improvedTokens: 0,
      lossReduction: 0,
      uptime: 0
    });
    
    // 方法
    const startEngine = () => {
      engineStatus.value = 'running';
      console.log('璇玑史进化引擎启动');
    };
    
    const stopEngine = () => {
      engineStatus.value = 'stopped';
      console.log('璇玑史进化引擎停止');
    };
    
    const triggerEvolution = async () => {
      console.log('触发进化...');
      // 调用后端API
    };
    
    return {
      engineStatus,
      version,
      rollouts,
      metrics,
      startEngine,
      stopEngine,
      triggerEvolution
    };
  },
  
  template: `
    <div class="xuanji-engine">
      <!-- 顶部状态栏 -->
      <header class="header">
        <h1>✈️ 璇玑史进化引擎</h1>
        <span class="version">{{ version }}</span>
      </header>
      
      <!-- 状态卡片 -->
      <div class="status-cards">
        <div class="card" :class="engineStatus">
          <span class="label">引擎状态</span>
          <span class="value">{{ engineStatus === 'running' ? '🟢 运行中' : '🔴 已停止' }}</span>
        </div>
        
        <div class="card">
          <span class="label">总Token</span>
          <span class="value">{{ metrics.totalTokens }}</span>
        </div>
        
        <div class="card">
          <span class="label">提升Token</span>
          <span class="value">+{{ metrics.improvedTokens }}</span>
        </div>
      </div>
      
      <!-- 控制面板 -->
      <div class="control-panel">
        <button @click="startEngine" :disabled="engineStatus === 'running'">
          启动引擎
        </button>
        <button @click="stopEngine" :disabled="engineStatus === 'stopped'">
          停止引擎
        </button>
        <button @click="triggerEvolution">
          触发进化
        </button>
      </div>
      
      <!-- 轨迹列表 -->
      <div class="rollout-list">
        <h2>Rollout轨迹</h2>
        <div v-if="rollouts.length === 0" class="empty">
          暂无轨迹数据
        </div>
        <div v-else v-for="r in rollouts" :key="r.id" class="rollout-item">
          {{ r.session_id }} - {{ r.feedback }}
        </div>
      </div>
    </div>
  `
});

app.use(createPinia());
app.mount('#app');
