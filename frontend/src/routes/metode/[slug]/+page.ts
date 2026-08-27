import { error } from '@sveltejs/kit';
import { METHODS } from '$lib/methods';
export const load = ({ params }) => { const method=METHODS[params.slug]; if(!method) error(404,'Metode tidak ditemukan'); return { method }; };
