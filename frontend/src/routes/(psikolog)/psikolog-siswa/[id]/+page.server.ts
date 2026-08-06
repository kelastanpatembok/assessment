import { createApiClient } from '$lib/api/index';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, params }) => {
  const api = createApiClient(locals.token);
  const id = params.id;

  const [student, disc, holland, papi, cfit, ist, certificates] = await Promise.allSettled([
    api.get(`/students/${encodeURIComponent(id)}`),
    api.get(`/disc/results/${encodeURIComponent(id)}`),
    api.get(`/holland/results/${encodeURIComponent(id)}`),
    api.get(`/papi/results/${encodeURIComponent(id)}`),
    api.get(`/cfit/results/${encodeURIComponent(id)}`),
    api.get(`/ist/results/${encodeURIComponent(id)}`),
    api.get(`/certificates/${encodeURIComponent(id)}`),
  ]);

  if (student.status !== 'fulfilled') throw error(404, 'Peserta tidak ditemukan');

  return {
    student: student.value,
    disc: disc.status === 'fulfilled' ? disc.value : null,
    holland: holland.status === 'fulfilled' ? holland.value : null,
    papi: papi.status === 'fulfilled' ? papi.value : null,
    cfit: cfit.status === 'fulfilled' ? cfit.value : null,
    ist: ist.status === 'fulfilled' ? ist.value : null,
    certificates: certificates.status === 'fulfilled' && Array.isArray(certificates.value) ? certificates.value : [],
  };
};
