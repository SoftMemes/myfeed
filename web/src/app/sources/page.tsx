"use client";

import { useCallback, useEffect, useState } from "react";
import { RotateCcw } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import type { Source } from "@/lib/domain";
import { resetData } from "@/lib/seed";
import { getSources, getSubscriptions, setSources } from "@/lib/storage";

export default function SourcesPage() {
  const [sources, setLocalSources] = useState<Source[]>([]);
  const [subCounts, setSubCounts] = useState<Record<string, number>>({});

  const load = useCallback(() => {
    setLocalSources(getSources());
    const counts: Record<string, number> = {};
    for (const sub of getSubscriptions()) {
      counts[sub.sourceId] = (counts[sub.sourceId] ?? 0) + 1;
    }
    setSubCounts(counts);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  function handleToggle(sourceId: string, enabled: boolean) {
    const updated = getSources().map((s) =>
      s.id === sourceId ? { ...s, enabled } : s
    );
    setSources(updated);
    load();
  }

  function handleReset() {
    if (
      window.confirm(
        "Reset all data? This will restore the default subscriptions and feed."
      )
    ) {
      resetData();
      load();
      window.location.href = "/";
    }
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
            {source.iconUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={source.iconUrl}
                alt={source.name}
                className="w-8 h-8 shrink-0"
              />
            ) : (
              <div className="w-8 h-8 rounded bg-gray-100 shrink-0" />
            )}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className="text-sm font-medium text-gray-900">
                  {source.name}
                </p>
                <Badge variant="secondary">
                  {subCounts[source.id] ?? 0} subscription
                  {(subCounts[source.id] ?? 0) !== 1 ? "s" : ""}
                </Badge>
              </div>
              <p className="text-xs text-gray-500 mt-0.5">
                {source.enabled
                  ? "Showing in feed"
                  : "Hidden from feed — subscriptions preserved"}
              </p>
            </div>
            <Switch
              checked={source.enabled}
              onCheckedChange={(checked) => handleToggle(source.id, checked)}
              aria-label={`Toggle ${source.name}`}
            />
          </div>
        ))}
      </div>

      <div className="mt-12 pt-6 border-t">
        <h2 className="text-sm font-medium text-gray-700 mb-1">Reset data</h2>
        <p className="text-xs text-gray-500 mb-3">
          Clears all subscriptions and feed items, then restores the default
          seed data.
        </p>
        <Button variant="outline" size="sm" onClick={handleReset}>
          <RotateCcw className="w-3.5 h-3.5 mr-1.5" />
          Reset to defaults
        </Button>
      </div>
    </div>
  );
}
