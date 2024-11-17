import { common } from '@kit.AbilityKit';
import display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';
import { ShowDialogSuccessResponse } from '@kit.ArkUI';

interface ServoXComponentInterface {
  loadURL(url: string): void;
  goBack(): void;
  goForward(): void;
  registerURLcallback(callback: (url: string) => void): void;
  registerPromptToastCallback(callback: (msg: string) => void): void
  // See signature of `show_dialog()` for the callback signature
  registerPromptDialogCallback(callback: (msg: string, labels: string[]) => Promise<ShowDialogSuccessResponse>): void
  initServo(options: InitOpts): void;
}

interface InitOpts {
  url: string;
  deviceType: string,
  osFullName: string,
  resourceDir: string,
  displayDensity: number,
  commandlineArgs: string,
}

function get_density(): number {
    try {
      let displayClass = display.getDefaultDisplaySync();
      console.info('Test densityDPI:' + JSON.stringify(displayClass.densityDPI));
      return displayClass.densityDPI / 160;
  } catch (exception) {
      console.error('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
      return 3;
  }
}

function get_device_type(): string {
  let device_type: string = deviceInfo.deviceType;
  if (device_type == "") {
      console.error("deviceInfo.deviceType is empty string!")
  } else {
    console.info("Device type is " + device_type)
  }
  return device_type;
}

function prompt_toast(msg: string) {
    promptAction.showToast({
      message: msg,
      duration: 2000
    });
}

type DialogButtonResult = number | null;

// todo: AsyncCallback<ShowDialogSuccessResponse>
function show_dialog(message: string, labels: string[] /*, callback: (err: number | null, pressed_button: number | null) => undefined
*/
):  Promise<ShowDialogSuccessResponse> {
  try {
    let index = promptAction.showDialog( {
      title: 'A servoshell dialog',
      message: message,
      // Todo: Figure out how to use `map` or similar to create buttons from the labels array
      buttons: [
        {
          text: labels[0],
          color: '#000000'
        },
        {
          text: labels[1],
          color: '#000000'
        }
      ]
    } /*, (err, data) => {
      if (err) {
        console.info('showDialog err: ' + err);
        callback(err.code, null)
      } else {
        console.info('showDialog success callback, click button: ' + data.index);
        callback(null, data.index)
      }
    } */);
    return index;
  // } catch (error) {
  //   let message = (error as BusinessError).message
  //   let code = (error as BusinessError).code
  //   console.error(`showDialog args error code is ${code}, message is ${message}`);
  //   return Promise.
  //   // todo: also callback servo on exception
  }
}

// Use the getShared API to obtain the LocalStorage instance shared by stage.
let storage = LocalStorage.getShared()

@Entry(storage)
@Component
struct Index {
  xComponentContext: ServoXComponentInterface | undefined = undefined;
  xComponentAttrs: XComponentAttrs = {
    id: 'ServoDemo',
    type: XComponentType.SURFACE,
    libraryname: 'servoshell',
  }

  private context = getContext(this) as common.UIAbilityContext;
  @LocalStorageProp('InitialURI') InitialURI: string = "unused"
  @LocalStorageProp('CommandlineArgs') CommandlineArgs: string = ""
  @State urlToLoad: string = this.InitialURI

  build() {
    Column() {
      Row() {
        Button('⇦').backgroundColor(Color.White)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bolder)
          .width('12%')
          .fontSize(12)
          .onClick(()=>{
            this.xComponentContext?.goBack()
          })
        Button('⇨').backgroundColor(Color.White)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bolder)
          .fontSize(12)
          .width('12%')
          .onClick(()=> {
            this.xComponentContext?.goForward()
          })
        TextInput({placeholder:'URL',text: $$this.urlToLoad})
          .type(InputType.Normal)
          .width('76%')
          .onChange((value) => {
            this.urlToLoad = value
          })
          .onSubmit((EnterKeyType)=>{
            this.xComponentContext?.loadURL(this.urlToLoad)
            console.info('Load URL: ', this.urlToLoad)
          })
      }
      XComponent(this.xComponentAttrs)
        .focusable(true)
        .onLoad((xComponentContext) => {
          this.xComponentContext = xComponentContext as ServoXComponentInterface;
          let resource_dir: string = this.context.resourceDir;
          console.debug("Resources are located at %{public}s", resource_dir);
          let init_options: InitOpts = {
            url: this.urlToLoad,
            deviceType: get_device_type(),
            osFullName: deviceInfo.osFullName,
            displayDensity: get_density(),
            resourceDir: resource_dir,
            commandlineArgs: this.CommandlineArgs
          }
          this.xComponentContext.initServo(init_options)
          this.xComponentContext.registerURLcallback((new_url) => {
            console.info('New URL from native: ', new_url)
            this.urlToLoad = new_url
          })
          this.xComponentContext.registerPromptToastCallback(prompt_toast)
          this.xComponentContext.registerPromptDialogCallback(show_dialog)
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