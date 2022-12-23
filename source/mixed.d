module mixed;

import dlangui;

import application;
import driver;

public T setDefaultStyle(T : Widget)(T widget)
{
    widget.padding(5);
    widget.margins(10);
    widget.fontSize(30);
    return widget;
}

public Button button(dstring text) 
{
    string id = to!string(text);

    Button button = new Button(id);
    button = setDefaultStyle!Button(button);

    button.text(text);
    button.minWidth(120);
    button.minHeight(85);

    return button;
}

public void resolveFromTQ(EditLine elInstance)
{
    // Fails with 'Invalid UTF-8 sequence (at index 1)'
    // when non-numeric expression is in the EditLine.
    ExecutionResult result = executeQuery(elInstance.text);

    debug 
    { 
        import std.stdio;
        writeln(result); 
    }

    if (result.isNaN())
        elInstance.text(result.message);
    else
        elInstance.text(result.asString);   
}

public Button setPadEvent(Button button, EditLine taskQuery)
{
    button.mouseEvent = delegate(Widget self, MouseEvent event)
    {
        if (event.action != MouseAction.ButtonUp)
            return true;

        if (self.id == "=")
            resolveFromTQ(taskQuery);
        else 
        {
            dstring tqOldText = taskQuery.text;
            taskQuery.text(tqOldText ~ self.text);
        }

        return true;
    };

    return button;
}

public T buildWidget(alias T)(Widget[] members...)
{
    auto base = new T();

    foreach (Widget member; members)
        base.addChild(member);

    return base;
}

public Widget buildApplication()
{
    TaskQuery taskQuery = new TaskQuery();
    Pad pad = new Pad(taskQuery);

    return buildWidget!VerticalLayout(
        taskQuery.instance,
        pad.getMain()
    );
}
