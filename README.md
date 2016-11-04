# vala-gist
Gist client library for Vala

```vala
using ValaGist;

public int main(string[] argv) {
    var profile = new MyProfile.login("ENTER GITHUB TOKEN HERE");

    Gist[] gists = profile.list_all();
    foreach (Gist gist in gists){
        print(gist.name + "\n");
        print(gist.description + "\n");
        print(gist.created_at + "\n");

        foreach (GistFile file in gist.files){
            print(file.filename + "\n");
            print(file.get_content()+ "\n");
        }

        print("\n");
    }
    return 0;
}
```
```sh
valac test.vala --pkg valagist-1.0
./test
```

## Installation
```sh
mkdir build/ && cd build
meson ..
ninja-build # or 'ninja' on some distributions
sudo ninja-build install
```

## Examples

### Create new gist

```vala

```
