namespace UniversalBridge
{
    class ItemPair
    {
        public string name;
        public int count;
        public ItemPair(string n, int c)
        {
            name = n;
            count = c;
        }

        public void incCount(int x)
        {
            count += x;
        }
    }
}
