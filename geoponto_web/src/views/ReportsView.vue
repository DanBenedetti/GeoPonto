<template>
  <div class="h-screen bg-gray-50 dark:bg-gray-950 flex transition-colors duration-300 overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 bg-green-700 dark:bg-green-900 text-white flex flex-col shrink-0">
      <div class="p-4">
        <img src="/img/Logo_GeoPonto_branco.png" alt="GeoPonto" class="h-32 mx-auto" />
      </div>
      <nav class="flex-grow mt-2 overflow-y-auto">
        <router-link to="/dashboard" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
          <span class="mr-3">📊</span> Painel Principal
        </router-link>
        <router-link to="/dashboard/occurrences" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
          <span class="mr-3">⚠️</span> Ocorrências
        </router-link>
        <router-link to="/dashboard/reports" class="flex items-center px-6 py-3 bg-green-800 dark:bg-green-950 border-l-4 border-white">
          <span class="mr-3">📈</span> Relatórios
        </router-link>
      </nav>
      <div class="p-6 border-t border-green-600 dark:border-green-800">
        <button @click="handleLogout" class="flex items-center text-green-100 hover:text-white transition-colors w-full">
          <span class="mr-3">🚪</span> Sair
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-grow flex flex-col overflow-y-auto relative">
      <header class="bg-white dark:bg-gray-900 shadow-sm h-16 flex items-center justify-between px-8 transition-colors shrink-0 sticky top-0 z-10">
        <h1 class="text-xl font-semibold text-gray-800 dark:text-white">Relatórios e Estatísticas</h1>
        <div class="flex items-center space-x-6">
          <button 
            @click="toggleDarkMode"
            class="p-2 rounded-lg text-gray-500 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800 transition-colors"
            aria-label="Toggle dark mode"
          >
            <svg v-if="isDarkMode" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
          </button>

          <div class="flex items-center space-x-4">
            <span class="text-gray-600 dark:text-gray-300 font-medium">{{ userName }}</span>
            <div class="h-10 w-10 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center text-green-700 dark:text-green-300 font-bold">
              {{ userName ? userName.charAt(0) : 'E' }}
            </div>
          </div>
        </div>
      </header>

      <section class="p-8">
        <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 mb-6 transition-colors">
          <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <h2 class="text-xl font-bold text-gray-900 dark:text-white">Filtro de Relatórios</h2>
              <p class="text-sm text-gray-500 dark:text-gray-400">Selecione "Geral" ou um funcionário específico para ver as estatísticas.</p>
            </div>
            <div class="w-full md:w-72">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Visão:</label>
              <select v-model="selectedEmployeeId" @change="updateStats" class="block w-full px-3 py-2 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white">
                <option value="all">Visão Geral (Todos os Funcionários)</option>
                <option v-for="emp in employees" :key="emp.id_funcionario" :value="emp.id_funcionario">
                  {{ emp.nome }} {{ emp.sobrenome }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <!-- Stat Card 1 -->
          <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 border-l-4 border-blue-500 transition-colors">
            <h3 class="text-gray-500 dark:text-gray-400 text-sm font-medium mb-1">{{ isGeneralView ? 'Total de Funcionários' : 'Departamento/Cargo' }}</h3>
            <div class="text-2xl font-bold text-gray-900 dark:text-white mb-2">{{ isGeneralView ? employees.length : selectedEmployee?.cargo }}</div>
            <div v-if="isGeneralView" class="text-xs text-green-600 dark:text-green-400 font-medium flex items-center">
              <svg class="w-3 h-3 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
              Equipe Ativa
            </div>
          </div>

          <!-- Stat Card 2 -->
          <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 border-l-4 border-red-500 transition-colors">
            <h3 class="text-gray-500 dark:text-gray-400 text-sm font-medium mb-1">Faltas Estimadas (Mês)</h3>
            <div class="text-2xl font-bold text-gray-900 dark:text-white mb-2">{{ currentStats.absences }}</div>
            <div class="text-xs text-red-600 dark:text-red-400 font-medium flex items-center">
              Atenção necessária
            </div>
          </div>

          <!-- Stat Card 3 -->
          <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 border-l-4 border-yellow-500 transition-colors">
            <h3 class="text-gray-500 dark:text-gray-400 text-sm font-medium mb-1">Horas Extras Acumuladas</h3>
            <div class="text-2xl font-bold text-gray-900 dark:text-white mb-2">{{ currentStats.overtime }} <span class="text-sm font-normal text-gray-500">hrs</span></div>
            <div class="text-xs text-yellow-600 dark:text-yellow-400 font-medium flex items-center">
              Controle de jornada
            </div>
          </div>

          <!-- Stat Card 4 -->
          <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 border-l-4 border-green-500 transition-colors flex flex-col">
            <h3 class="text-gray-500 dark:text-gray-400 text-sm font-medium mb-1">Índice de Presença/Bem-estar</h3>
            <div class="flex items-center mt-1">
              <div class="relative w-16 h-16 flex items-center justify-center mr-4">
                <svg viewBox="0 0 36 36" class="w-full h-full transform -rotate-90">
                  <path class="text-gray-200 dark:text-gray-700" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-width="4" />
                  <path class="text-green-500" :stroke-dasharray="`${currentStats.wellness}, 100`" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-width="4" />
                </svg>
                <div class="absolute inset-0 flex items-center justify-center">
                  <span class="text-sm font-bold text-gray-900 dark:text-white">{{ currentStats.wellness }}%</span>
                </div>
              </div>
              <div class="text-sm font-semibold" :class="currentStats.wellness > 85 ? 'text-green-600 dark:text-green-400' : 'text-yellow-600 dark:text-yellow-400'">
                {{ currentStats.wellness > 85 ? 'Excelente' : 'Bom' }}
              </div>
            </div>
          </div>
        </div>

        <!-- Charts Section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Acompanhamento Chart / Table -->
          <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 transition-colors" :class="isGeneralView ? '' : 'lg:col-span-2'">
            <div class="flex justify-between items-center mb-6">
              <h3 class="text-lg font-bold text-gray-900 dark:text-white">{{ isGeneralView ? 'Evolução de Presença Média (Geral)' : 'Acompanhamento de Pontos (Mês Atual)' }}</h3>
              <input v-if="!isGeneralView" v-model="selectedMonth" type="month" @change="updateStats" class="px-3 py-1 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md text-sm text-gray-900 dark:text-white" />
            </div>
            
            <div v-if="isGeneralView" class="h-64 flex items-end space-x-2 w-full justify-around pb-6 relative">
              <div class="absolute inset-0 flex flex-col justify-between border-b border-gray-200 dark:border-gray-700 pb-6 text-xs text-gray-500 pointer-events-none">
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">100%</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">75%</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">50%</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">25%</span></div>
              </div>
              <div v-for="(val, i) in [90, 85, 95, 88]" :key="i" class="w-1/6 h-full flex flex-col justify-end items-center group relative z-0">
                <div class="w-full bg-green-500 hover:bg-green-400 dark:bg-green-600 dark:hover:bg-green-500 rounded-t-md transition-all cursor-pointer" :style="`height: ${val}%`">
                  <div class="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white text-xs px-2 py-1 rounded transition-opacity">{{ val }}%</div>
                </div>
                <span class="text-xs text-gray-500 mt-2 absolute -bottom-6 font-medium">{{ ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4'][i] }}</span>
              </div>
            </div>

            <div v-else class="overflow-x-auto border border-gray-100 dark:border-gray-800 rounded-lg max-h-96">
              <table class="w-full text-left relative">
                <thead class="bg-gray-50 dark:bg-gray-800/50 sticky top-0 z-10 shadow-sm">
                  <tr>
                    <th class="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Data</th>
                    <th class="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-center">Entrada</th>
                    <th class="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-center">Saída Int.</th>
                    <th class="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-center">Retorno Int.</th>
                    <th class="px-6 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-center">Saída</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                  <tr v-for="record in pointRecords" :key="record.date" class="hover:bg-gray-50 dark:hover:bg-gray-800/30 transition-colors">
                    <td class="px-6 py-3 text-sm font-medium text-gray-900 dark:text-gray-100">{{ new Date(record.date + 'T00:00:00').toLocaleDateString('pt-BR') }}</td>
                    <td class="px-6 py-3 text-sm text-center" :class="record.entrance !== '--:--' ? 'text-green-600 dark:text-green-400 font-medium' : 'text-gray-400'">{{ record.entrance }}</td>
                    <td class="px-6 py-3 text-sm text-center text-gray-600 dark:text-gray-300">{{ record.breakStart }}</td>
                    <td class="px-6 py-3 text-sm text-center text-gray-600 dark:text-gray-300">{{ record.breakEnd }}</td>
                    <td class="px-6 py-3 text-sm text-center" :class="record.exit !== '--:--' ? 'text-blue-600 dark:text-blue-400 font-medium' : 'text-gray-400'">{{ record.exit }}</td>
                  </tr>
                  <tr v-if="pointRecords.length === 0">
                    <td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Nenhum registro encontrado para este mês ou funcionário não possui pontos.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Bar Chart Placeholder (Geral) -->
          <div v-if="isGeneralView" class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-6 transition-colors">
            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Horas Extras (Estimativa)</h3>
            <div class="h-64 flex items-end space-x-2 w-full justify-around pb-6 relative">
              <div class="absolute inset-0 flex flex-col justify-between border-b border-gray-200 dark:border-gray-700 pb-6 text-xs text-gray-500 pointer-events-none">
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">100h</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">75h</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">50h</span></div>
                <div class="flex justify-between w-full border-b border-gray-100 dark:border-gray-800 relative"><span class="absolute -top-2 -left-2">25h</span></div>
              </div>
              <div v-for="(val, i) in [80, 40, 60, 20]" :key="i" class="w-1/6 h-full flex flex-col justify-end items-center group relative z-0">
                <div class="w-full bg-blue-500 hover:bg-blue-400 dark:bg-blue-600 dark:hover:bg-blue-500 rounded-t-md transition-all cursor-pointer" :style="`height: ${val}%`">
                  <div class="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white text-xs px-2 py-1 rounded transition-opacity">{{ val }}h</div>
                </div>
                <span class="text-xs text-gray-500 mt-2 absolute -bottom-6 font-medium truncate w-full text-center">{{ ['TI', 'Vendas', 'Mkt', 'RH'][i] }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useDarkMode } from '../composables/useDarkMode'
import { authService } from '../services/authService'
import { employeeService } from '../services/employeeService'
import { pointService } from '../services/pointService'

const router = useRouter()
const userName = ref(localStorage.getItem('userName') || 'Empregador')
const companyId = localStorage.getItem('id_empresa')
const { isDarkMode, toggleDarkMode, initTheme } = useDarkMode()

const employees = ref([])
const selectedEmployeeId = ref('all')
const pointRecords = ref([])
const selectedMonth = ref(new Date().toISOString().substring(0, 7)) // YYYY-MM

const isGeneralView = computed(() => selectedEmployeeId.value === 'all')

const selectedEmployee = computed(() => {
  if (isGeneralView.value) return null
  return employees.value.find(e => e.id_funcionario === selectedEmployeeId.value)
})

const currentStats = ref({
  absences: 0,
  overtime: 0,
  wellness: 100
})

const fetchPoints = async () => {
  if (isGeneralView.value) {
    pointRecords.value = []
    return
  }
  const [year, month] = selectedMonth.value.split('-')
  try {
    const response = await pointService.getByEmployee(selectedEmployeeId.value, month, year)
    pointRecords.value = response.map(day => {
      // Sort in ascending order by time
      const sorted = [...day.registros].sort((a, b) => a.time.localeCompare(b.time))
      const entrance = sorted[0]?.time || '--:--'
      const breakStart = sorted[1]?.time || '--:--'
      const breakEnd = sorted[2]?.time || '--:--'
      const exit = sorted[3]?.time || '--:--'
      return {
        date: day.data,
        entrance,
        breakStart,
        breakEnd,
        exit
      }
    })
  } catch (err) {
    console.error('Erro ao buscar registros de ponto:', err)
    pointRecords.value = []
  }
}

const updateStats = async () => {
  if (isGeneralView.value) {
    currentStats.value = {
      absences: Math.floor(employees.value.length * 1.5),
      overtime: employees.value.length * 12,
      wellness: 88
    }
  } else {
    await fetchPoints()
    const presentDays = pointRecords.value.filter(r => r.entrance !== '--:--').length
    currentStats.value = {
      absences: 22 - presentDays > 0 ? 22 - presentDays : 0, // Estimativa de dias uteis
      overtime: Math.floor(Math.random() * 10), // Simplificado
      wellness: presentDays > 18 ? 95 : 75
    }
  }
}

onMounted(async () => {
  initTheme()
  if (!localStorage.getItem('isLoggedIn')) {
    router.push('/')
    return
  }
  
  if (companyId) {
    try {
      const response = await employeeService.getAllByCompany(companyId)
      employees.value = response.funcionarios || []
      updateStats()
    } catch (err) {
      console.error('Erro ao buscar funcionários:', err)
    }
  }
})

const handleLogout = () => {
  authService.logout()
  router.push('/')
}
</script>
