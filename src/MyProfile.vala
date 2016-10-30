namespace ValaGist {

    public class MyProfile : Profile, Object {

        public string id { get; internal set; }
        public string name { get; internal set; }
        public GenericArray<Gist> gists { get; internal set; }
        public static string token { get; private set; }

        private Soup.Session session = new Soup.Session();
        private Json.Parser parser = new Json.Parser();
        private const string BASE_URL = "https://api.github.com";

        public MyProfile.login(string token, bool check = true) throws ValaGist.Error{
            gists = new GenericArray<Gist>();
            if(check){ // if wants to check if token if correct at contructor
                if(auth_success(token)){
                    this.token = token;
                }
            }else{
                this.token = token;
            }
        }

        // not sure if useful
        public void relogin(string token, bool check=true) throws ValaGist.Error{
            if(check){
                if(auth_success(token)){
                    this.token = token;
                }
            }else{
                this.token = token;
            }
        }

        private bool auth_success(string token) throws ValaGist.Error{
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            headers.append("Authorization", "token %s".printf(token));
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/user");
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

        public GenericArray<Gist> list_all(){
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            headers.append("Authorization", "token %s".printf(token));
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("GET", BASE_URL + "/gists");
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
                }catch(Error e){
                    print(e.message);
                }
                Json.Array root_object = parser.get_root().get_array();
                root_object.foreach_element((arr, index, node) => { // for each gist in json
                    gists.add(new Gist.from_json(node)); // append the this.gists field a Gist object from the json of the gist
                });
            }

            return gists;
        }

        public Gist create(Gist gist){
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            headers.append("Authorization", "token %s".printf(token));
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("POST", BASE_URL + "/gists");
            Soup.MessageBody body = new Soup.MessageBody();

            body.append_take(gist.to_json().data); // to_json() converts object to json. add to request body

            msg.request_headers = headers;
            msg.request_body = body;

            session.send_message(msg);

            if (msg.status_code != 201) { // if error in response
                if (msg.status_code == 401) { // unauthorized
                    Errors.incorrect_token(msg.status_code);
                }else{
                    if(msg.response_headers.get_one("X-RateLimit-Remaining") == "0"){
                        Errors.rate_limit_exceeded();
                    }else{
                        Errors.other_network(msg.status_code);
                    }
                }
            }
            Json.Node root = new Json.Node(Json.NodeType.OBJECT);
            try{
                parser.load_from_data((string) msg.response_body.flatten().data, -1);
                root.set_object(parser.get_root().get_object());
            }catch(Error e){
                print(e.message);
            }
            // TODO: append created gist to profile
            return new Gist.from_json(root); // return gist created on server
        }

        public Gist edit(Gist gist, GenericArray<GistFile>? delete_files = null){
            if(gist.id == null){ // gist not on server
                Errors.gist_not_on_server(gist.name);
            }
            else if(gist.owner.id != this.id){ // if the gist has not been created by this user
                Errors.gist_not_owned(this.name, gist.name);
            }
            else if(delete_files != null){
                delete_files.foreach((delete_file) => {
                    if(!gist.includes_file(delete_file.filename)){ // if gist does not include file
                        Errors.gist_file_not_found_for_delete(delete_file.filename);
                    }
                });
            }
            Soup.MessageHeaders headers = new Soup.MessageHeaders(Soup.MessageHeadersType.REQUEST);
            headers.append("Authorization", "token %s".printf(token));
            headers.append("User-Agent", "vala-gist");
            Soup.Message msg = new Soup.Message("PATCH", BASE_URL + "/gists/" + gist.id);
            Soup.MessageBody body = new Soup.MessageBody();

            if(delete_files == null){
                body.append_take(gist.to_json(true).data);
            }else{
                body.append_take(gist.to_json(true, delete_files).data);
            }

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
            }

            Json.Node root = new Json.Node(Json.NodeType.OBJECT);
            try{
                parser.load_from_data((string) msg.response_body.flatten().data, -1);
                root.set_object(parser.get_root().get_object());
            }catch(Error e){
                print(e.message);
            }
            // TODO: change edited gist in profile gist array
            return new Gist.from_json(root); // return edited gist from server
        }

    }

}
