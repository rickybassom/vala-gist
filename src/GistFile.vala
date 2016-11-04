namespace ValaGist{
    public class GistFile {
        public string filename { get; private set; }
        internal string temp_filename { get; private set; }
        public string g_type { get; private set; }
        public string lanuage { get; private set; }
        public string file_content { get; private set; }
        private string temp_file_content { private get; private set; }
        public string raw_url { get; private set; }
        public string size { get; private set; }

        private Soup.Session session = new Soup.Session();
        private const string BASE_URL = "https://api.github.com";

        // create a gist file object from parameters
        public GistFile.local(string filename, string file_content){
            this.filename = filename;
            this.temp_filename = this.filename;
            this.file_content = file_content;
            this.temp_file_content = this.file_content;
        }

        // create a gist file object a json
        internal GistFile.from_json(Json.Node node){
            this.filename = node.get_object().get_string_member("filename");
            this.temp_filename = this.filename; // temp_filename is used to store changes to the filename so orginal is unchanged
            this.g_type = node.get_object().get_string_member("type");
            this.lanuage = node.get_object().get_string_member("language");
            this.raw_url = node.get_object().get_string_member("raw_url");
            this.size = node.get_object().get_string_member("size");
        }

        // get content of file object
        // refresh states if the user wants to get new content from the server
        public string get_content(bool refresh = false){
            if(file_content != null && !refresh) return file_content;
            var headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            if(MyProfile.token != null){
                headers.append("Authorization", "token %s".printf(MyProfile.token));
            }
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", raw_url);
            Soup.MessageBody body = new Soup.MessageBody();
            msg.request_headers = headers;
            msg.request_body = body;
            session.send_message(msg);
            file_content = (string) msg.response_body.data;
            temp_file_content = file_content;
            return (string) msg.response_body.data;

        }

        // gets to the altered version of the file contents
        internal string get_temp_content(){
            if(temp_file_content == null){
                return get_content();
            }else{
                return temp_file_content;
            }
        }

        public void edit_filename(string filename){
            this.temp_filename = filename;
        }

        public void edit_file_content(string file_content){
            this.temp_file_content = file_content;
        }

    }
}
