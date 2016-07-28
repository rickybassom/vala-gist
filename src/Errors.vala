namespace ValaGist {

    public errordomain Error {
        NULL,
        FAILED,
        INVALID,
        TYPE
    }

    internal class Errors {
        public static void incorrect_token(uint error_code) throws ValaGist.Error {
            throw new Error.FAILED("Invalid token, error from github. \nError code: " + error_code.to_string());
        }
        public static void other_network(uint error_code) throws ValaGist.Error {
            throw new Error.FAILED("Error from github. \nError code: " + error_code.to_string());
        }
        public static void rate_limit_exceeded() throws ValaGist.Error {
            throw new Error.FAILED("API rate limit exceeded, error from github.");
        }
        public static void gist_not_owned(string username, string name) throws ValaGist.Error {
            throw new Error.FAILED("Gist \"%s\" not owned by %s.".printf(name, username));
        }
        public static void gist_file_not_found_for_delete(string file_name) throws ValaGist.Error {
            throw new Error.FAILED("Gist file \"%s\" not found for deletion.".printf(file_name));
        }
        public static void gist_needs_more_than_one_file() throws IOError {
            throw new Error.FAILED("Gist needs more than one file.");
        }
    }
}
