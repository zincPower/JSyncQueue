import { DelayComponent } from './DelayComponent'
import { ImmediatelyComponent } from './ImmediatelyComponent'

@Entry
@Component
struct Index {
  build() {
    Scroll() {
      Column() {
        ImmediatelyComponent()
        DelayComponent()
      }
      .justifyContent(FlexAlign.Start)
    }
    .height('100%')
    .width('100%')
  }
}