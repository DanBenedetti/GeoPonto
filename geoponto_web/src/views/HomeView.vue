<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <Navbar />

    <main class="flex-grow">
      <!-- Hero Section -->
      <ResponsiveBanner
        desktopSrc="/img/banner_site_topo.png"
        mobileSrc="/img/banner_mobile_topo.png"
        alt="GeoPonto Topo"
      />

      <!-- Services Grid -->
      <section class="py-16 px-6 container mx-auto">
        <h2 class="text-3xl font-extrabold text-center text-gray-900 mb-12">
          Nossos Serviços Especializados
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          <ServiceCard
            v-for="(service, index) in services"
            :key="index"
            :image="service.image"
            :title="service.title"
            :description="service.description"
            :imagePosition="service.imagePosition"
          />
        </div>
      </section>

      <!-- Services Interstitial Banner -->
      <ResponsiveBanner
        desktopSrc="/img/banner_site_servico.png"
        mobileSrc="/img/banner_mobile_servicos.png"
        alt="Serviços GeoPonto"
      />

      <!-- App Banner Section -->
      <ResponsiveBanner
        desktopSrc="/img/banner_site_app.png"
        mobileSrc="/img/banner_mobile_app.png"
        alt="App GeoPonto"
      />
    </main>

    <Footer />
  </div>
</template>

<script setup>
import Navbar from '../components/Navbar.vue'
import Footer from '../components/Footer.vue'
import ResponsiveBanner from '../components/ResponsiveBanner.vue'
import ServiceCard from '../components/ServiceCard.vue'

const services = [
  {
    image: '/img/servico_1.png',
    title: 'Relatórios Analíticos',
    description: 'Gere dashboards e relatórios detalhados para tomada de decisão estratégica baseada em dados.'
  },
  {
    image: '/img/servico_2.png',
    title: 'Marcação de Ponto por Geolocalização',
    description: 'Sistema de ponto eletrônico com validação por geolocalização em tempo real, garantinco precisão e segurança.',
    imagePosition: 'object-top'
  },
  {
    image: '/img/servico_3.png',
    title: 'Reconhecimento Facial com IA',
    description: 'Tecnologia de reconhecimento facial para validação biometrica das marcações de ponto.'
  },
  {
    image: '/img/servico_4.png',
    title: 'Gerenciamento Eficiente de Jornada de Trabalho',
    description: 'Controle completo da jornada de trabalho da sua equipe com ferramentas inteligentes e intuitivas.'
  }
]
</script>
