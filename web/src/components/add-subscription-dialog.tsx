"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import type { Subscribable } from "@/lib/domain";
import { trpc } from "@/trpc/client";

interface Props {
  onSubscribed: () => void;
}

export function AddSubscriptionDialog({ onSubscribed }: Props) {
  const [open, setOpen] = useState(false);
  const [selectedSourceId, setSelectedSourceId] = useState("");
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<Subscribable[]>([]);

  const { data: sourcesData } = trpc.sources.list.useQuery(
    {},
    { enabled: open }
  );
  const sources = sourcesData?.sources ?? [];

  const { data: subsData } = trpc.subscriptions.list.useQuery(
    {},
    { enabled: open }
  );
  const existingExternalIds = new Set(
    (subsData?.subscriptions ?? []).map((s) => s.externalId)
  );

  trpc.sources.searchSubscribables.useSubscription(
    { sourceId: selectedSourceId, query },
    {
      enabled: open && !!selectedSourceId,
      onData: (item) => {
        setResults((prev) => {
          if (prev.some((r) => r.externalId === item.externalId)) return prev;
          return [...prev, item];
        });
      },
      onError: (err) => console.error("search error", err),
    }
  );

  const addSubscription = trpc.subscriptions.add.useMutation({
    onSuccess: () => {
      setOpen(false);
      setQuery("");
      setResults([]);
      setSelectedSourceId("");
      onSubscribed();
    },
  });

  function handleQueryChange(value: string) {
    setQuery(value);
    setResults([]);
  }

  function handleSourceChange(sourceId: string) {
    setSelectedSourceId(sourceId);
    setResults([]);
    setQuery("");
  }

  function handleSubscribe(item: Subscribable) {
    if (!selectedSourceId) return;
    addSubscription.mutate({
      sourceId: selectedSourceId,
      externalId: item.externalId,
      displayName: item.displayName,
      description: item.description,
      imageUrl: item.imageUrl,
    });
  }

  function handleOpenChange(value: boolean) {
    setOpen(value);
    if (!value) {
      setQuery("");
      setResults([]);
      setSelectedSourceId("");
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger render={<Button size="sm" />}>
        <Plus className="w-4 h-4 mr-1" />
        Add subscription
      </DialogTrigger>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Add subscription</DialogTitle>
        </DialogHeader>

        <select
          className="w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gray-400"
          value={selectedSourceId}
          onChange={(e) => handleSourceChange(e.target.value)}
        >
          <option value="">Select a source…</option>
          {sources.map((s) => (
            <option key={s.id} value={s.id}>
              {s.displayName}
            </option>
          ))}
        </select>

        <Input
          placeholder="Search…"
          value={query}
          onChange={(e) => handleQueryChange(e.target.value)}
          disabled={!selectedSourceId}
          autoFocus
        />

        <div className="mt-2 flex flex-col gap-1 max-h-80 overflow-y-auto">
          {!selectedSourceId && (
            <p className="text-sm text-gray-400 text-center py-6">
              Select a source to search
            </p>
          )}
          {selectedSourceId && results.length === 0 && query.length > 0 && (
            <p className="text-sm text-gray-400 text-center py-6">
              No results found
            </p>
          )}
          {results.map((item) => {
            const alreadySubscribed = existingExternalIds.has(item.externalId);
            return (
              <button
                key={item.externalId}
                onClick={() => !alreadySubscribed && handleSubscribe(item)}
                disabled={alreadySubscribed || addSubscription.isPending}
                className="flex items-center gap-3 rounded-md px-3 py-2 text-left hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={item.imageUrl || undefined}
                  alt={item.displayName}
                  className="w-9 h-9 rounded-full bg-gray-100 shrink-0"
                />
                <div className="min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {item.displayName}
                    {alreadySubscribed && (
                      <span className="ml-2 text-xs text-gray-400 font-normal">
                        subscribed
                      </span>
                    )}
                  </p>
                  <p className="text-xs text-gray-500 truncate">
                    {item.description}
                  </p>
                </div>
              </button>
            );
          })}
        </div>

        {addSubscription.isError && (
          <p className="text-sm text-red-500 mt-1">
            Could not add subscription. Try again.
          </p>
        )}
      </DialogContent>
    </Dialog>
  );
}
