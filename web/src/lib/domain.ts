export interface Source {
  id: string;
  platformType: string;
  displayName: string;
  createdAt: string;
}

export interface Subscription {
  id: string;
  sourceId: string;
  externalId: string;
  displayName: string;
  description: string;
  imageUrl: string;
  createdAt: string;
}

export interface Subscribable {
  externalId: string;
  displayName: string;
  description: string;
  imageUrl: string;
}

export interface FeedItem {
  id: string;
  sourceId: string;
  subscriptionId: string;
  platformType: string;
  title: string;
  description: string;
  url: string;
  imageUrl: string;
  publishedAt: string;
}
