<template>
  <div class="min-h-screen bg-gray-100 flex flex-col justify-center items-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <router-link to="/">
        <img class="mx-auto h-64 w-auto" src="/img/Logo_GeoPonto.png" alt="GeoPonto" />
      </router-link>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        {{ isLogin ? 'Acesse sua conta' : 'Crie sua conta de Empregador' }}
      </h2>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full" :class="isLogin ? 'sm:max-w-md' : 'sm:max-w-4xl'">
      <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <!-- Form Login -->
        <form v-if="isLogin" @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label for="username" class="block text-sm font-medium text-gray-700">Usuário</label>
            <div class="mt-1">
              <input v-model="loginForm.username" id="username" name="username" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">Senha</label>
            <div class="mt-1">
              <input v-model="loginForm.password" id="password" name="password" type="password" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
            </div>
          </div>

          <div v-if="error" class="text-red-600 text-sm">
            {{ error }}
          </div>

          <div>
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
              Entrar
            </button>
          </div>
        </form>

        <!-- Form Cadastro -->
        <form v-else @submit.prevent="handleRegister" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Razão Social</label>
              <div class="mt-1">
                <input v-model="registerForm.razaoSocial" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Nome Fantasia</label>
              <div class="mt-1">
                <input v-model="registerForm.nomeFantasia" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">CNPJ</label>
              <div class="mt-1">
                <input v-model="registerForm.cnpj" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Logradouro</label>
              <div class="mt-1">
                <input v-model="registerForm.logradouro" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Número</label>
              <div class="mt-1">
                <input v-model="registerForm.numero" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Bairro</label>
              <div class="mt-1">
                <input v-model="registerForm.bairro" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Município</label>
              <div class="mt-1">
                <input v-model="registerForm.municipio" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">UF</label>
              <div class="mt-1">
                <input v-model="registerForm.uf" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">CEP</label>
              <div class="mt-1">
                <input v-model="registerForm.cep" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">País</label>
              <div class="mt-1">
                <input v-model="registerForm.pais" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Nome de Usuário</label>
              <div class="mt-1">
                <input v-model="registerForm.username" type="text" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Senha</label>
              <div class="mt-1">
                <input v-model="registerForm.password" type="password" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Confirmar Senha</label>
              <div class="mt-1">
                <input v-model="registerForm.confirmPassword" type="password" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-green-500 focus:border-green-500 sm:text-sm" />
              </div>
            </div>
          </div>

          <div class="pt-4">
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
              Cadastrar
            </button>
          </div>
        </form>

        <div class="mt-6">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-white text-gray-500">
                {{ isLogin ? 'Ainda não tem conta?' : 'Já tem uma conta?' }}
              </span>
            </div>
          </div>

          <div class="mt-6">
            <button @click="isLogin = !isLogin" class="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
              {{ isLogin ? 'Cadastre-se agora' : 'Faça login' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const isLogin = ref(true)
const error = ref('')

const loginForm = reactive({
  username: '',
  password: ''
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
  pais: '',
  username: '',
  password: '',
  confirmPassword: ''
})

const handleLogin = () => {
  if (loginForm.username === 'admin' && loginForm.password === 'admin') {
    localStorage.setItem('isLoggedIn', 'true')
    localStorage.setItem('userName', 'Admin GeoPonto')
    router.push('/dashboard')
  } else {
    error.value = 'Usuário ou senha inválidos'
  }
}

const handleRegister = () => {
  if (registerForm.password !== registerForm.confirmPassword) {
    alert('As senhas não coincidem')
    return
  }
  // Simulando cadastro
  alert('Cadastro realizado com sucesso! Agora você pode fazer login.')
  isLogin.value = true
}
</script>
