/**
 * CSV Export Utility
 * 
 * Handles RFC 4180 compliant CSV generation and browser download functionality.
 * Includes UTF-8 BOM for Excel compatibility and proper field escaping.
 */

export interface Credential {
  username: string;
  password: string;
  schoolName?: string;
  testCategory?: string;
  createdAt?: string;
}

/**
 * Escapes a CSV field value according to RFC 4180
 * - If field contains comma, quote, or newline, wrap in quotes
 * - Double any quotes within the field
 * 
 * @param value - The raw field value
 * @returns The escaped field value
 */
export function escapeCSV(value: string): string {
  if (!value) {
    return '';
  }

  // Check if field needs escaping
  if (value.includes(',') || value.includes('"') || value.includes('\n') || value.includes('\r')) {
    // Escape quotes by doubling them
    const escaped = value.replace(/"/g, '""');
    // Wrap in quotes
    return `"${escaped}"`;
  }

  return value;
}

/**
 * Generates a CSV string from credentials with RFC 4180 compliance
 * 
 * @param credentials - Array of credential objects
 * @param schoolName - School name for the export
 * @param testCategory - Test category for the export
 * @returns RFC 4180 compliant CSV string (without BOM)
 */
export function generateCSV(
  credentials: Credential[],
  schoolName: string,
  testCategory: string
): string {
  // CSV headers as specified in requirements
  const headers = ['username', 'password', 'school_name', 'test_category', 'created_date'];

  // Convert credentials to CSV rows
  const rows = credentials.map((credential) => [
    escapeCSV(credential.username),
    escapeCSV(credential.password),
    escapeCSV(schoolName),
    escapeCSV(testCategory),
    escapeCSV(formatDate(credential.createdAt))
  ]);

  // Join all rows with newlines, including header row
  const csvContent = [headers, ...rows]
    .map((row) => row.join(','))
    .join('\n');

  return csvContent;
}

/**
 * Formats a date to ISO8601 date format (YYYY-MM-DD)
 * 
 * @param dateString - ISO8601 timestamp or date string
 * @returns Formatted date string in YYYY-MM-DD format
 */
function formatDate(dateString?: string): string {
  if (!dateString) {
    return new Date().toISOString().split('T')[0];
  }

  try {
    const date = new Date(dateString);
    return date.toISOString().split('T')[0];
  } catch {
    return dateString;
  }
}

/**
 * Generates a filename for CSV export
 * Pattern: credentials_{schoolCode}_{testCode}_{ISO8601-timestamp}.csv
 * 
 * @param schoolCode - School code identifier
 * @param testCode - Test code identifier
 * @returns Generated filename
 */
export function generateFilename(schoolCode: string, testCode: string): string {
  const now = new Date();
  const timestamp = now.toISOString().replace(/[:.]/g, '-').slice(0, -5); // e.g., 2024-01-15T10-30-45
  return `credentials_${schoolCode}_${testCode}_${timestamp}.csv`;
}

/**
 * Creates a Blob with UTF-8 BOM and CSV content
 * The BOM (Byte Order Mark) ensures Excel recognizes the file as UTF-8
 * 
 * @param csvContent - The CSV string content
 * @returns Blob with BOM prepended
 */
export function createCSVBlob(csvContent: string): Blob {
  // UTF-8 BOM
  const BOM = '\uFEFF';

  // Combine BOM and CSV content
  const csvWithBOM = BOM + csvContent;

  // Create Blob with UTF-8 encoding and BOM
  return new Blob([csvWithBOM], { type: 'text/csv;charset=utf-8' });
}

/**
 * Triggers a browser download of a Blob
 * 
 * @param blob - The Blob to download
 * @param filename - The filename for the downloaded file
 */
export function triggerDownload(blob: Blob, filename: string): void {
  // Create a temporary URL for the blob
  const url = URL.createObjectURL(blob);

  // Create a temporary anchor element
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.style.display = 'none';

  // Append to DOM, click, and remove
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  // Clean up the URL object
  URL.revokeObjectURL(url);
}

/**
 * Main export function that orchestrates CSV generation and download
 * 
 * @param credentials - Array of credentials to export
 * @param schoolName - School name
 * @param testCategory - Test category
 * @param schoolCode - School code for filename
 * @param testCode - Test code for filename
 */
export function downloadCSV(
  credentials: Credential[],
  schoolName: string,
  testCategory: string,
  schoolCode: string,
  testCode: string
): void {
  // Generate CSV content
  const csvContent = generateCSV(credentials, schoolName, testCategory);

  // Create Blob with UTF-8 BOM
  const blob = createCSVBlob(csvContent);

  // Generate filename
  const filename = generateFilename(schoolCode, testCode);

  // Trigger download
  triggerDownload(blob, filename);
}
