<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950 flex transition-colors duration-300">
    <!-- Sidebar -->
    <aside class="w-64 bg-green-700 dark:bg-green-900 text-white flex flex-col">
      <div class="p-4">
        <img src="/img/Logo_GeoPonto_branco.png" alt="GeoPonto" class="h-32 mx-auto" />
      </div>
      <nav class="flex-grow mt-2">
        <router-link to="/dashboard" class="flex items-center px-6 py-3 bg-green-800 dark:bg-green-950 border-l-4 border-white">
          <span class="mr-3">📊</span> Painel Principal
        </router-link>
        <router-link to="/dashboard/occurrences" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
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
        <h1 class="text-xl font-semibold text-gray-800 dark:text-white">Perfil do Empregador</h1>
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
        <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-8">
          <div class="flex justify-between items-center mb-8">
            <div>
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Gerenciamento de Funcionários</h2>
              <p class="text-gray-500 dark:text-gray-400 mt-1">Cadastre e gerencie a jornada dos seus colaboradores.</p>
            </div>
            <button @click="showEmployeeModal = true" class="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-sm">
              + Cadastrar Novo Funcionário
            </button>
          </div>

          <!-- Empty State / List placeholder -->
          <div class="border-2 border-dashed border-gray-200 dark:border-gray-700 rounded-lg py-12 text-center">
            <p class="text-gray-400 dark:text-gray-500">Nenhum funcionário cadastrado ainda.</p>
          </div>
        </div>
      </section>
    </main>

    <!-- Modal Cadastro Funcionário -->
    <div v-if="showEmployeeModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 overflow-y-auto">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl w-full max-w-4xl p-8 my-8">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-xl font-bold text-gray-900 dark:text-white">Cadastrar Novo Funcionário</h3>
          <button @click="showEmployeeModal = false" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 text-2xl">&times;</button>
        </div>
        <form @submit.prevent="handleRegisterEmployee" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Nome</label>
              <input v-model="employeeForm.name" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Sobrenome</label>
              <input v-model="employeeForm.surname" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">CPF</label>
              <input v-model="employeeForm.cpf" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Rua</label>
              <input v-model="employeeForm.street" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Número</label>
              <input v-model="employeeForm.number" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Bairro</label>
              <input v-model="employeeForm.neighborhood" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Cidade</label>
              <input v-model="employeeForm.city" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">CEP</label>
              <input v-model="employeeForm.cep" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">E-mail</label>
              <input v-model="employeeForm.email" type="email" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Telefone</label>
              <input v-model="employeeForm.phone" type="text" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Cargo</label>
              <input v-model="employeeForm.role" type="text" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Data de Admissão</label>
              <input v-model="employeeForm.admissionDate" type="date" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Senha</label>
              <input v-model="employeeForm.password" type="password" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Confirmar Senha</label>
              <input v-model="employeeForm.confirmPassword" type="password" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
          </div>
          <div class="pt-6 flex space-x-3">
            <button type="button" @click="showEmployeeModal = false" class="flex-1 px-4 py-2 border border-gray-300 rounded-md text-gray-700 font-medium hover:bg-gray-50">
              Cancelar
            </button>
            <button type="submit" class="flex-1 px-4 py-2 bg-green-600 text-white rounded-md font-medium hover:bg-green-700">
              Cadastrar funcionário
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDarkMode } from '../composables/useDarkMode'

const router = useRouter()
const userName = ref(localStorage.getItem('userName') || 'Empregador')
const showEmployeeModal = ref(false)
const { isDarkMode, toggleDarkMode, initTheme } = useDarkMode()

onMounted(() => {
  initTheme()
})

const employeeForm = reactive({
  name: '',
  surname: '',
  cpf: '',
  street: '',
  number: '',
  neighborhood: '',
  city: '',
  cep: '',
  email: '',
  phone: '',
  role: '',
  admissionDate: '',
  password: '',
  confirmPassword: ''
})

const handleLogout = () => {
  localStorage.removeItem('isLoggedIn')
  localStorage.removeItem('userName')
  router.push('/')
}

const handleRegisterEmployee = () => {
  if (employeeForm.password !== employeeForm.confirmPassword) {
    alert('As senhas não coincidem')
    return
  }
  // Simulando cadastro
  alert(`Funcionário ${employeeForm.name} ${employeeForm.surname} cadastrado com sucesso!`)
  showEmployeeModal.value = false
  // Reset form
  Object.keys(employeeForm).forEach(key => employeeForm[key] = '')
}
</script>
