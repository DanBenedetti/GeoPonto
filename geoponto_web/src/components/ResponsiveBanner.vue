<template>
  <div class="w-full">
    <!-- Desktop Banner -->
    <img :src="desktopSrc" :alt="alt" class="hidden md:block w-full object-cover">
    <!-- Mobile Banner -->
    <img :src="mobileSrc" :alt="alt" class="block md:hidden w-full object-cover">
  </div>
</template>

<script setup>
defineProps({
  desktopSrc: String,
  mobileSrc: String,
  alt: {
    type: String,
    default: 'Banner'
  }
})
</script>
