package twitter

import (
	"std"
	"testing"
	"time"
)

// Take note that these tests test unexported functions thinly wrapped by the exported
// contract functions. This is because I'm not sure how to mock out the std package and
// every contract call needs to obtain the calling user's address from std.GetOrigCaller().

func Test_postTweet(t *testing.T) {

	tests := []struct {
		name     string
		author   std.Address
		content  string
		expPanic bool
	}{
		{
			name:     "content too long panic",
			author:   std.Address("g1kgqpv6gqnvqvghaqd8ptlke436qtg7wjz87wsf"),
			content:  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
			expPanic: true,
		},
		{
			name:    "valid tweet",
			author:  std.Address("g1kgqpv6gqnvqvghaqd8ptlke436qtg7wjz87wsf"),
			content: "tweettweet it's called X now",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			start := time.Now()

			// For testing panic cases.
			defer func() { recover() }()

			tweet := postTweet(tt.author, tt.content)

			// It should have panicked if this is true.
			if tt.expPanic {
				t.Fatal("expected panic")
			}

			// Test that the tweet that was created looks to be correct.

			if tweet.Author.Address.String() != tt.author.String() {
				t.Errorf("wanted address %s, got %s", tt.author.String(), tweet.Author.Address.String())
			}

			if tweet.Content != tt.content {
				t.Errorf("wanted content %s, got %s", tt.content, tweet.Content)
			}

			if tweet.Timestamp.Before(start) {
				t.Errorf("wanted timestamp after %s, got %s", start.String(), tweet.Timestamp.String())
			}

			if len(tweet.Comments) != 0 {
				t.Errorf("wanted no comments, got %d", len(tweet.Comments))
			}

			// Then test that the tweet and user are registered in the global state trees as expected.

			userIface, exists := Users.Get(tt.author.String())
			if !exists {
				t.Errorf("wanted user %s to exist, but they do not", tt.author.String())
			}

			tweetIface, exists := Tweets.Get(tweet.ID)
			if !exists {
				t.Errorf("wanted tweet %s to exist, but it does not", tweet.ID)
			}
		})
	}
}
