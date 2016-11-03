# vala-gist
Gist client library for Vala

```vala
using ValaGist;

public static int main(string[] argv) {
    MyProfile profile = new MyProfile.login("ENTER GITHUB TOKEN HERE");

    GLib.GenericArray<Gist> gists = profile.list_all();
    gists.foreach ((gist) => {
        print(gist.name + "\n");
        print(gist.description + "\n");
        print(gist.created_at + "\n");

        gist.files.foreach((file) => {
            print(file.filename + "\n");
            print(file.get_content()+ "\n");
        });

        print("\n");
   });
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
