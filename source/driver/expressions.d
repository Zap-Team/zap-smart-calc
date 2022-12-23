module driver.expressions;

import std.conv;
import std.math;

public interface Expression
{   
    public double execute();
}

public final class UnaryExpression : Expression
{
private:
    string operator;
    Expression expression;

public:
    final this(string operator, Expression expression)
    {
        this.operator = operator;
        this.expression = expression;
    }

    double execute()
    {
        double operand = expression.execute();

        switch (operator)
        {
            case "-":
                return -operand;
            case "&":
                return operand < 0 ? double.nan : sqrt(operand);
            default:
                return operand;
        }
    }

debug:
    override string toString() const
    {
        import std.format;
        return format("%s %s", operator, expression);
    }
}

public final class BinaryExpression : Expression
{
private:
    string operator;
    Expression left;
    Expression right;

public:
    final this(string operator, Expression left, Expression right)
    {
        this.operator = operator;
        this.left = left;
        this.right = right;
    }

    double execute()
    {
        double leftDouble = left.execute();
        double rightDouble = right.execute();

        // For catching divisions by zero.
        if (operator == "/" && rightDouble == 0)
            return double.nan;

        switch (operator)
        {
            case "+":
                return leftDouble + rightDouble;
            case "-":
                return leftDouble - rightDouble;
            case "*":
                return leftDouble * rightDouble;
            case "/":
                return leftDouble / rightDouble;
            case "^":
                return pow(leftDouble, rightDouble);
            default:
                return double.nan;
        }
    }

debug:
    override string toString() const
    {
        import std.format;
        return format("%s %s %s", left, operator, right);
    }
}

public final class NumberExpression : Expression
{
private:
    string value;

public:
    final this(string value)
    {
        this.value = value;
    }

    double execute()
    {
        try
            return parse!double(value);
        catch (Exception _)
            return double.nan;
    }

debug:
    override string toString() const
    {
        return value;
    }
}

/// @depreacted
public final class FunctionExpression : Expression
{
private:
    string name;
    Expression operand;

public:
    final this(string name, Expression operand)
    {
        this.name = name;
        this.operand = operand;

        debug
        {
            this.calculated = execute();
        }  
    }

    double execute()
    {
        double value = operand.execute();

        switch (name)
        {
            case "sin":
                return sin(value);
            case "cos":
                return cos(value);
            case "tan":
                return tan(value);
            case "cot":
                return cos(value) / sin(value); // Must be checked.
            default:
                return double.nan;
        }
    }

debug:
    double calculated;

    override string toString() const
    {
        return to!string(calculated);
    }
}

public final class VoidExpression : Expression
{
public:
    double execute()
    {
        return double.nan;
    }

    /// FIXME: Not tested how it's work 
    /// with 'debug' modifier yet.
    override string toString() const
    {
        import std.format;
        return format("VExpression(\"Actually this is bad ):\")");
    }
}
