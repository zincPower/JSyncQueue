import { JSyncQueue, Message, Any } from "jsyncqueue"
import { Log } from "./Log"

export class ImmediatelyQueue extends JSyncQueue {
  private count = 0

  async onHandleMessage(message: Message): Promise<Any> {
    Log.i("ImmediatelyQueue", `onHandleMessage message=${JSON.stringify(message)}`)
    switch (message.what) {
      case "say_hello": {
        const name = message.data["name"]
        this.count += 1

        const delayTime1 = Math.round(Math.random() * 500)
        Log.i("ImmediatelyQueue", `【say_hello】执行逻辑 第一段 将会模拟耗时=${delayTime1}`)
        await this.delay(delayTime1)

        const delayTime2 = Math.round(Math.random() * 500)
        Log.i("ImmediatelyQueue", `【say_hello】执行逻辑 第二段 将会模拟耗时=${delayTime2}`)
        await this.delay(delayTime2)

        if (this.count % 10 == 5) {
          throw { message: "模拟异常" }
        }
        return `你好，${name}。这是第${this.count}次打招呼。`
      }
      case "remove_message": {
        const name = message.data["name"]
        this.count += 1

        const delayTime1 = Math.round(Math.random() * 500)
        Log.i("ImmediatelyQueue", `【remove_message】执行逻辑 第一段 将会模拟耗时=${delayTime1}`)
        await this.delay(delayTime1)

        const delayTime2 = Math.round(Math.random() * 500)
        Log.i("ImmediatelyQueue", `【remove_message】执行逻辑 第二段 将会模拟耗时=${delayTime2}`)
        await this.delay(delayTime2)

        if (this.count % 10 == 5) {
          throw { message: "模拟异常" }
        }
        return `你好，${name}。这是第${this.count}次打招呼。`
      }
    }
    return `my queue ${JSON.stringify(message)}`
  }

  private async delay(ms: number) {
    return new Promise<Any>(resolve => setTimeout(resolve, ms))
  }
}

export class DelayQueue extends JSyncQueue {
  async onHandleMessage(message: Message): Promise<Any> {
    Log.i("DelayQueue", `onHandleMessage message=${JSON.stringify(message)}`)
    return `my queue ${JSON.stringify(message)}`
  }
}