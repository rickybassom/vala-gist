namespace ValaGist{
    public interface Profile : Object {
        public abstract string id { get; internal set; }
        public abstract string name { get; internal set; }
        public abstract GenericArray<Gist> gists { get; internal set; }

        public abstract GenericArray<Gist> list_all();

    }
}
