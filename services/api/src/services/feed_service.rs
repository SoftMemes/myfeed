use tonic::{Request, Response, Status};

use crate::auth::check_auth;
use crate::proto::{
    feed_service_server::FeedService, GetFeedRequest, GetFeedResponse, PageResponse,
};
use crate::store::{decode_cursor, FeedRepository};

pub struct FeedServiceImpl<S> {
    pub store: S,
}

#[tonic::async_trait]
impl<S> FeedService for FeedServiceImpl<S>
where
    S: FeedRepository + Send + Sync + 'static,
{
    async fn get_feed(
        &self,
        request: Request<GetFeedRequest>,
    ) -> Result<Response<GetFeedResponse>, Status> {
        check_auth(request.metadata())?;
        let req = request.into_inner();

        let source_id = if req.source_id.is_empty() { None } else { Some(req.source_id.as_str()) };
        let subscription_id = if req.subscription_id.is_empty() {
            None
        } else {
            Some(req.subscription_id.as_str())
        };
        let after_secs = req.after.map(|t| t.seconds);
        let before_secs = req.before.map(|t| t.seconds);

        let page = req.page.unwrap_or_default();
        let page_size = if page.page_size <= 0 { 20 } else { page.page_size as usize };
        let offset = decode_cursor(&page.page_token)?;

        let (items, next_token) = self
            .store
            .get_feed(source_id, subscription_id, after_secs, before_secs, page_size, offset)
            .await?;

        Ok(Response::new(GetFeedResponse {
            items,
            page: Some(PageResponse { next_page_token: next_token.unwrap_or_default() }),
        }))
    }
}
