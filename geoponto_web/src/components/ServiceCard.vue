<template>
  <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg hover:shadow-2xl transition duration-300 transform hover:-translate-y-1 overflow-hidden">
    <div class="h-48 overflow-hidden">
      <img :src="image" :alt="title" :class="['w-full h-full object-cover dark:opacity-90', imagePosition || 'object-center']">
    </div>
    <div class="p-6">
      <h3 class="text-xl font-bold text-gray-800 dark:text-gray-100 mb-2">{{ title }}</h3>
      <p class="text-gray-600 dark:text-gray-400 leading-relaxed">{{ description }}</p>
    </div>
  </div>
</template>

<script setup>
defineProps({
  image: String,
  title: String,
  description: String,
  imagePosition: {
    type: String,
    default: 'object-center'
  }
})
</script>
