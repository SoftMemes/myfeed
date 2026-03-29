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
import type { Subscription } from "@/lib/domain";
import { searchMockChannels } from "@/lib/mock-data";
import { addSubscriptionWithItems } from "@/lib/seed";
import { getSubscriptions, setSubscriptions } from "@/lib/storage";

interface Props {
  onSubscribed: () => void;
}

export function AddSubscriptionDialog({ onSubscribed }: Props) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");

  const results = searchMockChannels(query);
  const existing = getSubscriptions();
  const existingChannelIds = new Set(
    existing.map((s) => s.id.replace("sub_", ""))
  );

  function handleSubscribe(channelId: string) {
    const channel = results.find((c) => c.id === channelId);
    if (!channel) return;

    const subId = `sub_${channel.id}`;
    const newSub: Subscription = {
      id: subId,
      sourceId: "youtube",
      publisherName: channel.name,
      publisherAvatarUrl: channel.avatarUrl,
      publisherDescription: channel.description,
      subscribedAt: new Date().toISOString(),
    };

    setSubscriptions([...getSubscriptions(), newSub]);
    addSubscriptionWithItems(subId, channel.id);
    setOpen(false);
    setQuery("");
    onSubscribed();
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button size="sm" />}>
        <Plus className="w-4 h-4 mr-1" />
        Add subscription
      </DialogTrigger>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Add subscription</DialogTitle>
        </DialogHeader>
        <Input
          placeholder="Search channels…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          autoFocus
        />
        <div className="mt-2 flex flex-col gap-1 max-h-80 overflow-y-auto">
          {results.length === 0 && (
            <p className="text-sm text-gray-400 text-center py-6">
              No channels found
            </p>
          )}
          {results.map((channel) => {
            const alreadySubscribed = existingChannelIds.has(channel.id);
            return (
              <button
                key={channel.id}
                onClick={() => !alreadySubscribed && handleSubscribe(channel.id)}
                disabled={alreadySubscribed}
                className="flex items-center gap-3 rounded-md px-3 py-2 text-left hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={channel.avatarUrl}
                  alt={channel.name}
                  className="w-9 h-9 rounded-full bg-gray-100 shrink-0"
                />
                <div className="min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {channel.name}
                    {alreadySubscribed && (
                      <span className="ml-2 text-xs text-gray-400 font-normal">
                        subscribed
                      </span>
                    )}
                  </p>
                  <p className="text-xs text-gray-500 truncate">
                    {channel.description}
                  </p>
                </div>
              </button>
            );
          })}
        </div>
      </DialogContent>
    </Dialog>
  );
}
