use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::Row;

use crate::{auth_extractor::AuthUser, error::{AppError, AppResult}, state::AppState};

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccessRequestInput { pub requester_name: String, pub requester_email: String, pub requested_role: String, pub school_id: Option<i64>, pub note: Option<String> }
#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReviewInput { pub note: Option<String> }
#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SchoolRegistrationInput { pub contact_name: String, pub contact_email: String, pub school_name: String, pub npsn: Option<String>, pub address: Option<String>, pub city: Option<String>, pub province: Option<String>, pub phone: Option<String>, pub note: Option<String> }
#[derive(Deserialize)] pub struct StatusQuery { pub status: Option<String> }

pub async fn create_access_request(State(state): State<AppState>, auth: AuthUser, Json(input): Json<AccessRequestInput>) -> AppResult<(StatusCode, Json<serde_json::Value>)> {
    let role = input.requested_role.trim().to_lowercase();
    if !matches!(role.as_str(), "siswa" | "gurubk" | "psikolog") { return Err(AppError::BadRequest("Peran pengajuan tidak valid".into())); }
    if input.requester_name.trim().is_empty() || input.requester_email.trim().is_empty() { return Err(AppError::BadRequest("Nama dan email harus diisi".into())); }
    if role == "psikolog" && input.school_id.is_some() { return Err(AppError::BadRequest("Pengajuan psikolog tidak terkait satu sekolah".into())); }
    if role != "psikolog" { let id=input.school_id.ok_or_else(|| AppError::BadRequest("Sekolah harus dipilih".into()))?; let exists:bool=sqlx::query_scalar("SELECT EXISTS(SELECT 1 FROM schools WHERE id=$1)").bind(id).fetch_one(&state.pool).await.map_err(|e|AppError::from_sqlx("request_school",e))?; if !exists{return Err(AppError::NotFound("Sekolah tidak ditemukan".into()));} }
    let row=sqlx::query("INSERT INTO access_requests(auth_user_id,requester_name,requester_email,requested_role,school_id,note) VALUES($1,$2,$3,$4,$5,$6) RETURNING id,status,created_at")
        .bind(&auth.user_id).bind(input.requester_name.trim()).bind(input.requester_email.trim().to_lowercase()).bind(&role).bind(input.school_id).bind(input.note.as_deref().map(str::trim)).fetch_one(&state.pool).await.map_err(|e|AppError::from_sqlx("create_access_request",e))?;
    Ok((StatusCode::CREATED,Json(serde_json::json!({"id":row.get::<i64,_>("id"),"status":row.get::<String,_>("status"),"createdAt":row.get::<chrono::NaiveDateTime,_>("created_at")}))))
}

pub async fn my_access_requests(State(state): State<AppState>, auth: AuthUser) -> AppResult<Json<serde_json::Value>> { Ok(Json(serde_json::json!({"items":list_requests(&state,Some(&auth.user_id),None).await?}))) }
pub async fn admin_access_requests(State(state): State<AppState>, auth: AuthUser, Query(q): Query<StatusQuery>) -> AppResult<Json<serde_json::Value>> { auth.require_role(&["SUPERADMIN"])?; Ok(Json(serde_json::json!({"items":list_requests(&state,None,q.status.as_deref()).await?}))) }

async fn list_requests(state:&AppState, user:Option<&str>, status:Option<&str>)->AppResult<Vec<serde_json::Value>>{
    let rows=match (user,status) {
      (Some(uid),_)=>sqlx::query("SELECT r.id,r.requester_name,r.requester_email,r.requested_role,r.school_id,s.name school_name,r.note,r.status,r.review_note,r.created_at,r.reviewed_at FROM access_requests r LEFT JOIN schools s ON s.id=r.school_id WHERE r.auth_user_id=$1 ORDER BY r.created_at DESC").bind(uid).fetch_all(&state.pool).await,
      (None,Some(st))=>sqlx::query("SELECT r.id,r.requester_name,r.requester_email,r.requested_role,r.school_id,s.name school_name,r.note,r.status,r.review_note,r.created_at,r.reviewed_at FROM access_requests r LEFT JOIN schools s ON s.id=r.school_id WHERE r.status=$1 ORDER BY r.created_at ASC").bind(st).fetch_all(&state.pool).await,
      _=>sqlx::query("SELECT r.id,r.requester_name,r.requester_email,r.requested_role,r.school_id,s.name school_name,r.note,r.status,r.review_note,r.created_at,r.reviewed_at FROM access_requests r LEFT JOIN schools s ON s.id=r.school_id ORDER BY r.created_at ASC").fetch_all(&state.pool).await,
    }.map_err(|e|AppError::from_sqlx("list_access_requests",e))?;
    Ok(rows.into_iter().map(|r|serde_json::json!({"id":r.get::<i64,_>("id"),"requesterName":r.get::<String,_>("requester_name"),"requesterEmail":r.get::<String,_>("requester_email"),"requestedRole":r.get::<String,_>("requested_role"),"schoolId":r.get::<Option<i64>,_>("school_id"),"schoolName":r.get::<Option<String>,_>("school_name"),"note":r.get::<Option<String>,_>("note"),"status":r.get::<String,_>("status"),"reviewNote":r.get::<Option<String>,_>("review_note"),"createdAt":r.get::<chrono::NaiveDateTime,_>("created_at"),"reviewedAt":r.get::<Option<chrono::NaiveDateTime>,_>("reviewed_at")})).collect())
}

pub async fn approve_access_request(State(state):State<AppState>,auth:AuthUser,Path(id):Path<i64>,Json(input):Json<ReviewInput>)->AppResult<Json<serde_json::Value>>{
 auth.require_role(&["SUPERADMIN"])?; let r=sqlx::query("SELECT auth_user_id,requester_name,requester_email,requested_role,school_id,status FROM access_requests WHERE id=$1 FOR UPDATE").bind(id).fetch_optional(&state.pool).await.map_err(|e|AppError::from_sqlx("access_request",e))?.ok_or_else(||AppError::NotFound("Pengajuan tidak ditemukan".into()))?;
 if r.get::<String,_>("status")!="pending" {return Err(AppError::Conflict("Pengajuan sudah ditinjau".into()));} let uid:String=r.get("auth_user_id");let role:String=r.get("requested_role");let school:Option<i64>=r.get("school_id");
 state.auth.replace_roles_as_superadmin(&auth.token,&uid,&[role.clone()]).await.map_err(AppError::Internal)?;
 sqlx::query("INSERT INTO assessment_users(auth_user_id,name,email,username,role,school_id,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$6,NOW(),NOW()) ON CONFLICT(auth_user_id) DO UPDATE SET name=EXCLUDED.name,email=EXCLUDED.email,role=EXCLUDED.role,school_id=EXCLUDED.school_id,updated_at=NOW()").bind(&uid).bind(r.get::<String,_>("requester_name")).bind(r.get::<String,_>("requester_email")).bind(r.get::<String,_>("requester_email")).bind(&role).bind(school).execute(&state.pool).await.map_err(|e|AppError::from_sqlx("provision_approved_request",e))?;
 sqlx::query("UPDATE access_requests SET status='approved',reviewed_by=$2,review_note=$3,reviewed_at=NOW(),updated_at=NOW() WHERE id=$1").bind(id).bind(&auth.user_id).bind(input.note.as_deref()).execute(&state.pool).await.map_err(|e|AppError::from_sqlx("approve_access_request",e))?;
 Ok(Json(serde_json::json!({"approved":true,"reauthRequired":true})))
}
pub async fn reject_access_request(State(state):State<AppState>,auth:AuthUser,Path(id):Path<i64>,Json(input):Json<ReviewInput>)->AppResult<Json<serde_json::Value>>{auth.require_role(&["SUPERADMIN"])?;let result=sqlx::query("UPDATE access_requests SET status='rejected',reviewed_by=$2,review_note=$3,reviewed_at=NOW(),updated_at=NOW() WHERE id=$1 AND status='pending'").bind(id).bind(&auth.user_id).bind(input.note.as_deref()).execute(&state.pool).await.map_err(|e|AppError::from_sqlx("reject_access_request",e))?;if result.rows_affected()==0{return Err(AppError::Conflict("Pengajuan tidak tersedia untuk ditolak".into()));}Ok(Json(serde_json::json!({"rejected":true})))}

pub async fn create_school_registration(State(state):State<AppState>,auth:Option<AuthUser>,Json(input):Json<SchoolRegistrationInput>)->AppResult<(StatusCode,Json<serde_json::Value>)>{
 if input.contact_name.trim().is_empty()||input.contact_email.trim().is_empty()||input.school_name.trim().is_empty(){return Err(AppError::BadRequest("Nama kontak, email, dan nama sekolah harus diisi".into()));}
 if let Some(npsn)=input.npsn.as_deref(){let exists:bool=sqlx::query_scalar("SELECT EXISTS(SELECT 1 FROM schools WHERE npsn=$1)").bind(npsn.trim()).fetch_one(&state.pool).await.map_err(|e|AppError::from_sqlx("check_school_npsn",e))?;if exists{return Err(AppError::Conflict("Sekolah dengan NPSN tersebut sudah terdaftar".into()));}}
 let row=sqlx::query("INSERT INTO school_registration_requests(requester_auth_user_id,contact_name,contact_email,school_name,npsn,address,city,province,phone,note) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING id,status").bind(auth.map(|a|a.user_id)).bind(input.contact_name.trim()).bind(input.contact_email.trim().to_lowercase()).bind(input.school_name.trim()).bind(input.npsn.as_deref().map(str::trim)).bind(input.address.as_deref()).bind(input.city.as_deref()).bind(input.province.as_deref()).bind(input.phone.as_deref()).bind(input.note.as_deref()).fetch_one(&state.pool).await.map_err(|e|AppError::from_sqlx("create_school_registration",e))?;Ok((StatusCode::CREATED,Json(serde_json::json!({"id":row.get::<i64,_>("id"),"status":row.get::<String,_>("status")}))))
}
