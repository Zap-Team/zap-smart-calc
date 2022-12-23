module driver.tokens;

public enum TokenType
{
    // Simulation of "data types":
    NUMBER,
    FUNCTION,

    // Control types:
    ADD,
    SUB,
    MUL,
    DIV,
    LPAR,
    RPAR,
    SQRT, // TODO: Implement me!
    SQUARE, // TODO: Implement me!
    
    // Core necessary types:
    ERRONEOUS,
    EOQ
}

public final class Token
{
public: 
    const string text;
    const TokenType type;

    final this(string text, TokenType type)
    {
        this.text = text;
        this.type = type;
    }

    override string toString() const
    {
        return text;
    }
}
