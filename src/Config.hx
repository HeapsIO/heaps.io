import Utils.*;

class Config {
    static public var htmlDir  = env("GHP_HTMLDIR",  "output");
    static public var remote   = env("GHP_REMOTE",   null); // should be in the form of https://token@github.com/account/repo.git
    static public var branch   = env("GHP_BRANCH",   "gh-pages");
    static public var username = env("GHP_USERNAME", null);
    static public var email    = env("GHP_EMAIL",    null);
    static public var cname    = env("GHP_CNAME",    null);
}