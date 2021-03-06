# vala-gist
Gist client library for Vala

```vala
using ValaGist;

public int main (string[] argv) {
    var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

    Gist[] gists = profile.list_all ();
    foreach (Gist gist in gists) {
        print (gist.name + "\n");
        print (gist.description + "\n");
        print (gist.created_at + "\n");

        foreach (GistFile file in gist.files) {
            print (file.filename + "\n");
            print (file.get_content()+ "\n");
        }
    }

    return 0;
}
```
```sh
valac test.vala --pkg valagist-1.0
./test
```

## Dependencies
These dependencies must be present before building

- `meson>=0.40.1`
- `json-glib-1.0`
- `libsoup-2.4`

## Installation

```sh
git clone https://github.com/rickybassom/vala-gist.git
meson build
cd build
ninja # or 'ninja-build' on some distributions
```

## More examples

### Create new gist

```vala
var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

GistFile[] files = {
    new GistFile ("file_name.txt", "file content"),
    new GistFile ("file_name2.txt", "file content 2"),
    new GistFile ("file_name3.txt", "file content 3")
};

profile.create (new Gist ("des", false, files));
```

### Edit gist

```vala
var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

Gist[] gists = profile.list_all ();
Gist edit_gist = gists[0];

edit_gist.edit_description ("Changed description");
edit_gist.files[0].edit_file_content ("changed content");

edit_gist.add_file (
    new GistFile ("newfile.txt", "new file with content!")
);

edit_gist.add_file (
    new GistFile ("newfile2.txt", "new file with content! 2")
);

profile.edit (edit_gist);
```

### Delete files

```vala
var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

Gist[] gists = profile.list_all ();
Gist edit_gist = gists[0];

GistFile[] delete_files = {
    edit_gist.files[0],
    edit_gist.files[1]
};

profile.edit (edit_gist, delete_files);
```

### Delete gist

```vala
var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

Gist[] gists = profile.list_all ();
profile.delete (gists[0]);
```

### Other profiles

```vala
var profile = new MyProfile ("ENTER GITHUB TOKEN HERE");

Gist[] gists = profile.list_all ();
Gist gist = gists[0];
print (gist.owner.name + "\n");
print (gist.owner.id + "\n");
print (gist.owner.list_all ()[0].name);
```

### No login

```vala
OtherProfile user = new OtherProfile ("rickybas");
print (user.name + "\n");
print (user.id + "\n");

Gist[] gists = user.list_all ();
foreach (Gist gist in gists){
    print (gist.name + "\n");
    print (gist.description + "\n");
    print (gist.created_at + "\n");

    foreach (GistFile file in gist.files) {
        print (file.filename + "\n");
        print (file.get_content()+ "\n");
    }
}
```

## Uninstall

```sh
chmod +x uninstall.sh
./uninstall.sh
```

