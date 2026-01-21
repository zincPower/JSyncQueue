import { JSyncQueue, Message, Any } from "jsyncqueue"
import { Log } from "./Log"

export class ImmediatelyQueue extends JSyncQueue {
  async onHandleMessage(message: Message): Promise<Any> {
    Log.i("ImmediatelyQueue", `onHandleMessage message=${JSON.stringify(message)}`)
    return `my queue ${JSON.stringify(message)}`
  }
}

export class DelayQueue extends JSyncQueue {
  async onHandleMessage(message: Message): Promise<Any> {
    Log.i("DelayQueue", `onHandleMessage message=${JSON.stringify(message)}`)
    return `my queue ${JSON.stringify(message)}`
  }
}