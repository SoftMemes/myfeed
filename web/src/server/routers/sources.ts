import { z } from "zod";
import { observable } from "@trpc/server/observable";
import { router, publicProcedure } from "../trpc";
import { subscriptionClient } from "../grpc";
import type { Source, Subscribable } from "@/lib/domain";

function toSource(s: {
  id: string;
  platformType: string;
  displayName: string;
  createdAt?: string;
}): Source {
  return {
    id: s.id,
    platformType: s.platformType,
    displayName: s.displayName,
    createdAt: s.createdAt ?? new Date(0).toISOString(),
  };
}

export const sourcesRouter = router({
  list: publicProcedure
    .input(z.object({ pageToken: z.string().optional() }))
    .query(async ({ input }) => {
      const response = await subscriptionClient.listSources({
        page: { pageSize: 100, pageToken: input.pageToken ?? "" },
      });

      return {
        sources: response.sources.map(toSource),
        nextPageToken: response.page?.nextPageToken ?? "",
      };
    }),

  create: publicProcedure
    .input(
      z.object({
        platformType: z.string(),
        displayName: z.string(),
      })
    )
    .mutation(async ({ input }) => {
      const response = await subscriptionClient.createSource(input);
      if (!response.source) {
        throw new Error("No source returned");
      }
      return toSource(response.source);
    }),

  delete: publicProcedure
    .input(z.object({ sourceId: z.string() }))
    .mutation(async ({ input }) => {
      await subscriptionClient.deleteSource(input);
    }),

  searchSubscribables: publicProcedure
    .input(z.object({ sourceId: z.string(), query: z.string() }))
    .subscription(({ input }) => {
      return observable<Subscribable>((emit) => {
        let cancelled = false;

        async function run() {
          const stream = subscriptionClient.searchSubscribables(input);
          for await (const response of stream) {
            if (cancelled) break;
            if (response.subscribable) {
              emit.next({
                externalId: response.subscribable.externalId,
                displayName: response.subscribable.displayName,
                description: response.subscribable.description,
                imageUrl: response.subscribable.imageUrl,
              });
            }
          }
          emit.complete();
        }

        run().catch((err) => emit.error(err));

        return () => {
          cancelled = true;
        };
      });
    }),
});
