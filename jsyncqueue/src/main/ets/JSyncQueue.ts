import { Log } from "./Log"

const TAG = "JSyncQueue"

export type Any = null | undefined | Object | void

/**
 * 消息
 */
export interface Message {
  what: string // 消息类型
  data: Any // 消息数据
}

/**
 * 任务
 * 1、通过 cancel 取消任务
 * 2、通过 getResult 获取结果
 * 3、通过 getTaskId 获取任务 Id
 */
export interface Task {
  /**
   * 取消任务
   */
  cancel()

  /**
   * 获取结果，会返回 Promise 通过 then 或 await 进行获取结果
   */
  getResult(): Promise<Any>

  /**
   * 任务 Id ，整个队列唯一标识
   */
  getTaskId(): number
}

export interface JSyncQueueCancelException {
  message: string
}

export interface JSyncQueueException {
  message: string
}

/**
 * 同步队列
 */
export class JSyncQueue {
  readonly queueName: string
  // 任务 Id 生成器
  private taskIdCreator = new IdCreator()
  // 是否正在处理任务
  private isProcessing = false
  // 队列，按入队顺序存储任务 Id
  private queue = new Array<number>()
  // 任务信息，任务 Id <--> 任务
  private tasks = new Map<number, TaskInfo>()
  // 回复结果的 Promise ，任务 Id <--> Promise
  private pendingReplies = new Map<number, PromiseReply>()
  // 处理延时任务池
  private delayPool = new DelayPool(this, this.taskIdCreator)

  /**
   * 构造队列
   * @param queueName 队列名称
   */
  constructor(queueName: string) {
    this.queueName = queueName
  }

  /**
   * 发送消息
   * @param message 需要处理的消息
   * @returns 任务
   */
  sendMessage(message: Message): Task {
    return this.addTask(message, undefined)
  }

  /**
   * 发送延时消息
   * @param message 需要处理的消息
   * @param delay 延时时间，单位为毫秒
   * @returns 任务
   */
  sendMessageDelay(message: Message, delay: number): Task {
    return this.delayPool.sendMessageDelay(message, delay)
  }

  /**
   * 执行闭包
   * @param runnable 闭包
   * @returns 任务
   */
  post(runnable: Runnable): Task {
    return this.addTask(undefined, runnable)
  }

  /**
   * 执行延时闭包
   * @param runnable 闭包
   * @param delay 延时时间，单位为毫秒
   * @returns 任务
   */
  postDelay(runnable: Runnable, delay: number): Task {
    return this.delayPool.postDelay(runnable, delay)
  }

  /**
   * 清空所有的任务，等待的任务会以 reject 方式进行终止任务
   */
  clear() {
    this.queue.forEach((id) => {
      this.pendingReplies.get(id)?.reject({ message: `Cancel task by clear function.` } as JSyncQueueCancelException)
      this.pendingReplies.delete(id)
    })
    this.pendingReplies.forEach((item) => {
      item.reject({ message: `Cancel task by clear function.` } as JSyncQueueCancelException
      )
    })
    this.delayPool.clear()
    this.queue = []
    this.tasks.clear()
    this.pendingReplies.clear()
  }

  /**
   * 获取任务数量
   * @returns 任务数量
   */
  get length() {
    return this.queue.length
  }

  /**
   * 打印同步队列的信息
   */
  dump() {
    Log.i(TAG, `name=${this.queueName} isProcessing=${this.isProcessing} queue=${JSON.stringify(this.queue)} tasks=${this.tasks.size} pendingReplies=${this.pendingReplies.size}`)
  }

  /**
   * 取消任务
   * @param taskId 任务 Id
   */
  cancel(taskId: number) {
    this.delayPool.cancel(taskId)
    this.queue = this.queue.filter((item) => item != taskId)
    this.tasks.delete(taskId)
    this.pendingReplies.get(taskId)?.reject({ message: `Cancel task by cancel function.` } as JSyncQueueCancelException)
    this.pendingReplies.delete(taskId)
  }

  /**
   * 处理任务消息，子类通过继承 JSyncQueue ，实现 onHandleMessage 方法，进行对接收到的消息进行处理
   * @param message 消息
   * @param taskId 任务 Id
   * @returns 处理完的结果，会返回到入队的调用点
   */
  async onHandleMessage(message: Message, taskId: number): Promise<Any> {
    return undefined
  }

  /**
   * 添加任务
   * @param message 消息
   * @param runnable 闭包
   * @returns 任务
   */
  private addTask(message: Message | undefined, runnable: Runnable | undefined): Task {
    const taskId = this.taskIdCreator.obtain()
    const promise = new Promise((resolve: Function, reject: Function) => {
      // 记录信息
      this.pendingReplies.set(taskId, {
        resolve: resolve,
        reject: reject,
      })
      this.tasks.set(taskId, {
        taskId: taskId,
        message: message,
        runnable: runnable,
      })
      this.queue.push(taskId)
      // 真正处理
      this.process()
    })
    return new RealtimeTask(taskId, new WeakRef(this), promise)
  }

  /**
   * 真正处理任务
   * 1、保证同一时间只有一个任务正在处理，因为如果多个异步任务，其中有些异步任务挂起则会导致后面的任务先执行，导致顺序乱了
   * 2、需要在处理完任务后，检测队列中是否还有任务需要处理
   */
  private async process() {
    if (this.isProcessing || this.queue.length == 0) {
      return
    }
    this.isProcessing = true

    // 循环处理完队列中的任务
    while (this.queue.length > 0) {
      // 获取任务队列的第一个进行执行
      const taskId = this.queue.shift()
      if (taskId == undefined) {
        continue
      }
      const task = this.tasks.get(taskId)
      if (task == undefined) {
        continue
      }
      this.tasks.delete(taskId)
      const reply = this.pendingReplies.get(taskId)
      if (reply == undefined) {
        continue
      }
      this.pendingReplies.delete(taskId)
      try {
        var result: Any = undefined
        // 进行执行逻辑
        // 1、闭包执行完后返回
        // 2、消息分发到真正的处理消息的 JSyncQueue 子类
        if (task.runnable) {
          result = await task.runnable(taskId)
        } else if (task.message) {
          result = await this.onHandleMessage(task.message, taskId)
        }
        reply.resolve(result)
      } catch (error) {
        Log.e(TAG, `process failure. e=${error}`)
        reply.reject({ message: `process failure. e=${error}` } as JSyncQueueException)
      }
    }
    this.isProcessing = false
  }
}

// ====================================== 内部使用 ======================================
// 有问题的任务 Id
const ERROR_TASK_ID = -1

/**
 * 任务 Id 生成器
 */
class IdCreator {
  private id = 0

  obtain(): number {
    return this.id++
  }
}

// 闭包
type Runnable = (taskId: number) => Promise<Any>

/**
 * 任务信息
 */
interface TaskInfo {
  taskId: number // 任务 Id
  message: Message | undefined // 任务消息
  runnable: Runnable | undefined // 闭包
}

/**
 * Promise 回调的函数
 */
interface PromiseReply {
  resolve: Function
  reject: Function
}

/**
 * 立即执行的任务
 */
class RealtimeTask implements Task {
  protected taskId: number
  protected queue: WeakRef<JSyncQueue>
  protected promise: Promise<Any>

  constructor(taskId: number, queue: WeakRef<JSyncQueue>, promise: Promise<Any>) {
    this.taskId = taskId
    this.queue = queue
    this.promise = promise
  }

  cancel() {
    this.queue.deref()?.cancel(this.taskId)
  }

  async getResult(): Promise<Any> {
    return await this.promise
  }

  getTaskId(): number {
    return this.taskId
  }
}

/**
 * 延时任务
 */
class DelayTask implements Task {
  readonly taskId: number
  readonly timeId: number
  private queue: WeakRef<JSyncQueue>
  private proxyPromise: Promise<Any>
  private promiseReply: PromiseReply

  constructor(taskId: number, timeId: number, queue: WeakRef<JSyncQueue>) {
    this.taskId = taskId
    this.timeId = timeId
    this.queue = queue
    this.proxyPromise = new Promise<Any>((resolve: Function, reject: Function) => {
      this.promiseReply = {
        resolve: resolve,
        reject: reject,
      }
    })
    if (this.taskId == ERROR_TASK_ID || this.timeId == ERROR_TASK_ID) {
      Log.e(TAG, `【constructor】id 是无效的 taskId=${this.taskId} timeId=${this.timeId}`)
      this.promiseReply.reject({ message: `Error id is invalid.` } as JSyncQueueException)
    }
  }

  /**
   * 关联真正的 Promise
   * 只有真正的执行才有真正的 Promise ，需要将真正的 Promise 结果转发到代理的 Promise 上
   * @param realtimePromise 真正的 Promise
   */
  setRealtimePromise(realtimePromise: Task | undefined) {
    realtimePromise?.getResult().then((data) => {
      this.promiseReply.resolve(data)
    }).catch((error) => {
      this.promiseReply.reject(error)
    })
  }

  /**
   * 取消任务，会直接调用 reject
   * 1、取消定时任务
   * 2、拒绝代理 Promise
   * 3、如果已经执行，则进行队列取消
   */
  cancel() {
    clearTimeout(this.timeId)
    this.promiseReply.reject({ message: `Cancel task by cancel function.` } as JSyncQueueCancelException)
    this.queue.deref()?.cancel(this.taskId)
  }

  /**
   * 获取结果，因为是延时任务，所以获取的是代理 Promise
   */
  getResult(): Promise<Any> {
    return this.proxyPromise
  }

  /**
   * 获取任务 Id
   */
  getTaskId(): number {
    return this.taskId
  }
}

/**
 * 延迟池
 */
class DelayPool {
  // 延迟任务
  private delayTasks = new Map<number, DelayTask>()
  // 同步队列
  private syncQueue: WeakRef<JSyncQueue>
  // 任务 Id 创建器
  private idCreator: WeakRef<IdCreator>

  /**
   * 构造延迟池
   * @param syncQueue 同步队列
   * @param idCreator 任务 Id 构造器
   */
  constructor(syncQueue: JSyncQueue, idCreator: IdCreator) {
    this.syncQueue = new WeakRef(syncQueue)
    this.idCreator = new WeakRef(idCreator)
  }

  /**
   * 发送延时消息
   * @param message 延时消息
   * @param delay 延时时间，单位为毫秒
   * @returns 任务
   */
  sendMessageDelay(message: Message, delay: number): Task {
    return this.addTask(message, undefined, delay)
  }

  /**
   * 压入延时闭包
   * @param runnable 延时闭包
   * @param delay 延时时间，单位为毫秒
   * @returns 任务
   */
  postDelay(runnable: Runnable, delay: number): Task {
    return this.addTask(undefined, runnable, delay)
  }

  /**
   * 取消任务
   * @param taskId 任务 Id
   */
  cancel(taskId: number) {
    const timeId = this.delayTasks.get(taskId)?.timeId
    if (timeId != ERROR_TASK_ID) {
      clearTimeout(timeId)
    }
    this.delayTasks.delete(taskId)
  }

  /**
   * 添加延时任务
   * @param message 延时消息
   * @param runnable 延时闭包
   * @param delay 延时时间，单位为毫秒
   * @returns 延时任务
   */
  private addTask(message: Message | undefined, runnable: Runnable | undefined, delay: number): DelayTask {
    const idCreator = this.idCreator.deref()
    if (idCreator == undefined) {
      Log.e(TAG, `Id creator is undefined.`)
      const promise = new DelayTask(ERROR_TASK_ID, ERROR_TASK_ID, this.syncQueue)
      return promise
    }

    const taskId = idCreator.obtain()
    const timeId = setTimeout(async (taskId: number, message: Message | undefined, runnable: Runnable | undefined) => {
      const syncQueue = this.syncQueue.deref()
      if (syncQueue == undefined) {
        Log.e(TAG, `Sync queue is undefined.`)
        return
      }
      let realtimePromise: Task | undefined = undefined
      if (message != undefined) {
        realtimePromise = syncQueue.sendMessage(message)
      } else if (runnable != undefined) {
        realtimePromise = syncQueue.post(runnable)
      }
      if (realtimePromise) {
        this.delayTasks.get(taskId)?.setRealtimePromise(realtimePromise)
      }
    }, delay, taskId, message, runnable)
    const delayTask = new DelayTask(taskId, timeId, this.syncQueue)
    this.delayTasks.set(taskId, delayTask)
    return delayTask
  }

  /**
   * 清理所有延时任务
   */
  clear() {
    this.delayTasks.forEach((item) => {
      item.cancel()
    })
  }
}