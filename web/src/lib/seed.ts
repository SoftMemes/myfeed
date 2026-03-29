import type { Source, Subscription } from "./domain";
import { generateFeedItems, MOCK_CHANNELS } from "./mock-data";
import {
  clearAll,
  getFeedItems,
  isSeeded,
  setFeedItems,
  setSources,
  setSubscriptions,
} from "./storage";

const SEED_SOURCES: Source[] = [
  {
    id: "youtube",
    name: "YouTube",
    enabled: true,
    iconUrl: "/youtube.svg",
  },
];

// Indices into MOCK_CHANNELS to pre-subscribe on first load
const SEED_CHANNEL_INDICES = [0, 2, 3, 6];

export function seedIfEmpty(): void {
  if (isSeeded()) return;

  setSources(SEED_SOURCES);

  const subscriptions: Subscription[] = SEED_CHANNEL_INDICES.map((idx) => {
    const channel = MOCK_CHANNELS[idx];
    return {
      id: `sub_${channel.id}`,
      sourceId: "youtube",
      publisherName: channel.name,
      publisherAvatarUrl: channel.avatarUrl,
      publisherDescription: channel.description,
      subscribedAt: new Date(
        Date.now() - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000
      ).toISOString(),
    };
  });

  setSubscriptions(subscriptions);

  const feedItems = subscriptions.flatMap((sub, i) => {
    const channel = MOCK_CHANNELS[SEED_CHANNEL_INDICES[i]];
    const count = Math.floor(Math.random() * 6) + 5; // 5–10
    return generateFeedItems(sub.id, "youtube", channel, count, 30 * 24);
  });

  setFeedItems(feedItems);
}

export function resetData(): void {
  clearAll();
  seedIfEmpty();
}

export function addSubscriptionWithItems(
  subscriptionId: string,
  channelId: string
): void {
  const channel = MOCK_CHANNELS.find((c) => c.id === channelId);
  if (!channel) return;

  const count = Math.floor(Math.random() * 6) + 5; // 5–10
  const newItems = generateFeedItems(subscriptionId, "youtube", channel, count, 14 * 24);
  const existing = getFeedItems();
  setFeedItems([...existing, ...newItems]);
}
