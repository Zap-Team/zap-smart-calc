module application.pad;

import dlangui;

import application;
import mixed;

public final class Pad
{
private:
    Widget[] buildButtons()
    {
        Button[] buttons;
        dstring[] padSource = [
            "1"d, "2"d, "3"d, "+"d, "²"d,
            "4"d, "5"d, "6"d, "-"d, "√"d,
            "7"d, "8"d, "9"d, "*"d, "π"d,
            "0"d, "."d, "="d, "/"d, 
        ];
        
        foreach (dstring stringOf; padSource)
            buttons ~= setPadEvent(button(stringOf), taskQuery.instance);
        
        return cast(Widget[]) buttons;
    }

public:
    TaskQuery taskQuery;

    final this(TaskQuery taskQuery)
    {
        this.taskQuery = taskQuery;
    }

    Widget getMain()
    {
        Widget[] buttons = buildButtons();

        return buildWidget!VerticalLayout(
            buildWidget!HorizontalLayout(buttons[0 .. 5]),
            buildWidget!HorizontalLayout(buttons[5 .. 10]),
            buildWidget!HorizontalLayout(buttons[10 .. 15]),
            buildWidget!HorizontalLayout(buttons[15 .. $])
        );
    }
}
