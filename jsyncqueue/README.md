# JSyncQueue

一个开箱即用的鸿蒙异步任务同步队列

项目地址：[https://github.com/zincPower/JSyncQueue](https://github.com/zincPower/JSyncQueue)

## 一、简介

在鸿蒙应用开发中，异步任务的顺序执行是一个常见需求。当多个异步任务需要按照特定顺序执行时，如果不加控制，可能会导致执行顺序混乱。

JSyncQueue 提供了一个简洁的解决方案：

- **顺序执行保证**：所有任务严格按照入队顺序执行，即使任务内部有异步操作也能保证顺序
- **双模式支持**：支持 "立即执行" 和 "延时执行"，满足不同场景需求
- **双任务模式**：支持 "Message 消息模式" 和 "Runnable 闭包模式"
- **任务取消和管理**：可随时取消指定任务或清空整个队列
- **Promise 集成**：通过 `getResult()` 获取任务执行结果，支持 `then/catch/finally`
- **可继承扩展**：通过继承 JSyncQueue 并重写 `onHandleMessage` 方法，实现自定义消息处理逻辑

项目架构如下图所示：

![](https://github.com/zincPower/JSyncQueue/blob/main/img/structure.png)

## 二、安装

```bash
ohpm install jsyncqueue
```

## 三、快速开始

### 3-1、基础使用

可以直接使用 JSyncQueue 无需继承，但仅支持 Runnable 模式（post/postDelay）。 

```typescript
import { JSyncQueue } from 'jsyncqueue'

// 创建队列
const queue = new JSyncQueue("MyQueue")

// 添加任务
queue.post(async (taskId) => {
  // 执行异步操作
  const result = await someAsyncOperation()
  return result
}).getResult().then((result) => {
  console.log(`任务完成: ${result}`)
}).catch((error) => {
  console.error(`任务失败: ${error}`)
})
```

### 3-2、继承使用

继承 JSyncQueue 后，既可以使用 Message 模式（sendMessage/sendMessageDelay）处理消息，也可以使用 Runnable 模式（post/postDelay）执行闭包。

```typescript
import { JSyncQueue, Message, Any } from 'jsyncqueue'

class MyQueue extends JSyncQueue {
  async onHandleMessage(message: Message, taskId: number): Promise<Any> {
    switch (message.what) {
      case "say_hello":
        const name = message.data["name"]
        return `你好，${name}！`
      default:
        return undefined
    }
  }
}

// 使用自定义队列
const queue = new MyQueue("MyQueue")
queue.sendMessage({
  what: "say_hello",
  data: { name: "小明" }
}).getResult().then((result) => {
  console.log(result) // 输出: 你好，小明！
})
```

## 四、核心概念

### 4-1、“立即执行” 和 “延时执行”

| 方法 | 说明 |
|------|------|
| `post(runnable)` | 立即将闭包加入队列执行 |
| `postDelay(runnable, delay)` | 延时指定毫秒后将闭包加入队列执行 |
| `sendMessage(message)` | 立即将消息加入队列执行 |
| `sendMessageDelay(message, delay)` | 延时指定毫秒后将消息加入队列执行 |

### 4-2、“Message 模式” 和 “Runnable 模式”

**Runnable 模式**：直接传入一个闭包函数，适合简单的一次性任务。
```typescript
queue.post(async (taskId) => {
  // 直接在闭包中编写执行逻辑
  return "任务结果"
})
```

**Message 模式**：发送消息到队列，由 `onHandleMessage` 方法处理，适合需要集中管理业务逻辑的场景。
```typescript
queue.sendMessage({
  what: "action_type",
  data: { key: "value" }
})
```

> 注意：直接使用 JSyncQueue 实例时，Message 模式的消息不会被处理（`onHandleMessage` 默认返回 `undefined`）。需要继承 JSyncQueue 并重写 `onHandleMessage` 方法才能处理消息。

## 五、API 文档

### 5-1、JSyncQueue 类

#### 构造函数

```typescript
constructor(queueName: string)
```

创建一个同步队列实例。

- `queueName`: 队列名称，用于标识和调试

#### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `post(runnable)` | `runnable: (taskId: number) => Promise<Any>` | `Task` | 立即执行闭包 |
| `postDelay(runnable, delay)` | `runnable: (taskId: number) => Promise<Any>`, `delay: number` | `Task` | 延时执行闭包，delay 单位为毫秒 |
| `sendMessage(message)` | `message: Message` | `Task` | 立即发送消息 |
| `sendMessageDelay(message, delay)` | `message: Message`, `delay: number` | `Task` | 延时发送消息，delay 单位为毫秒 |
| `cancel(taskId)` | `taskId: number` | `void` | 取消指定任务 |
| `clear()` | - | `void` | 清空队列中所有等待的任务 |
| `dumpInfo()` | - | `string` | 获取队列调试信息 |
| `onHandleMessage(message, taskId)` | `message: Message`, `taskId: number` | `Promise<Any>` | 消息处理方法，子类可重写 |

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `queueName` | `string` | 队列名称（只读） |
| `length` | `number` | 当前队列中的任务数量（只读） |

### 5-2、Message 接口

```typescript
interface Message {
  what: string   // 消息类型
  data: Any      // 消息数据
}
```

### 5-3、Task 接口

```typescript
interface Task {
  cancel(): void                  // 取消任务
  getResult(): Promise<Any>       // 获取任务结果
  getTaskId(): number            // 获取任务 ID
}
```

### 5-4、异常类型

#### JSyncQueueCancelException

任务被取消时抛出的异常。

```typescript
interface JSyncQueueCancelException {
  message: string
}
```

#### JSyncQueueException

队列内部错误时抛出的异常。

```typescript
interface JSyncQueueException {
  message: string
}
```

## 六、使用示例

### 6-1、直接使用 JSyncQueue + post()

适用于简单场景，直接使用闭包处理任务。

```typescript
import { JSyncQueue } from 'jsyncqueue'

const queue = new JSyncQueue("SimpleQueue")

// 添加多个任务，它们会按顺序执行
for (let i = 0; i < 5; i++) {
  queue.post(async (taskId) => {
    console.log(`开始执行任务 ${i}`)
    // 模拟异步操作
    await new Promise(resolve => setTimeout(resolve, 100))
    console.log(`完成任务 ${i}`)
    return `结果 ${i}`
  }).getResult().then((result) => {
    console.log(`任务 ${i} 返回: ${result}`)
  })
}
```

### 6-2、继承 JSyncQueue 自定义队列

适用于需要集中管理业务逻辑的场景，继承后同样支持 Runnable 模式。

```typescript
import { JSyncQueue, Message, Any } from 'jsyncqueue'

class UserQueue extends JSyncQueue {
  private userCount = 0

  async onHandleMessage(message: Message, taskId: number): Promise<Any> {
    switch (message.what) {
      case "register":
        this.userCount++
        const name = message.data["name"]
        // 模拟异步注册操作
        await this.simulateAsyncOperation()
        return `用户 ${name} 注册成功，当前用户数: ${this.userCount}`

      case "login":
        const username = message.data["username"]
        await this.simulateAsyncOperation()
        return `用户 ${username} 登录成功`

      default:
        return undefined
    }
  }

  private async simulateAsyncOperation() {
    return new Promise(resolve => setTimeout(resolve, 100))
  }
}

// 使用
const userQueue = new UserQueue("UserQueue")

userQueue.sendMessage({
  what: "register",
  data: { name: "张三" }
}).getResult().then(console.log)

userQueue.sendMessage({
  what: "login",
  data: { username: "张三" }
}).getResult().then(console.log)

// 继承后同样可以使用 post()
userQueue.post(async (taskId) => {
  console.log("执行自定义闭包任务")
  return "闭包任务完成"
}).getResult().then(console.log)
```

### 6-3、延时执行示例

```typescript
import { JSyncQueue } from 'jsyncqueue'

const queue = new JSyncQueue("DelayQueue")

// 延时 1 秒后执行
queue.postDelay(async (taskId) => {
  console.log("延时任务执行了")
  return "延时任务结果"
}, 1000).getResult().then((result) => {
  console.log(`延时任务返回: ${result}`)
})

// 延时发送消息（需要继承实现 onHandleMessage）
queue.sendMessageDelay({
  what: "delayed_action",
  data: { info: "延时消息" }
}, 2000)
```

### 6-4、任务取消示例

```typescript
import { JSyncQueue, Task, JSyncQueueCancelException } from 'jsyncqueue'

const queue = new JSyncQueue("CancelQueue")

// 添加任务并保存引用
const task: Task = queue.post(async (taskId) => {
  console.log("任务开始执行")
  await new Promise(resolve => setTimeout(resolve, 5000))
  return "任务完成"
})

// 监听任务结果
task.getResult().then((result) => {
  console.log(`任务成功: ${result}`)
}).catch((error: JSyncQueueCancelException) => {
  console.log(`任务被取消: ${error.message}`)
})

// 取消任务（两种方式）
task.cancel()                    // 方式1：通过 Task 对象取消
// queue.cancel(task.getTaskId()) // 方式2：通过队列和任务ID取消

// 清空所有任务
// queue.clear()
```

### 6-5、混合使用示例

Message 和 Runnable 可以混合使用，它们都会按入队顺序执行。

```typescript
import { JSyncQueue, Message, Any } from 'jsyncqueue'

class MixedQueue extends JSyncQueue {
  async onHandleMessage(message: Message, taskId: number): Promise<Any> {
    console.log(`处理消息: ${message.what}`)
    return `消息 ${message.what} 处理完成`
  }
}

const queue = new MixedQueue("MixedQueue")

// 混合添加任务
queue.post(async () => {
  console.log("Runnable 1")
  return "R1"
})

queue.sendMessage({ what: "msg1", data: null })

queue.post(async () => {
  console.log("Runnable 2")
  return "R2"
})

queue.sendMessage({ what: "msg2", data: null })

// 执行顺序：Runnable 1 -> msg1 -> Runnable 2 -> msg2
```

## 七、作者简介

### 7-1、个人博客

掘金：https://juejin.im/user/5c3033ef51882524ec3a88ba/posts

csdn：https://blog.csdn.net/weixin_37625173

公众号：微信搜索 "江澎涌" ，或扫描二维码

![](https://github.com/zincPower/JSyncQueue/blob/main/img/officialaccount.jpg)

### 7-2、赞赏

如果觉得 JSyncQueue 对你有帮助或启发，请我喝杯水果茶吧 😄

![](https://github.com/zincPower/JSyncQueue/blob/main/img/pay.jpg)