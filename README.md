# vala-gist
Gist client library for Vala

## Build and Install
```sh
mkdir build/ && cd build
meson ..
ninja-build # or 'ninja' on some distributions
sudo ninja-build install
```

## Example
```vala
using ValaGist;

public static int main(string[] argv) {
    MyProfile profile = new MyProfile.login("ENTER GITHUB TOKEN HERE");

    GLib.GenericArray<Gist> gists = profile.list_all();
    gists.foreach ((gist) => {
        print(gist.name + " - ");
        print(gist.id + " - ");
        print(gist.url + " - ");
        print(gist.description + " - ");
        print(gist.created_at + " - ");
        print(gist.updated_at + " - ");
        print(gist.is_public ? "public" : "not public");

        gist.files.foreach((file) => {
            print("\n   " + file.filename + " - " + file.raw_url);
            print("\n" + file.get_content());
        });

        print("\n------------\n");
   });
   return 0;
}
```


```sh
valac test.vala --pkg valagist-1.0
./test
```

