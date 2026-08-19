// Canonical assessment methods (the "metode" selectable when assigning tests).
// Keep in display order; labels match assignment-modules TEST_LABELS.
export const TEST_METHODS: { key: string; label: string }[] = [
	{ key: 'disc', label: 'DISC' },
	{ key: 'holland', label: 'Holland RIASEC' },
	{ key: 'papi', label: 'PAPI Kostick' },
	{ key: 'cfit', label: 'IQ CFIT' },
	{ key: 'ist', label: 'IQ IST' },
	{ key: 'epps', label: 'EPPS' }
];

export const TEST_METHOD_LABELS: Record<string, string> = Object.fromEntries(
	TEST_METHODS.map((m) => [m.key, m.label])
);

export function methodLabel(key: string): string {
	return TEST_METHOD_LABELS[key] ?? key.toUpperCase();
}
