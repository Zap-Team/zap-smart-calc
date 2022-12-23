module driver.utils;

import std.algorithm;
import std.array;
import std.conv;
import std.format;

import driver;

private dstring trimResult(double number)
{
    string stringOf = format("%f", number);

    while (stringOf[$ - 1] == '0')
    {
        byte slicingIndex = stringOf[$ - 2] == '.' ? 2 : 1;
        stringOf = stringOf[0 .. $ - slicingIndex];
    }
    
    return to!dstring(stringOf);
}

unittest
{
    assert(trimResult(13.0032000) == "13.0032"d);
    assert(trimResult(1.047197551) == "1.047198"d);
}

public final class ExecutionResult
{
public:
    const dstring message;
    const dstring asString;
    const double asNumber;

    final this(string message, double asNumber = double.nan)
    {
        this.message = to!dstring(message);
        this.asString = trimResult(asNumber);
        this.asNumber = asNumber;
    }

    bool isNaN()
    {
        return asNumber is double.nan;
    }

debug:
    override string toString() const
    {
        import std.format;
        return format("ExecutionResult(\"%s\", \"%s\", %f)", message, asString, asNumber);
    }
}

public ExecutionResult erroneousResult(T...)(string message, T args)
{
    return new ExecutionResult(format(message, args));
}

public ExecutionResult executeQuery(dstring query)
{
    string stringQuery = to!string(query);

    Tokenizer tokenizer = new Tokenizer(stringQuery);
    Token[] tokens = tokenizer.tokenize();

    foreach (Token token; tokens)
    {
        if (token.type == TokenType.ERRONEOUS)
            return erroneousResult("Ошибка в выражении: '%s'.", token);
    }

    Parser parser = new Parser(tokens);
    ExecutionResult result = parser.execute();

    return result.isNaN() 
        ? erroneousResult("Введено некорректное выражение.")
        : result;
}

unittest
{
    import std.stdio;
    writeln("\nTesting 'executeQuery' with correct and erroneous queries:");

    ExecutionResult soft = executeQuery("112 - √144 + (177 * -2) + 100"d); // Expecting: −154.
    ExecutionResult hard = executeQuery("1.1.1 + 1"d); // Expecting error.

    writefln(
        "Correct:\n%s\nMessage: %s\nAs string: %s\nAs number: %f", 
        soft, soft.message, soft.asString, soft.asNumber
    );
    writefln(
        "\nErroneous:\n%s\nMessage: %s\nAs string: %s\nAs number: %f", 
        hard, hard.message, hard.asString, hard.asNumber
    );

    assert(hard.isNaN());
}
