<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-950 flex flex-col justify-center items-center py-12 sm:px-6 lg:px-8 font-sans transition-colors duration-300">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <router-link to="/">
        <img class="mx-auto h-32 w-auto dark:brightness-110" src="/img/Logo_GeoPonto.png" alt="GeoPonto" />
      </router-link>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-white">
        Crie sua conta de Empregador
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
        Já tem uma conta? 
        <router-link to="/" class="font-medium text-green-600 dark:text-green-400 hover:text-green-500">
          Faça login pelo portal
        </router-link>
      </p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-4xl">
      <div class="bg-white dark:bg-gray-900 py-8 px-4 shadow-xl sm:rounded-2xl sm:px-10 border border-gray-100 dark:border-gray-800 transition-colors">
        <!-- Form Cadastro -->
        <form @submit.prevent="handleRegister" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Razão Social</label>
              <input v-model="registerForm.razaoSocial" type="text" required placeholder="Sua Empresa LTDA" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Nome Fantasia</label>
              <input v-model="registerForm.nomeFantasia" type="text" required placeholder="Nome da Empresa" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">CNPJ</label>
              <input v-model="registerForm.cnpj" type="text" required placeholder="00.000.000/0000-00" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">CEP</label>
              <input v-model="registerForm.cep" type="text" required placeholder="00000-000" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Logradouro</label>
              <input v-model="registerForm.logradouro" type="text" required placeholder="Rua, Avenida..." class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Número</label>
              <input v-model="registerForm.numero" type="text" required placeholder="123" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Bairro</label>
              <input v-model="registerForm.bairro" type="text" required placeholder="Bairro" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Município</label>
              <input v-model="registerForm.municipio" type="text" required placeholder="Cidade" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1 md:col-span-2">
              <hr class="my-4 border-gray-200 dark:border-gray-700" />
              <h3 class="text-lg font-bold text-gray-800 dark:text-gray-200 mb-4">Dados de Acesso</h3>
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Nome de Usuário</label>
              <input v-model="registerForm.username" type="text" required placeholder="usuário" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Senha</label>
              <input v-model="registerForm.password" type="password" required placeholder="........" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">Confirmar Senha</label>
              <input v-model="registerForm.confirmPassword" type="password" required placeholder="........" class="appearance-none block w-full px-4 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all text-gray-900 dark:text-white dark:placeholder-gray-500" />
            </div>
          </div>

          <div class="pt-6">
            <button type="submit" class="w-full flex justify-center py-4 px-4 border border-transparent rounded-xl shadow-lg text-lg font-bold text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-all transform hover:-translate-y-1">
              Finalizar Cadastro
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDarkMode } from '../composables/useDarkMode'

const router = useRouter()
const { initTheme } = useDarkMode()

onMounted(() => {
  initTheme()
})

const registerForm = reactive({
  razaoSocial: '',
  nomeFantasia: '',
  cnpj: '',
  logradouro: '',
  numero: '',
  bairro: '',
  municipio: '',
  uf: '',
  cep: '',
  pais: 'Brasil',
  username: '',
  password: '',
  confirmPassword: ''
})

const handleRegister = () => {
  if (registerForm.password !== registerForm.confirmPassword) {
    alert('As senhas não coincidem')
    return
  }
  // Simulando cadastro
  alert('Cadastro realizado com sucesso! Agora você pode fazer login pelo portal.')
  router.push('/')
}
</script>
