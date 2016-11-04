namespace ValaGist {

    public interface Profile : Object {
        public abstract string id { get; internal set; }
        public abstract string name { get; internal set; }
        internal abstract GenericArray<Gist> internal_gists { get; set; }

        public abstract Gist[] list_all();

    }

}
