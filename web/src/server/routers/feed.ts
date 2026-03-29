import { z } from "zod";
import { router, publicProcedure } from "../trpc";
import { feedClient } from "../grpc";
import type { FeedItem } from "@/lib/domain";
import { GetFeedRequest } from "../../../generated/proto/com/softmemes/myfeed/v1/feed";
import { PageRequest } from "../../../generated/proto/com/softmemes/myfeed/v1/common";

function toFeedItem(item: {
  id: string;
  sourceId: string;
  subscriptionId: string;
  platformType: string;
  title: string;
  description: string;
  url: string;
  imageUrl: string;
  publishedAt?: string;
}): FeedItem {
  return {
    id: item.id,
    sourceId: item.sourceId,
    subscriptionId: item.subscriptionId,
    platformType: item.platformType,
    title: item.title,
    description: item.description,
    url: item.url,
    imageUrl: item.imageUrl,
    publishedAt: item.publishedAt ?? new Date(0).toISOString(),
  };
}

export const feedRouter = router({
  getFeed: publicProcedure
    .input(
      z.object({
        sourceId: z.string().optional(),
        subscriptionId: z.string().optional(),
        pageSize: z.number().int().min(1).max(100).optional(),
        pageToken: z.string().optional(),
      })
    )
    .query(async ({ input }) => {
      const response = await feedClient.getFeed(
        GetFeedRequest.fromPartial({
          page: PageRequest.fromPartial({
            pageSize: input.pageSize ?? 20,
            pageToken: input.pageToken ?? "",
          }),
          sourceId: input.sourceId ?? "",
          subscriptionId: input.subscriptionId ?? "",
        })
      );

      return {
        items: response.items.map(toFeedItem),
        nextPageToken: response.page?.nextPageToken ?? "",
      };
    }),
});
