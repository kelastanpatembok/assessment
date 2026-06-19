export type TestModuleKey = 'disc' | 'holland' | 'papi' | 'cfit' | 'ist';

export interface TestModuleDefinition {
	key: TestModuleKey;
	label: string;
	description: string;
	questionPath: string;
	resultPath: string;
	route: string;
}

export const TEST_MODULES: TestModuleDefinition[] = [
	{
		key: 'disc',
		label: 'DISC',
		description: 'Modul kepribadian DISC untuk soal, hasil, dan pemakaian paket tes.',
		questionPath: '/disc/questions',
		resultPath: '/disc/results',
		route: '/test-modules/disc'
	},
	{
		key: 'holland',
		label: 'Holland RIASEC',
		description: 'Modul minat karier Holland untuk bank soal dan hasil RIASEC.',
		questionPath: '/holland/questions',
		resultPath: '/holland/results',
		route: '/test-modules/holland'
	},
	{
		key: 'papi',
		label: 'PAPI Kostick',
		description: 'Modul PAPI Kostick untuk pasangan soal, skor trait, dan hasil siswa.',
		questionPath: '/papi/questions',
		resultPath: '/papi/results',
		route: '/test-modules/papi'
	},
	{
		key: 'cfit',
		label: 'IQ CFIT',
		description: 'Modul IQ CFIT untuk subtes, skor total, dan hasil kecerdasan.',
		questionPath: '/cfit/questions',
		resultPath: '/cfit/results',
		route: '/test-modules/cfit'
	},
	{
		key: 'ist',
		label: 'IQ IST',
		description: 'Modul IQ IST untuk sembilan subtes, skor IQ, dan hasil siswa.',
		questionPath: '/ist/questions',
		resultPath: '/ist/results',
		route: '/test-modules/ist'
	}
];

export const TEST_MODULES_BY_KEY = Object.fromEntries(
	TEST_MODULES.map((module) => [module.key, module])
) as Record<TestModuleKey, TestModuleDefinition>;
