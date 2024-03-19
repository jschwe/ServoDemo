import hilog from '@ohos.hilog';
import simpleservo from 'libsimpleservo.so';

@Entry
@Component
struct Index {
  xComponentContext: object | undefined = undefined;
  xComponentAttrs: XComponentAttrs = {
    id: 'ServoDemo',
    type: XComponentType.SURFACE,
    libraryname: 'simpleservo'
  }
  urlToLoad: string = 'https://servo.org'
  build() {
    Column() {
      TextInput({placeholder:'URL',text: this.urlToLoad})
      .type(InputType.Normal)
        .onChange((value) => {
          this.urlToLoad = value
        })
        .onSubmit((EnterKeyType)=>{
          simpleservo.loadURL(this.urlToLoad)
          console.info('Load URL: ', this.urlToLoad)
        })
      XComponent(this.xComponentAttrs)
        .focusable(true)
        .onLoad((xComponentContext) => {
          this.xComponentContext = xComponentContext;
          console.info('ServoDemo XCOMPONENT onLoad enter');
        })
        .onDestroy(() => {
          console.info('ServoDemo XCOMPONENT onDestroy');
        })
    }
    .width('100%')
  }
}

interface XComponentAttrs {
  id: string;
  type: number;
  libraryname: string;
}