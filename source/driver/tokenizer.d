module driver.tokenizer;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.string;
import std.uni;

import constants;
import driver;

private string replaceReservedChars(string query)
{
    foreach (string character, pair; reservedCharsAA)
    {
        while (query.canFind(character))
            query = query.replace(character, pair);
    }

    return query;
}

private bool isReservedCharacter(char character)
{
    return reservedChars.canFind(character);
}

private TokenType defineOperatorType(char character)
{
    switch (character)
    {
        case '+':
            return TokenType.ADD;
        case '-':
            return TokenType.SUB;
        case '*':
            return TokenType.MUL;
        case '/':
            return TokenType.DIV;
        case '&':
            return TokenType.SQRT;
        case '^':
            return TokenType.SQUARE;
        case '(':
            return TokenType.LPAR;
        case ')':
            return TokenType.RPAR;
        default:
            return TokenType.ERRONEOUS;
    }
}

private double defineCharacterValue(char character)
{
    switch (character)
    {
        case 'P':
            return PI;
        case 'e':
            return E;
        default:
            return double.nan;
    }
}

private class TokenizerHH
{
protected:
    string query;
    uint position;
    Token[] tokens;

    void addToken(string text, TokenType type)
    {
        tokens ~= new Token(text, type);
    }

    char peek(ubyte forwardOn = 0)
    {
        uint peekingPosition = position + forwardOn;

        if (peekingPosition >= query.length)
            return '\0';

        return query[peekingPosition];
    }

    char next()
    {
        ++position;
        return peek();
    }

    final this(string query)
    {
        this.query = query;
    }
}

public final class Tokenizer : TokenizerHH
{
private:
    void tokenizeNumber()
    {
        string buffer;
        char currentChar = peek();
        TokenType type = TokenType.NUMBER;

        while (true)
        {
            if (currentChar == '.')
            {
                if (buffer.indexOf(".") != -1)
                    type = TokenType.ERRONEOUS;
            }
            else if (!isNumber(currentChar))
                break;

            buffer ~= currentChar;
            currentChar = next();
        }

        addToken(buffer, type);
    }

    void tokenizeOperator()
    {
        char currentChar = peek();
        TokenType type = defineOperatorType(currentChar);

        addToken(to!string(currentChar), type);
        ++position;
    }

    void tokenizeRCharacter() 
    {
        char currentChar = peek();
        double value = defineCharacterValue(currentChar);
        
        addToken(to!string(value), TokenType.NUMBER);
        ++position;
    }

    void tokenizeFunction()
    {
        string[] knownFunctions = [
            "sin", "cos", "tan", "cot"
        ];

        string buffer;
        char currentChar = peek();
        TokenType type = TokenType.FUNCTION;

        while (true)
        {
            if (!isAlpha(currentChar))
                break;

            buffer ~= currentChar;
            currentChar = next();
        }

        if (!knownFunctions.canFind(buffer))
            type = TokenType.ERRONEOUS;
        
        addToken(buffer, type);
    }

public:
    final this(string query)
    {
        super(replaceReservedChars(query));
    }

    Token[] tokenize()
    {
        while (position < query.length)
        {
            char currentChar = peek();

            if (isNumber(currentChar))
                tokenizeNumber();
            else if (isReservedCharacter(currentChar))
                tokenizeRCharacter();
            else if (isAlpha(currentChar))
                tokenizeFunction();
            else if (isWhite(currentChar))
                ++position;
            else
                tokenizeOperator();
        }

        return tokens;
    }
}

unittest
{
    import std.stdio;

    string query = "sin0.523598776 * 2 + π - 2²";
    writefln("\nTesting tokenizer with query: '%s':", query);

    Tokenizer tokenizer = new Tokenizer(query);
    Token[] tokens = tokenizer.tokenize();

    writeln(tokens);
}
