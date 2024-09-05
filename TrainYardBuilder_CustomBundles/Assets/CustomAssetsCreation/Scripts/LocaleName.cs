namespace CustomObjectsCreation
{
    [System.Serializable]
    public class LocaleName
    {
        public string LocaleId;
        public string Name;

        public LocaleName(string localeId, string name)
        {
            LocaleId = localeId;
            Name = name;
        }
    }
}