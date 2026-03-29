import { router } from "../trpc";
import { feedRouter } from "./feed";
import { subscriptionsRouter } from "./subscriptions";
import { sourcesRouter } from "./sources";

export const appRouter = router({
  feed: feedRouter,
  subscriptions: subscriptionsRouter,
  sources: sourcesRouter,
});

export type AppRouter = typeof appRouter;
