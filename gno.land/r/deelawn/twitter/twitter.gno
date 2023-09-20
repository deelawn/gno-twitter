package twitter

import (
	"std"
	"time"

	"gno.land/p/demo/avl"
)

var (
	// Users represents all users that have ever posted a tweet.
	Users *avl.Tree
	// Tweets represents all tweets that have ever been posted.
	// Tweets []*Tweet
)

func init() {
	Users = avl.NewTree()
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

	tweet := &Tweet{
		Author:    user,
		Timestamp: time.Now(),
		Content:   content,
	}

	user.Tweets = append(user.Tweets, tweet)
	return tweet
}
