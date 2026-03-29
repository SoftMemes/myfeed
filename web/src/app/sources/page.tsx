"use client";

import { Trash2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { trpc } from "@/trpc/client";

export default function SourcesPage() {
  const utils = trpc.useUtils();

  const { data: sourcesData, isLoading: sourcesLoading, error: sourcesError, refetch } =
    trpc.sources.list.useQuery({});
  const { data: subsData } = trpc.subscriptions.list.useQuery({});

  const sources = sourcesData?.sources ?? [];

  const subCounts = (subsData?.subscriptions ?? []).reduce<Record<string, number>>(
    (acc, sub) => {
      acc[sub.sourceId] = (acc[sub.sourceId] ?? 0) + 1;
      return acc;
    },
    {}
  );

  const deleteSource = trpc.sources.delete.useMutation({
    onSuccess: () => {
      utils.sources.list.invalidate();
      utils.subscriptions.list.invalidate();
      utils.feed.getFeed.invalidate();
    },
  });

  if (sourcesLoading) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-8">
        <div className="h-8 bg-gray-200 rounded w-32 animate-pulse mb-6" />
        <div className="flex flex-col gap-3">
          {Array.from({ length: 2 }).map((_, i) => (
            <div key={i} className="h-20 rounded-lg border bg-white animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  if (sourcesError) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-20 text-center">
        <p className="text-gray-500 mb-4">Could not load sources.</p>
        <Button variant="outline" onClick={() => refetch()}>Retry</Button>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">Sources</h1>

      <div className="flex flex-col gap-3">
        {sources.map((source) => (
          <div
            key={source.id}
            className="flex items-center gap-4 rounded-lg border bg-white p-4"
          >
            <div className="w-8 h-8 rounded bg-gray-100 shrink-0 flex items-center justify-center">
              <span className="text-xs font-medium text-gray-500 capitalize">
                {source.platformType.slice(0, 2)}
              </span>
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className="text-sm font-medium text-gray-900">
                  {source.displayName}
                </p>
                <Badge variant="secondary">
                  {subCounts[source.id] ?? 0} subscription
                  {(subCounts[source.id] ?? 0) !== 1 ? "s" : ""}
                </Badge>
              </div>
              <p className="text-xs text-gray-500 mt-0.5 capitalize">
                {source.platformType}
              </p>
            </div>
            <Button
              variant="ghost"
              size="icon"
              className="shrink-0 text-gray-400 hover:text-red-500"
              onClick={() => deleteSource.mutate({ sourceId: source.id })}
              disabled={deleteSource.isPending}
              aria-label={`Delete ${source.displayName}`}
            >
              <Trash2 className="w-4 h-4" />
            </Button>
          </div>
        ))}
      </div>
    </div>
  );
}
