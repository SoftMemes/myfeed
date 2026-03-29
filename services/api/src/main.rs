use tonic::transport::Server;
use tonic_health::server::health_reporter;
use tracing::info;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "info".into()),
        )
        .json()
        .init();

    let port: u16 = std::env::var("PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(50051);

    let addr = format!("0.0.0.0:{port}").parse()?;

    let (mut health_reporter, health_service) = health_reporter();
    health_reporter.set_service_status("", tonic_health::ServingStatus::Serving).await;

    info!(%addr, "starting myfeed-api");

    Server::builder()
        .add_service(health_service)
        .serve(addr)
        .await?;

    Ok(())
}
