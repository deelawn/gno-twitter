package twitter

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/avl"
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
