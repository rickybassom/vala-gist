using ValaGist;

public int main (string[] args) {
    OtherProfile user = new OtherProfile("rickybassom", true);
    string name = user.name;
    string id = user.id;

    Gist[] gists = user.list_all();
    foreach (Gist gist in gists){
        string gist_name = gist.name;
        string gist_description = gist.description;
        string gist_created_at = gist.created_at;

        foreach (GistFile file in gist.files){
            string file_name = file.filename;
            string file_cont = file.get_content();
        }

    }
    return 0;
}
