"use client";

import { useCallback, useEffect, useState } from "react";
import { FeedItemCard } from "@/components/feed-item-card";
import type { FeedItem, Subscription } from "@/lib/domain";
import { getFeedItems, getSources, getSubscriptions } from "@/lib/storage";
import { Button, buttonVariants } from "@/components/ui/button";
import Link from "next/link";

const PAGE_SIZE = 20;

export default function FeedPage() {
  const [items, setItems] = useState<FeedItem[]>([]);
  const [subscriptionMap, setSubscriptionMap] = useState<
    Map<string, Subscription>
  >(new Map());
  const [visible, setVisible] = useState(PAGE_SIZE);
  const [noSubscriptions, setNoSubscriptions] = useState(false);
  const [allDisabled, setAllDisabled] = useState(false);

  const load = useCallback(() => {
    const sources = getSources();
    const subscriptions = getSubscriptions();
    const feedItems = getFeedItems();

    const enabledSourceIds = new Set(
      sources.filter((s) => s.enabled).map((s) => s.id)
    );

    setNoSubscriptions(subscriptions.length === 0);
    setAllDisabled(
      sources.length > 0 && sources.every((s) => !s.enabled)
    );

    const filtered = feedItems
      .filter((item) => enabledSourceIds.has(item.sourceId))
      .sort(
        (a, b) =>
          new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime()
      );

    setItems(filtered);

    const subMap = new Map<string, Subscription>();
    for (const sub of subscriptions) {
      subMap.set(sub.id, sub);
    }
    setSubscriptionMap(subMap);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const visibleItems = items.slice(0, visible);
  const hasMore = visible < items.length;

  if (noSubscriptions) {
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

  if (allDisabled) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-20 text-center">
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          All sources are disabled
        </h2>
        <p className="text-gray-500 mb-6">
          Enable a source on the Sources page to see content.
        </p>
        <Link href="/sources" className={buttonVariants({ variant: "outline" })}>
          Manage sources
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {visibleItems.map((item) => (
          <FeedItemCard
            key={item.id}
            item={item}
            publisherName={
              subscriptionMap.get(item.subscriptionId)?.publisherName ?? ""
            }
          />
        ))}
      </div>
      {hasMore && (
        <div className="mt-8 flex justify-center">
          <Button
            variant="outline"
            onClick={() => setVisible((v) => v + PAGE_SIZE)}
          >
            Load more
          </Button>
        </div>
      )}
    </div>
  );
}
