import { z } from "zod";
import { router, publicProcedure } from "../trpc";
import { subscriptionClient } from "../grpc";
import type { Subscription } from "@/lib/domain";

function toSubscription(s: {
  id: string;
  sourceId: string;
  externalId: string;
  displayName: string;
  description: string;
  imageUrl: string;
  createdAt?: string;
}): Subscription {
  return {
    id: s.id,
    sourceId: s.sourceId,
    externalId: s.externalId,
    displayName: s.displayName,
    description: s.description,
    imageUrl: s.imageUrl,
    createdAt: s.createdAt ?? new Date(0).toISOString(),
  };
}

export const subscriptionsRouter = router({
  list: publicProcedure
    .input(
      z.object({
        sourceId: z.string().optional(),
        pageToken: z.string().optional(),
      })
    )
    .query(async ({ input }) => {
      const response = await subscriptionClient.listSubscriptions({
        sourceId: input.sourceId ?? "",
        page: { pageSize: 100, pageToken: input.pageToken ?? "" },
      });

      return {
        subscriptions: response.subscriptions.map(toSubscription),
        nextPageToken: response.page?.nextPageToken ?? "",
      };
    }),

  add: publicProcedure
    .input(
      z.object({
        sourceId: z.string(),
        externalId: z.string(),
        displayName: z.string(),
        description: z.string(),
        imageUrl: z.string(),
      })
    )
    .mutation(async ({ input }) => {
      const response = await subscriptionClient.addSubscription(input);
      if (!response.subscription) {
        throw new Error("No subscription returned");
      }
      return toSubscription(response.subscription);
    }),

  remove: publicProcedure
    .input(z.object({ subscriptionId: z.string() }))
    .mutation(async ({ input }) => {
      await subscriptionClient.removeSubscription(input);
    }),
});
