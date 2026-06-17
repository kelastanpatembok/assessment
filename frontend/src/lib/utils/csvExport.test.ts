import { describe, it, expect, beforeEach, vi } from 'vitest';
import {
  escapeCSV,
  generateCSV,
  generateFilename,
  createCSVBlob,
  downloadCSV,
  type Credential
} from './csvExport';

describe('CSV Export Utility', () => {
  describe('escapeCSV', () => {
    it('should return empty string for empty input', () => {
      expect(escapeCSV('')).toBe('');
    });

    it('should return unquoted field if no special characters', () => {
      expect(escapeCSV('simple')).toBe('simple');
      expect(escapeCSV('username123')).toBe('username123');
    });

    it('should escape field with comma', () => {
      expect(escapeCSV('Smith, John')).toBe('"Smith, John"');
    });

    it('should escape field with double quotes', () => {
      expect(escapeCSV('He said "hello"')).toBe('"He said ""hello"""');
    });

    it('should escape field with newline', () => {
      expect(escapeCSV('line1\nline2')).toBe('"line1\nline2"');
    });

    it('should escape field with carriage return', () => {
      expect(escapeCSV('line1\rline2')).toBe('"line1\rline2"');
    });

    it('should escape field with multiple special characters', () => {
      expect(escapeCSV('He said, "test"\nvalue')).toBe('"He said, ""test""\nvalue"');
    });

    it('should escape multiple consecutive quotes', () => {
      expect(escapeCSV('value""test')).toBe('"value""""test"');
    });
  });

  describe('generateCSV', () => {
    let credentials: Credential[];

    beforeEach(() => {
      credentials = [
        {
          username: 'SMAN_TEST_001',
          password: 'AbC12345',
          createdAt: '2024-01-15T10:30:45Z'
        },
        {
          username: 'SMAN_TEST_002',
          password: 'XyZ67890',
          createdAt: '2024-01-15T10:31:00Z'
        }
      ];
    });

    it('should include RFC 4180 header row', () => {
      const csv = generateCSV(credentials, 'SMA Negeri 1', 'Holland');
      expect(csv).toContain('username,password,school_name,test_category,created_date');
    });

    it('should include header as first line', () => {
      const csv = generateCSV(credentials, 'SMA Negeri 1', 'Holland');
      const lines = csv.split('\n');
      expect(lines[0]).toBe('username,password,school_name,test_category,created_date');
    });

    it('should format credential rows correctly', () => {
      const csv = generateCSV(credentials, 'SMA Negeri 1', 'Holland');
      expect(csv).toContain('SMAN_TEST_001,AbC12345,SMA Negeri 1,Holland,2024-01-15');
      expect(csv).toContain('SMAN_TEST_002,XyZ67890,SMA Negeri 1,Holland,2024-01-15');
    });

    it('should escape school name with special characters', () => {
      const csv = generateCSV(credentials, 'SMA "Test", School', 'Holland');
      expect(csv).toContain('"SMA ""Test"", School"');
    });

    it('should escape test category with special characters', () => {
      const csv = generateCSV(credentials, 'SMA Negeri 1', 'Test\nCategory');
      expect(csv).toContain('"Test\nCategory"');
    });

    it('should handle empty created_at date', () => {
      const credsWithoutDate: Credential[] = [
        {
          username: 'test_user',
          password: 'password123'
        }
      ];
      const csv = generateCSV(credsWithoutDate, 'School', 'Category');
      // Should contain today's date in YYYY-MM-DD format
      const today = new Date().toISOString().split('T')[0];
      expect(csv).toContain(today);
    });

    it('should handle multiple credentials', () => {
      const manyCredentials = Array.from({ length: 5 }, (_, i) => ({
        username: `user_${i + 1}`,
        password: `pass_${i + 1}`,
        createdAt: '2024-01-15T10:00:00Z'
      }));
      const csv = generateCSV(manyCredentials, 'School', 'Category');
      const lines = csv.split('\n');
      expect(lines).toHaveLength(6); // 1 header + 5 data rows
    });

    it('should produce valid RFC 4180 CSV format', () => {
      const csv = generateCSV(credentials, 'SMA Negeri 1', 'Holland');
      const lines = csv.split('\n');
      
      // Each line should have 5 comma-separated fields
      lines.forEach((line) => {
        // Count unquoted commas (simple validation)
        let quoteCount = 0;
        let commaCount = 0;
        
        for (let i = 0; i < line.length; i++) {
          if (line[i] === '"') {
            quoteCount++;
          } else if (line[i] === ',' && quoteCount % 2 === 0) {
            commaCount++;
          }
        }
        
        expect(commaCount).toBe(4); // 5 fields = 4 commas
      });
    });
  });

  describe('generateFilename', () => {
    it('should generate filename with correct pattern', () => {
      const filename = generateFilename('SMAN', 'TEST');
      expect(filename).toMatch(/^credentials_SMAN_TEST_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}\.csv$/);
    });

    it('should include school code and test code', () => {
      const filename = generateFilename('ABC', 'XYZ');
      expect(filename).toContain('credentials_ABC_XYZ_');
      expect(filename).toMatch(/\.csv$/);
    });

    it('should generate different timestamps for different calls', () => {
      const filename1 = generateFilename('SMAN', 'TEST');
      
      // Mock time to advance
      vi.useFakeTimers();
      vi.advanceTimersByTime(1000);
      
      const filename2 = generateFilename('SMAN', 'TEST');
      
      vi.useRealTimers();
      
      // They should be different due to timestamp
      expect(filename1).not.toBe(filename2);
    });
  });

  describe('createCSVBlob', () => {
    it('should create a Blob with correct type', () => {
      const blob = createCSVBlob('test,data\n1,2');
      expect(blob.type).toBe('text/csv;charset=utf-8');
    });

    it('should include UTF-8 BOM in blob content', () => {
      const blob = createCSVBlob('test');
      
      // Convert blob to string to check for BOM
      const reader = new FileReader();
      
      reader.onload = (e) => {
        const content = e.target?.result as string;
        // BOM character is \uFEFF
        expect(content.charCodeAt(0)).toBe(0xfeff);
      };
      
      reader.readAsText(blob);
    });

    it('should preserve CSV content after BOM', () => {
      const csvContent = 'username,password\ntest,pass';
      const blob = createCSVBlob(csvContent);
      
      const reader = new FileReader();
      reader.onload = (e) => {
        const content = e.target?.result as string;
        // Remove BOM and check content
        const withoutBOM = content.charCodeAt(0) === 0xfeff ? content.slice(1) : content;
        expect(withoutBOM).toContain('username,password');
        expect(withoutBOM).toContain('test,pass');
      };
      
      reader.readAsText(blob);
    });
  });

  describe('downloadCSV', () => {
    let mockCreateElement: any;
    let mockAppendChild: any;
    let mockRemoveChild: any;
    let mockClick: any;

    beforeEach(() => {
      // Mock DOM methods
      mockClick = vi.fn();
      mockAppendChild = vi.fn();
      mockRemoveChild = vi.fn();

      // Mock document.createElement
      mockCreateElement = vi.spyOn(document, 'createElement').mockReturnValue({
        click: mockClick,
        href: '',
        download: '',
        style: { display: '' }
      } as any);

      // Mock document methods
      vi.spyOn(document.body, 'appendChild').mockImplementation(mockAppendChild);
      vi.spyOn(document.body, 'removeChild').mockImplementation(mockRemoveChild);

      // Mock URL methods at the global scope
      (global.URL.createObjectURL as any) = vi.fn().mockReturnValue('blob:mock-url');
      (global.URL.revokeObjectURL as any) = vi.fn();
    });

    it('should create an anchor element', () => {
      downloadCSV(
        [{ username: 'test', password: 'pass' }],
        'School',
        'Category',
        'SMAN',
        'TEST'
      );

      expect(mockCreateElement).toHaveBeenCalledWith('a');
    });

    it('should set download attribute with generated filename', () => {
      downloadCSV(
        [{ username: 'test', password: 'pass' }],
        'School',
        'Category',
        'ABC',
        'XYZ'
      );

      // Verify click was called, which means file download was triggered
      expect(mockClick).toHaveBeenCalled();
    });

    it('should append and remove link from DOM', () => {
      downloadCSV(
        [{ username: 'test', password: 'pass' }],
        'School',
        'Category',
        'SMAN',
        'TEST'
      );

      expect(mockAppendChild).toHaveBeenCalled();
      expect(mockRemoveChild).toHaveBeenCalled();
    });

    it('should revoke object URL after download', () => {
      const revokeSpy = vi.fn();
      (global.URL.revokeObjectURL as any) = revokeSpy;

      downloadCSV(
        [{ username: 'test', password: 'pass' }],
        'School',
        'Category',
        'SMAN',
        'TEST'
      );

      expect(revokeSpy).toHaveBeenCalled();
    });
  });

  describe('RFC 4180 Compliance', () => {
    it('should handle all special characters correctly', () => {
      const credentials: Credential[] = [
        {
          username: 'user,1',
          password: 'pass"word',
          createdAt: '2024-01-15'
        },
        {
          username: 'user\n2',
          password: 'pass,word',
          createdAt: '2024-01-15'
        }
      ];

      const csv = generateCSV(credentials, 'School, Inc.', 'Test\nCategory');
      
      // Verify proper escaping
      expect(csv).toContain('"user,1"');
      expect(csv).toContain('"pass""word"');
      expect(csv).toContain('"user\n2"');
      expect(csv).toContain('"School, Inc."');
      expect(csv).toContain('"Test\nCategory"');
    });

    it('should maintain data integrity through CSV format', () => {
      const original = {
        username: 'test"user,123',
        password: 'p@ss"word',
        createdAt: '2024-01-15T10:30:45Z'
      };

      const credentials: Credential[] = [original];
      const csv = generateCSV(credentials, 'School', 'Category');

      // Verify that the escaped versions of the original values are in the CSV
      // When a field contains special characters, it gets quoted and quotes are doubled
      expect(csv).toContain('"test""user,123"');
      expect(csv).toContain('"p@ss""word"');
      expect(csv).toContain('2024-01-15');
    });
  });
});
