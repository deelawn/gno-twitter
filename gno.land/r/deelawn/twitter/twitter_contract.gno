package twitter

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/avl"
)

const (
	maxTweetLength uint = 140
)

var (
	// Users represents all users that have ever posted a tweet.
	Users *avl.Tree
	// Tweets represents all tweets that have ever been posted.
	Tweets *avl.Tree
	// TweetCounter is an atomic counter that is incremented every time a new tweet is posted.
	// The integer is used for the tweet's ID.
	tweetCounter uint64 // TODO: can't use the sync/atomic package. Are integer increments atomic by nature in gno?
)

func init() {
	Users = avl.NewTree()
	Tweets = avl.NewTree()
}

// PostTweet will create a new tweet with the given content and add it to the
// list of tweets for the user that called this function. It returns a reference
// to the new tweet.
func PostTweet(content string) *Tweet {

	author := std.GetOrigCaller()
	return postTweet(author, content)
}

func postTweet(author std.Address, content string) *Tweet {

	if r := []rune(content); len(r) > maxTweetLength {
		panic("tweet is too long")
	}

	user, err := resolveUser(author, true)
	if err != nil {
		panic(err)
	}

	idString := strconv.FormatUint(tweetCounter, 10)
	tweet := &Tweet{
		ID:        idString,
		Author:    user,
		Timestamp: time.Now(),
		Content:   content,
	}

	Tweets.Set(idString, tweet)
	user.Tweets = append(user.Tweets, tweet)
	//atomic.AddUint64(&tweetCounter, 1)
	tweetCounter++

	return tweet
}

// PostComment will create a new comment on the tweet with the given ID and add it to the
// list of comments for the user that called this function. It returns a reference
// to the new comment.
func PostComment(tweetID string, content string) *Comment {

	author := std.GetOrigCaller()
	return postComment(author, tweetID, content)
}

func postComment(author std.Address, tweetID string, content string) *Comment {

	if r := []rune(content); len(r) > maxTweetLength {
		panic("comment is too long")
	}

	user, err := resolveUser(author, true)
	if err != nil {
		panic(err)
	}

	tweetIface, exists := Tweets.Get(tweetID)
	if !exists {
		panic("tweet does not exist")
	}

	tweet, ok := tweetIface.(*Tweet)
	if !ok {
		panic("invalid tweet schema")
	}

	comment := &Comment{
		Author:    user,
		Timestamp: time.Now(),
		Tweet:     tweet,
		Content:   content,
	}

	tweet.Comments = append(tweet.Comments, comment)
	user.Comments = append(user.Comments, comment)

	return comment
}

// FollowUser will add the user with the given address to the list of users that the
// user that called this function follows.
func FollowUser(address std.Address) {

	author := std.GetOrigCaller()
	followUser(author, address)
}

func followUser(author std.Address, address std.Address) {
	user, err := resolveUser(author, true)
	if err != nil {
		panic(err)
	}

	if author.String() == address.String() {
		panic("user cannot follow themself")
	}

	if err := user.Follow(address); err != nil {
		panic(err)
	}
}
