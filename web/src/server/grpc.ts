import { createChannel, createClient } from "nice-grpc";
import { SubscriptionServiceDefinition } from "../../generated/proto/com/softmemes/myfeed/v1/subscriptions";
import { FeedServiceDefinition } from "../../generated/proto/com/softmemes/myfeed/v1/feed";

const channel = createChannel(
  process.env.GRPC_API_URL ?? "localhost:50051"
);

export const subscriptionClient = createClient(
  SubscriptionServiceDefinition,
  channel
);

export const feedClient = createClient(FeedServiceDefinition, channel);
