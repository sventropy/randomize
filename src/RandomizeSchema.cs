using GraphQL.Types;

namespace randomize
{
    public class RandomizeSchema : Schema
    {
        public RandomizeSchema()
        {
            Query = new RandomizeQuery();
        }
    }

    public class RandomizeQuery : ObjectGraphType
    {
        public RandomizeQuery()
        {
            Field<StringGraphType>("wizardName", resolve: context => new WizardNameGenerator().Generate());
        }
    }
}