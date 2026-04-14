<template>
  <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4" @click.self="close">
    <div class="bg-white dark:bg-gray-800 rounded-[2rem] shadow-2xl w-full max-w-4xl overflow-hidden relative animate-in fade-in zoom-in duration-300">
      <!-- Close Button -->
      <button @click="close" class="absolute top-6 right-6 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>

      <div class="p-10 md:p-16">
        <h2 class="text-4xl font-bold text-center text-gray-800 dark:text-white mb-16">Acesse sua conta</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
          <!-- Login Section -->
          <div class="border-[3px] border-green-500 rounded-[2rem] p-10 flex flex-col items-center">
            <h3 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-10">Já sou cliente</h3>
            
            <form @submit.prevent="handleLogin" class="w-full space-y-6">
              <div class="space-y-2">
                <label class="block text-lg font-bold text-gray-800 dark:text-gray-200 ml-1">Usuário</label>
                <div class="relative">
                  <input 
                    v-model="loginForm.username"
                    type="text" 
                    placeholder="admin"
                    required
                    class="w-full px-5 py-4 bg-gray-100 dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-2xl focus:border-green-500 focus:bg-white dark:focus:bg-gray-600 transition-all outline-none text-gray-700 dark:text-gray-200 shadow-inner"
                  >
                </div>
              </div>

              <div class="space-y-2">
                <label class="block text-lg font-bold text-gray-800 dark:text-gray-200 ml-1">Senha</label>
                <div class="relative">
                  <input 
                    v-model="loginForm.password"
                    type="password" 
                    placeholder="........"
                    required
                    class="w-full px-5 py-4 bg-gray-100 dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-2xl focus:border-green-500 focus:bg-white dark:focus:bg-gray-600 transition-all outline-none text-gray-700 dark:text-gray-200 shadow-inner"
                  >
                </div>
              </div>

              <div v-if="error" class="text-red-500 text-sm font-medium text-center">
                {{ error }}
              </div>

              <button 
                type="submit"
                class="w-full py-5 bg-green-500 hover:bg-green-600 text-white font-bold text-xl rounded-2xl shadow-lg transition-all transform hover:-translate-y-1 active:scale-95 mt-4"
              >
                Entrar
              </button>
            </form>
          </div>

          <!-- Register Section -->
          <div class="border-[3px] border-gray-100 dark:border-gray-700 rounded-[2rem] p-10 flex flex-col items-center justify-between text-center">
            <div>
              <h3 class="text-2xl font-bold text-gray-800 dark:text-gray-100 mb-10">Quero cadastrar minha empresa</h3>
              <p class="text-gray-500 dark:text-gray-400 text-lg leading-relaxed mb-10 px-4">
                Comece a gerenciar a jornada da sua equipe com inteligência e precisão.
              </p>
            </div>

            <button 
              @click="goToRegister"
              class="w-full py-5 border-[3px] border-green-500 text-green-500 hover:bg-green-50 dark:hover:bg-green-900/30 font-bold text-xl rounded-2xl transition-all transform hover:-translate-y-1 active:scale-95"
            >
              Criar Conta Grátis
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  isOpen: Boolean
})

const emit = defineEmits(['close'])

const router = useRouter()
const error = ref('')

const loginForm = reactive({
  username: '',
  password: ''
})

const close = () => {
  emit('close')
}

const handleLogin = () => {
  // Simple validation for demo
  if (loginForm.username && loginForm.password) {
    if (loginForm.username === 'admin' && loginForm.password === 'admin') {
      localStorage.setItem('isLoggedIn', 'true')
      localStorage.setItem('userName', 'Admin GeoPonto')
      close()
      router.push('/dashboard')
    } else {
      error.value = 'Usuário ou senha incorretos'
    }
  }
}

const goToRegister = () => {
  close()
  router.push('/register')
}
</script>
