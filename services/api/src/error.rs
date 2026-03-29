use std::collections::HashMap;
use tonic::Code;
use tonic_types::{ErrorDetails, StatusExt};

const DOMAIN: &str = "myfeed.softmemes.com";

fn with_error_info(code: Code, message: &str, reason: &str) -> tonic::Status {
    let details = ErrorDetails::with_error_info(reason, DOMAIN, HashMap::new());
    tonic::Status::with_error_details(code, message, details)
}

pub fn not_found(reason: &str, message: &str) -> tonic::Status {
    with_error_info(Code::NotFound, message, reason)
}

pub fn already_exists(reason: &str, message: &str) -> tonic::Status {
    with_error_info(Code::AlreadyExists, message, reason)
}

pub fn invalid_argument(reason: &str, message: &str) -> tonic::Status {
    with_error_info(Code::InvalidArgument, message, reason)
}

pub fn required_field(field: &str) -> tonic::Status {
    invalid_argument("MISSING_FIELD", &format!("required field missing: {field}"))
}

pub fn invalid_page_token() -> tonic::Status {
    invalid_argument("INVALID_PAGE_TOKEN", "invalid or malformed page token")
}
