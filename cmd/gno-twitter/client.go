package main

import (
	"context"
	"flag"
	"fmt"
	"os"

	"github.com/gnolang/gno/tm2/pkg/crypto/keys/client"
)

// This client wraps gnokey and is used to more easily interact with the twitter contract.
// Any of the `gnokey maketx call` flags can be added as a part of the command. The only required
// arguments for each client command are listed when displaying the help menu.

const (
	cmdPostTweet   string = "post-tweet"
	cmdPostComment string = "post-comment"
	cmdFollowUser  string = "follow-user"
)

var (
	flagset = flag.NewFlagSet("client", flag.ExitOnError)

	// Required.
	flagAddress = flagset.String("address", "", "required: the address of the user posting the tweet")

	// Optional (or required if defaults are not valid).
	flagPkgPath   = flagset.String("pkg-path", "gno.land/r/deelawn/twitter", "the path to the twitter contract package")
	flagGasFee    = flagset.String("gas-fee", "1000000ugnot", "the gas fee to pay for the transaction")
	flagGasWanted = flagset.String("gas-wanted", "2000000", "the gas limit for the transaction")
	flagChainID   = flagset.String("chainid", "dev", "the chain id for the transaction")
	flagRemote    = flagset.String("remote", "127.0.0.1:26657", "the remote node to connect to")

	baseUsage string = "supported client commands are: post-tweet, post-comment, follow-user"
)

func main() {

	if len(os.Args) < 2 {
		fmt.Println(baseUsage)
		os.Exit(1)
	}

	var gnokeyArgs []string

	switch args := os.Args; args[1] {
	case cmdPostTweet:
		gnokeyArgs = parsePostTweetArgs(args[2:])
	case cmdPostComment:
		gnokeyArgs = parsePostCommentArgs(args[2:])
	case cmdFollowUser:
		gnokeyArgs = parseFollowUserArgs(args[2:])
	default:
		fmt.Println(baseUsage)
		os.Exit(1)
	}

	cmd := client.NewRootCmd()
	if err := cmd.ParseAndRun(context.Background(), gnokeyArgs); err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "%+v\n", err)

		os.Exit(1)
	}
}

func parsePostTweetArgs(args []string) []string {

	content := flagset.String("content", "", "required: the content of the tweet")
	flagset.Parse(args)

	if *content == "" {
		fmt.Println("missing required argument: content")
		os.Exit(1)
	}
	if *flagAddress == "" {
		fmt.Println("missing required argument: address")
		os.Exit(1)
	}

	gnokeyArgs := getBaseArgs()
	gnokeyArgs = append(
		gnokeyArgs,
		"-func", "PostTweet",
		"-args", *content,
		*flagAddress,
	)

	return gnokeyArgs
}

func parsePostCommentArgs(args []string) []string {

	tweetID := flagset.String("tweet-id", "", "required: the id of the tweet to comment on")
	content := flagset.String("content", "", "required: the content of the comment")
	flagset.Parse(args)

	if *tweetID == "" {
		fmt.Println("missing required argument: tweet-id")
		os.Exit(1)
	}
	if *content == "" {
		fmt.Println("missing required argument: content")
		os.Exit(1)
	}
	if *flagAddress == "" {
		fmt.Println("missing required argument: address")
		os.Exit(1)
	}

	gnokeyArgs := getBaseArgs()
	gnokeyArgs = append(
		gnokeyArgs,
		"-func", "PostComment",
		"-args", *tweetID,
		"-args", *content,
		*flagAddress,
	)

	return gnokeyArgs
}

func parseFollowUserArgs(args []string) []string {

	user := flagset.String("user", "", "required: the user to follow")
	flagset.Parse(args)

	if *user == "" {
		fmt.Println("missing required argument: user")
		os.Exit(1)
	}

	gnokeyArgs := getBaseArgs()
	gnokeyArgs = append(
		gnokeyArgs,
		"-func", "FollowUser",
		"-args", *user,
		*flagAddress,
	)

	return gnokeyArgs
}

func getBaseArgs() []string {
	return []string{
		"maketx", "call",
		"-pkgpath", *flagPkgPath,
		"-gas-fee", *flagGasFee,
		"-gas-wanted", *flagGasWanted,
		"-broadcast",
		"-chainid", *flagChainID,
		"-remote", *flagRemote,
	}
}
