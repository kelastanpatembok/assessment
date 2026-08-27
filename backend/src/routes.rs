use axum::{
    http::{header::CONTENT_TYPE, HeaderValue},
    response::Response,
    routing::{delete, get, post, put},
    Router,
};
use tower_http::{
    cors::{AllowHeaders, AllowMethods, AllowOrigin, CorsLayer},
    limit::RequestBodyLimitLayer,
    trace::TraceLayer,
};

use crate::{handlers, state::AppState};

pub fn build_router(state: AppState) -> Router {
    let origins: Vec<_> = state
        .config
        .cors_allowed_origins
        .iter()
        .filter_map(|o| o.parse().ok())
        .collect();

    let cors = CorsLayer::new()
        .allow_origin(AllowOrigin::list(origins))
        .allow_methods(AllowMethods::list([
            axum::http::Method::GET,
            axum::http::Method::POST,
            axum::http::Method::PUT,
            axum::http::Method::DELETE,
            axum::http::Method::PATCH,
            axum::http::Method::OPTIONS,
            axum::http::Method::HEAD,
        ]))
        .allow_headers(AllowHeaders::mirror_request())
        .expose_headers([CONTENT_TYPE, axum::http::header::AUTHORIZATION])
        .allow_credentials(true)
        .max_age(std::time::Duration::from_secs(3600));

    let assignment_router = handlers::test_assignment::routes();
    let assignment2_router = handlers::test_assignment::routes();

    let api = Router::new()
        .route("/health", get(handlers::health::health))
        // ---- profile ----
        .route("/profile/provision", post(handlers::profile::provision))
        .route("/profile/me", get(handlers::profile::me))
        // ---- schools ----
        .route("/schools", get(handlers::school::list).post(handlers::school::create))
        .route("/schools/:id", get(handlers::school::get).put(handlers::school::update).delete(handlers::school::delete))
        .route("/schools/:id/pics", get(handlers::school_pic::list).post(handlers::school_pic::add))
        .route("/schools/:id/pics/:authUserId/primary", put(handlers::school_pic::set_primary))
        .route("/schools/:id/pics/:authUserId", delete(handlers::school_pic::remove))
        .route("/public/schools", get(handlers::school::public_search))
        // ---- users ----
        .route("/users", get(handlers::user::list).post(handlers::user::create))
        .route("/users/me", get(handlers::user::me))
        .route("/users/role/:role", get(handlers::user::by_role))
        .route("/users/school/:schoolId", get(handlers::user::by_school))
        .route("/users/:authUserId", put(handlers::user::update).delete(handlers::user::delete))
        // ---- students ----
        .route("/students", get(handlers::student::list).post(handlers::student::create_student))
        .route("/students/counselor", post(handlers::student::create_counselor))
        .route("/students/afiliator", post(handlers::student::create_afiliator))
        .route("/students/:authUserId", get(handlers::student::get).delete(handlers::student::delete))
        // ---- test categories ----
        .route("/test-categories", get(handlers::test_category::list).post(handlers::test_category::create))
        .route("/test-categories/:id", get(handlers::test_category::get).put(handlers::test_category::update).delete(handlers::test_category::delete))
        // ---- assignments (dual paths) ----
        .nest("/assignments", assignment_router)
        .nest("/test-assignments", assignment2_router)
        // ---- assignment summaries ----
        .route("/assignment-summaries", get(handlers::assignment_summary::list))
        .route("/assignment-summaries/summary", get(handlers::assignment_summary::summary))
        // ---- official school assessment reports ----
        .route("/assessment-reports", get(handlers::assessment_report::history))
        .route("/assessment-reports/preview/:assignmentId", get(handlers::assessment_report::preview))
        .route("/assessment-reports/send/:assignmentId", post(handlers::assessment_report::send))
        .route("/assessment-reports/:id/download", get(handlers::assessment_report::download))
        // Individual, role-scoped psychological reports.  The older school-wide
        // assessment-reports endpoints remain intact for historic deliveries.
        .route("/psychological-report-rules", get(handlers::psychological_report::rules).put(handlers::psychological_report::update_rules))
        .route("/psychological-reports/mine", get(handlers::psychological_report::mine))
        .route("/psychological-reports", get(handlers::psychological_report::list))
        .route("/psychological-reports/:assignmentId/:studentId", get(handlers::psychological_report::view))
        .route("/psychological-reports/:assignmentId/:studentId/download", get(handlers::psychological_report::download))
        // ---- role and school onboarding ----
        .route("/onboarding/access-requests", get(handlers::onboarding::my_access_requests).post(handlers::onboarding::create_access_request))
        .route("/admin/access-requests", get(handlers::onboarding::admin_access_requests))
        .route("/admin/access-requests/:id/approve", post(handlers::onboarding::approve_access_request))
        .route("/admin/access-requests/:id/reject", post(handlers::onboarding::reject_access_request))
        .route("/public/school-registration-requests", post(handlers::onboarding::create_school_registration))
        // ---- dashboard ----
        .route("/dashboard/summary", get(handlers::dashboard::summary))
        // ---- psikolog ----
        .route("/psikolog/search", get(handlers::psikolog::search))
        // ---- exams ----
        .route("/disc/questions", get(handlers::disc::questions))
        .route("/disc/check", get(handlers::disc::check))
        .route("/disc/submit", post(handlers::disc::submit))
        .route("/disc/result/me", get(handlers::disc::result_me))
        .route("/disc/results", get(handlers::disc::results))
        .route("/disc/results/:authUserId", get(handlers::disc::result_by_user))
        .route("/holland/questions", get(handlers::holland::questions))
        .route("/holland/check", get(handlers::holland::check))
        .route("/holland/submit", post(handlers::holland::submit))
        .route("/holland/result/me", get(handlers::holland::result_me))
        .route("/holland/results", get(handlers::holland::results))
        .route("/holland/results/:authUserId", get(handlers::holland::result_by_user))
        .route("/papi/questions", get(handlers::papi::questions))
        .route("/papi/check", get(handlers::papi::check))
        .route("/papi/submit", post(handlers::papi::submit))
        .route("/papi/result/me", get(handlers::papi::result_me))
        .route("/papi/results", get(handlers::papi::results))
        .route("/papi/results/:authUserId", get(handlers::papi::result_by_user))
        .route("/cfit/questions", get(handlers::cfit::questions))
        .route("/cfit/check", get(handlers::cfit::check))
        .route("/cfit/submit", post(handlers::cfit::submit))
        .route("/cfit/result/me", get(handlers::cfit::result_me))
        .route("/cfit/results", get(handlers::cfit::results))
        .route("/cfit/results/:authUserId", get(handlers::cfit::result_by_user))
        .route("/ist/questions", get(handlers::ist::questions))
        .route("/ist/check", get(handlers::ist::check))
        .route("/ist/submit", post(handlers::ist::submit))
        .route("/ist/result/me", get(handlers::ist::result_me))
        .route("/ist/results", get(handlers::ist::results))
        .route("/ist/results/:authUserId", get(handlers::ist::result_by_user))
        .route("/epps/questions", get(handlers::epps::questions))
        .route("/epps/check", get(handlers::epps::check))
        .route("/epps/submit", post(handlers::epps::submit))
        .route("/epps/result/me", get(handlers::epps::result_me))
        .route("/epps/results", get(handlers::epps::results))
        .route("/epps/results/:authUserId", get(handlers::epps::result_by_user))
        // ---- big5 (public funnel) ----
        .route("/big5/questions", get(handlers::big5::questions))
        .route("/big5/submit", post(handlers::big5::submit))
        .route("/big5/save", post(handlers::big5::save))
        .route("/big5/result/me", get(handlers::big5::result_me))
        // ---- fees ----
        .route("/fees/config", get(handlers::fee::config).put(handlers::fee::update_config))
        .route("/fees/my", get(handlers::fee::my))
        .route("/fees/summary/afiliator", get(handlers::fee::summary_afiliator))
        // ---- certificates ----
        .route("/certificates", post(handlers::certificate::create))
        .route("/certificates/mine", get(handlers::certificate::mine))
        .route("/certificates/:authUserId", get(handlers::certificate::for_student))
        .route("/certificates/:testType/:authUserId", get(handlers::certificate::test_certificate))
        // ---- credentials ----
        .route("/credentials/bulk-generate", post(handlers::credential::bulk_generate))
        .route("/credentials/batches", get(handlers::credential::batches))
        .route("/credentials/batches/:id/download", get(handlers::credential::download))
        .route("/credentials/batches/:id", delete(handlers::credential::delete))
        // ---- dev tools ----
        .route("/dev/results/:testKey", delete(handlers::devtools::clear_result))
        .layer(RequestBodyLimitLayer::new(20 * 1024 * 1024))
        .layer(axum::middleware::map_response(security_headers))
        .with_state(state.clone());

    // Mirrors the Java server.servlet.context-path: /api.
    Router::new()
        .nest("/api", api)
        .layer(cors)
        .layer(TraceLayer::new_for_http())
}

async fn security_headers(mut response: Response) -> Response {
    let headers = response.headers_mut();
    headers.insert("x-content-type-options", HeaderValue::from_static("nosniff"));
    headers.insert("x-frame-options", HeaderValue::from_static("DENY"));
    headers.insert("x-xss-protection", HeaderValue::from_static("0"));
    headers.insert("referrer-policy", HeaderValue::from_static("no-referrer"));
    headers.insert("cache-control", HeaderValue::from_static("no-cache, no-store, max-age=0, must-revalidate"));
    headers.insert("pragma", HeaderValue::from_static("no-cache"));
    response
}
