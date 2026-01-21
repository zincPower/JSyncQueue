import { Any, Task, JSyncQueue } from 'jsyncqueue'
import { Log } from './Log'
import { ImmediatelyQueue } from './MyQueue'

const TAG = "ImmediatelyComponent"

@ComponentV2
export struct ImmediatelyComponent {
  private queue: JSyncQueue = new ImmediatelyQueue("ImmediatelyQueue")

  build() {
    Column() {
      Text(`立刻执行任务`)
        .width(`100%`)
        .fontColor(Color.Black)
        .fontWeight(800)
        .fontSize(22)
        .textAlign(TextAlign.Center)
        .margin(5)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        Button(`同步添加多个任务`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              try {
                const result = await (this.queue.post(async () => {
                  Log.i(TAG, `【post runnable 1】i=${i}`)
                  return `jiangpengyong 1 ${i}`
                })).getResult()
                Log.i(TAG, `【post runnable 1】result=${result}`)
              } catch (e) {
                Log.e(TAG, `【post runnable 1】e=${e}`)
              }
            }
          }).margin(5)

        Button(`一次性添加多个任务`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              this.queue.post(async () => {
                Log.i(TAG, `【post runnable 2】i=${i}`)
                await this.delay(1_000 - i * 10)
                return `jiangpengyong 2 ${i}`
              })
                .getResult()
                .then((result) => {
                  Log.i(TAG, `【post runnable 2】result=${result}`)
                })
                .catch((e: Any) => {
                  Log.e(TAG, `【post runnable 2】error=${e}`)
                })
            }
          }).margin(5)

        Button(`同步添加多个信息`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              try {
                const result = await (this.queue.sendMessage({
                  what: `jiang`,
                  data: { name: 'jiang peng yong 3', age: 20 + i },
                }).getResult())
                Log.i(TAG, `【send message 3】result=${result}`)
              } catch (e) {
                Log.e(TAG, `【send message 3】e=${e}`)
              }
            }
          }).margin(5)

        Button(`一次性添加多个信息`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              this.queue.sendMessage({
                what: `jiang`,
                data: { name: 'jiang peng yong 4', age: 20 + i },
              })
                .getResult()
                .then((result) => {
                  Log.i(TAG, `【send message 4】result=${result}`)
                })
                .catch((e: Any) => {
                  Log.e(TAG, `【send message 4】e=${e}`)
                })
            }
          }).margin(5)

        Button(`移除任务`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 10; ++i) {
              const pro = this.queue.post(async () => {
                Log.i(TAG, `post runnable 5 i=${i}`)
                return `jiang peng yong 5 i=${i}`
              })
              pro.getResult().then((result) => {
                Log.i(TAG, `【post runnable 5】result=${result}`)
              }).catch((e: Any) => {
                Log.e(TAG, `【post runnable 5】e=${e}`)
              })
              if (i == 5) {
                task = pro
              }
            }
            Log.i(TAG, `进行取消 task=${JSON.stringify(task)}`)
            task?.cancel()
          }).margin(5)

        Button(`移除信息`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 10; ++i) {
              const pro = this.queue.sendMessage({
                what: `jiang`,
                data: { name: 'jiang peng yong 6', age: 20 + i },
              })
              pro.getResult().then((result) => {
                Log.i(TAG, `【send message 6】result=${result}`)
              }).catch((e: Any) => {
                Log.e(TAG, `【send message 6】e=${e}`)
              })
              if (i == 5) {
                task = pro
              }
            }
            Log.i(TAG, `进行取消 task=${JSON.stringify(task)}`)
            task?.cancel()
          }).margin(5)

        Button(`打印内部状态`)
          .onClick(async () => {
            this.queue.dump()
          }).margin(5)
      }.backgroundColor(`#FFBDBD`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10,
      })
      .borderRadius(5)
    }.padding(5)
  }

  private async delay(ms: number) {
    return new Promise<Any>(resolve => setTimeout(resolve, ms))
  }
}