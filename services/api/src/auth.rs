/// Check auth token in gRPC metadata.
///
/// In the dummy implementation the token is never verified — a single implicit
/// user is assumed. The check is enforced only when `REQUIRE_AUTH=1` is set,
/// in which case we require the header to be present (but still don't validate
/// its value). This allows exercising the client auth flow without real Firebase.
pub fn check_auth(metadata: &tonic::metadata::MetadataMap) -> Result<(), tonic::Status> {
    if std::env::var("REQUIRE_AUTH").as_deref() == Ok("1")
        && metadata.get("authorization").is_none()
    {
        return Err(tonic::Status::unauthenticated(
            "authorization header required",
        ));
    }
    Ok(())
}
