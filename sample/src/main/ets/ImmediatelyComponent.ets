import { Any, Task, JSyncQueue } from 'jsyncqueue'
import { Log } from './Log'
import { ImmediatelyQueue } from './MyQueue'

const TAG = "ImmediatelyComponent"

@ComponentV2
export struct ImmediatelyComponent {
  private immediatelyQueue: JSyncQueue = new ImmediatelyQueue("ImmediatelyQueue")
  private immediatelyJSyncQueue: JSyncQueue = new JSyncQueue("ImmediatelyJSyncQueue")

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
        RelativeContainer() {
          Text(`直接使用JSyncQueue`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })

          Button(`队列信息`)
            .onClick(async () => {
              Log.i(TAG, `【队列信息】${this.immediatelyJSyncQueue.dumpInfo()}`)
            })
            .padding({ left: 7.5, right: 7.5 })
            .margin({ right: 2.5 })
            .fontSize(12)
            .height(30)
            .backgroundColor("#5B8A72")
            .alignRules({
              center: { anchor: "__container__", align: VerticalAlign.Center },
              right: { anchor: "__container__", align: HorizontalAlign.End },
            })
        }.width(`100%`)
        .height(50)

        Text(`直接使用 JSyncQueue 则无法处理 Message 类型消息。因为 Message 类型消息需要在队列内部的 onHandleMessage 方法接受进行处理。`)
          .width(`100%`)
          .fontColor("#3D6B6B")
          .fontSize(12)
          .textAlign(TextAlign.Start)
          .margin(2.5)

        Button(`添加5个Runnable`)
          .onClick(() => {
            for (let i = 0; i < 5; ++i) {
              const task = this.immediatelyJSyncQueue.post(async () => {
                const delayTime1 = Math.round(Math.random() * 500)
                Log.i(TAG, `【添加5个Runnable】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                await this.delay(delayTime1)

                if (i == 3) {
                  throw { message: "模拟异常" } as Error
                }

                const delayTime2 = Math.round(Math.random() * 500)
                Log.i(TAG, `【添加5个Runnable】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                await this.delay(delayTime2)

                return `jiangpengyong-添加5个Runnable ${i}`
              })
              task.getResult()
                .then((result) => {
                  Log.i(TAG, `【添加5个Runnable-执行成功】i=${i} result=${result}`)
                })
                .catch((e: Error) => {
                  Log.e(TAG, `【添加5个Runnable-执行异常】i=${i} e=${JSON.stringify(e)}`)
                })
                .finally(() => {
                  Log.i(TAG, `【添加5个Runnable-执行结束】i=${i}`)
                })
            }
          }).margin(5)

        Button(`移除Runnable`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 5; ++i) {
              const tempTask = this.immediatelyJSyncQueue.post(async () => {
                const delayTime1 = Math.round(Math.random() * 500)
                Log.i(TAG, `【移除Runnable】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                await this.delay(delayTime1)

                const delayTime2 = Math.round(Math.random() * 500)
                Log.i(TAG, `【移除Runnable】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                await this.delay(delayTime2)

                if (i == 2) {
                  throw { message: "模拟异常" } as Error
                }
                return `jiangpengyong-移除Runnable ${i}`
              })
              tempTask.getResult().then((result) => {
                Log.i(TAG, `【移除Runnable】执行成功 i=${i} result=${result}`)
              }).catch((e: Any) => {
                Log.e(TAG, `【移除Runnable】执行异常 i=${i} e=${JSON.stringify(e)}`)
              }).finally(() => {
                Log.i(TAG, `【移除Runnable】执行完成 i=${i}`)
              })
              if (i == 3) {
                task = tempTask
              }
            }
            Log.i(TAG, `【移除Runnable】取消任务 task=${JSON.stringify(task)}`)
            task?.cancel()
          }).margin(5)
      }.backgroundColor(`#BADFDB`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10,
      })
      .borderRadius({ topLeft: 5, topRight: 5 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`继承使用 JSyncQueue`)
            .width(`100%`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })

          Button(`队列信息`)
            .onClick(async () => {
              Log.i(TAG, `【队列信息】${this.immediatelyQueue.dumpInfo()}`)
            })
            .padding({ left: 7.5, right: 7.5 })
            .margin({ right: 2.5 })
            .fontSize(12)
            .backgroundColor("#8B4A4A")
            .height(30)
            .alignRules({
              center: { anchor: "__container__", align: VerticalAlign.Center },
              right: { anchor: "__container__", align: HorizontalAlign.End },
            })
        }.width(`100%`)
        .height(50)

        Button(`添加5个Runnable`)
          .onClick(() => {
            for (let i = 0; i < 5; ++i) {
              (this.immediatelyQueue.post(async () => {
                const delayTime1 = Math.round(Math.random() * 500)
                Log.i(TAG, `【添加5个Runnable】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                await this.delay(delayTime1)

                const delayTime2 = Math.round(Math.random() * 500)
                Log.i(TAG, `【添加5个Runnable】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                await this.delay(delayTime2)

                if (i == 2) {
                  throw { message: "模拟异常" } as Error
                }
                return `jiangpengyong-添加5个Runnable ${i}`
              })).getResult()
                .then((result) => {
                  Log.i(TAG, `【添加5个Runnable】执行成功 i=${i} result=${result}`)
                })
                .catch((e: Error) => {
                  Log.e(TAG, `【添加5个Runnable】执行异常 i=${i} e=${JSON.stringify(e)}`)
                })
                .finally(() => {
                  Log.i(TAG, `【添加5个Runnable】执行结束 i=${i}`)
                })
            }
          }).margin(5)

        Button(`移除Runnable`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 10; ++i) {
              const tempTask = this.immediatelyQueue.post(async () => {
                const delayTime1 = Math.round(Math.random() * 500)
                Log.i(TAG, `【移除Runnable】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                await this.delay(delayTime1)

                const delayTime2 = Math.round(Math.random() * 500)
                Log.i(TAG, `【移除Runnable】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                await this.delay(delayTime2)

                if (i == 3) {
                  throw { message: "模拟异常" } as Error
                }
                return `jiangpengyong-移除Runnable ${i}`
              })
              tempTask.getResult().then((result) => {
                Log.i(TAG, `【移除Runnable】执行成功 i=${i} result=${result}`)
              }).catch((e: Any) => {
                Log.e(TAG, `【移除Runnable】执行异常 i=${i} e=${JSON.stringify(e)}`)
              }).finally(() => {
                Log.i(TAG, `【移除Runnable】执行完成 i=${i}`)
              })
              if (i == 5) {
                task = tempTask
              }
            }
            Log.i(TAG, `【移除Runnable】取消任务 task=${JSON.stringify(task)}`)
            task?.cancel()
          }).margin(5)

        Button(`添加5个Message`)
          .onClick(async () => {
            for (let i = 0; i < 5; ++i) {
              const tempTask = this.immediatelyQueue.sendMessage({
                what: `say_hello`,
                data: { name: '江澎涌', age: 20 + i },
              })
              tempTask.getResult()
                .then((result) => {
                  Log.i(TAG, `【添加5个Message】执行成功 i=${i} result=${result}`)
                })
                .catch((e: Error) => {
                  Log.e(TAG, `【添加5个Message】执行异常 i=${i} e=${JSON.stringify(e)}`)
                })
                .finally(() => {
                  Log.i(TAG, `【添加5个Message】执行结束i=${i}`)
                })
            }
          }).margin(5)

        Button(`移除Message`)
          .onClick(async () => {
            let task: Task | undefined
            for (let i = 0; i < 5; ++i) {
              const tempTask = this.immediatelyQueue.sendMessage({
                what: `remove_message`,
                data: { name: 'jiang peng yong', age: 10 + i },
              })
              tempTask.getResult().then((result) => {
                Log.i(TAG, `【移除Message】执行成功 i=${i} result=${result}`)
              }).catch((e: Any) => {
                Log.e(TAG, `【移除Message】执行异常 i=${i} e=${JSON.stringify(e)}`)
              }).finally(() => {
                Log.i(TAG, `【移除Message】执行完成 i=${i}`)
              })
              if (i == 1) {
                task = tempTask
              }
            }
            Log.i(TAG, `【移除Message】取消任务 task=${JSON.stringify(task)}`)
            task?.cancel()
          }).margin(5)

        Button(`添加10个Message和Runnable`)
          .onClick(async () => {
            for (let i = 0; i < 10; ++i) {
              let task: Task
              if (i % 2 == 0) {
                task = this.immediatelyQueue.post(async () => {
                  const delayTime1 = Math.round(Math.random() * 500)
                  Log.i(TAG, `【添加10个Message和Runnable】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                  await this.delay(delayTime1)

                  const delayTime2 = Math.round(Math.random() * 500)
                  Log.i(TAG, `【添加10个Message和Runnable】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                  await this.delay(delayTime2)

                  if (i / 2 == 3) {
                    throw { message: "模拟异常" } as Error
                  }
                  return `小朋友-添加10个Message和Runnable ${i}`
                })
              } else {
                task = this.immediatelyQueue.sendMessage({
                  what: `say_hello`,
                  data: { name: '小朋友', age: i },
                })
              }
              task.getResult()
                .then((result) => {
                  Log.i(TAG, `【添加10个Message和Runnable】执行成功 i=${i} result=${result}`)
                })
                .catch((e: Error) => {
                  Log.e(TAG, `【添加10个Message和Runnable】执行异常 i=${i} e=${JSON.stringify(e)}`)
                })
                .finally(() => {
                  Log.i(TAG, `【添加10个Message和Runnable】执行结束 i=${i}`)
                })
            }
          }).margin(5)

        Button(`清空队列`)
          .onClick(async () => {
            for (let i = 0; i < 5; ++i) {
              const task = this.immediatelyQueue.post(async () => {
                const delayTime1 = Math.round(Math.random() * 500)
                Log.i(TAG, `【清空队列】执行逻辑 i=${i} 第一段 将会模拟耗时=${delayTime1}`)
                await this.delay(delayTime1)

                const delayTime2 = Math.round(Math.random() * 500)
                Log.i(TAG, `【清空队列】执行逻辑 i=${i} 第二段 将会模拟耗时=${delayTime2}`)
                await this.delay(delayTime2)

                return `小朋友-清空队列 ${i}`
              })
              task.getResult()
                .then((result) => {
                  Log.i(TAG, `【清空队列】执行成功 i=${i} result=${result}`)
                })
                .catch((e: Error) => {
                  Log.e(TAG, `【清空队列】执行异常 i=${i} e=${JSON.stringify(e)}`)
                })
                .finally(() => {
                  Log.i(TAG, `【清空队列】执行结束 i=${i}`)
                })
            }
            this.immediatelyQueue.clear()
          }).margin(5)

      }.backgroundColor(`#FFBDBD`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10,
      })
      .borderRadius({ bottomLeft: 5, bottomRight: 5 })
    }.padding(5)
  }

  private async delay(ms: number) {
    return new Promise<Any>(resolve => setTimeout(resolve, ms))
  }
}