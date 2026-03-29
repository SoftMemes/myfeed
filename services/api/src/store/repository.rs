use std::future::Future;

use crate::proto::{FeedItem, Source, Subscribable, Subscription};

/// Repository for platform source connections.
pub trait SourceRepository {
    fn get_source(
        &self,
        source_id: &str,
    ) -> impl Future<Output = Result<Source, tonic::Status>> + Send;

    fn create_source(
        &self,
        platform_type: &str,
        display_name: &str,
    ) -> impl Future<Output = Result<Source, tonic::Status>> + Send;

    /// Delete a source. Implementations must cascade-delete all associated
    /// subscriptions and feed items.
    fn delete_source(
        &self,
        source_id: &str,
    ) -> impl Future<Output = Result<(), tonic::Status>> + Send;

    fn list_sources(
        &self,
        page_size: usize,
        offset: usize,
    ) -> impl Future<Output = Result<(Vec<Source>, Option<String>), tonic::Status>> + Send;
}

/// Repository for user subscriptions within a source.
pub trait SubscriptionRepository {
    fn add_subscription(
        &self,
        source_id: &str,
        external_id: &str,
        display_name: &str,
        description: &str,
        image_url: &str,
    ) -> impl Future<Output = Result<Subscription, tonic::Status>> + Send;

    fn remove_subscription(
        &self,
        subscription_id: &str,
    ) -> impl Future<Output = Result<(), tonic::Status>> + Send;

    fn list_subscriptions(
        &self,
        source_id: Option<&str>,
        page_size: usize,
        offset: usize,
    ) -> impl Future<Output = Result<(Vec<Subscription>, Option<String>), tonic::Status>> + Send;

    /// Look up subscribable candidates from the mock catalog for a given platform type,
    /// optionally filtered by a query string.
    fn get_subscribables(
        &self,
        platform_type: &str,
        query: &str,
    ) -> impl Future<Output = Result<Vec<Subscribable>, tonic::Status>> + Send;
}

/// Repository for feed items.
pub trait FeedRepository {
    /// Generate and store mock feed items for a newly added subscription.
    fn seed_feed_items(
        &self,
        subscription: &Subscription,
        platform_type: &str,
    ) -> impl Future<Output = Result<(), tonic::Status>> + Send;

    fn get_feed(
        &self,
        source_id: Option<&str>,
        subscription_id: Option<&str>,
        after_secs: Option<i64>,
        before_secs: Option<i64>,
        page_size: usize,
        offset: usize,
    ) -> impl Future<Output = Result<(Vec<FeedItem>, Option<String>), tonic::Status>> + Send;
}
