module driver.parser;

import std.format;
import driver;

private class ParserHH
{
protected:
    Token[] tokens;
    uint position;

    final this(Token[] tokens)
    {
        this.tokens = tokens;
    }

    Token getToken(ubyte forwardOn = 0)
    {
        uint peekingPosition = position + forwardOn;

        if (peekingPosition >= tokens.length)
            return new Token("", TokenType.EOQ);

        return tokens[peekingPosition];
    }

    bool match(TokenType expectedType)
    {
        Token currentToken = getToken();

        if (currentToken.type != expectedType)
            return false;

        ++position;
        return true;
    }
}

/// FIXME: Must be refactored, cause do not 
/// execute squares and sqrts first, and 
/// fails when parsing trigonometry functions.
public final class Parser : ParserHH
{
private:
    Expression binaryOnLocal(alias previous, E)(string operator, E expression)
    {
        return new BinaryExpression(operator, expression, previous());
    }

    Expression additive()
    {
        Expression expression = multiplicative();

        while (true)
        {
            if (match(TokenType.ADD))
            {
                expression = binaryOnLocal!multiplicative("+", expression);
                continue;
            }
            if (match(TokenType.SUB))
            {
                expression = binaryOnLocal!multiplicative("-", expression);
                continue;
            }

            break;
        }

        return expression;
    }

    Expression multiplicative()
    {
        Expression expression = unary();

        while (true)
        {
            if (match(TokenType.SQUARE))
            {
                expression = binaryOnLocal!unary("^", expression);
                continue;
            }
            if (match(TokenType.MUL))
            {
                expression = binaryOnLocal!unary("*", expression);
                continue;
            }
            if (match(TokenType.DIV))
            {
                expression = binaryOnLocal!unary("/", expression);
                continue;
            }
            
            break;
        }

        return expression;
    }

    Expression unary()
    {
        if (match(TokenType.SQRT))
            return new UnaryExpression("&", primary());
        else if (match(TokenType.ADD))
            return new UnaryExpression("+", primary());
        else if (match(TokenType.SUB))
            return new UnaryExpression("-", primary());

        return primary();
    }

    Expression primary()
    {
        Token currentToken = getToken();

        if (match(TokenType.NUMBER))
            return new NumberExpression(currentToken.text);
        else if (match(TokenType.FUNCTION))
            return new FunctionExpression(currentToken.text, additive());
        else if (match(TokenType.LPAR))
        {
            Expression expression = additive();
            match(TokenType.RPAR);

            return expression;
        }

        return new VoidExpression();
    }

public:
    final this(Token[] tokens)
    {
        super(tokens);
    }

    ExecutionResult execute()
    {
        Expression expression = additive();
        return new ExecutionResult(
            "Task sucessfully completed.",
            expression.execute()
        );
    }
}

unittest
{
    import std.stdio;

    string query = "(204 - 6) + 4² - √144"; // Expecting: 202.
    writefln("\nTesting tokenizer and parser with query: '%s':", query);
    
    Tokenizer tokenizer = new Tokenizer(query);
    Token[] tokens = tokenizer.tokenize();
    writeln(tokens);

    Parser parser = new Parser(tokens);
    ExecutionResult result = parser.execute();

    writeln(result);
    writeln(result.message);
    writeln(result.asString);
    writeln(result.asNumber);
}
