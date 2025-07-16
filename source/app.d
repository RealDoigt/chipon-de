import std.stdio,
       std.random,
       std.conv;

enum Flags
{
    none,
    luck,
    damage,
    honour
}

auto r = Random(unpredictableSeed);

enum minimumDieValue  = 1;
enum d20SuperiorCrits = [18, 19, 20];
enum d20InferiorCrits = [1, 2, 3];
enum d6SuperiorCrits  = [5, 6];
enum d6InferiorCrits  = [1, 2];
enum roll(int die) = uniform(minimumDieValue, die + 1, r);

void printError()
{
    "Erreur: Paramètres invalides. Usage correct: « chipon-de [type de dé] [quantité de dé] [optionnel: c/d/h] »".writeln;
    "Info: Si vous utilisez le drapeau c ou h, le premier paramètre devient la valeur actuelle.".writeln;
}

void main(string[] args)
{
    if (args.length < 3)
    {
        printError;
        return;
    }

    auto flag = Flags.none;

    if (args.length == 4)
    {
        switch(args[3])
        {
            case "c": flag = Flags.luck; break;
            case "d": flag = Flags.damage; break;
            case "h": flag = Flags.honour; break;

            default:
                "Erreur: drapeau non reconnu. Les drapeaux valides sont c, d et h.".writeln;
                return;
        }
    }

    const dieType = to!int(args[1]), dieQuantity = to!int(args[2]);
    scope (failure) printError;

    auto hasMinUpperBound = false,
         hasMinLowerBound = false,
         inferiorCrits = 0,
         superiorCrits = 0,
         total = 0;

    final switch (flag)
    {
        case flags.none:

            if (dieType != 6 && dieType != 20)
            {
                "Erreur: type de dé invalide pour un test d'attribut. Les dés valides sont 6 et 20.".writeln;
                return;
            }

            for (int i; i < dieQuantity; ++i)
            {
                auto result = roll!dieType;

                if (result == dieType - 1)
                    hasMinUpperBound = true;

                if (result == minimumDieValue)
                    hasMinLowerBound = true;

                if (dieType == 6)
                {
                    if (d6InferiorCrits.canFind(result))
                        ++inferiorCrits;

                    if (d6SuperiorCrits.canFind(result))
                        ++superiorCrits;
                }

                else
                {
                    if (d20InferiorCrits.canFind(result))
                        ++inferiorCrits;

                    if (d20SuperiorCrits.canFind(result))
                        ++superiorCrits;
                }

                total += result;
            }


    }
}
