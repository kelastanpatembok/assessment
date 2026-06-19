<script lang="ts">
  import { createApiClient } from '$lib/api/index';
  import {
    StepIndicator,
    AssignmentCreationForm,
    UsernamePatternConfig,
    CredentialDisplay,
    ProgressIndicator,
  } from '$lib/components/wizard';
  import { PUBLIC_API_URL } from '$env/static/public';

  // ==================== TypeScript Interfaces ====================

  /**
   * Represents a test assignment that can be selected in step 1
   * Combines school and test category information
   */
  interface TestAssignment {
    id: number;
    schoolId: number;
    categoryId: number;
    school: {
      id: number;
      name: string;
    };
    category: {
      id: number;
      name: string;
      slug: string;
    };
    status: string;
    startDate: string;
    endDate: string;
  }

  /**
   * Represents a generated student credential
   * Contains plaintext password for display/export only (never logged or stored)
   */
  interface Credential {
    username: string;
    password: string; // plaintext, for display/export only
    authUserId: string;
    createdAt: string;
  }

  /**
   * Represents the username pattern template
   * Used in step 2 for configuring credential naming
   */
  interface UsernamePattern {
    schoolCode: string;
    testCode: string;
    preview: string;
  }

  // ==================== Wizard State (Svelte 5 Runes) ====================

  let currentStep = $state(1); // 1 = create assignment, 2 = configure, 3 = display
  let assignmentForm = $state({
    schoolId: null as number | null,
    categoryId: null as number | null, 
    startDate: '',
    endDate: ''
  });
  let createdAssignment = $state<TestAssignment | null>(null);
  let assignmentErrors = $state<{ [key: string]: string }>({});
  let usernamePattern = $state<UsernamePattern>({
    schoolCode: '',
    testCode: '',
    preview: '',
  });
  let studentCount = $state<number>(1);
  let generatedCredentials = $state<Credential[]>([]);
  let isGenerating = $state(false);
  let error = $state<string | null>(null);

  // ==================== Lifecycle & Props ====================

  let { data } = $props();
  let token: string | null = $state(null);

  // Initialize token from page data
  $effect(() => {
    if (data?.token) {
      token = data.token;
    }
  });

  // ==================== Step Navigation Logic ====================

  /**
   * Handles progression to next step with validation
   * - Step 1: Requires assignment form validation and creates assignment
   * - Step 2: Requires pattern validation and student count
   * - Step 3: Display phase (no progression)
   */
  function handleStepNext() {
    switch (currentStep) {
      case 1:
        // Validate and create assignment
        if (!validateAssignmentForm()) return;
        
        handleCreateAssignment();
        break;

      case 2:
        if (!validatePattern()) {
          return;
        }
        if (studentCount < 1 || studentCount > 500 || !Number.isInteger(studentCount)) {
          error = 'Jumlah siswa harus antara 1 dan 500';
          return;
        }
        error = null;
        currentStep = 3;
        // Trigger generation in task 5.8
        handleGenerate();
        break;

      case 3:
        // No progression from step 3 (display phase)
        break;
    }
  }

  /**
   * Handles backward navigation
   * Preserves form data when going backward
   * Does not display back button on final display screen (handled in template)
   */
  function handleStepBack() {
    if (currentStep > 1) {
      error = null;
      currentStep--;
    }
  }

  /**
   * Validates username pattern components
   * - schoolCode: max 10 chars, alphanumeric + underscore
   * - testCode: max 10 chars, alphanumeric + underscore
   */
  function validatePattern(): boolean {
    const patternRegex = /^[A-Za-z0-9_]+$/;

    if (!usernamePattern.schoolCode.trim()) {
      error = 'School code diperlukan';
      return false;
    }

    if (usernamePattern.schoolCode.length > 10) {
      error = 'School code maksimal 10 karakter';
      return false;
    }

    if (!patternRegex.test(usernamePattern.schoolCode)) {
      error = 'School code hanya boleh berisi huruf, angka, dan underscore';
      return false;
    }

    if (!usernamePattern.testCode.trim()) {
      error = 'Test code diperlukan';
      return false;
    }

    if (usernamePattern.testCode.length > 10) {
      error = 'Test code maksimal 10 karakter';
      return false;
    }

    if (!patternRegex.test(usernamePattern.testCode)) {
      error = 'Test code hanya boleh berisi huruf, angka, dan underscore';
      return false;
    }

    error = null;
    return true;
  }

  /**
   * Derives default school code from school name
   * Takes first 10 alphanumeric characters and converts to uppercase
   */
  function deriveSchoolCode(schoolName: string): string {
    return schoolName
      .replace(/[^a-zA-Z0-9]/g, '')
      .substring(0, 10)
      .toUpperCase();
  }

  /**
   * Validates assignment form before creation
   */
  function validateAssignmentForm(): boolean {
    assignmentErrors = {};
    
    if (!assignmentForm.schoolId) {
      assignmentErrors.schoolId = 'Pilih sekolah';
    }
    if (!assignmentForm.categoryId) {
      assignmentErrors.categoryId = 'Pilih kategori tes';
    }
    if (!assignmentForm.startDate) {
      assignmentErrors.startDate = 'Tanggal mulai diperlukan';
    }
    if (!assignmentForm.endDate) {
      assignmentErrors.endDate = 'Tanggal berakhir diperlukan';
    }
    if (assignmentForm.startDate && assignmentForm.endDate && assignmentForm.startDate >= assignmentForm.endDate) {
      assignmentErrors.endDate = 'Tanggal berakhir harus setelah tanggal mulai';
    }
    
    return Object.keys(assignmentErrors).length === 0;
  }

  /**
   * Creates a new test assignment and moves to step 2
   */
  async function handleCreateAssignment() {
    isGenerating = true;
    error = null;
    
    try {
      const api = createApiClient(token);
      
      const response = await api.post('/test-assignments', {
        schoolId: assignmentForm.schoolId,
        categoryId: assignmentForm.categoryId,
        windowStart: assignmentForm.startDate + 'T00:00:00',
        windowEnd: assignmentForm.endDate + 'T23:59:59',
        active: true
      });
      
      createdAssignment = {
        id: response.id,
        schoolId: assignmentForm.schoolId!,
        categoryId: assignmentForm.categoryId!,
        school: data.schools.find(s => s.id === assignmentForm.schoolId)!,
        category: data.categories.find(c => c.id === assignmentForm.categoryId)!,
        status: 'aktif',
        startDate: assignmentForm.startDate,
        endDate: assignmentForm.endDate
      };
      
      // Auto-derive username pattern from created assignment
      usernamePattern.schoolCode = deriveSchoolCode(createdAssignment.school.name);
      usernamePattern.testCode = createdAssignment.category.slug.substring(0, 10).toUpperCase();
      
      currentStep = 2;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Gagal membuat penugasan tes';
    } finally {
      isGenerating = false;
    }
  }

  /**
   * Generates preview usernames based on current pattern and count
   * Shows first and last username format
   */
  function generatePreview(): string {
    if (!usernamePattern.schoolCode || !usernamePattern.testCode) {
      return '';
    }

    const prefix = `${usernamePattern.schoolCode}_${usernamePattern.testCode}`;
    const first = `${prefix}_001`;
    const last = `${prefix}_${String(studentCount).padStart(3, '0')}`;

    if (studentCount === 1) {
      return first;
    }

    return `${first} ... ${last}`;
  }

  /**
   * Handles bulk credential generation API call
   * Called automatically after step 2 validation (task 5.8)
   * Sets isGenerating flag during request
   * Handles success and error responses with retry capability
   */
  async function handleGenerate() {
    if (!createdAssignment) return;

    isGenerating = true;
    error = null;

    try {
      // Create API client for this request
      // In task 5.8, token will be available from page context
      const api = createApiClient(token);

      console.log('Generating credentials with data:', {
        testAssignmentId: createdAssignment.id,
        schoolCode: usernamePattern.schoolCode,
        testCode: usernamePattern.testCode,
        count: studentCount,
      });

      const response = await api.post('/credentials/bulk-generate', {
        testAssignmentId: createdAssignment.id,
        schoolCode: usernamePattern.schoolCode,
        testCode: usernamePattern.testCode,
        count: studentCount,
      });

      console.log('API response:', response);

      if (response && response.credentials) {
        generatedCredentials = response.credentials;
        currentStep = 3;
      } else {
        // Show what the actual response contains for debugging
        console.error('Invalid response structure:', response);
        error = `Respons server tidak valid. Expected 'credentials' field but got: ${JSON.stringify(response, null, 2)}`;
      }
    } catch (e) {
      // Show more details about the actual error
      console.error('Credential generation failed:', e);
      
      let errorMessage = 'Terjadi kesalahan saat membuat kredensial';
      
      if (e instanceof Error) {
        errorMessage = e.message;
        
        // Check for common error scenarios
        if (e.message.includes('401') || e.message.includes('Unauthorized')) {
          errorMessage = 'Sesi telah berakhir. Silakan login ulang.';
        } else if (e.message.includes('403') || e.message.includes('Forbidden')) {
          errorMessage = 'Anda tidak memiliki izin untuk membuat kredensial.';
        } else if (e.message.includes('404') || e.message.includes('Not Found')) {
          errorMessage = 'Endpoint tidak ditemukan. Periksa konfigurasi server.';
        } else if (e.message.includes('500')) {
          errorMessage = 'Terjadi kesalahan server internal. Hubungi administrator.';
        } else if (e.message.includes('network') || e.message.includes('fetch')) {
          errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        }
      } else {
        errorMessage = `Kesalahan tidak dikenal: ${JSON.stringify(e)}`;
      }
      
      error = errorMessage;
      currentStep = 2; // Return to config step on error
    } finally {
      isGenerating = false;
    }
  }

  /**
   * Handles retry after error
   * Resets error state and retries with same inputs
   * Called from error display in template
   */
  function handleRetry() {
    error = null;
    currentStep = 2;
    handleGenerate();
  }

  // ==================== Reactive Updates ====================

  /**
   * Update preview whenever pattern or count changes
   */
  $effect(() => {
    usernamePattern.preview = generatePreview();
  });
</script>

<svelte:head><title>Generate Kredensial Siswa</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Generate Kredensial Siswa</h2>
    <a
      href="/admin-dashboard"
      class="text-muted-foreground hover:text-foreground text-sm transition-colors"
    >
      &larr; Kembali ke Dashboard
    </a>
  </div>

  <!-- Step Indicator -->
  <StepIndicator step={currentStep} />

  <!-- Step 1: Create Test Assignment -->
  {#if currentStep === 1}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <h3 class="mb-4 text-lg font-semibold">Buat Penugasan Tes</h3>
      <AssignmentCreationForm 
        schools={data.schools}
        categories={data.categories}
        bind:form={assignmentForm}
        errors={assignmentErrors}
      />
    </div>
  {/if}

  <!-- Step 2: Configure Username Pattern & Student Count -->
  {#if currentStep === 2}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <h3 class="mb-4 text-lg font-semibold">Konfigurasi Pola Username</h3>
      {#if createdAssignment}
        <UsernamePatternConfig
          bind:pattern={usernamePattern}
          bind:count={studentCount}
          assignment={createdAssignment}
        />
      {/if}
    </div>
  {/if}

  <!-- Step 3: Display Generated Credentials -->
  {#if currentStep === 3}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <CredentialDisplay
        credentials={generatedCredentials}
        schoolName={createdAssignment?.school.name || ''}
        testCategory={createdAssignment?.category.name || ''}
      />
    </div>
  {/if}

  <!-- Error Display with Retry -->
  {#if error}
    <div class="bg-destructive/10 border-destructive rounded-lg border p-4">
      <p class="text-destructive font-medium mb-2">{error}</p>
      
      <!-- Development debugging info -->
      {#if import.meta.env.DEV}
        <details class="mt-2">
          <summary class="text-sm cursor-pointer text-destructive/80 hover:text-destructive">
            Debug Info (Development Only)
          </summary>
          <div class="mt-2 p-3 bg-destructive/5 rounded text-xs font-mono">
            <div><strong>Current Step:</strong> {currentStep}</div>
            <div><strong>Token Present:</strong> {!!token}</div>
            <div><strong>API URL:</strong> {PUBLIC_API_URL || 'Not configured'}</div>
            {#if createdAssignment}
              <div><strong>Assignment ID:</strong> {createdAssignment.id}</div>
            {/if}
            <div><strong>Pattern:</strong> {JSON.stringify(usernamePattern, null, 2)}</div>
            <div><strong>Student Count:</strong> {studentCount}</div>
          </div>
        </details>
      {/if}
      
      <button
        onclick={handleRetry}
        class="text-destructive hover:underline text-sm font-medium mt-2 block"
      >
        Coba Lagi
      </button>
    </div>
  {/if}

  <!-- Progress Indicator - displays during credential generation -->
  {#if isGenerating}
    <ProgressIndicator current={generatedCredentials.length} total={studentCount} isActive={true} />
  {/if}

  <!-- Navigation Buttons -->
  <div class="flex justify-between gap-4">
    {#if currentStep > 1 && currentStep < 3}
      <button
        onclick={handleStepBack}
        disabled={isGenerating}
        class="px-6 py-2 bg-secondary hover:bg-secondary/80 disabled:opacity-50 rounded-lg font-medium transition-colors"
      >
        Kembali
      </button>
    {/if}

    {#if currentStep < 3}
      <button
        onclick={handleStepNext}
        disabled={isGenerating}
        class="px-6 py-2 bg-primary hover:bg-primary/90 disabled:opacity-50 text-primary-foreground rounded-lg font-medium transition-colors ml-auto"
      >
        {currentStep === 1 ? 'Buat Penugasan' : currentStep === 2 ? 'Buat Kredensial' : 'Selanjutnya'}
      </button>
    {/if}
  </div>
</div>
