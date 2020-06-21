namespace ValaGist {

    public class Gist {
        public string id { get; private set; }
        public string name { get; private set; }
        public string url { get; private set; }
        public string description { get; private set; }
        private string temp_description { private get; private set; }
        public bool is_public { get; private set; }
        internal GenericArray<GistFile> internal_files { get; set; }
        public GistFile[] files {
            get { return this.internal_files.data; }
            private set {}
        }
        private GenericArray<GistFile> temp_files { private get; private set; }
        public string created_at { get; private set; }
        public string updated_at { get; private set; }
        public OtherProfile owner { get; private set; }

        // create a gist object from parameters
        public Gist(string description, bool is_public,
                           GistFile[] files) {
            internal_files = new GenericArray<GistFile>();
            this.internal_files.data = files;

            this.description = description;
            this.temp_description = this.description;
            this.is_public = is_public;
            if(internal_files.length == 0){
                Errors.gist_needs_more_than_one_file();
            }
            this.internal_files.sort((a, b) => { // sort by filename
                CompareFunc<string> strcmp = GLib.strcmp;
                return strcmp(a.filename, b.filename);
            });
            this.temp_files = this.internal_files; // temp_files is used to store changes to the files so orginal is unchanged
            this.name = this.internal_files[0].filename; // first file's name in gist is the name of the whole gist
        }

        // create a gist object a json gist file
        internal Gist.from_json(Json.Node node) {
            this.internal_files = new GenericArray<GistFile>(); // array used to store files of gist

            // set object fields to node properties
            this.id = node.get_object().get_string_member("id");
            this.url = node.get_object().get_string_member("html_url");
            this.description = node.get_object().get_string_member("description");
            this.temp_description = this.description;
            this.is_public = node.get_object().get_boolean_member("public");
            node.get_object().get_object_member("files").foreach_member((arr, index, node) => { // loop through array files in json and append GistFile object to array
                this.internal_files.add(new GistFile.from_json(node)); // constructor in GistFile.from_json extracts data from node into object fields
            });
            this.temp_files = this.internal_files; // temp_files is used to store changes to the files so orginal is unchanged
            this.name = this.internal_files[0].filename; // first file's name in gist is the name of the whole gist
            this.created_at = node.get_object().get_string_member("created_at");
            this.updated_at = node.get_object().get_string_member("updated_at");
            this.owner = new OtherProfile.from_json(node);
        }

        // converts object to json
        public string to_json(bool use_temp = false, GistFile[] delete_files = {}) {
            // See below for example gist in json format
            var generator = new Json.Generator ();

            var builder = new Json.Builder ();
            builder.begin_object (); // {

            builder.set_member_name ("description")
                .add_string_value (use_temp ? temp_description : description); // "description": "description of gist",

            builder.set_member_name ("public")
                .add_boolean_value (is_public); // "public": true,

            var files_json = builder.set_member_name ("files");
            files_json.begin_object (); // "files": {
            (use_temp ? temp_files : this.internal_files).foreach((file) => {
                // get files to delete from changed filenames
                if (file.temp_filename != file.filename) {
                    files_json.set_member_name (file.filename)
                        .add_null_value (); // "this is a filename": null
                }

                files_json.set_member_name (file.filename);
                files_json.begin_object (); // "this is a filename": {
                files_json.set_member_name ("filename");
                files_json.add_string_value (use_temp ? file.temp_filename : file.filename); // "filename": "this is a filename",
                files_json.set_member_name ("content");
                files_json.add_string_value (use_temp ? file.get_temp_content() : file.get_content()); // "content": "contents of gist"
                files_json.end_object (); // }
            });
            if (delete_files.length != 0) {
                foreach (GistFile delete_file in delete_files) {
                    files_json.set_member_name (delete_file.filename)
                        .add_null_value (); // "this is a filename": null
                }
            }
            files_json.end_object (); // }

            builder.end_object (); // }

            generator.set_root (builder.get_root ());
            return generator.to_data (null);
        }

        // checks if filename is in the gists files
        internal bool includes_file(string filename) {
            bool found = false;
            this.internal_files.foreach((file) => {
                if(file.filename == filename){
                    found = true;
                    return;
                }
            });
            return found;
        }

        public void edit_description(string description) {
            this.temp_description = description;  // changes non-orginal copy of description
        }

        public void add_file(GistFile file) {
            this.temp_files.add (file); // changes non-orginal copy of files
        }

        public void replace_with_files (GistFile[] files) {
            this.temp_files.data = files;
        }
    }

}


/*
Example gist
{
  "url": "https://api.github.com/gists/aa5a315d61ae9438b18d",
  "forks_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/forks",
  "commits_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/commits",
  "id": "aa5a315d61ae9438b18d",
  "description": "description of gist",
  "public": true,
  "owner": {
    "login": "octocat",
    "id": 1,
    "avatar_url": "https://github.com/images/error/octocat_happy.gif",
    "gravatar_id": "",
    "url": "https://api.github.com/users/octocat",
    "html_url": "https://github.com/octocat",
    "followers_url": "https://api.github.com/users/octocat/followers",
    "following_url": "https://api.github.com/users/octocat/following{/other_user}",
    "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
    "organizations_url": "https://api.github.com/users/octocat/orgs",
    "repos_url": "https://api.github.com/users/octocat/repos",
    "events_url": "https://api.github.com/users/octocat/events{/privacy}",
    "received_events_url": "https://api.github.com/users/octocat/received_events",
    "type": "User",
    "site_admin": false
  },
  "user": null,
  "files": {
    "this is a filename": {
      "filename": "this is a filename",
      "size": 932,
      "raw_url": "https://gist.githubusercontent.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl",
      "type": "text/plain",
      "language": "Erlang",
      "truncated": false,
      "content": "contents of gist"
    }
  },
  "truncated": false,
  "comments": 0,
  "comments_url": "https://api.github.com/gists/aa5a315d61ae9438b18d/comments/",
  "html_url": "https://gist.github.com/aa5a315d61ae9438b18d",
  "git_pull_url": "https://gist.github.com/aa5a315d61ae9438b18d.git",
  "git_push_url": "https://gist.github.com/aa5a315d61ae9438b18d.git",
  "created_at": "2010-04-14T02:15:15Z",
  "updated_at": "2011-06-20T11:34:15Z",
  "forks": [
    {
      "user": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "",
        "url": "https://api.github.com/users/octocat",
        "html_url": "https://github.com/octocat",
        "followers_url": "https://api.github.com/users/octocat/followers",
        "following_url": "https://api.github.com/users/octocat/following{/other_user}",
        "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
        "organizations_url": "https://api.github.com/users/octocat/orgs",
        "repos_url": "https://api.github.com/users/octocat/repos",
        "events_url": "https://api.github.com/users/octocat/events{/privacy}",
        "received_events_url": "https://api.github.com/users/octocat/received_events",
        "type": "User",
        "site_admin": false
      },
      "url": "https://api.github.com/gists/dee9c42e4998ce2ea439",
      "id": "dee9c42e4998ce2ea439",
      "created_at": "2011-04-14T16:00:49Z",
      "updated_at": "2011-04-14T16:00:49Z"
    }
  ],
  "history": [
    {
      "url": "https://api.github.com/gists/aa5a315d61ae9438b18d/57a7f021a713b1c5a6a199b54cc514735d2d462f",
      "version": "57a7f021a713b1c5a6a199b54cc514735d2d462f",
      "user": {
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        "gravatar_id": "",
        "url": "https://api.github.com/users/octocat",
        "html_url": "https://github.com/octocat",
        "followers_url": "https://api.github.com/users/octocat/followers",
        "following_url": "https://api.github.com/users/octocat/following{/other_user}",
        "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
        "organizations_url": "https://api.github.com/users/octocat/orgs",
        "repos_url": "https://api.github.com/users/octocat/repos",
        "events_url": "https://api.github.com/users/octocat/events{/privacy}",
        "received_events_url": "https://api.github.com/users/octocat/received_events",
        "type": "User",
        "site_admin": false
      },
      "change_status": {
        "deletions": 0,
        "additions": 180,
        "total": 180
      },
      "committed_at": "2010-04-14T02:15:15Z"
    }
  ]
}
*/

