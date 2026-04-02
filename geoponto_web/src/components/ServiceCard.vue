<template>
  <div class="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-2xl transition duration-300 transform hover:-translate-y-1">
    <div class="h-48 overflow-hidden">
      <img :src="image" :alt="title" :class="['w-full h-full object-cover', imagePosition || 'object-center']">
    </div>
    <div class="p-6">
      <h3 class="text-xl font-bold text-gray-800 mb-2">{{ title }}</h3>
      <p class="text-gray-600 leading-relaxed">{{ description }}</p>
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
