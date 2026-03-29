"use client";

import { useCallback, useEffect, useState } from "react";
import { Trash2 } from "lucide-react";
import { AddSubscriptionDialog } from "@/components/add-subscription-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import type { Subscription } from "@/lib/domain";
import {
  getFeedItems,
  getSubscriptions,
  setFeedItems,
  setSubscriptions,
} from "@/lib/storage";

export default function SubscriptionsPage() {
  const [subscriptions, setLocalSubscriptions] = useState<Subscription[]>([]);

  const load = useCallback(() => {
    setLocalSubscriptions(getSubscriptions());
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  function handleRemove(subId: string) {
    const updated = getSubscriptions().filter((s) => s.id !== subId);
    setSubscriptions(updated);

    const updatedItems = getFeedItems().filter(
      (item) => item.subscriptionId !== subId
    );
    setFeedItems(updatedItems);

    load();
  }

  const grouped = subscriptions.reduce<Record<string, Subscription[]>>(
    (acc, sub) => {
      (acc[sub.sourceId] ??= []).push(sub);
      return acc;
    },
    {}
  );

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold text-gray-900">Subscriptions</h1>
        <AddSubscriptionDialog onSubscribed={load} />
      </div>

      {subscriptions.length === 0 ? (
        <div className="text-center py-20">
          <p className="text-gray-500 mb-4">You have no subscriptions yet.</p>
          <AddSubscriptionDialog onSubscribed={load} />
        </div>
      ) : (
        <div className="flex flex-col gap-8">
          {Object.entries(grouped).map(([sourceId, subs]) => (
            <section key={sourceId}>
              <h2 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3 capitalize">
                {sourceId}
              </h2>
              <div className="flex flex-col gap-2">
                {subs.map((sub) => (
                  <div
                    key={sub.id}
                    className="flex items-center gap-3 rounded-lg border bg-white p-3"
                  >
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={sub.publisherAvatarUrl ?? ""}
                      alt={sub.publisherName}
                      className="w-10 h-10 rounded-full bg-gray-100 shrink-0"
                    />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {sub.publisherName}
                        </p>
                        <Badge variant="secondary" className="capitalize text-xs">
                          {sub.sourceId}
                        </Badge>
                      </div>
                      {sub.publisherDescription && (
                        <p className="text-xs text-gray-500 truncate mt-0.5">
                          {sub.publisherDescription}
                        </p>
                      )}
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="shrink-0 text-gray-400 hover:text-red-500"
                      onClick={() => handleRemove(sub.id)}
                      aria-label={`Remove ${sub.publisherName}`}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}
