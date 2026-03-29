"use client";

import { useState } from "react";
import { FeedItemCard } from "@/components/feed-item-card";
import { trpc } from "@/trpc/client";
import { Button, buttonVariants } from "@/components/ui/button";
import Link from "next/link";

export default function FeedPage() {
  const [pageToken, setPageToken] = useState<string | undefined>(undefined);
  const [allItems, setAllItems] = useState<
    { id: string; subscriptionId: string; sourceId: string; platformType: string; title: string; description: string; url: string; imageUrl: string; publishedAt: string }[]
  >([]);

  const { data: subscriptionsData } = trpc.subscriptions.list.useQuery({});

  const { data, isLoading, error, refetch } = trpc.feed.getFeed.useQuery(
    { pageToken },
    {
      onSuccess: (result) => {
        if (pageToken) {
          setAllItems((prev) => [...prev, ...result.items]);
        } else {
          setAllItems(result.items);
        }
      },
    }
  );

  const subscriptionMap = new Map(
    (subscriptionsData?.subscriptions ?? []).map((s) => [s.id, s])
  );

  if (isLoading && allItems.length === 0) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 9 }).map((_, i) => (
            <div key={i} className="rounded-lg border bg-white overflow-hidden animate-pulse">
              <div className="aspect-video bg-gray-200" />
              <div className="p-3 space-y-2">
                <div className="h-4 bg-gray-200 rounded w-3/4" />
                <div className="h-3 bg-gray-200 rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error && allItems.length === 0) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 text-center">
        <p className="text-gray-500 mb-4">Could not load feed.</p>
        <Button variant="outline" onClick={() => refetch()}>
          Retry
        </Button>
      </div>
    );
  }

  if (!isLoading && allItems.length === 0) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 text-center">
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Your feed is empty
        </h2>
        <p className="text-gray-500 mb-6">
          Subscribe to channels to see their content here.
        </p>
        <Link href="/subscriptions" className={buttonVariants()}>
          Add subscriptions
        </Link>
      </div>
    );
  }

  const hasMore = !!data?.nextPageToken;

  return (
    <div className="max-w-6xl mx-auto px-4 py-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {allItems.map((item) => (
          <FeedItemCard
            key={item.id}
            item={item}
            publisherName={
              subscriptionMap.get(item.subscriptionId)?.displayName ?? ""
            }
          />
        ))}
      </div>
      {hasMore && (
        <div className="mt-8 flex justify-center">
          <Button
            variant="outline"
            onClick={() => setPageToken(data?.nextPageToken)}
            disabled={isLoading}
          >
            {isLoading ? "Loading…" : "Load more"}
          </Button>
        </div>
      )}
    </div>
  );
}
