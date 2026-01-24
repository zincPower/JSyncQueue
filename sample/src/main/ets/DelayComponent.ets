import { Any, Task, JSyncQueue } from 'jsyncqueue'
import { Log } from './Log'
import { DelayQueue } from './MyQueue'
import { systemDateTime } from '@kit.BasicServicesKit'

const TAG = "DelayComponent"

@ComponentV2
export struct DelayComponent {
  private queue: JSyncQueue = new DelayQueue("DelayQueue")

  build() {
    Column() {
      Text(`延时任务`)
        .width(`100%`)
        .fontColor(Color.Black)
        .fontWeight(800)
        .fontSize(22)
        .textAlign(TextAlign.Center)
        .margin(5)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        Button(`同步添加多个延迟任务`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              try {
                const startTime = systemDateTime.getTime(false)
                const delayTime = i * 100
                const result = await (this.queue.postDelay(async () => {
                  const endTime = systemDateTime.getTime(false)
                  const duration = endTime - startTime
                  Log.i(TAG, `【post runnable 1】i=${i} delay=${delayTime} duration=${duration}`)
                  return `jiangpengyong 1 i=${i} delay=${delayTime} duration=${duration}`
                }, delayTime)).getResult()
                Log.i(TAG, `【post runnable 1】result=${result}`)
              } catch (e) {
                Log.e(TAG, `【post runnable 1】e=${e}`)
              }
            }
          }).margin(5)

        Button(`一次性添加多个延迟任务`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              const startTime = systemDateTime.getTime(false)
              const delayTime = i * 100
              this.queue.postDelay(async () => {
                const endTime = systemDateTime.getTime(false)
                const duration = endTime - startTime
                Log.i(TAG, `【post runnable 2】i=${i} duration=${duration}`)
                return `jiangpengyong 2 ${i} duration=${duration}`
              }, delayTime)
                .getResult()
                .then((result) => {
                  Log.i(TAG, `【post runnable 2】result=${result}`)
                })
                .catch((e: Any) => {
                  Log.e(TAG, `【post runnable 2】error=${e}`)
                })
            }
          }).margin(5)

        Button(`同步添加多个延时信息`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              try {
                const delayTime = i * 100
                const result = await (this.queue.sendMessageDelay({
                  what: `jiang`,
                  data: { name: 'jiang peng yong 3', age: 20 + i },
                }, delayTime).getResult())
                Log.i(TAG, `【send message 3】result=${result}`)
              } catch (e) {
                Log.e(TAG, `【send message 3】e=${e}`)
              }
            }
          }).margin(5)

        Button(`一次性添加多个延时信息`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              const delayTime = i * 100
              this.queue.sendMessageDelay({
                what: `jiang`,
                data: { name: 'jiang peng yong 4', age: 20 + i },
              }, delayTime)
                .getResult()
                .then((result) => {
                  Log.i(TAG, `【send message 4】result=${result}`)
                })
                .catch((e: Any) => {
                  Log.e(TAG, `【send message 4】e=${e}`)
                })
            }
          }).margin(5)

        Button(`移除延时任务`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 10; ++i) {
              const startTime = systemDateTime.getTime(false)
              const delayTime = i * 100
              const pro = this.queue.postDelay(async () => {
                const endTime = systemDateTime.getTime(false)
                const duration = endTime - startTime
                Log.i(TAG, `post runnable 5 i=${i} duration=${duration}`)
                return `jiang peng yong 5 i=${i} duration=${duration}`
              }, delayTime)
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

        Button(`移除延时信息`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 10; ++i) {
              const delayTime = i * 100
              const pro = this.queue.sendMessageDelay({
                what: `jiang`,
                data: { name: 'jiang peng yong 6', age: 20 + i },
              }, delayTime)
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

        Button(`队列信息`)
          .onClick(async () => {
            Log.i(TAG, `【队列信息】${this.queue.dumpInfo()}`)
          }).margin(5)
      }.backgroundColor(`#BADFDB`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10,
      })
      .borderRadius(5)
    }.padding(5)
  }
}