namespace ValaGist {

    public class OtherProfile : Profile, Object {

        public string id { get; internal set; }
        public string name { get; internal set; }
        public GenericArray<Gist> gists { get; internal set; }

        private Soup.Session session = new Soup.Session();
        private Json.Parser parser = new Json.Parser();
        private const string BASE_URL = "https://api.github.com";

        public OtherProfile.from_username(string name, bool check=true) throws ValaGist.Error {
            gists = new GenericArray<Gist>();
            if(check){
                if(user_exists(name)){
                    this.name = name;
                }
            }else{
                this.name = name;
            }
        }

        private bool user_exists(string name) throws ValaGist.Error {
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            if(MyProfile.token != null){
                headers.append("Authorization", "token %s".printf(MyProfile.token));
            }
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/users/%s".printf(name));
            Soup.MessageBody body = new Soup.MessageBody();
            msg.request_headers = headers;
            msg.request_body = body;
            session.send_message(msg);

            if (msg.status_code != 200) {
                if (msg.status_code == 401) {
                    Errors.incorrect_token(msg.status_code);
                }else{
                    if(msg.response_headers.get_one("X-RateLimit-Remaining") == "0"){
                        Errors.rate_limit_exceeded();
                    }else{
                        Errors.other_network(msg.status_code);
                    }
                }
                return false;
            }else{
                try{
                    parser.load_from_data ((string) msg.response_body.data, -1);
                }catch(Error e){
                    print(e.message);
                }
                Json.Object root_object = parser.get_root ().get_object ();
                this.id = root_object.get_int_member ("id").to_string();
                this.name = root_object.get_string_member ("login");
            }
            return true;
        }

        internal OtherProfile.from_json(Json.Node node){
            gists = new GenericArray<Gist>();
            this.id = node.get_object().get_object_member("owner").get_int_member("id").to_string();
            this.name = node.get_object().get_object_member("owner").get_string_member("login");
        }

        public GenericArray<Gist> list_all(){
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            if(MyProfile.token != null){
                headers.append("Authorization", "token %s".printf(MyProfile.token));
            }
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/users/%s/gists".printf(this.name));
            Soup.MessageBody body = new Soup.MessageBody();
            msg.request_headers = headers;
            msg.request_body = body;
            session.send_message(msg);

            if (msg.status_code != 200) {
                if (msg.status_code == 401) {
                    Errors.incorrect_token(msg.status_code);
                }else{
                    if(msg.response_headers.get_one("X-RateLimit-Remaining") == "0"){
                        Errors.rate_limit_exceeded();
                    }else{
                        Errors.other_network(msg.status_code);
                    }
                }
            }else{
                try{
                    parser.load_from_data ((string) msg.response_body.data, -1);

                    Json.Array root_object = parser.get_root().get_array();
                    root_object.foreach_element((arr, index, node) => {
                        gists.add(new Gist.from_json(node));
                    });
                }catch(Error e){
                    print(e.message);
                }
            }

            return gists;
        }

    }

}
