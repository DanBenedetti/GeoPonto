<template>
  <nav class="bg-white shadow-md py-2 px-6 sticky top-0 z-50 h-20">
    <div class="container mx-auto flex items-center h-full">
      <div class="flex items-center relative h-full w-48">
        <img src="/img/Logo_GeoPonto.png" alt="GeoPonto" class="h-36 absolute top-1/2 -translate-y-1/2 left-0 max-w-none">
      </div>
      <div class="hidden md:flex ml-auto space-x-8 text-gray-700 font-medium mr-12">
        <a href="#" class="hover:text-green-600 transition-colors">Home</a>
        <a href="#" class="hover:text-green-600 transition-colors">Serviços</a>
        <a href="#" class="hover:text-green-600 transition-colors">Sobre</a>
        <a href="#" class="hover:text-green-600 transition-colors">Contato</a>
      </div>
      <div>
        <button class="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-sm">
          Login
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup>
</script>
