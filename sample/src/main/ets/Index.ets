import { DelayComponent } from './DelayComponent'
import { ExamplesComponent } from './ExamplesComponent'
import { ImmediatelyComponent } from './ImmediatelyComponent'

@Entry
@Component
struct Index {
  build() {
    Scroll() {
      Column() {
        ImmediatelyComponent()
        DelayComponent()
        ExamplesComponent()
      }
      .justifyContent(FlexAlign.Start)
    }
    .height('100%')
    .width('100%')
  }
}