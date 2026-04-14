import { ref } from 'vue'

const isDarkMode = ref(false)

export function useDarkMode() {
  const updateTheme = (dark) => {
    isDarkMode.value = dark
    if (dark) {
      document.documentElement.classList.add('dark')
      localStorage.setItem('theme', 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem('theme', 'light')
    }
  }

  const toggleDarkMode = () => {
    updateTheme(!isDarkMode.value)
  }

  const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    const dark = savedTheme === 'dark'
    
    // Set initial class without side effects
    isDarkMode.value = dark
    if (dark) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  return {
    isDarkMode,
    toggleDarkMode,
    initTheme
  }
}
