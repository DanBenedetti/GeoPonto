import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import RegisterView from '../views/RegisterView.vue'
import DashboardView from '../views/DashboardView.vue'
import OccurrencesView from '../views/OccurrencesView.vue'
import ReportsView from '../views/ReportsView.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterView
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardView,
    meta: { requiresAuth: true }
  },
  {
    path: '/dashboard/reports',
    name: 'reports',
    component: ReportsView,
    meta: { requiresAuth: true }
  },
  {
    path: '/dashboard/occurrences',
    name: 'occurrences',
    component: OccurrencesView,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true'
  if (to.meta.requiresAuth && !isLoggedIn) {
    // If not logged in, redirect to home where the login modal is
    next('/')
  } else {
    next()
  }
})

export default router
