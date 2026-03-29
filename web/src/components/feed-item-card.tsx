import type { FeedItem } from "@/lib/domain";

function timeAgo(isoString: string): string {
  const diff = Date.now() - new Date(isoString).getTime();
  const minutes = Math.floor(diff / 60000);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  if (weeks < 5) return `${weeks}w ago`;
  return new Date(isoString).toLocaleDateString();
}

interface Props {
  item: FeedItem;
  publisherName: string;
}

export function FeedItemCard({ item, publisherName }: Props) {
  return (
    <a
      href={item.url}
      target="_blank"
      rel="noopener noreferrer"
      className="group block rounded-lg overflow-hidden border bg-white hover:shadow-md transition-shadow"
    >
      <div className="aspect-video overflow-hidden bg-gray-100">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={item.thumbnailUrl}
          alt={item.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          loading="lazy"
        />
      </div>
      <div className="p-3">
        <p className="text-sm font-medium text-gray-900 line-clamp-2 leading-snug">
          {item.title}
        </p>
        <p className="text-xs text-gray-500 mt-1">
          {publisherName} &bull; {timeAgo(item.publishedAt)}
        </p>
      </div>
    </a>
  );
}
