<template>
  <nav class="bg-white dark:bg-gray-900 shadow-md py-2 px-6 sticky top-0 z-50 h-20 transition-colors duration-300">
    <div class="container mx-auto flex items-center h-full">
      <div class="flex items-center relative h-full w-48">
        <img src="/img/Logo_GeoPonto.png" alt="GeoPonto" class="h-36 absolute top-1/2 -translate-y-1/2 left-0 max-w-none dark:brightness-110">
      </div>
      <div class="hidden md:flex ml-auto space-x-8 text-gray-700 dark:text-gray-300 font-medium mr-12">
        <a href="#" class="hover:text-green-600 dark:hover:text-green-400 transition-colors">Home</a>
        <a href="#" class="hover:text-green-600 dark:hover:text-green-400 transition-colors">Serviços</a>
        <a href="#" class="hover:text-green-600 dark:hover:text-green-400 transition-colors">Sobre</a>
        <a href="#" class="hover:text-green-600 dark:hover:text-green-400 transition-colors">Contato</a>
      </div>
      <div class="flex items-center space-x-4">
        <button 
          @click="toggleDarkMode"
          class="p-2 rounded-lg text-gray-500 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-700 transition-colors"
          aria-label="Toggle dark mode"
        >
          <!-- Sun icon -->
          <svg v-if="isDarkMode" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <!-- Moon icon -->
          <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
          </svg>
        </button>

        <button 
          @click="isAuthModalOpen = true"
          class="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-sm cursor-pointer"
        >
          Login
        </button>
      </div>
    </div>
  </nav>

  <!-- Auth Modal -->
  <AuthModal :isOpen="isAuthModalOpen" @close="isAuthModalOpen = false" />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AuthModal from './AuthModal.vue'
import { useDarkMode } from '../composables/useDarkMode'

const isAuthModalOpen = ref(false)
const { isDarkMode, toggleDarkMode, initTheme } = useDarkMode()

onMounted(() => {
  initTheme()
})
</script>
