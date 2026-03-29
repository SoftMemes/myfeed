import { createChannel, createClient } from "nice-grpc";
import {
  SubscriptionServiceDefinition,
  type SubscriptionServiceClient,
} from "../../generated/proto/com/softmemes/myfeed/v1/subscriptions";
import {
  FeedServiceDefinition,
  type FeedServiceClient,
} from "../../generated/proto/com/softmemes/myfeed/v1/feed";

const channel = createChannel(
  process.env.GRPC_API_URL ?? "localhost:50051"
);

export const subscriptionClient: SubscriptionServiceClient = createClient(
  SubscriptionServiceDefinition,
  channel
);

export const feedClient: FeedServiceClient = createClient(
  FeedServiceDefinition,
  channel
);
