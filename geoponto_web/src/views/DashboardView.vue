<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950 flex transition-colors duration-300">
    <!-- Sidebar -->
    <aside class="w-64 bg-green-700 dark:bg-green-900 text-white flex flex-col">
      <div class="p-4">
        <img src="/img/Logo_GeoPonto_branco.png" alt="GeoPonto" class="h-32 mx-auto" />
      </div>
      <nav class="flex-grow mt-2">
        <router-link to="/dashboard" class="flex items-center px-6 py-3 bg-green-800 dark:bg-green-950 border-l-4 border-white">
          <span class="mr-3">📊</span> Painel Principal
        </router-link>
        <router-link to="/dashboard/occurrences" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
          <span class="mr-3">⚠️</span> Ocorrências
        </router-link>
        <router-link to="/dashboard/reports" class="flex items-center px-6 py-3 hover:bg-green-600 dark:hover:bg-green-800 transition-colors">
          <span class="mr-3">📈</span> Relatórios
        </router-link>
      </nav>
      <div class="p-6 border-t border-green-600 dark:border-green-800">
        <button @click="handleLogout" class="flex items-center text-green-100 hover:text-white transition-colors w-full">
          <span class="mr-3">🚪</span> Sair
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-grow flex flex-col">
      <header class="bg-white dark:bg-gray-900 shadow-sm h-16 flex items-center justify-between px-8 transition-colors">
        <h1 class="text-xl font-semibold text-gray-800 dark:text-white">Perfil do Empregador</h1>
        <div class="flex items-center space-x-6">
          <button 
            @click="toggleDarkMode"
            class="p-2 rounded-lg text-gray-500 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800 transition-colors"
            aria-label="Toggle dark mode"
          >
            <svg v-if="isDarkMode" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
            </svg>
          </button>

          <div class="flex items-center space-x-4">
            <span class="text-gray-600 dark:text-gray-300 font-medium">{{ userName }}</span>
            <div class="h-10 w-10 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center text-green-700 dark:text-green-300 font-bold">
              {{ userName ? userName.charAt(0) : 'E' }}
            </div>
          </div>
        </div>
      </header>

      <section class="p-8">
        <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md p-8">
          <div class="flex justify-between items-center mb-8">
            <div>
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Gerenciamento de Funcionários</h2>
              <p class="text-gray-500 dark:text-gray-400 mt-1">Cadastre e gerencie a jornada dos seus colaboradores.</p>
            </div>
            <button @click="openRegisterModal" class="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-sm">
              + Cadastrar Novo Funcionário
            </button>
          </div>

          <!-- Empty State / List placeholder -->
          <div v-if="employees.length === 0" class="border-2 border-dashed border-gray-200 dark:border-gray-700 rounded-lg py-12 text-center">
            <p class="text-gray-400 dark:text-gray-500">Nenhum funcionário cadastrado ainda.</p>
          </div>

          <!-- Employee List Table -->
          <div v-else class="overflow-x-auto">
            <table class="w-full text-left">
              <thead class="bg-gray-50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-800">
                <tr>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Funcionário</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-right">Ações</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                <tr v-for="employee in employees" :key="employee.id_funcionario" class="hover:bg-gray-50 dark:hover:bg-gray-800/30 transition-colors">
                  <td class="px-6 py-4">
                    <div class="flex items-center">
                      <div class="h-10 w-10 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center text-green-700 dark:text-green-300 font-bold mr-3">
                        {{ employee.nome ? employee.nome.charAt(0) : '?' }}
                      </div>
                      <div>
                        <div class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ employee.nome }} {{ employee.sobrenome }}</div>
                        <div class="text-xs text-gray-500 dark:text-gray-400">{{ employee.cargo }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4 text-right">
                    <div class="flex justify-end space-x-3">
                      <button @click="openJornadaModal(employee)" title="Jornada" class="p-2 text-blue-600 hover:bg-blue-50 dark:text-blue-400 dark:hover:bg-blue-900/30 rounded-lg transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                      </button>
                      <button @click="openEditModal(employee)" title="Alterar Dados" class="p-2 text-amber-600 hover:bg-amber-50 dark:text-amber-400 dark:hover:bg-amber-900/30 rounded-lg transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                      <button @click="openPointRecordsModal(employee)" title="Ver Ponto" class="p-2 text-green-600 hover:bg-green-50 dark:text-green-400 dark:hover:bg-green-900/30 rounded-lg transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                      </button>
                      <button @click="handleDeleteEmployee(employee.id_funcionario)" title="Excluir" class="p-2 text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/30 rounded-lg transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </main>

    <!-- Modal Cadastro/Edição Funcionário -->
    <div v-if="showEmployeeModal" class="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl w-full max-w-4xl p-8 my-8 text-left transition-all">
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">{{ isEditing ? 'Alterar Dados do Funcionário' : 'Cadastrar Novo Funcionário' }}</h3>
            <button @click="showEmployeeModal = false" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 text-2xl">&times;</button>
          </div>
          <form @submit.prevent="handleRegisterEmployee" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Nome</label>
                <input v-model="employeeForm.name" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Sobrenome</label>
                <input v-model="employeeForm.surname" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">CPF</label>
                <input v-model="employeeForm.cpf" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Rua</label>
                <input v-model="employeeForm.street" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Número</label>
                <input v-model="employeeForm.number" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Bairro</label>
                <input v-model="employeeForm.neighborhood" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Cidade</label>
                <input v-model="employeeForm.city" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">CEP</label>
                <input v-model="employeeForm.cep" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">E-mail</label>
                <input v-model="employeeForm.email" type="email" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Telefone</label>
                <input v-model="employeeForm.phone" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Cargo</label>
                <input v-model="employeeForm.role" type="text" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Data de Admissão</label>
                <input v-model="employeeForm.admissionDate" type="date" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div v-if="!isEditing">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Senha</label>
                <input v-model="employeeForm.password" type="password" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
              <div v-if="!isEditing">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Confirmar Senha</label>
                <input v-model="employeeForm.confirmPassword" type="password" required class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 sm:text-sm text-gray-900 dark:text-white" />
              </div>
            </div>
            <div class="pt-6 flex space-x-3">
              <button type="button" @click="showEmployeeModal = false" class="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 font-medium hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                Cancelar
              </button>
              <button type="submit" class="flex-1 px-4 py-2 bg-green-600 text-white rounded-md font-medium hover:bg-green-700 transition-colors">
                {{ isEditing ? 'Salvar Alterações' : 'Cadastrar funcionário' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal Jornada de Trabalho (Baseado no exemplos/jornada.png) -->
    <div v-if="showJornadaModal" class="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
        <div class="bg-gray-100 dark:bg-gray-900 rounded-xl shadow-xl w-full max-w-lg overflow-hidden my-8 text-left transition-all">
          <header class="bg-green-600 text-white p-4 flex items-center">
            <button @click="showJornadaModal = false" class="mr-4 text-xl hover:bg-green-700 w-10 h-10 flex items-center justify-center rounded-full transition-colors">←</button>
            <h3 class="text-xl font-semibold">Jornada de Trabalho</h3>
          </header>
          
          <div class="p-6 space-y-6">
            <div v-if="selectedEmployee" class="mb-2 pb-4 border-b border-gray-200 dark:border-gray-800">
              <h4 class="text-lg font-bold text-gray-900 dark:text-white">
                {{ selectedEmployee.nome }} {{ selectedEmployee.sobrenome }}
              </h4>
              <p class="text-gray-500 dark:text-gray-400 font-medium">{{ selectedEmployee.cargo }}</p>
            </div>

            <section>
              <h5 class="text-gray-600 dark:text-gray-300 font-semibold mb-3">Jornada Padrão</h5>
              <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">Selecione os dias da semana para a jornada padrão:</p>
              <div class="flex justify-between mb-6">
                <button 
                  v-for="(day, index) in ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']" 
                  :key="index"
                  type="button"
                  @click="jornadaForm.weekDays[index] = !jornadaForm.weekDays[index]"
                  :class="[
                    'h-10 w-10 rounded-lg flex items-center justify-center border transition-colors font-medium',
                    jornadaForm.weekDays[index] 
                      ? 'bg-green-100 border-green-500 text-green-700 dark:bg-green-900 dark:border-green-400 dark:text-green-300' 
                      : 'bg-white border-gray-200 text-gray-500 dark:bg-gray-800 dark:border-gray-700'
                  ]"
                >
                  {{ day }}
                </button>
              </div>

              <div class="space-y-4">
                <div>
                  <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Entrada (HH:MM)</label>
                  <div class="relative mt-1">
                    <input v-model="jornadaForm.entrance" type="time" class="block w-full pl-3 pr-10 py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white" />
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-400">🕒</div>
                  </div>
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Saída Intervalo (HH:MM) - Opcional</label>
                  <div class="relative mt-1">
                    <input v-model="jornadaForm.breakStart" type="time" class="block w-full pl-3 pr-10 py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white" />
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-400">🕒</div>
                  </div>
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Retorno Intervalo (HH:MM) - Opcional</label>
                  <div class="relative mt-1">
                    <input v-model="jornadaForm.breakEnd" type="time" class="block w-full pl-3 pr-10 py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white" />
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-400">🕒</div>
                  </div>
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Saída (HH:MM)</label>
                  <div class="relative mt-1">
                    <input v-model="jornadaForm.exit" type="time" class="block w-full pl-3 pr-10 py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm focus:ring-green-500 focus:border-green-500 text-gray-900 dark:text-white" />
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-400">🕒</div>
                  </div>
                </div>
              </div>
            </section>

            <section>
              <h5 class="text-gray-600 dark:text-gray-300 font-semibold mb-3">Jornadas de Exceção</h5>
              <button type="button" class="text-green-600 dark:text-green-400 text-sm font-medium flex items-center hover:underline">
                <span class="mr-1 text-lg font-bold">+</span> Adicionar jornada de exceção
              </button>
            </section>

            <section class="pt-4 border-t border-gray-200 dark:border-gray-800">
              <div class="flex items-center justify-between mb-4">
                <span class="text-gray-700 dark:text-gray-300 font-medium">Limitar local de registro de ponto</span>
                <button 
                  type="button"
                  @click="jornadaForm.limitLocation = !jornadaForm.limitLocation"
                  :class="['w-12 h-6 rounded-full transition-colors relative focus:outline-none', jornadaForm.limitLocation ? 'bg-green-500' : 'bg-gray-300']"
                >
                  <div :class="['absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform', jornadaForm.limitLocation ? 'translate-x-6' : '']"></div>
                </button>
              </div>

              <div v-if="jornadaForm.limitLocation" class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-xs text-gray-500 uppercase font-semibold">Latitude</label>
                    <input v-model="jornadaForm.latitude" type="text" class="mt-1 block w-full px-3 py-2 bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg text-sm text-gray-900 dark:text-white" />
                  </div>
                  <div>
                    <label class="block text-xs text-gray-500 uppercase font-semibold">Longitude</label>
                    <input v-model="jornadaForm.longitude" type="text" class="mt-1 block w-full px-3 py-2 bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg text-sm text-gray-900 dark:text-white" />
                  </div>
                </div>
                <div>
                  <label class="block text-xs text-gray-500 uppercase font-semibold">Raio em metros</label>
                  <input v-model="jornadaForm.radius" type="number" class="mt-1 block w-full px-3 py-2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg text-gray-900 dark:text-white" />
                </div>
                <button 
                  type="button" 
                  @click="openMapModal"
                  class="w-full py-2 flex items-center justify-center text-gray-700 dark:text-gray-300 bg-gray-200 dark:bg-gray-800 rounded-lg text-sm font-medium hover:bg-gray-300 dark:hover:bg-gray-700 transition-colors"
                >
                  <span class="mr-2 text-base">🗺️</span> Selecionar no Mapa
                </button>
              </div>
            </section>

            <button @click="showJornadaModal = false" class="w-full py-3 bg-gray-200 dark:bg-gray-800 text-gray-900 dark:text-white rounded-xl font-bold shadow-sm hover:bg-gray-300 dark:hover:bg-gray-700 transition-colors mt-4">
              Salvar Jornada
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Selecionar no Mapa -->
    <div v-if="showMapModal" class="fixed inset-0 bg-black/60 z-[60] flex items-center justify-center p-4">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl w-full max-w-4xl overflow-hidden flex flex-col max-h-[90vh]">
        <header class="p-4 bg-green-600 text-white flex justify-between items-center">
          <h3 class="text-lg font-bold">Selecionar Localização</h3>
          <button @click="closeMapModal" class="text-2xl hover:bg-green-700 w-8 h-8 rounded-full flex items-center justify-center transition-colors">&times;</button>
        </header>

        <div class="p-4 bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
          <div class="flex gap-2">
            <div class="relative flex-grow">
              <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">🔍</span>
              <input 
                v-model="searchQuery" 
                @keyup.enter="searchAddress"
                type="text" 
                placeholder="Buscar endereço (ex: Av. Paulista, 1000)" 
                class="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-green-500 outline-none"
              />
            </div>
            <button 
              @click="searchAddress" 
              :disabled="searching"
              class="px-4 py-2 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors disabled:opacity-50"
            >
              {{ searching ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">Você pode clicar no mapa ou arrastar o marcador para definir o local exato.</p>
        </div>

        <div class="relative flex-grow min-h-[400px]">
          <div ref="mapContainer" class="absolute inset-0 z-0"></div>
          
          <!-- Botão Localização Atual -->
          <button 
            @click="getCurrentLocation"
            class="absolute bottom-6 right-6 z-[400] bg-white dark:bg-gray-800 p-3 rounded-full shadow-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors text-xl"
            title="Minha Localização"
          >
            📍
          </button>
        </div>

        <footer class="p-4 bg-gray-50 dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 flex justify-between items-center">
          <div class="text-sm text-gray-600 dark:text-gray-400">
            <span class="font-bold">Lat:</span> {{ Number(jornadaForm.latitude).toFixed(6) }} | 
            <span class="font-bold">Lng:</span> {{ Number(jornadaForm.longitude).toFixed(6) }} |
            <span class="font-bold">Raio:</span> {{ jornadaForm.radius }}m
          </div>
          <button @click="closeMapModal" class="px-8 py-2 bg-green-600 text-white rounded-lg font-bold hover:bg-green-700 transition-colors shadow-md">
            Confirmar Localização
          </button>
        </footer>
      </div>
    </div>

    <!-- Modal Registros de Ponto (Ver Ponto) -->
    <div v-if="showPointRecordsModal" class="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
        <div class="bg-white dark:bg-gray-900 rounded-xl shadow-xl w-full max-w-4xl p-8 my-8 text-left transition-all">
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">Registros de Ponto</h3>
            <button @click="showPointRecordsModal = false" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 text-2xl">&times;</button>
          </div>

          <div v-if="selectedEmployee" class="mb-6 flex flex-col md:flex-row justify-between items-start md:items-end gap-4">
            <div>
              <h4 class="text-lg font-bold text-gray-900 dark:text-white">
                {{ selectedEmployee.nome }} {{ selectedEmployee.sobrenome }}
              </h4>
              <p class="text-gray-500 dark:text-gray-400 font-medium">{{ selectedEmployee.cargo }}</p>
            </div>
            <div class="w-full md:w-auto">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Selecionar Mês</label>
              <input v-model="selectedMonth" type="month" class="w-full md:w-auto px-3 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-md text-sm text-gray-900 dark:text-white focus:ring-green-500 focus:border-green-500" />
            </div>
          </div>

          <div class="overflow-x-auto border border-gray-100 dark:border-gray-800 rounded-lg">
            <table class="w-full text-left">
              <thead class="bg-gray-50 dark:bg-gray-800/50">
                <tr>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Data</th>
                  <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Horários Registrados</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                <tr v-for="record in pointRecords" :key="record.date" class="hover:bg-gray-50 dark:hover:bg-gray-800/30 transition-colors">
                  <td class="px-6 py-4 text-sm font-medium text-gray-900 dark:text-gray-100">
                    {{ new Date(record.date + 'T12:00:00').toLocaleDateString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit', year: 'numeric' }) }}
                  </td>
                  <td class="px-6 py-4">
                    <div class="flex flex-wrap gap-2">
                      <span v-for="(reg, index) in record.registros" :key="index" 
                            class="px-3 py-1 bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-300 rounded-full text-xs font-bold border border-green-200 dark:border-green-800">
                        {{ reg.time }}
                      </span>
                      <span v-if="!record.registros || record.registros.length === 0" class="text-gray-400 italic text-sm">Nenhum registro</span>
                    </div>
                  </td>
                </tr>
                <tr v-if="pointRecords.length === 0">
                  <td colspan="2" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Nenhum registro encontrado para este mês.</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="mt-8 flex justify-end">
            <button @click="showPointRecordsModal = false" class="px-8 py-2 bg-green-600 text-white rounded-lg font-bold hover:bg-green-700 transition-colors shadow-md">
              Fechar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useDarkMode } from '../composables/useDarkMode'
import { employeeService } from '../services/employeeService'
import { pointService } from '../services/pointService'
import { authService } from '../services/authService'
import { Employee } from '../models/Employee'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

const router = useRouter()
const userName = ref(localStorage.getItem('userName') || 'Empregador')
const companyId = localStorage.getItem('id_empresa')
const showEmployeeModal = ref(false)
const { isDarkMode, toggleDarkMode, initTheme } = useDarkMode()

const isEditing = ref(false)
const selectedEmployeeId = ref(null)
const showJornadaModal = ref(false)
const showPointRecordsModal = ref(false)
const showMapModal = ref(false)
const mapContainer = ref(null)
const searchQuery = ref('')
const loading = ref(false)
const searching = ref(false)

let map = null
let marker = null
let circle = null

const employees = ref([])

const selectedEmployee = computed(() => {
  if (!selectedEmployeeId.value) return null
  return employees.value.find(e => e.id_funcionario === selectedEmployeeId.value) || 
         employees.value.find(e => String(e.id_funcionario) === String(selectedEmployeeId.value))
})

const fetchEmployees = async () => {
  if (!companyId) return
  loading.value = true
  try {
    const response = await employeeService.getAllByCompany(companyId)
    // The API returns { "funcionarios": [...] }
    employees.value = response.funcionarios || []
  } catch (err) {
    console.error('Erro ao buscar funcionários:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  initTheme()
  if (!localStorage.getItem('isLoggedIn')) {
    router.push('/')
    return
  }
  fetchEmployees()
})

const employeeForm = reactive({
  name: '',
  surname: '',
  cpf: '',
  street: '',
  number: '',
  neighborhood: '',
  city: '',
  cep: '',
  email: '',
  phone: '',
  role: '',
  admissionDate: '',
  password: '',
  confirmPassword: ''
})

const jornadaForm = reactive({
  weekDays: [false, true, true, true, true, true, false], // D, S, T, Q, Q, S, S
  entrance: '08:00',
  breakStart: '12:00',
  breakEnd: '13:00',
  exit: '17:00',
  limitLocation: true,
  latitude: '-20.56263126',
  longitude: '-47.3722213',
  radius: 50
})

const selectedMonth = ref(new Date().toISOString().substring(0, 7)) // YYYY-MM
const pointRecords = ref([])

const handleLogout = () => {
  authService.logout()
  router.push('/')
}

const openRegisterModal = () => {
  isEditing.value = false
  selectedEmployeeId.value = null
  Object.keys(employeeForm).forEach(key => employeeForm[key] = '')
  showEmployeeModal.value = true
}

const openEditModal = (employee) => {
  isEditing.value = true
  selectedEmployeeId.value = employee.id_funcionario
  employeeForm.name = employee.nome
  employeeForm.surname = employee.sobrenome
  employeeForm.cpf = employee.cpf || ''
  employeeForm.street = employee.rua || ''
  employeeForm.number = employee.numero || ''
  employeeForm.neighborhood = employee.bairro || ''
  employeeForm.city = employee.cidade || ''
  employeeForm.cep = employee.cep || ''
  employeeForm.email = employee.email
  employeeForm.phone = employee.telefone || ''
  employeeForm.role = employee.cargo
  employeeForm.admissionDate = employee.data_admissao ? employee.data_admissao.split('T')[0] : ''
  employeeForm.password = ''
  employeeForm.confirmPassword = ''
  showEmployeeModal.value = true
}

const openJornadaModal = (employee) => {
  selectedEmployeeId.value = employee.id_funcionario
  showJornadaModal.value = true
}

const openPointRecordsModal = async (employee) => {
  selectedEmployeeId.value = employee.id_funcionario
  showPointRecordsModal.value = true
  await fetchPointRecords()
}

watch(selectedMonth, () => {
  fetchPointRecords()
})

const fetchPointRecords = async () => {
  if (!selectedEmployeeId.value) return
  const [year, month] = selectedMonth.value.split('-')
  try {
    const response = await pointService.getByEmployee(selectedEmployeeId.value, month, year)
    
    // Suporta resposta como array direto ou objeto { "pontos": [...] }
    const data = Array.isArray(response) ? response : (response.pontos || response.registros || [])
    
    pointRecords.value = data.map(day => ({
      date: day.data,
      registros: day.registros || []
    }))
  } catch (err) {
    console.error('Erro ao buscar registros de ponto:', err)
    pointRecords.value = []
  }
}

const handleRegisterEmployee = async () => {
  if (!isEditing.value && employeeForm.password !== employeeForm.confirmPassword) {
    alert('As senhas não coincidem')
    return
  }

  try {
    const employeeData = new Employee({
      id_empresa: companyId,
      nome: employeeForm.name,
      sobrenome: employeeForm.surname,
      cpf: employeeForm.cpf,
      rua: employeeForm.street,
      numero: employeeForm.number,
      bairro: employeeForm.neighborhood,
      cidade: employeeForm.city,
      cep: employeeForm.cep,
      email: employeeForm.email,
      telefone: employeeForm.phone,
      cargo: employeeForm.role,
      senha: employeeForm.password,
      data_admissao: employeeForm.admissionDate
    })

    if (isEditing.value) {
      await employeeService.update(selectedEmployeeId.value, employeeData.toJSON())
      alert(`Dados de ${employeeForm.name} atualizados com sucesso!`)
    } else {
      await employeeService.register(employeeData.toJSON())
      alert(`Funcionário ${employeeForm.name} ${employeeForm.surname} cadastrado com sucesso!`)
    }
    showEmployeeModal.value = false
    fetchEmployees()
  } catch (err) {
    alert(err.message || 'Erro ao processar funcionário')
  }
}

const handleDeleteEmployee = async (id) => {
  if (confirm('Tem certeza que deseja excluir este funcionário?')) {
    try {
      await employeeService.delete(id)
      fetchEmployees()
    } catch (err) {
      alert(err.message || 'Erro ao excluir funcionário')
    }
  }
}

// Map Logic
const openMapModal = async () => {
  showMapModal.value = true
  await nextTick()
  initMap()
}

const closeMapModal = () => {
  showMapModal.value = false
  if (map) {
    map.remove()
    map = null
  }
}

const initMap = () => {
  const lat = parseFloat(jornadaForm.latitude) || -23.55052
  const lng = parseFloat(jornadaForm.longitude) || -46.633308
  const radius = parseInt(jornadaForm.radius) || 100

  if (map) {
    map.remove()
  }

  map = L.map(mapContainer.value).setView([lat, lng], 15)

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map)

  // Fix for Leaflet default icons in Vite
  const defaultIcon = L.icon({
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41]
  })

  marker = L.marker([lat, lng], { draggable: true, icon: defaultIcon }).addTo(map)
  circle = L.circle([lat, lng], {
    color: '#16a34a',
    fillColor: '#22c55e',
    fillOpacity: 0.2,
    radius: radius
  }).addTo(map)

  marker.on('drag', (e) => {
    const { lat, lng } = e.target.getLatLng()
    jornadaForm.latitude = lat.toString()
    jornadaForm.longitude = lng.toString()
    circle.setLatLng(e.target.getLatLng())
  })

  map.on('click', (e) => {
    const { lat, lng } = e.latlng
    jornadaForm.latitude = lat.toString()
    jornadaForm.longitude = lng.toString()
    marker.setLatLng(e.latlng)
    circle.setLatLng(e.latlng)
  })
}

// Watch radius for circle updates
watch(() => jornadaForm.radius, (newRadius) => {
  if (circle && map) {
    circle.setRadius(newRadius || 0)
  }
})

const searchAddress = async () => {
  if (!searchQuery.value) return
  searching.value = true
  try {
    const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(searchQuery.value)}`)
    const data = await response.json()
    if (data && data.length > 0) {
      const { lat, lon } = data[0]
      const newLat = parseFloat(lat)
      const newLng = parseFloat(lon)
      
      jornadaForm.latitude = newLat.toString()
      jornadaForm.longitude = newLng.toString()
      
      map.setView([newLat, newLng], 16)
      marker.setLatLng([newLat, newLng])
      circle.setLatLng([newLat, newLng])
    } else {
      alert('Endereço não encontrado')
    }
  } catch (err) {
    console.error('Erro na busca:', err)
    alert('Erro ao buscar endereço')
  } finally {
    searching.value = false
  }
}

const getCurrentLocation = () => {
  if (!navigator.geolocation) {
    alert('Geolocalização não suportada pelo seu navegador')
    return
  }

  navigator.geolocation.getCurrentPosition((position) => {
    const { latitude, longitude } = position.coords
    jornadaForm.latitude = latitude.toString()
    jornadaForm.longitude = longitude.toString()
    
    if (map) {
      map.setView([latitude, longitude], 16)
      marker.setLatLng([latitude, longitude])
      circle.setLatLng([latitude, longitude])
    }
  }, (err) => {
    let msg = 'Erro ao obter localização'
    if (err.code === 1) msg = 'Permissão de localização negada'
    alert(msg)
  })
}
</script>
