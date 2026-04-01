mod auth;
mod content;
mod error;
mod logging;
mod proto;
mod services;
mod store;
mod youtube;

use tonic::transport::Server;
use tonic_health::server::health_reporter;
use tracing::{info, warn};

use content::PlatformContentResolver;
use logging::GrpcLoggingLayer;
use proto::{
    feed_service_server::FeedServiceServer,
    subscription_service_server::SubscriptionServiceServer,
};
use services::{FeedServiceImpl, SubscriptionServiceImpl};
use store::InMemoryStore;
use youtube::YouTubeClient;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenvy::dotenv().ok();

    let env_filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| "info".into());

    let use_json = std::env::var("LOG_FORMAT")
        .map(|v| v.eq_ignore_ascii_case("json"))
        .unwrap_or(false);

    if use_json {
        tracing_subscriber::fmt()
            .with_env_filter(env_filter)
            .json()
            .init();
    } else {
        tracing_subscriber::fmt()
            .with_env_filter(env_filter)
            .init();
    }

    let port: u16 = std::env::var("PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(50051);

    let addr = format!("0.0.0.0:{port}").parse()?;

    let (mut health_reporter, health_service) = health_reporter();
    health_reporter
        .set_service_status("", tonic_health::ServingStatus::Serving)
        .await;

    let youtube_client = match std::env::var("YOUTUBE_API_KEY") {
        Ok(key) if !key.is_empty() => {
            info!("YouTube Data API integration enabled");
            Some(YouTubeClient::new(key))
        }
        _ => {
            warn!("YOUTUBE_API_KEY not set; YouTube search and feed fetching will return empty results");
            None
        }
    };

    let content = PlatformContentResolver::new(youtube_client);
    let store = InMemoryStore::new();

    let subscription_svc = SubscriptionServiceServer::new(SubscriptionServiceImpl {
        store: store.clone(),
        content,
    });
    let feed_svc = FeedServiceServer::new(FeedServiceImpl { store });

    info!(%addr, "starting myfeed-api");

    Server::builder()
        .layer(GrpcLoggingLayer)
        .add_service(health_service)
        .add_service(subscription_svc)
        .add_service(feed_svc)
        .serve(addr)
        .await?;

    Ok(())
}
