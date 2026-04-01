use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::Instant;

use http::{Request, Response};
use tower::{Layer, Service};
use tracing::{info, warn};

#[derive(Clone)]
pub struct GrpcLoggingLayer;

impl<S> Layer<S> for GrpcLoggingLayer {
    type Service = GrpcLoggingService<S>;

    fn layer(&self, inner: S) -> Self::Service {
        GrpcLoggingService { inner }
    }
}

#[derive(Clone)]
pub struct GrpcLoggingService<S> {
    inner: S,
}

type BoxFuture<'a, T> = Pin<Box<dyn Future<Output = T> + Send + 'a>>;

impl<S, ReqBody, ResBody> Service<Request<ReqBody>> for GrpcLoggingService<S>
where
    S: Service<Request<ReqBody>, Response = Response<ResBody>> + Clone + Send + 'static,
    S::Future: Send + 'static,
    S::Error: std::fmt::Display,
    ReqBody: Send + 'static,
{
    type Response = S::Response;
    type Error = S::Error;
    type Future = BoxFuture<'static, Result<Self::Response, Self::Error>>;

    fn poll_ready(&mut self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.inner.poll_ready(cx)
    }

    fn call(&mut self, req: Request<ReqBody>) -> Self::Future {
        let method = req.uri().path().to_owned();
        let start = Instant::now();

        info!(method = %method, "gRPC request started");

        let future = self.inner.call(req);

        Box::pin(async move {
            match future.await {
                Ok(response) => {
                    let elapsed_ms = start.elapsed().as_millis();
                    // gRPC status is carried in the "grpc-status" trailer (or header on errors).
                    // A missing grpc-status header in the response means OK (0).
                    let grpc_status = response
                        .headers()
                        .get("grpc-status")
                        .and_then(|v| v.to_str().ok())
                        .unwrap_or("0");

                    if grpc_status == "0" {
                        info!(
                            method = %method,
                            status = grpc_status,
                            elapsed_ms = elapsed_ms,
                            "gRPC request finished"
                        );
                    } else {
                        warn!(
                            method = %method,
                            status = grpc_status,
                            elapsed_ms = elapsed_ms,
                            "gRPC request finished with error"
                        );
                    }
                    Ok(response)
                }
                Err(err) => {
                    let elapsed_ms = start.elapsed().as_millis();
                    warn!(
                        method = %method,
                        elapsed_ms = elapsed_ms,
                        error = %err,
                        "gRPC request failed"
                    );
                    Err(err)
                }
            }
        })
    }
}
