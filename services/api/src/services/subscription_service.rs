use std::time::Duration;

use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tonic::{Request, Response, Status};

use crate::auth::check_auth;
use crate::error::required_field;
use crate::proto::{
    subscription_service_server::SubscriptionService, AddSubscriptionRequest,
    AddSubscriptionResponse, CreateSourceRequest, CreateSourceResponse, DeleteSourceRequest,
    DeleteSourceResponse, ListSourcesRequest, ListSourcesResponse, ListSubscriptionsRequest,
    ListSubscriptionsResponse, PageResponse, RemoveSubscriptionRequest, RemoveSubscriptionResponse,
    SearchSubscribablesRequest, SearchSubscribablesResponse,
};
use crate::store::{decode_cursor, FeedRepository, SourceRepository, SubscriptionRepository};

pub struct SubscriptionServiceImpl<S> {
    pub store: S,
}

#[tonic::async_trait]
impl<S> SubscriptionService for SubscriptionServiceImpl<S>
where
    S: SourceRepository + SubscriptionRepository + FeedRepository + Clone + Send + Sync + 'static,
{
    type SearchSubscribablesStream = ReceiverStream<Result<SearchSubscribablesResponse, Status>>;

    async fn create_source(
        &self,
        request: Request<CreateSourceRequest>,
    ) -> Result<Response<CreateSourceResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        if req.platform_type.is_empty() {
            return Err(required_field("platform_type"));
        }
        if req.display_name.is_empty() {
            return Err(required_field("display_name"));
        }
        let source = self.store.create_source(&req.platform_type, &req.display_name).await?;
        Ok(Response::new(CreateSourceResponse { source: Some(source) }))
    }

    async fn delete_source(
        &self,
        request: Request<DeleteSourceRequest>,
    ) -> Result<Response<DeleteSourceResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        if req.source_id.is_empty() {
            return Err(required_field("source_id"));
        }
        self.store.delete_source(&req.source_id).await?;
        Ok(Response::new(DeleteSourceResponse {}))
    }

    async fn list_sources(
        &self,
        request: Request<ListSourcesRequest>,
    ) -> Result<Response<ListSourcesResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        let (page_size, offset) = parse_page(req.page)?;
        let (sources, next_token) = self.store.list_sources(page_size, offset).await?;
        Ok(Response::new(ListSourcesResponse {
            sources,
            page: Some(PageResponse { next_page_token: next_token.unwrap_or_default() }),
        }))
    }

    async fn search_subscribables(
        &self,
        request: Request<SearchSubscribablesRequest>,
    ) -> Result<Response<Self::SearchSubscribablesStream>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        if req.source_id.is_empty() {
            return Err(required_field("source_id"));
        }

        // Look up the source to get its platform_type
        let source = self.store.get_source(&req.source_id).await?;
        let subscribables = self
            .store
            .get_subscribables(&source.platform_type, &req.query)
            .await?;

        let (tx, rx) = mpsc::channel(32);
        tokio::spawn(async move {
            for s in subscribables {
                tokio::time::sleep(Duration::from_millis(150)).await;
                if tx
                    .send(Ok(SearchSubscribablesResponse { subscribable: Some(s) }))
                    .await
                    .is_err()
                {
                    break;
                }
            }
        });

        Ok(Response::new(ReceiverStream::new(rx)))
    }

    async fn add_subscription(
        &self,
        request: Request<AddSubscriptionRequest>,
    ) -> Result<Response<AddSubscriptionResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        if req.source_id.is_empty() {
            return Err(required_field("source_id"));
        }
        if req.external_id.is_empty() {
            return Err(required_field("external_id"));
        }
        if req.display_name.is_empty() {
            return Err(required_field("display_name"));
        }

        // Look up platform_type before adding (for feed item seeding)
        let source = self.store.get_source(&req.source_id).await?;
        let subscription = self
            .store
            .add_subscription(
                &req.source_id,
                &req.external_id,
                &req.display_name,
                &req.description,
                &req.image_url,
            )
            .await?;

        // Auto-generate mock feed items for the new subscription
        let _ = self
            .store
            .seed_feed_items(&subscription, &source.platform_type)
            .await;

        Ok(Response::new(AddSubscriptionResponse { subscription: Some(subscription) }))
    }

    async fn remove_subscription(
        &self,
        request: Request<RemoveSubscriptionRequest>,
    ) -> Result<Response<RemoveSubscriptionResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        if req.subscription_id.is_empty() {
            return Err(required_field("subscription_id"));
        }
        self.store.remove_subscription(&req.subscription_id).await?;
        Ok(Response::new(RemoveSubscriptionResponse {}))
    }

    async fn list_subscriptions(
        &self,
        request: Request<ListSubscriptionsRequest>,
    ) -> Result<Response<ListSubscriptionsResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();
        let source_id = if req.source_id.is_empty() { None } else { Some(req.source_id.as_str()) };
        let (page_size, offset) = parse_page(req.page)?;
        let (subscriptions, next_token) = self
            .store
            .list_subscriptions(source_id, page_size, offset)
            .await?;
        Ok(Response::new(ListSubscriptionsResponse {
            subscriptions,
            page: Some(PageResponse { next_page_token: next_token.unwrap_or_default() }),
        }))
    }
}

fn parse_page(page: Option<crate::proto::PageRequest>) -> Result<(usize, usize), Status> {
    let p = page.unwrap_or_default();
    let size = if p.page_size <= 0 { 20 } else { p.page_size as usize };
    let offset = decode_cursor(&p.page_token)?;
    Ok((size, offset))
}
