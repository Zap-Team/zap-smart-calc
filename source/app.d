import dlangui;
import mixed;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
    Window window = Platform.instance.createWindow(
        "Smart calc", null, WindowFlag.Modal, 600, 407
    );
    window.mainWidget = buildApplication();

    window.show();
    return Platform.instance.enterMessageLoop();
}
