const base = 'https://assessment.jogjaitcamp.com';
const password = process.env.ASSESSMENT_ADMIN_PASSWORD;
if (!password) throw new Error('ASSESSMENT_ADMIN_PASSWORD is required');
const names = ['SMK TAMANSISWA JETIS','SMK KOPERASI YOGYAKARTA','SMK SMTI YOGYAKARTA','SMK BOPKRI 1 YOGYAKARTA','SMK MUHAMMADIYAH 1 YOGYAKARTA','SMK MAARIF 1 YOGYAKARTA','SMK PIRI 1 YOGYAKARTA','SMKN 1 BANTUL','SMKN 1 PANDAK','SMK KESEHATAN SADEWA','SMK YPKK 2 SLEMAN','SMK TRISULA 1 DEPOK','SMKN 2 PENGASIH','SMKN 1 KOKAP','SMK TJIPTA INSANI MULIA','SMA MUHAMMADIYAH 2 YOGYAKARTA','SMA STELLA DUCE 1 YOGYAKARTA','SMA STELLA DUCE 2 YOGYAKARTA','SMAN 1 BANTUL','SMAN 1 KRETEK','SMA MUHAMMADIYAH 1 PRAMBANAN','SMAN 1 SAMIGALUH','SMAIT ABU BAKAR BOARDING SCHOOL KULON PROGO','SMA MUHAMMADIYAH AL MUJAHIDIN WONOSARI','PKBM HSPG YOGYAKARTA','PKBM HOMESCHOOLING ENTREPRENEUR','HOMESCHOOLING ANAK PELANGI','HOMESCHOOLING BINA MULIA JOGJA'];
const places = {BANTUL:['Kab. Bantul','Prov. D.I. Yogyakarta'],PANDEK:['Kab. Bantul','Prov. D.I. Yogyakarta'],SLEMAN:['Kab. Sleman','Prov. D.I. Yogyakarta'],DEPOK:['Kab. Sleman','Prov. D.I. Yogyakarta'],PENGASIH:['Kab. Kulon Progo','Prov. D.I. Yogyakarta'],KOKAP:['Kab. Kulon Progo','Prov. D.I. Yogyakarta'],KULON:['Kab. Kulon Progo','Prov. D.I. Yogyakarta'],SAMIGALUH:['Kab. Kulon Progo','Prov. D.I. Yogyakarta'],WONOSARI:['Kab. Gunung Kidul','Prov. D.I. Yogyakarta'],YOGYAKARTA:['Kota Yogyakarta','Prov. D.I. Yogyakarta']};
const placeFor = n => Object.entries(places).find(([key]) => n.includes(key))?.[1] ?? ['Kota Yogyakarta','Prov. D.I. Yogyakarta'];
const request = (path, token, body) => fetch(base + path, {method:'POST',headers:{'content-type':'application/json',authorization:`Bearer ${token}`},body:JSON.stringify(body)});
const login = await fetch(base + '/api/auth/login', {method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({username:'admin',password})});
if (!login.ok) throw new Error(`admin login failed: ${login.status}`);
const { token } = await login.json();
let made = 0;
try {
  for (const [index, name] of names.entries()) {
    const [city, province] = placeFor(name);
    const schoolResponse = await request('/api/v1/schools', token, {name,city,province});
    let school;
    if (schoolResponse.ok) school = await schoolResponse.json();
    else if (schoolResponse.status === 409) {
      const found = await fetch(`${base}/api/v1/public/schools?search=${encodeURIComponent(name)}`).then(r => r.json());
      school = found.items?.[0];
      if (!school) throw new Error(`${name}: existing school could not be recovered`);
    } else throw new Error(`${name}: school ${schoolResponse.status}`);
    const assignmentResponse = await request('/api/v1/test-assignments', token, {schoolId:school.id,categoryId:1,startDate:'2026-08-27',endDate:'2026-12-31'});
    if (!assignmentResponse.ok) throw new Error(`${name}: assignment ${assignmentResponse.status}`);
    const assignment = await assignmentResponse.json();
    const count = index < 8 ? 3 : 2;
    const generated = await request('/api/v1/credentials/bulk-generate', token, {testAssignmentId:assignment.id,schoolCode:name.replace(/[^A-Z0-9]/g,'').slice(0,10),testCode:'PAKETLENGK',count});
    if (!generated.ok) throw new Error(`${name}: credential ${generated.status}`);
    made += (await generated.json()).count;
    console.log(JSON.stringify({name,count}));
  }
  console.log(JSON.stringify({createdSchools:names.length,createdCredentials:made}));
} finally { await fetch(base + '/api/auth/logout', {method:'POST',headers:{authorization:`Bearer ${token}`}}); }
