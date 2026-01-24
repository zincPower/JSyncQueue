import { Any, JSyncQueue } from 'jsyncqueue'
import { Log } from './Log'
import { UserQueue, MixedQueue } from './MyQueue'

const TAG = "ExamplesComponent"

@ComponentV2
export struct ExamplesComponent {
  private simpleQueue: JSyncQueue = new JSyncQueue("SimpleQueue")
  private userQueue: UserQueue = new UserQueue("UserQueue")
  private delayQueue: JSyncQueue = new JSyncQueue("DelayQueue")
  private cancelQueue: JSyncQueue = new JSyncQueue("CancelQueue")
  private mixedQueue: MixedQueue = new MixedQueue("MixedQueue")

  build() {
    Column() {
      Text(`JSyncQueue 使用示例`)
        .width(`100%`)
        .fontColor(Color.Black)
        .fontWeight(800)
        .fontSize(22)
        .textAlign(TextAlign.Center)
        .margin(5)

      // 直接使用 JSyncQueue + post()
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`直接使用 JSyncQueue + post()`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })
        }.width(`100%`)
        .height(40)

        Text(`适用于简单场景，直接使用闭包处理任务`)
          .width(`100%`)
          .fontColor("#2E7D32")
          .fontSize(12)
          .textAlign(TextAlign.Start)
          .margin(2.5)

        Button(`执行5个任务`)
          .onClick(async () => {
            for (let i = 1; i <= 5; i++) {
              this.simpleQueue.post(async () => {
                Log.i(TAG, `【示例1】任务 ${i} 开始执行`)
                await this.delay(200)
                Log.i(TAG, `【示例1】任务 ${i} 执行完成`)
                return `任务 ${i} 结果`
              }).getResult().then((result) => {
                Log.i(TAG, `【示例1】任务 ${i} 返回: ${result}`)
              })
            }
          }).margin(5)
      }.backgroundColor(`#BADFDB`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10
      })
      .borderRadius(5)
      .margin({ bottom: 5 })

      // 继承 JSyncQueue 自定义队列
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`继承 JSyncQueue 自定义队列`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })
        }.width(`100%`)
        .height(40)

        Text(`适用于需要集中管理业务逻辑的场景`)
          .width(`100%`)
          .fontColor("#8B4A4A")
          .fontSize(12)
          .textAlign(TextAlign.Start)
          .margin(2.5)

        Button(`注册用户`)
          .onClick(async () => {
            this.userQueue.sendMessage({
              what: "register",
              data: { name: "张三" }
            }).getResult().then((result) => {
              Log.i(TAG, `【示例2】${result}`)
            })
          }).margin(5)

        Button(`登录用户`)
          .onClick(async () => {
            this.userQueue.sendMessage({
              what: "login",
              data: { username: "zhangsan" }
            }).getResult().then((result) => {
              Log.i(TAG, `【示例2】${result}`)
            })
          }).margin(5)

        Button(`执行闭包任务`)
          .onClick(async () => {
            this.userQueue.post(async () => {
              Log.i(TAG, `【示例2】闭包任务开始执行`)
              await this.delay(100)
              return "闭包任务完成"
            }).getResult().then((result) => {
              Log.i(TAG, `【示例2】${result}`)
            })
          }).margin(5)
      }.backgroundColor(`#FFBDBD`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10
      })
      .borderRadius(5)
      .margin({ bottom: 5 })

      // 延时执行示例
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`延时执行示例`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })
        }.width(`100%`)
        .height(40)

        Button(`延时1秒执行`)
          .onClick(async () => {
            Log.i(TAG, `【示例3】添加延时任务，1秒后执行`)
            this.delayQueue.postDelay(async () => {
              Log.i(TAG, `【示例3】延时1秒后，任务执行了！`)
              return "延时任务完成"
            }, 1000).getResult().then((result) => {
              Log.i(TAG, `【示例3】${result}`)
            })
          }).margin(5)

        Button(`延时发送消息`)
          .onClick(async () => {
            Log.i(TAG, `【示例3】添加延时消息，2秒后执行`)
            this.delayQueue.sendMessageDelay({
              what: "delayed_msg",
              data: { content: "这是延时消息" }
            }, 2000).getResult().then(() => {
              Log.i(TAG, `【示例3】延时消息已处理`)
            })
          }).margin(5)
      }.backgroundColor(`#D4E6F1`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10
      })
      .borderRadius(5)
      .margin({ bottom: 5 })

      // 任务取消示例
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`任务取消示例`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })
        }.width(`100%`)
        .height(40)

        Button(`添加并取消任务`)
          .onClick(async () => {
            const task = this.cancelQueue.postDelay(async () => {
              Log.i(TAG, `【示例4】这个任务不会执行，因为被取消了`)
              return "任务结果"
            }, 3000)
            Log.i(TAG, `【示例4】添加了一个3秒后执行的任务`)
            setTimeout(() => {
              task.cancel()
              Log.i(TAG, `【示例4】任务已取消`)
            }, 1000)
          }).margin(5)

        Button(`清空所有任务`)
          .onClick(async () => {
            // 先添加几个任务
            for (let i = 1; i <= 3; i++) {
              this.cancelQueue.postDelay(async () => {
                Log.i(TAG, `【示例4】任务 ${i} 执行`)
                return `任务 ${i}`
              }, i * 1000)
            }
            Log.i(TAG, `【示例4】添加了3个延时任务`)
            setTimeout(() => {
              this.cancelQueue.clear()
              Log.i(TAG, `【示例4】已清空所有任务`)
            }, 500)
          }).margin(5)
      }.backgroundColor(`#FCF3CF`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10
      })
      .borderRadius(5)
      .margin({ bottom: 5 })

      // 混合使用示例
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        RelativeContainer() {
          Text(`混合使用示例`)
            .fontColor(Color.White)
            .fontWeight(800)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin(2.5)
            .width(`100%`)
            .alignRules({ center: { anchor: "__container__", align: VerticalAlign.Center } })
        }.width(`100%`)
        .height(40)

        Text(`Message 和 Runnable 可以混合使用，都会按入队顺序执行`)
          .width(`100%`)
          .fontColor("#6A1B9A")
          .fontSize(12)
          .textAlign(TextAlign.Start)
          .margin(2.5)

        Button(`混合执行任务`)
          .onClick(async () => {
            // 交替添加 Runnable 和 Message
            this.mixedQueue.post(async () => {
              Log.i(TAG, `【示例5】Runnable 1 执行`)
              await this.delay(100)
              return "Runnable 1 完成"
            })

            this.mixedQueue.sendMessage({
              what: "msg_1",
              data: {}
            })

            this.mixedQueue.post(async () => {
              Log.i(TAG, `【示例5】Runnable 2 执行`)
              await this.delay(100)
              return "Runnable 2 完成"
            })

            this.mixedQueue.sendMessage({
              what: "msg_2",
              data: {}
            })

            Log.i(TAG, `【示例5】已添加 2 个 Runnable 和 2 个 Message，将按顺序执行`)
          }).margin(5)
      }.backgroundColor(`#E8DAEF`)
      .padding({
        left: 5,
        top: 10,
        right: 5,
        bottom: 10
      })
      .borderRadius(5)
    }.padding(5)
  }

  private async delay(ms: number) {
    return new Promise<Any>(resolve => setTimeout(resolve, ms))
  }
}
