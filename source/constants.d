module constants;

import dlangui;

/// We've tried to use lambdas - it's impossible.
@property
public string[string] reservedCharsAA()
{
    return ["π": "P", "²": "^ 2", "√": "&"];
}
public const char[] reservedChars = ['P', 'e'];
public const KeyAction[] watchingActions = [KeyAction.KeyUp, KeyAction.Repeat];
