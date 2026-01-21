import { DelayComponent } from './DelayComponent'
import { ImmediatelyComponent } from './ImmediatelyComponent'

@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      Column() {
        ImmediatelyComponent()
        DelayComponent()
      }.width(`100%`)
      .height(`100%`)
      .justifyContent(FlexAlign.Start)
    }
    .height('100%')
    .width('100%')
  }
}