import type { FeedItem, Source, Subscription } from "./domain";

const KEYS = {
  sources: "myfeed:sources",
  subscriptions: "myfeed:subscriptions",
  feedItems: "myfeed:feedItems",
} as const;

function read<T>(key: string): T[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T[]) : [];
  } catch {
    return [];
  }
}

function write<T>(key: string, data: T[]): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(key, JSON.stringify(data));
}

export const getSources = (): Source[] => read<Source>(KEYS.sources);
export const setSources = (data: Source[]): void => write(KEYS.sources, data);

export const getSubscriptions = (): Subscription[] =>
  read<Subscription>(KEYS.subscriptions);
export const setSubscriptions = (data: Subscription[]): void =>
  write(KEYS.subscriptions, data);

export const getFeedItems = (): FeedItem[] => read<FeedItem>(KEYS.feedItems);
export const setFeedItems = (data: FeedItem[]): void =>
  write(KEYS.feedItems, data);

export function clearAll(): void {
  if (typeof window === "undefined") return;
  Object.values(KEYS).forEach((k) => localStorage.removeItem(k));
}

export function isSeeded(): boolean {
  if (typeof window === "undefined") return false;
  return localStorage.getItem(KEYS.sources) !== null;
}
