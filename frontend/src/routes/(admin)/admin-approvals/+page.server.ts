import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
export const load: PageServerLoad = async ({ locals }) => ({ requests: (await createApiClient(locals.token).get('/admin/access-requests?status=pending')).items ?? [] });
export const actions: Actions = {
  approve: async ({ request, locals }) => { const d=await request.formData(); try { await createApiClient(locals.token).post(`/admin/access-requests/${d.get('id')}/approve`, { note: String(d.get('note') ?? '') }); return { ok:true }; } catch(e){return fail(400,{error:e instanceof Error?e.message:'Gagal menyetujui'});} },
  reject: async ({ request, locals }) => { const d=await request.formData(); try { await createApiClient(locals.token).post(`/admin/access-requests/${d.get('id')}/reject`, { note: String(d.get('note') ?? '') }); return { ok:true }; } catch(e){return fail(400,{error:e instanceof Error?e.message:'Gagal menolak'});} }
};
