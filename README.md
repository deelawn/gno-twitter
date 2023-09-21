# gno-twitter

![gno twitter app flow](flow.jpg "App Flow")

## Supported Operations

The three supported operations are:
- Create post
- Comment on post
- Follow user

## Supported renderings

Supported html renderings are mapped below, URL -> data displayed.

- `.../twitter` -> displays a list of all users addresses that have posted a tweet or comment
- `.../twitter:users` -> same as previous
- `.../twitter:users/<user address>` -> displays the number of users they follow and a list of condensed tweets, ordered by newest
- `.../twitter:users/<user address>/follows` -> displays a list of all users the user with this address follows
- `.../twitter:tweets/<tweet id>` -> displays a full tweet and all comments, ordered by oldest

## Testing

I've included tests for posting tweets. It seemed cumbersome to repeat the process for each contract function, but this should be
good enough to illustrate the approach I might use for testing this, and writing test cases in go generally.

## Improvements

There is defintely room for improvement. I timeboxed myself so I wouldn't go too crazy with it but I still went a bit over.
Here are some recommendations for things that would need to be added to make this app more production ready:

- perhaps utilzing the built in user modules rather than relying on managing this in the app itself
- better select tweet keys so that they can be ranged over to show the N most recent tweets in a feed
- use go templating to improve and make rendering easier
- use existing or create a simple path router to clean up the code around path parsing in the `Render` function
- support more lifecycle methods around tweets and comments (update, delete) and follow (unfollow)
- would need to think more about different rederings desired by users and come up with ways to try to efficiently store data
to be able to render them quickly
- managing state data also becomes important depending on the size of the application
- integers represented as strings as tweet keys are not ideal
- allow users to set human readable names

## Examples for deploying and interacting with the contract

Make sure there are two users created, test and sally, before trying this. Execute the `maketx` command
from within the `gno.land/r/deelawn/twitter` directory.

Verify everything works by firing up `gnoweb` locally and navigating to `http://localhost:8888/r/deelawn/twitter:tweets/1`
### Deployment

```
gnokey maketx addpkg \
-deposit="1ugnot" \
-gas-fee="1ugnot" \
-gas-wanted="5000000" \
-broadcast="true" \
-remote="localhost:26657" \
-chainid="dev" \
-pkgdir="." \
-pkgpath="gno.land/r/deelawn/twitter" \
test
```

### Interacting via gnokey

```
Post a tweet

gnokey maketx call -pkgpath "gno.land/r/deelawn/twitter" -func "PostTweet" -gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" -args "my first tweet" -remote "127.0.0.1:26657" test

Post another tweet

gnokey maketx call -pkgpath "gno.land/r/deelawn/twitter" -func "PostTweet" -gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" -args "this one is really loooooooooooooooooooooooooooooooooooooooooooonnnngggggg" -remote "127.0.0.1:26657" test

Post a comment
 
gnokey maketx call -pkgpath "gno.land/r/deelawn/twitter" -func "PostComment" -gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" -args "1" -args "i personally like second posts better than first posts" -remote "127.0.0.1:26657" sally

Follow sally

gnokey maketx call -pkgpath "gno.land/r/deelawn/twitter" -func "FollowUser" -gas-fee 1000000ugnot -gas-wanted 2000000 -send "" -broadcast -chainid "dev" -args "g1ds4pvhlsj09lxme6up9av27jlveppscgrfuu69" -remote "127.0.0.1:26657" test
```

### Interacting via the twitter client

This will work assuming all of the flags show above in the gnokey examples also apply now.

Install it
`go install github.com/deelawn/gno-twitter/cmd/gno-twitter`

And use it
```
gno-twitter post-tweet -content "my first tweet" -address test

gno-twitter post-tweet -content "this one is really loooooooooooooooooooooooooooooooooooooooooooonnnngggggg" -address test

gno-twitter post-comment -tweet-id 1 -content "i personally like second posts better than first posts" -address sally

gno-twitter follow-user -user g1ds4pvhlsj09lxme6up9av27jlveppscgrfuu69 -address test
```