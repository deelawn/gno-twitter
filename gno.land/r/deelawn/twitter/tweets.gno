package twitter

import "time"

type Tweet struct {
	ID        string // uint64 string
	Author    *User
	Timestamp time.Time
	Comments  []*Comment
	Content   string
}
