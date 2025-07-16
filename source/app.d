import std.stdio,
       std.algorithm,
       std.random,
       std.conv,
       dasfor;

enum Flags
{
    none,
    luck,
    damage,
    honour
}

Random r;

enum minimumDieValue  = 1;
enum d20SuperiorCrits = [18, 19, 20];
enum d20InferiorCrits = [1, 2, 3];
enum d6SuperiorCrits  = [5, 6];
enum d6InferiorCrits  = [1, 2];
auto roll(int die) { return uniform(minimumDieValue, die + 1, r); }

void printError()
{
    "Erreur: Paramètres invalides. Usage correct: « chipon-de [type de dé] [quantité de dé] [optionnel: c/d/h] »".writeln;
    "Info: Si vous utilisez le drapeau c ou h, le premier paramètre devient la valeur actuelle.".writeln;
}

void main(string[] args)
{
    r = Random(unpredictableSeed);

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
        case Flags.none:

            if (dieType != 6 && dieType != 20)
            {
                "Erreur: type de dé invalide pour un test d'attribut. Les dés valides sont 6 et 20.".writeln;
                return;
            }

            for (int i; i < dieQuantity; ++i)
            {
                auto result = dieType.roll;

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

            if (hasMinLowerBound) "Dés inférieurs: $0/$1".daswriteln(inferiorCrits, dieQuantity);
            if (hasMinUpperBound) "Dés supérieurs: $0/$1".daswriteln(superiorCrits, dieQuantity);

            daswriteln
            (
                "Le résultat est un jet $0 de $1",
                cast(double)inferiorCrits / dieQuantity * 100 < 50 ?
                cast(double)superiorCrits / dieQuantity * 100 < 50 ?
                "normal" :
                "critique supérieur" :
                "critique inférieur",
                total
            );
            break;

        case Flags.luck:

            total = 12.roll;
            bool isLucky;

            if (dieType < 0) isLucky = total > dieType * -1;
            else isLucky = total < dieType;
            writeln(isLucky ? "Le joueur est chanceux" : "Le joueur est malchanceux");
            break;

        case Flags.honour:

            total = dieType.roll;
            writeln(total < dieType ? "Le joueur demeure honorable" : "Le joueur est déshonoré");
            break;

        case Flags.damage:

            for (int i; i < dieQuantity; ++i)
                total += dieType.roll;

            "Le résultat du jet de dés est $0".daswriteln(total);
            break;
    }
}
