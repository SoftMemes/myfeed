export interface Source {
  id: string;
  name: string;
  enabled: boolean;
  iconUrl?: string;
}

export interface Subscription {
  id: string;
  sourceId: string;
  publisherName: string;
  publisherAvatarUrl?: string;
  publisherDescription?: string;
  subscribedAt: string;
}

export interface FeedItem {
  id: string;
  subscriptionId: string;
  sourceId: string;
  title: string;
  description: string;
  thumbnailUrl: string;
  url: string;
  publishedAt: string;
  contentType: "video" | "podcast_episode" | "article" | "episode" | "post";
}

export interface MockChannel {
  id: string;
  name: string;
  avatarUrl: string;
  description: string;
  videoTitles: string[];
}
