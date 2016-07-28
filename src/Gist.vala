namespace ValaGist{

    public class Gist {

        public string id { get; private set; }
        public string name { get; private set; }
        public string url { get; private set; }
        public string description { get; private set; }
        private string temp_description { private get; private set; }
        public bool is_public { get; private set; }
        public GenericArray<GistFile> files { get; private set; }
        private GenericArray<GistFile> temp_files { private get; private set; }
        public string created_at { get; private set; }
        public string updated_at { get; private set; }
        public OtherProfile owner { get; private set; }

        public Gist.local(string description, bool is_public,
                           GenericArray<GistFile> files){
            this.description = description;
            this.temp_description = this.description;
            this.is_public = is_public;
            if(files.length == 0){
                Errors.gist_needs_more_than_one_file();
            }
            this.files = files;
            this.files.sort((a, b) => {
                CompareFunc<string> strcmp = GLib.strcmp;
                return strcmp(a.filename, b.filename);
            });
            this.temp_files = this.files;
            this.name = files[0].filename;
        }

        internal Gist.from_json(Json.Node node){
            files = new GenericArray<GistFile>();

            this.id = node.get_object().get_string_member("id");
            this.url = node.get_object().get_string_member("html_url");
            this.description = node.get_object().get_string_member("description");
            this.temp_description = this.description;
            this.is_public = node.get_object().get_boolean_member("public");
            node.get_object().get_object_member("files").foreach_member((arr, index, node) => {
                files.add(new GistFile.from_json(node));
            });
            this.temp_files = this.files;
            this.name = files[0].filename;
            this.created_at = node.get_object().get_string_member("created_at");
            this.updated_at = node.get_object().get_string_member("updated_at");
            this.owner = new OtherProfile.from_json(node);
        }

        internal string to_json(bool use_temp = false, GenericArray<GistFile>? delete_files = null) {
            var generator = new Json.Generator ();

            var builder = new Json.Builder ();
            builder.begin_object ();

            builder.set_member_name ("description")
                .add_string_value (use_temp ? temp_description : description);

            builder.set_member_name ("public")
                .add_boolean_value (is_public);

            var files_json = builder.set_member_name ("files");
            files_json.begin_object ();
            (use_temp ? temp_files : files).foreach((file) => {
                files_json.set_member_name (file.filename);
                files_json.begin_object ();
                files_json.set_member_name ("filename");
                files_json.add_string_value (use_temp ? file.temp_filename : file.filename);
                files_json.set_member_name ("content");
                files_json.add_string_value (use_temp ? file.get_temp_content() : file.get_content());
                files_json.end_object ();
            });
            if(delete_files != null){
                delete_files.foreach((delete_file) => {
                    files_json.set_member_name (delete_file.filename)
                        .add_null_value ();
                });
            }
            files_json.end_object ();

            builder.end_object ();

            generator.set_root (builder.get_root ());
            return generator.to_data (null);
        }

        internal bool includes_file(string filename){
            bool found = false;
            files.foreach((file) => {
                if(file.filename == filename){
                    found = true;
                    return;
                }
            });
            return found;
        }

        public void edit_description(string description){
            this.temp_description = description;
        }

        public void edit_add_file(GistFile file){
            this.temp_files.add(file);
        }

    }

}
