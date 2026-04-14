<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950 flex transition-colors duration-300">
    <!-- Sidebar (Same as Dashboard) -->
    <aside class="w-64 bg-green-700 dark:bg-green-900 text-white flex flex-col">
      <div class="p-4">
        <img src="/img/Logo_GeoPonto_branco.png" alt="GeoPonto" class="h-32 mx-auto" />
      </div>
      <nav class="flex-grow mt-2">
        <router-link to="/dashboard" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
          <span class="mr-3">📊</span> Painel Principal
        </router-link>
        <router-link to="/dashboard/occurrences" class="flex items-center px-6 py-3 bg-green-800 dark:bg-green-950 border-l-4 border-white">
          <span class="mr-3">⚠️</span> Ocorrências
        </router-link>
        <div class="flex items-center px-6 py-3 opacity-50 cursor-not-allowed">
          <span class="mr-3">📈</span> Relatórios (Em breve)
        </div>
      </nav>
      <div class="p-6 border-t border-green-600 dark:border-green-800">
        <button @click="handleLogout" class="flex items-center text-green-100 hover:text-white transition-colors w-full">
          <span class="mr-3">🚪</span> Sair
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-grow flex flex-col">
      <header class="bg-white dark:bg-gray-900 shadow-sm h-16 flex items-center justify-between px-8 transition-colors">
        <h1 class="text-xl font-semibold text-gray-800 dark:text-white">Ocorrências</h1>
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
              {{ userName.charAt(0) }}
            </div>
          </div>
        </div>
      </header>

      <section class="p-8">
        <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md overflow-hidden transition-colors">
          <div class="p-6 border-b border-gray-100 dark:border-gray-800 flex justify-between items-center">
            <h2 class="text-lg font-bold text-gray-900 dark:text-white">Histórico de Alertas</h2>
            <div class="flex space-x-2">
              <span class="px-3 py-1 bg-yellow-100 dark:bg-yellow-900/40 text-yellow-800 dark:text-yellow-300 rounded-full text-xs font-semibold">Pendentes: 2</span>
              <span class="px-3 py-1 bg-green-100 dark:bg-green-900/40 text-green-800 dark:text-green-300 rounded-full text-xs font-semibold">Resolvidos: 15</span>
            </div>
          </div>
          
          <table class="w-full text-left">
            <thead class="bg-gray-50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-800">
              <tr>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Funcionário</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Data/Hora</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Tipo de Ocorrência</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-right">Ações</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
              <tr v-for="occ in sampleOccurrences" :key="occ.id" class="hover:bg-gray-50 dark:hover:bg-gray-800/30 transition-colors">
                <td class="px-6 py-4">
                  <div class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ occ.name }}</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ occ.role }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm text-gray-900 dark:text-gray-200">{{ occ.date }}</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ occ.time }}</div>
                </td>
                <td class="px-6 py-4">
                  <span :class="occ.typeClass" class="px-2 py-1 rounded text-xs font-medium dark:opacity-80">
                    {{ occ.type }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <span :class="occ.statusClass" class="flex items-center text-xs font-semibold">
                    <span class="h-2 w-2 rounded-full mr-2" :class="occ.statusDot"></span>
                    {{ occ.status }}
                  </span>
                </td>
                <td class="px-6 py-4 text-right">
                  <button class="text-green-600 dark:text-green-400 hover:text-green-800 dark:hover:text-green-300 text-sm font-medium transition-colors">Ver detalhes</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDarkMode } from '../composables/useDarkMode'
import { authService } from '../services/authService'

const router = useRouter()
const userName = ref(localStorage.getItem('userName') || 'Empregador')
const { isDarkMode, toggleDarkMode, initTheme } = useDarkMode()

onMounted(() => {
  initTheme()
  if (!localStorage.getItem('isLoggedIn')) {
    router.push('/')
    return
  }
})

const handleLogout = () => {
  authService.logout()
  router.push('/')
}

const sampleOccurrences = [
  {
    id: 1,
    name: 'João Silva',
    role: 'Desenvolvedor',
    date: '13/04/2026',
    time: '08:15',
    type: 'Marcação fora do perímetro',
    typeClass: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
    status: 'Pendente',
    statusClass: 'text-yellow-600 dark:text-yellow-400',
    statusDot: 'bg-yellow-500'
  },
  {
    id: 2,
    name: 'Maria Oliveira',
    role: 'Analista de RH',
    date: '12/04/2026',
    time: '18:30',
    type: 'Hora Extra não autorizada',
    typeClass: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300',
    status: 'Pendente',
    statusClass: 'text-yellow-600 dark:text-yellow-400',
    statusDot: 'bg-yellow-500'
  },
  {
    id: 3,
    name: 'Pedro Santos',
    role: 'Gerente',
    date: '11/04/2026',
    time: '09:05',
    type: 'Atraso injustificado',
    typeClass: 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300',
    status: 'Resolvido',
    statusClass: 'text-green-600 dark:text-green-400',
    statusDot: 'bg-green-500'
  }
]
</script>
