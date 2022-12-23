module application.task_query;

import std.algorithm;

import dlangui;

import constants;
import mixed;

public final class TaskQuery
{
public:
    EditLine instance;

    final this()
    {
        this.instance = new EditLine();
        instance.minHeight(40);
        instance = setDefaultStyle!EditLine(instance);

        instance.keyEvent = delegate(Widget self, KeyEvent event)
        {
            debug 
            {
                import std.stdio;
                writefln("Event key code: '%d'.", event.keyCode);
            }

            if (!watchingActions.canFind(event.action))
                return true;
            
            if (event.keyCode == 8) // 'Backspace' button: FIXME.
            {
                dstring oldText = self.text;
                
                if (oldText.length == 0)
                    return true;

                self.text(oldText[0 .. $ - 1]);
            }
            if (event.keyCode == 13) // 'Enter' button: FIXME.
                resolveFromTQ(instance);

            return true;
        };
    }
}
