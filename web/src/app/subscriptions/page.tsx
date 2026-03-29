"use client";

import { Trash2 } from "lucide-react";
import { AddSubscriptionDialog } from "@/components/add-subscription-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { trpc } from "@/trpc/client";

export default function SubscriptionsPage() {
  const utils = trpc.useUtils();

  const { data, isLoading, error, refetch } = trpc.subscriptions.list.useQuery({});
  const subscriptions = data?.subscriptions ?? [];

  const remove = trpc.subscriptions.remove.useMutation({
    onSuccess: () => {
      utils.subscriptions.list.invalidate();
      utils.feed.getFeed.invalidate();
    },
  });

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-8">
        <div className="h-8 bg-gray-200 rounded w-48 animate-pulse mb-6" />
        <div className="flex flex-col gap-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="h-16 rounded-lg border bg-white animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-20 text-center">
        <p className="text-gray-500 mb-4">Could not load subscriptions.</p>
        <Button variant="outline" onClick={() => refetch()}>Retry</Button>
      </div>
    );
  }

  const grouped = subscriptions.reduce<Record<string, typeof subscriptions>>(
    (acc, sub) => {
      (acc[sub.sourceId] ??= []).push(sub);
      return acc;
    },
    {}
  );

  function handleSubscribed() {
    utils.subscriptions.list.invalidate();
    utils.feed.getFeed.invalidate();
  }

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold text-gray-900">Subscriptions</h1>
        <AddSubscriptionDialog onSubscribed={handleSubscribed} />
      </div>

      {subscriptions.length === 0 ? (
        <div className="text-center py-20">
          <p className="text-gray-500 mb-4">You have no subscriptions yet.</p>
          <AddSubscriptionDialog onSubscribed={handleSubscribed} />
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
                      src={sub.imageUrl}
                      alt={sub.displayName}
                      className="w-10 h-10 rounded-full bg-gray-100 shrink-0"
                    />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {sub.displayName}
                        </p>
                        <Badge variant="secondary" className="capitalize text-xs">
                          {sub.sourceId}
                        </Badge>
                      </div>
                      {sub.description && (
                        <p className="text-xs text-gray-500 truncate mt-0.5">
                          {sub.description}
                        </p>
                      )}
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="shrink-0 text-gray-400 hover:text-red-500"
                      onClick={() => remove.mutate({ subscriptionId: sub.id })}
                      disabled={remove.isPending}
                      aria-label={`Remove ${sub.displayName}`}
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
