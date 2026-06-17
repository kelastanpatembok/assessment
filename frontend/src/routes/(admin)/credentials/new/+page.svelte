<script lang="ts">
  import { createApiClient } from '$lib/api/index';
  import { TestAssignmentSelector, ProgressIndicator } from '$lib/components/wizard';

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

  let currentStep = $state(1); // 1 = select assignment, 2 = configure, 3 = display
  let selectedAssignment = $state<TestAssignment | null>(null);
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

  // Initialize API client when component mounts
  $effect(() => {
    // Token would be set via server-side auth context or props
    // This can be accessed from locals.token in the page load
  });

  // ==================== Step Navigation Logic ====================

  /**
   * Handles progression to next step with validation
   * - Step 1: Requires assignment selection
   * - Step 2: Requires pattern validation and student count
   * - Step 3: Display phase (no progression)
   */
  function handleStepNext() {
    switch (currentStep) {
      case 1:
        if (!selectedAssignment) {
          error = 'Pilih penugasan tes untuk melanjutkan';
          return;
        }
        error = null;
        currentStep = 2;
        // Pre-fill pattern with defaults from assignment
        if (!usernamePattern.schoolCode) {
          usernamePattern.schoolCode = deriveSchoolCode(selectedAssignment.school.name);
        }
        if (!usernamePattern.testCode) {
          usernamePattern.testCode = selectedAssignment.category.slug.substring(0, 10).toUpperCase();
        }
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
    if (!selectedAssignment) return;

    isGenerating = true;
    error = null;

    try {
      // Create API client for this request
      // In task 5.8, token will be available from page context
      const api = createApiClient(token);

      const response = await api.post('/api/credentials/bulk-generate', {
        testAssignmentId: selectedAssignment.id,
        schoolCode: usernamePattern.schoolCode,
        testCode: usernamePattern.testCode,
        count: studentCount,
      });

      if (response && response.credentials) {
        generatedCredentials = response.credentials;
        currentStep = 3;
      } else {
        error = 'Respons server tidak valid';
      }
    } catch (e) {
      const errorMessage = e instanceof Error ? e.message : 'Terjadi kesalahan saat membuat kredensial';
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

  <!-- Step Indicator - to be implemented in task 5.3 -->
  <div class="bg-muted rounded-lg p-3 text-center text-sm">
    <p>Langkah {currentStep} dari 3</p>
  </div>

  <!-- Step 1: Test Assignment Selection -->
  {#if currentStep === 1}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <h3 class="mb-4 text-lg font-semibold">Pilih Penugasan Tes</h3>
      <TestAssignmentSelector 
        assignments={data.assignments}
        bind:selected={selectedAssignment}
      />
    </div>
  {/if}

  <!-- Step 2: Configure Username Pattern & Student Count -->
  {#if currentStep === 2}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <h3 class="mb-4 text-lg font-semibold">Konfigurasi Pola Username</h3>
      <!-- UsernamePatternConfig component will be implemented in task 5.5 -->
      <p class="text-muted-foreground text-sm mb-4">
        Pola username saat ini: <code>{usernamePattern.preview || 'Belum dikonfigurasi'}</code>
      </p>
      <p class="text-muted-foreground text-sm">
        Jumlah siswa: {studentCount}
      </p>
    </div>
  {/if}

  <!-- Step 3: Display Generated Credentials -->
  {#if currentStep === 3}
    <div class="bg-card border-border rounded-xl border p-6 shadow-sm">
      <h3 class="mb-4 text-lg font-semibold">Kredensial yang Dihasilkan</h3>
      <!-- CredentialDisplay component will be implemented in task 5.6 -->
      {#if generatedCredentials.length > 0}
        <p class="text-muted-foreground text-sm">
          Berhasil membuat {generatedCredentials.length} kredensial
        </p>
      {/if}
    </div>
  {/if}

  <!-- Error Display with Retry -->
  {#if error}
    <div class="bg-destructive/10 border-destructive rounded-lg border p-4">
      <p class="text-destructive font-medium mb-2">{error}</p>
      <button
        onclick={handleRetry}
        class="text-destructive hover:underline text-sm font-medium"
      >
        Coba Lagi
      </button>
    </div>
  {/if}

  <!-- Progress Indicator - displays during credential generation -->
  {#if isGenerating}
    <ProgressIndicator current={0} total={studentCount} isActive={true} />
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
        {currentStep === 2 ? 'Buat Kredensial' : 'Selanjutnya'}
      </button>
    {/if}
  </div>
</div>
