using System;

namespace randomize
{
    public class WizardNameGenerator
    {

        private string[] firstNames = { "Harry", "Hermoine", "Ron", "Luna", "Dobby" };
        private string[] lastNames = { "Potter", "Granger", "Weasly", "Lovegood", "Elf" };

        public string Generate()
        {
            var firstNameIndex = GetRandomArrayIndex(firstNames);
            var lastNameIndex = GetRandomArrayIndex(lastNames);
            return string.Format("{0} {1}", firstNames[firstNameIndex], lastNames[lastNameIndex]);
        }

        private int GetRandomArrayIndex(Array array)
        {
            var random = new Random();
            return random.Next() % array.Length;
        }
    }
}