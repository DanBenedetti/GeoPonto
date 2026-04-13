<template>
  <div class="min-h-screen bg-gray-50 flex">
    <!-- Sidebar (Same as Dashboard) -->
    <aside class="w-64 bg-green-700 text-white flex flex-col">
      <div class="p-6">
        <img src="/img/Logo_GeoPonto.png" alt="GeoPonto" class="h-36 brightness-0 invert mx-auto" />
      </div>
      <nav class="flex-grow mt-6">
        <router-link to="/dashboard" class="flex items-center px-6 py-3 hover:bg-green-600 transition-colors">
          <span class="mr-3">📊</span> Painel Principal
        </router-link>
        <router-link to="/dashboard/occurrences" class="flex items-center px-6 py-3 bg-green-800 border-l-4 border-white">
          <span class="mr-3">⚠️</span> Ocorrências
        </router-link>
        <div class="flex items-center px-6 py-3 opacity-50 cursor-not-allowed">
          <span class="mr-3">📈</span> Relatórios (Em breve)
        </div>
      </nav>
      <div class="p-6 border-t border-green-600">
        <button @click="handleLogout" class="flex items-center text-green-100 hover:text-white transition-colors">
          <span class="mr-3">🚪</span> Sair
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-grow flex flex-col">
      <header class="bg-white shadow-sm h-16 flex items-center justify-between px-8">
        <h1 class="text-xl font-semibold text-gray-800">Ocorrências</h1>
        <div class="flex items-center space-x-4">
          <span class="text-gray-600 font-medium">{{ userName }}</span>
          <div class="h-10 w-10 bg-green-100 rounded-full flex items-center justify-center text-green-700 font-bold">
            {{ userName.charAt(0) }}
          </div>
        </div>
      </header>

      <section class="p-8">
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
          <div class="p-6 border-b border-gray-100 flex justify-between items-center">
            <h2 class="text-lg font-bold text-gray-900">Histórico de Alertas</h2>
            <div class="flex space-x-2">
              <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-semibold">Pendentes: 2</span>
              <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold">Resolvidos: 15</span>
            </div>
          </div>
          
          <table class="w-full text-left">
            <thead class="bg-gray-50 border-b border-gray-100">
              <tr>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Funcionário</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Data/Hora</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Tipo de Ocorrência</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Ações</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
              <tr v-for="occ in sampleOccurrences" :key="occ.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4">
                  <div class="text-sm font-medium text-gray-900">{{ occ.name }}</div>
                  <div class="text-xs text-gray-500">{{ occ.role }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm text-gray-900">{{ occ.date }}</div>
                  <div class="text-xs text-gray-500">{{ occ.time }}</div>
                </td>
                <td class="px-6 py-4">
                  <span :class="occ.typeClass" class="px-2 py-1 rounded text-xs font-medium">
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
                  <button class="text-green-600 hover:text-green-800 text-sm font-medium">Ver detalhes</button>
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const userName = ref(localStorage.getItem('userName') || 'Empregador')

const handleLogout = () => {
  localStorage.removeItem('isLoggedIn')
  localStorage.removeItem('userName')
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
    typeClass: 'bg-red-100 text-red-700',
    status: 'Pendente',
    statusClass: 'text-yellow-600',
    statusDot: 'bg-yellow-500'
  },
  {
    id: 2,
    name: 'Maria Oliveira',
    role: 'Analista de RH',
    date: '12/04/2026',
    time: '18:30',
    type: 'Hora Extra não autorizada',
    typeClass: 'bg-orange-100 text-orange-700',
    status: 'Pendente',
    statusClass: 'text-yellow-600',
    statusDot: 'bg-yellow-500'
  },
  {
    id: 3,
    name: 'Pedro Santos',
    role: 'Gerente',
    date: '11/04/2026',
    time: '09:05',
    type: 'Atraso injustificado',
    typeClass: 'bg-gray-100 text-gray-700',
    status: 'Resolvido',
    statusClass: 'text-green-600',
    statusDot: 'bg-green-500'
  }
]
</script>
