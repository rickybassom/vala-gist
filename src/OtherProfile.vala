namespace ValaGist {

    public class OtherProfile : Profile, Object {

        public string id { get; internal set; }
        public string name { get; internal set; }
        internal GenericArray<Gist> internal_gists { get; set; }

        private Soup.Session session = new Soup.Session();
        private Json.Parser parser = new Json.Parser();
        private const string BASE_URL = "https://api.github.com";

        public OtherProfile.from_username(string name, bool check=true) throws ValaGist.Error {
            this.internal_gists = new GenericArray<Gist>();
            if(check){ // if wants to check if token if correct at contructor
                if(user_exists(name)){
                    this.name = name;
                }
            }else{
                this.name = name;
            }
        }

        private bool user_exists(string name) throws ValaGist.Error {
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            if(MyProfile.token != null){ // if actual user loged in
                headers.append("Authorization", "token %s".printf(MyProfile.token));  // not essential for requests but increases rate limit
            }
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/users/%s".printf(name));
            Soup.MessageBody body = new Soup.MessageBody();
            msg.request_headers = headers;
            msg.request_body = body;
            session.send_message(msg);

            if (msg.status_code != 200) { // if error in response
                if (msg.status_code == 401) { // unauthorized
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

        // create OtherProfile object from json object
        internal OtherProfile.from_json(Json.Node node){
            this.internal_gists = new GenericArray<Gist>();
            this.id = node.get_object().get_object_member("owner").get_int_member("id").to_string();
            this.name = node.get_object().get_object_member("owner").get_string_member("login");
        }

        public Gist[] list_all(bool fetch_from_server = true){
            if(!fetch_from_server && this.internal_gists.length != 0) return this.internal_gists.data;
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            if(MyProfile.token != null){ // if actual user loged in
                headers.append("Authorization", "token %s".printf(MyProfile.token)); // not essential for requests but increases rate limit
            }
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/users/%s/gists".printf(this.name));
            Soup.MessageBody body = new Soup.MessageBody();
            msg.request_headers = headers;
            msg.request_body = body;
            session.send_message(msg);

            if (msg.status_code != 200) { // if error in response
                if (msg.status_code == 401) { // unauthorized
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
                    root_object.foreach_element((arr, index, node) => { // for each gist in json
                        this.internal_gists.add(new Gist.from_json(node)); // append the this.internal_gists field a Gist object from the json of the gist
                    });
                }catch(Error e){
                    print(e.message);
                }
            }

            return this.internal_gists.data;
        }

    }

}
